SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CashEvent] (
		[Oid]                            [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[CashDrawer]                     [uniqueidentifier] NULL,
		[DateTime]                       [datetime] NULL,
		[Type]                           [int] NULL,
		[Reason]                         [int] NULL,
		[Cashier]                        [uniqueidentifier] NULL,
		[Currency]                       [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[CashIn]                         [money] NULL,
		[CashOut]                        [money] NULL,
		[Reconciliation]                 [uniqueidentifier] NULL,
		[Sale]                           [uniqueidentifier] NULL,
		[OptimisticLockField]            [int] NULL,
		[GCRecord]                       [int] NULL,
		[CashDrawerReconciliationID]     [int] NULL,
		CONSTRAINT [PK_CashEvent]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CashEvent]
	WITH NOCHECK
	ADD CONSTRAINT [FK_CashEvent_CashDrawer]
	FOREIGN KEY ([CashDrawer]) REFERENCES [dbo].[CashDrawer] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[CashEvent]
	CHECK CONSTRAINT [FK_CashEvent_CashDrawer]

GO
ALTER TABLE [dbo].[CashEvent]
	WITH NOCHECK
	ADD CONSTRAINT [FK_CashEvent_Cashier]
	FOREIGN KEY ([Cashier]) REFERENCES [dbo].[ExtendedSecurityUser] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[CashEvent]
	CHECK CONSTRAINT [FK_CashEvent_Cashier]

GO
ALTER TABLE [dbo].[CashEvent]
	WITH NOCHECK
	ADD CONSTRAINT [FK_CashEvent_Reconciliation]
	FOREIGN KEY ([CashDrawerReconciliationID]) REFERENCES [dbo].[CashDrawerReconciliation] ([CashDrawerReconciliationID])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[CashEvent]
	CHECK CONSTRAINT [FK_CashEvent_Reconciliation]

GO
ALTER TABLE [dbo].[CashEvent]
	WITH NOCHECK
	ADD CONSTRAINT [FK_CashEvent_Sale]
	FOREIGN KEY ([Sale]) REFERENCES [dbo].[Sale] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[CashEvent]
	CHECK CONSTRAINT [FK_CashEvent_Sale]

GO
CREATE NONCLUSTERED INDEX [iCashDrawer_CashEvent]
	ON [dbo].[CashEvent] ([CashDrawer])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iCashier_CashEvent]
	ON [dbo].[CashEvent] ([Cashier])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_CashEvent]
	ON [dbo].[CashEvent] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iReconciliation_CashEvent]
	ON [dbo].[CashEvent] ([Reconciliation])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iSale_CashEvent]
	ON [dbo].[CashEvent] ([Sale])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[CashEvent] SET (LOCK_ESCALATION = TABLE)
GO
