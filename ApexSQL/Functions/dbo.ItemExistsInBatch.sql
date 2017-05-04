SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ItemExistsInBatch] (@Item UNIQUEIDENTIFIER, @Batch UNIQUEIDENTIFIER)
RETURNS INT
AS
BEGIN

	DECLARE @ItemExistsInBatch INT

	SELECT	@ItemExistsInBatch = COUNT(*)
	FROM	Inventory INV
			LEFT JOIN BatchLineItem BLI ON BLI.Oid = INV.BatchLineItem 
	WHERE	INV.Item = @Item 
			AND BLI.Batch = @Batch
					
	RETURN @ItemExistsInBatch
	
END
GO
