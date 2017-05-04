SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[PurchaseOrderTask] (
		[Oid]                       [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[PurchaseOrderTaskType]     [int] NULL,
		[PurchaseOrder]             [uniqueidentifier] NULL,
		CONSTRAINT [PK_PurchaseOrderTask]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PurchaseOrderTask]
	WITH NOCHECK
	ADD CONSTRAINT [FK_PurchaseOrderTask_Oid]
	FOREIGN KEY ([Oid]) REFERENCES [dbo].[Task] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[PurchaseOrderTask]
	CHECK CONSTRAINT [FK_PurchaseOrderTask_Oid]

GO
ALTER TABLE [dbo].[PurchaseOrderTask]
	WITH NOCHECK
	ADD CONSTRAINT [FK_PurchaseOrderTask_PurchaseOrder]
	FOREIGN KEY ([PurchaseOrder]) REFERENCES [dbo].[PurchaseOrder] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[PurchaseOrderTask]
	CHECK CONSTRAINT [FK_PurchaseOrderTask_PurchaseOrder]

GO
CREATE NONCLUSTERED INDEX [iPurchaseOrder_PurchaseOrderTask]
	ON [dbo].[PurchaseOrderTask] ([PurchaseOrder])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[PurchaseOrderTask] SET (LOCK_ESCALATION = TABLE)
GO
