SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tempConciliaDesp] (
		[CODIGO]             [int] IDENTITY(1, 1) NOT NULL,
		[PID_INDICED]        [int] NOT NULL,
		[MA_NOPARTE]         [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PI_CODIGO]          [int] NULL,
		[PATENTE_FOLIO]      [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MA_CODIGO]          [int] NULL,
		[PID_SALDOGEN]       [float] NULL,
		[PI_FEC_ENT]         [datetime] NULL,
		[pid_fechavence]     [datetime] NULL,
		[FED_SALDOGEN]       [float] NULL,
		[END_SALDOGEN]       [float] NULL,
		CONSTRAINT [IX_tempConciliaDesp]
		UNIQUE
		NONCLUSTERED
		([CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
