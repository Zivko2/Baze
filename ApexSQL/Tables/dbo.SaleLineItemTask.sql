SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[SaleLineItemTask] (
		[Oid]                      [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[SaleLineItemTaskType]     [int] NULL,
		[SaleLineItem]             [uniqueidentifier] NULL,
		CONSTRAINT [PK_SaleLineItemTask]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SaleLineItemTask]
	WITH NOCHECK
	ADD CONSTRAINT [FK_SaleLineItemTask_Oid]
	FOREIGN KEY ([Oid]) REFERENCES [dbo].[Task] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[SaleLineItemTask]
	CHECK CONSTRAINT [FK_SaleLineItemTask_Oid]

GO
ALTER TABLE [dbo].[SaleLineItemTask]
	WITH NOCHECK
	ADD CONSTRAINT [FK_SaleLineItemTask_SaleLineItem]
	FOREIGN KEY ([SaleLineItem]) REFERENCES [dbo].[SaleLineItem] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[SaleLineItemTask]
	CHECK CONSTRAINT [FK_SaleLineItemTask_SaleLineItem]

GO
CREATE NONCLUSTERED INDEX [iSaleLineItem_SaleLineItemTask]
	ON [dbo].[SaleLineItemTask] ([SaleLineItem])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[SaleLineItemTask] SET (LOCK_ESCALATION = TABLE)
GO
