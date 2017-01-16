SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ERRORCAMPDESC] (
		[ERR_TIPOREGISTRO]     [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ERR_CAMPO]            [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ERR_DESCRIPCION]      [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ERR_CAMPOTIPO]        [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ERR_CAMPOSIZE]        [int] NULL,
		[ERR_CAMPODEC]         [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ERRORCAMPDESC]
	ADD
	CONSTRAINT [PK_ERRORCAMPDESC]
	PRIMARY KEY
	NONCLUSTERED
	([ERR_TIPOREGISTRO], [ERR_CAMPO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[ERRORCAMPDESC] SET (LOCK_ESCALATION = TABLE)
GO
