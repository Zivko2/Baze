SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[XpoTrackingRecord] (
		[OID]                     [int] IDENTITY(1, 1) NOT FOR REPLICATION NOT NULL,
		[InstanceId]              [uniqueidentifier] NULL,
		[DateTime]                [datetime] NULL,
		[Data]                    [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
		[ActivityId]              [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_XpoTrackingRecord]
		PRIMARY KEY
		CLUSTERED
		([OID])
	ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_XpoTrackingRecord]
	ON [dbo].[XpoTrackingRecord] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[XpoTrackingRecord] SET (LOCK_ESCALATION = TABLE)
GO
