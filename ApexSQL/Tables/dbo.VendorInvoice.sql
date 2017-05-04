SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[VendorInvoice] (
		[Oid]                       [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[InvoiceAmount]             [money] NULL,
		[Vendor]                    [uniqueidentifier] NULL,
		[InvoiceNumber]             [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[InvoiceDate]               [datetime] NULL,
		[Currency]                  [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[SubmittedForPaymentOn]     [datetime] NULL,
		[ReadyForPaymentOn]         [datetime] NULL,
		[PaidOn]                    [datetime] NULL,
		[ExcludeFromPayment]        [bit] NULL,
		[Note]                      [nvarchar](1000) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]       [int] NULL,
		[GCRecord]                  [int] NULL,
		CONSTRAINT [PK_VendorInvoice]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VendorInvoice]
	WITH NOCHECK
	ADD CONSTRAINT [FK_VendorInvoice_Vendor]
	FOREIGN KEY ([Vendor]) REFERENCES [dbo].[Vendor] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[VendorInvoice]
	CHECK CONSTRAINT [FK_VendorInvoice_Vendor]

GO
CREATE NONCLUSTERED INDEX [iGCRecord_VendorInvoice]
	ON [dbo].[VendorInvoice] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iVendor_VendorInvoice]
	ON [dbo].[VendorInvoice] ([Vendor])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[VendorInvoice] SET (LOCK_ESCALATION = TABLE)
GO
