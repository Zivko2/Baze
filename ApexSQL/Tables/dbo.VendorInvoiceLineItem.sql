SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[VendorInvoiceLineItem] (
		[Oid]                              [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[VendorInvoice]                    [uniqueidentifier] NULL,
		[CostType]                         [uniqueidentifier] NULL,
		[GLAccount]                        [uniqueidentifier] NULL,
		[AmountAmount]                     [money] NULL,
		[AmountIsoCode]                    [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[AmountExchangeRateDate]           [datetime] NULL,
		[AmountBaseAmount]                 [money] NULL,
		[AmountExchangeRate]               [money] NULL,
		[AmountForcedIsoCode]              [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[AmountForcedExchangeRateDate]     [datetime] NULL,
		[Note]                             [nvarchar](1000) COLLATE Latin1_General_CI_AS NULL,
		[OriginatedFromLineItemCost]       [uniqueidentifier] NULL,
		[OptimisticLockField]              [int] NULL,
		[GCRecord]                         [int] NULL,
		CONSTRAINT [PK_VendorInvoiceLineItem]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VendorInvoiceLineItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_VendorInvoiceLineItem_CostType]
	FOREIGN KEY ([CostType]) REFERENCES [dbo].[CostType] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[VendorInvoiceLineItem]
	CHECK CONSTRAINT [FK_VendorInvoiceLineItem_CostType]

GO
ALTER TABLE [dbo].[VendorInvoiceLineItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_VendorInvoiceLineItem_GLAccount]
	FOREIGN KEY ([GLAccount]) REFERENCES [dbo].[GLAccount] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[VendorInvoiceLineItem]
	CHECK CONSTRAINT [FK_VendorInvoiceLineItem_GLAccount]

GO
ALTER TABLE [dbo].[VendorInvoiceLineItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_VendorInvoiceLineItem_OriginatedFromLineItemCost]
	FOREIGN KEY ([OriginatedFromLineItemCost]) REFERENCES [dbo].[LineItemCost] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[VendorInvoiceLineItem]
	CHECK CONSTRAINT [FK_VendorInvoiceLineItem_OriginatedFromLineItemCost]

GO
ALTER TABLE [dbo].[VendorInvoiceLineItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_VendorInvoiceLineItem_VendorInvoice]
	FOREIGN KEY ([VendorInvoice]) REFERENCES [dbo].[VendorInvoice] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[VendorInvoiceLineItem]
	CHECK CONSTRAINT [FK_VendorInvoiceLineItem_VendorInvoice]

GO
CREATE NONCLUSTERED INDEX [iCostType_VendorInvoiceLineItem]
	ON [dbo].[VendorInvoiceLineItem] ([CostType])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_VendorInvoiceLineItem]
	ON [dbo].[VendorInvoiceLineItem] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGLAccount_VendorInvoiceLineItem]
	ON [dbo].[VendorInvoiceLineItem] ([GLAccount])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iOriginatedFromLineItemCost_VendorInvoiceLineItem]
	ON [dbo].[VendorInvoiceLineItem] ([OriginatedFromLineItemCost])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iVendorInvoice_VendorInvoiceLineItem]
	ON [dbo].[VendorInvoiceLineItem] ([VendorInvoice])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[VendorInvoiceLineItem] SET (LOCK_ESCALATION = TABLE)
GO
