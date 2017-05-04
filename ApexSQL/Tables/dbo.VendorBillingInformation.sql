SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[VendorBillingInformation] (
		[Oid]                       [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[Name]                      [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Description]               [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Note]                      [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
		[ContactName]               [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Address]                   [uniqueidentifier] NULL,
		[Email]                     [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[PhoneNumber1]              [uniqueidentifier] NULL,
		[PhoneNumber2]              [uniqueidentifier] NULL,
		[Website]                   [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[DefaultCurrency]           [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[ExternalReferenceCode]     [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]       [int] NULL,
		[GCRecord]                  [int] NULL,
		CONSTRAINT [PK_VendorBillingInformation]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[VendorBillingInformation]
	WITH NOCHECK
	ADD CONSTRAINT [FK_VendorBillingInformation_Address]
	FOREIGN KEY ([Address]) REFERENCES [dbo].[Address] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[VendorBillingInformation]
	CHECK CONSTRAINT [FK_VendorBillingInformation_Address]

GO
ALTER TABLE [dbo].[VendorBillingInformation]
	WITH NOCHECK
	ADD CONSTRAINT [FK_VendorBillingInformation_PhoneNumber1]
	FOREIGN KEY ([PhoneNumber1]) REFERENCES [dbo].[PhoneNumber] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[VendorBillingInformation]
	CHECK CONSTRAINT [FK_VendorBillingInformation_PhoneNumber1]

GO
ALTER TABLE [dbo].[VendorBillingInformation]
	WITH NOCHECK
	ADD CONSTRAINT [FK_VendorBillingInformation_PhoneNumber2]
	FOREIGN KEY ([PhoneNumber2]) REFERENCES [dbo].[PhoneNumber] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[VendorBillingInformation]
	CHECK CONSTRAINT [FK_VendorBillingInformation_PhoneNumber2]

GO
CREATE NONCLUSTERED INDEX [iAddress_VendorBillingInformation]
	ON [dbo].[VendorBillingInformation] ([Address])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_VendorBillingInformation]
	ON [dbo].[VendorBillingInformation] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iPhoneNumber1_VendorBillingInformation]
	ON [dbo].[VendorBillingInformation] ([PhoneNumber1])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iPhoneNumber2_VendorBillingInformation]
	ON [dbo].[VendorBillingInformation] ([PhoneNumber2])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[VendorBillingInformation] SET (LOCK_ESCALATION = TABLE)
GO
