SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Stocktake].[SubmitBatchCount] @Stocktake uniqueidentifier, @Item uniqueidentifier, @Batch uniqueidentifier, @Count int, @UserName nvarchar(100)
AS
BEGIN

      declare @sysCount int;
      set @sysCount = (select SUM(inv.QuantityDecimalValue) from Batch b
            join BatchLineItem bli on bli.Batch = b.Oid
            join Inventory inv on inv.Oid = bli.Inventory
            where inv.Item = @Item and bli.Batch = @Batch and
				inv.GCRecord is null and bli.GCRecord is null)

      insert into StockTakeLineItem (Oid, ManualCountRecordedOn, ManualCountRecordedBy, SystemCountWhenManualCountRecordedDecimalValue, StockTake, Item, Batch, ManualCountDecimalValue)
            select NEWID(), GETDATE(), Oid, @sysCount, @Stocktake, @Item, @Batch, @Count from SecuritySystemUser where UserName = @UserName and GCRecord is null
      
END
GO
