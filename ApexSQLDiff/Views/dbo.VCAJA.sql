SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO































CREATE VIEW dbo.VCAJA
with encryption as
SELECT MAESTRO.MA_CODIGO, MAESTRO.MA_NOPARTE, 
    MAESTRO.MA_NOPARTEAUX, TCAJA.TCA_NOMBRE, 
    TCAJA.TCA_CODIGO
FROM CONFIGURATIPO RIGHT OUTER JOIN
    MAESTRO ON 
    CONFIGURATIPO.TI_CODIGO = MAESTRO.TI_CODIGO LEFT OUTER
     JOIN
    TCAJA RIGHT OUTER JOIN
    ANEXO24 ON 
    TCAJA.TCA_CODIGO = ANEXO24.TCA_CODIGO ON 
    MAESTRO.MA_CODIGO = ANEXO24.MA_CODIGO
WHERE (CONFIGURATIPO.CFT_TIPO = 'C')





































































GO
