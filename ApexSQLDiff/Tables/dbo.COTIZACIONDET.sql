SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[COTIZACIONDET] (
		[COT_CODIGO]             [int] NOT NULL,
		[COTD_INDICED]           [int] NOT NULL,
		[MA_CODIGO]              [int] NOT NULL,
		[COTD_NOPARTE]           [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[COTD_NOMBRE]            [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[COTD_NAME]              [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[COTD_CANT]              [decimal](38, 6) NOT NULL,
		[ME_CODIGO]              [int] NULL,
		[COTD_SALDO]             [decimal](38, 6) NULL,
		[COTD_PRECIOVENTA]       [decimal](38, 6) NULL,
		[COTD_COS_UNI]           [decimal](38, 6) NULL,
		[COTD_COS_TOT]           [decimal](38, 6) NULL,
		[COTD_COS_TOT_VENTA]     [decimal](38, 6) NULL,
		[TI_CODIGO]              [int] NULL,
		[MA_EMPAQUE]             [int] NULL,
		[COTD_CANTEMP]           [decimal](38, 6) NULL,
		[COTD_OBSERVA]           [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[COTD_ENUSO]             [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[COTD_FECHAENTREGA]      [datetime] NULL,
		[COTD_DESCUENTO]         [decimal](38, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[COTIZACIONDET]
	ADD
	CONSTRAINT [PK_COTIZACIONDET]
	PRIMARY KEY
	NONCLUSTERED
	([COTD_INDICED])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[COTIZACIONDET]
	ADD
	CONSTRAINT [DF_COTIZACIONDET_COTD_ENUSO]
	DEFAULT ('N') FOR [COTD_ENUSO]
GO
ALTER TABLE [dbo].[COTIZACIONDET] SET (LOCK_ESCALATION = TABLE)
GO
