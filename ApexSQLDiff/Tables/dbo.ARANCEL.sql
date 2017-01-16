SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ARANCEL] (
		[AR_CODIGO]            [int] NOT NULL,
		[AR_FRACCION]          [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[AR_DIGITO]            [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[AR_OFICIAL]           [varchar](1500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[AR_USO]               [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CS_CODIGO]            [smallint] NULL,
		[AR_TIPO]              [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[AR_TIPOREG]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[AR_LN_DESC]           [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[RA_CODIGO]            [int] NULL,
		[PA_CODIGO]            [int] NOT NULL,
		[ME_CODIGO]            [int] NOT NULL,
		[ME_CODIGO2]           [int] NULL,
		[VI_CODIGO]            [smallint] NULL,
		[TV_CODIGO]            [smallint] NULL,
		[AR_ESTADO]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[AR_FEC_REV]           [datetime] NULL,
		[AR_PERINI]            [datetime] NOT NULL,
		[AR_PERFIN]            [datetime] NOT NULL,
		[AR_OBSERVA]           [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PG_ADV]               [smallint] NULL,
		[PG_BEN]               [smallint] NULL,
		[PG_CUOTA]             [smallint] NULL,
		[PG_IVA]               [smallint] NULL,
		[PG_IEPS]              [smallint] NULL,
		[PG_ISAN]              [smallint] NULL,
		[AR_TIPOIMPUESTO]      [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[AR_CANTUMESP]         [decimal](38, 6) NULL,
		[AR_ESPEC]             [decimal](38, 6) NULL,
		[AR_PORCENT_8VA]       [decimal](38, 6) NOT NULL,
		[AR_ADVDEF]            [decimal](38, 6) NOT NULL,
		[AR_CUOTA]             [decimal](38, 6) NULL,
		[AR_IVA]               [decimal](38, 6) NOT NULL,
		[AR_IVAFRANJA]         [decimal](38, 6) NOT NULL,
		[AR_IEPS]              [decimal](38, 6) NULL,
		[AR_ISAN]              [decimal](38, 6) NULL,
		[ARR_CODIGO]           [int] NULL,
		[AR_CAPITULO]          [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AR_DESCCAPITULO]      [varchar](1500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AR_PARTIDA]           [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AR_DESCPARTIDA]       [varchar](1500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AR_FECHAREVISION]     [datetime] NOT NULL,
		[AR_OBSOLETA]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[AR_PAGAISAN]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[AR_ULTMODIFTIGIE]     [datetime] NULL,
		[AR_ADVFRONTERA]       [decimal](38, 6) NOT NULL,
		CONSTRAINT [IX_ARANCEL]
		UNIQUE
		NONCLUSTERED
		([AR_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ARANCEL]
	ADD
	CONSTRAINT [PK_ARANCEL]
	PRIMARY KEY
	NONCLUSTERED
	([AR_FRACCION], [AR_TIPO], [PA_CODIGO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[ARANCEL]
	ADD
	CONSTRAINT [DF_ARANCEL_AR_ADVDEF]
	DEFAULT ((-1)) FOR [AR_ADVDEF]
GO
ALTER TABLE [dbo].[ARANCEL]
	ADD
	CONSTRAINT [DF_ARANCEL_AR_ADVFRONTERA]
	DEFAULT ((-1)) FOR [AR_ADVFRONTERA]
GO
ALTER TABLE [dbo].[ARANCEL]
	ADD
	CONSTRAINT [DF_ARANCEL_AR_DIGITO]
	DEFAULT ('') FOR [AR_DIGITO]
GO
ALTER TABLE [dbo].[ARANCEL]
	ADD
	CONSTRAINT [DF_ARANCEL_AR_ESTADO]
	DEFAULT ('') FOR [AR_ESTADO]
GO
ALTER TABLE [dbo].[ARANCEL]
	ADD
	CONSTRAINT [DF_ARANCEL_AR_FECHAREVISION]
	DEFAULT (convert(varchar(10),getdate(),101)) FOR [AR_FECHAREVISION]
GO
ALTER TABLE [dbo].[ARANCEL]
	ADD
	CONSTRAINT [DF_ARANCEL_AR_IVA]
	DEFAULT ((-1)) FOR [AR_IVA]
GO
ALTER TABLE [dbo].[ARANCEL]
	ADD
	CONSTRAINT [DF_ARANCEL_AR_IVAFRANJA]
	DEFAULT ((-1)) FOR [AR_IVAFRANJA]
GO
ALTER TABLE [dbo].[ARANCEL]
	ADD
	CONSTRAINT [DF_ARANCEL_AR_LN_DESC]
	DEFAULT ('') FOR [AR_LN_DESC]
GO
ALTER TABLE [dbo].[ARANCEL]
	ADD
	CONSTRAINT [DF_ARANCEL_AR_OBSOLETA]
	DEFAULT ('N') FOR [AR_OBSOLETA]
GO
ALTER TABLE [dbo].[ARANCEL]
	ADD
	CONSTRAINT [DF_ARANCEL_AR_PAGAISAN]
	DEFAULT ('N') FOR [AR_PAGAISAN]
GO
ALTER TABLE [dbo].[ARANCEL]
	ADD
	CONSTRAINT [DF_ARANCEL_AR_PERFIN]
	DEFAULT ('1/1/9999') FOR [AR_PERFIN]
GO
ALTER TABLE [dbo].[ARANCEL]
	ADD
	CONSTRAINT [DF_ARANCEL_AR_PERINI]
	DEFAULT ('1/1/1999') FOR [AR_PERINI]
GO
ALTER TABLE [dbo].[ARANCEL]
	ADD
	CONSTRAINT [DF_ARANCEL_AR_PORCENT_8VA]
	DEFAULT ((-1)) FOR [AR_PORCENT_8VA]
GO
ALTER TABLE [dbo].[ARANCEL]
	ADD
	CONSTRAINT [DF_ARANCEL_AR_TIPOIMPUESTO]
	DEFAULT ('A') FOR [AR_TIPOIMPUESTO]
GO
ALTER TABLE [dbo].[ARANCEL]
	ADD
	CONSTRAINT [DF_ARANCEL_AR_TIPOREG]
	DEFAULT ('F') FOR [AR_TIPOREG]
GO
ALTER TABLE [dbo].[ARANCEL]
	ADD
	CONSTRAINT [DF_ARANCEL_AR_USO]
	DEFAULT ('') FOR [AR_USO]
GO
CREATE CLUSTERED INDEX [IX_ARANCEL_1]
	ON [dbo].[ARANCEL] ([AR_CODIGO], [AR_FRACCION])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[ARANCEL] SET (LOCK_ESCALATION = TABLE)
GO
