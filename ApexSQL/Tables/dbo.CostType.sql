SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CostType] (
		[Oid]                                    [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[Vendor]                                 [uniqueidentifier] NULL,
		[Name]                                   [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[DefaultGLAccount]                       [uniqueidentifier] NULL,
		[AccountToCredit]                        [uniqueidentifier] NULL,
		[GenerateAccountTransfers]               [bit] NULL,
		[Priorityc]                              [int] NULL,
		[ExcludeFromCostCalculations]            [bit] NULL,
		[TotalDeltaBalance]                      [money] NULL,
		[IntendedForDistributedCosts]            [bit] NULL,
		[IsItemPrice]                            [bit] NULL,
		[ManualOverrideAbsorptionRate]           [money] NULL,
		[DaysToBalanceDeltas]                    [int] NULL,
		[MinimumIntervalHistory]                 [int] NULL,
		[MaximumIntervalHistory]                 [int] NULL,
		[CalculatedAbsorptionRateExpriesOn]      [datetime] NULL,
		[CalculationFormula]                     [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
		[CalculatedFormulaVariable]              [money] NULL,
		[MathematicalOperator]                   [int] NULL,
		[FormulaVariable]                        [money] NULL,
		[AutomaticallyUseCalculatedVariable]     [bit] NULL,
		[Description]                            [nvarchar](1000) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]                    [int] NULL,
		[GCRecord]                               [int] NULL,
		CONSTRAINT [PK_CostType]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CostType]
	WITH NOCHECK
	ADD CONSTRAINT [FK_CostType_AccountToCredit]
	FOREIGN KEY ([AccountToCredit]) REFERENCES [dbo].[GLAccount] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[CostType]
	CHECK CONSTRAINT [FK_CostType_AccountToCredit]

GO
ALTER TABLE [dbo].[CostType]
	WITH NOCHECK
	ADD CONSTRAINT [FK_CostType_DefaultGLAccount]
	FOREIGN KEY ([DefaultGLAccount]) REFERENCES [dbo].[GLAccount] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[CostType]
	CHECK CONSTRAINT [FK_CostType_DefaultGLAccount]

GO
ALTER TABLE [dbo].[CostType]
	WITH NOCHECK
	ADD CONSTRAINT [FK_CostType_Vendor]
	FOREIGN KEY ([Vendor]) REFERENCES [dbo].[Vendor] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[CostType]
	CHECK CONSTRAINT [FK_CostType_Vendor]

GO
CREATE NONCLUSTERED INDEX [iAccountToCredit_CostType]
	ON [dbo].[CostType] ([AccountToCredit])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iDefaultGLAccount_CostType]
	ON [dbo].[CostType] ([DefaultGLAccount])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_CostType]
	ON [dbo].[CostType] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iVendor_CostType]
	ON [dbo].[CostType] ([Vendor])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[CostType] SET (LOCK_ESCALATION = TABLE)
GO
