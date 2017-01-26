SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[pedimpconcilia] (
		[PI_CODIGO]           [int] NULL,
		[Pedimento]           [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OperationType]       [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PedimentoCode]       [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NumberShipments]     [int] NULL,
		[ConversionRate]      [decimal](38, 6) NULL,
		[GrossWeight]         [decimal](38, 6) NULL,
		[CustomSection]       [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TotalValueUSD]       [decimal](38, 6) NULL,
		[TotalValueAduMn]     [decimal](38, 6) NULL,
		[TotalValueMN]        [decimal](38, 6) NULL,
		[InsuranceCost]       [decimal](38, 6) NULL,
		[FreightCost]         [decimal](38, 6) NULL,
		[PackagesCost]        [decimal](38, 6) NULL,
		[OtherCost]           [decimal](38, 6) NULL,
		[EntryDate]           [datetime] NULL,
		[PaymentDate]         [datetime] NULL,
		[InitialDate]         [datetime] NULL,
		[FinalDate]           [datetime] NULL,
		[ElectronicSig]       [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TotalAmount]         [decimal](38, 6) NULL,
		[TotalAmountCash]     [decimal](38, 6) NULL,
		[RFCImporter]         [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TransMode]           [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
