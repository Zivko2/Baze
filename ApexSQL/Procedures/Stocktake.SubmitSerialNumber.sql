SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Stocktake].[SubmitSerialNumber] @Stocktake uniqueidentifier, @Item uniqueidentifier, @SerialNo nvarchar(100), @UserName nvarchar(100)
AS
BEGIN
	
	declare @sysCount int, @batch uniqueidentifier;
	set @sysCount = (select case when COUNT(Oid) > 0 then 1 else 0 end from Inventory
		where Item = @Item and QuantityDecimalValue > 0 and SerialNumber = @SerialNo and GCRecord is null)
	
	select @batch = BLI.Batch 
	from	Inventory INV
			INNER JOIN BatchLineItem BLI ON BLI.Inventory = INV.Oid
	where INV.Item = @Item and INV.SerialNumber = @SerialNo and INV.QuantityDecimalValue > 0 and INV.GCRecord is null and BLI.GCRecord is null
	
	insert into StockTakeLineItem (Oid, ManualCountRecordedOn, ManualCountRecordedBy, SystemCountWhenManualCountRecordedDecimalValue, StockTake, Item, Batch, SerialNumber, ManualCountDecimalValue)
		select NEWID(), GETDATE(), Oid, @sysCount, @Stocktake, @Item, @Batch, @SerialNo, 1 from SecuritySystemUser where UserName = @UserName and GCRecord is null
	
END
GO
