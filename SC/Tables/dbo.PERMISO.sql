SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PERMISO] (
		[PE_CODIGO]            [int] NOT NULL,
		[PE_PERMISO]           [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PE_COMPLE]            [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PE_FOLIO]             [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PE_FECHA]             [smalldatetime] NOT NULL,
		[PE_PRODUC]            [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PE_TIPO]              [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PE_ORIGEN]            [int] NULL,
		[TC_CANT]              [decimal](38, 6) NULL,
		[AD_CODIGO]            [int] NULL,
		[AD_ALTERNA]           [int] NULL,
		[CL_CODIGO]            [int] NOT NULL,
		[DI_CODIGO]            [int] NULL,
		[PE_APROBADO]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[US_CODIGO]            [smallint] NULL,
		[IDE_CODIGO]           [smallint] NULL,
		[PE_FECHAVENC]         [datetime] NULL,
		[PE_FIRMAELEC]         [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PE_ANIO]              [smallint] NULL,
		[PE_REGIMEN]           [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PE_PAISESIMP]         [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PE_PERIODOCONS]       [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PE_IDENTMCIA]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PE_IDENTMCIAOTRO]     [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PE_USOMCIA]           [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PE_DESCMCIA]          [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AR_CODIGO]            [int] NULL,
		[PE_CONSUMOMCIA]       [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PE_OBSERVACIONES]     [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PE_DATOSCOMPL]        [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PE_CANT]              [decimal](38, 6) NOT NULL,
		[PE_COSTOT]            [decimal](38, 6) NOT NULL,
		[PE_SALDO]             [decimal](38, 6) NOT NULL,
		[PE_SALDOCOSTOT]       [decimal](38, 6) NOT NULL,
		[PE_ENUSO]             [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PE_ENUSOCOSTOT]       [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PE_ESTATUS]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		CONSTRAINT [IX_PERMISO]
		UNIQUE
		NONCLUSTERED
		([PE_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[PERMISO]
	ADD
	CONSTRAINT [PK_PERMISO]
	PRIMARY KEY
	NONCLUSTERED
	([PE_PERMISO], [PE_FOLIO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[PERMISO]
	ADD
	CONSTRAINT [DF_PERMISO_CL_CODIGO]
	DEFAULT (1) FOR [CL_CODIGO]
GO
ALTER TABLE [dbo].[PERMISO]
	ADD
	CONSTRAINT [DF_PERMISO_PE_APROBADO]
	DEFAULT ('S') FOR [PE_APROBADO]
GO
ALTER TABLE [dbo].[PERMISO]
	ADD
	CONSTRAINT [DF_PERMISO_PE_CANT]
	DEFAULT (0) FOR [PE_CANT]
GO
ALTER TABLE [dbo].[PERMISO]
	ADD
	CONSTRAINT [DF_PERMISO_PE_COSTOT]
	DEFAULT (0) FOR [PE_COSTOT]
GO
ALTER TABLE [dbo].[PERMISO]
	ADD
	CONSTRAINT [DF_PERMISO_PE_ENUSO]
	DEFAULT ('N') FOR [PE_ENUSO]
GO
ALTER TABLE [dbo].[PERMISO]
	ADD
	CONSTRAINT [DF_PERMISO_PE_ENUSOCOSTOT]
	DEFAULT ('N') FOR [PE_ENUSOCOSTOT]
GO
ALTER TABLE [dbo].[PERMISO]
	ADD
	CONSTRAINT [DF_PERMISO_PE_ESTATUS]
	DEFAULT ('A') FOR [PE_ESTATUS]
GO
ALTER TABLE [dbo].[PERMISO]
	ADD
	CONSTRAINT [DF_PERMISO_PE_PRODUC]
	DEFAULT ('') FOR [PE_PRODUC]
GO
ALTER TABLE [dbo].[PERMISO]
	ADD
	CONSTRAINT [DF_PERMISO_PE_SALDO]
	DEFAULT (0) FOR [PE_SALDO]
GO
ALTER TABLE [dbo].[PERMISO]
	ADD
	CONSTRAINT [DF_PERMISO_PE_SALDOCOSTOT]
	DEFAULT (0) FOR [PE_SALDOCOSTOT]
GO
