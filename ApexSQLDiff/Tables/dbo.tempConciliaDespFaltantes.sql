SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tempConciliaDespFaltantes] (
		[MA_NOPARTE]        [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PI_CODIGO]         [int] NULL,
		[PATENTE_FOLIO]     [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MA_CODIGO]         [int] NULL,
		[PI_FEC_ENT]        [datetime] NULL,
		[SALDOGEN]          [decimal](38, 6) NULL,
		[TIPO]              [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tempConciliaDespFaltantes] SET (LOCK_ESCALATION = TABLE)
GO
