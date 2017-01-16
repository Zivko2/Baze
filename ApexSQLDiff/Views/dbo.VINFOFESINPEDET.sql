SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







































CREATE VIEW dbo.[VINFOFESINPEDET]
with encryption as
SELECT FACTEXP.FE_FOLIO, FACTEXP.FE_FECHA, 
    TFACTURA.TF_NOMBRE, FACTEXP.FE_TIPO
FROM FACTEXP LEFT OUTER JOIN
    TFACTURA ON 
    FACTEXP.TF_CODIGO = TFACTURA.TF_CODIGO
WHERE (FACTEXP.FE_CANCELADO = 'N') AND 
    (FACTEXP.PI_CODIGO <=  -1) AND (FACTEXP.FE_TIPO <> 'T')
GROUP BY FACTEXP.FE_FOLIO, 
    TFACTURA.TF_NOMBRE, FACTEXP.FE_FECHA, 
    FACTEXP.FE_TIPO









































































GO
