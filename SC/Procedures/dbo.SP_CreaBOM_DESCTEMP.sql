SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_CreaBOM_DESCTEMP]   as

	
		if not exists (select * from dbo.sysobjects where name='BOM_DESCTEMP')
	begin
		CREATE TABLE [dbo].[BOM_DESCTEMP] (
			[CONSECUTIVO] [int] IDENTITY (1, 1) NOT NULL ,
			[FE_CODIGO] [int] NULL ,
			[FED_INDICED] [int] NULL ,
			[BST_PT] [int] NOT NULL ,
			[BST_ENTRAVIGOR] [datetime] NULL ,
			[BST_HIJO] [int] NOT NULL ,
			[BST_INCORPOR] decimal(38,20) NOT NULL CONSTRAINT [DF_BOM_DESCTEMP_BST_INCORPOR] DEFAULT (1),
			[BST_DISCH] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BOM_DESCTEMP_BST_DISCH] DEFAULT ('S'),
			[TI_CODIGO] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[ME_CODIGO] [int] NULL ,
			[FACTCONV] decimal(28,14) NOT NULL CONSTRAINT [DF_BOM_DESCTEMP_FACTCONV] DEFAULT (1),
			[BST_PERINI] [datetime] NULL ,
			[BST_PERFIN] [datetime] NULL CONSTRAINT [DF_BOM_DESCTEMP_BST_PERFIN] DEFAULT ('01/01/9999'),
			[ME_GEN] [int] NULL ,
			[BST_TRANS] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BOM_DESCTEMP_BST_TRANS] DEFAULT ('N'),
			[BST_TIPOCOSTO] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[BST_COSTO] decimal(38,6) NULL ,
			[MA_TIP_ENS] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[FED_CANT] decimal(38,6) NULL ,
			[BST_NIVEL] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[BST_TIPODESC] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[BST_PERTENECE] [int] NULL ,
			[BST_CONTESTATUS] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BOM_DESCTEMP_BST_CONTESTATUS] DEFAULT ('E'),
			[FACT_INV] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BOM_DESCTEMP_FACT_INV] DEFAULT ('F'),
			[BST_DESCARGADO] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BOM_DESCTEMP_BST_DESCARGADO] DEFAULT ('N'),
			[BST_PESO_KG] decimal(38,6) NULL CONSTRAINT [DF_BOM_DESCTEMP_BST_PESO_KG] DEFAULT (0) 
		) ON [PRIMARY]
		
		ALTER TABLE [dbo].[BOM_DESCTEMP] ADD 
			CONSTRAINT [IX_BOM_DESCTEMP] UNIQUE  NONCLUSTERED 
			(
				[CONSECUTIVO]
			) WITH  FILLFACTOR = 90  ON [PRIMARY]

         -- Índice para BOM_DescTemp.FE_Codigo
         CREATE NONCLUSTERED INDEX IX_BOM_DESCTEMP_1 ON dbo.BOM_DESCTEMP
         (
            FE_CODIGO
         ) ON [PRIMARY]

         -- Índice para BOM_DescTemp.FED_IndiceD
         CREATE NONCLUSTERED INDEX IX_BOM_DESCTEMP_2 ON dbo.BOM_DESCTEMP
         (
            FED_INDICED
         ) ON [PRIMARY]

         -- Índice para BOM_DescTemp.BST_Hijo
         CREATE NONCLUSTERED INDEX IX_BOM_DESCTEMP_3 ON dbo.BOM_DESCTEMP
         (
            BST_HIJO
         ) ON [PRIMARY]

         -- BOM_DescTemp.BST_PT
         CREATE NONCLUSTERED INDEX IX_BOM_DESCTEMP_4 ON dbo.BOM_DESCTEMP
         (
            BST_PT
         ) ON [PRIMARY]

	end



























GO
