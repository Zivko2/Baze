SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[sysusrlog50000Hist] (
		[sysusrlog_id]     [int] NOT NULL,
		[user_id]          [smallint] NOT NULL,
		[mov_id]           [smallint] NOT NULL,
		[referencia]       [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[frmtag]           [smallint] NOT NULL,
		[fechahora]        [datetime] NOT NULL,
		CONSTRAINT [IX_sysusrlog50000Hist]
		UNIQUE
		NONCLUSTERED
		([sysusrlog_id])
		WITH FILLFACTOR=90
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[sysusrlog50000Hist] SET (LOCK_ESCALATION = TABLE)
GO
