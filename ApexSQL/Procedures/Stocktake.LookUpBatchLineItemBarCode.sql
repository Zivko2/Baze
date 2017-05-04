SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Stocktake].[LookUpBatchLineItemBarCode] @Stocktake uniqueidentifier, @BarCode nvarchar(100)
AS
BEGIN

	select it.Oid ItemId, it.ItemNumber, it.[Description], uom.Name Unit, it.TrackSerialNumbers, b.Oid BatchId, b.BatchNumber, bli.SerialNumber,
		sum(isnull(stli.ManualCountDecimalValue, 0)) [Count] from Batch b
	join BatchLineItem bli on bli.Batch = b.Oid
	join Item it on it.Oid = bli.Item
	join UnitOfMeasure uom on uom.Oid = it.UnitOfMeasure
	left join StockTakeLineItem stli on stli.StockTake = @Stocktake and stli.Item = it.Oid and stli.Batch = b.Oid
	where bli.BarCode = @BarCode and bli.GCRecord is null
	group by it.Oid, it.ItemNumber, it.[Description], uom.Name, it.TrackSerialNumbers, b.Oid, b.BatchNumber, bli.SerialNumber
	
END
GO
