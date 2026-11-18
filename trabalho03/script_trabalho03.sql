-- TRABALHO PRÁTICO 03 - OPERADORES E FUNÇÕES SQL
-- Banco de dados: Player One - Biblioteca de Jogos


-- QUESTÃO 1 - PRECEDÊNCIA LÓGICA COM PARÊNTESES (AND, OR)
-- Lista jogos que estão sendo jogados ou já foram zerados e que
-- possuem pelo menos 100 horas jogadas OU custaram R$ 100,00 ou mais.
-- Os parênteses fazem com que o filtro de status seja aplicado
-- junto com uma das duas condições seguintes.
-- Sem os parênteses, o AND teria precedência sobre o OR e poderiam
-- aparecer jogos de outros status que atendessem à condição após o OR.
SELECT
    j.titulo,
    b.status,
    b.horas_jogadas,
    b.valor_pago
FROM biblioteca b
INNER JOIN jogos j ON j.id_jogo = b.id_jogo
WHERE (b.status = 'JOGANDO' OR b.status = 'ZERADO')
  AND (b.horas_jogadas >= 100 OR b.valor_pago >= 100)
ORDER BY j.titulo;


-- QUESTÃO 2 - NEGAÇÃO E VERIFICAÇÃO DE NULOS (NOT, IS NULL / IS NOT NULL)
-- Mostra jogos da biblioteca que não foram abandonados e que já possuem
-- uma avaliação registrada. A avaliação é opcional e pode ser NULL.
SELECT
    j.titulo,
    b.status,
    b.avaliacao
FROM biblioteca b
INNER JOIN jogos j ON j.id_jogo = b.id_jogo
WHERE NOT (b.status = 'ABANDONADO')
  AND b.avaliacao IS NOT NULL
ORDER BY b.avaliacao DESC, j.titulo;


-- QUESTÃO 3 - INTERVALOS INCLUSIVOS E LISTAS (BETWEEN, IN)
-- Localiza jogos com quantidade de horas entre 100 e 500 (incluindo
-- os limites), cujo status seja JOGANDO ou ZERADO.
SELECT
    j.titulo,
    b.horas_jogadas,
    b.status
FROM biblioteca b
INNER JOIN jogos j ON j.id_jogo = b.id_jogo
WHERE b.horas_jogadas BETWEEN 100 AND 500
  AND b.status IN ('JOGANDO', 'ZERADO')
ORDER BY b.horas_jogadas DESC;


-- QUESTÃO 4A - BUSCA CASE-INSENSITIVE COM ILIKE E %
-- Procura jogos cujo título contenha a palavra "craft", sem diferenciar
-- letras maiúsculas e minúsculas. O símbolo % representa qualquer
-- quantidade de caracteres antes ou depois do termo.
SELECT
    id_jogo,
    titulo
FROM jogos
WHERE titulo ILIKE '%craft%';


-- QUESTÃO 4B - BUSCA COM CORINGA DE CARACTERE ÚNICO (_)
-- Localiza títulos que tenham "GTA " seguido de exatamente um caractere.
-- O sublinhado (_) representa somente um caractere.
SELECT
    id_jogo,
    titulo
FROM jogos
WHERE titulo ILIKE 'GTA _';


-- QUESTÃO 5 - SIMULAÇÃO NUMÉRICA E ARREDONDAMENTOS
-- Simula um reajuste de 7,5% sobre o preço dos jogos e apresenta
-- o resultado arredondado com ROUND e cortado com TRUNC, ambos
-- com duas casas decimais.
SELECT
    titulo,
    preco AS preco_original,
    ROUND(preco * 1.075, 2) AS preco_com_round,
    TRUNC(preco * 1.075, 2) AS preco_com_trunc
FROM jogos
ORDER BY titulo;


-- QUESTÃO 6A - CLASSIFICAÇÃO POR MÓDULO (MOD)
-- Classifica os jogos pelo identificador: números pares ou ímpares.
SELECT
    id_jogo,
    titulo,
    CASE
        WHEN MOD(id_jogo, 2) = 0 THEN 'Par'
        ELSE 'Ímpar'
    END AS classificacao_id
FROM jogos
ORDER BY id_jogo;


-- QUESTÃO 6B - SORTEIO DE UM JOGO (RANDOM)
-- Sorteia aleatoriamente um jogo cadastrado na plataforma.
-- O resultado pode mudar a cada execução.
SELECT
    id_jogo,
    titulo,
    preco
FROM jogos
ORDER BY RANDOM()
LIMIT 1;


-- QUESTÃO 7 - CONCATENAÇÃO, PADRONIZAÇÃO E EXTRAÇÃO DE STRINGS
-- Monta uma identificação do jogador com CONCAT e COALESCE,
-- transforma o nickname em maiúsculas e extrai a parte do e-mail
-- que aparece antes do caractere @ usando SPLIT_PART.
SELECT
    CONCAT(j.nickname, ' - ', COALESCE(j.cidade, 'Cidade não informada'))
        AS identificacao_jogador,
    UPPER(j.nickname) AS nickname_maiusculo,
    SPLIT_PART(j.email, '@', 1) AS usuario_email
FROM jogadores j
ORDER BY j.id_jogador;


-- QUESTÃO 8 - EXTRAÇÃO TEMPORAL E JANELA DE PERÍODO
-- Exibe o ano e o mês de aquisição dos jogos e trunca a data para
-- o início do mês. O filtro considera aquisições dos últimos 24 meses.
SELECT
    j.titulo,
    b.data_aquisicao,
    EXTRACT(YEAR FROM b.data_aquisicao) AS ano_aquisicao,
    EXTRACT(MONTH FROM b.data_aquisicao) AS mes_aquisicao,
    DATE_TRUNC('month', b.data_aquisicao)::DATE AS inicio_mes
FROM biblioteca b
INNER JOIN jogos j ON j.id_jogo = b.id_jogo
WHERE b.data_aquisicao >= CURRENT_DATE - INTERVAL '24 months'
ORDER BY b.data_aquisicao DESC;


-- QUESTÃO 9 - TEMPO DECORRIDO E PROJEÇÃO FUTURA (AGE, NOW, INTERVAL)
-- Calcula há quanto tempo cada jogador está cadastrado e projeta
-- a data de um ano após o cadastro.
SELECT
    nickname,
    data_cadastro,
    AGE(NOW(), data_cadastro) AS tempo_de_cadastro,
    (data_cadastro + INTERVAL '1 year')::DATE AS data_projetada_1_ano
FROM jogadores
ORDER BY data_cadastro;


-- QUESTÃO 10 - RELATÓRIO GERENCIAL FORMATADO
-- Gera um relatório da biblioteca unindo jogadores, jogos e biblioteca.
-- Formata a data no padrão brasileiro, o valor pago como moeda e
-- o identificador do jogador com zeros à esquerda usando LPAD.
SELECT
    LPAD(jg.id_jogador::TEXT, 4, '0') AS codigo_jogador,
    jg.nickname AS jogador,
    j.titulo AS jogo,
    TO_CHAR(b.data_aquisicao, 'DD/MM/YYYY') AS data_aquisicao,
    TO_CHAR(b.valor_pago, 'FM"R$ "999G990D00') AS valor_pago_formatado,
    b.status
FROM biblioteca b
INNER JOIN jogadores jg ON jg.id_jogador = b.id_jogador
INNER JOIN jogos j ON j.id_jogo = b.id_jogo
ORDER BY b.data_aquisicao DESC, jg.nickname;
