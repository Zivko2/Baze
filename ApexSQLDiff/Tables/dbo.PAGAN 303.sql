SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PAGAN 303] (
		[PID_INDICED]         [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PI_FOLIO]            [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PID_NOPARTE]         [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PID_NOMBRE]          [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PID_PAGACONTRIB]     [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CP_CLAVE]            [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PID_POR_DEF]         [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PID_DEF_TIP]         [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PA_CORTO]            [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Col010]              [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Col011]              [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Col012]              [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PAGAN 303] SET (LOCK_ESCALATION = TABLE)
GO
