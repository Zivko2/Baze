SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Item] (
		[Oid]                                           [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[LastEventOccurredOn]                           [datetime] NULL,
		[LastReceivedOn]                                [datetime] NULL,
		[BatchesWithInventory]                          [nvarchar](500) COLLATE Latin1_General_CI_AS NULL,
		[CrossReferences]                               [nvarchar](500) COLLATE Latin1_General_CI_AS NULL,
		[LinkedInventoryLocations]                      [nvarchar](500) COLLATE Latin1_General_CI_AS NULL,
		[ItemNumber]                                    [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Description]                                   [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[ItemType]                                      [uniqueidentifier] NULL,
		[AccountingGroup]                               [uniqueidentifier] NULL,
		[DefaultVendor]                                 [uniqueidentifier] NULL,
		[Manufacturer]                                  [uniqueidentifier] NULL,
		[ManufacturerItemNumber]                        [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[UnitOfMeasure]                                 [uniqueidentifier] NULL,
		[InternalQuantityDecimalValue]                  [decimal](19, 5) NULL,
		[InternalQuantityStringValue]                   [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[InternalUnitOfMeasure]                         [uniqueidentifier] NULL,
		[ReorderPointDecimalValue]                      [decimal](19, 5) NULL,
		[ReorderPointStringValue]                       [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[BaseInventoryLevelDecimalValue]                [decimal](19, 5) NULL,
		[BaseInventoryLevelStringValue]                 [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[SellByMode]                                    [int] NULL,
		[WorkOrderOnSaleIsRequired]                     [int] NULL,
		[WholesaleValueCalculationScope]                [int] NULL,
		[InventoryAccount]                              [uniqueidentifier] NULL,
		[ShippingUnitWeightAmount]                      [float] NULL,
		[ShippingUnitWeightUnitOfMeasure]               [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[ShippingUnitWeightBaseAmount]                  [float] NULL,
		[ShippingUnitVolumeAmount]                      [float] NULL,
		[ShippingUnitVolumeUnitOfMeasure]               [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[ShippingUnitVolumeBaseAmount]                  [float] NULL,
		[BarCode]                                       [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[CalculatedBaseInventoryLevelDecimalValue]      [decimal](19, 5) NULL,
		[CalculatedBaseInventoryLevelStringValue]       [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[CalculatedReorderPointDecimalValue]            [decimal](19, 5) NULL,
		[CalculatedReorderPointStringValue]             [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[CalculatedShippingUnitVolume]                  [float] NULL,
		[CalculatedShippingUnitWeight]                  [float] NULL,
		[TotalInventoryValue]                           [money] NULL,
		[UnitWholesaleValueOverride]                    [money] NULL,
		[UnitWholesaleValueOverrideCurrency]            [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[UnitPriceCapMin]                               [money] NULL,
		[UnitPriceCapMax]                               [money] NULL,
		[InactivatedBy]                                 [uniqueidentifier] NULL,
		[InactivatedOn]                                 [datetime] NULL,
		[HighlightedNote]                               [nvarchar](500) COLLATE Latin1_General_CI_AS NULL,
		[HightlightColor]                               [int] NULL,
		[RateOfSaleAdjustment]                          [int] NULL,
		[TrackSerialNumbers]                            [bit] NULL,
		[AllowFractionsInReceiving]                     [bit] NULL,
		[NumberOfQuantityDecimalPlacesInReceiving]      [int] NULL,
		[AllowFractionsInSales]                         [bit] NULL,
		[NumberOfQuantityDecimalPlacesInSales]          [int] NULL,
		[AllowFractionsInPurchasing]                    [bit] NULL,
		[NumberOfQuantityDecimalPlacesInPurchasing]     [int] NULL,
		[InventoryQuantityDecimalValue]                 [decimal](19, 5) NULL,
		[InventoryQuantityStringValue]                  [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[AvailableInventoryQuantityDecimalValue]        [decimal](19, 5) NULL,
		[AvailableInventoryQuantityStringValue]         [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[OnOrderQuantityDecimalValue]                   [decimal](19, 5) NULL,
		[OnOrderQuantityStringValue]                    [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[WantListQuantityDecimalValue]                  [decimal](19, 5) NULL,
		[WantListQuantityStringValue]                   [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[XRefInventoryQuantityDecimalValue]             [decimal](19, 5) NULL,
		[XRefInventoryQuantityStringValue]              [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[XRefOnOrderQuantityDecimalValue]               [decimal](19, 5) NULL,
		[XRefOnOrderQuantityStringValue]                [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Photo]                                         [varbinary](max) NULL,
		[ReorderPlan]                                   [uniqueidentifier] NULL,
		[ExemptFromNonBasePriceComponents]              [bit] NULL,
		[Note]                                          [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]                           [int] NULL,
		[GCRecord]                                      [int] NULL,
		CONSTRAINT [PK_Item]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Item]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Item_AccountingGroup]
	FOREIGN KEY ([AccountingGroup]) REFERENCES [dbo].[AccountingGroup] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Item]
	CHECK CONSTRAINT [FK_Item_AccountingGroup]

GO
ALTER TABLE [dbo].[Item]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Item_DefaultVendor]
	FOREIGN KEY ([DefaultVendor]) REFERENCES [dbo].[Vendor] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Item]
	CHECK CONSTRAINT [FK_Item_DefaultVendor]

GO
ALTER TABLE [dbo].[Item]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Item_InactivatedBy]
	FOREIGN KEY ([InactivatedBy]) REFERENCES [dbo].[ExtendedSecurityUser] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Item]
	CHECK CONSTRAINT [FK_Item_InactivatedBy]

GO
ALTER TABLE [dbo].[Item]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Item_InternalUnitOfMeasure]
	FOREIGN KEY ([InternalUnitOfMeasure]) REFERENCES [dbo].[UnitOfMeasure] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Item]
	CHECK CONSTRAINT [FK_Item_InternalUnitOfMeasure]

GO
ALTER TABLE [dbo].[Item]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Item_InventoryAccount]
	FOREIGN KEY ([InventoryAccount]) REFERENCES [dbo].[InventoryAccount] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Item]
	CHECK CONSTRAINT [FK_Item_InventoryAccount]

GO
ALTER TABLE [dbo].[Item]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Item_ItemType]
	FOREIGN KEY ([ItemType]) REFERENCES [dbo].[ItemType] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Item]
	CHECK CONSTRAINT [FK_Item_ItemType]

GO
ALTER TABLE [dbo].[Item]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Item_Manufacturer]
	FOREIGN KEY ([Manufacturer]) REFERENCES [dbo].[Manufacturer] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Item]
	CHECK CONSTRAINT [FK_Item_Manufacturer]

GO
ALTER TABLE [dbo].[Item]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Item_ReorderPlan]
	FOREIGN KEY ([ReorderPlan]) REFERENCES [dbo].[ReorderPlan] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Item]
	CHECK CONSTRAINT [FK_Item_ReorderPlan]

GO
ALTER TABLE [dbo].[Item]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Item_UnitOfMeasure]
	FOREIGN KEY ([UnitOfMeasure]) REFERENCES [dbo].[UnitOfMeasure] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Item]
	CHECK CONSTRAINT [FK_Item_UnitOfMeasure]

GO
CREATE NONCLUSTERED INDEX [iAccountingGroup_Item]
	ON [dbo].[Item] ([AccountingGroup])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iDefaultVendor_Item]
	ON [dbo].[Item] ([DefaultVendor])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_Item]
	ON [dbo].[Item] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iInactivatedBy_Item]
	ON [dbo].[Item] ([InactivatedBy])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iInternalUnitOfMeasure_Item]
	ON [dbo].[Item] ([InternalUnitOfMeasure])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iInventoryAccount_Item]
	ON [dbo].[Item] ([InventoryAccount])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iItemType_Item]
	ON [dbo].[Item] ([ItemType])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iManufacturer_Item]
	ON [dbo].[Item] ([Manufacturer])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iReorderPlan_Item]
	ON [dbo].[Item] ([ReorderPlan])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iUnitOfMeasure_Item]
	ON [dbo].[Item] ([UnitOfMeasure])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Item] SET (LOCK_ESCALATION = TABLE)
GO
