SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PlantillaExp] (
		[PXP_CODIGO]                  [int] NOT NULL,
		[PXP_PLANTILLA]               [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CR_CODIGO]                   [int] NULL,
		[IMT_CODIGO]                  [int] NULL,
		[PXP_FIJO_DELIM]              [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PXP_TITULOS]                 [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PXP_SEPARACAMPO]             [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PXP_OTROSEPARACAMPO]         [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PXP_TEXTQUAL]                [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PXP_CHRRELLENO]              [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PXP_ORDENFECHA]              [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PXP_SEPARAFECHA]             [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PXP_CUATROCIFRAS]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PXP_MESCONLETRAS]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PXP_SEPARAHORA]              [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PXP_SEPARADECIMAL]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PXP_NOMBREARCHIVO]           [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PXP_MULTFILE]                [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PXP_TRIGGERFILE]             [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PXP_READONLY]                [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PXP_TRANSKEYS]               [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PXP_CONTENIDOTRIGGER]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PXP_GENERATABLAS]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PXP_ORDENARCHIVOXSEC]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PXP_NOMBRE_RPT]              [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PXP_TABLA_RPT]               [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PXP_CAMPO_RPT]               [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PXP_CAMPONOMBRE_PDF]         [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PXP_INFORMACION_TRIGGER]     [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_PlantillaExp]
		UNIQUE
		NONCLUSTERED
		([PXP_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PlantillaExp]
	ADD
	CONSTRAINT [PK_PlantillaExp]
	PRIMARY KEY
	CLUSTERED
	([PXP_PLANTILLA])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[PlantillaExp]
	ADD
	CONSTRAINT [DF_PlantillaExp_PXP_CHRRELLENO]
	DEFAULT (' ') FOR [PXP_CHRRELLENO]
GO
ALTER TABLE [dbo].[PlantillaExp]
	ADD
	CONSTRAINT [DF_PlantillaExp_PXP_CONTENIDOTRIGGER]
	DEFAULT ('N') FOR [PXP_CONTENIDOTRIGGER]
GO
ALTER TABLE [dbo].[PlantillaExp]
	ADD
	CONSTRAINT [DF_PlantillaExp_PXP_CUATROCIFRAS]
	DEFAULT ('N') FOR [PXP_CUATROCIFRAS]
GO
ALTER TABLE [dbo].[PlantillaExp]
	ADD
	CONSTRAINT [DF_PlantillaExp_PXP_FIJO_DELIM]
	DEFAULT ('D') FOR [PXP_FIJO_DELIM]
GO
ALTER TABLE [dbo].[PlantillaExp]
	ADD
	CONSTRAINT [DF_PlantillaExp_PXP_GENERATABLAS]
	DEFAULT ('N') FOR [PXP_GENERATABLAS]
GO
ALTER TABLE [dbo].[PlantillaExp]
	ADD
	CONSTRAINT [DF_PlantillaExp_PXP_MESCONLETRAS]
	DEFAULT ('N') FOR [PXP_MESCONLETRAS]
GO
ALTER TABLE [dbo].[PlantillaExp]
	ADD
	CONSTRAINT [DF_PlantillaExp_PXP_MULTFILE]
	DEFAULT ('N') FOR [PXP_MULTFILE]
GO
ALTER TABLE [dbo].[PlantillaExp]
	ADD
	CONSTRAINT [DF_PlantillaExp_PXP_ORDENARCHIVOXSEC]
	DEFAULT ('N') FOR [PXP_ORDENARCHIVOXSEC]
GO
ALTER TABLE [dbo].[PlantillaExp]
	ADD
	CONSTRAINT [DF_PlantillaExp_PXP_ORDENFECHA]
	DEFAULT ('1') FOR [PXP_ORDENFECHA]
GO
ALTER TABLE [dbo].[PlantillaExp]
	ADD
	CONSTRAINT [DF_PlantillaExp_PXP_OTROSEPARACAMPO]
	DEFAULT ('|') FOR [PXP_OTROSEPARACAMPO]
GO
ALTER TABLE [dbo].[PlantillaExp]
	ADD
	CONSTRAINT [DF_PlantillaExp_PXP_READONLY]
	DEFAULT ('N') FOR [PXP_READONLY]
GO
ALTER TABLE [dbo].[PlantillaExp]
	ADD
	CONSTRAINT [DF_PlantillaExp_PXP_SEPARACAMPO]
	DEFAULT ('T') FOR [PXP_SEPARACAMPO]
GO
ALTER TABLE [dbo].[PlantillaExp]
	ADD
	CONSTRAINT [DF_PlantillaExp_PXP_SEPARADECIMAL]
	DEFAULT ('P') FOR [PXP_SEPARADECIMAL]
GO
ALTER TABLE [dbo].[PlantillaExp]
	ADD
	CONSTRAINT [DF_PlantillaExp_PXP_SEPARAFECHA]
	DEFAULT ('D') FOR [PXP_SEPARAFECHA]
GO
ALTER TABLE [dbo].[PlantillaExp]
	ADD
	CONSTRAINT [DF_PlantillaExp_PXP_SEPARAHORA]
	DEFAULT ('P') FOR [PXP_SEPARAHORA]
GO
ALTER TABLE [dbo].[PlantillaExp]
	ADD
	CONSTRAINT [DF_PlantillaExp_PXP_TEXTQUAL]
	DEFAULT ('N') FOR [PXP_TEXTQUAL]
GO
ALTER TABLE [dbo].[PlantillaExp]
	ADD
	CONSTRAINT [DF_PlantillaExp_PXP_TITULOS]
	DEFAULT ('N') FOR [PXP_TITULOS]
GO
ALTER TABLE [dbo].[PlantillaExp]
	ADD
	CONSTRAINT [DF_PlantillaExp_PXP_TRANSKEYS]
	DEFAULT ('S') FOR [PXP_TRANSKEYS]
GO
