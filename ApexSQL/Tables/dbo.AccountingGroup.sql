SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AccountingGroup] (
		[Oid]                                       [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[Name]                                      [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Description]                               [nvarchar](1000) COLLATE Latin1_General_CI_AS NULL,
		[DefaultInventoryAccount]                   [uniqueidentifier] NULL,
		[DefaultSellByMode]                         [int] NULL,
		[WorkOrderIsRequired]                       [int] NULL,
		[DefaultWholesaleValueCalculationScope]     [int] NULL,
		[DefaultLabelPriceCurrency]                 [uniqueidentifier] NULL,
		[ItemPriceCostTypeAffinity]                 [uniqueidentifier] NULL,
		[Enabled]                                   [bit] NULL,
		[ExcludeFromFinancialTransferSets]          [bit] NULL,
		[TrackQuantities]                           [bit] NULL,
		[RequiredSaleLineItemType]                  [uniqueidentifier] NULL,
		[OptimisticLockField]                       [int] NULL,
		[GCRecord]                                  [int] NULL,
		CONSTRAINT [PK_AccountingGroup]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AccountingGroup]
	WITH NOCHECK
	ADD CONSTRAINT [FK_AccountingGroup_DefaultInventoryAccount]
	FOREIGN KEY ([DefaultInventoryAccount]) REFERENCES [dbo].[InventoryAccount] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[AccountingGroup]
	CHECK CONSTRAINT [FK_AccountingGroup_DefaultInventoryAccount]

GO
ALTER TABLE [dbo].[AccountingGroup]
	WITH NOCHECK
	ADD CONSTRAINT [FK_AccountingGroup_DefaultLabelPriceCurrency]
	FOREIGN KEY ([DefaultLabelPriceCurrency]) REFERENCES [dbo].[Currency] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[AccountingGroup]
	CHECK CONSTRAINT [FK_AccountingGroup_DefaultLabelPriceCurrency]

GO
ALTER TABLE [dbo].[AccountingGroup]
	WITH NOCHECK
	ADD CONSTRAINT [FK_AccountingGroup_ItemPriceCostTypeAffinity]
	FOREIGN KEY ([ItemPriceCostTypeAffinity]) REFERENCES [dbo].[CostType] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[AccountingGroup]
	CHECK CONSTRAINT [FK_AccountingGroup_ItemPriceCostTypeAffinity]

GO
ALTER TABLE [dbo].[AccountingGroup]
	WITH NOCHECK
	ADD CONSTRAINT [FK_AccountingGroup_RequiredSaleLineItemType]
	FOREIGN KEY ([RequiredSaleLineItemType]) REFERENCES [dbo].[SaleLineItemType] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[AccountingGroup]
	CHECK CONSTRAINT [FK_AccountingGroup_RequiredSaleLineItemType]

GO
CREATE NONCLUSTERED INDEX [iDefaultInventoryAccount_AccountingGroup]
	ON [dbo].[AccountingGroup] ([DefaultInventoryAccount])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iDefaultLabelPriceCurrency_AccountingGroup]
	ON [dbo].[AccountingGroup] ([DefaultLabelPriceCurrency])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_AccountingGroup]
	ON [dbo].[AccountingGroup] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iItemPriceCostTypeAffinity_AccountingGroup]
	ON [dbo].[AccountingGroup] ([ItemPriceCostTypeAffinity])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iRequiredSaleLineItemType_AccountingGroup]
	ON [dbo].[AccountingGroup] ([RequiredSaleLineItemType])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[AccountingGroup] SET (LOCK_ESCALATION = TABLE)
GO
