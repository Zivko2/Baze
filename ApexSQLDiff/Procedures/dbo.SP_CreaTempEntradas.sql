SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_CreaTempEntradas]   as

		exec sp_droptable 'TempEntradas'
	CREATE TABLE [dbo].[TempEntradas] (
		[Codigo] [int] IDENTITY (1, 1) NOT NULL ,
		[NoCatalogo] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Cantidad] decimal(38,6) NULL ,
		[NoOrden] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Factura] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FechaEntrada] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[CodeAmaps] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Vendor] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[RP] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[RQ] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[PrecioOrden] decimal(38,6) NULL ,
		[CostoStd] decimal(38,6) NULL ,
		[Sistema] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[CostoTotal] decimal(38,6) NULL ,
		[Tipo] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		CONSTRAINT [IX_TempEntradas] UNIQUE  NONCLUSTERED 
		(
			[Codigo]
		) WITH  FILLFACTOR = 90  ON [PRIMARY] 
	) ON [PRIMARY]


	exec sp_droptable 'TempTotEntradasNac'
	CREATE TABLE [dbo].[TempTotEntradasNac] (
		[Codigo] [int] IDENTITY (1, 1) NOT NULL ,
		[NoCatalogo] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Cantidad] decimal(38,6) NULL ,
		[NoOrden] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Factura] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FechaEntrada] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[CodeAmaps] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Vendor] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[RP] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[RQ] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[PrecioOrden] decimal(38,6) NULL ,
		[CostoStd] decimal(38,6) NULL ,
		[Sistema] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[CostoTotal] decimal(38,6) NULL ,
		[Tipo] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		CONSTRAINT [IX_TempTotEntradasNac] UNIQUE  NONCLUSTERED 
		(
			[Codigo]
		) WITH  FILLFACTOR = 90  ON [PRIMARY] 
	) ON [PRIMARY]


	exec sp_droptable 'TempTotEntradasImp'
	CREATE TABLE [dbo].[TempTotEntradasImp] (
		[Codigo] [int] IDENTITY (1, 1) NOT NULL ,
		[NoCatalogo] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Cantidad] decimal(38,6) NULL ,
		[NoOrden] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Factura] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FechaEntrada] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[CodeAmaps] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Vendor] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[RP] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[RQ] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[PrecioOrden] decimal(38,6) NULL ,
		[CostoStd] decimal(38,6) NULL ,
		[Sistema] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[CostoTotal] decimal(38,6) NULL ,
		[Tipo] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		CONSTRAINT [IX_TempTotEntradasImp] UNIQUE  NONCLUSTERED 
		(
			[Codigo]
		) WITH  FILLFACTOR = 90  ON [PRIMARY] 
	) ON [PRIMARY]



GO
