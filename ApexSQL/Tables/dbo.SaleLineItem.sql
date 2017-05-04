SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SaleLineItem] (
		[Oid]                             [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[UnitWholesaleValue]              [money] NULL,
		[UnitSalePrice]                   [money] NULL,
		[Sale]                            [uniqueidentifier] NULL,
		[LineNumber]                      [int] NULL,
		[BatchLineItem]                   [uniqueidentifier] NULL,
		[ReserveItemQuantity]             [bit] NULL,
		[UnitPriceLocked]                 [bit] NULL,
		[Note]                            [nvarchar](1000) COLLATE Latin1_General_CI_AS NULL,
		[Item]                            [uniqueidentifier] NULL,
		[UnitOfMeasure]                   [uniqueidentifier] NULL,
		[QuantityDecimalValue]            [decimal](19, 5) NULL,
		[QuantityStringValue]             [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[WorkOrder]                       [uniqueidentifier] NULL,
		[SaleLineItemType]                [uniqueidentifier] NULL,
		[SerialNumber]                    [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[UnitSalePriceInBaseCurrency]     [money] NULL,
		[LockedUnitPrice]                 [money] NULL,
		[OptimisticLockField]             [int] NULL,
		[GCRecord]                        [int] NULL,
		CONSTRAINT [PK_SaleLineItem]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SaleLineItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_SaleLineItem_BatchLineItem]
	FOREIGN KEY ([BatchLineItem]) REFERENCES [dbo].[BatchLineItem] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[SaleLineItem]
	CHECK CONSTRAINT [FK_SaleLineItem_BatchLineItem]

GO
ALTER TABLE [dbo].[SaleLineItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_SaleLineItem_Item]
	FOREIGN KEY ([Item]) REFERENCES [dbo].[Item] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[SaleLineItem]
	CHECK CONSTRAINT [FK_SaleLineItem_Item]

GO
ALTER TABLE [dbo].[SaleLineItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_SaleLineItem_Sale]
	FOREIGN KEY ([Sale]) REFERENCES [dbo].[Sale] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[SaleLineItem]
	CHECK CONSTRAINT [FK_SaleLineItem_Sale]

GO
ALTER TABLE [dbo].[SaleLineItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_SaleLineItem_SaleLineItemType]
	FOREIGN KEY ([SaleLineItemType]) REFERENCES [dbo].[SaleLineItemType] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[SaleLineItem]
	CHECK CONSTRAINT [FK_SaleLineItem_SaleLineItemType]

GO
ALTER TABLE [dbo].[SaleLineItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_SaleLineItem_UnitOfMeasure]
	FOREIGN KEY ([UnitOfMeasure]) REFERENCES [dbo].[UnitOfMeasure] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[SaleLineItem]
	CHECK CONSTRAINT [FK_SaleLineItem_UnitOfMeasure]

GO
ALTER TABLE [dbo].[SaleLineItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_SaleLineItem_WorkOrder]
	FOREIGN KEY ([WorkOrder]) REFERENCES [dbo].[WorkOrder] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[SaleLineItem]
	CHECK CONSTRAINT [FK_SaleLineItem_WorkOrder]

GO
CREATE NONCLUSTERED INDEX [iBatchLineItem_SaleLineItem]
	ON [dbo].[SaleLineItem] ([BatchLineItem])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_SaleLineItem]
	ON [dbo].[SaleLineItem] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iItem_SaleLineItem]
	ON [dbo].[SaleLineItem] ([Item])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iSale_SaleLineItem]
	ON [dbo].[SaleLineItem] ([Sale])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iSaleLineItemType_SaleLineItem]
	ON [dbo].[SaleLineItem] ([SaleLineItemType])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iUnitOfMeasure_SaleLineItem]
	ON [dbo].[SaleLineItem] ([UnitOfMeasure])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iWorkOrder_SaleLineItem]
	ON [dbo].[SaleLineItem] ([WorkOrder])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[SaleLineItem] SET (LOCK_ESCALATION = TABLE)
GO
