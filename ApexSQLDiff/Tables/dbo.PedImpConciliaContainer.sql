SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PedImpConciliaContainer] (
		[Pedimento]          [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NoContenedor]       [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TipoContenedor]     [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PI_CODIGO]          [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PedImpConciliaContainer] SET (LOCK_ESCALATION = TABLE)
GO
