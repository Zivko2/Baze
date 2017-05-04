SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Stocktake].[LookUpItemBarCode] @BarCode nvarchar(100)
AS
BEGIN

	select it.Oid ItemId, it.ItemNumber, it.[Description], uom.Name Unit, it.TrackSerialNumbers, null BatchId, null BatchNumber, null SerialNumber from Item it
	join UnitOfMeasure uom on uom.Oid = it.UnitOfMeasure
	where it.BarCode = @BarCode

END
GO
