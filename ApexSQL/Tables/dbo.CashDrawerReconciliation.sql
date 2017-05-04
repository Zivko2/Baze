SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[CashDrawerReconciliation] (
		[Oid]                            [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[CashDrawer]                     [uniqueidentifier] NULL,
		[StartingBalance]                [money] NULL,
		[CompletedBy]                    [uniqueidentifier] NULL,
		[ConfirmedBy]                    [uniqueidentifier] NULL,
		[CompletedOn]                    [datetime] NULL,
		[FinalBalance]                   [money] NULL,
		[FinancialTransferSet]           [uniqueidentifier] NULL,
		[OptimisticLockField]            [int] NULL,
		[GCRecord]                       [int] NULL,
		[CashDrawerReconciliationID]     [int] IDENTITY(1, 1) NOT NULL,
		CONSTRAINT [UQ_PK_CashDrawerReconciliation_545B0295]
		UNIQUE
		NONCLUSTERED
		([Oid])
		ON [PRIMARY],
		CONSTRAINT [PK_CashDrawerReconciliation]
		PRIMARY KEY
		CLUSTERED
		([CashDrawerReconciliationID])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CashDrawerReconciliation]
	WITH NOCHECK
	ADD CONSTRAINT [FK_CashDrawerReconciliation_CashDrawer]
	FOREIGN KEY ([CashDrawer]) REFERENCES [dbo].[CashDrawer] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[CashDrawerReconciliation]
	CHECK CONSTRAINT [FK_CashDrawerReconciliation_CashDrawer]

GO
ALTER TABLE [dbo].[CashDrawerReconciliation]
	WITH NOCHECK
	ADD CONSTRAINT [FK_CashDrawerReconciliation_CompletedBy]
	FOREIGN KEY ([CompletedBy]) REFERENCES [dbo].[ExtendedSecurityUser] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[CashDrawerReconciliation]
	CHECK CONSTRAINT [FK_CashDrawerReconciliation_CompletedBy]

GO
ALTER TABLE [dbo].[CashDrawerReconciliation]
	WITH NOCHECK
	ADD CONSTRAINT [FK_CashDrawerReconciliation_ConfirmedBy]
	FOREIGN KEY ([ConfirmedBy]) REFERENCES [dbo].[ExtendedSecurityUser] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[CashDrawerReconciliation]
	CHECK CONSTRAINT [FK_CashDrawerReconciliation_ConfirmedBy]

GO
ALTER TABLE [dbo].[CashDrawerReconciliation]
	WITH NOCHECK
	ADD CONSTRAINT [FK_CashDrawerReconciliation_FinancialTransferSet]
	FOREIGN KEY ([FinancialTransferSet]) REFERENCES [dbo].[FinancialTransferSet] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[CashDrawerReconciliation]
	CHECK CONSTRAINT [FK_CashDrawerReconciliation_FinancialTransferSet]

GO
CREATE NONCLUSTERED INDEX [iCashDrawer_CashDrawerReconciliation]
	ON [dbo].[CashDrawerReconciliation] ([CashDrawer])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iCompletedBy_CashDrawerReconciliation]
	ON [dbo].[CashDrawerReconciliation] ([CompletedBy])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iConfirmedBy_CashDrawerReconciliation]
	ON [dbo].[CashDrawerReconciliation] ([ConfirmedBy])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iFinancialTransferSet_CashDrawerReconciliation]
	ON [dbo].[CashDrawerReconciliation] ([FinancialTransferSet])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_CashDrawerReconciliation]
	ON [dbo].[CashDrawerReconciliation] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[CashDrawerReconciliation] SET (LOCK_ESCALATION = TABLE)
GO
