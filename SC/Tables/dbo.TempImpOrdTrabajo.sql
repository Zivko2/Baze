SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TempImpOrdTrabajo] (
		[OT_IDENTITY]        [int] IDENTITY(1, 1) NOT NULL,
		[OT_CODIGO]          [int] NULL,
		[OTD_INDICED]        [int] NULL,
		[BST_PT]             [int] NOT NULL,
		[BST_ENTRAVIGOR]     [datetime] NULL,
		[BST_HIJO]           [int] NOT NULL,
		[BST_INCORPOR]       [decimal](38, 6) NOT NULL,
		[BST_DISCH]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TI_CODIGO]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ME_CODIGO]          [int] NULL,
		[FACTCONV]           [decimal](28, 14) NOT NULL,
		[BST_PERINI]         [datetime] NULL,
		[BST_PERFIN]         [datetime] NULL,
		[ME_GEN]             [int] NULL,
		[BST_TRANS]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[BST_TIPOCOSTO]      [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[BST_DESP]           [decimal](38, 6) NOT NULL,
		[BST_MERMA]          [decimal](38, 6) NOT NULL,
		[MA_TIP_ENS]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OTD_CANT]           [decimal](38, 6) NULL,
		[BST_NIVEL]          [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[BST_TIPODESC]       [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[BST_PERTENECE]      [int] NULL,
		CONSTRAINT [IX_TempImpOrdTrabajo]
		UNIQUE
		NONCLUSTERED
		([OT_IDENTITY])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempImpOrdTrabajo]
	ADD
	CONSTRAINT [DF_TempImpOrdTrabajo_BST_DESP]
	DEFAULT (0) FOR [BST_DESP]
GO
ALTER TABLE [dbo].[TempImpOrdTrabajo]
	ADD
	CONSTRAINT [DF_TempImpOrdTrabajo_BST_DISCH]
	DEFAULT ('S') FOR [BST_DISCH]
GO
ALTER TABLE [dbo].[TempImpOrdTrabajo]
	ADD
	CONSTRAINT [DF_TempImpOrdTrabajo_BST_INCORPOR]
	DEFAULT (1) FOR [BST_INCORPOR]
GO
ALTER TABLE [dbo].[TempImpOrdTrabajo]
	ADD
	CONSTRAINT [DF_TempImpOrdTrabajo_BST_MERMA]
	DEFAULT (0) FOR [BST_MERMA]
GO
ALTER TABLE [dbo].[TempImpOrdTrabajo]
	ADD
	CONSTRAINT [DF_TempImpOrdTrabajo_BST_PERFIN]
	DEFAULT ('01/01/9999') FOR [BST_PERFIN]
GO
ALTER TABLE [dbo].[TempImpOrdTrabajo]
	ADD
	CONSTRAINT [DF_TempImpOrdTrabajo_BST_TRANS]
	DEFAULT ('N') FOR [BST_TRANS]
GO
ALTER TABLE [dbo].[TempImpOrdTrabajo]
	ADD
	CONSTRAINT [DF_TempImpOrdTrabajo_FACTCONV]
	DEFAULT (1) FOR [FACTCONV]
GO
