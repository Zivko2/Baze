SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[PriceComponent] (
		[Oid]                         [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[SaleLineItem]                [uniqueidentifier] NULL,
		[PriceComponentType]          [uniqueidentifier] NULL,
		[Amount]                      [money] NULL,
		[TruncatedAmount]             [money] NULL,
		[ExtendedAmount]              [money] NULL,
		[TruncatedExtendedAmount]     [money] NULL,
		[OptimisticLockField]         [int] NULL,
		[GCRecord]                    [int] NULL,
		CONSTRAINT [PK_PriceComponent]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PriceComponent]
	WITH NOCHECK
	ADD CONSTRAINT [FK_PriceComponent_PriceComponentType]
	FOREIGN KEY ([PriceComponentType]) REFERENCES [dbo].[PriceComponentType] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[PriceComponent]
	CHECK CONSTRAINT [FK_PriceComponent_PriceComponentType]

GO
ALTER TABLE [dbo].[PriceComponent]
	WITH NOCHECK
	ADD CONSTRAINT [FK_PriceComponent_SaleLineItem]
	FOREIGN KEY ([SaleLineItem]) REFERENCES [dbo].[SaleLineItem] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[PriceComponent]
	CHECK CONSTRAINT [FK_PriceComponent_SaleLineItem]

GO
CREATE NONCLUSTERED INDEX [iGCRecord_PriceComponent]
	ON [dbo].[PriceComponent] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iPriceComponentType_PriceComponent]
	ON [dbo].[PriceComponent] ([PriceComponentType])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iSaleLineItem_PriceComponent]
	ON [dbo].[PriceComponent] ([SaleLineItem])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[PriceComponent] SET (LOCK_ESCALATION = TABLE)
GO
