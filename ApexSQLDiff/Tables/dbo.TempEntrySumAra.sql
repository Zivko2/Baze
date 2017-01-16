SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TempEntrySumAra] (
		[ETA_CODIGO]           [int] IDENTITY(1, 1) NOT NULL,
		[ET_CODIGO]            [int] NOT NULL,
		[FE_CODIGO]            [int] NOT NULL,
		[AR_CODIGO]            [int] NULL,
		[ETA_TIPOIMPUESTO]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ETD_LINE]             [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ETA_RATE]             [decimal](38, 6) NOT NULL,
		[MA_NAFTA]             [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ETA_ADV_CDVCASE]      [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ETA_CHGS]             [int] NOT NULL,
		[ETA_ADV_CDVRATE]      [decimal](38, 6) NOT NULL,
		[ETA_RELATIONSHIP]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ETA_CANT]             [decimal](38, 6) NOT NULL,
		[ETA_CANTAR]           [decimal](38, 6) NULL,
		[ETA_GRAV_VA]          [decimal](38, 6) NOT NULL,
		[ETA_GRAV_MAT]         [decimal](38, 6) NOT NULL,
		[ETA_NG_MAT]           [decimal](38, 6) NOT NULL,
		[ETA_NG_EMP]           [decimal](38, 6) NOT NULL,
		[ETA_NG_VA]            [decimal](38, 6) NOT NULL,
		[ETA_COS_TOT]          [int] NOT NULL,
		[ETA_IRC]              [decimal](38, 6) NOT NULL,
		[ETA_VISA]             [decimal](38, 6) NOT NULL,
		[ETA_DLLS_IRC]         [decimal](38, 6) NOT NULL,
		[ETA_DLLS_VISA]        [decimal](38, 6) NOT NULL,
		[ETA_WMPF]             [int] NOT NULL,
		[ETA_WOMPF]            [int] NOT NULL,
		[ETA_MPF]              [decimal](38, 6) NOT NULL,
		[ETA_DLLS_MPF]         [decimal](38, 6) NOT NULL,
		[ETA_DLLS_RATE]        [decimal](38, 6) NOT NULL,
		[SPI_CODIGO]           [smallint] NULL,
		[ME_CODIGO]            [int] NULL,
		[PA_CODIGO]            [int] NULL,
		[ETA_PESO]             [decimal](38, 6) NULL,
		[AR_ORIG]              [int] NULL,
		[ETA_NAME]             [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AR_NG_EMP]            [int] NULL,
		[ETA_RETRABAJO]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CFT_TIPO]             [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_TempEntrySumAra]
		UNIQUE
		NONCLUSTERED
		([ETA_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempEntrySumAra]
	ADD
	CONSTRAINT [DF_TempEntrySumAra_ETA_ADV_CDVCASE]
	DEFAULT ('') FOR [ETA_ADV_CDVCASE]
GO
ALTER TABLE [dbo].[TempEntrySumAra]
	ADD
	CONSTRAINT [DF_TempEntrySumAra_ETA_ADV_CDVRATE]
	DEFAULT (0) FOR [ETA_ADV_CDVRATE]
GO
ALTER TABLE [dbo].[TempEntrySumAra]
	ADD
	CONSTRAINT [DF_TempEntrySumAra_ETA_CANT]
	DEFAULT (0) FOR [ETA_CANT]
GO
ALTER TABLE [dbo].[TempEntrySumAra]
	ADD
	CONSTRAINT [DF_TempEntrySumAra_ETA_CHGS]
	DEFAULT (0) FOR [ETA_CHGS]
GO
ALTER TABLE [dbo].[TempEntrySumAra]
	ADD
	CONSTRAINT [DF_TempEntrySumAra_ETA_COS_TOT]
	DEFAULT (0) FOR [ETA_COS_TOT]
GO
ALTER TABLE [dbo].[TempEntrySumAra]
	ADD
	CONSTRAINT [DF_TempEntrySumAra_ETA_DLLS_IRC]
	DEFAULT (0) FOR [ETA_DLLS_IRC]
GO
ALTER TABLE [dbo].[TempEntrySumAra]
	ADD
	CONSTRAINT [DF_TempEntrySumAra_ETA_DLLS_MPF]
	DEFAULT (0) FOR [ETA_DLLS_MPF]
GO
ALTER TABLE [dbo].[TempEntrySumAra]
	ADD
	CONSTRAINT [DF_TempEntrySumAra_ETA_DLLS_RATE]
	DEFAULT (0) FOR [ETA_DLLS_RATE]
GO
ALTER TABLE [dbo].[TempEntrySumAra]
	ADD
	CONSTRAINT [DF_TempEntrySumAra_ETA_DLLS_VISA]
	DEFAULT (0) FOR [ETA_DLLS_VISA]
GO
ALTER TABLE [dbo].[TempEntrySumAra]
	ADD
	CONSTRAINT [DF_TempEntrySumAra_ETA_GRAV_MAT]
	DEFAULT (0) FOR [ETA_GRAV_MAT]
GO
ALTER TABLE [dbo].[TempEntrySumAra]
	ADD
	CONSTRAINT [DF_TempEntrySumAra_ETA_GRAV_VA]
	DEFAULT (0) FOR [ETA_GRAV_VA]
GO
ALTER TABLE [dbo].[TempEntrySumAra]
	ADD
	CONSTRAINT [DF_TempEntrySumAra_ETA_IRC]
	DEFAULT (0) FOR [ETA_IRC]
GO
ALTER TABLE [dbo].[TempEntrySumAra]
	ADD
	CONSTRAINT [DF_TempEntrySumAra_ETA_MPF]
	DEFAULT (0) FOR [ETA_MPF]
GO
ALTER TABLE [dbo].[TempEntrySumAra]
	ADD
	CONSTRAINT [DF_TempEntrySumAra_ETA_NG_EMP]
	DEFAULT (0) FOR [ETA_NG_EMP]
GO
ALTER TABLE [dbo].[TempEntrySumAra]
	ADD
	CONSTRAINT [DF_TempEntrySumAra_ETA_NG_MAT]
	DEFAULT (0) FOR [ETA_NG_MAT]
GO
ALTER TABLE [dbo].[TempEntrySumAra]
	ADD
	CONSTRAINT [DF_TempEntrySumAra_ETA_NG_VA]
	DEFAULT (0) FOR [ETA_NG_VA]
GO
ALTER TABLE [dbo].[TempEntrySumAra]
	ADD
	CONSTRAINT [DF_TempEntrySumAra_ETA_RATE]
	DEFAULT (0) FOR [ETA_RATE]
GO
ALTER TABLE [dbo].[TempEntrySumAra]
	ADD
	CONSTRAINT [DF_TempEntrySumAra_ETA_RELATIONSHIP]
	DEFAULT ('N') FOR [ETA_RELATIONSHIP]
GO
ALTER TABLE [dbo].[TempEntrySumAra]
	ADD
	CONSTRAINT [DF_TempEntrySumAra_ETA_VISA]
	DEFAULT (0) FOR [ETA_VISA]
GO
ALTER TABLE [dbo].[TempEntrySumAra]
	ADD
	CONSTRAINT [DF_TempEntrySumAra_ETA_WMPF]
	DEFAULT (0) FOR [ETA_WMPF]
GO
ALTER TABLE [dbo].[TempEntrySumAra]
	ADD
	CONSTRAINT [DF_TempEntrySumAra_ETA_WOMPF]
	DEFAULT (0) FOR [ETA_WOMPF]
GO
ALTER TABLE [dbo].[TempEntrySumAra]
	ADD
	CONSTRAINT [DF_TempEntrySumAra_ETD_LINE]
	DEFAULT ('') FOR [ETD_LINE]
GO
ALTER TABLE [dbo].[TempEntrySumAra]
	ADD
	CONSTRAINT [DF_TempEntrySumAra_MA_NAFTA]
	DEFAULT ('N') FOR [MA_NAFTA]
GO
ALTER TABLE [dbo].[TempEntrySumAra] SET (LOCK_ESCALATION = TABLE)
GO
