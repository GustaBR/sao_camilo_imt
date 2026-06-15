alter table nutri_esportiva.medicos_atletas
drop constraint if exists medicos_atletas_atletas_id_key;

alter table nutri_esportiva.medicos_atletas
drop constraint if exists medicos_atletas_medicos_id_key;

alter table nutri_esportiva.nutricionistas_atletas
drop constraint if exists nutricionistas_atletas_atletas_id_key;

alter table nutri_esportiva.nutricionistas_atletas
drop constraint if exists nutricionistas_atletas_nutricionistas_id_key;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'medicos_atletas_pkey'
      and conrelid = 'nutri_esportiva.medicos_atletas'::regclass
  ) then
    alter table nutri_esportiva.medicos_atletas
    add constraint medicos_atletas_pkey primary key (medicos_id, atletas_id);
  end if;
end $$;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'nutricionistas_atletas_pkey'
      and conrelid = 'nutri_esportiva.nutricionistas_atletas'::regclass
  ) then
    alter table nutri_esportiva.nutricionistas_atletas
    add constraint nutricionistas_atletas_pkey primary key (nutricionistas_id, atletas_id);
  end if;
end $$;

create index if not exists medicos_atletas_atletas_id_idx
on nutri_esportiva.medicos_atletas (atletas_id);

create index if not exists nutricionistas_atletas_atletas_id_idx
on nutri_esportiva.nutricionistas_atletas (atletas_id);

create index if not exists treinos_atletas_id_idx
on nutri_esportiva.treinos (atletas_id);
