SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FACTCONS] (
		[FC_CODIGO]                [int] NOT NULL,
		[FC_FOLIO]                 [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FC_TIPO]                  [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CP_CODIGO]                [smallint] NOT NULL,
		[FC_SEM]                   [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FC_INI]                   [datetime] NOT NULL,
		[FC_FIN]                   [datetime] NOT NULL,
		[FC_ACUSEDERECIBO]         [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AGT_CODIGO]               [smallint] NOT NULL,
		[FC_FECHA]                 [datetime] NULL,
		[FC_CONSOLIDA]             [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FC_DTA1_CANT]             [decimal](38, 6) NULL,
		[FC_ADV_CANT]              [decimal](38, 6) NULL,
		[FC_TIP_CAM]               [decimal](38, 6) NULL,
		[FC_TOTAL]                 [decimal](38, 6) NULL,
		[AD_DES]                   [smallint] NOT NULL,
		[REG_CODIGO]               [smallint] NULL,
		[CL_CODIGO]                [int] NOT NULL,
		[US_CODIGO]                [smallint] NULL,
		[FC_IVA]                   [decimal](38, 6) NULL,
		[FC_ESTATUS]               [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ZO_CODIGO]                [int] NULL,
		[AGM_CODIGO]               [int] NULL,
		[FC_FIRMAELECTAVANZ]       [varchar](300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FC_CONSECUTIVOREMESA]     [int] NULL,
		[FC_FECHALIMCERRAR]        [datetime] NULL,
		[FC_FOLIOCL]               [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FC_PATENTECL]             [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AD_DESCL]                 [smallint] NULL,
		[PR_CODIGO]                [int] NULL,
		[FC_FEACODBARRAS]          [varchar](300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_FACTCONS]
		UNIQUE
		NONCLUSTERED
		([FC_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FACTCONS]
	ADD
	CONSTRAINT [PK_FACTCONS]
	PRIMARY KEY
	CLUSTERED
	([FC_FOLIO], [AGT_CODIGO], [AD_DES])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[FACTCONS]
	ADD
	CONSTRAINT [DF_FACTCONS_CL_CODIGO]
	DEFAULT (1) FOR [CL_CODIGO]
GO
ALTER TABLE [dbo].[FACTCONS]
	ADD
	CONSTRAINT [DF_FACTCONS_FC_CONSOLIDA]
	DEFAULT ('S') FOR [FC_CONSOLIDA]
GO
ALTER TABLE [dbo].[FACTCONS]
	ADD
	CONSTRAINT [DF_FACTCONS_FC_ESTATUS]
	DEFAULT ('A') FOR [FC_ESTATUS]
GO
ALTER TABLE [dbo].[FACTCONS]
	ADD
	CONSTRAINT [DF_FACTCONS_FC_FIN]
	DEFAULT ('01/01/2001') FOR [FC_FIN]
GO
ALTER TABLE [dbo].[FACTCONS]
	ADD
	CONSTRAINT [DF_FACTCONS_FC_INI]
	DEFAULT ('01/01/2001') FOR [FC_INI]
GO
