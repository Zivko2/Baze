SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_CreaTempAgencia]   as

		exec sp_droptable 'TempAgencia'
	CREATE TABLE [dbo].[TempAgencia] (
		[Codigo] [int] IDENTITY (1, 1) NOT NULL ,
		[NoCatalogo] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Fraccion] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Descripcion] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[PesoLbs] decimal(38,6) NULL ,
		[UMAlm] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Nafta] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		CONSTRAINT [IX_TempAgencia] UNIQUE  NONCLUSTERED 
		(
			[Codigo]
		) WITH  FILLFACTOR = 90  ON [PRIMARY] 
	) ON [PRIMARY]


	exec sp_droptable 'TempTotAgencia'
	CREATE TABLE [dbo].[TempTotAgencia] (
		[Codigo] [int] IDENTITY (1, 1) NOT NULL ,
		[NoCatalogo] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Fraccion] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Descripcion] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[PesoLbs] decimal(38,6) NULL ,
		[UMAlm] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Nafta] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[NoParteInTrade] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[FraccionInTrade] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[DescripcionInTrade] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[PesoLbsInTrade] decimal(38,6) NULL ,
		[UMAlmInTrade] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[NaftaInTrade] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Tipo] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,  -- SOLO EN INTRADE, EN AMBOS, SOLO EN AGENCIA
		[IgualFraccion] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[IgualDescripcion] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[IgualPesoLbs] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[IgualUMAlm] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[IgualNafta] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		CONSTRAINT [IX_TempTotAgencia] UNIQUE  NONCLUSTERED 
		(
			[Codigo]
		) WITH  FILLFACTOR = 90  ON [PRIMARY] 
	) ON [PRIMARY]











GO
