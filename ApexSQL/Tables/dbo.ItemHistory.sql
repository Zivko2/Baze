SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ItemHistory] (
		[Oid]                      [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[Item]                     [uniqueidentifier] NULL,
		[MovementOccurredOn]       [datetime] NULL,
		[QuantityDecimalValue]     [decimal](19, 5) NULL,
		[QuantityStringValue]      [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[BaseValue]                [money] NULL,
		[Inventory]                [uniqueidentifier] NULL,
		[SaleLineItem]             [uniqueidentifier] NULL,
		[LineItemCost]             [uniqueidentifier] NULL,
		[ReturnOfSaleLineItem]     [uniqueidentifier] NULL,
		[ItemHistoryType]          [int] NULL,
		[Note]                     [nvarchar](1000) COLLATE Latin1_General_CI_AS NULL,
		[LandedUnitCost]           [money] NULL,
		[COGSAdjustment]           [money] NULL,
		[OptimisticLockField]      [int] NULL,
		[GCRecord]                 [int] NULL,
		CONSTRAINT [PK_ItemHistory]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ItemHistory]
	WITH NOCHECK
	ADD CONSTRAINT [FK_ItemHistory_Inventory]
	FOREIGN KEY ([Inventory]) REFERENCES [dbo].[Inventory] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[ItemHistory]
	CHECK CONSTRAINT [FK_ItemHistory_Inventory]

GO
ALTER TABLE [dbo].[ItemHistory]
	WITH NOCHECK
	ADD CONSTRAINT [FK_ItemHistory_Item]
	FOREIGN KEY ([Item]) REFERENCES [dbo].[Item] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[ItemHistory]
	CHECK CONSTRAINT [FK_ItemHistory_Item]

GO
ALTER TABLE [dbo].[ItemHistory]
	WITH NOCHECK
	ADD CONSTRAINT [FK_ItemHistory_LineItemCost]
	FOREIGN KEY ([LineItemCost]) REFERENCES [dbo].[LineItemCost] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[ItemHistory]
	CHECK CONSTRAINT [FK_ItemHistory_LineItemCost]

GO
ALTER TABLE [dbo].[ItemHistory]
	WITH NOCHECK
	ADD CONSTRAINT [FK_ItemHistory_ReturnOfSaleLineItem]
	FOREIGN KEY ([ReturnOfSaleLineItem]) REFERENCES [dbo].[SaleLineItem] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[ItemHistory]
	CHECK CONSTRAINT [FK_ItemHistory_ReturnOfSaleLineItem]

GO
ALTER TABLE [dbo].[ItemHistory]
	WITH NOCHECK
	ADD CONSTRAINT [FK_ItemHistory_SaleLineItem]
	FOREIGN KEY ([SaleLineItem]) REFERENCES [dbo].[SaleLineItem] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[ItemHistory]
	CHECK CONSTRAINT [FK_ItemHistory_SaleLineItem]

GO
CREATE NONCLUSTERED INDEX [iGCRecord_ItemHistory]
	ON [dbo].[ItemHistory] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iInventory_ItemHistory]
	ON [dbo].[ItemHistory] ([Inventory])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iItem_ItemHistory]
	ON [dbo].[ItemHistory] ([Item])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iLineItemCost_ItemHistory]
	ON [dbo].[ItemHistory] ([LineItemCost])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iReturnOfSaleLineItem_ItemHistory]
	ON [dbo].[ItemHistory] ([ReturnOfSaleLineItem])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iSaleLineItem_ItemHistory]
	ON [dbo].[ItemHistory] ([SaleLineItem])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[ItemHistory] SET (LOCK_ESCALATION = TABLE)
GO
