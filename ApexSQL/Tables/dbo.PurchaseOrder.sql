SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PurchaseOrder] (
		[Oid]                                   [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[SubmittedToVendorOn]                   [datetime] NULL,
		[AmountApprovedBy]                      [uniqueidentifier] NULL,
		[AmountAuthorizationRequestedBy]        [uniqueidentifier] NULL,
		[SupervisorAssignedToApproveAmount]     [uniqueidentifier] NULL,
		[PurchaseOrderStatus]                   [int] NULL,
		[AmountApprovalRequestNote]             [nvarchar](1000) COLLATE Latin1_General_CI_AS NULL,
		[AmountApprovalSupervisorNote]          [nvarchar](1000) COLLATE Latin1_General_CI_AS NULL,
		[SubmittedToVendorBy]                   [int] NULL,
		[PurchaseOrderNumber]                   [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Vendor]                                [uniqueidentifier] NULL,
		[ShippingMethod]                        [uniqueidentifier] NULL,
		[InventoryAccount]                      [uniqueidentifier] NULL,
		[Currency]                              [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[CreatedOn]                             [datetime] NULL,
		[Note]                                  [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
		[ShippingNote]                          [nvarchar](1000) COLLATE Latin1_General_CI_AS NULL,
		[PurchaseOrderType]                     [int] NULL,
		[OutboundWeightAmount]                  [float] NULL,
		[OutboundWeightUnitOfMeasure]           [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[OutboundWeightBaseAmount]              [float] NULL,
		[OutboundVolumeAmount]                  [float] NULL,
		[OutboundVolumeUnitOfMeasure]           [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[OutboundVolumeBaseAmount]              [float] NULL,
		[OutboundPieces]                        [int] NULL,
		[OutboundShippingReferenceNumber]       [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]                   [int] NULL,
		[GCRecord]                              [int] NULL,
		CONSTRAINT [PK_PurchaseOrder]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[PurchaseOrder]
	WITH NOCHECK
	ADD CONSTRAINT [FK_PurchaseOrder_AmountApprovedBy]
	FOREIGN KEY ([AmountApprovedBy]) REFERENCES [dbo].[ExtendedSecurityUser] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[PurchaseOrder]
	CHECK CONSTRAINT [FK_PurchaseOrder_AmountApprovedBy]

GO
ALTER TABLE [dbo].[PurchaseOrder]
	WITH NOCHECK
	ADD CONSTRAINT [FK_PurchaseOrder_AmountAuthorizationRequestedBy]
	FOREIGN KEY ([AmountAuthorizationRequestedBy]) REFERENCES [dbo].[ExtendedSecurityUser] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[PurchaseOrder]
	CHECK CONSTRAINT [FK_PurchaseOrder_AmountAuthorizationRequestedBy]

GO
ALTER TABLE [dbo].[PurchaseOrder]
	WITH NOCHECK
	ADD CONSTRAINT [FK_PurchaseOrder_InventoryAccount]
	FOREIGN KEY ([InventoryAccount]) REFERENCES [dbo].[InventoryAccount] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[PurchaseOrder]
	CHECK CONSTRAINT [FK_PurchaseOrder_InventoryAccount]

GO
ALTER TABLE [dbo].[PurchaseOrder]
	WITH NOCHECK
	ADD CONSTRAINT [FK_PurchaseOrder_ShippingMethod]
	FOREIGN KEY ([ShippingMethod]) REFERENCES [dbo].[ShippingMethod] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[PurchaseOrder]
	CHECK CONSTRAINT [FK_PurchaseOrder_ShippingMethod]

GO
ALTER TABLE [dbo].[PurchaseOrder]
	WITH NOCHECK
	ADD CONSTRAINT [FK_PurchaseOrder_SupervisorAssignedToApproveAmount]
	FOREIGN KEY ([SupervisorAssignedToApproveAmount]) REFERENCES [dbo].[ExtendedSecurityUser] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[PurchaseOrder]
	CHECK CONSTRAINT [FK_PurchaseOrder_SupervisorAssignedToApproveAmount]

GO
ALTER TABLE [dbo].[PurchaseOrder]
	WITH NOCHECK
	ADD CONSTRAINT [FK_PurchaseOrder_Vendor]
	FOREIGN KEY ([Vendor]) REFERENCES [dbo].[Vendor] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[PurchaseOrder]
	CHECK CONSTRAINT [FK_PurchaseOrder_Vendor]

GO
CREATE NONCLUSTERED INDEX [iAmountApprovedBy_PurchaseOrder]
	ON [dbo].[PurchaseOrder] ([AmountApprovedBy])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iAmountAuthorizationRequestedBy_PurchaseOrder]
	ON [dbo].[PurchaseOrder] ([AmountAuthorizationRequestedBy])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_PurchaseOrder]
	ON [dbo].[PurchaseOrder] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iInventoryAccount_PurchaseOrder]
	ON [dbo].[PurchaseOrder] ([InventoryAccount])
	ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [iPurchaseOrderNumber_PurchaseOrder]
	ON [dbo].[PurchaseOrder] ([PurchaseOrderNumber])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iShippingMethod_PurchaseOrder]
	ON [dbo].[PurchaseOrder] ([ShippingMethod])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iSupervisorAssignedToApproveAmount_PurchaseOrder]
	ON [dbo].[PurchaseOrder] ([SupervisorAssignedToApproveAmount])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iVendor_PurchaseOrder]
	ON [dbo].[PurchaseOrder] ([Vendor])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[PurchaseOrder] SET (LOCK_ESCALATION = TABLE)
GO
