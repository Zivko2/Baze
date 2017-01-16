SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[REQUISICIONDET] (
		[REQD_INDICED]           [int] NOT NULL,
		[REQ_CODIGO]             [int] NOT NULL,
		[REQD_CANT_ST]           [decimal](38, 6) NULL,
		[REQD_COS_UNI]           [decimal](38, 6) NULL,
		[REQD_COS_TOT]           [decimal](38, 6) NULL,
		[REQD_NOMBRE]            [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[REQD_NAME]              [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[REQD_NOPARTE]           [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[REQD_SALDO]             [decimal](38, 6) NULL,
		[REQD_ENUSO]             [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[REQD_ENVIO]             [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[REQD_FEC_EST]           [smalldatetime] NULL,
		[REQD_FECHA]             [smalldatetime] NULL,
		[MA_CODIGO]              [int] NULL,
		[ME_CODIGO]              [int] NULL,
		[TI_CODIGO]              [int] NOT NULL,
		[MA_EMPAQUE]             [int] NULL,
		[REQD_CANTEMP]           [decimal](38, 6) NULL,
		[TCO_CODIGO]             [smallint] NULL,
		[REQD_OBSERVA]           [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[REQD_REQUISICION]       [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[REQD_FEC_REQUERIDA]     [datetime] NULL,
		[REQD_FEC_ARRIBO]        [datetime] NULL,
		[REQD_FEC_ENV]           [datetime] NULL,
		[PR_CODIGO]              [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[REQUISICIONDET]
	ADD
	CONSTRAINT [PK_REQUISICIONDET]
	PRIMARY KEY
	NONCLUSTERED
	([REQD_INDICED])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[REQUISICIONDET]
	ADD
	CONSTRAINT [DF_REQUISICIONDET_REQD_ENUSO]
	DEFAULT ('N') FOR [REQD_ENUSO]
GO
ALTER TABLE [dbo].[REQUISICIONDET]
	ADD
	CONSTRAINT [DF_REQUISICIONDET_REQD_NOPARTE]
	DEFAULT ('') FOR [REQD_NOPARTE]
GO
ALTER TABLE [dbo].[REQUISICIONDET] SET (LOCK_ESCALATION = TABLE)
GO
