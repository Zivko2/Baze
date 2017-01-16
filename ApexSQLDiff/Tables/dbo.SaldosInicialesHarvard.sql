SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SaldosInicialesHarvard] (
		[REF]               [varchar](55) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Patente]           [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Folio]             [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Clave]             [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FolioOriginl]      [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ClaveOriginal]     [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NoParte]           [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FCUMT]             [decimal](28, 14) NULL,
		[Saldo]             [decimal](38, 6) NULL,
		[PesoUniKG]         [decimal](38, 6) NULL,
		[COSTUNI]           [decimal](38, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SaldosInicialesHarvard] SET (LOCK_ESCALATION = TABLE)
GO
