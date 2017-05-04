SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Task] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[Subject]                 [nvarchar](200) COLLATE Latin1_General_CI_AS NULL,
		[AssignedTo]              [uniqueidentifier] NULL,
		[OriginatedBy]            [uniqueidentifier] NULL,
		[TaskPriority]            [int] NULL,
		[TaskType]                [int] NULL,
		[UpdatedOn]               [datetime] NULL,
		[CreatedOn]               [datetime] NULL,
		[ClosedOn]                [datetime] NULL,
		[ViewedOn]                [datetime] NULL,
		[DeferredUntil]           [datetime] NULL,
		[NoteHistory]             [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
		[CreatedByWorkflow]       [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		[ObjectType]              [int] NULL,
		CONSTRAINT [PK_Task]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Task]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Task_AssignedTo]
	FOREIGN KEY ([AssignedTo]) REFERENCES [dbo].[ExtendedSecurityUser] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Task]
	CHECK CONSTRAINT [FK_Task_AssignedTo]

GO
ALTER TABLE [dbo].[Task]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Task_ObjectType]
	FOREIGN KEY ([ObjectType]) REFERENCES [dbo].[XPObjectType] ([OID])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Task]
	CHECK CONSTRAINT [FK_Task_ObjectType]

GO
ALTER TABLE [dbo].[Task]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Task_OriginatedBy]
	FOREIGN KEY ([OriginatedBy]) REFERENCES [dbo].[ExtendedSecurityUser] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Task]
	CHECK CONSTRAINT [FK_Task_OriginatedBy]

GO
CREATE NONCLUSTERED INDEX [iAssignedTo_Task]
	ON [dbo].[Task] ([AssignedTo])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_Task]
	ON [dbo].[Task] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iObjectType_Task]
	ON [dbo].[Task] ([ObjectType])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iOriginatedBy_Task]
	ON [dbo].[Task] ([OriginatedBy])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Task] SET (LOCK_ESCALATION = TABLE)
GO
