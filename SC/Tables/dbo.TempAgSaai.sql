SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TempAgSaai] (
		[Codigo]               [int] IDENTITY(1, 1) NOT NULL,
		[Patente]              [varchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Pedimento]            [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Aduana]               [varchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TOper]                [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CveDocto]             [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[RFC]                  [varchar](13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Contribuyente]        [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FecPagoReal]          [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TipoPed]              [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Fraccion]             [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Sec]                  [int] NULL,
		[Descripcion]          [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PaisOD]               [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PaisCV]               [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ValorAduana]          [decimal](38, 6) NULL,
		[ValorComercial]       [decimal](38, 6) NULL,
		[CantidadUMT]          [decimal](38, 6) NULL,
		[ImporteIVA]           [decimal](38, 6) NULL,
		[FPagoIVA]             [smallint] NULL,
		[ImporteADvalorem]     [decimal](38, 6) NULL,
		[FPagoAdvalorem]       [smallint] NULL,
		[Indicador]            [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Texto]                [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_TempAgSaai]
		UNIQUE
		NONCLUSTERED
		([Codigo])
		ON [PRIMARY]
) ON [PRIMARY]
GO
