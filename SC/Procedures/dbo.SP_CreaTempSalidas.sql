SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_CreaTempSalidas]   as

		exec sp_droptable 'TempSalidas'
	CREATE TABLE [dbo].[TempSalidas] (
		[Codigo] [int] IDENTITY (1, 1) NOT NULL ,
		[NoCatalogo] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Cantidad] decimal(38,6) NULL ,
		[NoOrden] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[FacturaQ2C] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CodeAmaps] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[FechaSalida] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[RS] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[SQ] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[ST] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[C] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Destino] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[CostoStd] decimal(38,6) NULL ,
		[Sistema] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[CostoTotal] decimal(38,6) NULL ,
		[Tipo] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		CONSTRAINT [IX_TempSalidas] UNIQUE  NONCLUSTERED 
		(
			[Codigo]
		) WITH  FILLFACTOR = 90  ON [PRIMARY] 
	) ON [PRIMARY]


	exec sp_droptable 'TempTotSalidasNac'
	CREATE TABLE [dbo].[TempTotSalidasNac] (
		[Codigo] [int] IDENTITY (1, 1) NOT NULL ,
		[NoCatalogo] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Cantidad] decimal(38,6) NULL ,
		[NoOrden] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[FacturaQ2C] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CodeAmaps] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[FechaSalida] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[RS] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[SQ] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[ST] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[C] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Destino] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[CostoStd] decimal(38,6) NULL ,
		[Sistema] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[CostoTotal] decimal(38,6) NULL ,
		[Tipo] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		CONSTRAINT [IX_TempTotSalidasNac] UNIQUE  NONCLUSTERED 
		(
			[Codigo]
		) WITH  FILLFACTOR = 90  ON [PRIMARY] 
	) ON [PRIMARY]


	exec sp_droptable 'TempTotSalidasExp'
	CREATE TABLE [dbo].[TempTotSalidasExp] (
		[Codigo] [int] IDENTITY (1, 1) NOT NULL ,
		[NoCatalogo] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Cantidad] decimal(38,6) NULL ,
		[NoOrden] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[FacturaQ2C] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CodeAmaps] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[FechaSalida] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[RS] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[SQ] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[ST] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[C] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Destino] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[CostoStd] decimal(38,6) NULL ,
		[Sistema] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[CostoTotal] decimal(38,6) NULL ,
		[Tipo] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		CONSTRAINT [IX_TempTotSalidasExp] UNIQUE  NONCLUSTERED 
		(
			[Codigo]
		) WITH  FILLFACTOR = 90  ON [PRIMARY] 
	) ON [PRIMARY]



GO
