SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Inventory] (
		[Oid]                              [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[ReleaseNoteLegacy]                [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Item]                             [uniqueidentifier] NULL,
		[SerialNumber]                     [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[QuantityDecimalValue]             [decimal](19, 5) NULL,
		[QuantityStringValue]              [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[BatchLineItem]                    [uniqueidentifier] NULL,
		[PurchaseOrderLineItem]            [uniqueidentifier] NULL,
		[ReceivedTotalCost]                [money] NULL,
		[InventoryLocation]                [uniqueidentifier] NULL,
		[ReceivedQuantityDecimalValue]     [decimal](19, 5) NULL,
		[ReceivedQuantityStringValue]      [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[ExpiresOn]                        [datetime] NULL,
		[UsedItem]                         [bit] NULL,
		[ReceivedOn]                       [datetime] NULL,
		[Note]                             [nvarchar](1000) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]              [int] NULL,
		[GCRecord]                         [int] NULL,
		CONSTRAINT [PK_Inventory]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Inventory]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Inventory_BatchLineItem]
	FOREIGN KEY ([BatchLineItem]) REFERENCES [dbo].[BatchLineItem] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Inventory]
	CHECK CONSTRAINT [FK_Inventory_BatchLineItem]

GO
ALTER TABLE [dbo].[Inventory]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Inventory_InventoryLocation]
	FOREIGN KEY ([InventoryLocation]) REFERENCES [dbo].[InventoryLocation] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Inventory]
	CHECK CONSTRAINT [FK_Inventory_InventoryLocation]

GO
ALTER TABLE [dbo].[Inventory]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Inventory_Item]
	FOREIGN KEY ([Item]) REFERENCES [dbo].[Item] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Inventory]
	CHECK CONSTRAINT [FK_Inventory_Item]

GO
ALTER TABLE [dbo].[Inventory]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Inventory_PurchaseOrderLineItem]
	FOREIGN KEY ([PurchaseOrderLineItem]) REFERENCES [dbo].[PurchaseOrderLineItem] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Inventory]
	CHECK CONSTRAINT [FK_Inventory_PurchaseOrderLineItem]

GO
CREATE NONCLUSTERED INDEX [iBatchLineItem_Inventory]
	ON [dbo].[Inventory] ([BatchLineItem])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_Inventory]
	ON [dbo].[Inventory] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iInventoryLocation_Inventory]
	ON [dbo].[Inventory] ([InventoryLocation])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iItem_Inventory]
	ON [dbo].[Inventory] ([Item])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iPurchaseOrderLineItem_Inventory]
	ON [dbo].[Inventory] ([PurchaseOrderLineItem])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iQuantityDecimalValueQuantityStringValue_Inventory]
	ON [dbo].[Inventory] ([QuantityDecimalValue], [QuantityStringValue])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Inventory] SET (LOCK_ESCALATION = TABLE)
GO
