-- Exercício 1: UDF
-- Considere a tabela livro (id, livro, tipo). Construa essa tabela e insira 5 livros. Escreva uma função (UDF) para auxiliar o cálculo da
-- data de devolução de um livro em uma biblioteca. Exemplifique comandos SQL que usem essa função (e.g. SELECT, INSERT,UPDATE).
-- Considere que:
-- se o livro for MUITOPROCURADO, a devolução deve ocorrer no dia seguinte ao empréstimo;
-- se o livro for POUCOPROCURADO, a devolução deve ser três dias depois do empréstimo;
-- se o livro for RARAMENTEPROCURADO, a devolução deve ocorrer cinco dias após o empréstimo.
-- Dica: estudar sobre o tipo timestamp, as funções now() e age(), e intervalos.
-- Nota:
-- date + integer → date
-- Add a number of days to a date
-- date '2021-09-28' + 7 → 2021-10-05

CREATE TABLE livro (
    id SMALLINT NOT NULL,
    livro VARCHAR(60) NOT NULL,
    tipo VARCHAR(60)
);

insert into livro(id, livro, tipo) values (1, 'Cachorro', 'MUITOPROCURADO');
insert into livro(id, livro, tipo) values (2, 'Gato', 'MUITOPROCURADO');
insert into livro(id, livro, tipo) values (3, 'Cavalo', 'POUCOPROCURADO');
insert into livro(id, livro, tipo) values (4, 'Jacare', 'POUCOPROCURADO');
insert into livro(id, livro, tipo) values (5, 'vaca', 'RARAMENTEPROCURADO');

SELECT CURRENT_DATE;

Create or replace function devolucao (um_id INT) returns date AS $$
declare 
	um_tipo livro.tipo%type;
begin
	select l.tipo into um_tipo
	from livro l
	where l.id = um_id;
	
	if um_tipo = 'MUITOPROCURADO' THEN
		return current_date + 1;
	end if;
	
	if um_tipo = 'POUCOPROCURADO' THEN
		return current_date + 3;
	end if;
	
	if um_tipo = 'RARAMENTEPROCURADO' THEN
		return current_date + 5;
	end if;
	
end;
$$ language 'plpgsql';	

----------------------------------------------------------------------------------

-- Exercicio 2 

CREATE OR REPLACE PROCEDURE registrar_info_empregado(um_cpf VARCHAR, qtde_dep INT, depto BIGINT, projetos BIGINT)
AS $$
BEGIN
IF EXISTS(SELECT cpf FROM info_empregado WHERE cpf=um_cpf) THEN
UPDATE info_empregado SET
data_hora = CURRENT_TIMESTAMP,
qtde_dependentes = qtde_dep,
depto_atual = depto,
qtde_projetos = projetos
WHERE cpf = um_cpf;
ELSE
INSERT INTO info_empregado
VALUES (um_cpf, CURRENT_TIMESTAMP, qtde_dep, depto, projetos);
END IF;
END;
$$ LANGUAGE 'plpgsql';
CALL registrar_info_empregado('123.456.789-55', 5, 1, 10);
SELECT * FROM info_empregado;
-- Database: exercicio
-- DROP DATABASE exercicio;
CREATE DATABASE exercicio
WITH
OWNER = postgres
ENCODING = 'UTF8'
LC_COLLATE = 'Portuguese_Brazil.1252'
LC_CTYPE = 'Portuguese_Brazil.1252'
TABLESPACE = pg_default
CONNECTION LIMIT = -1;
-- Table: public.info_empregado
-- DROP TABLE public.info_empregado;
CREATE TABLE IF NOT EXISTS public.info_empregado
(
cpf character varying COLLATE pg_catalog."default" NOT NULL,
data_hora date NOT NULL,
qtde_dependentes bigint,
depto_atual bigint,
qtde_projetos bigint,
CONSTRAINT info_empregado_pkey PRIMARY KEY (cpf)
)
TABLESPACE pg_default;
ALTER TABLE public.info_empregado
OWNER to postgres;
-- Table: public.livro
-- DROP TABLE public.livro;
CREATE TABLE IF NOT EXISTS public.livro
(
id bigint NOT NULL,
livro character varying COLLATE pg_catalog."default" NOT NULL,
tipo character varying COLLATE pg_catalog."default" NOT NULL,
CONSTRAINT livro_pkey PRIMARY KEY (id)
)
TABLESPACE pg_default;
ALTER TABLE public.livro
OWNER to postgres; 

----------------------------------------------------------------------------------

-- Exercicio 3
	
CREATE TABLE classificacao (
    selecao_nome VARCHAR(60),
    grupo VARCHAR(1),
    pontos SMALLINT,
	jogos SMALLINT,
	vitorias SMALLINT,
	empates SMALLINT,
	derrotas SMALLINT,
	gols_pro SMALLINT,
	gols_contra SMALLINT,
	saldo_gols SMALLINT
);

CREATE TABLE partida(
	nro_partida SMALLINT,
	grupo VARCHAR(1),
	selecao_mandante VARCHAR(30),
	gols_selecao_mandante SMALLINT,
	selecao_visitante VARCHAR(30),
	gols_selecao_visitante SMALLINT
);

INSERT INTO classificacao(selecao_nome, grupo, pontos, jogos, vitorias, empates,derrotas,gols_pro, gols_contra, saldo_gols) VALUES ('Brasil', 'G', 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO classificacao(selecao_nome, grupo, pontos, jogos, vitorias, empates,derrotas,gols_pro, gols_contra, saldo_gols) VALUES ('Coréia do Norte', 'G', 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO classificacao(selecao_nome, grupo, pontos, jogos, vitorias, empates,derrotas,gols_pro, gols_contra, saldo_gols) VALUES ('Costa do Marfim', 'G', 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO classificacao(selecao_nome, grupo, pontos, jogos, vitorias, empates,derrotas,gols_pro, gols_contra, saldo_gols) VALUES ('Portugual', 'G', 0, 0, 0, 0, 0, 0, 0, 0);

CREATE OR REPLACE FUNCTION tg_classificacao_trigger()
RETURNS TRIGGER AS $$
BEGIN

if new.gols_selecao_mandante > new.gols_selecao_visitante then
	UPDATE classificacao
	set pontos = pontos + 3, jogos = jogos + 1, vitorias = vitorias + 1, gols_pro = gols_pro + new.gols_selecao_mandante, 
    gols_contra = gols_contra + new.gols_selecao_visitante, saldo_gols = saldo_gols + (gols_pro - gols_contra)
	where selecao_nome = new.selecao_mandante;
	
	UPDATE classificacao
	set jogos = jogos + 1, derrotas = derrotas + 1, gols_pro = gols_pro + new.gols_selecao_mandante, 
    gols_contra = gols_contra + new.gols_selecao_visitante, saldo_gols = saldo_gols + (gols_pro - gols_contra)
	where selecao_nome = new.selecao_visitante;
return new;
end if;

if new.gols_selecao_mandante < new.gols_selecao_visitante then
	UPDATE classificacao
	set pontos = pontos + 3, jogos = jogos + 1, vitorias = vitorias + 1, gols_pro = gols_pro + new.gols_selecao_mandante,
    gols_contra = gols_contra + new.gols_selecao_visitante, saldo_gols = saldo_gols + (gols_pro - gols_contra)
	where selecao_nome = new.selecao_visitante;

	UPDATE classificacao
	set jogos = jogos + 1, derrotas = derrotas + 1, gols_pro = gols_pro + new.gols_selecao_mandante,
    gols_contra = gols_contra + new.gols_selecao_visitante, saldo_gols = saldo_gols + (gols_pro - gols_contra)
	where selecao_nome = new.selecao_mandante;
return new;
end if;

if new.gols_selecao_mandante = new.gols_selecao_visitante then
	UPDATE classificacao
	set pontos = pontos + 1, jogos = jogos + 1, empates = empates + 1, gols_pro = gols_pro + new.gols_selecao_mandante,
    gols_contra = gols_contra + new.gols_selecao_visitante, saldo_gols = saldo_gols + (gols_pro - gols_contra)
	where selecao_nome = new.selecao_visitante;

	UPDATE classificacao
	set pontos = pontos + 1, jogos = jogos + 1, empates = empates + 1, gols_pro = gols_pro + new.gols_selecao_mandante,
    gols_contra = gols_contra + new.gols_selecao_visitante, saldo_gols = saldo_gols + (gols_pro - gols_contra)
	where selecao_nome = new.selecao_mandante;
return new;
end if;


RETURN NULL;
END;
$$ language 'plpgsql';


create trigger t_classificacao_trigger
after insert on partida
for each row execute function tg_classificacao_trigger();

INSERT INTO partida(nro_partida, grupo, selecao_mandante, gols_selecao_mandante, selecao_visitante, gols_selecao_visitante) VALUES (13, 'G', 'Costa do Marfim', 0, 'Portugal', 0);
INSERT INTO partida(nro_partida, grupo, selecao_mandante, gols_selecao_mandante, selecao_visitante, gols_selecao_visitante) VALUES (14, 'G', 'Brasil', 2, 'Coréia do Norte', 1);


----------------------------------------------------------------------------------

-- Exercício 4

-- A consulta seguinte é frequentemente executada no banco de dados empresa.
-- SELECT projeto.nome as projeto_nome, count(*) as salarios_entre_2500e10000
-- FROM projeto

                -- INNER JOIN trabalha_em ON projeto.numero=trabalha_em.proj_num

                -- INNER JOIN colaborador ON trabalha_em.cpf = colaborador.cpf

-- WHERE  colaborador.salario > 2500.00 AND colaborador.salario < 10000.01

-- GROUP BY projeto.nome
-- ORDER BY projeto.nome;

-- a. Execute a consulta e mostre o plano e o relatório de execução.
EXPLAIN ANALYZE
SELECT projeto.nome as projeto_nome, count(*) as salarios_entre_2500e10000
FROM projeto
INNER JOIN trabalha_em ON projeto.numero=trabalha_em.proj_num
INNER JOIN colaborador ON trabalha_em.cpf = colaborador.cpf
WHERE  colaborador.salario > 2500.00 AND colaborador.salario < 10000.01
GROUP BY projeto.nome
ORDER BY projeto.nome;

-- b. Identifique a ordem das operações executadas.

1	 GroupAggregate  (cost=3.66..3.68 rows=1 width=56)
2	   Group Key: projeto.nome
3	   ->  Sort  (cost=3.66..3.67 rows=1 width=48)
4			 Sort Key: projeto.nome
5			 ->  Hash Join  (cost=2.50..3.65 rows=1 width=48)
6				   Hash Cond: (projeto.numero = trabalha_em.proj_num)
7				   ->  Seq Scan on projeto  (cost=0.00..1.10 rows=10 width=50)
8				   ->  Hash  (cost=2.49..2.49 rows=1 width=2)
9						 ->  Hash Join  (cost=1.40..2.49 rows=1 width=2)
10							   Hash Cond: (trabalha_em.cpf = colaborador.cpf)
11							   ->  Seq Scan on trabalha_em  (cost=0.00..1.07 rows=7 width=62)
12							   ->  Hash  (cost=1.39..1.39 rows=1 width=60)
13									 ->  Seq Scan on colaborador  (cost=0.00..1.39 rows=1 width=60)
14										   Filter: ((salario > 2500.00) AND (salario < 10000.01))

Ordem: (13), (12,11), (9), (8,7), (5), (3), (1)

-- c. Identifique a operação mais custosa individualmente.
Linhas 12, 9, 8, 5, 3, 1;

-- d. Identifique a operação mais demorada individualmente.

 GroupAggregate  (cost=3.66..3.68 rows=1 width=56) (actual time=0.381..0.388 rows=2 loops=1)
   Group Key: projeto.nome
   ->  Sort  (cost=3.66..3.67 rows=1 width=48) (actual time=0.366..0.371 rows=3 loops=1)
         Sort Key: projeto.nome
         Sort Method: quicksort  Memory: 25kB
         ->  Hash Join  (cost=2.50..3.65 rows=1 width=48) (actual time=0.248..0.259 rows=3 loops=1)
               Hash Cond: (projeto.numero = trabalha_em.proj_num)
               ->  Seq Scan on projeto  (cost=0.00..1.10 rows=10 width=50) (actual time=0.054..0.056 rows=10 loops=1)
               ->  Hash  (cost=2.49..2.49 rows=1 width=2) (actual time=0.171..0.174 rows=3 loops=1)
                     Buckets: 1024  Batches: 1  Memory Usage: 9kB
                     ->  Hash Join  (cost=1.40..2.49 rows=1 width=2) (actual time=0.153..0.164 rows=3 loops=1)
                           Hash Cond: (trabalha_em.cpf = colaborador.cpf)
                           ->  Seq Scan on trabalha_em  (cost=0.00..1.07 rows=7 width=62) (actual time=0.028..0.030 rows=8 loops=1)
                           ->  Hash  (cost=1.39..1.39 rows=1 width=60) (actual time=0.085..0.086 rows=12 loops=1)
                                 Buckets: 1024  Batches: 1  Memory Usage: 9kB
                                 ->  Seq Scan on colaborador  (cost=0.00..1.39 rows=1 width=60) (actual time=0.048..0.067 rows=12 loops=1)
                                       Filter: ((salario > 2500.00) AND (salario < 10000.01))
                                       Rows Removed by Filter: 16
									   
O GroupAggregate é a operação mais demorada individualmente, time = 0.381.							   

-- e. Quais colunas envolvidas nessa consulta já possuem índices? Por quê?
                       List of relations
 Schema |        Name         | Type  |  Owner   |    Table
--------+---------------------+-------+----------+--------------
 public | colaborador_pk      | index | postgres | colaborador
 public | dependente_pf       | index | postgres | dependente
 public | depto_nome_unique   | index | postgres | departamento
 public | depto_pk            | index | postgres | departamento
 public | edificios_pk        | index | postgres | edificios
 public | projeto_nome_unique | index | postgres | projeto
 public | projeto_pk          | index | postgres | projeto
 public | trabalha_em_pk      | index | postgres | trabalha_em
 
 As colunas com indice envolvidas nessa pesquisa são: colaborador, trabalha_em, projeto.
 
-- f. Caso a cláusula WHERE da consulta possa ter o desempenho do processamento melhorado, por meio da criação de um índice, qual seria o tipo desse índice? Por quê?

EXPLAIN ANALYZE
SELECT projeto.nome as projeto_nome, count(*) as salarios_entre_2500e10000
FROM projeto
INNER JOIN trabalha_em ON projeto.numero=trabalha_em.proj_num
INNER JOIN colaborador ON trabalha_em.cpf = colaborador.cpf
WHERE  colaborador.salario > 2500.00 AND colaborador.salario < 10000.01
GROUP BY projeto.nome
ORDER BY projeto.nome;

B+-tree
- Consultas por igualdade
- Consultas por por intervalo

-- g. Redija o comando CREATE INDEX correspondente.

CREATE INDEX colaborador_salario ON colaborador
USING BTREE (salario);

-- h. Execute a consulta e mostre o plano e o relatório de execução. Verifique se o índice foi usado.

-- Não foi usado.

-- i. Caso não tenha sido, use parâmetros de configuração para "forçar" seu uso.

SET enable_sort = off;
SET enable_indexscan = on;

-- j. Execute ANALYZE; para atualizar as estatísticas do SGBD. Logo após, execute novamente a consulta e e mostre o plano e o relatório de execução. Compare o tempo para o
-- processamento da cláusula WHERE nesta execução com o tempo das execuções anteriores. Comente se este tempo foi menor que aqueles anteriores.

-- Sim, foi menor.

----------------------------------------------------------------------------------

-- Exercício 5

-- Acesso remoto
-- - Redija as linhas do arquivo pg_hba.conf de modo que
-- - analista acesse o servidor a partir de endereços cujo prefixo é 192.168.55
-- - gestao idem
-- - sec_depto25 acesse o servidor a partir do endereço 192.168.55.125
-- - sec_depto25 acesse o servidor a partir do endereço 192.168.55.177
-- - Esses acessos só podem ser autorizados mediante apresentação de senha criptografada

