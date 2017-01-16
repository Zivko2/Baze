SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_CreaTablaTempBOM_NIVEL]   as

exec sp_droptable 'TempBOM_NIVEL'
CREATE TABLE [dbo].[TempBOM_NIVEL] (
	[BST_PT] [int]  NOT NULL ,
	[BST_PERTENECE] [int] NOT NULL ,
	[BST_HIJO] [int] NULL ,
	[BST_NIVEL] [int] NULL ,
	[BST_PERINI] [datetime] NULL,
	[BST_INCORPOR] decimal(38,6) NULL,
	[BST_INCORPORUSO] decimal(38,6) NULL
) ON [PRIMARY]



GO
