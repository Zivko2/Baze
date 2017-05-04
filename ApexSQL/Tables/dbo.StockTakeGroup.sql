SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[StockTakeGroup] (
		[Oid]                                    [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[Name]                                   [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[CountsToBeEnteredRealTime]              [bit] NULL,
		[CountByBatch]                           [bit] NULL,
		[AdjustUncountedItemsToZeroQuantity]     [bit] NULL,
		[GenerateFinancialTransferSet]           [bit] NULL,
		[ScheduledStartDate]                     [datetime] NULL,
		[ScheduledEndDate]                       [datetime] NULL,
		[ReconciledOn]                           [datetime] NULL,
		[ReconciledBy]                           [uniqueidentifier] NULL,
		[AdjustmentAccount]                      [uniqueidentifier] NULL,
		[Description]                            [nvarchar](1000) COLLATE Latin1_General_CI_AS NULL,
		[Notes]                                  [nvarchar](1000) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]                    [int] NULL,
		[GCRecord]                               [int] NULL,
		CONSTRAINT [PK_StockTakeGroup]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StockTakeGroup]
	WITH NOCHECK
	ADD CONSTRAINT [FK_StockTakeGroup_AdjustmentAccount]
	FOREIGN KEY ([AdjustmentAccount]) REFERENCES [dbo].[Customer] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[StockTakeGroup]
	CHECK CONSTRAINT [FK_StockTakeGroup_AdjustmentAccount]

GO
ALTER TABLE [dbo].[StockTakeGroup]
	WITH NOCHECK
	ADD CONSTRAINT [FK_StockTakeGroup_ReconciledBy]
	FOREIGN KEY ([ReconciledBy]) REFERENCES [dbo].[ExtendedSecurityUser] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[StockTakeGroup]
	CHECK CONSTRAINT [FK_StockTakeGroup_ReconciledBy]

GO
CREATE NONCLUSTERED INDEX [iAdjustmentAccount_StockTakeGroup]
	ON [dbo].[StockTakeGroup] ([AdjustmentAccount])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_StockTakeGroup]
	ON [dbo].[StockTakeGroup] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iReconciledBy_StockTakeGroup]
	ON [dbo].[StockTakeGroup] ([ReconciledBy])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[StockTakeGroup] SET (LOCK_ESCALATION = TABLE)
GO
