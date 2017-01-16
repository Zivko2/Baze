SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







































CREATE VIEW dbo.[VINFOFESINDESCDET]
with encryption as
SELECT FACTEXP.FE_FOLIO, TFACTURA.TF_NOMBRE, 
    FACTEXP.FE_FECHA, FACTEXP.FE_TIPO
FROM FACTEXP LEFT OUTER JOIN
    TFACTURA ON 
    FACTEXP.TF_CODIGO = TFACTURA.TF_CODIGO
GROUP BY FACTEXP.FE_TIPO, FACTEXP.FE_DESCARGADA, 
    TFACTURA.TF_NOMBRE, FACTEXP.FE_FECHA, 
    FACTEXP.FE_FOLIO
HAVING (FACTEXP.FE_TIPO <> 'T') AND 
    (FACTEXP.FE_DESCARGADA = 'N')






































































GO
