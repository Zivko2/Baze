SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO









CREATE VIEW dbo.VDATOSPEDEXPPAGOUSA
with encryption as
SELECT     PIB_INDICEB, FED_INDICED, FED_RATEIMPFO, TOTALVALORGRAVUSA, TOTALVALORGRAVMN, TOTALARANUSAMN, TOTALARANUSA, 
                      PI_CODIGO, PIB_DESTNAFTA, PIB_SECUENCIA, AR_EXPFO
FROM         dbo.KARDATOSPEDEXPPAGOUSA


GO
