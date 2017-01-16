SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[dESCSINDESC] (
		[FED_INDICED]     [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Factura]         [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Fecha]           [datetime] NULL,
		[FED_NOMBRE]      [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NoParte]         [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ Grupo]          [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ TipoMat]        [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ Cantidad]       [float] NULL,
		[ ValorDlls]      [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dESCSINDESC] SET (LOCK_ESCALATION = TABLE)
GO
