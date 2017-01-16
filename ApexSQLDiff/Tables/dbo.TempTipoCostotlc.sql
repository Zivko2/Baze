SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TempTipoCostotlc] (
		[BST_CODIGO]        [int] NOT NULL,
		[esGravable]        [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[esAnadido]         [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[esMP]              [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[esSUB]             [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[bst_tipocosto]     [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempTipoCostotlc] SET (LOCK_ESCALATION = TABLE)
GO
