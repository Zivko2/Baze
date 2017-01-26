SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE BORRARINFORMACION AS
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[COMBOBOXES]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE COMBOBOXES

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IMPORTFIELDS]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE IMPORTFIELDS

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IMPORTTABLES]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE IMPORTTABLES

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IMPORTTABLESDETCONT]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE IMPORTTABLESDETCONT

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FORMATABLA]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE FORMATABLA

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[LOOKUPFIELD]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE LOOKUPFIELD

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[LOOKUPTABLE]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE LOOKUPTABLE

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TDOCUMENTO]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE TDOCUMENTO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TENVIO]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE TENVIO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TSERVICIO]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE TSERVICIO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RELIDENTIFICATIPOTASA]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE RELIDENTIFICATIPOTASA

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ERRORCAMPDESC]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE ERRORCAMPDESC

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ERRORREGDESC]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE ERRORREGDESC

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ERRORBANCO]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE ERRORBANCO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ERRORSAAI]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE ERRORSAAI

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ERRORSAAISINT]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE ERRORSAAISINT

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ACTUALIZAMASA]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE ACTUALIZAMASA

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FOREIGNKEYS]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE FOREIGNKEYS

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UPDATEINFO]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE UPDATEINFO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RELCLAVEPEDIDENTIFICA]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE RELCLAVEPEDIDENTIFICA

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CONEXIONARCHIVO]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE CONEXIONARCHIVO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TALMACEN]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE TALMACEN

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TCOMPRA]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE TCOMPRA

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CONTRIBUCIONFIJA]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE CONTRIBUCIONFIJA

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TEMPAQUE]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE TEMPAQUE

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TRECIBE]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE TRECIBE

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TINBOND]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE TINBOND

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TREQUISICION]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE TREQUISICION

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CLASIFICA]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE CLASIFICA

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TPERSONAL]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE TPERSONAL

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CONFIGURATMOVIMIENTO]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE CONFIGURATMOVIMIENTO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TIPS]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE TIPS

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ACTUALIZAMASADET]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE ACTUALIZAMASADET

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TREPORTEDEL]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE TREPORTEDEL

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CONTRIBUCION]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE CONTRIBUCION

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TPAGO]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE TPAGO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SPI]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE SPI


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SECTOR]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
TRUNCATE TABLE SECTOR
GO
