SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

















































CREATE VIEW dbo.VPID_DESTNAFTA
with encryption as
SELECT     dbo.FACTEXPDET.FED_INDICED, 'PA_CODIGO'=case when dbo.FACTEXP.FE_TIPO ='V' THEN (select max(pa_codigo) from pais where pa_corto='MX') ELSE 
(case when dbo.FACTEXP.TN_CODIGO in (select tn_codigo from tenvio where tn_descrip='inbond') and dbo.DIR_CLIENTE.PA_CODIGO in (select max(pa_codigo) from pais where pa_corto='MX') then (select max(pa_codigo) from pais where pa_corto='USA') else dbo.DIR_CLIENTE.PA_CODIGO end) END, 
 'PID_DESTNAFTA'= CASE 
when dbo.FACTEXP.FE_TIPO ='V' THEN 'M' else
(case when dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT CF_PAIS_MX FROM CONFIGURACION) THEN 'M'
 when dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT CF_PAIS_USA FROM CONFIGURACION) or dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT CF_PAIS_CA FROM CONFIGURACION)
then 'N'  WHEN 	  dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT PA_CODIGO FROM PAIS WHERE SPI_CODIGO IN ( SELECT SPI_CODIGO FROM SPI WHERE SPI_CLAVE='MX-UE')) 
then 'U' when 	  dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT PA_CODIGO FROM PAIS WHERE SPI_CODIGO IN ( SELECT SPI_CODIGO FROM SPI WHERE SPI_CLAVE='AELC')) 
then 'A'  else 'F' end) end
FROM         dbo.DIR_CLIENTE RIGHT OUTER JOIN
                      dbo.FACTEXP ON dbo.DIR_CLIENTE.DI_INDICE = dbo.FACTEXP.DI_DESTFIN RIGHT OUTER JOIN
                      dbo.FACTEXPDET ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO










































































GO
