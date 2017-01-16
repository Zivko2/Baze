SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[pidescarga_AntesDeCambioTemporalidadAl20110309] (
		[PI_CODIGO]               [int] NOT NULL,
		[PID_INDICED]             [int] NOT NULL,
		[PID_SALDOGEN]            [decimal](38, 6) NOT NULL,
		[MA_CODIGO]               [int] NULL,
		[MA_GENERICO]             [int] NULL,
		[PI_FEC_ENT]              [datetime] NULL,
		[PID_FECHAVENCE]          [datetime] NULL,
		[PI_ACTIVOFIJO]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PID_SALDOINCORRECTO]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PID_CONGELASUBMAQ]       [decimal](38, 6) NOT NULL,
		[PI_DEFINITIVO]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PID_COS_UNIDLS]          [decimal](38, 6) NOT NULL,
		[DI_DEST_ORIGEN]          [int] NULL,
		[PID_IDDESCARGA]          [int] NULL,
		[PID_DESPERDICIO]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[pidescarga_AntesDeCambioTemporalidadAl20110309] SET (LOCK_ESCALATION = TABLE)
GO
