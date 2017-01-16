SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO













































CREATE PROCEDURE [dbo].[SP_ACTUALIZATASASMAESTROALL]   as

SET NOCOUNT ON 
/*
-- general
UPDATE dbo.MAESTRO
SET     dbo.MAESTRO.MA_POR_DEF= dbo.ARANCEL.AR_ADVDEF
FROM         dbo.MAESTRO INNER JOIN
                      dbo.ARANCEL ON dbo.MAESTRO.AR_IMPMX = dbo.ARANCEL.AR_CODIGO
WHERE     (dbo.MAESTRO.MA_DEF_TIP = 'G') AND (dbo.MAESTRO.MA_INV_GEN = 'I')

-- bajo tratado
UPDATE dbo.MAESTRO
SET     dbo.MAESTRO.MA_POR_DEF= dbo.PAISARA.PAR_BEN, 
dbo.MAESTRO.SPI_CODIGO=dbo.PAISARA.SPI_CODIGO
FROM         dbo.MAESTRO INNER JOIN
                      dbo.PAISARA ON dbo.MAESTRO.AR_IMPMX = dbo.PAISARA.AR_CODIGO AND dbo.MAESTRO.PA_ORIGEN = dbo.PAISARA.PA_CODIGO
WHERE     (dbo.MAESTRO.MA_DEF_TIP = 'P') AND (dbo.MAESTRO.MA_INV_GEN = 'I')


--sectorial
UPDATE dbo.MAESTRO
SET     dbo.MAESTRO.MA_POR_DEF= dbo.SECTORARA.SA_PORCENT
FROM         dbo.MAESTRO INNER JOIN
                      dbo.SECTORARA ON dbo.MAESTRO.MA_SEC_IMP = dbo.SECTORARA.SE_CODIGO AND 
                      dbo.MAESTRO.AR_IMPMX = dbo.SECTORARA.AR_CODIGO
WHERE     (dbo.MAESTRO.MA_DEF_TIP = 'S') AND (dbo.MAESTRO.MA_INV_GEN = 'I')


-- regla octava
UPDATE dbo.MAESTRO
SET     dbo.MAESTRO.MA_POR_DEF= dbo.ARANCEL.AR_PORCENT_8VA
FROM         dbo.MAESTRO INNER JOIN
                      dbo.ARANCEL ON dbo.MAESTRO.AR_IMPMX = dbo.ARANCEL.AR_CODIGO
WHERE     (dbo.MAESTRO.MA_DEF_TIP = 'R') AND (dbo.MAESTRO.MA_INV_GEN = 'I')




-- USA
UPDATE dbo.MAESTRO
SET     dbo.MAESTRO.MA_RATEIMPFO= dbo.ARANCEL.AR_ADVDEF
FROM         dbo.MAESTRO INNER JOIN
                      dbo.ARANCEL ON dbo.MAESTRO.AR_IMPFO = dbo.ARANCEL.AR_CODIGO
WHERE (dbo.MAESTRO.MA_INV_GEN = 'I')




*/







































GO
