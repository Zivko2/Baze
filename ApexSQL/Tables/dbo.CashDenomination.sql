SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CashDenomination] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[Currency]                [uniqueidentifier] NULL,
		[Name]                    [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Value]                   [money] NULL,
		[Enabled]                 [bit] NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_CashDenomination]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CashDenomination]
	WITH NOCHECK
	ADD CONSTRAINT [FK_CashDenomination_Currency]
	FOREIGN KEY ([Currency]) REFERENCES [dbo].[Currency] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[CashDenomination]
	CHECK CONSTRAINT [FK_CashDenomination_Currency]

GO
CREATE NONCLUSTERED INDEX [iCurrency_CashDenomination]
	ON [dbo].[CashDenomination] ([Currency])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_CashDenomination]
	ON [dbo].[CashDenomination] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[CashDenomination] SET (LOCK_ESCALATION = TABLE)
GO
