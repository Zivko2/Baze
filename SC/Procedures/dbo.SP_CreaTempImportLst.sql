SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO















CREATE PROCEDURE [dbo].[SP_CreaTempImportLst]   as

		exec sp_droptable 'TempImportLst'


	CREATE TABLE [dbo].[TempImportLst](
		[Codigo] [int] IDENTITY(1,1) NOT NULL,
		[Folio] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Fecha] [datetime] NULL,
		[NoParte] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Cantidad] decimal(38,6) NULL,
		[TipoMcia] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CostoUnitUSD] decimal(38,6) NULL,
		[PesoLb] decimal(38,6) NULL,
		[PesoTotalLbs] decimal(38,6) NULL,
		[TipoImportacion] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CantBultos] [smallint] NULL,
		[TipoEmpaque] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[BalanceEmpaque] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ConsecutivoBalance] [varchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Proveedor] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Pais] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Observaciones] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Sel] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	 CONSTRAINT [IX_TempImportLst] UNIQUE NONCLUSTERED 
	(
		[Codigo] ASC
	) ON [PRIMARY]
	) ON [PRIMARY]



	ALTER TABLE [dbo].[TempImportLst] ADD 
	CONSTRAINT [DF_TempImportLst_Sel] DEFAULT ('N') FOR [Sel]

	exec sp_droptable 'TempImportLstSel'
	CREATE TABLE [dbo].[TempImportLstSel] (
		[Fecha] [datetime] NULL ,
		[Folio] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Estatus] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Movimiento] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	) ON [PRIMARY]



GO
