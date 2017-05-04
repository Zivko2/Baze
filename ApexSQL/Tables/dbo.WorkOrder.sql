SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[WorkOrder] (
		[Oid]                             [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[WorkOrderNumber]                 [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[WorkOrderType]                   [uniqueidentifier] NULL,
		[WorkOrderGroup]                  [uniqueidentifier] NULL,
		[CustomerPurchaseOrderNumber]     [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Description]                     [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
		[ContactName]                     [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[OpenedOn]                        [datetime] NULL,
		[PrintedOn]                       [datetime] NULL,
		[ClosedBy]                        [uniqueidentifier] NULL,
		[ClosedOn]                        [datetime] NULL,
		[BarCode]                         [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]             [int] NULL,
		[GCRecord]                        [int] NULL,
		CONSTRAINT [PK_WorkOrder]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkOrder]
	WITH NOCHECK
	ADD CONSTRAINT [FK_WorkOrder_ClosedBy]
	FOREIGN KEY ([ClosedBy]) REFERENCES [dbo].[ExtendedSecurityUser] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[WorkOrder]
	CHECK CONSTRAINT [FK_WorkOrder_ClosedBy]

GO
ALTER TABLE [dbo].[WorkOrder]
	WITH NOCHECK
	ADD CONSTRAINT [FK_WorkOrder_WorkOrderGroup]
	FOREIGN KEY ([WorkOrderGroup]) REFERENCES [dbo].[WorkOrderGroup] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[WorkOrder]
	CHECK CONSTRAINT [FK_WorkOrder_WorkOrderGroup]

GO
ALTER TABLE [dbo].[WorkOrder]
	WITH NOCHECK
	ADD CONSTRAINT [FK_WorkOrder_WorkOrderType]
	FOREIGN KEY ([WorkOrderType]) REFERENCES [dbo].[WorkOrderType] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[WorkOrder]
	CHECK CONSTRAINT [FK_WorkOrder_WorkOrderType]

GO
CREATE NONCLUSTERED INDEX [iClosedBy_WorkOrder]
	ON [dbo].[WorkOrder] ([ClosedBy])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_WorkOrder]
	ON [dbo].[WorkOrder] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iWorkOrderGroup_WorkOrder]
	ON [dbo].[WorkOrder] ([WorkOrderGroup])
	ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [iWorkOrderNumber_WorkOrder]
	ON [dbo].[WorkOrder] ([WorkOrderNumber])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iWorkOrderType_WorkOrder]
	ON [dbo].[WorkOrder] ([WorkOrderType])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkOrder] SET (LOCK_ESCALATION = TABLE)
GO
