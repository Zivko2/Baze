SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ADMLOCAL] (
		[ADL_IDADMON]       [smallint] IDENTITY(1, 1) NOT NULL,
		[ADL_TEXTADMON]     [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		CONSTRAINT [IX_ADMLOCAL]
		UNIQUE
		NONCLUSTERED
		([ADL_IDADMON])
		WITH FILLFACTOR=90
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ADMLOCAL]
	ADD
	CONSTRAINT [PK_ADMLOCAL]
	PRIMARY KEY
	NONCLUSTERED
	([ADL_TEXTADMON])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[ADMLOCAL] SET (LOCK_ESCALATION = TABLE)
GO
