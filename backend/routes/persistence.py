from datetime import date, datetime, timedelta
import random
import string
import unicodedata
import uuid

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy import text
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from backend.config.database import get_db

router = APIRouter(tags=["persistence"])

SCHEMA = "nutri_esportiva"
VALID_ROLES = {"atleta", "medico", "nutricionista"}
VALID_SEXOS = {"masculino", "feminino", "outro", "nao_informado"}


class LoginRequest(BaseModel):
    email: str
    senha: str
    tipo: str


class AtletaCreateRequest(BaseModel):
    nome: str
    email: str
    senha: str
    dataNascimento: date
    altura: float
    peso: float
    sexo: str


class ProfissionalCreateRequest(BaseModel):
    nome: str
    email: str
    senha: str
    tipo: str
    registro: str


class AtletaUpdateRequest(BaseModel):
    peso: float | None = None
    altura: float | None = None
    dataNascimento: date | None = None
    sexo: str | None = None


class ProfissionalAtletaRequest(BaseModel):
    codigo: str


class NotaCreateRequest(BaseModel):
    profissionalId: int
    profissionalTipo: str
    titulo: str
    conteudo: str


class TreinoCreateRequest(BaseModel):
    atletaId: str
    modalidade: str
    duracaoMinutos: int
    duracaoPrevistaMin: int | None = None
    duracaoRealSegundos: int | None = None
    fluidosMl: int
    alimentosAgua: str = ""
    volumeUrinarioMl: int | None = None
    massaCorporalPreKg: float
    massaCorporalPosKg: float
    escalaBorg: int
    sensacaoTermica: float | None = None
    vento: str = ""
    exposicaoSolar: str = ""
    corUrina: str | int | None = None
    vestimenta: str = ""
    equipamento: str = ""
    estaComSede: bool = False
    sintomasPreDescricao: str = ""
    historicoHidratacao: str = ""
    roupasEncharcadas: bool = False
    trocaVestimenta: bool = False
    observacaoRoupas: str = ""
    teveSintomasGastro: bool
    sintomasDescricao: str = ""
    teveFadiga: bool
    fadigaDescricao: str = ""
    temperatura: int
    umidade: int


def _role_from_row(row) -> str | None:
    if row["is_atleta"]:
        return "atleta"
    if row["is_medico"]:
        return "medico"
    if row["is_nutricionista"]:
        return "nutricionista"
    return None


def _usuario_response(row, tipo: str) -> dict:
    return {
        "id": str(row["id"]),
        "nome": row["nome"],
        "email": row["email"],
        "tipo": tipo,
        "codigo": row.get("codigo"),
    }


def _gerar_codigo_acesso(db: Session) -> str:
    for _ in range(20):
        letras = "".join(random.choice(string.ascii_uppercase) for _ in range(3))
        numeros = "".join(random.choice(string.digits) for _ in range(3))
        codigo = f"{letras}{numeros}"
        existe = db.execute(
            text(f"select 1 from {SCHEMA}.atletas where codigo_acesso = :codigo"),
            {"codigo": codigo},
        ).first()
        if not existe:
            return codigo
    raise HTTPException(status_code=500, detail="Nao foi possivel gerar codigo de acesso.")


def _normalizar_altura(altura: float) -> float:
    altura_metros = altura / 100 if altura > 3 else altura
    if altura_metros <= 0:
        raise HTTPException(status_code=400, detail="Altura deve ser maior que zero.")
    return altura_metros


def _validar_peso(peso: float) -> float:
    if peso <= 0:
        raise HTTPException(status_code=400, detail="Peso deve ser maior que zero.")
    return peso


def _normalizar_sexo(sexo: str) -> str:
    valor = (
        unicodedata.normalize("NFKD", sexo or "")
        .encode("ascii", "ignore")
        .decode("ascii")
        .strip()
        .lower()
        .replace(" ", "_")
    )
    if valor not in VALID_SEXOS:
        raise HTTPException(status_code=400, detail="Sexo invalido.")
    return valor


def _criar_auth_user_e_pessoa(db: Session, nome: str, email: str, senha: str):
    auth_user_id = str(uuid.uuid4())
    db.execute(
        text(
            """
            insert into auth.users (
              id,
              aud,
              role,
              email,
              encrypted_password,
              email_confirmed_at,
              raw_app_meta_data,
              raw_user_meta_data,
              created_at,
              updated_at
            )
            values (
              cast(:auth_user_id as uuid),
              'authenticated',
              'authenticated',
              :email,
              crypt(cast(:senha as text), gen_salt('bf')),
              now(),
              '{"provider":"email","providers":["email"]}'::jsonb,
              jsonb_build_object('name', cast(:nome as text)),
              now(),
              now()
            )
            """
        ),
        {"auth_user_id": auth_user_id, "email": email, "senha": senha, "nome": nome},
    )
    return db.execute(
        text(
            f"""
            insert into {SCHEMA}.pessoas (nome, email, auth_user_id)
            values (:nome, :email, :auth_user_id)
            returning id
            """
        ),
        {"nome": nome, "email": email, "auth_user_id": auth_user_id},
    ).mappings().one()


def _buscar_usuario_por_login(db: Session, email: str, senha: str):
    return db.execute(
        text(
            f"""
            select
              p.id,
              p.nome,
              p.email,
              a.codigo_acesso as codigo,
              a.id is not null as is_atleta,
              m.id is not null as is_medico,
              n.id is not null as is_nutricionista
            from auth.users u
            join {SCHEMA}.pessoas p on p.auth_user_id = u.id
            left join {SCHEMA}.atletas a on a.id = p.id
            left join {SCHEMA}.medicos m on m.id = p.id
            left join {SCHEMA}.nutricionistas n on n.id = p.id
            where lower(u.email) = lower(:email)
              and u.encrypted_password = crypt(:senha, u.encrypted_password)
              and u.deleted_at is null
            limit 1
            """
        ),
        {"email": email, "senha": senha},
    ).mappings().first()


def _buscar_atleta(db: Session, identificador: str):
    query = f"""
        select
          a.id,
          p.nome,
          p.email,
          a.codigo_acesso as codigo,
          a.altura,
          a.peso,
          case when a.data_nasc = date '2000-01-01' then null else a.data_nasc end as data_nasc,
          case
            when a.data_nasc = date '2000-01-01' then null
            else extract(year from age(current_date, a.data_nasc))::int
          end as idade,
          a.sexo
        from {SCHEMA}.atletas a
        join {SCHEMA}.pessoas p on p.id = a.id
        where upper(a.codigo_acesso) = upper(:identificador)
           or cast(a.id as text) = :identificador
        limit 1
    """
    return db.execute(text(query), {"identificador": identificador}).mappings().first()


def _buscar_profissional(db: Session, profissional_id: int):
    return db.execute(
        text(
            f"""
            select
              p.id,
              p.nome,
              p.email,
              m.id is not null as is_medico,
              n.id is not null as is_nutricionista
            from {SCHEMA}.pessoas p
            left join {SCHEMA}.medicos m on m.id = p.id
            left join {SCHEMA}.nutricionistas n on n.id = p.id
            where p.id = :id
            """
        ),
        {"id": profissional_id},
    ).mappings().first()


def _tipo_profissional(row) -> str | None:
    if row["is_medico"]:
        return "medico"
    if row["is_nutricionista"]:
        return "nutricionista"
    return None


def _profissional_vinculado_ao_atleta(
    db: Session,
    profissional_id: int,
    atleta_id: int,
    profissional_tipo: str,
) -> bool:
    if profissional_tipo == "medico":
        tabela_vinculo = "medicos_atletas"
        coluna_profissional = "medicos_id"
    elif profissional_tipo == "nutricionista":
        tabela_vinculo = "nutricionistas_atletas"
        coluna_profissional = "nutricionistas_id"
    else:
        return False

    vinculo = db.execute(
        text(
            f"""
            select 1
            from {SCHEMA}.{tabela_vinculo}
            where {coluna_profissional} = :profissional_id
              and atletas_id = :atleta_id
            limit 1
            """
        ),
        {"profissional_id": profissional_id, "atleta_id": atleta_id},
    ).first()
    return vinculo is not None


COR_URINA_CODIGOS = {
    "transparente": 1,
    "amarelo claro": 2,
    "amarelo": 3,
    "amarelo escuro": 4,
    "ambar": 5,
    "marrom escuro": 6,
}

COR_URINA_DESCRICOES = {
    1: "Transparente",
    2: "Amarelo claro",
    3: "Amarelo",
    4: "Amarelo escuro",
    5: "Ambar",
    6: "Marrom escuro",
}


def _cor_urina_codigo(valor) -> int:
    if isinstance(valor, int) and not isinstance(valor, bool):
        return valor
    texto = (
        unicodedata.normalize("NFKD", str(valor or ""))
        .encode("ascii", "ignore")
        .decode("ascii")
        .strip()
        .lower()
    )
    return COR_URINA_CODIGOS.get(texto, 0)


def _cor_urina_descricao(valor) -> str:
    return COR_URINA_DESCRICOES.get(int(valor or 0), "Nao informado")


def _treino_response(row) -> dict:
    data = row["data_hora"]
    duracao_minutos = row["duracao_real_segundos"] // 60
    return {
        "id": str(row["id"]),
        "atletaId": str(row["atletas_id"]),
        "atletaNome": row["atleta_nome"],
        "data": data.isoformat() if data else None,
        "modalidade": row["modalidade"],
        "duracaoMinutos": duracao_minutos,
        "duracaoPrevistaMin": row["duracao_prevista_min"],
        "duracaoRealSegundos": row["duracao_real_segundos"],
        "fluidosMl": row["ing_fluidos"],
        "alimentosAgua": row["ing_alimentos"] or "",
        "volumeUrinarioMl": row["volume_urinario"] or 0,
        "massaCorporalPreKg": float(row["massa_pre"]),
        "massaCorporalPosKg": float(row["massa_pos"]),
        "escalaBorg": row["intensidade"],
        "sensacaoTermica": float(row["sensacao_termica"]),
        "vento": row["velocidade_vento"],
        "exposicaoSolar": row["exposicao_solar"],
        "corUrina": _cor_urina_descricao(row["cor_urina"]),
        "corUrinaCodigo": row["cor_urina"],
        "vestimenta": row["tipo_vest"],
        "equipamento": row["equipamento"],
        "estaComSede": row["sede"],
        "sintomasPreDescricao": row["sintomas_pre"] or "",
        "historicoHidratacao": row["historico_recente_hidratacao"],
        "roupasEncharcadas": row["roupa_encharc"],
        "trocaVestimenta": row["troca_vest"],
        "observacaoRoupas": row["observacao_roupas"] or "",
        "teveSintomasGastro": row["sintomas_gastro"],
        "sintomasDescricao": row["descricao_sintomas_gastro"] or "",
        "teveFadiga": row["fadiga"],
        "fadigaDescricao": row["descricao_fadiga"] or "",
        "temperatura": round(float(row["temperatura_c"])),
        "umidade": row["umidade_percentual"],
    }


def _nota_response(row) -> dict:
    data = row["criado_em"]
    return {
        "id": str(row["id"]),
        "atletaCodigo": row["atleta_codigo"],
        "profissionalId": str(row["profissionais_id"]),
        "profissionalNome": row["profissional_nome"],
        "profissionalTipo": row["profissional_tipo"],
        "titulo": row["titulo"],
        "conteudo": row["conteudo"],
        "data": data.isoformat() if data else None,
    }


def _calcular_recomendacao(fluido_ml: int, variacao_massa: float) -> str:
    if variacao_massa > 2:
        return "Aumentar reposição hidríca e monitorar sinais de desidratação."
    if fluido_ml < 500:
        return "Ingestão hidríca abaixo do recomendado para a sessão."
    return "Manter estratégia de hidratação."


@router.post("/auth/login")
def login(payload: LoginRequest, db: Session = Depends(get_db)):
    tipo = payload.tipo.strip().lower()
    if tipo not in VALID_ROLES:
        raise HTTPException(status_code=400, detail="Tipo de usuario invalido.")

    usuario = _buscar_usuario_por_login(db, payload.email.strip(), payload.senha)
    if not usuario:
        raise HTTPException(status_code=401, detail="E-mail ou senha invalidos.")

    papel = _role_from_row(usuario)
    if papel != tipo:
        raise HTTPException(status_code=403, detail="Usuario nao possui o perfil solicitado.")

    return _usuario_response(usuario, tipo)


@router.post("/atletas")
def criar_atleta(payload: AtletaCreateRequest, db: Session = Depends(get_db)):
    email = payload.email.strip().lower()
    nome = payload.nome.strip()
    senha = payload.senha
    altura = _normalizar_altura(payload.altura)
    peso = _validar_peso(payload.peso)
    sexo = _normalizar_sexo(payload.sexo)

    if not nome or not email or not senha:
        raise HTTPException(status_code=400, detail="Nome, e-mail e senha sao obrigatorios.")
    if payload.dataNascimento >= date.today():
        raise HTTPException(status_code=400, detail="Data de nascimento deve estar no passado.")

    codigo = _gerar_codigo_acesso(db)

    try:
        pessoa = _criar_auth_user_e_pessoa(db, nome, email, senha)
        db.execute(
            text(
                f"""
                insert into {SCHEMA}.atletas (id, altura, peso, data_nasc, sexo, codigo_acesso)
                values (:id, :altura, :peso, :data_nasc, :sexo, :codigo)
                """
            ),
            {
                "id": pessoa["id"],
                "altura": altura,
                "peso": peso,
                "data_nasc": payload.dataNascimento,
                "sexo": sexo,
                "codigo": codigo,
            },
        )
        db.commit()
    except IntegrityError as exc:
        db.rollback()
        raise HTTPException(status_code=409, detail="E-mail ou codigo ja cadastrado.") from exc

    return {"id": str(pessoa["id"]), "nome": nome, "email": email, "tipo": "atleta", "codigo": codigo}


@router.post("/profissionais")
def criar_profissional(payload: ProfissionalCreateRequest, db: Session = Depends(get_db)):
    email = payload.email.strip().lower()
    nome = payload.nome.strip()
    senha = payload.senha
    tipo = payload.tipo.strip().lower()
    registro = payload.registro.strip().upper()

    if tipo not in {"medico", "nutricionista"}:
        raise HTTPException(status_code=400, detail="Tipo de profissional invalido.")
    if not nome or not email or not senha or not registro:
        raise HTTPException(status_code=400, detail="Nome, e-mail, senha e registro sao obrigatorios.")

    tabela = "medicos" if tipo == "medico" else "nutricionistas"
    coluna_registro = "crm" if tipo == "medico" else "crn"

    try:
        pessoa = _criar_auth_user_e_pessoa(db, nome, email, senha)
        db.execute(
            text(
                f"""
                insert into {SCHEMA}.{tabela} (id, {coluna_registro})
                values (:id, :registro)
                """
            ),
            {"id": pessoa["id"], "registro": registro},
        )
        db.commit()
    except IntegrityError as exc:
        db.rollback()
        raise HTTPException(status_code=409, detail="E-mail ou registro ja cadastrado.") from exc

    return {"id": str(pessoa["id"]), "nome": nome, "email": email, "tipo": tipo}


@router.get("/atletas/{identificador}")
def obter_atleta(identificador: str, db: Session = Depends(get_db)):
    atleta = _buscar_atleta(db, identificador.strip())
    if not atleta:
        raise HTTPException(status_code=404, detail="Atleta nao encontrado.")
    return {
        "id": str(atleta["id"]),
        "codigo": atleta["codigo"],
        "nome": atleta["nome"],
        "email": atleta["email"],
        "altura": float(atleta["altura"]),
        "peso": float(atleta["peso"]),
        "dataNascimento": atleta["data_nasc"].isoformat() if atleta["data_nasc"] else None,
        "idade": atleta["idade"],
        "sexo": atleta["sexo"],
    }


@router.patch("/atletas/{identificador}")
def atualizar_atleta(
    identificador: str,
    payload: AtletaUpdateRequest,
    db: Session = Depends(get_db),
):
    atleta = _buscar_atleta(db, identificador.strip())
    if not atleta:
        raise HTTPException(status_code=404, detail="Atleta nao encontrado.")

    altura = _normalizar_altura(payload.altura) if payload.altura is not None else None
    peso = _validar_peso(payload.peso) if payload.peso is not None else None
    sexo = _normalizar_sexo(payload.sexo) if payload.sexo is not None else None

    if payload.dataNascimento is not None and payload.dataNascimento >= date.today():
        raise HTTPException(status_code=400, detail="Data de nascimento deve estar no passado.")

    if (
        altura is not None
        or peso is not None
        or payload.dataNascimento is not None
        or sexo is not None
    ):
        db.execute(
            text(
                f"""
                update {SCHEMA}.atletas
                set
                  altura = coalesce(:altura, altura),
                  peso = coalesce(:peso, peso),
                  data_nasc = coalesce(:data_nasc, data_nasc),
                  sexo = coalesce(:sexo, sexo)
                where id = :id
                """
            ),
            {
                "altura": altura,
                "peso": peso,
                "data_nasc": payload.dataNascimento,
                "sexo": sexo,
                "id": atleta["id"],
            },
        )
        db.commit()

    return obter_atleta(str(atleta["id"]), db)


@router.get("/profissionais/{profissional_id}/atletas")
def listar_atletas_profissional(profissional_id: int, db: Session = Depends(get_db)):
    profissional = db.execute(
        text(
            f"""
            select
              m.id is not null as is_medico,
              n.id is not null as is_nutricionista
            from {SCHEMA}.pessoas p
            left join {SCHEMA}.medicos m on m.id = p.id
            left join {SCHEMA}.nutricionistas n on n.id = p.id
            where p.id = :id
            """
        ),
        {"id": profissional_id},
    ).mappings().first()

    if not profissional:
        raise HTTPException(status_code=404, detail="Profissional nao encontrado.")

    if profissional["is_medico"]:
        tabela_vinculo = "medicos_atletas"
        coluna_profissional = "medicos_id"
    elif profissional["is_nutricionista"]:
        tabela_vinculo = "nutricionistas_atletas"
        coluna_profissional = "nutricionistas_id"
    else:
        raise HTTPException(status_code=400, detail="Pessoa nao e profissional.")

    rows = db.execute(
        text(
            f"""
            select
              a.id,
              p.nome,
              p.email,
              a.codigo_acesso as codigo
            from {SCHEMA}.{tabela_vinculo} pa
            join {SCHEMA}.atletas a on a.id = pa.atletas_id
            join {SCHEMA}.pessoas p on p.id = a.id
            where pa.{coluna_profissional} = :id
            order by p.nome
            """
        ),
        {"id": profissional_id},
    ).mappings().all()

    return [
        {"id": str(row["id"]), "codigo": row["codigo"], "nome": row["nome"], "email": row["email"]}
        for row in rows
    ]


@router.post("/profissionais/{profissional_id}/atletas")
def adicionar_atleta_profissional(
    profissional_id: int,
    payload: ProfissionalAtletaRequest,
    db: Session = Depends(get_db),
):
    atleta = _buscar_atleta(db, payload.codigo.strip().upper())
    if not atleta:
        raise HTTPException(status_code=404, detail="Atleta nao encontrado.")

    profissional = db.execute(
        text(
            f"""
            select
              m.id is not null as is_medico,
              n.id is not null as is_nutricionista
            from {SCHEMA}.pessoas p
            left join {SCHEMA}.medicos m on m.id = p.id
            left join {SCHEMA}.nutricionistas n on n.id = p.id
            where p.id = :id
            """
        ),
        {"id": profissional_id},
    ).mappings().first()

    if not profissional:
        raise HTTPException(status_code=404, detail="Profissional nao encontrado.")

    if profissional["is_medico"]:
        tabela_vinculo = "medicos_atletas"
        coluna_profissional = "medicos_id"
    elif profissional["is_nutricionista"]:
        tabela_vinculo = "nutricionistas_atletas"
        coluna_profissional = "nutricionistas_id"
    else:
        raise HTTPException(status_code=400, detail="Pessoa nao e profissional.")

    try:
        result = db.execute(
            text(
                f"""
                insert into {SCHEMA}.{tabela_vinculo} ({coluna_profissional}, atletas_id)
                values (:profissional_id, :atleta_id)
                on conflict do nothing
                """
            ),
            {"profissional_id": profissional_id, "atleta_id": atleta["id"]},
        )
        db.commit()
    except IntegrityError as exc:
        db.rollback()
        raise HTTPException(status_code=409, detail="Nao foi possivel vincular atleta.") from exc

    return {"ok": (result.rowcount or 0) > 0}


@router.delete("/profissionais/{profissional_id}/atletas/{codigo}")
def remover_atleta_profissional(
    profissional_id: int,
    codigo: str,
    db: Session = Depends(get_db),
):
    atleta = _buscar_atleta(db, codigo.strip().upper())
    if not atleta:
        raise HTTPException(status_code=404, detail="Atleta nao encontrado.")

    deleted = 0
    for tabela_vinculo, coluna_profissional in [
        ("medicos_atletas", "medicos_id"),
        ("nutricionistas_atletas", "nutricionistas_id"),
    ]:
        result = db.execute(
            text(
                f"""
                delete from {SCHEMA}.{tabela_vinculo}
                where {coluna_profissional} = :profissional_id
                  and atletas_id = :atleta_id
                """
            ),
            {"profissional_id": profissional_id, "atleta_id": atleta["id"]},
        )
        deleted += result.rowcount or 0

    db.commit()
    return {"ok": deleted > 0}


@router.get("/atletas/{identificador}/notas")
def listar_notas_atleta(identificador: str, db: Session = Depends(get_db)):
    atleta = _buscar_atleta(db, identificador.strip())
    if not atleta:
        raise HTTPException(status_code=404, detail="Atleta nao encontrado.")

    rows = db.execute(
        text(
            f"""
            select
              n.id,
              a.codigo_acesso as atleta_codigo,
              n.profissionais_id,
              p.nome as profissional_nome,
              n.profissional_tipo,
              n.titulo,
              n.conteudo,
              n.criado_em
            from {SCHEMA}.notas_atletas n
            join {SCHEMA}.atletas a on a.id = n.atletas_id
            join {SCHEMA}.pessoas p on p.id = n.profissionais_id
            where n.atletas_id = :atleta_id
            order by n.criado_em desc, n.id desc
            """
        ),
        {"atleta_id": atleta["id"]},
    ).mappings().all()

    return [_nota_response(row) for row in rows]


@router.post("/atletas/{identificador}/notas")
def criar_nota_atleta(
    identificador: str,
    payload: NotaCreateRequest,
    db: Session = Depends(get_db),
):
    atleta = _buscar_atleta(db, identificador.strip())
    if not atleta:
        raise HTTPException(status_code=404, detail="Atleta nao encontrado.")

    profissional_tipo = payload.profissionalTipo.strip().lower()
    if profissional_tipo not in {"medico", "nutricionista"}:
        raise HTTPException(status_code=400, detail="Tipo de profissional invalido.")

    titulo = payload.titulo.strip()
    conteudo = payload.conteudo.strip()
    if not titulo or not conteudo:
        raise HTTPException(status_code=400, detail="Titulo e conteudo sao obrigatorios.")

    profissional = _buscar_profissional(db, payload.profissionalId)
    if not profissional:
        raise HTTPException(status_code=404, detail="Profissional nao encontrado.")

    tipo_real = _tipo_profissional(profissional)
    if tipo_real != profissional_tipo:
        raise HTTPException(status_code=403, detail="Profissional nao possui o tipo informado.")

    if not _profissional_vinculado_ao_atleta(
        db,
        payload.profissionalId,
        atleta["id"],
        profissional_tipo,
    ):
        raise HTTPException(status_code=403, detail="Profissional nao vinculado ao atleta.")

    try:
        row = db.execute(
            text(
                f"""
                insert into {SCHEMA}.notas_atletas (
                  atletas_id,
                  profissionais_id,
                  profissional_tipo,
                  titulo,
                  conteudo
                )
                values (
                  :atleta_id,
                  :profissional_id,
                  :profissional_tipo,
                  :titulo,
                  :conteudo
                )
                returning
                  id,
                  atletas_id,
                  profissionais_id,
                  profissional_tipo,
                  titulo,
                  conteudo,
                  criado_em
                """
            ),
            {
                "atleta_id": atleta["id"],
                "profissional_id": payload.profissionalId,
                "profissional_tipo": profissional_tipo,
                "titulo": titulo,
                "conteudo": conteudo,
            },
        ).mappings().one()
        db.commit()
    except IntegrityError as exc:
        db.rollback()
        raise HTTPException(status_code=409, detail="Nao foi possivel salvar nota.") from exc

    nota = dict(row)
    nota["atleta_codigo"] = atleta["codigo"]
    nota["profissional_nome"] = profissional["nome"]
    return _nota_response(nota)


@router.get("/atletas/{identificador}/treinos")
def listar_treinos_atleta(identificador: str, db: Session = Depends(get_db)):
    atleta = _buscar_atleta(db, identificador.strip())
    if not atleta:
        raise HTTPException(status_code=404, detail="Atleta nao encontrado.")

    rows = db.execute(
        text(
            f"""
            select
              t.*,
              p.nome as atleta_nome
            from {SCHEMA}.treinos t
            join {SCHEMA}.atletas a on a.id = t.atletas_id
            join {SCHEMA}.pessoas p on p.id = a.id
            where t.atletas_id = :atleta_id
            order by t.data_hora desc
            """
        ),
        {"atleta_id": atleta["id"]},
    ).mappings().all()
    return [_treino_response(row) for row in rows]


@router.post("/treinos")
def criar_treino(payload: TreinoCreateRequest, db: Session = Depends(get_db)):
    atleta = _buscar_atleta(db, payload.atletaId.strip())
    if not atleta:
        raise HTTPException(status_code=404, detail="Atleta nao encontrado.")

    data = datetime.now()
    duracao_segundos = (
        max(payload.duracaoRealSegundos, 0)
        if payload.duracaoRealSegundos is not None
        else max(payload.duracaoMinutos, 0) * 60
    )
    duracao_prevista = payload.duracaoPrevistaMin or payload.duracaoMinutos
    fim = data + timedelta(seconds=duracao_segundos)
    variacao_massa = 0.0
    if payload.massaCorporalPreKg > 0:
        variacao_massa = (
            (payload.massaCorporalPreKg - payload.massaCorporalPosKg)
            / payload.massaCorporalPreKg
        ) * 100
    taxa_sudorese = 0.0
    duracao_horas = duracao_segundos / 3600
    if duracao_horas > 0:
        taxa_sudorese = (payload.fluidosMl / 1000) / duracao_horas
    balanco_hidrico = payload.fluidosMl - int(
        max(payload.massaCorporalPreKg - payload.massaCorporalPosKg, 0) * 1000
    )

    row = db.execute(
        text(
            f"""
            insert into {SCHEMA}.treinos (
              massa_pre,
              temperatura_c,
              sensacao_termica,
              velocidade_vento,
              modalidade,
              intensidade,
              tipo_vest,
              equipamento,
              cor_urina,
              sede,
              sintomas_pre,
              ing_fluidos,
              ing_alimentos,
              volume_urinario,
              massa_pos,
              roupa_encharc,
              troca_vest,
              observacao_roupas,
              data_hora,
              duracao_prevista_min,
              duracao_real_segundos,
              inicio_em,
              fim_em,
              umidade_percentual,
              exposicao_solar,
              sintomas_gastro,
              descricao_sintomas_gastro,
              fadiga,
              descricao_fadiga,
              historico_recente_hidratacao,
              taxa_sudorese,
              variacao_massa_percentual,
              balanco_hidrico,
              recomendacao_hidratacao,
              atletas_id
            )
            values (
              :massa_pre,
              :temperatura_c,
              :sensacao_termica,
              :velocidade_vento,
              :modalidade,
              :intensidade,
              :tipo_vest,
              :equipamento,
              :cor_urina,
              :sede,
              :sintomas_pre,
              :ing_fluidos,
              :ing_alimentos,
              :volume_urinario,
              :massa_pos,
              :roupa_encharc,
              :troca_vest,
              :observacao_roupas,
              :data_hora,
              :duracao_prevista_min,
              :duracao_real_segundos,
              :inicio_em,
              :fim_em,
              :umidade_percentual,
              :exposicao_solar,
              :sintomas_gastro,
              :descricao_sintomas_gastro,
              :fadiga,
              :descricao_fadiga,
              :historico_recente_hidratacao,
              :taxa_sudorese,
              :variacao_massa_percentual,
              :balanco_hidrico,
              :recomendacao_hidratacao,
              :atletas_id
            )
            returning *
            """
        ),
        {
            "massa_pre": payload.massaCorporalPreKg,
            "temperatura_c": payload.temperatura,
            "sensacao_termica": payload.sensacaoTermica
            if payload.sensacaoTermica is not None
            else payload.temperatura,
            "velocidade_vento": payload.vento.strip() or "Nao informado",
            "modalidade": payload.modalidade,
            "intensidade": payload.escalaBorg,
            "tipo_vest": payload.vestimenta.strip() or "Nao informado",
            "equipamento": payload.equipamento.strip() or "Nao informado",
            "cor_urina": _cor_urina_codigo(payload.corUrina),
            "sede": payload.estaComSede,
            "sintomas_pre": payload.sintomasPreDescricao or None,
            "ing_fluidos": payload.fluidosMl,
            "ing_alimentos": payload.alimentosAgua or None,
            "volume_urinario": payload.volumeUrinarioMl,
            "massa_pos": payload.massaCorporalPosKg,
            "roupa_encharc": payload.roupasEncharcadas,
            "troca_vest": payload.trocaVestimenta,
            "observacao_roupas": payload.observacaoRoupas.strip() or None,
            "data_hora": data,
            "duracao_prevista_min": duracao_prevista,
            "duracao_real_segundos": duracao_segundos,
            "inicio_em": data,
            "fim_em": fim,
            "umidade_percentual": payload.umidade,
            "exposicao_solar": payload.exposicaoSolar.strip() or "Nao informado",
            "sintomas_gastro": payload.teveSintomasGastro,
            "descricao_sintomas_gastro": payload.sintomasDescricao or None,
            "fadiga": payload.teveFadiga,
            "descricao_fadiga": payload.fadigaDescricao or None,
            "historico_recente_hidratacao": payload.historicoHidratacao.strip()
            or "Nao informado",
            "taxa_sudorese": taxa_sudorese,
            "variacao_massa_percentual": variacao_massa,
            "balanco_hidrico": balanco_hidrico,
            "recomendacao_hidratacao": _calcular_recomendacao(payload.fluidosMl, variacao_massa),
            "atletas_id": atleta["id"],
        },
    ).mappings().one()

    if payload.massaCorporalPreKg > 0:
        db.execute(
            text(
                f"""
                update {SCHEMA}.atletas
                set peso = :peso
                where id = :atleta_id
                """
            ),
            {"peso": payload.massaCorporalPreKg, "atleta_id": atleta["id"]},
        )

    db.commit()

    treino = dict(row)
    treino["atleta_nome"] = atleta["nome"]
    return _treino_response(treino)
