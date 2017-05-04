SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BatchLineItem] (
		[Oid]                                                  [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[BatchLineItemStatus]                                  [int] NULL,
		[MarkedCompleteOn]                                     [datetime] NULL,
		[MarkedCompleteBy]                                     [uniqueidentifier] NULL,
		[MissingVendorInvoicesApprovedBy]                      [uniqueidentifier] NULL,
		[MissingVendorInvoicesRequestedBy]                     [uniqueidentifier] NULL,
		[PurchaseOrderApprovedBy]                              [uniqueidentifier] NULL,
		[PurchaseOrderRequestedBy]                             [uniqueidentifier] NULL,
		[SupervisorAssignedToApproveMissingVendorInvoices]     [uniqueidentifier] NULL,
		[SupervisorAssignedToApprovePurchaseOrder]             [uniqueidentifier] NULL,
		[BarCode]                                              [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[BatchLineItemCode]                                    [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[MissingVendorInvoicesApprovalRequestNote]             [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
		[MissingVendorInvoicesApprovalSupervisorNote]          [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
		[PurchaseOrderApprovalRequestNote]                     [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
		[PurchaseOrderApprovalSupervisorNote]                  [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
		[Batch]                                                [uniqueidentifier] NULL,
		[LineNumber]                                           [int] NULL,
		[Item]                                                 [uniqueidentifier] NULL,
		[SerialNumber]                                         [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[QuantityDecimalValue]                                 [decimal](19, 5) NULL,
		[QuantityStringValue]                                  [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[PurchaseOrder]                                        [uniqueidentifier] NULL,
		[ShippingMethod]                                       [uniqueidentifier] NULL,
		[WeightAmount]                                         [float] NULL,
		[WeightUnitOfMeasure]                                  [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[WeightBaseAmount]                                     [float] NULL,
		[VolumeAmount]                                         [float] NULL,
		[VolumeUnitOfMeasure]                                  [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[VolumeBaseAmount]                                     [float] NULL,
		[InventoryLocation]                                    [uniqueidentifier] NULL,
		[ExpiresOn]                                            [datetime] NULL,
		[UsedItem]                                             [bit] NULL,
		[ReceivedOn]                                           [datetime] NULL,
		[Inventory]                                            [uniqueidentifier] NULL,
		[PurchaseOrderLineItem]                                [uniqueidentifier] NULL,
		[SpecifyInventoryLocation]                             [bit] NULL,
		[Note]                                                 [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
		[InventoryAccount]                                     [uniqueidentifier] NULL,
		[FinancialTransferSet]                                 [uniqueidentifier] NULL,
		[OptimisticLockField]                                  [int] NULL,
		[GCRecord]                                             [int] NULL,
		CONSTRAINT [PK_BatchLineItem]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[BatchLineItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_BatchLineItem_Batch]
	FOREIGN KEY ([Batch]) REFERENCES [dbo].[Batch] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[BatchLineItem]
	CHECK CONSTRAINT [FK_BatchLineItem_Batch]

GO
ALTER TABLE [dbo].[BatchLineItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_BatchLineItem_FinancialTransferSet]
	FOREIGN KEY ([FinancialTransferSet]) REFERENCES [dbo].[FinancialTransferSet] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[BatchLineItem]
	CHECK CONSTRAINT [FK_BatchLineItem_FinancialTransferSet]

GO
ALTER TABLE [dbo].[BatchLineItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_BatchLineItem_Inventory]
	FOREIGN KEY ([Inventory]) REFERENCES [dbo].[Inventory] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[BatchLineItem]
	CHECK CONSTRAINT [FK_BatchLineItem_Inventory]

GO
ALTER TABLE [dbo].[BatchLineItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_BatchLineItem_InventoryAccount]
	FOREIGN KEY ([InventoryAccount]) REFERENCES [dbo].[InventoryAccount] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[BatchLineItem]
	CHECK CONSTRAINT [FK_BatchLineItem_InventoryAccount]

GO
ALTER TABLE [dbo].[BatchLineItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_BatchLineItem_InventoryLocation]
	FOREIGN KEY ([InventoryLocation]) REFERENCES [dbo].[InventoryLocation] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[BatchLineItem]
	CHECK CONSTRAINT [FK_BatchLineItem_InventoryLocation]

GO
ALTER TABLE [dbo].[BatchLineItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_BatchLineItem_Item]
	FOREIGN KEY ([Item]) REFERENCES [dbo].[Item] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[BatchLineItem]
	CHECK CONSTRAINT [FK_BatchLineItem_Item]

GO
ALTER TABLE [dbo].[BatchLineItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_BatchLineItem_MarkedCompleteBy]
	FOREIGN KEY ([MarkedCompleteBy]) REFERENCES [dbo].[ExtendedSecurityUser] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[BatchLineItem]
	CHECK CONSTRAINT [FK_BatchLineItem_MarkedCompleteBy]

GO
ALTER TABLE [dbo].[BatchLineItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_BatchLineItem_MissingVendorInvoicesApprovedBy]
	FOREIGN KEY ([MissingVendorInvoicesApprovedBy]) REFERENCES [dbo].[ExtendedSecurityUser] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[BatchLineItem]
	CHECK CONSTRAINT [FK_BatchLineItem_MissingVendorInvoicesApprovedBy]

GO
ALTER TABLE [dbo].[BatchLineItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_BatchLineItem_MissingVendorInvoicesRequestedBy]
	FOREIGN KEY ([MissingVendorInvoicesRequestedBy]) REFERENCES [dbo].[ExtendedSecurityUser] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[BatchLineItem]
	CHECK CONSTRAINT [FK_BatchLineItem_MissingVendorInvoicesRequestedBy]

GO
ALTER TABLE [dbo].[BatchLineItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_BatchLineItem_PurchaseOrder]
	FOREIGN KEY ([PurchaseOrder]) REFERENCES [dbo].[PurchaseOrder] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[BatchLineItem]
	CHECK CONSTRAINT [FK_BatchLineItem_PurchaseOrder]

GO
ALTER TABLE [dbo].[BatchLineItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_BatchLineItem_PurchaseOrderApprovedBy]
	FOREIGN KEY ([PurchaseOrderApprovedBy]) REFERENCES [dbo].[ExtendedSecurityUser] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[BatchLineItem]
	CHECK CONSTRAINT [FK_BatchLineItem_PurchaseOrderApprovedBy]

GO
ALTER TABLE [dbo].[BatchLineItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_BatchLineItem_PurchaseOrderLineItem]
	FOREIGN KEY ([PurchaseOrderLineItem]) REFERENCES [dbo].[PurchaseOrderLineItem] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[BatchLineItem]
	CHECK CONSTRAINT [FK_BatchLineItem_PurchaseOrderLineItem]

GO
ALTER TABLE [dbo].[BatchLineItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_BatchLineItem_PurchaseOrderRequestedBy]
	FOREIGN KEY ([PurchaseOrderRequestedBy]) REFERENCES [dbo].[ExtendedSecurityUser] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[BatchLineItem]
	CHECK CONSTRAINT [FK_BatchLineItem_PurchaseOrderRequestedBy]

GO
ALTER TABLE [dbo].[BatchLineItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_BatchLineItem_ShippingMethod]
	FOREIGN KEY ([ShippingMethod]) REFERENCES [dbo].[ShippingMethod] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[BatchLineItem]
	CHECK CONSTRAINT [FK_BatchLineItem_ShippingMethod]

GO
ALTER TABLE [dbo].[BatchLineItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_BatchLineItem_SupervisorAssignedToApproveMissingVendorInvoices]
	FOREIGN KEY ([SupervisorAssignedToApproveMissingVendorInvoices]) REFERENCES [dbo].[ExtendedSecurityUser] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[BatchLineItem]
	CHECK CONSTRAINT [FK_BatchLineItem_SupervisorAssignedToApproveMissingVendorInvoices]

GO
ALTER TABLE [dbo].[BatchLineItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_BatchLineItem_SupervisorAssignedToApprovePurchaseOrder]
	FOREIGN KEY ([SupervisorAssignedToApprovePurchaseOrder]) REFERENCES [dbo].[ExtendedSecurityUser] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[BatchLineItem]
	CHECK CONSTRAINT [FK_BatchLineItem_SupervisorAssignedToApprovePurchaseOrder]

GO
CREATE UNIQUE NONCLUSTERED INDEX [iBarCodeGCRecord_BatchLineItem]
	ON [dbo].[BatchLineItem] ([BarCode], [GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iBatch_BatchLineItem]
	ON [dbo].[BatchLineItem] ([Batch])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iFinancialTransferSet_BatchLineItem]
	ON [dbo].[BatchLineItem] ([FinancialTransferSet])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_BatchLineItem]
	ON [dbo].[BatchLineItem] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iInventory_BatchLineItem]
	ON [dbo].[BatchLineItem] ([Inventory])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iInventoryAccount_BatchLineItem]
	ON [dbo].[BatchLineItem] ([InventoryAccount])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iInventoryLocation_BatchLineItem]
	ON [dbo].[BatchLineItem] ([InventoryLocation])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iItem_BatchLineItem]
	ON [dbo].[BatchLineItem] ([Item])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iMarkedCompleteBy_BatchLineItem]
	ON [dbo].[BatchLineItem] ([MarkedCompleteBy])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iMissingVendorInvoicesApprovedBy_BatchLineItem]
	ON [dbo].[BatchLineItem] ([MissingVendorInvoicesApprovedBy])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iMissingVendorInvoicesRequestedBy_BatchLineItem]
	ON [dbo].[BatchLineItem] ([MissingVendorInvoicesRequestedBy])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iPurchaseOrder_BatchLineItem]
	ON [dbo].[BatchLineItem] ([PurchaseOrder])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iPurchaseOrderApprovedBy_BatchLineItem]
	ON [dbo].[BatchLineItem] ([PurchaseOrderApprovedBy])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iPurchaseOrderLineItem_BatchLineItem]
	ON [dbo].[BatchLineItem] ([PurchaseOrderLineItem])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iPurchaseOrderRequestedBy_BatchLineItem]
	ON [dbo].[BatchLineItem] ([PurchaseOrderRequestedBy])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iShippingMethod_BatchLineItem]
	ON [dbo].[BatchLineItem] ([ShippingMethod])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iSupervisorAssignedToApproveMissingVendorInvoices_BatchLineItem]
	ON [dbo].[BatchLineItem] ([SupervisorAssignedToApproveMissingVendorInvoices])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iSupervisorAssignedToApprovePurchaseOrder_BatchLineItem]
	ON [dbo].[BatchLineItem] ([SupervisorAssignedToApprovePurchaseOrder])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[BatchLineItem] SET (LOCK_ESCALATION = TABLE)
GO
