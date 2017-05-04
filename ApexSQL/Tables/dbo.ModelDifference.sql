SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ModelDifference] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[UserId]                  [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[ContextId]               [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Version]                 [int] NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_ModelDifference]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_ModelDifference]
	ON [dbo].[ModelDifference] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[ModelDifference] SET (LOCK_ESCALATION = TABLE)
GO
