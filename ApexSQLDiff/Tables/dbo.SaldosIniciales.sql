SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SaldosIniciales] (
		[Patente]           [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Folio]             [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Clave]             [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FolioOriginl]      [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ClaveOriginal]     [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AnoEntrada]        [int] NULL,
		[FechaEntrada]      [datetime] NULL,
		[AnoPago]           [int] NULL,
		[FechaPago]         [datetime] NULL,
		[NoParte]           [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Fraccion]          [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FCUMT]             [decimal](28, 14) NULL,
		[CantidadGen]       [decimal](38, 6) NULL,
		[CantUMT]           [decimal](38, 6) NULL,
		[ValorDlls]         [decimal](38, 6) NULL,
		[Saldo]             [decimal](38, 6) NULL,
		[ValorSaldo]        [decimal](38, 6) NULL,
		[PesoTotalKg]       [decimal](38, 6) NULL,
		[PesoUniKG]         [decimal](38, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SaldosIniciales] SET (LOCK_ESCALATION = TABLE)
GO
