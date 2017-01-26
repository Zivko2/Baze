SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[AVISOTRASLADOSALDO] (
		[ATIS_CODIGO]           [int] IDENTITY(1, 1) NOT NULL,
		[ATID_INDICED]          [int] NOT NULL,
		[ATI_CODIGO]            [int] NOT NULL,
		[MA_CODIGO]             [int] NULL,
		[MA_HIJO]               [int] NULL,
		[ATIS_CANTHIJO]         [decimal](38, 6) NULL,
		[DI_INDICE]             [int] NULL,
		[ME_CODIGO]             [int] NULL,
		[ATIS_SALDODISP_PI]     [decimal](38, 6) NULL,
		[PID_INDICED]           [int] NULL,
		CONSTRAINT [IX_AVISOTRASLADOSALDO]
		UNIQUE
		NONCLUSTERED
		([ATIS_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
