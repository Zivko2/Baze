SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[patient] (
		[sdsd]      [int] NULL,
		[sasas]     [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT INSERT
	ON [dbo].[patient]
	TO [Zivko2]
GO
GRANT SELECT
	ON [dbo].[patient]
	TO [Zivko2]
GO
GRANT UPDATE
	ON [dbo].[patient]
	TO [Zivko2]
GO
ALTER TABLE [dbo].[patient] SET (LOCK_ESCALATION = TABLE)
GO
