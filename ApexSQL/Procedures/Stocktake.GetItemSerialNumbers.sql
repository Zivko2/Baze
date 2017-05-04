SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Stocktake].[GetItemSerialNumbers] @ItemId uniqueidentifier
AS
BEGIN

	select SerialNumber from Inventory
	where Item = @ItemId and QuantityDecimalValue > 0 and SerialNumber is not null and GCRecord is null
	order by SerialNumber
	
END
GO
