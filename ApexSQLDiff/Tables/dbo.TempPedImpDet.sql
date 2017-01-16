SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TempPedImpDet] (
		[PI_CODIGO]                 [int] NOT NULL,
		[PID_INDICED]               [int] IDENTITY(1, 1) NOT NULL,
		[MA_CODIGO]                 [int] NOT NULL,
		[PID_NOPARTE]               [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PID_NOMBRE]                [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PID_NAME]                  [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PID_COS_UNI]               [decimal](38, 6) NOT NULL,
		[PID_COS_UNIADU]            [decimal](38, 6) NULL,
		[PID_COS_UNIGEN]            [decimal](38, 6) NOT NULL,
		[PID_COS_UNIVA]             [decimal](38, 6) NOT NULL,
		[PID_COS_UNIMATGRA]         [decimal](38, 6) NOT NULL,
		[PID_CANT]                  [decimal](38, 6) NOT NULL,
		[PID_CAN_AR]                [decimal](28, 14) NOT NULL,
		[PID_CAN_GEN]               [decimal](38, 6) NOT NULL,
		[PID_VAL_ADU]               [decimal](38, 6) NOT NULL,
		[PID_CTOT_DLS]              [decimal](38, 6) NOT NULL,
		[ME_CODIGO]                 [int] NULL,
		[ME_GENERICO]               [int] NULL,
		[MA_GENERICO]               [int] NOT NULL,
		[EQ_GENERICO]               [decimal](28, 14) NOT NULL,
		[EQ_IMPMX]                  [decimal](28, 14) NOT NULL,
		[AR_IMPMX]                  [int] NOT NULL,
		[ME_ARIMPMX]                [int] NULL,
		[AR_EXPFO]                  [int] NOT NULL,
		[PID_RATEEXPFO]             [decimal](38, 6) NULL,
		[PID_SEC_IMP]               [smallint] NULL,
		[PID_DEF_TIP]               [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PID_POR_DEF]               [decimal](38, 6) NOT NULL,
		[CS_CODIGO]                 [smallint] NULL,
		[PID_SALDOGEN]              [decimal](38, 6) NULL,
		[TI_CODIGO]                 [smallint] NOT NULL,
		[PA_ORIGEN]                 [int] NULL,
		[PA_PROCEDE]                [int] NULL,
		[SPI_CODIGO]                [smallint] NULL,
		[PR_CODIGO]                 [int] NULL,
		[PID_IMPRIMIR]              [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PID_GENERA_EMP]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PID_CANT_DESP]             [decimal](38, 6) NULL,
		[PID_DESCARGABLE]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PID_MA_CODIGOPADREKIT]     [int] NULL,
		[PID_REGIONFIN]             [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[SE_CODIGO]                 [int] NULL,
		[PID_PAGACONTRIB]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PID_NOPARTEAUX]            [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PID_ORD_COMP]              [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PID_CODIGOFACT]            [int] NULL,
		[PID_INDICEDORIG]           [int] NULL,
		[PID_CTOT_MN]               [decimal](38, 6) NULL,
		[PID_GENERA_EMPDET]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PID_PES_UNIKG]             [decimal](38, 6) NULL,
		[PID_SERVICIO]              [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PG_CODIGO]                 [smallint] NULL,
		[PID_SECUENCIA]             [int] NULL,
		CONSTRAINT [IX_TempPedImpDet]
		UNIQUE
		NONCLUSTERED
		([PID_INDICED])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempPedImpDet]
	ADD
	CONSTRAINT [DF_TempPedImpDet_AR_EXPFO]
	DEFAULT (0) FOR [AR_EXPFO]
GO
ALTER TABLE [dbo].[TempPedImpDet]
	ADD
	CONSTRAINT [DF_TempPedImpDet_AR_IMPMX]
	DEFAULT (0) FOR [AR_IMPMX]
GO
ALTER TABLE [dbo].[TempPedImpDet]
	ADD
	CONSTRAINT [DF_TempPedImpDet_EQ_GENERICO]
	DEFAULT (1) FOR [EQ_GENERICO]
GO
ALTER TABLE [dbo].[TempPedImpDet]
	ADD
	CONSTRAINT [DF_TempPedImpDet_EQ_IMPMX]
	DEFAULT (1) FOR [EQ_IMPMX]
GO
ALTER TABLE [dbo].[TempPedImpDet]
	ADD
	CONSTRAINT [DF_TempPedImpDet_MA_GENERICO]
	DEFAULT (0) FOR [MA_GENERICO]
GO
ALTER TABLE [dbo].[TempPedImpDet]
	ADD
	CONSTRAINT [DF_TempPedImpDet_PID_CAN_AR]
	DEFAULT (0) FOR [PID_CAN_AR]
GO
ALTER TABLE [dbo].[TempPedImpDet]
	ADD
	CONSTRAINT [DF_TempPedImpDet_PID_CAN_GEN]
	DEFAULT (0) FOR [PID_CAN_GEN]
GO
ALTER TABLE [dbo].[TempPedImpDet]
	ADD
	CONSTRAINT [DF_TempPedImpDet_PID_CANT]
	DEFAULT (0) FOR [PID_CANT]
GO
ALTER TABLE [dbo].[TempPedImpDet]
	ADD
	CONSTRAINT [DF_TempPedImpDet_PID_COS_UNI]
	DEFAULT (0) FOR [PID_COS_UNI]
GO
ALTER TABLE [dbo].[TempPedImpDet]
	ADD
	CONSTRAINT [DF_TempPedImpDet_PID_COS_UNIGEN]
	DEFAULT (0) FOR [PID_COS_UNIGEN]
GO
ALTER TABLE [dbo].[TempPedImpDet]
	ADD
	CONSTRAINT [DF_TempPedImpDet_PID_COS_UNIMATGRA]
	DEFAULT (0) FOR [PID_COS_UNIMATGRA]
GO
ALTER TABLE [dbo].[TempPedImpDet]
	ADD
	CONSTRAINT [DF_TempPedImpDet_PID_COS_UNIVA]
	DEFAULT (0) FOR [PID_COS_UNIVA]
GO
ALTER TABLE [dbo].[TempPedImpDet]
	ADD
	CONSTRAINT [DF_TempPedImpDet_PID_CTOT_DLS]
	DEFAULT (0) FOR [PID_CTOT_DLS]
GO
ALTER TABLE [dbo].[TempPedImpDet]
	ADD
	CONSTRAINT [DF_TempPedImpDet_PID_DEF_TIP]
	DEFAULT ('G') FOR [PID_DEF_TIP]
GO
ALTER TABLE [dbo].[TempPedImpDet]
	ADD
	CONSTRAINT [DF_TempPedImpDet_PID_DESCARGABLE]
	DEFAULT ('S') FOR [PID_DESCARGABLE]
GO
ALTER TABLE [dbo].[TempPedImpDet]
	ADD
	CONSTRAINT [DF_TempPedImpDet_PID_IMPRIMIR]
	DEFAULT ('S') FOR [PID_IMPRIMIR]
GO
ALTER TABLE [dbo].[TempPedImpDet]
	ADD
	CONSTRAINT [DF_TempPedImpDet_PID_NOPARTE]
	DEFAULT ('') FOR [PID_NOPARTE]
GO
ALTER TABLE [dbo].[TempPedImpDet]
	ADD
	CONSTRAINT [DF_TempPedImpDet_PID_PAGACONTRIB]
	DEFAULT ('S') FOR [PID_PAGACONTRIB]
GO
ALTER TABLE [dbo].[TempPedImpDet]
	ADD
	CONSTRAINT [DF_TempPedImpDet_PID_POR_DEF]
	DEFAULT (0) FOR [PID_POR_DEF]
GO
ALTER TABLE [dbo].[TempPedImpDet]
	ADD
	CONSTRAINT [DF_TempPedImpDet_PID_REGIONFIN]
	DEFAULT ('F') FOR [PID_REGIONFIN]
GO
ALTER TABLE [dbo].[TempPedImpDet]
	ADD
	CONSTRAINT [DF_TempPedImpDet_PID_VAL_ADU]
	DEFAULT (0) FOR [PID_VAL_ADU]
GO
ALTER TABLE [dbo].[TempPedImpDet] SET (LOCK_ESCALATION = TABLE)
GO
