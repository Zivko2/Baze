SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FinancialTransferSet] (
		[Oid]                                 [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[IsBalanced]                          [bit] NULL,
		[SubmittedFileName]                   [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[SalesGatheredOn]                     [datetime] NULL,
		[SubmittedOn]                         [datetime] NULL,
		[UnsubmittedOn]                       [datetime] NULL,
		[SalesGatheredBy]                     [uniqueidentifier] NULL,
		[SubmittedBy]                         [uniqueidentifier] NULL,
		[SetName]                             [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[DirectCustomerSalesTotal]            [money] NULL,
		[WorkOrderSalesTotal]                 [money] NULL,
		[TotalValueReceivedIntoInventory]     [money] NULL,
		[TotalCurrentInventoryValue]          [money] NULL,
		[SetStartDate]                        [datetime] NULL,
		[SetEndDate]                          [datetime] NULL,
		[StockTakeGroup]                      [uniqueidentifier] NULL,
		[TransferSetExport]                   [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]                 [int] NULL,
		[GCRecord]                            [int] NULL,
		CONSTRAINT [PK_FinancialTransferSet]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[FinancialTransferSet]
	WITH NOCHECK
	ADD CONSTRAINT [FK_FinancialTransferSet_SalesGatheredBy]
	FOREIGN KEY ([SalesGatheredBy]) REFERENCES [dbo].[ExtendedSecurityUser] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[FinancialTransferSet]
	CHECK CONSTRAINT [FK_FinancialTransferSet_SalesGatheredBy]

GO
ALTER TABLE [dbo].[FinancialTransferSet]
	WITH NOCHECK
	ADD CONSTRAINT [FK_FinancialTransferSet_StockTakeGroup]
	FOREIGN KEY ([StockTakeGroup]) REFERENCES [dbo].[StockTakeGroup] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[FinancialTransferSet]
	CHECK CONSTRAINT [FK_FinancialTransferSet_StockTakeGroup]

GO
ALTER TABLE [dbo].[FinancialTransferSet]
	WITH NOCHECK
	ADD CONSTRAINT [FK_FinancialTransferSet_SubmittedBy]
	FOREIGN KEY ([SubmittedBy]) REFERENCES [dbo].[ExtendedSecurityUser] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[FinancialTransferSet]
	CHECK CONSTRAINT [FK_FinancialTransferSet_SubmittedBy]

GO
CREATE NONCLUSTERED INDEX [iGCRecord_FinancialTransferSet]
	ON [dbo].[FinancialTransferSet] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iSalesGatheredBy_FinancialTransferSet]
	ON [dbo].[FinancialTransferSet] ([SalesGatheredBy])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iStockTakeGroup_FinancialTransferSet]
	ON [dbo].[FinancialTransferSet] ([StockTakeGroup])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iSubmittedBy_FinancialTransferSet]
	ON [dbo].[FinancialTransferSet] ([SubmittedBy])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[FinancialTransferSet] SET (LOCK_ESCALATION = TABLE)
GO
