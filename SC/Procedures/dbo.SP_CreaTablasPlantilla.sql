SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- Este procedimiento se debera actualizar cada vez que se haga un cambio a las tablas de las plantillas
CREATE PROCEDURE [dbo].[SP_CreaTablasPlantilla]    as

declare @pxs_codigo int, @pxf_codigo int, @pxd_codigo int, @pxsf_codigo int, @pxm_codigo int, @pxff_codigo int

exec sp_droptable 'TempPlantillaExp'
CREATE TABLE [dbo].[TempPlantillaExp] (
	[PXP_CODIGO] [int] NULL ,
	[PXP_PLANTILLA] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[CR_CODIGO] [int] NULL ,
	[IMT_CODIGO] [int] NULL ,
	[PXP_FIJO_DELIM] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlantillaExp_PXP_FIJO_DELIM] DEFAULT ('D'),
	[PXP_TITULOS] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlantillaExp_PXP_TITULOS] DEFAULT ('N'),
	[PXP_SEPARACAMPO] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlantillaExp_PXP_SEPARACAMPO] DEFAULT ('T'),
	[PXP_OTROSEPARACAMPO] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlantillaExp_PXP_OTROSEPARACAMPO] DEFAULT ('|'),
	[PXP_TEXTQUAL] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlantillaExp_PXP_TEXTQUAL] DEFAULT ('N'),
	[PXP_CHRRELLENO] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlantillaExp_PXP_CHRRELLENO] DEFAULT (' '),
	[PXP_ORDENFECHA] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlantillaExp_PXP_ORDENFECHA] DEFAULT ('1'),
	[PXP_SEPARAFECHA] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlantillaExp_PXP_SEPARAFECHA] DEFAULT ('D'),
	[PXP_CUATROCIFRAS] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlantillaExp_PXP_CUATROCIFRAS] DEFAULT ('N'),
	[PXP_MESCONLETRAS] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlantillaExp_PXP_MESCONLETRAS] DEFAULT ('N'),
	[PXP_SEPARAHORA] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlantillaExp_PXP_SEPARAHORA] DEFAULT ('P'),
	[PXP_SEPARADECIMAL] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlantillaExp_PXP_SEPARADECIMAL] DEFAULT ('P'),
	[PXP_NOMBREARCHIVO] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PXP_MULTFILE] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlantillaExp_PXP_MULTFILE] DEFAULT ('N'),
	[PXP_TRIGGERFILE] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PXP_READONLY] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlantillaExp_PXP_READONLY] DEFAULT ('N'),
	[PXP_TRANSKEYS] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlantillaExp_PXP_TRANSKEYS] DEFAULT ('S'),
	[PXP_CONTENIDOTRIGGER] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlantillaExp_PXP_CONTENIDOTRIGGER] DEFAULT ('N'),
	[PXP_GENERATABLAS] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlantillaExp_PXP_GENERATABLAS] DEFAULT ('N'),
	[PXP_ORDENARCHIVOXSEC] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlantillaExp_PXP_ORDENARCHIVOXSEC] DEFAULT ('N'),
	[PXP_NOMBRE_RPT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PXP_TABLA_RPT] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PXP_CAMPO_RPT] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PXP_CAMPONOMBRE_PDF] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	CONSTRAINT [IX_TempPlantillaExp] UNIQUE  NONCLUSTERED 
	(
		[PXP_CODIGO]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
) ON [PRIMARY]


exec sp_droptable 'TempPlntExpSecc'
CREATE TABLE [dbo].[TempPlntExpSecc] (
	[PXS_CODIGO] [int] NULL ,
	[PXP_CODIGO] [int] NULL ,
	[PXS_SECCION] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PXS_ORDENSECCION] [int] NULL CONSTRAINT [DF_TempPlntExpSecc_PXS_ORDENSECCION] DEFAULT (0),
	[PXS_AGRUPACION] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlntExpSecc_PXS_AGRUPACION] DEFAULT ('S'),
	[PXS_QUERY] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlntExpSecc_PXS_QUERY] DEFAULT (''),
	[PXS_PARAMTEXT] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlntExpSecc_PXS_PARAMTEXT] DEFAULT (''),
	[PXS_PARAMTEXT2] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlntExpSecc_PXS_PARAMTEXT2] DEFAULT (''),
	[PXS_FILTRO] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlntExpSecc_PXS_FILTRO] DEFAULT (''),
	[PXS_ESPRINCIPAL] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlntExpSecc_PXS_ESPRINCIPAL] DEFAULT ('N'),
	[PXS_PADRE] [int] NULL CONSTRAINT [DF_TempPlntExpSecc_PXS_PADRE] DEFAULT (0),
	[PXS_CODIGONVO] [int] IDENTITY (1, 1) NOT NULL ,
	[PXS_FILTROFORMULA] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlntExpSecc_PXS_FILTROFORMULA] DEFAULT (''),
	[PXS_OMITIRSININFO] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlntExpSecc_PXS_OMITIRSININFO] DEFAULT ('N'),
	[PXS_REPETIRSECCION] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlntExpSecc_PXS_REPETIRSECCION] DEFAULT ('N'),
	[PXS_OMITIRTRANSSININFO] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlntExpSecc_PXS_OMITIRTRANSSININFO] DEFAULT ('N'),
	[PXS_QUERYORDERBY] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlntExpSecc_PXS_QUERYORDERBY] DEFAULT (''),
	CONSTRAINT [IX_TempPlntExpSecc] UNIQUE  NONCLUSTERED 
	(
		[PXS_CODIGO]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
) ON [PRIMARY]

--declare @pxs_codigo int
set @pxs_codigo=isnull((select max(pxs_codigo)+1 from PlntExpSecc),1)
--print @pxs_codigo 
dbcc checkident (TempPlntExpSecc, reseed, @pxs_codigo) WITH NO_INFOMSGS

/*exec sp_droptable 'TempPlntExpCnx'
CREATE TABLE [dbo].[TempPlntExpCnx] (
	[PXC_CODIGO] [int] NULL ,
	[PXP_CODIGO] [int] NULL CONSTRAINT [DF_TempPlntExpCnx_PXP_CODIGO] DEFAULT (0),
	[PXC_NOMBRE] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PXC_TIPOEMPRESA] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlntExpCnx_PXC_TIPOEMPRESA] DEFAULT ('A'),
	[PXC_EMPRESA] [int] NULL CONSTRAINT [DF_TempPlntExpCnx_PXC_EMPRESA] DEFAULT (0),
	[PXC_RUTALOCAL] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PXC_FTP] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PXC_RUTAREMOTA] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PXC_USERNAME] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PXC_PASSWORD] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PXC_FILENUMBER] [int] NULL CONSTRAINT [DF_TempPlntExpCnx_PXC_FILENUMBER] DEFAULT (1),
	[PXC_UNE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PXC_CODIGONVO] [int] IDENTITY (1, 1) NULL 
) ON [PRIMARY]


set @consecutivo=(select max(pxc_codigo)+1 from PlntExpCnx)
dbcc checkident (TempPlntExpCnx, reseed, @consecutivo) WITH NO_INFOMSGS*/

exec sp_droptable 'TempPlntExpDet'
CREATE TABLE [dbo].[TempPlntExpDet] (
	[PXP_CODIGO] [int] NOT NULL ,
	[PXT_TBLNAME] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PXT_SELECTED] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlntExpDet_PXT_SELECTED] DEFAULT ('N'),
	CONSTRAINT [PK_TempPlntExpDet] PRIMARY KEY  CLUSTERED 
	(
		[PXP_CODIGO],
		[PXT_TBLNAME]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
) ON [PRIMARY]


exec sp_droptable 'TempPlntExpFormula'
CREATE TABLE [dbo].[TempPlntExpFormula] (
	[PXF_CODIGO] [int] NULL ,
	[PXS_CODIGO] [int] NOT NULL CONSTRAINT [DF_TempPlntExpFormula_PXS_CODIGO] DEFAULT (0),
	[PXF_FORMULANAME] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PXF_FORMULASTRING] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PXF_DATATYPE] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlntExpFormula_PXF_DATATYPE] DEFAULT ('0'),
	[PXF_VERIFICADA] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlntExpFormula_PXF_VERIFICADA] DEFAULT ('N'),
	[BUM_CODIGO] [int] NULL CONSTRAINT [DF_TempPlntExpFormula_BUM_CODIGO] DEFAULT (0),
	[PXF_CODIGONVO] [int] IDENTITY (1, 1) NOT NULL ,
	CONSTRAINT [PK_TempPlntExpFormula] PRIMARY KEY  CLUSTERED 
	(
		[PXS_CODIGO],
		[PXF_FORMULANAME]
	)  ON [PRIMARY] 
) ON [PRIMARY] 

set @pxf_codigo=isnull((select max(pxf_codigo)+1 from PlntExpFormula),1)
dbcc checkident (TempPlntExpFormula, reseed, @pxf_codigo) WITH NO_INFOMSGS


exec sp_droptable 'TempPlntExpSeccDet'
CREATE TABLE [dbo].[TempPlntExpSeccDet] (
	[PXD_CODIGO] [int] NOT NULL ,
	[PXS_CODIGO] [int] NULL ,
	[PXD_MOSTRAR] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlntExpSeccDet_PXD_MOSTRAR] DEFAULT ('S'),
	[PXD_TIPOCOL] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlntExpSeccDet_PXD_TIPOCOL] DEFAULT ('C'),
	[PXD_TABLA] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlntExpSeccDet_PXD_TABLA] DEFAULT (''),
	[IMF_CODIGO] [int] NULL CONSTRAINT [DF_TempPlntExpSeccDet_IMF_CODIGO] DEFAULT (0),
	[PXF_CODIGO] [int] NULL CONSTRAINT [DF_TempPlntExpSeccDet_PXF_CODIGO] DEFAULT (0),
	[PXD_DETALLE] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PXD_OBLIGATORIO] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlntExpSeccDet_PXD_OBLIGATORIO] DEFAULT ('N'),
	[PXD_SIZE] [int] NULL CONSTRAINT [DF_TempPlntExpSeccDet_PXD_SIZE] DEFAULT (20),
	[PXD_AGRUPACION] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlntExpSeccDet_PXD_AGRUPACION] DEFAULT ('A'),
	[PXD_CASONULO] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PXD_VALOROMISION] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PXD_ORDENCOL] [int] NULL CONSTRAINT [DF_TempPlntExpSeccDet_PXD_ORDENCOL] DEFAULT (0),	[PXD_PROCSOLO] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlntExpSeccDet_PXD_PROCSOLO] DEFAULT ('N'),
	[PXD_CODIGONVO] [int] IDENTITY (1, 1) NOT NULL ,
	[PXD_IDENTSECCION] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlntExpSeccDet_PXD_IDENTSECCION] DEFAULT ('N'),
	[PXD_ININEWROW] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlntExpSeccDet_PXD_ININEWROW] DEFAULT ('N'),
	[PXD_ACUMULATOTALES] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlntExpSeccDet_PXD_ACUMULATOTALES] DEFAULT ('N'),
	[PXD_QUERY] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlntExpSeccDet_PXD_QUERY] DEFAULT (''),
	CONSTRAINT [PK_TempPlntExpSeccDet] PRIMARY KEY  CLUSTERED 
	(
		[PXD_CODIGO]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
) ON [PRIMARY]

set @pxd_codigo=isnull((select max(pxd_codigo)+1 from PlntExpSeccDet),1)
dbcc checkident (TempPlntExpSeccDet, reseed, @pxd_codigo) WITH NO_INFOMSGS


exec sp_droptable 'TempPlntExpSeccFiltro'
CREATE TABLE [dbo].[TempPlntExpSeccFiltro] (
	[PXSF_CODIGO] [int] NOT NULL ,
	[PXS_CODIGO] [int] NULL ,
	[PXSF_CAMPO1] [int] NULL ,
	[PXSF_CAMPO2] [int] NULL CONSTRAINT [DF_TempPlntExpSeccFiltro_PXSF_CAMPO2] DEFAULT (0),
	[PXSF_OPERADOR] [int] NULL ,
	[PXSF_IGUAL] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PXSF_MIN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PXSF_MAX] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PXSF_NULL] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlntExpSeccFiltro_PXSF_NULL] DEFAULT ('N'),
	[PXSF_CODIGONVO] [int] IDENTITY (1, 1) NOT NULL ,
	CONSTRAINT [PK_TempPlntExpSeccFiltro] PRIMARY KEY  NONCLUSTERED 
	(
		[PXSF_CODIGO]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
) ON [PRIMARY]

set @pxsf_codigo=isnull((select max(pxsf_codigo)+1 from PlntExpSeccFiltro),1)
dbcc checkident (TempPlntExpSeccFiltro, reseed, @pxsf_codigo) WITH NO_INFOMSGS


exec sp_droptable 'TempPlntExpSeccFiltro_IN'
CREATE TABLE [dbo].[TempPlntExpSeccFiltro_IN] (
	[PXSF_CODIGO] [int] NULL ,
	[PXSF_ELEMENTO] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]


exec sp_droptable 'TempPlntExpSeccPrm'
CREATE TABLE [dbo].[TempPlntExpSeccPrm] (
	[PXM_CODIGO] [int] NULL ,
	[PXS_CODIGO] [int] NULL ,
	[PXM_ORDEN] [int] NULL CONSTRAINT [DF_TempPlntExpSeccPrm_PXM_ORDEN] DEFAULT (0),
	[IMF_CODIGO] [int] NULL CONSTRAINT [DF_TempPlntExpSeccPrm_IMF_CODIGO] DEFAULT (0),
	[PXM_LABELPARAMETRO] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PXM_OPERADOR] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlntExpSeccPrm_PXM_OPERADOR] DEFAULT ('='),
	[PXM_DISPLAYFIELDS] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PXM_TIPOPARAM] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlntExpSeccPrm_PXM_TIPOPARAM] DEFAULT ('U') ,
	[PXM_PROCSOLO] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlntExpSeccPrm_PXM_PROCSOLO] DEFAULT ('N'),
	[PXM_CODIGONVO] [int] IDENTITY (1, 1) NOT NULL 
) ON [PRIMARY]


set @pxm_codigo=isnull((select max(pxm_codigo)+1 from PlntExpSeccPrm),1)
dbcc checkident (TempPlntExpSeccPrm, reseed, @pxm_codigo) WITH NO_INFOMSGS


exec sp_droptable 'TempBUSQUEDAMASCARA'
CREATE TABLE [dbo].[TempBUSQUEDAMASCARA] (
	[BUM_CODIGO] [int] NULL ,
	[BUM_TEXTOMOSTRAR] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[BUM_TIPO] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[BUM_DECIMAL] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempBUSQUEDAMASCARA_BUM_DECIMAL] DEFAULT ('C'),
	[BUM_REDONDEO] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempBUSQUEDAMASCARA_BUM_REDONDEO] DEFAULT ('C'),
	[BUM_SEPARAMIL] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempBUSQUEDAMASCARA_BUM_SEPARAMIL] DEFAULT ('N'),
	[BUM_SIMADICIONA] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[BUM_SIMPOSICION] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[BUM_NEGATIVO] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempBUSQUEDAMASCARA_BUM_NEGATIVO] DEFAULT (1),
	[BUM_DATEORDER] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempBUSQUEDAMASCARA_BUM_DATEORDER] DEFAULT (2),
	[BUM_MESFORMAT] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempBUSQUEDAMASCARA_BUM_MESFORMAT] DEFAULT (3),
	[BUM_DIAFORMAT] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempBUSQUEDAMASCARA_BUM_DIAFORMAT] DEFAULT (2),
	[BUM_ANIOFORMAT] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempBUSQUEDAMASCARA_BUM_ANIOFORMAT] DEFAULT (2),
	[BUM_DATESEPARA] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempBUSQUEDAMASCARA_BUM_DATESEPARA] DEFAULT ('/'),
	[BUM_MASCARATEXT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]

exec sp_droptable 'TempPlntExpSeccFiltroFormula'
CREATE TABLE [dbo].[TempPlntExpSeccFiltroFormula] (
	[PXFF_CODIGO] [int] NOT NULL ,
	[PXFF_CODIGONVO] [int] IDENTITY (1, 1) NOT NULL ,
	[PXS_CODIGO] [int] NULL ,
	[PXFF_FORMULA] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PXFF_OPERADOR] [int] NULL ,
	[PXFF_IGUAL] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PXFF_MIN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PXFF_MAX] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PXFF_NULL] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPlntExpSeccFiltroFormula_PXSF_NULL] DEFAULT ('N'),
	CONSTRAINT [PK_TempPlntExpSeccFiltroFormula] PRIMARY KEY  NONCLUSTERED 
	(
		[PXFF_CODIGO]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
) ON [PRIMARY]

set @pxff_codigo=isnull((select max(pxff_codigo)+1 from PlntExpSeccFiltroFormula),1)
dbcc checkident (TempPlntExpSeccFiltroFormula, reseed, @pxff_codigo) WITH NO_INFOMSGS

exec sp_droptable 'TempPlntExpSeccFiltroFormula_IN'
CREATE TABLE [dbo].[TempPlntExpSeccFiltroFormula_IN] (
	[PXFF_CODIGO] [int] NULL ,
	[PXFF_ELEMENTO] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]






GO
