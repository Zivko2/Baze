SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PCKLISTDET] (
		[PLD_INDICED]        [int] NOT NULL,
		[PL_CODIGO]          [int] NOT NULL,
		[PLD_CANT_ORIG]      [decimal](38, 6) NULL,
		[PLD_CANT_ST]        [decimal](38, 6) NULL,
		[PLD_COS_UNI]        [decimal](38, 6) NULL,
		[PLD_NOMBRE]         [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PLD_NAME]           [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PLD_NOPARTE]        [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OR_CODIGO]          [int] NULL,
		[PLD_ORD_COMP]       [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ORD_INDICED]        [int] NULL,
		[PLD_NOORDEN]        [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PLD_ENVIO]          [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PLD_SALDO]          [decimal](38, 6) NULL,
		[PLD_PES_UNI]        [decimal](38, 6) NULL,
		[PLD_PES_NET]        [decimal](38, 6) NULL,
		[PLD_PES_BRU]        [decimal](38, 6) NULL,
		[PLD_PES_UNILB]      [decimal](38, 6) NULL,
		[PLD_PES_NETLB]      [decimal](38, 6) NULL,
		[PLD_PES_BRULB]      [decimal](38, 6) NULL,
		[PLD_COS_TOT]        [decimal](38, 6) NULL,
		[PLD_FEC_ENT]        [datetime] NULL,
		[PLD_NUM_ENT]        [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PLD_SEC_IMP]        [smallint] NULL,
		[PLD_DEF_TIP]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PLD_POR_DEF]        [decimal](38, 6) NOT NULL,
		[PLD_ENUSO]          [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PLD_FEC_EST]        [smalldatetime] NULL,
		[PLD_FECHA]          [smalldatetime] NULL,
		[MV_CODIGO]          [int] NULL,
		[MA_CODIGO]          [int] NOT NULL,
		[PA_CODIGO]          [int] NULL,
		[AR_IMPMX]           [int] NULL,
		[AR_EXPFO]           [int] NULL,
		[MA_GENERICO]        [int] NOT NULL,
		[ME_CODIGO]          [int] NULL,
		[ME_ARIMPMX]         [int] NULL,
		[EQ_IMPMX]           [decimal](28, 14) NOT NULL,
		[EQ_EXPFO]           [decimal](28, 14) NOT NULL,
		[EQ_GEN]             [decimal](28, 14) NOT NULL,
		[PLD_RATEEXPFO]      [decimal](38, 6) NULL,
		[TI_CODIGO]          [int] NOT NULL,
		[ME_GEN]             [int] NULL,
		[MA_EMPAQUE]         [int] NULL,
		[PLD_CANTEMP]        [decimal](38, 6) NULL,
		[PLD_FEC_ENV]        [datetime] NULL,
		[SPI_CODIGO]         [smallint] NULL,
		[TCO_CODIGO]         [smallint] NULL,
		[PLD_NOPARTEAUX]     [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[EQ_EXPFO2]          [decimal](28, 14) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PCKLISTDET]
	ADD
	CONSTRAINT [PK_PCKLISTDET]
	PRIMARY KEY
	CLUSTERED
	([PL_CODIGO], [PLD_INDICED])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[PCKLISTDET]
	ADD
	CONSTRAINT [DF_PCKLISTDET_EQ_EXPFO]
	DEFAULT (1) FOR [EQ_EXPFO]
GO
ALTER TABLE [dbo].[PCKLISTDET]
	ADD
	CONSTRAINT [DF_PCKLISTDET_EQ_EXPFO2]
	DEFAULT (1) FOR [EQ_EXPFO2]
GO
ALTER TABLE [dbo].[PCKLISTDET]
	ADD
	CONSTRAINT [DF_PCKLISTDET_EQ_GEN]
	DEFAULT (1) FOR [EQ_GEN]
GO
ALTER TABLE [dbo].[PCKLISTDET]
	ADD
	CONSTRAINT [DF_PCKLISTDET_EQ_IMPMX]
	DEFAULT (1) FOR [EQ_IMPMX]
GO
ALTER TABLE [dbo].[PCKLISTDET]
	ADD
	CONSTRAINT [DF_PCKLISTDET_MA_GENERICO]
	DEFAULT (0) FOR [MA_GENERICO]
GO
ALTER TABLE [dbo].[PCKLISTDET]
	ADD
	CONSTRAINT [DF_PCKLISTDET_PLD_DEF_TIP]
	DEFAULT ('G') FOR [PLD_DEF_TIP]
GO
ALTER TABLE [dbo].[PCKLISTDET]
	ADD
	CONSTRAINT [DF_PCKLISTDET_PLD_ENUSO]
	DEFAULT ('N') FOR [PLD_ENUSO]
GO
ALTER TABLE [dbo].[PCKLISTDET]
	ADD
	CONSTRAINT [DF_PCKLISTDET_PLD_NOPARTE]
	DEFAULT ('') FOR [PLD_NOPARTE]
GO
ALTER TABLE [dbo].[PCKLISTDET]
	ADD
	CONSTRAINT [DF_PCKLISTDET_PLD_POR_DEF]
	DEFAULT ((-1)) FOR [PLD_POR_DEF]
GO
