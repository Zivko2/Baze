SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[pedimpconciliaDet] (
		[Consecutivo]           [int] IDENTITY(1, 1) NOT NULL,
		[PI_CODIGO]             [int] NULL,
		[Pedimento]             [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[InvoiceNo]             [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[RecordNum]             [int] NULL,
		[PartNo]                [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DescSpanish]           [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Quantity]              [decimal](38, 6) NULL,
		[UM]                    [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[QtyUMHTS]              [decimal](38, 6) NULL,
		[UMHTS]                 [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[HTS]                   [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TotalValueMN]          [decimal](38, 6) NULL,
		[CountrySel]            [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CountryOrig]           [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[UnitValueAduanaMN]     [decimal](38, 6) NULL,
		[UnitValueUSD]          [decimal](38, 6) NULL,
		[PIB_INDICEB]           [int] NULL,
		[Sistema]               [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TotalValueAdu]         [decimal](38, 6) NULL,
		[AddValue]              [decimal](38, 6) NULL,
		CONSTRAINT [IX_pedimpconciliaDet]
		UNIQUE
		NONCLUSTERED
		([Consecutivo])
		ON [PRIMARY]
) ON [PRIMARY]
GO
