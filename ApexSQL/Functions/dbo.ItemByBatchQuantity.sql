SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ItemByBatchQuantity] (@Item UNIQUEIDENTIFIER, @Batch UNIQUEIDENTIFIER, @SerialNumber VARCHAR(100))
RETURNS DECIMAL(19, 5)
AS
BEGIN

	DECLARE @TotalQuantity DECIMAL(19, 5)

	SELECT	@TotalQuantity = SUM(INV.QuantityDecimalValue)
	FROM	Inventory INV
			LEFT JOIN BatchLineItem BLI ON BLI.Oid = INV.BatchLineItem 
	WHERE	INV.Item = @Item 
			AND BLI.Batch = @Batch
			AND IsNull(@SerialNumber, '') = IsNull(INV.SerialNumber, '')
					
	RETURN @TotalQuantity
	
END
GO
