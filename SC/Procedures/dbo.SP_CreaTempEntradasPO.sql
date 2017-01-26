SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_CreaTempEntradasPO]   as

		exec sp_droptable 'TempEntradasPO'
	CREATE TABLE [dbo].[TempEntradasPO] (
		[Codigo] [int] IDENTITY (1, 1) NOT NULL ,
		[VENDOR] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[PO_NBR] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[ITEM_NUMBER] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[ITEM_DESCRIPTION] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[INV_ACCT] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[PLACE_DATE] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[DOCK_DATE] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[RCPT_DATE] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[DUE_DATE] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[REQ_QUANTITY] decimal(38,6) NULL ,
		[RECEIPT_QUANTITY] decimal(38,6) NULL ,
		[OUTSTANDING_QTY] decimal(38,6) NULL ,
		[DOCUMENT_NBR] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[VENDOR_NAME] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[UM] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[STD_COST] decimal(38,6) NULL ,
		[LAST_COST] decimal(38,6) NULL ,
		[EXT_COST] decimal(38,6) NULL ,
		[BYCOL] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,

		CONSTRAINT [IX_TempEntradasPO] UNIQUE  NONCLUSTERED 
		(
			[Codigo]
		) WITH  FILLFACTOR = 90  ON [PRIMARY] 
	) ON [PRIMARY]


	exec sp_droptable 'TempTotEntradasPO'
	CREATE TABLE [dbo].[TempTotEntradasPO] (
		[Codigo] [int] IDENTITY (1, 1) NOT NULL ,
		[Factura] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TipoFactura] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[FechaEntrada] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[NoParte] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Cantidad] decimal(38,6) NULL ,
		[NoOrdenCompra] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Sistema] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		CONSTRAINT [IX_TempTotEntradasPO] UNIQUE  NONCLUSTERED 
		(
			[Codigo]
		) WITH  FILLFACTOR = 90  ON [PRIMARY] 
	) ON [PRIMARY]



	if not exists (SELECT dbo.sysobjects.name FROM dbo.sysobjects 
	WHERE     (dbo.sysobjects.name = N'TempTotEntradasPOExclFact'))
	CREATE TABLE [dbo].[TempTotEntradasPOExclFact] (
		[Codigo] [int] IDENTITY (1, 1) NOT NULL ,
		[Factura] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[FacturaObserva] [varchar] (1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		CONSTRAINT [IX_TempTotEntradasPOExclFact] UNIQUE  NONCLUSTERED 
		(
			[Codigo]
		) WITH  FILLFACTOR = 90  ON [PRIMARY] 
	) ON [PRIMARY]



	if not exists (SELECT dbo.sysobjects.name FROM dbo.sysobjects
	WHERE     (dbo.sysobjects.name = N'TempTotEntradasPOInclFact'))
	CREATE TABLE [dbo].[TempTotEntradasPOInclFact] (
		[Codigo] [int] IDENTITY (1, 1) NOT NULL ,
		[Factura] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[FacturaObserva] [varchar] (1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		CONSTRAINT [IX_TempTotEntradasPOInclFact] UNIQUE  NONCLUSTERED 
		(
			[Codigo]
		) WITH  FILLFACTOR = 90  ON [PRIMARY] 
	) ON [PRIMARY]


GO
