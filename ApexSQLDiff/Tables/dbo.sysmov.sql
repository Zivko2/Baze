SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[sysmov] (
		[sysmov_id]       [int] NOT NULL,
		[sysmov_desc]     [char](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[sysmov]
	ADD
	CONSTRAINT [PK_sysmov]
	PRIMARY KEY
	CLUSTERED
	([sysmov_desc])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[sysmov] SET (LOCK_ESCALATION = TABLE)
GO
