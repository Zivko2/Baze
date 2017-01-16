SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PEDIDODET] (
		[PD_CODIGO]             [int] NOT NULL,
		[PDD_INDICED]           [int] NOT NULL,
		[MA_CODIGO]             [int] NOT NULL,
		[PDD_NOPARTE]           [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PDD_NOMBRE]            [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PDD_NAME]              [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PDD_CANT]              [decimal](38, 6) NOT NULL,
		[ME_CODIGO]             [int] NULL,
		[PDD_SALDO]             [decimal](38, 6) NULL,
		[PDD_PRECIOVENTA]       [decimal](38, 6) NULL,
		[PDD_COS_UNI]           [decimal](38, 6) NULL,
		[PDD_COS_TOT]           [decimal](38, 6) NULL,
		[PDD_COS_TOT_VENTA]     [decimal](38, 6) NULL,
		[TI_CODIGO]             [int] NULL,
		[MA_EMPAQUE]            [int] NULL,
		[PDD_CANTEMP]           [decimal](38, 6) NULL,
		[PDD_OBSERVA]           [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PDD_ENUSO]             [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PDD_FECHAENTREGA]      [datetime] NULL,
		[PDD_DESCUENTO]         [decimal](38, 6) NULL,
		[PDD_COTD_INDICED]      [int] NULL,
		[PDD_COT_FOLIO]         [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PEDIDODET] SET (LOCK_ESCALATION = TABLE)
GO
