SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO












































CREATE VIEW dbo.[VINFOGENSINPER]
with encryption as
SELECT COUNT(MAESTRO.MA_CODIGO) AS COUNTMA_GENERICO, 
    TIPO.TI_NOMBRE
FROM MAESTRO LEFT OUTER JOIN
    TIPO ON 
    MAESTRO.TI_CODIGO = TIPO.TI_CODIGO LEFT OUTER JOIN
    PERMISODET ON 
    MAESTRO.MA_CODIGO = PERMISODET.MA_GENERICO
GROUP BY MAESTRO.MA_INV_GEN, PERMISODET.MA_GENERICO, 
    TIPO.TI_NOMBRE
HAVING (MAESTRO.MA_INV_GEN = 'G') AND 
    (PERMISODET.MA_GENERICO IS NULL)






































































GO
