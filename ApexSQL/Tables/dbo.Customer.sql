SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Customer] (
		[Oid]                        [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[AccountNumberReference]     [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[CustomerCode]               [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Name]                       [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Address]                    [uniqueidentifier] NULL,
		[DefaultRateType]            [uniqueidentifier] NULL,
		[DefaultPaymentMethod]       [uniqueidentifier] NULL,
		[PhoneNumber1]               [uniqueidentifier] NULL,
		[PhoneNumber2]               [uniqueidentifier] NULL,
		[SaleAlertNote]              [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Email]                      [nvarchar](250) COLLATE Latin1_General_CI_AS NULL,
		[Website]                    [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Enabled]                    [bit] NULL,
		[BarCode]                    [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[ExternalBarCode]            [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[CurrenciesNotAllowed]       [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Note]                       [nvarchar](1000) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]        [int] NULL,
		[GCRecord]                   [int] NULL,
		CONSTRAINT [PK_Customer]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Customer]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Customer_Address]
	FOREIGN KEY ([Address]) REFERENCES [dbo].[Address] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Customer]
	CHECK CONSTRAINT [FK_Customer_Address]

GO
ALTER TABLE [dbo].[Customer]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Customer_DefaultPaymentMethod]
	FOREIGN KEY ([DefaultPaymentMethod]) REFERENCES [dbo].[PaymentMethod] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Customer]
	CHECK CONSTRAINT [FK_Customer_DefaultPaymentMethod]

GO
ALTER TABLE [dbo].[Customer]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Customer_DefaultRateType]
	FOREIGN KEY ([DefaultRateType]) REFERENCES [dbo].[RateType] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Customer]
	CHECK CONSTRAINT [FK_Customer_DefaultRateType]

GO
ALTER TABLE [dbo].[Customer]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Customer_PhoneNumber1]
	FOREIGN KEY ([PhoneNumber1]) REFERENCES [dbo].[PhoneNumber] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Customer]
	CHECK CONSTRAINT [FK_Customer_PhoneNumber1]

GO
ALTER TABLE [dbo].[Customer]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Customer_PhoneNumber2]
	FOREIGN KEY ([PhoneNumber2]) REFERENCES [dbo].[PhoneNumber] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Customer]
	CHECK CONSTRAINT [FK_Customer_PhoneNumber2]

GO
CREATE NONCLUSTERED INDEX [iAddress_Customer]
	ON [dbo].[Customer] ([Address])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iDefaultPaymentMethod_Customer]
	ON [dbo].[Customer] ([DefaultPaymentMethod])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iDefaultRateType_Customer]
	ON [dbo].[Customer] ([DefaultRateType])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_Customer]
	ON [dbo].[Customer] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iPhoneNumber1_Customer]
	ON [dbo].[Customer] ([PhoneNumber1])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iPhoneNumber2_Customer]
	ON [dbo].[Customer] ([PhoneNumber2])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Customer] SET (LOCK_ESCALATION = TABLE)
GO
