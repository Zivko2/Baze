SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RelacionBOM] (
		[BSU_NOPARTE]      [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TipoSug]          [float] NULL,
		[BST_NOPARTE]      [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TipoSugerido]     [float] NULL
) ON [PRIMARY]
GO
