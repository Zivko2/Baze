SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[XpoInstanceKey] (
		[OID]                     [int] IDENTITY(1, 1) NOT FOR REPLICATION NOT NULL,
		[KeyId]                   [uniqueidentifier] NULL,
		[InstanceId]              [uniqueidentifier] NULL,
		[Properties]              [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_XpoInstanceKey]
		PRIMARY KEY
		CLUSTERED
		([OID])
	ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_XpoInstanceKey]
	ON [dbo].[XpoInstanceKey] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[XpoInstanceKey] SET (LOCK_ESCALATION = TABLE)
GO
