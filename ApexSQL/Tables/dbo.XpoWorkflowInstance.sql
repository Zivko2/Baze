SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[XpoWorkflowInstance] (
		[OID]                     [int] IDENTITY(1, 1) NOT FOR REPLICATION NOT NULL,
		[Owner]                   [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[InstanceId]              [uniqueidentifier] NULL,
		[Status]                  [int] NULL,
		[Content]                 [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
		[Metadata]                [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
		[ExpirationDateTime]      [datetime] NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_XpoWorkflowInstance]
		PRIMARY KEY
		CLUSTERED
		([OID])
	ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_XpoWorkflowInstance]
	ON [dbo].[XpoWorkflowInstance] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[XpoWorkflowInstance] SET (LOCK_ESCALATION = TABLE)
GO
