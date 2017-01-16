SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_CreaTempCertOrigen]   as

		exec sp_droptable 'TempCertOrigen'
	CREATE TABLE [dbo].[TempCertOrigen] (
		[Codigo] [int] IDENTITY (1, 1) NOT NULL ,
		[NoCatalogo] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Descripcion] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[USTariff] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[MexicoTariff] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[CanadaTariff] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[PrefCriterion] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Producer] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[NETCost] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[CountryOrigin] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Location] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[BlanketPeriod] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[DateComplete] [varchar] (10) NULL ,
		[Suppliername] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[PrefCriterionInTrade] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[ProducerInTrade] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[NETCostInTrade] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[SuppliernameInTrade] [int] NULL ,
		CONSTRAINT [IX_TempCertOrigen] UNIQUE  NONCLUSTERED 
		(
			[Codigo]
		) WITH  FILLFACTOR = 90  ON [PRIMARY] 
	) ON [PRIMARY]


GO
