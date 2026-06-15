alter table nutri_esportiva.atletas
add column if not exists peso numeric not null default 70;

update nutri_esportiva.atletas
set sexo = 'nao_informado'
where sexo is null or btrim(sexo) = '';

alter table nutri_esportiva.atletas
alter column sexo set default 'nao_informado';

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'atletas_peso_positive'
      and conrelid = 'nutri_esportiva.atletas'::regclass
  ) then
    alter table nutri_esportiva.atletas
    add constraint atletas_peso_positive check (peso > 0);
  end if;
end $$;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'atletas_altura_positive'
      and conrelid = 'nutri_esportiva.atletas'::regclass
  ) then
    alter table nutri_esportiva.atletas
    add constraint atletas_altura_positive check (altura > 0);
  end if;
end $$;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'atletas_sexo_valid'
      and conrelid = 'nutri_esportiva.atletas'::regclass
  ) then
    alter table nutri_esportiva.atletas
    add constraint atletas_sexo_valid
    check (sexo in ('masculino', 'feminino', 'outro', 'nao_informado'));
  end if;
end $$;
