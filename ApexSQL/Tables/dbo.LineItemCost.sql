SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LineItemCost] (
		[Oid]                                            [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[ActualCostEnteredOn]                            [datetime] NULL,
		[EstimatedToActualDelta]                         [money] NULL,
		[RemainingDeltaToAbsorb]                         [money] NULL,
		[LineNumber]                                     [int] NULL,
		[BatchLineItem]                                  [uniqueidentifier] NULL,
		[CostType]                                       [uniqueidentifier] NULL,
		[CalculatedCostAmount]                           [money] NULL,
		[CalculatedCostIsoCode]                          [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[CalculatedCostExchangeRateDate]                 [datetime] NULL,
		[CalculatedCostBaseAmount]                       [money] NULL,
		[CalculatedCostExchangeRate]                     [money] NULL,
		[CalculatedCostForcedIsoCode]                    [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[CalculatedCostForcedExchangeRateDate]           [datetime] NULL,
		[CalculatedAdjustmentAmount]                     [money] NULL,
		[CalculatedAdjustmentIsoCode]                    [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[CalculatedAdjustmentExchangeRateDate]           [datetime] NULL,
		[CalculatedAdjustmentBaseAmount]                 [money] NULL,
		[CalculatedAdjustmentExchangeRate]               [money] NULL,
		[CalculatedAdjustmentForcedIsoCode]              [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[CalculatedAdjustmentForcedExchangeRateDate]     [datetime] NULL,
		[EstimatedCostAmount]                            [money] NULL,
		[EstimatedCostIsoCode]                           [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[EstimatedCostExchangeRateDate]                  [datetime] NULL,
		[EstimatedCostBaseAmount]                        [money] NULL,
		[EstimatedCostExchangeRate]                      [money] NULL,
		[EstimatedCostForcedIsoCode]                     [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[EstimatedCostForcedExchangeRateDate]            [datetime] NULL,
		[ActualAdjustmentAmount]                         [money] NULL,
		[ActualAdjustmentIsoCode]                        [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[ActualAdjustmentExchangeRateDate]               [datetime] NULL,
		[ActualAdjustmentBaseAmount]                     [money] NULL,
		[ActualAdjustmentExchangeRate]                   [money] NULL,
		[ActualAdjustmentForcedIsoCode]                  [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[ActualAdjustmentForcedExchangeRateDate]         [datetime] NULL,
		[ActualCostAmount]                               [money] NULL,
		[ActualCostIsoCode]                              [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[ActualCostExchangeRateDate]                     [datetime] NULL,
		[ActualCostBaseAmount]                           [money] NULL,
		[ActualCostExchangeRate]                         [money] NULL,
		[ActualCostForcedIsoCode]                        [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[ActualCostForcedExchangeRateDate]               [datetime] NULL,
		[VendorInvoice]                                  [uniqueidentifier] NULL,
		[ExcludeFromPayment]                             [bit] NULL,
		[PaidOn]                                         [datetime] NULL,
		[CreatedPostReceived]                            [bit] NULL,
		[ApplyToLandedUnitCost]                          [bit] NULL,
		[AppliedToLandedUnitCostOn]                      [datetime] NULL,
		[AppliedToLandedUnitCostBy]                      [uniqueidentifier] NULL,
		[Note]                                           [nvarchar](1000) COLLATE Latin1_General_CI_AS NULL,
		[FinancialTransferSet]                           [uniqueidentifier] NULL,
		[OptimisticLockField]                            [int] NULL,
		[GCRecord]                                       [int] NULL,
		CONSTRAINT [PK_LineItemCost]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LineItemCost]
	WITH NOCHECK
	ADD CONSTRAINT [FK_LineItemCost_AppliedToLandedUnitCostBy]
	FOREIGN KEY ([AppliedToLandedUnitCostBy]) REFERENCES [dbo].[ExtendedSecurityUser] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[LineItemCost]
	CHECK CONSTRAINT [FK_LineItemCost_AppliedToLandedUnitCostBy]

GO
ALTER TABLE [dbo].[LineItemCost]
	WITH NOCHECK
	ADD CONSTRAINT [FK_LineItemCost_BatchLineItem]
	FOREIGN KEY ([BatchLineItem]) REFERENCES [dbo].[BatchLineItem] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[LineItemCost]
	CHECK CONSTRAINT [FK_LineItemCost_BatchLineItem]

GO
ALTER TABLE [dbo].[LineItemCost]
	WITH NOCHECK
	ADD CONSTRAINT [FK_LineItemCost_CostType]
	FOREIGN KEY ([CostType]) REFERENCES [dbo].[CostType] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[LineItemCost]
	CHECK CONSTRAINT [FK_LineItemCost_CostType]

GO
ALTER TABLE [dbo].[LineItemCost]
	WITH NOCHECK
	ADD CONSTRAINT [FK_LineItemCost_FinancialTransferSet]
	FOREIGN KEY ([FinancialTransferSet]) REFERENCES [dbo].[FinancialTransferSet] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[LineItemCost]
	CHECK CONSTRAINT [FK_LineItemCost_FinancialTransferSet]

GO
ALTER TABLE [dbo].[LineItemCost]
	WITH NOCHECK
	ADD CONSTRAINT [FK_LineItemCost_VendorInvoice]
	FOREIGN KEY ([VendorInvoice]) REFERENCES [dbo].[VendorInvoice] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[LineItemCost]
	CHECK CONSTRAINT [FK_LineItemCost_VendorInvoice]

GO
CREATE NONCLUSTERED INDEX [iAppliedToLandedUnitCostBy_LineItemCost]
	ON [dbo].[LineItemCost] ([AppliedToLandedUnitCostBy])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iBatchLineItem_LineItemCost]
	ON [dbo].[LineItemCost] ([BatchLineItem])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iCostType_LineItemCost]
	ON [dbo].[LineItemCost] ([CostType])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iFinancialTransferSet_LineItemCost]
	ON [dbo].[LineItemCost] ([FinancialTransferSet])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_LineItemCost]
	ON [dbo].[LineItemCost] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iVendorInvoice_LineItemCost]
	ON [dbo].[LineItemCost] ([VendorInvoice])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[LineItemCost] SET (LOCK_ESCALATION = TABLE)
GO
