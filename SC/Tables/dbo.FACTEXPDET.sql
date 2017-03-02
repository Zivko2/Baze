SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FACTEXPDET] (
		[FED_INDICED]           [int] NOT NULL,
		[FE_CODIGO]             [int] NOT NULL,
		[MA_CODIGO]             [int] NOT NULL,
		[FED_NOMBRE]            [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FED_NOPARTE]           [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FED_NAME]              [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ME_CODIGO]             [int] NULL,
		[FED_OBSERVA]           [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FED_CANT]              [decimal](38, 6) NOT NULL,
		[FED_GRA_MP]            [decimal](38, 6) NOT NULL,
		[FED_GRA_MO]            [decimal](38, 6) NOT NULL,
		[FED_GRA_EMP]           [decimal](38, 6) NOT NULL,
		[FED_GRA_ADD]           [decimal](38, 6) NOT NULL,
		[FED_GRA_GI]            [decimal](38, 6) NOT NULL,
		[FED_GRA_GI_MX]         [decimal](38, 6) NOT NULL,
		[FED_NG_MP]             [decimal](38, 6) NOT NULL,
		[FED_NG_EMP]            [decimal](38, 6) NOT NULL,
		[FED_NG_ADD]            [decimal](38, 6) NOT NULL,
		[FED_NG_USA]            [decimal](38, 6) NOT NULL,
		[FED_COS_UNI]           [decimal](38, 6) NOT NULL,
		[FED_COS_TOT]           [decimal](38, 6) NOT NULL,
		[FED_PES_UNI]           [decimal](38, 6) NOT NULL,
		[FED_PES_NET]           [decimal](38, 6) NOT NULL,
		[FED_PES_BRU]           [decimal](38, 6) NOT NULL,
		[FED_PES_UNILB]         [decimal](38, 6) NOT NULL,
		[FED_PES_NETLB]         [decimal](38, 6) NOT NULL,
		[FED_PES_BRULB]         [decimal](38, 6) NOT NULL,
		[FED_SEC_IMP]           [smallint] NULL,
		[FED_DEF_TIP]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FED_POR_DEF]           [decimal](38, 6) NOT NULL,
		[FED_LOTE]              [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AR_IMPMX]              [int] NOT NULL,
		[AR_EXPMX]              [int] NOT NULL,
		[AR_IMPFO]              [int] NOT NULL,
		[FED_CON_PED]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MA_GENERICO]           [int] NOT NULL,
		[PA_CODIGO]             [int] NOT NULL,
		[LE_CODIGO]             [int] NULL,
		[LED_INDICED]           [int] NULL,
		[EX_CODIGO]             [int] NULL,
		[FED_ORD_COMP]          [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FED_NOORDEN]           [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FED_USO_COMMINV]       [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[EQ_GEN]                [decimal](28, 14) NOT NULL,
		[EQ_IMPFO]              [decimal](28, 14) NOT NULL,
		[EQ_EXPMX]              [decimal](28, 14) NOT NULL,
		[TI_CODIGO]             [smallint] NOT NULL,
		[FED_TENVIO]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FED_INBOND]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FED_TIPOINBOND]        [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FED_RATEEXPMX]         [decimal](38, 6) NOT NULL,
		[FED_RATEIMPFO]         [decimal](38, 6) NOT NULL,
		[FED_RELEMP]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FED_FECHA_STRUCT]      [datetime] NULL,
		[FED_DISCHARGE]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[LE_FOLIO]              [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[SPI_CODIGO]            [smallint] NOT NULL,
		[FED_SALDO]             [decimal](38, 6) NOT NULL,
		[FED_RETRABAJO]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ADE_CODIGO]            [int] NULL,
		[MA_EMPAQUE]            [int] NOT NULL,
		[FED_CANTEMP]           [decimal](38, 6) NOT NULL,
		[FED_FAC_NUM]           [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FED_FEC_ENV]           [datetime] NULL,
		[FED_CON_CERTORIG]      [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FED_COS_UNI_CO]        [decimal](38, 6) NOT NULL,
		[FED_GRA_MAT_CO]        [decimal](38, 6) NOT NULL,
		[FED_EMP_CO]            [decimal](38, 6) NOT NULL,
		[FED_NG_MAT_CO]         [decimal](38, 6) NOT NULL,
		[FED_VA_CO]             [decimal](38, 6) NOT NULL,
		[FED_CANTGEN]           [decimal](38, 6) NOT NULL,
		[MO_CODIGO]             [int] NULL,
		[FED_DESCARGADO]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FED_PARTTYPE]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ME_GENERICO]           [int] NOT NULL,
		[FED_TIP_ENS]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PID_INDICED]           [int] NOT NULL,
		[MA_NOPARTECL]          [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ME_AREXPMX]            [int] NOT NULL,
		[FED_NAFTA]             [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FED_DEFTXT1]           [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FED_DEFTXT2]           [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FED_DEFNO3]            [decimal](38, 6) NULL,
		[FED_DEFNO4]            [decimal](38, 6) NULL,
		[PID_INDICEDLIGA]       [int] NOT NULL,
		[PID_INDICEDLIGAR1]     [int] NOT NULL,
		[TCO_CODIGO]            [smallint] NOT NULL,
		[PI_ORIGENKITPADRE]     [int] NOT NULL,
		[CS_CODIGO]             [smallint] NOT NULL,
		[SE_CODIGO]             [smallint] NOT NULL,
		[FED_RELCAJAS]          [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[END_INDICED]           [int] NULL,
		[EN_CODIGO]             [int] NULL,
		[FED_SALDOTRANS]        [decimal](38, 6) NOT NULL,
		[FED_USOTRANS]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FED_USOSALDO]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CL_CODIGO]             [int] NULL,
		[MA_STRUCT]             [int] NULL,
		[FED_DESTNAFTA]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AR_ORIG]               [int] NOT NULL,
		[AR_NG_EMP]             [int] NOT NULL,
		[FED_NOPARTEAUX]        [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ETA_CODIGO]            [int] NOT NULL,
		[FED_NOPARTESTRUCT]     [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FED_NG_MX]             [decimal](38, 6) NOT NULL,
		[FED_GENERA_EMPDET]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FED_GRAVA_VA]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FED_PARTIDA]           [int] NULL,
		[FED_SECF4]             [int] NULL,
		[FED_PRECIO_UNI]        [decimal](38, 6) NULL,
		[FED_PRECIO_TOT]        [decimal](38, 6) NULL,
		[FED_PIDSECUENCIA]      [int] NULL,
		[FED_FOLIO_CERT]        [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FED_POR_CERT]          [decimal](38, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [PK_FACTEXPDET]
	PRIMARY KEY
	NONCLUSTERED
	([FED_INDICED])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_AR_EXPMX]
	DEFAULT (0) FOR [AR_EXPMX]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_AR_IMPFO]
	DEFAULT (0) FOR [AR_IMPFO]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_AR_IMPMX]
	DEFAULT (0) FOR [AR_IMPMX]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_AR_NG_EMP]
	DEFAULT (0) FOR [AR_NG_EMP]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_AR_ORIG]
	DEFAULT (0) FOR [AR_ORIG]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_CS_CODIGO]
	DEFAULT (0) FOR [CS_CODIGO]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_EQ_EXPMX]
	DEFAULT (1) FOR [EQ_EXPMX]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_EQ_GEN]
	DEFAULT (1) FOR [EQ_GEN]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_EQ_IMPFO]
	DEFAULT (1) FOR [EQ_IMPFO]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_ETA_CODIGO]
	DEFAULT ((-1)) FOR [ETA_CODIGO]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_CANT]
	DEFAULT (0) FOR [FED_CANT]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_CANTEMP]
	DEFAULT (0) FOR [FED_CANTEMP]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_CANTGEN]
	DEFAULT (0) FOR [FED_CANTGEN]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_CON_CERTORIG]
	DEFAULT ('N') FOR [FED_CON_CERTORIG]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_CON_PED]
	DEFAULT ('N') FOR [FED_CON_PED]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_COS_TOT]
	DEFAULT (0) FOR [FED_COS_TOT]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_COS_UNI]
	DEFAULT (0) FOR [FED_COS_UNI]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_COS_UNI_CO]
	DEFAULT (0) FOR [FED_COS_UNI_CO]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_DEF_TIP]
	DEFAULT ('G') FOR [FED_DEF_TIP]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_DEFTXT1]
	DEFAULT ('') FOR [FED_DEFTXT1]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_DEFTXT2]
	DEFAULT ('') FOR [FED_DEFTXT2]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_DESCARGADO]
	DEFAULT ('N') FOR [FED_DESCARGADO]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_DISCHARGE]
	DEFAULT ('S') FOR [FED_DISCHARGE]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_EMP_CO]
	DEFAULT (0) FOR [FED_EMP_CO]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_GENERA_EMPDET]
	DEFAULT ('D') FOR [FED_GENERA_EMPDET]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_GRA_ADD]
	DEFAULT (0) FOR [FED_GRA_ADD]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_GRA_EMP]
	DEFAULT (0) FOR [FED_GRA_EMP]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_GRA_GI]
	DEFAULT (0) FOR [FED_GRA_GI]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_GRA_GI_MX]
	DEFAULT (0) FOR [FED_GRA_GI_MX]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_GRA_MAT_CO]
	DEFAULT (0) FOR [FED_GRA_MAT_CO]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_GRA_MO]
	DEFAULT (0) FOR [FED_GRA_MO]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_GRA_MP]
	DEFAULT (0) FOR [FED_GRA_MP]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_GRAVA_VA]
	DEFAULT ('S') FOR [FED_GRAVA_VA]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_NAFTA]
	DEFAULT ('N') FOR [FED_NAFTA]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_NG_ADD]
	DEFAULT (0) FOR [FED_NG_ADD]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_NG_EMP]
	DEFAULT (0) FOR [FED_NG_EMP]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_NG_MAT_CO]
	DEFAULT (0) FOR [FED_NG_MAT_CO]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_NG_MP]
	DEFAULT (0) FOR [FED_NG_MP]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_NG_MX]
	DEFAULT (0) FOR [FED_NG_MX]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_NG_USA]
	DEFAULT (0) FOR [FED_NG_USA]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_NOORDEN]
	DEFAULT ('') FOR [FED_NOORDEN]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_ORD_COMP]
	DEFAULT ('') FOR [FED_ORD_COMP]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_PES_BRU]
	DEFAULT (0) FOR [FED_PES_BRU]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_PES_BRULB]
	DEFAULT (0) FOR [FED_PES_BRULB]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_PES_NET]
	DEFAULT (0) FOR [FED_PES_NET]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_PES_NETLB]
	DEFAULT (0) FOR [FED_PES_NETLB]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_PES_UNI]
	DEFAULT (0) FOR [FED_PES_UNI]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_PES_UNILB]
	DEFAULT (0) FOR [FED_PES_UNILB]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_POR_DEF]
	DEFAULT ((-1)) FOR [FED_POR_DEF]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_RATEEXPMX]
	DEFAULT ((-1)) FOR [FED_RATEEXPMX]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_RATEIMPFO]
	DEFAULT ((-1)) FOR [FED_RATEIMPFO]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_RELEMP]
	DEFAULT ('N') FOR [FED_RELEMP]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_RETRABAJO]
	DEFAULT ('N') FOR [FED_RETRABAJO]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_SALDO]
	DEFAULT (0) FOR [FED_SALDO]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_SALDOTRANS]
	DEFAULT (0) FOR [FED_SALDOTRANS]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_SEC_IMP]
	DEFAULT (0) FOR [FED_SEC_IMP]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_USO_COMMINV]
	DEFAULT ('N') FOR [FED_USO_COMMINV]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_USOSALDO]
	DEFAULT ('N') FOR [FED_USOSALDO]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_USOTRANS]
	DEFAULT ('N') FOR [FED_USOTRANS]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_FED_VA_CO]
	DEFAULT (0) FOR [FED_VA_CO]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_MA_EMPAQUE]
	DEFAULT (0) FOR [MA_EMPAQUE]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_MA_GENERICO]
	DEFAULT (0) FOR [MA_GENERICO]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_ME_AREXPMX]
	DEFAULT (0) FOR [ME_AREXPMX]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_ME_GENERICO]
	DEFAULT (0) FOR [ME_GENERICO]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_PA_CODIGO]
	DEFAULT (0) FOR [PA_CODIGO]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_PI_ORIGENKITPADRE]
	DEFAULT ((-1)) FOR [PI_ORIGENKITPADRE]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_PID_INDICED]
	DEFAULT ((-1)) FOR [PID_INDICED]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_PID_INDICEDLIGA]
	DEFAULT ((-1)) FOR [PID_INDICEDLIGA]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_PID_INDICEDLIGAR1]
	DEFAULT ((-1)) FOR [PID_INDICEDLIGAR1]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_SE_CODIGO]
	DEFAULT (0) FOR [SE_CODIGO]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_SPI_CODIGO]
	DEFAULT (0) FOR [SPI_CODIGO]
GO
ALTER TABLE [dbo].[FACTEXPDET]
	ADD
	CONSTRAINT [DF_FACTEXPDET_TCO_CODIGO]
	DEFAULT (0) FOR [TCO_CODIGO]
GO
CREATE CLUSTERED INDEX [IX_FACTEXPDET]
	ON [dbo].[FACTEXPDET] ([FE_CODIGO], [FED_INDICED])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FACTEXPDET_1]
	ON [dbo].[FACTEXPDET] ([AR_EXPMX])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FACTEXPDET_10]
	ON [dbo].[FACTEXPDET] ([PID_INDICED], [FE_CODIGO], [FED_CANT], [EQ_GEN])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FACTEXPDET_11]
	ON [dbo].[FACTEXPDET] ([FE_CODIGO], [FED_COS_TOT])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FACTEXPDET_12]
	ON [dbo].[FACTEXPDET] ([PID_INDICEDLIGA])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FACTEXPDET_13]
	ON [dbo].[FACTEXPDET] ([FE_CODIGO], [FED_PES_BRU])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FACTEXPDET_14]
	ON [dbo].[FACTEXPDET] ([PID_INDICEDLIGAR1])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FACTEXPDET_2]
	ON [dbo].[FACTEXPDET] ([AR_IMPFO])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FACTEXPDET_3]
	ON [dbo].[FACTEXPDET] ([PA_CODIGO])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FACTEXPDET_4]
	ON [dbo].[FACTEXPDET] ([ME_CODIGO])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FACTEXPDET_5]
	ON [dbo].[FACTEXPDET] ([MA_GENERICO])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FACTEXPDET_6]
	ON [dbo].[FACTEXPDET] ([ME_AREXPMX])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FACTEXPDET_7]
	ON [dbo].[FACTEXPDET] ([CL_CODIGO])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FACTEXPDET_8]
	ON [dbo].[FACTEXPDET] ([FED_DESCARGADO])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FACTEXPDET_9]
	ON [dbo].[FACTEXPDET] ([FE_CODIGO])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FACTEXPDET_TI_Codigo]
	ON [dbo].[FACTEXPDET] ([TI_CODIGO])
	ON [PRIMARY]
GO