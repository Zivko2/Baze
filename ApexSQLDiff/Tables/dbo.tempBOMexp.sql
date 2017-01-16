SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[tempBOMexp] (
		[Bsu_subensamble]     [int] NULL,
		[bst_hijo]            [int] NULL,
		[BST_PERINI]          [datetime] NULL,
		[BST_PERFIN]          [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tempBOMexp] SET (LOCK_ESCALATION = TABLE)
GO
