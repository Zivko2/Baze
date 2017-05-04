SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Stocktake].[GetItemBatches] @ItemId uniqueidentifier
AS
BEGIN

	select distinct b.Oid BatchId, b.BatchNumber from Batch b
	join BatchLineItem bli on bli.Batch = b.Oid
	where bli.Item = @ItemId and bli.QuantityDecimalValue > 0 and bli.GCRecord is null
	order by b.BatchNumber
	
END
GO
