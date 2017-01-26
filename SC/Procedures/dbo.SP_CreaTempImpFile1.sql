SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


























CREATE PROCEDURE [dbo].[SP_CreaTempImpFile1]   as


exec sp_droptable 'TempImpFile1'
CREATE TABLE [dbo].[TempImpFile1] (
	[Codigo] [int] IDENTITY (1, 1) NOT NULL ,
	[RecordType] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[BCNo] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[FileType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[TMMBCTransNumber] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[TMMBCTransNumberOri] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[NumberRecords] [int] NULL ,
	[TrailerNo] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PedimentoClass] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[InsuranceCost] decimal(38,6) NULL ,
	[FreightCost] decimal(38,6) NULL ,
	[PackingCost] decimal(38,6) NULL ,
	[OthersCost] decimal(38,6) NULL ,
	[CountryExport] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[OriginId] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Route] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[ShipDate] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[ShipTime] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[ETAatswitching] [varchar] (26) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[TotalValue] decimal(38,6) NULL ,
	[TotalPackages] [int] NULL ,
	[TotalMetalPck] [int] NULL ,
	[TotalPlasticPck] [int] NULL ,
	[DRecordType] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[TMMBCManifiestPO] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PartNo] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DescripEng] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DescripSpa] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[VINNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[NetWeight] decimal(38,6) NULL ,
	[Hazard] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Mileage] [int] NULL ,
	[QtyofPart] decimal(38,6) NULL ,
	[UMofPart] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[UnitPrice] decimal(38,6) NULL ,
	[CountryOriginDest] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[CountrySupplierPurch] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Importer] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[CommercialTreatment] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[HTSMex] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[QtyHTSMex] decimal(38,6) NULL ,
	[UMHTSMex] [int] NULL ,
	[USHTS] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[QtyUSHTS1] decimal(38,6) NULL ,
	[UMHTS1] [int] NULL ,
	[QtyUSHTS2] decimal(38,6) NULL ,
	[UMHTS2] [int] NULL 
) ON [PRIMARY]



























GO
