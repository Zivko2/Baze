SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[LineItemCostAbsorptionHistory] (
		[Oid]                                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[LineItemCostAbsorptionContributions]     [uniqueidentifier] NULL,
		[LineItemCostAbsorptionReceipts]          [uniqueidentifier] NULL,
		[Amount]                                  [money] NULL,
		[OccurredOn]                              [datetime] NULL,
		[OptimisticLockField]                     [int] NULL,
		[GCRecord]                                [int] NULL,
		CONSTRAINT [PK_LineItemCostAbsorptionHistory]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LineItemCostAbsorptionHistory]
	WITH NOCHECK
	ADD CONSTRAINT [FK_LineItemCostAbsorptionHistory_LineItemCostAbsorptionContributions]
	FOREIGN KEY ([LineItemCostAbsorptionContributions]) REFERENCES [dbo].[LineItemCost] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[LineItemCostAbsorptionHistory]
	CHECK CONSTRAINT [FK_LineItemCostAbsorptionHistory_LineItemCostAbsorptionContributions]

GO
ALTER TABLE [dbo].[LineItemCostAbsorptionHistory]
	WITH NOCHECK
	ADD CONSTRAINT [FK_LineItemCostAbsorptionHistory_LineItemCostAbsorptionReceipts]
	FOREIGN KEY ([LineItemCostAbsorptionReceipts]) REFERENCES [dbo].[LineItemCost] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[LineItemCostAbsorptionHistory]
	CHECK CONSTRAINT [FK_LineItemCostAbsorptionHistory_LineItemCostAbsorptionReceipts]

GO
CREATE NONCLUSTERED INDEX [iGCRecord_LineItemCostAbsorptionHistory]
	ON [dbo].[LineItemCostAbsorptionHistory] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iLineItemCostAbsorptionContributions_LineItemCostAbsorptionHistory]
	ON [dbo].[LineItemCostAbsorptionHistory] ([LineItemCostAbsorptionContributions])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iLineItemCostAbsorptionReceipts_LineItemCostAbsorptionHistory]
	ON [dbo].[LineItemCostAbsorptionHistory] ([LineItemCostAbsorptionReceipts])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[LineItemCostAbsorptionHistory] SET (LOCK_ESCALATION = TABLE)
GO
