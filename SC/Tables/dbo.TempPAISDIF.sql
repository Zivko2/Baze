SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TempPAISDIF] (
		[BST_TRANS]      [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[bst_codigo]     [int] NOT NULL,
		[pa_codigo]      [int] NOT NULL
) ON [PRIMARY]
GO
