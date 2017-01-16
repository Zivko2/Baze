SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_CreaTempAgSaai]   as

		-- tabla que se queda con la informacion
	  if not exists (select * from .sysobjects where id = object_id('[GLOSASAAI]') and OBJECTPROPERTY(id, 'IsTable') = 1)    
	CREATE TABLE [dbo].[GLOSASAAI] (
		[Codigo] [int] IDENTITY (1, 1) NOT NULL ,
		[Patente] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Pedimento] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Aduana] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[TOper] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[CveDocto] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[RFC] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Contribuyente] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[FecPagoReal] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[TipoPed] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[TipoCambio] decimal(38,6) NULL ,
		[Fraccion] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Descripcion] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Sec] [Int] NULL ,
		[PaisOD] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[PaisCV] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[ValorAduana] decimal(38,6) NULL ,
		[ValorComercial] decimal(38,6) NULL ,
		[CantidadUMT] decimal(38,6) NULL ,
		[ImporteIVA] decimal(38,6)  NULL ,
		[FPagoIVA] [smallint]  NULL ,
		[ImporteADvalorem] decimal(38,6)  NULL ,
		[FPagoAdvalorem] [smallint]  NULL ,
		[TipoTasa] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Tratado] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Sector] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[ComplST] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[ComplDT] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Indicador] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Texto] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		CONSTRAINT [IX_GlosaSAAI] UNIQUE  NONCLUSTERED 
		(
			[Codigo]
		) WITH  FILLFACTOR = 90  ON [PRIMARY] 
	) ON [PRIMARY]



	-- original del archivo excel (worksheet 1)
	exec sp_droptable 'TempAgSaai'
	CREATE TABLE [dbo].[TempAgSaai] (
		[Codigo] [int] IDENTITY (1, 1) NOT NULL ,
		[Patente] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Pedimento] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Aduana] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[TOper] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[CveDocto] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[RFC] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Contribuyente] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[FecPagoReal] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[TipoPed] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Fraccion] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Sec] [Int] NULL ,
		[Descripcion] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[PaisOD] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[PaisCV] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[ValorAduana] decimal(38,6) NULL ,
		[ValorComercial] decimal(38,6) NULL ,
		[CantidadUMT] decimal(38,6) NULL ,
		[ImporteIVA] decimal(38,6)  NULL ,
		[FPagoIVA] [smallint]  NULL ,
		[ImporteADvalorem] decimal(38,6)  NULL ,
		[FPagoAdvalorem] [smallint]  NULL ,
		[Indicador] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Texto] [varchar] (100) NULL ,
		CONSTRAINT [IX_TempAgSaai] UNIQUE  NONCLUSTERED 
		(
			[Codigo]
		) WITH  FILLFACTOR = 90  ON [PRIMARY] 
	) ON [PRIMARY]


	-- original del archivo excel (worksheet 2)
	exec sp_droptable 'TempAgSaaiContrib'
	CREATE TABLE [dbo].[TempAgSaaiContrib] (
		[Patente] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Pedimento] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Aduana] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Fraccion] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,		[Sec] [Int] NULL ,
		[Contribucion] [smallint]  NULL ,
		[FPago] [smallint]  NULL ,
		[Importe] decimal(38,6)  NULL ) ON [PRIMARY]


	-- se llena para la comparacion, con info de la glosa y de intrade, ya agrupados por Patente, Aduana, pedimento, pais y fraccion
	exec sp_droptable 'TempAgTotSaai'
	CREATE TABLE [dbo].[TempAgTotSaai] (
		[Codigo] [int] IDENTITY (1, 1) NOT NULL ,
		[Aduana] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Patente] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Pedimento] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[TOper] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[CveDocto] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[FecPagoReal] [varchar] (25) NULL ,
		[TipoPed] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Fraccion] [varchar] (8) NULL ,
		[Sec] [Int] NULL ,
		[PaisOD] [varchar] (5) NULL ,
		[PaisCV] [varchar] (5) NULL ,
		[ValorAduana] decimal(38,6) NULL ,
		[ValorComercial] decimal(38,6) NULL ,
		[CantidadUMT] decimal(38,6) NULL ,
		[ImporteIVA] decimal(38,6)  NULL ,
		[FPagoIVA] [smallint]  NULL ,
		[ImporteADvalorem] decimal(38,6)  NULL ,
		[FPagoAdvalorem] [smallint]  NULL ,
		[Pib_indiceb] [int] NULL ,
		[Indicador] [varchar] (3) NULL ,
		[Texto] [varchar] (100) NULL ,
		[CuadraPartida] [char] (1) NULL CONSTRAINT [DF_TempAgTotSaai_CuadraPartida] DEFAULT ('N'),
		CONSTRAINT [IX_TempAgTotSaai] UNIQUE  NONCLUSTERED 
		(
			[Codigo]
		) WITH  FILLFACTOR = 90  ON [PRIMARY] 
	) ON [PRIMARY]




	if not exists (SELECT dbo.sysobjects.name FROM dbo.sysobjects 
	WHERE     (dbo.sysobjects.name = N'TempAgSaaiExclPed'))
		--exec sp_droptable 'TempAgSaaiExclPed'

	CREATE TABLE [dbo].[TempAgSaaiExclPed] (
		[Codigo] [int] IDENTITY (1, 1) NOT NULL ,
		[Pedimento] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[PedimentoObserva] [varchar] (1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		CONSTRAINT [IX_TempAgSaaiExclPed] UNIQUE  NONCLUSTERED 
		(
			[Codigo]
		) WITH  FILLFACTOR = 90  ON [PRIMARY] 
	) ON [PRIMARY]
GO
