SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Stocktake].[SubmitItemCount] @Stocktake uniqueidentifier, @Item uniqueidentifier, @Count int, @UserName nvarchar(100)
AS
BEGIN

	insert into StockTakeLineItem (Oid, ManualCountRecordedOn, ManualCountRecordedBy, SystemCountWhenManualCountRecordedDecimalValue, StockTake, Item, ManualCountDecimalValue)
		select NEWID(), GETDATE(), (select Oid from SecuritySystemUser where UserName = @UserName and GCRecord is null),
			InventoryQuantityDecimalValue, @Stocktake, @Item, @Count from Item where Oid = @Item and GCRecord is null
	
END
GO
