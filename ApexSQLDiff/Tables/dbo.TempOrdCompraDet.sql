SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TempOrdCompraDet] (
		[ORD_INDICED]             [int] IDENTITY(1, 1) NOT NULL,
		[OR_CODIGO]               [int] NOT NULL,
		[ORD_CANT_ST]             [decimal](38, 6) NULL,
		[ORD_COS_UNI]             [decimal](38, 6) NULL,
		[ORD_COS_TOT]             [decimal](38, 6) NULL,
		[ORD_NOMBRE]              [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ORD_NAME]                [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ORD_NOPARTE]             [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ORD_SALDO]               [decimal](38, 6) NULL,
		[ORD_ENUSO]               [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ORD_ENVIO]               [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ORD_FEC_EST]             [smalldatetime] NULL,
		[ORD_FECHA]               [smalldatetime] NULL,
		[MA_CODIGO]               [int] NOT NULL,
		[ME_CODIGO]               [int] NULL,
		[TI_CODIGO]               [int] NOT NULL,
		[MA_EMPAQUE]              [int] NULL,
		[ORD_CANTEMP]             [decimal](38, 6) NULL,
		[TCO_CODIGO]              [smallint] NULL,
		[ORD_OBSERVA]             [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ORD_REQUISICION]         [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ORD_FEC_REQUERIDA]       [datetime] NULL,
		[ORD_FEC_ARRIBO]          [datetime] NULL,
		[ORD_FEC_ENV]             [datetime] NULL,
		[ORD_REQD_INDICED]        [int] NULL,
		[OT_CODIGO]               [int] NULL,
		[OTD_INDICED]             [int] NULL,
		[OT_FOLIO]                [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OTD_SALDOUSAORDTRAB]     [decimal](38, 6) NULL,
		[PD_FOLIO]                [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ORD_NOPARTEPROVEE]       [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_TempOrdCompraDet]
		UNIQUE
		NONCLUSTERED
		([ORD_INDICED])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempOrdCompraDet] SET (LOCK_ESCALATION = TABLE)
GO
