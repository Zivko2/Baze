SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[KpiHistoryItem] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[KpiInstance]             [uniqueidentifier] NULL,
		[RangeStart]              [datetime] NULL,
		[RangeEnd]                [datetime] NULL,
		[Value]                   [float] NULL,
		[OptimisticLockField]     [int] NULL,
		CONSTRAINT [PK_KpiHistoryItem]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KpiHistoryItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_KpiHistoryItem_KpiInstance]
	FOREIGN KEY ([KpiInstance]) REFERENCES [dbo].[KpiInstance] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[KpiHistoryItem]
	CHECK CONSTRAINT [FK_KpiHistoryItem_KpiInstance]

GO
CREATE NONCLUSTERED INDEX [iKpiInstance_KpiHistoryItem]
	ON [dbo].[KpiHistoryItem] ([KpiInstance])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[KpiHistoryItem] SET (LOCK_ESCALATION = TABLE)
GO
