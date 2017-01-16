SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[SP_CreaTempMaq100F]   as

		exec sp_droptable 'TempMaq100F'
	CREATE TABLE [dbo].[TempMaq100F] (
		[Codigo] [int] IDENTITY (1, 1) NOT NULL ,
		[NoOrden] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[NoCatalogo] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Descripcion] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Cantidad] decimal(38,6) NULL ,
		[UM] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Localizacion] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[FechaOrdCerrada] [datetime] NULL ,
		[FechaOrdVencimiento] [datetime] NULL ,
		[FechaOrdEntrada] [datetime] NULL ,
		[CostoStd] decimal(38,6) NULL ,
		[FacturaQ2C] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PesoKg] decimal(38,6) NULL ,
		[Sel] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		CONSTRAINT [IX_TempMaq100F] UNIQUE  NONCLUSTERED 
		(
			[Codigo]
		) WITH  FILLFACTOR = 90  ON [PRIMARY] 
	) ON [PRIMARY]


	ALTER TABLE [dbo].[TempMaq100F] ADD 
	CONSTRAINT [DF_TempMaq100F_Sel] DEFAULT ('N') FOR [Sel]

	exec sp_droptable 'TempMaq100FSel'
	CREATE TABLE [dbo].[TempMaq100FSel] (
		[FechaOrdCerrada] [datetime] NULL ,
		[FacturaQ2C] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Localizacion] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Estatus] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Movimiento] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	) ON [PRIMARY]



GO
