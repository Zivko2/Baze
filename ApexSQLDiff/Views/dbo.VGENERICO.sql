SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO































CREATE VIEW dbo.VGENERICO
with encryption as
SELECT MAESTRO.MA_CODIGO, MAESTRO.MA_NOMBRE, MAESTRO.MA_NOPARTEAUX,
    MAESTRO.ME_COM, MAESTRO.TI_CODIGO, MEDIDA.ME_CODIGO,
    MAESTRO.MA_NOPARTE, MEDIDA.ME_CORTO
FROM MAESTRO LEFT OUTER JOIN
    MEDIDA ON 
    MAESTRO.ME_COM = MEDIDA.ME_CODIGO
WHERE (MAESTRO.MA_INV_GEN = 'G')


































































GO
