SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Vendor] (
		[Oid]                              [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[VendorBillingInformation]         [uniqueidentifier] NULL,
		[Name]                             [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Description]                      [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Note]                             [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
		[ContactName]                      [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Address]                          [uniqueidentifier] NULL,
		[Email]                            [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[PhoneNumber1]                     [uniqueidentifier] NULL,
		[PhoneNumber2]                     [uniqueidentifier] NULL,
		[Website]                          [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[DefaultCurrency]                  [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[ShowInSupplyVendorLists]          [bit] NULL,
		[ShowInLogisticsVendorLists]       [bit] NULL,
		[DefaultShippingMethod]            [uniqueidentifier] NULL,
		[PurchaseOrderNumberPrefix]        [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[DefaultPurchaseOrderReport]       [uniqueidentifier] NULL,
		[DefaultRepairOrderReport]         [uniqueidentifier] NULL,
		[DefaultRequestForQuoteReport]     [uniqueidentifier] NULL,
		[DefaultToExcludeFromPayment]      [bit] NULL,
		[InactivatedOn]                    [datetime] NULL,
		[OptimisticLockField]              [int] NULL,
		[GCRecord]                         [int] NULL,
		CONSTRAINT [PK_Vendor]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Vendor]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Vendor_Address]
	FOREIGN KEY ([Address]) REFERENCES [dbo].[Address] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Vendor]
	CHECK CONSTRAINT [FK_Vendor_Address]

GO
ALTER TABLE [dbo].[Vendor]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Vendor_DefaultPurchaseOrderReport]
	FOREIGN KEY ([DefaultPurchaseOrderReport]) REFERENCES [dbo].[ReportDataV2] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Vendor]
	CHECK CONSTRAINT [FK_Vendor_DefaultPurchaseOrderReport]

GO
ALTER TABLE [dbo].[Vendor]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Vendor_DefaultRepairOrderReport]
	FOREIGN KEY ([DefaultRepairOrderReport]) REFERENCES [dbo].[ReportDataV2] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Vendor]
	CHECK CONSTRAINT [FK_Vendor_DefaultRepairOrderReport]

GO
ALTER TABLE [dbo].[Vendor]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Vendor_DefaultRequestForQuoteReport]
	FOREIGN KEY ([DefaultRequestForQuoteReport]) REFERENCES [dbo].[ReportDataV2] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Vendor]
	CHECK CONSTRAINT [FK_Vendor_DefaultRequestForQuoteReport]

GO
ALTER TABLE [dbo].[Vendor]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Vendor_DefaultShippingMethod]
	FOREIGN KEY ([DefaultShippingMethod]) REFERENCES [dbo].[ShippingMethod] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Vendor]
	CHECK CONSTRAINT [FK_Vendor_DefaultShippingMethod]

GO
ALTER TABLE [dbo].[Vendor]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Vendor_PhoneNumber1]
	FOREIGN KEY ([PhoneNumber1]) REFERENCES [dbo].[PhoneNumber] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Vendor]
	CHECK CONSTRAINT [FK_Vendor_PhoneNumber1]

GO
ALTER TABLE [dbo].[Vendor]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Vendor_PhoneNumber2]
	FOREIGN KEY ([PhoneNumber2]) REFERENCES [dbo].[PhoneNumber] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Vendor]
	CHECK CONSTRAINT [FK_Vendor_PhoneNumber2]

GO
ALTER TABLE [dbo].[Vendor]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Vendor_VendorBillingInformation]
	FOREIGN KEY ([VendorBillingInformation]) REFERENCES [dbo].[VendorBillingInformation] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Vendor]
	CHECK CONSTRAINT [FK_Vendor_VendorBillingInformation]

GO
CREATE NONCLUSTERED INDEX [iAddress_Vendor]
	ON [dbo].[Vendor] ([Address])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iDefaultPurchaseOrderReport_Vendor]
	ON [dbo].[Vendor] ([DefaultPurchaseOrderReport])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iDefaultRepairOrderReport_Vendor]
	ON [dbo].[Vendor] ([DefaultRepairOrderReport])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iDefaultRequestForQuoteReport_Vendor]
	ON [dbo].[Vendor] ([DefaultRequestForQuoteReport])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iDefaultShippingMethod_Vendor]
	ON [dbo].[Vendor] ([DefaultShippingMethod])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_Vendor]
	ON [dbo].[Vendor] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iPhoneNumber1_Vendor]
	ON [dbo].[Vendor] ([PhoneNumber1])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iPhoneNumber2_Vendor]
	ON [dbo].[Vendor] ([PhoneNumber2])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iVendorBillingInformation_Vendor]
	ON [dbo].[Vendor] ([VendorBillingInformation])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Vendor] SET (LOCK_ESCALATION = TABLE)
GO
