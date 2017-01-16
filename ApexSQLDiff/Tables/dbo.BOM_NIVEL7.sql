SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[BOM_NIVEL7] (
		[BST_PT]              [int] NOT NULL,
		[BST_PERTENECE]       [int] NOT NULL,
		[BST_HIJO]            [int] NULL,
		[BST_NIVEL]           [int] NULL,
		[BST_PERINI]          [datetime] NULL,
		[BST_INCORPOR]        [float] NULL,
		[BST_INCORPORUSO]     [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BOM_NIVEL7] SET (LOCK_ESCALATION = TABLE)
GO
