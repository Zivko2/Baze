SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[XpoStartWorkflowRequest] (
		[Oid]                        [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[TargetWorkflowUniqueId]     [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[TargetObjectKey]            [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[TargetObjectType]           [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]        [int] NULL,
		[GCRecord]                   [int] NULL,
		CONSTRAINT [PK_XpoStartWorkflowRequest]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_XpoStartWorkflowRequest]
	ON [dbo].[XpoStartWorkflowRequest] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[XpoStartWorkflowRequest] SET (LOCK_ESCALATION = TABLE)
GO
