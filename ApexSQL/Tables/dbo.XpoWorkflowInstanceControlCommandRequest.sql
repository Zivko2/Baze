SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[XpoWorkflowInstanceControlCommandRequest] (
		[Oid]                          [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[TargetWorkflowUniqueId]       [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[TargetActivityInstanceId]     [uniqueidentifier] NULL,
		[Command]                      [int] NULL,
		[CreatedOn]                    [datetime] NULL,
		[Result]                       [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]          [int] NULL,
		[GCRecord]                     [int] NULL,
		CONSTRAINT [PK_XpoWorkflowInstanceControlCommandRequest]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_XpoWorkflowInstanceControlCommandRequest]
	ON [dbo].[XpoWorkflowInstanceControlCommandRequest] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[XpoWorkflowInstanceControlCommandRequest] SET (LOCK_ESCALATION = TABLE)
GO
