SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PurchaseOrderLineItem] (
		[Oid]                                 [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[PurchaseOrder]                       [uniqueidentifier] NULL,
		[LineNumber]                          [int] NULL,
		[Item]                                [uniqueidentifier] NULL,
		[Inventory]                           [uniqueidentifier] NULL,
		[UnitPrice]                           [money] NULL,
		[RepairQuoteAmount]                   [money] NULL,
		[UnitPriceInBaseCurrency]             [money] NULL,
		[QuantityOrderedDecimalValue]         [decimal](19, 5) NULL,
		[QuantityOrderedStringValue]          [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[QuantityReceivedDecimalValue]        [decimal](19, 5) NULL,
		[QuantityReceivedStringValue]         [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[QuantityUnfulfilledDecimalValue]     [decimal](19, 5) NULL,
		[QuantityUnfulfilledStringValue]      [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Note]                                [nvarchar](1000) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]                 [int] NULL,
		[GCRecord]                            [int] NULL,
		CONSTRAINT [PK_PurchaseOrderLineItem]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PurchaseOrderLineItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_PurchaseOrderLineItem_Inventory]
	FOREIGN KEY ([Inventory]) REFERENCES [dbo].[Inventory] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[PurchaseOrderLineItem]
	CHECK CONSTRAINT [FK_PurchaseOrderLineItem_Inventory]

GO
ALTER TABLE [dbo].[PurchaseOrderLineItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_PurchaseOrderLineItem_Item]
	FOREIGN KEY ([Item]) REFERENCES [dbo].[Item] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[PurchaseOrderLineItem]
	CHECK CONSTRAINT [FK_PurchaseOrderLineItem_Item]

GO
ALTER TABLE [dbo].[PurchaseOrderLineItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_PurchaseOrderLineItem_PurchaseOrder]
	FOREIGN KEY ([PurchaseOrder]) REFERENCES [dbo].[PurchaseOrder] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[PurchaseOrderLineItem]
	CHECK CONSTRAINT [FK_PurchaseOrderLineItem_PurchaseOrder]

GO
CREATE NONCLUSTERED INDEX [iGCRecord_PurchaseOrderLineItem]
	ON [dbo].[PurchaseOrderLineItem] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iInventory_PurchaseOrderLineItem]
	ON [dbo].[PurchaseOrderLineItem] ([Inventory])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iItem_PurchaseOrderLineItem]
	ON [dbo].[PurchaseOrderLineItem] ([Item])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iPurchaseOrder_PurchaseOrderLineItem]
	ON [dbo].[PurchaseOrderLineItem] ([PurchaseOrder])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iQuantityReceivedDecimalValueQuantityReceivedStringValueQuantityUnfulfilledDecimalValueQuantityUnfulfilledStringValueQu_0860992F]
	ON [dbo].[PurchaseOrderLineItem] ([QuantityReceivedDecimalValue], [QuantityReceivedStringValue], [QuantityUnfulfilledDecimalValue], [QuantityUnfulfilledStringValue], [QuantityOrderedDecimalValue], [QuantityOrderedStringValue])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[PurchaseOrderLineItem] SET (LOCK_ESCALATION = TABLE)
GO
