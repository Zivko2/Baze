SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW dbo.VENTRADAALM
with encryption as
SELECT     EN_CODIGO, EN_FOLIO, EN_FECHA, TM_CODIGO, EN_REFERENCIA, EN_OBSERVA, EN_CUENTAMAYOR, PR_CODIGO, DI_PROVEE, CL_DESTINO, 
                      DI_DESTINO, US_CODIGO, EN_NOAUTORIZA, EN_TIPOCAMBIO, EN_ESTATUS, EN_ORDENTRABAJO, EN_SOLINVENTARIO, EN_CANCELADO, 
                      EN_FOLIOAUTORIZACION, EN_TOTALB, RC_CODIGO, ALM_ORIGEN, ALM_DESTINO
FROM         dbo.ENTSALALM
WHERE     (EN_TIPO = 'E')

GO
