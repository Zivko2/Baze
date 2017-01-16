SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RELTFACTCLAPED] (
		[TF_CODIGO]     [smallint] NOT NULL,
		[CP_CODIGO]     [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RELTFACTCLAPED]
	ADD
	CONSTRAINT [PK_RELTFACTCLAPED]
	PRIMARY KEY
	NONCLUSTERED
	([TF_CODIGO], [CP_CODIGO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[RELTFACTCLAPED] SET (LOCK_ESCALATION = TABLE)
GO
