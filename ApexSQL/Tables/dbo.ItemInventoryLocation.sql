SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[ItemInventoryLocation] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[LineNumber]              [int] NULL,
		[Item]                    [uniqueidentifier] NULL,
		[InventoryLocation]       [uniqueidentifier] NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_ItemInventoryLocation]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ItemInventoryLocation]
	WITH NOCHECK
	ADD CONSTRAINT [FK_ItemInventoryLocation_InventoryLocation]
	FOREIGN KEY ([InventoryLocation]) REFERENCES [dbo].[InventoryLocation] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[ItemInventoryLocation]
	CHECK CONSTRAINT [FK_ItemInventoryLocation_InventoryLocation]

GO
ALTER TABLE [dbo].[ItemInventoryLocation]
	WITH NOCHECK
	ADD CONSTRAINT [FK_ItemInventoryLocation_Item]
	FOREIGN KEY ([Item]) REFERENCES [dbo].[Item] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[ItemInventoryLocation]
	CHECK CONSTRAINT [FK_ItemInventoryLocation_Item]

GO
CREATE NONCLUSTERED INDEX [iGCRecord_ItemInventoryLocation]
	ON [dbo].[ItemInventoryLocation] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iInventoryLocation_ItemInventoryLocation]
	ON [dbo].[ItemInventoryLocation] ([InventoryLocation])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iItem_ItemInventoryLocation]
	ON [dbo].[ItemInventoryLocation] ([Item])
	ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [iItemInventoryLocationGCRecord_ItemInventoryLocation]
	ON [dbo].[ItemInventoryLocation] ([Item], [InventoryLocation], [GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[ItemInventoryLocation] SET (LOCK_ESCALATION = TABLE)
GO
