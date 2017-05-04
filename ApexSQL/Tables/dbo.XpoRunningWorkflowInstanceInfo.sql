SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[XpoRunningWorkflowInstanceInfo] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[WorkflowName]            [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
		[WorkflowUniqueId]        [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
		[TargetObjectHandle]      [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
		[ActivityInstanceId]      [uniqueidentifier] NULL,
		[State]                   [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_XpoRunningWorkflowInstanceInfo]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_XpoRunningWorkflowInstanceInfo]
	ON [dbo].[XpoRunningWorkflowInstanceInfo] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[XpoRunningWorkflowInstanceInfo] SET (LOCK_ESCALATION = TABLE)
GO
