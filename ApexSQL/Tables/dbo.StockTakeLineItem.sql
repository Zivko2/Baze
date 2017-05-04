SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[StockTakeLineItem] (
		[Oid]                                                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[StockTake]                                          [uniqueidentifier] NULL,
		[Item]                                               [uniqueidentifier] NULL,
		[Batch]                                              [uniqueidentifier] NULL,
		[SerialNumber]                                       [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[SystemCountWhenManualCountRecordedDecimalValue]     [decimal](19, 5) NULL,
		[SystemCountWhenManualCountRecordedStringValue]      [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[ManualCountDecimalValue]                            [decimal](19, 5) NULL,
		[ManualCountStringValue]                             [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[ManualCountRecordedOn]                              [datetime] NULL,
		[ManualCountRecordedBy]                              [uniqueidentifier] NULL,
		[ManualCountVerified]                                [bit] NULL,
		[Note]                                               [nvarchar](1000) COLLATE Latin1_General_CI_AS NULL,
		[AdjustmentOccurredOn]                               [datetime] NULL,
		[BatchLineItem]                                      [uniqueidentifier] NULL,
		[OptimisticLockField]                                [int] NULL,
		[GCRecord]                                           [int] NULL,
		[CurrentSystemCount]                                 AS ([dbo].[ItemByBatchQuantity]([Item],[Batch],[SerialNumber])),
		[ItemBatchMistmatch]                                 AS (case when [dbo].[ItemExistsInBatch]([Item],[Batch])=(0) then (1) else (0) end),
		CONSTRAINT [PK_StockTakeLineItem]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StockTakeLineItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_StockTakeLineItem_Batch]
	FOREIGN KEY ([Batch]) REFERENCES [dbo].[Batch] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[StockTakeLineItem]
	CHECK CONSTRAINT [FK_StockTakeLineItem_Batch]

GO
ALTER TABLE [dbo].[StockTakeLineItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_StockTakeLineItem_BatchLineItem]
	FOREIGN KEY ([BatchLineItem]) REFERENCES [dbo].[BatchLineItem] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[StockTakeLineItem]
	CHECK CONSTRAINT [FK_StockTakeLineItem_BatchLineItem]

GO
ALTER TABLE [dbo].[StockTakeLineItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_StockTakeLineItem_Item]
	FOREIGN KEY ([Item]) REFERENCES [dbo].[Item] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[StockTakeLineItem]
	CHECK CONSTRAINT [FK_StockTakeLineItem_Item]

GO
ALTER TABLE [dbo].[StockTakeLineItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_StockTakeLineItem_ManualCountRecordedBy]
	FOREIGN KEY ([ManualCountRecordedBy]) REFERENCES [dbo].[ExtendedSecurityUser] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[StockTakeLineItem]
	CHECK CONSTRAINT [FK_StockTakeLineItem_ManualCountRecordedBy]

GO
ALTER TABLE [dbo].[StockTakeLineItem]
	WITH NOCHECK
	ADD CONSTRAINT [FK_StockTakeLineItem_StockTake]
	FOREIGN KEY ([StockTake]) REFERENCES [dbo].[StockTake] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[StockTakeLineItem]
	CHECK CONSTRAINT [FK_StockTakeLineItem_StockTake]

GO
CREATE NONCLUSTERED INDEX [iBatch_StockTakeLineItem]
	ON [dbo].[StockTakeLineItem] ([Batch])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iBatchLineItem_StockTakeLineItem]
	ON [dbo].[StockTakeLineItem] ([BatchLineItem])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_StockTakeLineItem]
	ON [dbo].[StockTakeLineItem] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iItem_StockTakeLineItem]
	ON [dbo].[StockTakeLineItem] ([Item])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iManualCountRecordedBy_StockTakeLineItem]
	ON [dbo].[StockTakeLineItem] ([ManualCountRecordedBy])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iManualCountRecordedOn_StockTakeLineItem]
	ON [dbo].[StockTakeLineItem] ([ManualCountRecordedOn])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iStockTake_StockTakeLineItem]
	ON [dbo].[StockTakeLineItem] ([StockTake])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[StockTakeLineItem] SET (LOCK_ESCALATION = TABLE)
GO
