SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[REGISTROSSQL] (
		[RS_RegistrosSQLID]     [int] IDENTITY(1, 1) NOT NULL,
		[RS_SQL]                [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[RS_Fecha]              [datetime] NULL,
		[RS_Usuario]            [int] NULL,
		[RS_Estatus]            [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_REGISTROSSQL]
		UNIQUE
		NONCLUSTERED
		([RS_RegistrosSQLID])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[REGISTROSSQL] SET (LOCK_ESCALATION = TABLE)
GO
