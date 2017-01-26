SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TempAgTotSaai] (
		[Codigo]               [int] IDENTITY(1, 1) NOT NULL,
		[Aduana]               [varchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Patente]              [varchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Pedimento]            [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TOper]                [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CveDocto]             [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FecPagoReal]          [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TipoPed]              [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Fraccion]             [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Sec]                  [int] NULL,
		[PaisOD]               [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PaisCV]               [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ValorAduana]          [decimal](38, 6) NULL,
		[ValorComercial]       [decimal](38, 6) NULL,
		[CantidadUMT]          [decimal](38, 6) NULL,
		[ImporteIVA]           [decimal](38, 6) NULL,
		[FPagoIVA]             [smallint] NULL,
		[ImporteADvalorem]     [decimal](38, 6) NULL,
		[FPagoAdvalorem]       [smallint] NULL,
		[Pib_indiceb]          [int] NULL,
		[Indicador]            [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Texto]                [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CuadraPartida]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_TempAgTotSaai]
		UNIQUE
		NONCLUSTERED
		([Codigo])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempAgTotSaai]
	ADD
	CONSTRAINT [DF_TempAgTotSaai_CuadraPartida]
	DEFAULT ('N') FOR [CuadraPartida]
GO
