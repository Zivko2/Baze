SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ActGrupos$] (
		[NoParte]         [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Grupo]           [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CodigoGrupo]     [float] NULL,
		[UMGen]           [float] NULL,
		[UMParte]         [float] NULL,
		[FC]              [float] NULL
) ON [PRIMARY]
GO
