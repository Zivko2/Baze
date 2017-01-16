SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW dbo.VAGENCIAMX
with encryption as
SELECT     dbo.AGENCIA.AG_CODIGO, dbo.AGENCIA.AG_NOMBRE, 
	   dbo.AGENCIA.AG_AGENTE, dbo.AGENCIA.AG_RFC, dbo.AGENCIA.AG_PATENTE AS AG_PATENTEus, 
           dbo.AGENCIA.AG_TIPO, dbo.AGENCIA.AG_CURP, dbo.AGENCIA.AG_CALLE, 
           dbo.AGENCIA.AG_NOEXT, dbo.AGENCIA.AG_NOINT, dbo.AGENCIA.AG_COL, dbo.AGENCIA.AG_CP, dbo.AGENCIA.AG_POBOX, dbo.AGENCIA.AG_CIUDAD, 
           dbo.AGENCIA.AG_MUNIC, dbo.AGENCIA.ES_CODIGO, dbo.AGENCIA.PA_CODIGO, dbo.AGENCIA.AG_TEL1, dbo.AGENCIA.AG_FAX,
ISNULL((SELECT AGT_PATENTE FROM AGENCIAPATENTE WHERE AGT_DEFAULT = 'S' AND AGT_TIPO in ('A', 'P') AND AG_CODIGO = AGENCIA.AG_CODIGO),
(SELECT AGENCIAPATENTE1.AGT_PATENTE FROM AGENCIAPATENTE AGENCIAPATENTE1 WHERE AGENCIAPATENTE1.AG_CODIGO = AGENCIA.AG_CODIGO
AND AGENCIAPATENTE1.AGT_CODIGO IN (SELECT MAX(AGENCIAPATENTE2.AGT_CODIGO) FROM AGENCIAPATENTE AGENCIAPATENTE2
WHERE AGENCIAPATENTE2.AG_CODIGO = AGENCIA.AG_CODIGO))) AS AG_PATENTE,

ISNULL((SELECT AGT_CODIGO FROM AGENCIAPATENTE WHERE AGT_DEFAULT = 'S' AND AGT_TIPO in ('A', 'P') AND AG_CODIGO = AGENCIA.AG_CODIGO),
(SELECT AGENCIAPATENTE1.AGT_CODIGO FROM AGENCIAPATENTE AGENCIAPATENTE1 WHERE AGENCIAPATENTE1.AG_CODIGO = AGENCIA.AG_CODIGO
AND AGENCIAPATENTE1.AGT_CODIGO IN (SELECT MAX(AGENCIAPATENTE2.AGT_CODIGO) FROM AGENCIAPATENTE AGENCIAPATENTE2
WHERE AGENCIAPATENTE2.AG_CODIGO = AGENCIA.AG_CODIGO))) AS AGT_CODIGO,

ISNULL((SELECT AGT_NOMBRE FROM AGENCIAPATENTE WHERE AGT_DEFAULT = 'S' AND AGT_TIPO in ('A', 'P') AND AG_CODIGO = AGENCIA.AG_CODIGO),
(SELECT AGENCIAPATENTE1.AGT_NOMBRE FROM AGENCIAPATENTE AGENCIAPATENTE1 WHERE AGENCIAPATENTE1.AG_CODIGO = AGENCIA.AG_CODIGO
AND AGENCIAPATENTE1.AGT_CODIGO IN (SELECT MAX(AGENCIAPATENTE2.AGT_CODIGO) FROM AGENCIAPATENTE AGENCIAPATENTE2
WHERE AGENCIAPATENTE2.AG_CODIGO = AGENCIA.AG_CODIGO))) AS AGT_NOMBRE,


ISNULL((SELECT AGT_RFC FROM AGENCIAPATENTE WHERE AGT_DEFAULT = 'S' AND AGT_TIPO in ('A', 'P') AND AG_CODIGO = AGENCIA.AG_CODIGO),
(SELECT AGENCIAPATENTE1.AGT_RFC FROM AGENCIAPATENTE AGENCIAPATENTE1 WHERE AGENCIAPATENTE1.AG_CODIGO = AGENCIA.AG_CODIGO
AND AGENCIAPATENTE1.AGT_CODIGO IN (SELECT MAX(AGENCIAPATENTE2.AGT_CODIGO) FROM AGENCIAPATENTE AGENCIAPATENTE2
WHERE AGENCIAPATENTE2.AG_CODIGO = AGENCIA.AG_CODIGO))) AS AGT_RFC,

ISNULL((SELECT AGT_CURP FROM AGENCIAPATENTE WHERE AGT_DEFAULT = 'S' AND AGT_TIPO in ('A', 'P') AND AG_CODIGO = AGENCIA.AG_CODIGO),
(SELECT AGENCIAPATENTE1.AGT_CURP FROM AGENCIAPATENTE AGENCIAPATENTE1 WHERE AGENCIAPATENTE1.AG_CODIGO = AGENCIA.AG_CODIGO
AND AGENCIAPATENTE1.AGT_CODIGO IN (SELECT MAX(AGENCIAPATENTE2.AGT_CODIGO) FROM AGENCIAPATENTE AGENCIAPATENTE2
WHERE AGENCIAPATENTE2.AG_CODIGO = AGENCIA.AG_CODIGO))) AS AGT_CURP,

ISNULL((SELECT AGT_TIPO FROM AGENCIAPATENTE WHERE AGT_DEFAULT = 'S' AND AGT_TIPO in ('A', 'P') AND AG_CODIGO = AGENCIA.AG_CODIGO),
(SELECT AGENCIAPATENTE1.AGT_CURP FROM AGENCIAPATENTE AGENCIAPATENTE1 WHERE AGENCIAPATENTE1.AG_CODIGO = AGENCIA.AG_CODIGO
AND AGENCIAPATENTE1.AGT_CODIGO IN (SELECT MAX(AGENCIAPATENTE2.AGT_CODIGO) FROM AGENCIAPATENTE AGENCIAPATENTE2
WHERE AGENCIAPATENTE2.AG_CODIGO = AGENCIA.AG_CODIGO))) AS AGT_TIPO,

ISNULL((SELECT AGT_PATENTE FROM AGENCIAPATENTE WHERE AGT_DEFAULT = 'S' AND AGT_TIPO in ('A', 'P') AND AG_CODIGO = AGENCIA.AG_CODIGO),
(SELECT AGENCIAPATENTE1.AGT_CURP FROM AGENCIAPATENTE AGENCIAPATENTE1 WHERE AGENCIAPATENTE1.AG_CODIGO = AGENCIA.AG_CODIGO
AND AGENCIAPATENTE1.AGT_CODIGO IN (SELECT MAX(AGENCIAPATENTE2.AGT_CODIGO) FROM AGENCIAPATENTE AGENCIAPATENTE2
WHERE AGENCIAPATENTE2.AG_CODIGO = AGENCIA.AG_CODIGO))) AS AGT_PATENTE


FROM         dbo.AGENCIA
WHERE     (dbo.AGENCIA.AG_TIPO = 'M') or (dbo.AGENCIA.AG_TIPO = 'A')



GO
