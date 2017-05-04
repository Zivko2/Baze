SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PaymentMethod] (
		[Oid]                               [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[LineNumber]                        [int] NULL,
		[Name]                              [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Description]                       [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[IsCash]                            [bit] NULL,
		[IsCheque]                          [bit] NULL,
		[CurrenciesNotAllowed]              [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[DefaultCurrency]                   [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[IncludeInFinancialTransferSet]     [bit] NULL,
		[OptimisticLockField]               [int] NULL,
		[GCRecord]                          [int] NULL,
		CONSTRAINT [PK_PaymentMethod]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_PaymentMethod]
	ON [dbo].[PaymentMethod] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[PaymentMethod] SET (LOCK_ESCALATION = TABLE)
GO
