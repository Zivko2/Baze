SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO












































CREATE VIEW dbo.[VINFOFISINPIDET]
with encryption as
SELECT FACTIMP.FI_FOLIO, FACTIMP.FI_FECHA, FACTIMP.FI_TIPO, FACTIMP.FI_CODIGO,
    TFACTURA.TF_NOMBRE
FROM FACTIMP LEFT OUTER JOIN
    TFACTURA ON 
    FACTIMP.TF_CODIGO = TFACTURA.TF_CODIGO
WHERE (FACTIMP.FI_CANCELADO = 'N') AND 
    (FACTIMP.PI_CODIGO = 0 OR
    FACTIMP.PI_CODIGO IS NULL OR
    FACTIMP.PI_CODIGO = - 1) AND (FACTIMP.FI_TIPO <> 'T')
GROUP BY FACTIMP.FI_TIPO, 
    FACTIMP.FI_FOLIO, FACTIMP.FI_FECHA, 
    TFACTURA.TF_NOMBRE, FACTIMP.FI_CODIGO







































































GO
