SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[VERSIONFECHAACT] (
		[FECHAACT]     [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VERSIONFECHAACT] SET (LOCK_ESCALATION = TABLE)
GO
