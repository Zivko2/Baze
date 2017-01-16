SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO












































CREATE VIEW dbo.[VINFOGENSINPERDET]
with encryption as
SELECT MAESTRO.MA_NOPARTE, MAESTRO.MA_NOMBRE, 
    TIPO.TI_NOMBRE
FROM MAESTRO LEFT OUTER JOIN
    TIPO ON 
    MAESTRO.TI_CODIGO = TIPO.TI_CODIGO LEFT OUTER JOIN
    PERMISODET ON 
    MAESTRO.MA_CODIGO = PERMISODET.MA_GENERICO
GROUP BY MAESTRO.MA_INV_GEN, PERMISODET.MA_GENERICO, 
    TIPO.TI_NOMBRE, MAESTRO.MA_NOPARTE, 
    MAESTRO.MA_NOMBRE
HAVING (MAESTRO.MA_INV_GEN = 'G') AND 
    (PERMISODET.MA_GENERICO IS NULL)






































































GO
