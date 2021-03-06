SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DECANUALNVADET] (
		[DAN_CODIGO]           [int] NOT NULL,
		[DAND_INDICED]         [int] IDENTITY(1, 1) NOT NULL,
		[MA_GENERICO]          [int] NOT NULL,
		[DAND_NOMBRE]          [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[SE_CODIGO]            [smallint] NOT NULL,
		[AR_CODIGO]            [int] NOT NULL,
		[ME_AR]                [smallint] NOT NULL,
		[DAND_TOTALBIENES]     [decimal](38, 6) NOT NULL,
		[DAND_MDONAC]          [decimal](38, 6) NOT NULL,
		[DAND_EXPORT]          [decimal](38, 6) NOT NULL,
		CONSTRAINT [IX_DECANUALNVADET]
		UNIQUE
		NONCLUSTERED
		([DAND_INDICED])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DECANUALNVADET]
	ADD
	CONSTRAINT [PK_DECANUALNVADET]
	PRIMARY KEY
	NONCLUSTERED
	([DAN_CODIGO], [DAND_INDICED])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[DECANUALNVADET]
	ADD
	CONSTRAINT [DF_DECANUALNVADET_AR_CODIGO]
	DEFAULT (0) FOR [AR_CODIGO]
GO
ALTER TABLE [dbo].[DECANUALNVADET]
	ADD
	CONSTRAINT [DF_DECANUALNVADET_DAND_EXPORT]
	DEFAULT (0) FOR [DAND_EXPORT]
GO
ALTER TABLE [dbo].[DECANUALNVADET]
	ADD
	CONSTRAINT [DF_DECANUALNVADET_DAND_MDONAC]
	DEFAULT (0) FOR [DAND_MDONAC]
GO
ALTER TABLE [dbo].[DECANUALNVADET]
	ADD
	CONSTRAINT [DF_DECANUALNVADET_DAND_NOMBRE]
	DEFAULT ('') FOR [DAND_NOMBRE]
GO
ALTER TABLE [dbo].[DECANUALNVADET]
	ADD
	CONSTRAINT [DF_DECANUALNVADET_DAND_TOTALBIENES]
	DEFAULT (0) FOR [DAND_TOTALBIENES]
GO
ALTER TABLE [dbo].[DECANUALNVADET]
	ADD
	CONSTRAINT [DF_DECANUALNVADET_ME_AR]
	DEFAULT (0) FOR [ME_AR]
GO
ALTER TABLE [dbo].[DECANUALNVADET]
	ADD
	CONSTRAINT [DF_DECANUALNVADET_SE_CODIGO]
	DEFAULT (0) FOR [SE_CODIGO]
GO
