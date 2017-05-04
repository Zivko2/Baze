SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- Create Procedure BatchLineItemByItemAndBatch
CREATE PROCEDURE [Stocktake].[BatchLineItemByItemAndBatch] @StockTakeGroup UNIQUEIDENTIFIER
AS
BEGIN

	DECLARE @Temp TABLE
	(
	  TempID UNIQUEIDENTIFIER,
	  StockTake UNIQUEIDENTIFIER,
	  BatchLineItem UNIQUEIDENTIFIER, 
	  Item UNIQUEIDENTIFIER,
	  SerialNumber NVARCHAR(100),
	  Batch UNIQUEIDENTIFIER,
	  ManualCountVsCurrentSystemCount DECIMAL(19, 5)
	)
	
	INSERT INTO @Temp (TempID, StockTake, BatchLineItem, Item, SerialNumber, Batch, ManualCountVsCurrentSystemCount)
		SELECT  NEWID(), STLI.StockTake, CONVERT(UNIQUEIDENTIFIER, MAX(CONVERT(char(36), BLI.Oid))) AS BatchLineItem, BLI.Item, INV.SerialNumber, BLI.Batch, 
				IsNull(STLI.TotalManualCount, 0) - dbo.ItemByBatchQuantity(STLI.Item, STLI.Batch, STLI.SerialNumber) AS ManualCountVsCurrentSystemCount
		FROM	[Stocktake].[StockTakeGroupConsolidated1](@StockTakeGroup) STLI
				LEFT JOIN BatchLineItem BLI ON BLI.Batch = STLI.Batch AND BLI.Item = STLI.Item AND BLI.GCRecord Is Null
				INNER JOIN Inventory INV ON INV.Oid = BLI.Inventory AND INV.GCRecord Is Null
				INNER JOIN Item I ON I.Oid = BLI.Item
				INNER JOIN AccountingGroup AG ON AG.Oid = I.AccountingGroup AND AG.TrackQuantities = 1
		WHERE	(LastCountRecordedOn Is Not Null
					 AND (STLI.TotalManualCount - dbo.ItemByBatchQuantity(STLI.Item, STLI.Batch, STLI.SerialNumber) > 0 AND (STLI.SerialNumber Is Null OR INV.SerialNumber = STLI.SerialNumber))
					  OR (STLI.TotalManualCount - dbo.ItemByBatchQuantity(STLI.Item, STLI.Batch, STLI.SerialNumber) < 0
				 		  AND INV.QuantityDecimalValue >= ABS(STLI.TotalManualCount - dbo.ItemByBatchQuantity(STLI.Item, STLI.Batch, STLI.SerialNumber))
				 		  AND (STLI.SerialNumber Is Null OR INV.SerialNumber = STLI.SerialNumber))
					 )
				OR (LastCountRecordedOn Is Null AND dbo.ItemByBatchQuantity(STLI.Item, STLI.Batch, STLI.SerialNumber) > 0 AND (STLI.SerialNumber Is Null OR INV.SerialNumber = STLI.SerialNumber))
				AND BLI.BatchLineItemStatus IN (55, 60)
		GROUP BY STLI.StockTake, BLI.Item, INV.SerialNumber, BLI.Batch, IsNull(STLI.TotalManualCount, 0) - dbo.ItemByBatchQuantity(STLI.Item, STLI.Batch, STLI.SerialNumber), LastCountRecordedOn

	DELETE FROM @Temp WHERE ManualCountVsCurrentSystemCount = 0
	
	-- do a second search for those where the quantities are not great enough in a single batch line item
	-- for the negative adjustment size, but there are multiples of the same item on the same batch and we can break
	-- it up across them.
	DECLARE distrubuteAdjustment CURSOR FOR
		SELECT	T.TempID, T.StockTake, BLI.Oid, BLI.Item, INV.SerialNumber, BLI.Batch, T.ManualCountVsCurrentSystemCount,
				INV.QuantityDecimalValue
		FROM	@Temp T
				LEFT JOIN BatchLineItem BLI ON BLI.Batch = T.Batch AND BLI.Item = T.Item AND BLI.GCRecord Is Null
				LEFT JOIN Inventory INV ON INV.Oid = BLI.Inventory 
				LEFT JOIN BatchLineItem BLI2 ON BLI2.Oid = T.BatchLineItem
				LEFT JOIN Inventory INV2 ON INV2.Oid = BLI2.Inventory
		WHERE	INV2.QuantityDecimalValue <= -T.ManualCountVsCurrentSystemCount 
				AND INV2.QuantityDecimalValue + T.ManualCountVsCurrentSystemCount < 0
				AND INV.QuantityDecimalValue > 0
				AND (T.SerialNumber Is Null OR INV.SerialNumber = T.SerialNumber)
				AND BLI.BatchLineItemStatus IN (55, 60)
		ORDER BY BLI.Item, BLI.Batch

	DECLARE @StockTake UNIQUEIDENTIFIER, @BatchLineItem UNIQUEIDENTIFIER, @Item UNIQUEIDENTIFIER, @Batch UNIQUEIDENTIFIER, @SerialNumber NVARCHAR(100)
	DECLARE @ManualVsCurrent DECIMAL(19, 5), @QuantityAvailable DECIMAL(19, 5), @RemainingToAdjust DECIMAL(19, 5)
	DECLARE @PrevItemBatch VARCHAR(100), @TempID UNIQUEIDENTIFIER
	
	SELECT @RemainingToAdjust = 0, @PrevItemBatch = ''
	
	OPEN distrubuteAdjustment
	FETCH NEXT FROM distrubuteAdjustment INTO 
		@TempID, @StockTake, @BatchLineItem, @Item, @SerialNumber, @Batch, @ManualVsCurrent, @QuantityAvailable

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		IF @PrevItemBatch <> CONVERT(VARCHAR(36), @Item) + ':' + CONVERT(VARCHAR(36), @Batch) + ':' + IsNull(@SerialNumber, '')
		BEGIN
			IF @RemainingToAdjust <> 0 BEGIN
				DECLARE @msg NVARCHAR(2048) = N'Abort! Cannot account for all adjustment quantity! Item:Batch ' + CONVERT(VARCHAR(173), @PrevItemBatch) + N' still needs: ' + CONVERT(VARCHAR(10), @RemainingToAdjust);
				THROW 60000, @msg, 1
			END
			SET @PrevItemBatch = CONVERT(VARCHAR(36), @Item) + ':' + CONVERT(VARCHAR(36), @Batch) + ':' + IsNull(@SerialNumber, '')
			SET @RemainingToAdjust = @ManualVsCurrent
		END
			
		PRINT 'Quantity Avialable For BatchLineItem: ' + CONVERT(VARCHAR(36), @BatchLineItem) + ' is ' + CONVERT(VARCHAR(10), @QuantityAvailable) + ' needing: ' + CONVERT(VARCHAR(10), @RemainingToAdjust)
		--Clear out the entry if it was there before
		DELETE FROM @Temp WHERE TempID = @TempID

		IF @QuantityAvailable >= ABS(@RemainingToAdjust)
		BEGIN
			PRINT 'Allocating: ' + CONVERT(VARCHAR(10), @RemainingToAdjust) + 'to ItemBatch: ' + @PrevItemBatch
			INSERT INTO @Temp VALUES (NEWID(), @StockTake, @BatchLineItem, @Item, @SerialNumber, @Batch, @RemainingToAdjust)
			SET @RemainingToAdjust = 0
		END
		ELSE
		BEGIN
			PRINT 'Partially Allocating: ' + CONVERT(VARCHAR(10), -@QuantityAvailable) + 'to ItemBatch: ' + @PrevItemBatch
			INSERT INTO @Temp VALUES (NEWID(), @StockTake, @BatchLineItem, @Item, @SerialNumber, @Batch, -@QuantityAvailable)
			SET @RemainingToAdjust = @RemainingToAdjust + @QuantityAvailable
		END
	
		FETCH NEXT FROM distrubuteAdjustment INTO 
			@TempID, @StockTake, @BatchLineItem, @Item, @SerialNumber, @Batch, @ManualVsCurrent, @QuantityAvailable
	END
	
	CLOSE distrubuteAdjustment
	DEALLOCATE distrubuteAdjustment

	SELECT StockTake, BatchLineItem, Item, Batch, ManualCountVsCurrentSystemCount 
	FROM @Temp 
	ORDER BY Batch
	
END
GO
