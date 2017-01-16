SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW dbo.VMAESTRO
with encryption as
SELECT MAESTRO.MA_CODIGO, MAESTRO.MA_NOPARTE, 
    MAESTRO.MA_NOMBRE, MAESTRO.MA_NAME, 
    MAESTRO.MA_TIP_ENS, TIPO.TI_NOMBRE, TIPO.TI_NAME, 
    MAESTRO.MA_NOPARTEAUX,MAESTRO.MA_OCULTO
FROM MAESTRO LEFT OUTER JOIN
    TIPO ON MAESTRO.TI_CODIGO = TIPO.TI_CODIGO
WHERE MAESTRO.MA_OCULTO='N'







































































GO
