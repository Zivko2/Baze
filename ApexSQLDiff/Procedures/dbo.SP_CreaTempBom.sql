SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dbo].[SP_CreaTempBom]   as


		exec sp_droptable 'TempBom'
	CREATE TABLE [dbo].[TempBom] (
		[CODIGO] [int] IDENTITY(1,1) NOT NULL,
		[NOPARTEPADRE] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NOPARTEHIJO] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[INCORPOR] decimal(38,6) NOT NULL CONSTRAINT [DF_TempBom_INCORPOR]  DEFAULT (1),
		[DESP] decimal(38,6) NOT NULL CONSTRAINT [DF_TempBom_DESP]  DEFAULT (0),
		[PERINI] [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PERFIN] [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PAIS] [int] NULL,
		[DISCH] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TempBom_DISCH]  DEFAULT ('S'),
		[SEC] [smallint] NOT NULL CONSTRAINT [DF_TempBom_SEC]  DEFAULT (0),
		[UM] [int] NULL,
		[FACTCONV] decimal(28,14) NOT NULL CONSTRAINT [DF_TempBom_FACTCONV]  DEFAULT (1),
		CONSTRAINT [IX_TempBom] UNIQUE  NONCLUSTERED 
		(
			[Codigo]
		) WITH  FILLFACTOR = 90  ON [PRIMARY] 
	) ON [PRIMARY]


	exec sp_droptable 'TempBomTot'
	CREATE TABLE [dbo].[TempBomTot] (
		[CODIGO] [int] IDENTITY (1, 1) NOT NULL ,
		[FECHA] [datetime] NULL ,
		[NOPARTEPADRE] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[NOPARTEHIJO] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[CANTIDADINTRADE] decimal(38,6)  NULL ,
		[CANTIDADAMAPS] decimal(38,6)  NULL ,
		[DIFERENCIA] decimal(38,6)  NULL ,
		[TEXTO] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		CONSTRAINT [IX_TempBomTot] UNIQUE  NONCLUSTERED 
		(
			[CODIGO]
		) WITH  FILLFACTOR = 90  ON [PRIMARY] 
	) ON [PRIMARY]





GO
