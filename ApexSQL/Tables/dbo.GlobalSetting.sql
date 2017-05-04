SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GlobalSetting] (
		[Oid]                                                      [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[CompanyName]                                              [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
		[DepartmentName]                                           [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
		[CompanyAddress]                                           [uniqueidentifier] NULL,
		[CompanyPhone]                                             [uniqueidentifier] NULL,
		[CompanyFax]                                               [uniqueidentifier] NULL,
		[CompanyEmail]                                             [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[CompanyWebsite]                                           [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[FinanceEmail]                                             [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[CompanyIdentificationCodeForFinance]                      [nvarchar](2) COLLATE Latin1_General_CI_AS NULL,
		[DefaultFinancialTransferDescription]                      [nvarchar](26) COLLATE Latin1_General_CI_AS NULL,
		[StartPageUrl]                                             [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[JiraUrl]                                                  [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[CompanyLogo]                                              [varbinary](max) NULL,
		[EstimatedToActualDeltasLastClearedOn]                     [datetime] NULL,
		[EnableCompleteSaleConfirmationForAnonymous]               [bit] NULL,
		[DocumentManagementSystemPath]                             [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[DocumentManagementSystemPathTest]                         [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[BarcodeScannerPrefixAsciiCode]                            [nvarchar](5) COLLATE Latin1_General_CI_AS NULL,
		[BarcodeScannerPrefixAsciiCodeAlternate]                   [nvarchar](5) COLLATE Latin1_General_CI_AS NULL,
		[BarcodeScannerSuffixAsciiCode]                            [nvarchar](5) COLLATE Latin1_General_CI_AS NULL,
		[BarcodeScannerSuffixAsciiCodeAlternate]                   [nvarchar](5) COLLATE Latin1_General_CI_AS NULL,
		[PurchaseOrderLineItemMaximumAmountWithoutApproval]        [money] NULL,
		[PurchaseOrderMaximumTotalAmountWithoutApproval]           [money] NULL,
		[PurchaseOrderLineItemMaximumAmountWithoutCfoApproval]     [money] NULL,
		[PurchaseOrderMaximumTotalAmountWithoutCfoApproval]        [money] NULL,
		[PromptToAssociateWorkOrderAndCustomerDuringSale]          [bit] NULL,
		[DefaultPurchaseOrderReport]                               [uniqueidentifier] NULL,
		[DefaultRepairOrderReport]                                 [uniqueidentifier] NULL,
		[DefaultRequestForQuoteReport]                             [uniqueidentifier] NULL,
		[DefaultPurchaseOrderInventoryAccount]                     [uniqueidentifier] NULL,
		[DefaultPurchaseOrderPrefix]                               [nvarchar](5) COLLATE Latin1_General_CI_AS NULL,
		[DefaultPurchaseOrderEmailSubject]                         [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[DefaultPurchaseOrderEmailBody]                            [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
		[DefaultPurchaseOrderFaxSubject]                           [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[DefaultPurchaseOrderFaxBody]                              [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
		[PurchaseOrderEmailSubjectReportName]                      [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
		[PurchaseOrderEmailBodyReportName]                         [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
		[PurchaseOrderFaxSubjectReportName]                        [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
		[PurchaseOrderFaxBodyReportName]                           [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
		[PurchaseOrderReportFooterLeftSignature]                   [nvarchar](500) COLLATE Latin1_General_CI_AS NULL,
		[PurchaseOrderReportFooterRightSignature]                  [nvarchar](500) COLLATE Latin1_General_CI_AS NULL,
		[DefaultSellByMode]                                        [int] NULL,
		[WorkOrderRequiredOnAllSales]                              [int] NULL,
		[DefaultWholesaleValueCalculationScope]                    [int] NULL,
		[DefaultInventoryAccount]                                  [uniqueidentifier] NULL,
		[DefaultSaleLineItemType]                                  [uniqueidentifier] NULL,
		[DefaultCashRoundingDifferenceSaleLineItemType]            [uniqueidentifier] NULL,
		[RequireCashDrawerForCashTransactions]                     [bit] NULL,
		[CashReconciliationOverShortAccount]                       [uniqueidentifier] NULL,
		[ClearingCashSalesAccount]                                 [uniqueidentifier] NULL,
		[ReceiptPrinterName]                                       [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
		[DefaultReceiptReport]                                     [uniqueidentifier] NULL,
		[DefaultCreditMemoReport]                                  [uniqueidentifier] NULL,
		[ReceiptPrintedByDefault]                                  [bit] NULL,
		[DaysToExpireExchangeRates]                                [float] NULL,
		[BaseCurrency]                                             [nvarchar](3) COLLATE Latin1_General_CI_AS NULL,
		[BaseWeightUnitOfMeasure]                                  [nvarchar](10) COLLATE Latin1_General_CI_AS NULL,
		[BaseVolumeUnitOfMeasure]                                  [nvarchar](10) COLLATE Latin1_General_CI_AS NULL,
		[DaysOfStatisticalDataToUseForWeightsAndVolume]            [int] NULL,
		[Note]                                                     [nvarchar](500) COLLATE Latin1_General_CI_AS NULL,
		[ItemPhotoEnabled]                                         [bit] NULL,
		[RequireAuthorizationForMissingVendorInvoices]             [bit] NULL,
		[DefaultSpecifyInventoryLocation]                          [bit] NULL,
		[CompanyPrefixToDistinguishBarCodes]                       [nvarchar](2) COLLATE Latin1_General_CI_AS NULL,
		[UseVendorInvoiceDateForExchangeRateWhenPossible]          [bit] NULL,
		[DefaultQuoteExpirationDays]                               [int] NULL,
		[FileAccessAccount]                                        [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
		[FileAccessAccountDomain]                                  [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
		[FileAccessAccountPasswordHash]                            [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
		[PrependSaleNumberWithCompanyCode]                         [bit] NULL,
		[PrependBatchNumberWithCompanyCode]                        [bit] NULL,
		[PrependPurchaseOrderNumberWithCompanyCode]                [bit] NULL,
		[PrependWorkOrderNumberWithCompanyCode]                    [bit] NULL,
		[AllowManualWorkOrderNumberEntry]                          [bit] NULL,
		[PrependSaleNumberWithDocumentPrefix]                      [bit] NULL,
		[PrependBatchNumberWithDocumentPrefix]                     [bit] NULL,
		[PrependWorkOrderNumberWithDocumentPrefix]                 [bit] NULL,
		[OptimisticLockField]                                      [int] NULL,
		[GCRecord]                                                 [int] NULL,
		CONSTRAINT [PK_GlobalSetting]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[GlobalSetting]
	WITH NOCHECK
	ADD CONSTRAINT [FK_GlobalSetting_CashReconciliationOverShortAccount]
	FOREIGN KEY ([CashReconciliationOverShortAccount]) REFERENCES [dbo].[GLAccount] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[GlobalSetting]
	CHECK CONSTRAINT [FK_GlobalSetting_CashReconciliationOverShortAccount]

GO
ALTER TABLE [dbo].[GlobalSetting]
	WITH NOCHECK
	ADD CONSTRAINT [FK_GlobalSetting_ClearingCashSalesAccount]
	FOREIGN KEY ([ClearingCashSalesAccount]) REFERENCES [dbo].[GLAccount] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[GlobalSetting]
	CHECK CONSTRAINT [FK_GlobalSetting_ClearingCashSalesAccount]

GO
ALTER TABLE [dbo].[GlobalSetting]
	WITH NOCHECK
	ADD CONSTRAINT [FK_GlobalSetting_CompanyAddress]
	FOREIGN KEY ([CompanyAddress]) REFERENCES [dbo].[Address] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[GlobalSetting]
	CHECK CONSTRAINT [FK_GlobalSetting_CompanyAddress]

GO
ALTER TABLE [dbo].[GlobalSetting]
	WITH NOCHECK
	ADD CONSTRAINT [FK_GlobalSetting_CompanyFax]
	FOREIGN KEY ([CompanyFax]) REFERENCES [dbo].[PhoneNumber] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[GlobalSetting]
	CHECK CONSTRAINT [FK_GlobalSetting_CompanyFax]

GO
ALTER TABLE [dbo].[GlobalSetting]
	WITH NOCHECK
	ADD CONSTRAINT [FK_GlobalSetting_CompanyPhone]
	FOREIGN KEY ([CompanyPhone]) REFERENCES [dbo].[PhoneNumber] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[GlobalSetting]
	CHECK CONSTRAINT [FK_GlobalSetting_CompanyPhone]

GO
ALTER TABLE [dbo].[GlobalSetting]
	WITH NOCHECK
	ADD CONSTRAINT [FK_GlobalSetting_DefaultCashRoundingDifferenceSaleLineItemType]
	FOREIGN KEY ([DefaultCashRoundingDifferenceSaleLineItemType]) REFERENCES [dbo].[SaleLineItemType] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[GlobalSetting]
	CHECK CONSTRAINT [FK_GlobalSetting_DefaultCashRoundingDifferenceSaleLineItemType]

GO
ALTER TABLE [dbo].[GlobalSetting]
	WITH NOCHECK
	ADD CONSTRAINT [FK_GlobalSetting_DefaultCreditMemoReport]
	FOREIGN KEY ([DefaultCreditMemoReport]) REFERENCES [dbo].[ReportDataV2] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[GlobalSetting]
	CHECK CONSTRAINT [FK_GlobalSetting_DefaultCreditMemoReport]

GO
ALTER TABLE [dbo].[GlobalSetting]
	WITH NOCHECK
	ADD CONSTRAINT [FK_GlobalSetting_DefaultInventoryAccount]
	FOREIGN KEY ([DefaultInventoryAccount]) REFERENCES [dbo].[InventoryAccount] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[GlobalSetting]
	CHECK CONSTRAINT [FK_GlobalSetting_DefaultInventoryAccount]

GO
ALTER TABLE [dbo].[GlobalSetting]
	WITH NOCHECK
	ADD CONSTRAINT [FK_GlobalSetting_DefaultPurchaseOrderInventoryAccount]
	FOREIGN KEY ([DefaultPurchaseOrderInventoryAccount]) REFERENCES [dbo].[InventoryAccount] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[GlobalSetting]
	CHECK CONSTRAINT [FK_GlobalSetting_DefaultPurchaseOrderInventoryAccount]

GO
ALTER TABLE [dbo].[GlobalSetting]
	WITH NOCHECK
	ADD CONSTRAINT [FK_GlobalSetting_DefaultPurchaseOrderReport]
	FOREIGN KEY ([DefaultPurchaseOrderReport]) REFERENCES [dbo].[ReportDataV2] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[GlobalSetting]
	CHECK CONSTRAINT [FK_GlobalSetting_DefaultPurchaseOrderReport]

GO
ALTER TABLE [dbo].[GlobalSetting]
	WITH NOCHECK
	ADD CONSTRAINT [FK_GlobalSetting_DefaultReceiptReport]
	FOREIGN KEY ([DefaultReceiptReport]) REFERENCES [dbo].[ReportDataV2] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[GlobalSetting]
	CHECK CONSTRAINT [FK_GlobalSetting_DefaultReceiptReport]

GO
ALTER TABLE [dbo].[GlobalSetting]
	WITH NOCHECK
	ADD CONSTRAINT [FK_GlobalSetting_DefaultRepairOrderReport]
	FOREIGN KEY ([DefaultRepairOrderReport]) REFERENCES [dbo].[ReportDataV2] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[GlobalSetting]
	CHECK CONSTRAINT [FK_GlobalSetting_DefaultRepairOrderReport]

GO
ALTER TABLE [dbo].[GlobalSetting]
	WITH NOCHECK
	ADD CONSTRAINT [FK_GlobalSetting_DefaultRequestForQuoteReport]
	FOREIGN KEY ([DefaultRequestForQuoteReport]) REFERENCES [dbo].[ReportDataV2] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[GlobalSetting]
	CHECK CONSTRAINT [FK_GlobalSetting_DefaultRequestForQuoteReport]

GO
ALTER TABLE [dbo].[GlobalSetting]
	WITH NOCHECK
	ADD CONSTRAINT [FK_GlobalSetting_DefaultSaleLineItemType]
	FOREIGN KEY ([DefaultSaleLineItemType]) REFERENCES [dbo].[SaleLineItemType] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[GlobalSetting]
	CHECK CONSTRAINT [FK_GlobalSetting_DefaultSaleLineItemType]

GO
CREATE NONCLUSTERED INDEX [iCashReconciliationOverShortAccount_GlobalSetting]
	ON [dbo].[GlobalSetting] ([CashReconciliationOverShortAccount])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iClearingCashSalesAccount_GlobalSetting]
	ON [dbo].[GlobalSetting] ([ClearingCashSalesAccount])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iCompanyAddress_GlobalSetting]
	ON [dbo].[GlobalSetting] ([CompanyAddress])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iCompanyFax_GlobalSetting]
	ON [dbo].[GlobalSetting] ([CompanyFax])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iCompanyPhone_GlobalSetting]
	ON [dbo].[GlobalSetting] ([CompanyPhone])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iDefaultCashRoundingDifferenceSaleLineItemType_GlobalSetting]
	ON [dbo].[GlobalSetting] ([DefaultCashRoundingDifferenceSaleLineItemType])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iDefaultCreditMemoReport_GlobalSetting]
	ON [dbo].[GlobalSetting] ([DefaultCreditMemoReport])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iDefaultInventoryAccount_GlobalSetting]
	ON [dbo].[GlobalSetting] ([DefaultInventoryAccount])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iDefaultPurchaseOrderInventoryAccount_GlobalSetting]
	ON [dbo].[GlobalSetting] ([DefaultPurchaseOrderInventoryAccount])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iDefaultPurchaseOrderReport_GlobalSetting]
	ON [dbo].[GlobalSetting] ([DefaultPurchaseOrderReport])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iDefaultReceiptReport_GlobalSetting]
	ON [dbo].[GlobalSetting] ([DefaultReceiptReport])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iDefaultRepairOrderReport_GlobalSetting]
	ON [dbo].[GlobalSetting] ([DefaultRepairOrderReport])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iDefaultRequestForQuoteReport_GlobalSetting]
	ON [dbo].[GlobalSetting] ([DefaultRequestForQuoteReport])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iDefaultSaleLineItemType_GlobalSetting]
	ON [dbo].[GlobalSetting] ([DefaultSaleLineItemType])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_GlobalSetting]
	ON [dbo].[GlobalSetting] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[GlobalSetting] SET (LOCK_ESCALATION = TABLE)
GO
