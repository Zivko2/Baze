SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PERMISOPT] (
		[PE_CODIGO]             [int] NOT NULL,
		[TRA_CODIGO]            [int] NULL,
		[MA_CODIGO]             [int] NOT NULL,
		[MA_NOPARTE]            [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[AR_CODIGO]             [int] NULL,
		[ME_CODIGO]             [int] NULL,
		[PPT_VOLUMEN]           [decimal](38, 6) NULL,
		[PPT_CAPINST]           [decimal](38, 6) NULL,
		[CL_CODIGO]             [int] NULL,
		[DI_CODIGO]             [int] NULL,
		[PPT_PERIODOINI]        [datetime] NULL,
		[PPT_PERIODOFIN]        [datetime] NULL,
		[PPT_PAISES]            [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CX_CODIGO]             [smallint] NULL,
		[PPT_USOTEXTIL]         [decimal](38, 6) NULL,
		[PPT_DOCENASTEXTIL]     [decimal](38, 6) NULL,
		[PPT_M2TEXTIL]          [decimal](38, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PERMISOPT]
	ADD
	CONSTRAINT [PK_PERMISOPT]
	PRIMARY KEY
	NONCLUSTERED
	([PE_CODIGO], [MA_CODIGO])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PERMISOPT]
	ON [dbo].[PERMISOPT] ([PE_CODIGO])
	WITH ( FILLFACTOR = 90)
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[PERMISOPT] SET (LOCK_ESCALATION = TABLE)
GO
