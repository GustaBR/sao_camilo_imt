alter table nutri_esportiva.treinos
add column if not exists equipamento text not null default 'Nao informado';

alter table nutri_esportiva.treinos
add column if not exists observacao_roupas text;
