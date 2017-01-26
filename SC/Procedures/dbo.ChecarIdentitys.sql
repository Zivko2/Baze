SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


























CREATE PROCEDURE dbo.ChecarIdentitys  (@Mensage sysname output)   as


/* actualizada al 08 enero del 2002 */

-- para las tablas que deben de tener identity
set @Mensage=''
if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ACTIVIDAD]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla ACTIVIDAD deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ADMLOCAL]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla ADMLOCAL deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ADUANA]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla ADUANA deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AGENCIA]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla AGENCIA deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AGENCIACONEXION]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla AGENCIACONEXION deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ALMACENDESP]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla ALMACENDESP deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ARANCELENTRY]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla ARANCELENTRY deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BOM]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla BOM deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BOM_STRUCT]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla BOM_STRUCT deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BONDTYPE]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla BONDTYPE deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CAJA]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla CAJA deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CAMION]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla CAMION deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CATTEXTIL]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla CATTEXTIL deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[COMBOBOXES]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla COMBOBOXES deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CONT_AGENCIA]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla CONT_AGENCIA deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CONT_CLIENTE]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla CONT_CLIENTE deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CONT_CTRANSPOR]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla CONT_CTRANSPOR deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CONTRIBUCION]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla CONTRIBUCION deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[COSTSUBB_247]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla COSTSUBB_247 deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[COSTSUBBAJ]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla COSTSUBBAJ deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[COSTSUBBASBDETGRAJ]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla COSTSUBBASBDETGRAJ deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[COSTSUBBASC]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla COSTSUBBASC deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[COSTSUBD]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla COSTSUBD deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[COSTSUBREL_BASEDATOS]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla COSTSUBREL_BASEDATOS deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CTRANSPOR]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla CTRANSPOR deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DEPTOS]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla DEPTOS deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DIR_CLIENTE]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla DIR_CLIENTE deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DTA]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla DTA deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ENTRADA_A]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla ENTRADA_A deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ENTRADA_B]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla ENTRADA_B deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ESTADO]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla ESTADO deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FACTCONS]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla FACTCONS deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FCC]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla FCC deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FUNCION]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla FUNCION deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IMPLEMENTAPEDIMP]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla IMPLEMENTAPEDIMP deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[INCREMENTABLE]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla INCREMENTABLE deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[LISTAEXPCONT]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla LISTAEXPCONT deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IMPORTFIELDS]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla IMPORTFIELDS deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IMPORTTABLES]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla IMPORTTABLES deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[INCOTERMS]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla INCOTERMS deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[KARDESPED]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla KARDESPED deberia tener IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[LOOKUPFIELD]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla LOOKUPFIELD no deberia tener IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[LOOKUPTABLE]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla LOOKUPTABLE no deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MAESTROCOSTO]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla MAESTROCOSTO deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MAESTROSUST]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla MAESTROSUST deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MATPELIGROSO]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla MATPELIGROSO deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MEDIDA]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla MEDIDA deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MEDIOTRAN]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla MEDIOTRAN deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MISING]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla MISING deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MONEDA]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla MONEDA deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PAIS]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PAIS deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PAISARA]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PAISARA deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PCKLISTCONT]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PCKLISTCONT deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PERSONAL]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PERSONAL deberia tener IDENTITY'




if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PUERTO]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PUERTO deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PUESTO]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PUESTO deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RECARGO]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla RECARGO deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[REGIMEN]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla REGIMEN deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[REPEXPUSACA]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla REPEXPUSACA deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RUTA]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla RUTA deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SECTOR]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla SECTOR deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SECTORARA]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla SECTORARA deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SPI]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla SPI deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TCAJA]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla TCAJA deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TEMBARQUE]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla TEMBARQUE deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TENVIO]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla TENVIO deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TERMINO]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla TERMINO deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TFACTURA]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla TFACTURA deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TINBOND]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla TINBOND deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TIPO]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla TIPO deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TPAGO]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla TPAGO deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TRANSMISION]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla TRANSMISION deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TREPORTECLASIF]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla TREPORTECLASIF deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TTASA]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla TTASA deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TVALORA]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla TVALORA deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[VINCULA]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla VINCULA deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[YARDA]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla YARDA deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ZONA]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla ZONA deberia tener IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TREPORTE]')
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla TREPORTE deberia tener IDENTITY'



/* ==================== para las tablas que NO deben de llevar identity =================================*/


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ANEXO24]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla ANEXO24 no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ARANCEL]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla ARANCEL no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BOM_ARANCEL]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla BOM_ARANCEL no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TempBOM_CALCULABASE]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla TempBOM_CALCULABASE no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BOM_DESCTEMP]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla BOM_DESCTEMP no deberia llevar IDENTITY'



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TempBomCosto]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla TempBomCosto no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CANADACINV]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla CANADACINV no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[COMMINV]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla COMMINV no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MAINBROKER]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla MAINBROKER no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[COMMINVDET]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla COMMINVDET no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CONFIGFOLIOMSTR]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla CONFIGFOLIOMSTR no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CONFIGURACION]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla CONFIGURACION no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CONFIGURACLAVEPED]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla CONFIGURACLAVEPED no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CONFIGURACOSTSUB]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla CONFIGURACOSTSUB no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CONFIGURAFOLIOENT]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla CONFIGURAFOLIOENT no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CONFIGURAFOLIOSAL]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla CONFIGURAFOLIOSAL no deberia llevar IDENTITY'



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CONFIGURATEMBARQUE]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla CONFIGURATEMBARQUE no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CONFIGURATFACT]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla CONFIGURATFACT no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CONFIGURATIEMPO]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla CONFIGURATIEMPO no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CONFIGURATIPO]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla CONFIGURATIPO no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CONSECUTIVO]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla CONSECUTIVO no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CONSTEXP]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla CONSTEXP no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CONSTEXPCONS]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla CONSTEXPCONS no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CONSTEXPCONT]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla CONSTEXPCONT no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CONSTEXPDET]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla CONSTEXPDET no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CONSTEXPEMPAQUE]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla CONSTEXPEMPAQUE no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CONSTEXPPED]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla CONSTEXPPED no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CONSTEXPRELEMPAQUE]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla CONSTEXPRELEMPAQUE no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CONSULTA]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla CONSULTA no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CONTROLCAMION]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla CONTROLCAMION no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[COSTSUB_CONFIGEXA]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla COSTSUB_CONFIGEXA no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[COSTSUB_DESGLOSE]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla COSTSUB_DESGLOSE no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[COSTSUBA]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla COSTSUBA no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[COSTSUBB]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla COSTSUBB no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[COSTSUBBASA]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla COSTSUBBASA no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[COSTSUBBASBDETARAAJ]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla COSTSUBBASBDETARAAJ no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[COSTSUBBASBESTAJ]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla COSTSUBBASBESTAJ no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[COSTSUBBASC247]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla COSTSUBBASC247 no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[COSTSUBBASC247DET]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla COSTSUBBASC247DET no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[COSTSUBDFLOW]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla COSTSUBDFLOW no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[COSTSUBDPT]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla COSTSUBDPT no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[COSTSUBPER]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla COSTSUBPER no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[COSTSUBREL_TABLAS]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla COSTSUBREL_TABLAS no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DECANUAL]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla DECANUAL no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DESTRUCCIONDESP]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla DESTRUCCIONDESP no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[COSTSUBREL_TABLAS]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla COSTSUBREL_TABLAS no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DICTAMENFISCAL]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla DICTAMENFISCAL no deberia llevar IDENTITY'



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ENTRACAMION]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla ENTRACAMION no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ENTRYSUM]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla ENTRYSUM no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ENTRYSUMARA]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla ENTRYSUMARA no deberia llevar IDENTITY'

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[EQUIVALE]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla EQUIVALE no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FACTCONSTQ]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla FACTCONSTQ no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FACTEXP]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla FACTEXP no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FACTEXPAGRU]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla FACTEXPAGRU no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FACTEXPCONT]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla FACTEXPCONT no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FACTEXPDET]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla FACTEXPDET no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FACTEXPEMPAQUE]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla FACTEXPEMPAQUE no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FACTEXPRELEMPAQUE]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla FACTEXPRELEMPAQUE no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FACTIMP]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla FACTIMP no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FACTIMPAGRU]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla FACTIMPAGRU no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FACTIMPCONT]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla FACTIMPCONT no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FACTIMPDET]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla FACTIMPDET no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FACTIMPEMPAQUE]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla FACTIMPEMPAQUE no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FACTIMPPED]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla FACTIMPPED no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FACTIMPRELEMPAQUE]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla FACTIMPRELEMPAQUE no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FAX]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla FAX no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FORMATABLA]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla FORMATABLA no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[HEBOM]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla HEBOM no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IDENTIFICA]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla IDENTIFICA no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IDENTIFICADET]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla IDENTIFICADET no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IMPLEMENTA]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla IMPLEMENTA no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IMPLEMENTACONTRIB]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla IMPLEMENTACONTRIB no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IMPLEMENTADET]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla IMPLEMENTADET no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IMPLEMENTAREL]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla IMPLEMENTAREL no deberia llevar IDENTITY'



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IMPORTSPEC]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla IMPORTSPEC no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IMPORTSPECDET]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla IMPORTSPECDET no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IMPPEDIMPTMP]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla IMPPEDIMPTMP no deberia llevar IDENTITY'



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[INEGI]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla INEGI no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[INPC]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla INPC no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[KARARANCEL]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla KARARANCEL no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[KARDESPED1]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla KARDESPED1 no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[KARDESPEDCONT]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla KARDESPEDCONT no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[LISTAEXP]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla LISTAEXP no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[LISTAEXPDET]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla LISTAEXPDET no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[LOGO]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla LOGO no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MAESTRO]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla MAESTRO no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MAESTROAUX]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla MAESTROAUX no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MAESTROAUXDET]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla MAESTROAUXDET no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MAESTROCLIENTE]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla MAESTROCLIENTE no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MAESTRODEF]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla MAESTRODEF no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MAESTROMEDIDA]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla MAESTROMEDIDA no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MAESTROPROVEE]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla MAESTROPROVEE no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[NAFTA]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla NAFTA no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[NAFTAACUMULA]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla NAFTAACUMULA no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OMISION]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla OMISION no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OMISIONAGRU]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla OMISIONAGRU no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OMISIONMAESTRO]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla OMISIONMAESTRO no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OMISIONRELFACTPED]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla OMISIONRELFACTPED no deberia llevar IDENTITY'



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PCKLIST]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PCKLIST no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PCKLISTDET]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PCKLISTDET no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PEDEMPAQ]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PEDEMPAQ no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PEDEXP]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PEDEXP no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PEDEXPCONT]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PEDEXPCONT no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PEDEXPDET]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PEDEXPDET no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PEDEXPDETB]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PEDEXPDETB no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PEDEXPDETPERM]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PEDEXPDETPERM no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PEDEXPFACT]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PEDEXPFACT no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PEDIMP]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PEDIMP no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PEDIMPCONT]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PEDIMPCONT no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PEDIMPCONTRIBUCION]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PEDIMPCONTRIBUCION no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PEDIMPDET]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PEDIMPDET no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PEDIMPDETB]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PEDIMPDETB no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PEDIMPDETIDENTIFICA]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PEDIMPDETIDENTIFICA no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PEDIMPDETPERM]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PEDIMPDETPERM no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PEDIMPFP]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PEDIMPFP no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PEDIMPIDENTIFICA]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PEDIMPIDENTIFICA no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PEDIMPINCREMENTA]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PEDIMPINCREMENTA no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PEDIMPTIEMPO]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PEDIMPTIEMPO no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PEDKITDET]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PEDKITDET no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PERMISO]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PERMISO no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PERMISOAGENCIA]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PERMISOAGENCIA no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PERMISOCLIENTES]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PERMISOCLIENTES no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PERMISODET]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PERMISODET no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PERMISOGRAL]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PERMISOGRAL no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PERMISOPORCENTAJE]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PERMISOPORCENTAJE no deberia llevar IDENTITY'



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PERMISOPT]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PERMISOPT no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PERMISOSERVICIOS]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PERMISOSERVICIOS no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PERMISOVENTAS]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PERMISOVENTAS no deberia llevar IDENTITY'



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PROINVOICE]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PROINVOICE no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PROYCONSDET]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PROYCONSDET no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PROYDET]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PROYDET no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PROYECTA]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla PROYECTA no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RANGOARA]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla RANGOARA no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RECADUAN]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla RECADUAN no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RECADUANDET]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla RECADUANDET no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RELCLAVEPEDREG]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla RELCLAVEPEDREG no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RELCTRANSPORMEDIOTRAN]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla RELCTRANSPORMEDIOTRAN no deberia llevar IDENTITY'



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RELPERSONALDEPTOS]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla RELPERSONALDEPTOS no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RELTEMBTIPO]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla RELTEMBTIPO no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RELTFACTCLAPED]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla RELTFACTCLAPED no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RELTFACTTEMBAR]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla RELTFACTTEMBAR no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RETRABAJO]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla RETRABAJO no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[REVORIGEN]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla REVORIGEN no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SALIDACAMION]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla SALIDACAMION no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SHIPINST]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla SHIPINST no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SUSTITUTO]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla SUSTITUTO no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TCAMBIO]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla TCAMBIO no deberia llevar IDENTITY'


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TDOCUMENTO]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla TDOCUMENTO deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TPROVEEDOR]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla TPROVEEDOR no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TPROYECTA]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla TPROYECTA no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TRANSFER]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla TRANSFER no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TRANSFERCONS]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla TRANSFERCONS no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TRANSFERCONT]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla TRANSFERCONT no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TRANSFERDET]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla TRANSFERDET no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TRANSFEREMPAQUE]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla TRANSFEREMPAQUE no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TRANSFERPED]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla TRANSFERPED no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TRANSFERRELEMPAQUE]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla TRANSFERRELEMPAQUE no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TREPORTEFRMS]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla TREPORTEFRMS no deberia llevar IDENTITY'


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[VERSIONINFO]') 
and OBJECTPROPERTY(id, N'TableHasIdentity') = 1)
set @Mensage=@Mensage+' La tabla VERSIONINFO no deberia llevar IDENTITY'



GO
