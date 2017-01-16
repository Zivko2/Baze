SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[pedimpconciliaInvoice] (
		[PI_CODIGO]              [int] NULL,
		[Pedimento]              [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[InvoiceNo]              [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Supplier_Client]        [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Supplier_ClientIRS]     [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[InvoiceDate]            [datetime] NULL,
		[Incoterms]              [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Currency]               [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ValueForeignCurr]       [decimal](38, 6) NULL,
		[ValueUSD]               [decimal](38, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[pedimpconciliaInvoice] SET (LOCK_ESCALATION = TABLE)
GO
