SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AnalisisTipoMat] (
		[Padre]         [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TipoPadre]     [int] NOT NULL,
		[Hijo]          [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TipoHijo]      [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AnalisisTipoMat] SET (LOCK_ESCALATION = TABLE)
GO
