SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[IncomeAccount] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[AccountingGroup]         [uniqueidentifier] NULL,
		[IncomeGLAccount]         [uniqueidentifier] NULL,
		[RateType]                [uniqueidentifier] NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_IncomeAccount]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IncomeAccount]
	WITH NOCHECK
	ADD CONSTRAINT [FK_IncomeAccount_AccountingGroup]
	FOREIGN KEY ([AccountingGroup]) REFERENCES [dbo].[AccountingGroup] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[IncomeAccount]
	CHECK CONSTRAINT [FK_IncomeAccount_AccountingGroup]

GO
ALTER TABLE [dbo].[IncomeAccount]
	WITH NOCHECK
	ADD CONSTRAINT [FK_IncomeAccount_IncomeGLAccount]
	FOREIGN KEY ([IncomeGLAccount]) REFERENCES [dbo].[GLAccount] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[IncomeAccount]
	CHECK CONSTRAINT [FK_IncomeAccount_IncomeGLAccount]

GO
ALTER TABLE [dbo].[IncomeAccount]
	WITH NOCHECK
	ADD CONSTRAINT [FK_IncomeAccount_RateType]
	FOREIGN KEY ([RateType]) REFERENCES [dbo].[RateType] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[IncomeAccount]
	CHECK CONSTRAINT [FK_IncomeAccount_RateType]

GO
CREATE NONCLUSTERED INDEX [iAccountingGroup_IncomeAccount]
	ON [dbo].[IncomeAccount] ([AccountingGroup])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_IncomeAccount]
	ON [dbo].[IncomeAccount] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iIncomeGLAccount_IncomeAccount]
	ON [dbo].[IncomeAccount] ([IncomeGLAccount])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iRateType_IncomeAccount]
	ON [dbo].[IncomeAccount] ([RateType])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[IncomeAccount] SET (LOCK_ESCALATION = TABLE)
GO
