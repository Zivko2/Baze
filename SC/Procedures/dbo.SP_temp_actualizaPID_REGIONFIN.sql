SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE [dbo].[SP_temp_actualizaPID_REGIONFIN]   as

SET NOCOUNT ON 

UPDATE dbo.FACTEXPDET
SET     dbo.FACTEXPDET.FED_DESTNAFTA= CASE 
when dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT CF_PAIS_MX FROM CONFIGURACION) THEN 'M'
 when dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT CF_PAIS_USA FROM CONFIGURACION) or dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT CF_PAIS_CA FROM CONFIGURACION)
then 'N'  WHEN 	  dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT PA_CODIGO FROM PAIS WHERE SPI_CODIGO IN ( SELECT SPI_CODIGO FROM SPI WHERE SPI_CLAVE='MX-UE')) 
then 'U' when 	  dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT PA_CODIGO FROM PAIS WHERE SPI_CODIGO IN ( SELECT SPI_CODIGO FROM SPI WHERE SPI_CLAVE='AELC')) 
then 'A'  else 'F' end
FROM         dbo.FACTEXPDET INNER JOIN
                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO LEFT OUTER JOIN
                      dbo.DIR_CLIENTE ON dbo.FACTEXP.DI_DESTFIN = dbo.DIR_CLIENTE.DI_INDICE


-- lo de region no nafta
UPDATE dbo.PEDIMPDET
SET     dbo.PEDIMPDET.PID_REGIONFIN='F'
FROM         dbo.PEDIMPDET INNER JOIN
                      dbo.VPEDEXP ON dbo.PEDIMPDET.PI_CODIGO = dbo.VPEDEXP.PI_CODIGO

-- lo de region union europea
UPDATE dbo.PEDIMPDET
SET     dbo.PEDIMPDET.PID_REGIONFIN='U'
FROM         dbo.PEDIMPDET INNER JOIN
                      dbo.VPEDEXP ON dbo.PEDIMPDET.PI_CODIGO = dbo.VPEDEXP.PI_CODIGO INNER JOIN
                      dbo.FACTEXPDET ON dbo.PEDIMPDET.PID_INDICED = dbo.FACTEXPDET.PID_INDICEDLIGA INNER JOIN
                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO INNER JOIN
                      dbo.DIR_CLIENTE ON dbo.FACTEXP.DI_DESTFIN = dbo.DIR_CLIENTE.DI_INDICE
WHERE     dbo.DIR_CLIENTE.PA_CODIGO IN
                          (SELECT PA_CODIGO FROM PAIS WHERE SPI_CODIGO IN ( SELECT SPI_CODIGO FROM SPI WHERE SPI_CLAVE='MX-UE'))

-- lo de region AELC
UPDATE dbo.PEDIMPDET
SET     dbo.PEDIMPDET.PID_REGIONFIN='A'
FROM         dbo.PEDIMPDET INNER JOIN
                      dbo.VPEDEXP ON dbo.PEDIMPDET.PI_CODIGO = dbo.VPEDEXP.PI_CODIGO INNER JOIN
                      dbo.FACTEXPDET ON dbo.PEDIMPDET.PID_INDICED = dbo.FACTEXPDET.PID_INDICEDLIGA INNER JOIN
                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO INNER JOIN
                      dbo.DIR_CLIENTE ON dbo.FACTEXP.DI_DESTFIN = dbo.DIR_CLIENTE.DI_INDICE
WHERE     dbo.DIR_CLIENTE.PA_CODIGO IN
                          (SELECT PA_CODIGO FROM PAIS WHERE SPI_CODIGO IN ( SELECT SPI_CODIGO FROM SPI WHERE SPI_CLAVE='AELC'))

-- lo de mercado nacional
UPDATE dbo.PEDIMPDET
SET     dbo.PEDIMPDET.PID_REGIONFIN='M'
FROM         dbo.PEDIMPDET INNER JOIN
                      dbo.VPEDEXP ON dbo.PEDIMPDET.PI_CODIGO = dbo.VPEDEXP.PI_CODIGO INNER JOIN
                      dbo.FACTEXPDET ON dbo.PEDIMPDET.PID_INDICED = dbo.FACTEXPDET.PID_INDICEDLIGA INNER JOIN
                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO INNER JOIN
                      dbo.DIR_CLIENTE ON dbo.FACTEXP.DI_DESTFIN = dbo.DIR_CLIENTE.DI_INDICE
WHERE     (dbo.DIR_CLIENTE.PA_CODIGO IN
                          (SELECT     CF_PAIS_MX
                            FROM          dbo.CONFIGURACION))

-- lo de region nafta
UPDATE dbo.PEDIMPDET
SET     dbo.PEDIMPDET.PID_REGIONFIN='N'
FROM         dbo.PEDIMPDET INNER JOIN
                      dbo.VPEDEXP ON dbo.PEDIMPDET.PI_CODIGO = dbo.VPEDEXP.PI_CODIGO INNER JOIN
                      dbo.FACTEXPDET ON dbo.PEDIMPDET.PID_INDICED = dbo.FACTEXPDET.PID_INDICEDLIGA INNER JOIN
                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO INNER JOIN
                      dbo.DIR_CLIENTE ON dbo.FACTEXP.DI_DESTFIN = dbo.DIR_CLIENTE.DI_INDICE
WHERE     (dbo.DIR_CLIENTE.PA_CODIGO IN
                          (SELECT     CF_PAIS_USA
                            FROM          dbo.CONFIGURACION)) OR
                      (dbo.DIR_CLIENTE.PA_CODIGO IN
                          (SELECT     CF_PAIS_CA
                            FROM          dbo.CONFIGURACION))



























GO