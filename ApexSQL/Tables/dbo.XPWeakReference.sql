SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[XPWeakReference] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[TargetType]              [int] NULL,
		[TargetKey]               [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		[ObjectType]              [int] NULL,
		CONSTRAINT [PK_XPWeakReference]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[XPWeakReference]
	WITH NOCHECK
	ADD CONSTRAINT [FK_XPWeakReference_ObjectType]
	FOREIGN KEY ([ObjectType]) REFERENCES [dbo].[XPObjectType] ([OID])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[XPWeakReference]
	CHECK CONSTRAINT [FK_XPWeakReference_ObjectType]

GO
ALTER TABLE [dbo].[XPWeakReference]
	WITH NOCHECK
	ADD CONSTRAINT [FK_XPWeakReference_TargetType]
	FOREIGN KEY ([TargetType]) REFERENCES [dbo].[XPObjectType] ([OID])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[XPWeakReference]
	CHECK CONSTRAINT [FK_XPWeakReference_TargetType]

GO
CREATE NONCLUSTERED INDEX [iGCRecord_XPWeakReference]
	ON [dbo].[XPWeakReference] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iObjectType_XPWeakReference]
	ON [dbo].[XPWeakReference] ([ObjectType])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iTargetType_XPWeakReference]
	ON [dbo].[XPWeakReference] ([TargetType])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[XPWeakReference] SET (LOCK_ESCALATION = TABLE)
GO
