do $$
declare
  pessoa_id_type text;
  atleta_id_type text;
begin
  select format_type(a.atttypid, a.atttypmod)
  into pessoa_id_type
  from pg_attribute a
  join pg_class c on c.oid = a.attrelid
  join pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'nutri_esportiva'
    and c.relname = 'pessoas'
    and a.attname = 'id'
    and not a.attisdropped;

  select format_type(a.atttypid, a.atttypmod)
  into atleta_id_type
  from pg_attribute a
  join pg_class c on c.oid = a.attrelid
  join pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'nutri_esportiva'
    and c.relname = 'atletas'
    and a.attname = 'id'
    and not a.attisdropped;

  if pessoa_id_type is null or atleta_id_type is null then
    raise exception 'Nao foi possivel identificar o tipo das chaves em nutri_esportiva.pessoas/atletas.';
  end if;

  execute format(
    'create table if not exists nutri_esportiva.treinadores (id %s primary key)',
    pessoa_id_type
  );

  if not exists (
    select 1
    from pg_constraint
    where conname = 'treinadores_id_fkey'
      and conrelid = 'nutri_esportiva.treinadores'::regclass
  ) then
    alter table nutri_esportiva.treinadores
    add constraint treinadores_id_fkey
    foreign key (id) references nutri_esportiva.pessoas(id)
    on delete cascade;
  end if;

  execute format(
    'create table if not exists nutri_esportiva.treinadores_atletas (treinadores_id %s not null, atletas_id %s not null)',
    pessoa_id_type,
    atleta_id_type
  );

  if not exists (
    select 1
    from pg_constraint
    where conname = 'treinadores_atletas_pkey'
      and conrelid = 'nutri_esportiva.treinadores_atletas'::regclass
  ) then
    alter table nutri_esportiva.treinadores_atletas
    add constraint treinadores_atletas_pkey primary key (treinadores_id, atletas_id);
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conname = 'treinadores_atletas_treinadores_id_fkey'
      and conrelid = 'nutri_esportiva.treinadores_atletas'::regclass
  ) then
    alter table nutri_esportiva.treinadores_atletas
    add constraint treinadores_atletas_treinadores_id_fkey
    foreign key (treinadores_id) references nutri_esportiva.treinadores(id)
    on delete cascade;
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conname = 'treinadores_atletas_atletas_id_fkey'
      and conrelid = 'nutri_esportiva.treinadores_atletas'::regclass
  ) then
    alter table nutri_esportiva.treinadores_atletas
    add constraint treinadores_atletas_atletas_id_fkey
    foreign key (atletas_id) references nutri_esportiva.atletas(id)
    on delete cascade;
  end if;
end $$;

create index if not exists treinadores_atletas_atletas_id_idx
on nutri_esportiva.treinadores_atletas (atletas_id);
