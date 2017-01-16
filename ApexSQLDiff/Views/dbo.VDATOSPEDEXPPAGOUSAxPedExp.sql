SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.VDATOSPEDEXPPAGOUSAxPedExp
with encryption as
SELECT     PIB_INDICEB, FED_INDICED, AR_EXPFO, TOTALVALORUSAMN * (case when (select cf_pagocontribucion from configuracion)='J' or PIB_DESTNAFTA='N' then 0 else FED_RATEIMPFO end)/100 as TOTALARANUSAMN, PIB_SECUENCIA, PI_CODIGO, PIB_DESTNAFTA, 
                    TOTALVALORUSA* (case when (select cf_pagocontribucion from configuracion)='J' or PIB_DESTNAFTA='N' then 0 else FED_RATEIMPFO end)/100 as TOTALARANUSA, TOTALVALORUSA AS TOTALVALORGRAVUSA, TOTALVALORUSAMN AS TOTALVALORGRAVMN,
	FED_RATEIMPFO=case when (select cf_pagocontribucion from configuracion)='J' or PIB_DESTNAFTA='N' then 0 else FED_RATEIMPFO end, MA_CODIGOFED
FROM         VDATOSPEDEXPPAGOUSAxPedExp1
GO
