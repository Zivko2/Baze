SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RateType] (
		[Oid]                                      [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[LineNumber]                               [int] NULL,
		[Name]                                     [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Description]                              [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[AggregateSalesInFinancialTransferSet]     [bit] NULL,
		[MustBeCustomerDefault]                    [bit] NULL,
		[DefaultPaymentMethod]                     [uniqueidentifier] NULL,
		[DisallowSaleOfServices]                   [bit] NULL,
		[OptimisticLockField]                      [int] NULL,
		[GCRecord]                                 [int] NULL,
		CONSTRAINT [PK_RateType]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RateType]
	WITH NOCHECK
	ADD CONSTRAINT [FK_RateType_DefaultPaymentMethod]
	FOREIGN KEY ([DefaultPaymentMethod]) REFERENCES [dbo].[PaymentMethod] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[RateType]
	CHECK CONSTRAINT [FK_RateType_DefaultPaymentMethod]

GO
CREATE NONCLUSTERED INDEX [iDefaultPaymentMethod_RateType]
	ON [dbo].[RateType] ([DefaultPaymentMethod])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_RateType]
	ON [dbo].[RateType] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[RateType] SET (LOCK_ESCALATION = TABLE)
GO
