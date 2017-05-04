SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[WorkOrderWorkOrders_CustomerCustomers] (
		[Customers]               [uniqueidentifier] NULL,
		[WorkOrders]              [uniqueidentifier] NULL,
		[OID]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[OptimisticLockField]     [int] NULL,
		CONSTRAINT [PK_WorkOrderWorkOrders_CustomerCustomers]
		PRIMARY KEY
		CLUSTERED
		([OID])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkOrderWorkOrders_CustomerCustomers]
	WITH NOCHECK
	ADD CONSTRAINT [FK_WorkOrderWorkOrders_CustomerCustomers_Customers]
	FOREIGN KEY ([Customers]) REFERENCES [dbo].[Customer] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[WorkOrderWorkOrders_CustomerCustomers]
	CHECK CONSTRAINT [FK_WorkOrderWorkOrders_CustomerCustomers_Customers]

GO
ALTER TABLE [dbo].[WorkOrderWorkOrders_CustomerCustomers]
	WITH NOCHECK
	ADD CONSTRAINT [FK_WorkOrderWorkOrders_CustomerCustomers_WorkOrders]
	FOREIGN KEY ([WorkOrders]) REFERENCES [dbo].[WorkOrder] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[WorkOrderWorkOrders_CustomerCustomers]
	CHECK CONSTRAINT [FK_WorkOrderWorkOrders_CustomerCustomers_WorkOrders]

GO
CREATE NONCLUSTERED INDEX [iCustomers_WorkOrderWorkOrders_CustomerCustomers]
	ON [dbo].[WorkOrderWorkOrders_CustomerCustomers] ([Customers])
	ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [iCustomersWorkOrders_WorkOrderWorkOrders_CustomerCustomers]
	ON [dbo].[WorkOrderWorkOrders_CustomerCustomers] ([Customers], [WorkOrders])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iWorkOrders_WorkOrderWorkOrders_CustomerCustomers]
	ON [dbo].[WorkOrderWorkOrders_CustomerCustomers] ([WorkOrders])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkOrderWorkOrders_CustomerCustomers] SET (LOCK_ESCALATION = TABLE)
GO
