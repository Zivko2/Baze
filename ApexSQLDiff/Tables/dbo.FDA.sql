SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FDA] (
		[FDA_CODIGO]     [smallint] IDENTITY(1, 1) NOT NULL,
		[FDA_CLAVE]      [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FDA_DESC]       [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_FDA]
		UNIQUE
		NONCLUSTERED
		([FDA_CODIGO])
		WITH FILLFACTOR=90
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FDA]
	ADD
	CONSTRAINT [PK_FDA]
	PRIMARY KEY
	NONCLUSTERED
	([FDA_CLAVE])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[FDA] SET (LOCK_ESCALATION = TABLE)
GO
