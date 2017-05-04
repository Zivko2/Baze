SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Sale] (
		[Oid]                        [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[SaleNumber]                 [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[MarkedAsQuoteBy]            [uniqueidentifier] NULL,
		[CompletedBy]                [uniqueidentifier] NULL,
		[BarCode]                    [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[ProcessedOnBehalfOf]        [uniqueidentifier] NULL,
		[TransactionDescription]     [nvarchar](16) COLLATE Latin1_General_CI_AS NULL,
		[TransactionDate]            [datetime] NULL,
		[CompletedOn]                [datetime] NULL,
		[MarkedAsQuoteOn]            [datetime] NULL,
		[QuoteExpiresOn]             [datetime] NULL,
		[CreatedOn]                  [datetime] NULL,
		[Currency]                   [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Customer]                   [uniqueidentifier] NULL,
		[LockInAllPrices]            [bit] NULL,
		[QuoteCancelled]             [bit] NULL,
		[QuoteDescription]           [nvarchar](1000) COLLATE Latin1_General_CI_AS NULL,
		[PaymentMethod]              [uniqueidentifier] NULL,
		[FinancialTransferSet]       [uniqueidentifier] NULL,
		[RateType]                   [uniqueidentifier] NULL,
		[WorkOrder]                  [uniqueidentifier] NULL,
		[ReserveItemsOnThisSale]     [bit] NULL,
		[CreatedBy]                  [uniqueidentifier] NULL,
		[OptimisticLockField]        [int] NULL,
		[GCRecord]                   [int] NULL,
		CONSTRAINT [PK_Sale]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Sale]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Sale_CompletedBy]
	FOREIGN KEY ([CompletedBy]) REFERENCES [dbo].[ExtendedSecurityUser] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Sale]
	CHECK CONSTRAINT [FK_Sale_CompletedBy]

GO
ALTER TABLE [dbo].[Sale]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Sale_CreatedBy]
	FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[ExtendedSecurityUser] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Sale]
	CHECK CONSTRAINT [FK_Sale_CreatedBy]

GO
ALTER TABLE [dbo].[Sale]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Sale_Customer]
	FOREIGN KEY ([Customer]) REFERENCES [dbo].[Customer] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Sale]
	CHECK CONSTRAINT [FK_Sale_Customer]

GO
ALTER TABLE [dbo].[Sale]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Sale_FinancialTransferSet]
	FOREIGN KEY ([FinancialTransferSet]) REFERENCES [dbo].[FinancialTransferSet] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Sale]
	CHECK CONSTRAINT [FK_Sale_FinancialTransferSet]

GO
ALTER TABLE [dbo].[Sale]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Sale_MarkedAsQuoteBy]
	FOREIGN KEY ([MarkedAsQuoteBy]) REFERENCES [dbo].[ExtendedSecurityUser] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Sale]
	CHECK CONSTRAINT [FK_Sale_MarkedAsQuoteBy]

GO
ALTER TABLE [dbo].[Sale]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Sale_PaymentMethod]
	FOREIGN KEY ([PaymentMethod]) REFERENCES [dbo].[PaymentMethod] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Sale]
	CHECK CONSTRAINT [FK_Sale_PaymentMethod]

GO
ALTER TABLE [dbo].[Sale]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Sale_ProcessedOnBehalfOf]
	FOREIGN KEY ([ProcessedOnBehalfOf]) REFERENCES [dbo].[ExtendedSecurityUser] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Sale]
	CHECK CONSTRAINT [FK_Sale_ProcessedOnBehalfOf]

GO
ALTER TABLE [dbo].[Sale]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Sale_RateType]
	FOREIGN KEY ([RateType]) REFERENCES [dbo].[RateType] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Sale]
	CHECK CONSTRAINT [FK_Sale_RateType]

GO
ALTER TABLE [dbo].[Sale]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Sale_WorkOrder]
	FOREIGN KEY ([WorkOrder]) REFERENCES [dbo].[WorkOrder] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Sale]
	CHECK CONSTRAINT [FK_Sale_WorkOrder]

GO
CREATE NONCLUSTERED INDEX [iCompletedBy_Sale]
	ON [dbo].[Sale] ([CompletedBy])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iCreatedBy_Sale]
	ON [dbo].[Sale] ([CreatedBy])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iCustomer_Sale]
	ON [dbo].[Sale] ([Customer])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iFinancialTransferSet_Sale]
	ON [dbo].[Sale] ([FinancialTransferSet])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_Sale]
	ON [dbo].[Sale] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iMarkedAsQuoteBy_Sale]
	ON [dbo].[Sale] ([MarkedAsQuoteBy])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iPaymentMethod_Sale]
	ON [dbo].[Sale] ([PaymentMethod])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iProcessedOnBehalfOf_Sale]
	ON [dbo].[Sale] ([ProcessedOnBehalfOf])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iRateType_Sale]
	ON [dbo].[Sale] ([RateType])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iWorkOrder_Sale]
	ON [dbo].[Sale] ([WorkOrder])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Sale] SET (LOCK_ESCALATION = TABLE)
GO
