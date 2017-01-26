SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

















CREATE PROCEDURE [dbo].[sp_CreaTempEntryConcilia]   as



exec sp_droptable 'TempEntryConcilia'

CREATE TABLE [dbo].[TempEntryConcilia](
	[ClientCode] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BrokerCode] [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[EntryNumber] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[EntryDate] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReferenceNumber] [varchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PartNumber] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Country] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Quantity] decimal(38,6) NULL,
	[SpecialProgramIndicator] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[HarmonizedNo] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CommercialValue] decimal(38,6) NULL,
	[NueveOchoCeroDosValue] decimal(38,6) NULL,
	[DutyValue] decimal(38,6) NULL,
	[DutyRate] decimal(38,6) NULL,
	[DutyPaid] decimal(38,6) NULL,
	[Location] [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SupplierInvNo] [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ImportDate] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LiquidationDate] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[EntryType] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ManufactureId] [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TresCuatroSeisUnobyLine] [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MPF] decimal(38,6) NULL,
   	[MPFProRateByCes] decimal(38,6) NULL,
	[PartDescription] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ClientRefNo] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ET_CODIGO] [int] NULL,
	[ETA_CODIGO] [int] NULL,
	[Texto] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,

) ON [PRIMARY]

EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'YYMMDD' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TempEntryConcilia', @level2type=N'COLUMN',@level2name=N'EntryDate'

EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'YYYYMMDD' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TempEntryConcilia', @level2type=N'COLUMN',@level2name=N'ImportDate'

EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'YYMMDD' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TempEntryConcilia', @level2type=N'COLUMN',@level2name=N'LiquidationDate'










GO
