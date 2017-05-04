SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[StockTake] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[CompletedOn]             [datetime] NULL,
		[InProgressOn]            [datetime] NULL,
		[StockTakeGroup]          [uniqueidentifier] NULL,
		[Name]                    [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Status]                  [int] NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_StockTake]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StockTake]
	WITH NOCHECK
	ADD CONSTRAINT [FK_StockTake_StockTakeGroup]
	FOREIGN KEY ([StockTakeGroup]) REFERENCES [dbo].[StockTakeGroup] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[StockTake]
	CHECK CONSTRAINT [FK_StockTake_StockTakeGroup]

GO
CREATE NONCLUSTERED INDEX [iGCRecord_StockTake]
	ON [dbo].[StockTake] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iStockTakeGroup_StockTake]
	ON [dbo].[StockTake] ([StockTakeGroup])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[StockTake] SET (LOCK_ESCALATION = TABLE)
GO
