SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LISTAEXPDET] (
		[LED_INDICED]        [int] NOT NULL,
		[LE_CODIGO]          [int] NOT NULL,
		[MA_CODIGO]          [int] NULL,
		[LED_NOMBRE]         [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[LED_NAME]           [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ME_CODIGO]          [int] NULL,
		[LED_CANT]           [decimal](38, 6) NOT NULL,
		[LED_GRA_MP]         [decimal](38, 6) NULL,
		[LED_GRA_MO]         [decimal](38, 6) NULL,
		[LED_GRA_EMP]        [decimal](38, 6) NULL,
		[LED_GRA_ADD]        [decimal](38, 6) NULL,
		[LED_GRA_GI_MX]      [decimal](38, 6) NULL,
		[LED_GRA_GI]         [decimal](38, 6) NULL,
		[LED_GRA_VA]         [decimal](38, 6) NULL,
		[TOT_GRAV_UNI]       [decimal](38, 6) NULL,
		[LED_NG_MP]          [decimal](38, 6) NULL,
		[LED_NG_EMP]         [decimal](38, 6) NULL,
		[LED_NG_ADD]         [decimal](38, 6) NULL,
		[LED_NG_USA]         [decimal](38, 6) NULL,
		[TOT_NG_UNI]         [decimal](38, 6) NULL,
		[LED_COS_UNI]        [decimal](38, 6) NULL,
		[LED_COS_TOT]        [decimal](38, 6) NOT NULL,
		[LED_PES_UNI]        [decimal](38, 6) NULL,
		[LED_PES_NET]        [decimal](38, 6) NOT NULL,
		[LED_PES_BRU]        [decimal](38, 6) NOT NULL,
		[LED_PES_UNILB]      [decimal](38, 6) NULL,
		[LED_PES_NETLB]      [decimal](38, 6) NOT NULL,
		[LED_PES_BRULB]      [decimal](38, 6) NOT NULL,
		[LED_LOTE]           [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PA_CODIGO]          [int] NULL,
		[LED_SEC_IMP]        [smallint] NULL,
		[LED_DEF_TIP]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LED_POR_DEF]        [decimal](38, 6) NULL,
		[AR_IMPMX]           [int] NULL,
		[AR_EXPMX]           [int] NULL,
		[AR_IMPFO]           [int] NULL,
		[AR_RETRA]           [int] NULL,
		[AR_DESP]            [int] NULL,
		[EQ_GEN]             [decimal](28, 14) NULL,
		[MA_GENERICO]        [int] NULL,
		[LED_GRA_TOT]        [decimal](38, 6) NOT NULL,
		[LED_NG_TOT]         [decimal](38, 6) NOT NULL,
		[LED_SALDO]          [decimal](38, 6) NULL,
		[LED_ENUSO]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LED_NOPARTE]        [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LED_RATEEXPMX]      [decimal](38, 6) NULL,
		[LED_RATEIMPFO]      [decimal](38, 6) NULL,
		[LED_RATERETRA]      [decimal](38, 6) NULL,
		[LED_RATEDESP]       [decimal](38, 6) NULL,
		[EQ_RETRA]           [decimal](28, 14) NULL,
		[EQ_DESP]            [decimal](28, 14) NULL,
		[EQ_IMPFO]           [decimal](28, 14) NULL,
		[EQ_EXPMX]           [decimal](28, 14) NULL,
		[TI_CODIGO]          [smallint] NOT NULL,
		[ME_GEN]             [int] NULL,
		[TCO_CODIGO]         [smallint] NULL,
		[END_INDICED]        [int] NULL,
		[EN_CODIGO]          [int] NULL,
		[PD_FOLIO]           [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MA_EMPAQUE]         [int] NULL,
		[LED_CANTEMP]        [decimal](38, 6) NULL,
		[LED_NOPARTEAUX]     [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MA_NOPARTECL]       [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[SPI_CODIGO]         [int] NULL,
		[LED_NAFTA]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AR_ORIG]            [int] NULL,
		[AR_NG_EMP]          [int] NULL,
		[LED_TIP_ENS]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LED_PRECIO_UNI]     [decimal](38, 6) NULL,
		[LED_PRECIO_TOT]     [decimal](38, 6) NULL,
		[MA_STRUCT]          [int] NULL,
		[LED_RETRABAJO]      [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LISTAEXPDET]
	ADD
	CONSTRAINT [PK_LISTAEXPDET]
	PRIMARY KEY
	NONCLUSTERED
	([LED_INDICED])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[LISTAEXPDET]
	ADD
	CONSTRAINT [DF_LISTAEXPDET_EQ_DESP]
	DEFAULT (0) FOR [EQ_DESP]
GO
ALTER TABLE [dbo].[LISTAEXPDET]
	ADD
	CONSTRAINT [DF_LISTAEXPDET_EQ_EXPMX]
	DEFAULT (0) FOR [EQ_EXPMX]
GO
ALTER TABLE [dbo].[LISTAEXPDET]
	ADD
	CONSTRAINT [DF_LISTAEXPDET_EQ_IMPFO]
	DEFAULT (0) FOR [EQ_IMPFO]
GO
ALTER TABLE [dbo].[LISTAEXPDET]
	ADD
	CONSTRAINT [DF_LISTAEXPDET_EQ_RETRA]
	DEFAULT (0) FOR [EQ_RETRA]
GO
ALTER TABLE [dbo].[LISTAEXPDET]
	ADD
	CONSTRAINT [DF_LISTAEXPDET_LED_CANT]
	DEFAULT (0) FOR [LED_CANT]
GO
ALTER TABLE [dbo].[LISTAEXPDET]
	ADD
	CONSTRAINT [DF_LISTAEXPDET_LED_CANTEMP]
	DEFAULT (0) FOR [LED_CANTEMP]
GO
ALTER TABLE [dbo].[LISTAEXPDET]
	ADD
	CONSTRAINT [DF_LISTAEXPDET_LED_COS_TOT]
	DEFAULT (0) FOR [LED_COS_TOT]
GO
ALTER TABLE [dbo].[LISTAEXPDET]
	ADD
	CONSTRAINT [DF_LISTAEXPDET_LED_ENUSO]
	DEFAULT ('N') FOR [LED_ENUSO]
GO
ALTER TABLE [dbo].[LISTAEXPDET]
	ADD
	CONSTRAINT [DF_LISTAEXPDET_LED_GRA_TOT]
	DEFAULT (0) FOR [LED_GRA_TOT]
GO
ALTER TABLE [dbo].[LISTAEXPDET]
	ADD
	CONSTRAINT [DF_LISTAEXPDET_LED_NG_TOT]
	DEFAULT (0) FOR [LED_NG_TOT]
GO
ALTER TABLE [dbo].[LISTAEXPDET]
	ADD
	CONSTRAINT [DF_LISTAEXPDET_LED_PES_BRU]
	DEFAULT (0) FOR [LED_PES_BRU]
GO
ALTER TABLE [dbo].[LISTAEXPDET]
	ADD
	CONSTRAINT [DF_LISTAEXPDET_LED_PES_BRULB]
	DEFAULT (0) FOR [LED_PES_BRULB]
GO
ALTER TABLE [dbo].[LISTAEXPDET]
	ADD
	CONSTRAINT [DF_LISTAEXPDET_LED_PES_NET]
	DEFAULT (0) FOR [LED_PES_NET]
GO
ALTER TABLE [dbo].[LISTAEXPDET]
	ADD
	CONSTRAINT [DF_LISTAEXPDET_LED_PES_NETLB]
	DEFAULT (0) FOR [LED_PES_NETLB]
GO
ALTER TABLE [dbo].[LISTAEXPDET]
	ADD
	CONSTRAINT [DF_LISTAEXPDET_LED_RATEDESP]
	DEFAULT (0) FOR [LED_RATEDESP]
GO
ALTER TABLE [dbo].[LISTAEXPDET]
	ADD
	CONSTRAINT [DF_LISTAEXPDET_LED_RATEEXPMX]
	DEFAULT (0) FOR [LED_RATEEXPMX]
GO
ALTER TABLE [dbo].[LISTAEXPDET]
	ADD
	CONSTRAINT [DF_LISTAEXPDET_LED_RATEIMPFO]
	DEFAULT (0) FOR [LED_RATEIMPFO]
GO
ALTER TABLE [dbo].[LISTAEXPDET]
	ADD
	CONSTRAINT [DF_LISTAEXPDET_LED_RATERETRA]
	DEFAULT (0) FOR [LED_RATERETRA]
GO
ALTER TABLE [dbo].[LISTAEXPDET]
	ADD
	CONSTRAINT [DF_LISTAEXPDET_LED_RETRABAJO]
	DEFAULT ('N') FOR [LED_RETRABAJO]
GO
ALTER TABLE [dbo].[LISTAEXPDET] SET (LOCK_ESCALATION = TABLE)
GO
