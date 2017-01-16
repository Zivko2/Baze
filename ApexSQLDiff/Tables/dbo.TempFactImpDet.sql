SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TempFactImpDet] (
		[FID_INDICED]            [int] IDENTITY(1, 1) NOT NULL,
		[FI_CODIGO]              [int] NOT NULL,
		[FID_NOPARTE]            [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FID_NOMBRE]             [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FID_NAME]               [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FID_CANT_ST]            [decimal](38, 6) NOT NULL,
		[FID_COS_UNI]            [decimal](38, 6) NOT NULL,
		[FID_COS_TOT]            [decimal](38, 6) NOT NULL,
		[FID_PES_UNI]            [decimal](38, 6) NOT NULL,
		[FID_PES_NET]            [decimal](38, 6) NOT NULL,
		[FID_PES_BRU]            [decimal](38, 6) NOT NULL,
		[FID_PES_UNILB]          [decimal](38, 6) NOT NULL,
		[FID_PES_NETLB]          [decimal](38, 6) NOT NULL,
		[FID_PES_BRULB]          [decimal](38, 6) NOT NULL,
		[OR_CODIGO]              [int] NULL,
		[FID_ORD_COMP]           [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ORD_INDICED]            [int] NULL,
		[FID_NOORDEN]            [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FID_OBSERVA]            [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FID_FEC_ENT]            [datetime] NULL,
		[FID_NUM_ENT]            [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FID_SEC_IMP]            [smallint] NULL,
		[FID_POR_DEF]            [decimal](38, 6) NOT NULL,
		[FID_DEF_TIP]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FID_ENVIO]              [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AR_IMPMX]               [int] NULL,
		[AR_EXPFO]               [int] NULL,
		[MA_CODIGO]              [int] NOT NULL,
		[MV_CODIGO]              [int] NULL,
		[ME_CODIGO]              [int] NULL,
		[MA_GENERICO]            [int] NOT NULL,
		[ME_ARIMPMX]             [int] NULL,
		[PA_CODIGO]              [int] NULL,
		[PR_CODIGO]              [int] NULL,
		[PL_FOLIO]               [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PL_CODIGO]              [int] NULL,
		[PLD_INDICED]            [int] NULL,
		[CS_CODIGO]              [smallint] NULL,
		[PE_CODIGO]              [int] NULL,
		[EQ_GEN]                 [decimal](28, 14) NOT NULL,
		[EQ_IMPMX]               [decimal](28, 14) NOT NULL,
		[EQ_EXPFO]               [decimal](28, 14) NOT NULL,
		[TI_CODIGO]              [int] NOT NULL,
		[FID_RATEEXPFO]          [decimal](38, 6) NULL,
		[FID_RELEMP]             [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[SPI_CODIGO]             [smallint] NOT NULL,
		[MA_EMPAQUE]             [int] NULL,
		[FID_CANTEMP]            [decimal](38, 6) NOT NULL,
		[FID_LOTE]               [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FID_FAC_NUM]            [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FID_FEC_ENV]            [datetime] NULL,
		[FID_LISTA]              [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FID_CON_CERTORIG]       [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ME_GEN]                 [int] NULL,
		[FID_GENERA_EMP]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FID_CANT_DESP]          [decimal](38, 6) NOT NULL,
		[FID_DEFTXT1]            [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FID_DEFTXT2]            [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FID_DEFNO3]             [decimal](38, 6) NULL,
		[FID_DEFNO4]             [decimal](38, 6) NULL,
		[FID_FECHA_STRUCT]       [datetime] NULL,
		[FID_PADREKITINSERT]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PID_INDICEDLIGA]        [int] NOT NULL,
		[PID_INDICEDLIGAR1]      [int] NOT NULL,
		[TCO_CODIGO]             [smallint] NULL,
		[FID_RELCAJAS]           [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FID_SALDO]              [decimal](38, 6) NOT NULL,
		[FID_ENUSO]              [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		CONSTRAINT [IX_TempFactImpDet]
		UNIQUE
		NONCLUSTERED
		([FID_INDICED])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempFactImpDet]
	ADD
	CONSTRAINT [DF_TempFactImpDet_CS_CODIGO]
	DEFAULT (0) FOR [CS_CODIGO]
GO
ALTER TABLE [dbo].[TempFactImpDet]
	ADD
	CONSTRAINT [DF_TempFactImpDet_EQ_EXPFO]
	DEFAULT (1) FOR [EQ_EXPFO]
GO
ALTER TABLE [dbo].[TempFactImpDet]
	ADD
	CONSTRAINT [DF_TempFactImpDet_EQ_GEN]
	DEFAULT (1) FOR [EQ_GEN]
GO
ALTER TABLE [dbo].[TempFactImpDet]
	ADD
	CONSTRAINT [DF_TempFactImpDet_EQ_IMPMX]
	DEFAULT (1) FOR [EQ_IMPMX]
GO
ALTER TABLE [dbo].[TempFactImpDet]
	ADD
	CONSTRAINT [DF_TempFactImpDet_FID_CANT_DESP]
	DEFAULT (0) FOR [FID_CANT_DESP]
GO
ALTER TABLE [dbo].[TempFactImpDet]
	ADD
	CONSTRAINT [DF_TempFactImpDet_FID_CANT_ST]
	DEFAULT (0) FOR [FID_CANT_ST]
GO
ALTER TABLE [dbo].[TempFactImpDet]
	ADD
	CONSTRAINT [DF_TempFactImpDet_FID_CANTEMP]
	DEFAULT (0) FOR [FID_CANTEMP]
GO
ALTER TABLE [dbo].[TempFactImpDet]
	ADD
	CONSTRAINT [DF_TempFactImpDet_FID_COS_TOT]
	DEFAULT (0) FOR [FID_COS_TOT]
GO
ALTER TABLE [dbo].[TempFactImpDet]
	ADD
	CONSTRAINT [DF_TempFactImpDet_FID_COS_UNI]
	DEFAULT (0) FOR [FID_COS_UNI]
GO
ALTER TABLE [dbo].[TempFactImpDet]
	ADD
	CONSTRAINT [DF_TempFactImpDet_FID_DEF_TIP]
	DEFAULT ('G') FOR [FID_DEF_TIP]
GO
ALTER TABLE [dbo].[TempFactImpDet]
	ADD
	CONSTRAINT [DF_TempFactImpDet_FID_DEFTXT1]
	DEFAULT ('') FOR [FID_DEFTXT1]
GO
ALTER TABLE [dbo].[TempFactImpDet]
	ADD
	CONSTRAINT [DF_TempFactImpDet_FID_DEFTXT2]
	DEFAULT ('') FOR [FID_DEFTXT2]
GO
ALTER TABLE [dbo].[TempFactImpDet]
	ADD
	CONSTRAINT [DF_TempFactImpDet_FID_ENUSO]
	DEFAULT ('N') FOR [FID_ENUSO]
GO
ALTER TABLE [dbo].[TempFactImpDet]
	ADD
	CONSTRAINT [DF_TempFactImpDet_FID_GENERA_EMP]
	DEFAULT ('D') FOR [FID_GENERA_EMP]
GO
ALTER TABLE [dbo].[TempFactImpDet]
	ADD
	CONSTRAINT [DF_TempFactImpDet_FID_PADREKITINSERT]
	DEFAULT ('S') FOR [FID_PADREKITINSERT]
GO
ALTER TABLE [dbo].[TempFactImpDet]
	ADD
	CONSTRAINT [DF_TempFactImpDet_FID_PES_BRU]
	DEFAULT (0) FOR [FID_PES_BRU]
GO
ALTER TABLE [dbo].[TempFactImpDet]
	ADD
	CONSTRAINT [DF_TempFactImpDet_FID_PES_BRULB]
	DEFAULT (0) FOR [FID_PES_BRULB]
GO
ALTER TABLE [dbo].[TempFactImpDet]
	ADD
	CONSTRAINT [DF_TempFactImpDet_FID_PES_NET]
	DEFAULT (0) FOR [FID_PES_NET]
GO
ALTER TABLE [dbo].[TempFactImpDet]
	ADD
	CONSTRAINT [DF_TempFactImpDet_FID_PES_NETLB]
	DEFAULT (0) FOR [FID_PES_NETLB]
GO
ALTER TABLE [dbo].[TempFactImpDet]
	ADD
	CONSTRAINT [DF_TempFactImpDet_FID_PES_UNI]
	DEFAULT (0) FOR [FID_PES_UNI]
GO
ALTER TABLE [dbo].[TempFactImpDet]
	ADD
	CONSTRAINT [DF_TempFactImpDet_FID_PES_UNILB]
	DEFAULT (0) FOR [FID_PES_UNILB]
GO
ALTER TABLE [dbo].[TempFactImpDet]
	ADD
	CONSTRAINT [DF_TempFactImpDet_FID_POR_DEF]
	DEFAULT ((-1)) FOR [FID_POR_DEF]
GO
ALTER TABLE [dbo].[TempFactImpDet]
	ADD
	CONSTRAINT [DF_TempFactImpDet_FID_RELEMP]
	DEFAULT ('N') FOR [FID_RELEMP]
GO
ALTER TABLE [dbo].[TempFactImpDet]
	ADD
	CONSTRAINT [DF_TempFactImpDet_FID_SALDO]
	DEFAULT (0) FOR [FID_SALDO]
GO
ALTER TABLE [dbo].[TempFactImpDet]
	ADD
	CONSTRAINT [DF_TempFactImpDet_MA_GENERICO]
	DEFAULT (0) FOR [MA_GENERICO]
GO
ALTER TABLE [dbo].[TempFactImpDet]
	ADD
	CONSTRAINT [DF_TempFactImpDet_PID_INDICEDLIGA]
	DEFAULT ((-1)) FOR [PID_INDICEDLIGA]
GO
ALTER TABLE [dbo].[TempFactImpDet]
	ADD
	CONSTRAINT [DF_TempFactImpDet_PID_INDICEDLIGAR1]
	DEFAULT ((-1)) FOR [PID_INDICEDLIGAR1]
GO
ALTER TABLE [dbo].[TempFactImpDet]
	ADD
	CONSTRAINT [DF_TempFactImpDet_SPI_CODIGO]
	DEFAULT (0) FOR [SPI_CODIGO]
GO
ALTER TABLE [dbo].[TempFactImpDet] SET (LOCK_ESCALATION = TABLE)
GO
