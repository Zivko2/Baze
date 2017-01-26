SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TempFaltantes8100] (
		[Codigo]              [int] IDENTITY(1, 1) NOT NULL,
		[FE_FOLIO]            [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_FECHA]            [datetime] NULL,
		[TF_NOMBRE]           [varchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[BST_HIJO]            [int] NULL,
		[BST_NOPARTE]         [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MA_NOMBRE]           [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[GRUPOGEN]            [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PA_CORTO]            [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ME_CORTOGEN]         [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NOPARTEPADRE]        [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FED_CANT]            [decimal](38, 6) NULL,
		[BST_INCORPORGEN]     [decimal](38, 6) NULL,
		[CANT_A_DESC]         [decimal](38, 6) NULL,
		[SALDOACTUAL]         [decimal](38, 6) NULL,
		[SALDONVO]            [decimal](38, 6) NULL,
		CONSTRAINT [IX_TempFaltantes8100]
		UNIQUE
		NONCLUSTERED
		([Codigo])
		ON [PRIMARY]
) ON [PRIMARY]
GO
