SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_CreaTempSalidasPO]   as

		exec sp_droptable 'TempSalidasPO'
	CREATE TABLE [dbo].[TempSalidasPO] (
		[CODE] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[UPDDT] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[ORDNO] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[VNDNR] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[REFNO] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[RS] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[ITNBR] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[ITDSC] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[PRODLN] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[M] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[PR] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[ST] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[CONVFACT] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[SQ] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[RQ] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[TQTY] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[TOTAL_MATL] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[TOTAL_ITP_VAR] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[TOTAL_ITP_BASE] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[TOTAL_MARKUP] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[TOTAL_FREIGHT] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[TOTAL_OUTSIDE] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[TOTAL_LABOR] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[TOTAL_VAR] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[TOTAL_FIX] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[TOTAL_EXT_COSTS] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[MATL] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[ITP_VAR] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[ITP_BASE] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[MARKUP] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[FREIGHT] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[OUTSIDE] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[LABOR] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[VARIABLE] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[FIXED] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[TOTAL_COSTS] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[C] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[PURCHASE_PRICE] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Field39] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
	) ON [PRIMARY]



	exec sp_droptable 'TempTotSalidasPOStock'
	CREATE TABLE [dbo].[TempTotSalidasPOStock] (
		[Codigo] [int] IDENTITY (1, 1) NOT NULL ,
		[Factura] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TipoFactura] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[FechaEntrada] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[PlacasContenedor] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NoParte] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Cantidad] decimal(38,6) NULL ,
		[NoOrden] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Sistema] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		CONSTRAINT [IX_TempTotSalidasPOStock] UNIQUE  NONCLUSTERED 
		(
			[Codigo]
		) WITH  FILLFACTOR = 90  ON [PRIMARY] 
	) ON [PRIMARY]


	exec sp_droptable 'TempTotSalidasPONonStock'
	CREATE TABLE [dbo].[TempTotSalidasPONonStock] (
		[Codigo] [int] IDENTITY (1, 1) NOT NULL ,
		[Factura] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TipoFactura] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[FechaEntrada] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[PlacasContenedor] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NoParte] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Cantidad] decimal(38,6) NULL ,
		[NoOrden] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Sistema] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		CONSTRAINT [IX_TTempTotSalidasPONonStock] UNIQUE  NONCLUSTERED 
		(
			[Codigo]
		) WITH  FILLFACTOR = 90  ON [PRIMARY] 
	) ON [PRIMARY]


	if not exists (SELECT dbo.syscolumns.name FROM dbo.syscolumns INNER JOIN
	                      dbo.sysobjects ON dbo.syscolumns.id = dbo.sysobjects.id
	WHERE     (dbo.sysobjects.name = N'TempTotSalidasPOExclFact') AND (dbo.syscolumns.name = N'FacturaObserva'))
		exec sp_droptable 'TempTotSalidasPOExclFact'


	if not exists (SELECT dbo.syscolumns.name FROM dbo.syscolumns INNER JOIN
	                      dbo.sysobjects ON dbo.syscolumns.id = dbo.sysobjects.id
	WHERE     (dbo.sysobjects.name = N'TempTotSalidasPOExclFact') AND (dbo.syscolumns.name = N'FacturaObserva'))
	CREATE TABLE [dbo].[TempTotSalidasPOExclFact] (
		[Codigo] [int] IDENTITY (1, 1) NOT NULL ,
		[Factura] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[FacturaObserva] [varchar] (1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		CONSTRAINT [IX_TempTotSalidasPOExclFact] UNIQUE  NONCLUSTERED 
		(
			[Codigo]
		) WITH  FILLFACTOR = 90  ON [PRIMARY] 
	) ON [PRIMARY]



	if not exists (SELECT dbo.syscolumns.name FROM dbo.syscolumns INNER JOIN
	                      dbo.sysobjects ON dbo.syscolumns.id = dbo.sysobjects.id
	WHERE     (dbo.sysobjects.name = N'TempTotSalidasPOInclFact') AND (dbo.syscolumns.name = N'FacturaObserva'))
		exec sp_droptable 'TempTotSalidasPOInclFact'


	if not exists (SELECT dbo.syscolumns.name FROM dbo.syscolumns INNER JOIN
	                      dbo.sysobjects ON dbo.syscolumns.id = dbo.sysobjects.id
	WHERE     (dbo.sysobjects.name = N'TempTotSalidasPOInclFact') AND (dbo.syscolumns.name = N'FacturaObserva'))
	CREATE TABLE [dbo].[TempTotSalidasPOInclFact] (
		[Codigo] [int] IDENTITY (1, 1) NOT NULL ,
		[Factura] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[FacturaObserva] [varchar] (1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		CONSTRAINT [IX_TempTotSalidasPOInclFact] UNIQUE  NONCLUSTERED 
		(
			[Codigo]
		) WITH  FILLFACTOR = 90  ON [PRIMARY] 
	) ON [PRIMARY]


GO
