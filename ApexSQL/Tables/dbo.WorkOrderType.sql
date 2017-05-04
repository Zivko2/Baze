SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[WorkOrderType] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[Description]             [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_WorkOrderType]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_WorkOrderType]
	ON [dbo].[WorkOrderType] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkOrderType] SET (LOCK_ESCALATION = TABLE)
GO
