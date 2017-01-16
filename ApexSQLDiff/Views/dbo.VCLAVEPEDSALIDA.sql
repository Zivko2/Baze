SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW dbo.VCLAVEPEDSALIDA
with encryption as
SELECT     dbo.CLAVEPED.CP_CODIGO, dbo.CLAVEPED.CP_CLAVE, dbo.CLAVEPED.CP_NOMBRE, dbo.CLAVEPED.CP_DESCARGABLE, 
                      dbo.CLAVEPED.CP_CONSOLIDADO, dbo.CONFIGURACLAVEPED.CCP_TIPO
FROM         dbo.CLAVEPED LEFT OUTER JOIN
                      dbo.CONFIGURACLAVEPED ON dbo.CLAVEPED.CP_CODIGO = dbo.CONFIGURACLAVEPED.CP_CODIGO
WHERE     (dbo.CONFIGURACLAVEPED.CCP_TIPO IN ('IE', 'EV', 'ET', 'IB', 'ET', /*'CN',*/ 'IR', 'ER', 'RP', 'RE', 'VT', 'SD', 'CT', 'SI', 'EC', 'RD'))



























































GO
