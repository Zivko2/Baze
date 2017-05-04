SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ChecklistItem] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[ChecklistItemType]       [uniqueidentifier] NULL,
		[ProcessedOn]             [datetime] NULL,
		[ProcessedBy]             [uniqueidentifier] NULL,
		[Batch]                   [uniqueidentifier] NULL,
		[BatchLineItem]           [uniqueidentifier] NULL,
		[Yes]                     [bit] NULL,
		[No]                      [bit] NULL,
		[Note]                    [nvarchar](1000) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_ChecklistItem]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChecklistItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_ChecklistItem_Batch]
	FOREIGN KEY ([Batch]) REFERENCES [dbo].[Batch] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[ChecklistItem]
	CHECK CONSTRAINT [FK_ChecklistItem_Batch]

GO
ALTER TABLE [dbo].[ChecklistItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_ChecklistItem_BatchLineItem]
	FOREIGN KEY ([BatchLineItem]) REFERENCES [dbo].[BatchLineItem] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[ChecklistItem]
	CHECK CONSTRAINT [FK_ChecklistItem_BatchLineItem]

GO
ALTER TABLE [dbo].[ChecklistItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_ChecklistItem_ChecklistItemType]
	FOREIGN KEY ([ChecklistItemType]) REFERENCES [dbo].[ChecklistItemType] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[ChecklistItem]
	CHECK CONSTRAINT [FK_ChecklistItem_ChecklistItemType]

GO
ALTER TABLE [dbo].[ChecklistItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_ChecklistItem_ProcessedBy]
	FOREIGN KEY ([ProcessedBy]) REFERENCES [dbo].[ExtendedSecurityUser] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[ChecklistItem]
	CHECK CONSTRAINT [FK_ChecklistItem_ProcessedBy]

GO
CREATE NONCLUSTERED INDEX [iBatch_ChecklistItem]
	ON [dbo].[ChecklistItem] ([Batch])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iBatchLineItem_ChecklistItem]
	ON [dbo].[ChecklistItem] ([BatchLineItem])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iChecklistItemType_ChecklistItem]
	ON [dbo].[ChecklistItem] ([ChecklistItemType])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_ChecklistItem]
	ON [dbo].[ChecklistItem] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iProcessedBy_ChecklistItem]
	ON [dbo].[ChecklistItem] ([ProcessedBy])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChecklistItem] SET (LOCK_ESCALATION = TABLE)
GO
