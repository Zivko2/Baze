SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AuditDataItemPersistent] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[UserName]                [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[ModifiedOn]              [datetime] NULL,
		[OperationType]           [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Description]             [nvarchar](2048) COLLATE Latin1_General_CI_AS NULL,
		[AuditedObject]           [uniqueidentifier] NULL,
		[OldObject]               [uniqueidentifier] NULL,
		[NewObject]               [uniqueidentifier] NULL,
		[OldValue]                [nvarchar](1024) COLLATE Latin1_General_CI_AS NULL,
		[NewValue]                [nvarchar](1024) COLLATE Latin1_General_CI_AS NULL,
		[PropertyName]            [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_AuditDataItemPersistent]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AuditDataItemPersistent]
	WITH NOCHECK
	ADD CONSTRAINT [FK_AuditDataItemPersistent_AuditedObject]
	FOREIGN KEY ([AuditedObject]) REFERENCES [dbo].[AuditedObjectWeakReferencevv] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[AuditDataItemPersistent]
	CHECK CONSTRAINT [FK_AuditDataItemPersistent_AuditedObject]

GO
ALTER TABLE [dbo].[AuditDataItemPersistent]
	WITH NOCHECK
	ADD CONSTRAINT [FK_AuditDataItemPersistent_NewObject]
	FOREIGN KEY ([NewObject]) REFERENCES [dbo].[XPWeakReference] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[AuditDataItemPersistent]
	CHECK CONSTRAINT [FK_AuditDataItemPersistent_NewObject]

GO
ALTER TABLE [dbo].[AuditDataItemPersistent]
	WITH NOCHECK
	ADD CONSTRAINT [FK_AuditDataItemPersistent_OldObject]
	FOREIGN KEY ([OldObject]) REFERENCES [dbo].[XPWeakReference] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[AuditDataItemPersistent]
	CHECK CONSTRAINT [FK_AuditDataItemPersistent_OldObject]

GO
CREATE NONCLUSTERED INDEX [iAuditedObject_AuditDataItemPersistent]
	ON [dbo].[AuditDataItemPersistent] ([AuditedObject])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_AuditDataItemPersistent]
	ON [dbo].[AuditDataItemPersistent] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iModifiedOn_AuditDataItemPersistent]
	ON [dbo].[AuditDataItemPersistent] ([ModifiedOn])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iNewObject_AuditDataItemPersistent]
	ON [dbo].[AuditDataItemPersistent] ([NewObject])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iOldObject_AuditDataItemPersistent]
	ON [dbo].[AuditDataItemPersistent] ([OldObject])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iOperationType_AuditDataItemPersistent]
	ON [dbo].[AuditDataItemPersistent] ([OperationType])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iUserName_AuditDataItemPersistent]
	ON [dbo].[AuditDataItemPersistent] ([UserName])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[AuditDataItemPersistent] SET (LOCK_ESCALATION = TABLE)
GO
