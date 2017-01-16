SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Bom_StructBkp] (
		[BST_CODIGO]          [int] IDENTITY(1, 1) NOT NULL,
		[BSU_SUBENSAMBLE]     [int] NOT NULL,
		[BST_HIJO]            [int] NOT NULL,
		[BST_INCORPOR]        [decimal](38, 6) NOT NULL,
		[BST_DISCH]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TI_CODIGO]           [smallint] NULL,
		[ME_CODIGO]           [int] NULL,
		[FACTCONV]            [decimal](28, 14) NOT NULL,
		[BST_PERINI]          [datetime] NOT NULL,
		[BST_PERFIN]          [datetime] NOT NULL,
		[ME_GEN]              [int] NULL,
		[BST_TRANS]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[BST_TIPOCOSTO]       [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[BST_DESP]            [decimal](38, 6) NOT NULL,
		[BST_MERMA]           [decimal](38, 6) NOT NULL,
		[BSU_NOPARTE]         [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[BST_NOPARTE]         [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PA_CODIGO]           [int] NULL,
		[BSU_NOPARTEAUX]      [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[BST_NOPARTEAUX]      [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[BST_TIP_ENS]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[BST_PESO_KG]         [decimal](38, 6) NULL,
		[AR_CODIGO]           [int] NULL,
		[FACTCONVALM]         [decimal](28, 14) NULL,
		[ME_ALM]              [int] NULL,
		[BST_SEC]             [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Bom_StructBkp] SET (LOCK_ESCALATION = TABLE)
GO
