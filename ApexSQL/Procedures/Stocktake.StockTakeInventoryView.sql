SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Stocktake].[StockTakeInventoryView] @StockTake UNIQUEIDENTIFIER AS
BEGIN
--SELECT * FROM StockTakeGroup
--SELECT * FROM StockTake WHERE StockTakeGroup = '95A88123-6336-478F-A45F-58B2AAC72E05'
--[Stocktake].[StockTakeInventoryView] '051FE956-4967-4A6F-8A3B-1261A7A892B7'
--SELECT * FROM Item WHERE ItemNumber = '000006'
DECLARE @FirstStockTakeInGroupStartedOn DATETIME, @ThisStockTakeInGroupStartedOn DATETIME
DECLARE @StockTakeGroupOid UNIQUEIDENTIFIER, @CountByBatch INT
DECLARE @PotentialMatchesFromPreviousCounts TABLE (StockTake UNIQUEIDENTIFIER, Item UNIQUEIDENTIFIER, Batch UNIQUEIDENTIFIER, SerialNumber NVARCHAR(100), ManualCountTotal DECIMAL(19, 5), ManualCountVerified INT)
DECLARE @MatchesFromPreviousCounts TABLE (Item UNIQUEIDENTIFIER, Batch UNIQUEIDENTIFIER, SerialNumber NVARCHAR(100), CurrentSystemCount DECIMAL(19, 5))

	--First determine if we are the first stock take in the group, or a later one in a sequence of multiple stock take counts
	SELECT	@StockTakeGroupOid = StockTakeGroup, @CountByBatch = IsNull(STG.CountByBatch, 0)
	FROM	StockTake ST 
			LEFT JOIN StockTakeGroup STG ON STG.Oid = ST.StockTakeGroup
	WHERE	ST.Oid = @StockTake
	
	SELECT	@FirstStockTakeInGroupStartedOn = MIN(InProgressOn)
	FROM	StockTake ST
	WHERE	ST.StockTakeGroup = @StockTakeGroupOid

	SELECT	@ThisStockTakeInGroupStartedOn = InProgressOn
	FROM	StockTake ST
	WHERE	ST.Oid = @StockTake

	IF NOT EXISTS(SELECT * FROM StockTake WHERE Oid = @StockTake AND InProgressOn = @FirstStockTakeInGroupStartedOn) 
	BEGIN
		--If not the first in the group, then we will only show items in the view that are not balanced with the current system counts
		--Or do not match with a previous manual count
		--Build a list of items per batch that balance in the previous stock take counts within this group
		INSERT INTO @PotentialMatchesFromPreviousCounts
			SELECT	ST.Oid, Item, Batch, SerialNumber, SUM(STLI.ManualCountDecimalValue), MIN(CAST(STLI.ManualCountVerified AS INT))
			FROM	StockTakeGroup STG
					INNER JOIN StockTake ST ON ST.StockTakeGroup = STG.Oid AND ST.GCRecord Is Null
					INNER JOIN StockTakeLineItem STLI ON STLI.StockTake = ST.Oid AND STLI.GCRecord Is Null
			WHERE	STG.Oid = @StockTakeGroupOid
			GROUP BY ST.Oid, Item, Batch, SerialNumber, STLI.ItemBatchMistmatch
			HAVING STLI.ItemBatchMistmatch = 0

		--Now determine if a count matches another stock take count's manual count or the system count
		DECLARE @StockTakeOid UNIQUEIDENTIFIER, @ItemOid UNIQUEIDENTIFIER, @BatchOid UNIQUEIDENTIFIER, @SerialNumber NVARCHAR(100), @ManualCountTotal DECIMAL(19, 5), @CurrentSystemCount DECIMAL(19, 5), @ManualCountVerified INT
		DECLARE @LastItemOid UNIQUEIDENTIFIER, @LastBatchOid UNIQUEIDENTIFIER, @LastSerialNumber NVARCHAR(100), @Match INT
		SET @Match = 0

		DECLARE c_FindMatches CURSOR FOR
			SELECT	MFPC.StockTake, MFPC.Item, MFPC.Batch, MFPC.SerialNumber, MFPC.ManualCountTotal,
					CASE WHEN @CountByBatch = 1 THEN [dbo].[ItemByBatchQuantity](MFPC.Item, MFPC.Batch, MFPC.SerialNumber) ELSE I.InventoryQuantityDecimalValue END,
					ManualCountVerified
			FROM	@PotentialMatchesFromPreviousCounts MFPC
					LEFT JOIN StockTake ST ON ST.Oid = MFPC.StockTake
					LEFT JOIN Item I ON I.Oid = MFPC.Item
			ORDER BY MFPC.Item, I.InventoryQuantityDecimalValue, MFPC.Batch, MFPC.SerialNumber, ST.InProgressOn ASC
		
		OPEN c_FindMatches 	

		FETCH NEXT FROM c_FindMatches INTO
			@StockTakeOid, @ItemOid, @BatchOid, @SerialNumber, @ManualCountTotal, @CurrentSystemCount, @ManualCountVerified

		WHILE (@@FETCH_STATUS <> -1) BEGIN

			SET @Match = 0
				
			--If we are still on the same item, batch and serial number, then check to see if it matches the System count
			IF @ManualCountVerified = 1
				SET @Match = 1
			ELSE IF @ManualCountTotal = @CurrentSystemCount
				SET @Match = 1
			ELSE
				--Check if it matches another count
				IF EXISTS
					(SELECT	DISTINCT ManualCountTotal 
						FROM	@PotentialMatchesFromPreviousCounts 
						WHERE	StockTake <> @StockTakeOid 
							AND ManualCountTotal = @ManualCountTotal
							AND Item = @ItemOid
							AND (@CountByBatch = 1 AND Batch = @BatchOid OR @CountByBatch <> 1)
							AND IsNull(SerialNumber, '') = IsNull(@SerialNumber, ''))
						SET @Match = 1

			IF @Match = 1 
				INSERT INTO @MatchesFromPreviousCounts 
					SELECT	@ItemOid, @BatchOid, @SerialNumber, @CurrentSystemCount
					WHERE NOT EXISTS (SELECT 1 FROM @MatchesFromPreviousCounts WHERE Item = @ItemOid AND ((@CountByBatch = 1 AND Batch = @BatchOid) OR @CountByBatch <> 1) AND IsNull(SerialNumber, '') = IsNull(@SerialNumber, ''))

			FETCH NEXT FROM c_FindMatches INTO
				@StockTakeOid, @ItemOid, @BatchOid, @SerialNumber, @ManualCountTotal, @CurrentSystemCount, @ManualCountVerified
		END
		
		CLOSE c_FindMatches
		DEALLOCATE c_FindMatches

	END
	
	--SELECT * FROM @MatchesFromPreviousCounts

	SELECT	NULL AS Oid,
			@StockTake AS StockTake,
			INV.Item, 
			BLI.Batch,
			INV.SerialNumber,
			AVG(INV.ReceivedTotalCost / CASE WHEN INV.ReceivedQuantityDecimalValue = 0 THEN 1 ELSE INV.ReceivedQuantityDecimalValue END) AS LandedUnitCost,
			STUFF((SELECT	CHAR(13) + CHAR(10) + 'Count Of: "' + dbo.FormatDecimalToString(STLI2.ManualCountDecimalValue) + '" Taken By: "' + SSU.UserName + '" On: "' + CONVERT(VARCHAR(20), STLI2.ManualCountRecordedOn, 22) + '"'
			FROM	StockTakeLineItem STLI2
					LEFT JOIN SecuritySystemUser SSU ON SSU.Oid = STLI2.ManualCountRecordedBy
			WHERE	STLI2.StockTake = @StockTake
					AND STLI2.Item = INV.Item
					AND ((@CountByBatch = 1 AND STLI2.Batch = BLI.Batch) OR @CountByBatch <> 1)
					AND IsNull(STLI2.SerialNumber, '') = IsNull(INV.SerialNumber, '')
					AND STLI2.GCRecord Is Null
			ORDER BY STLI2.ManualCountRecordedOn
			FOR XML PATH(''), TYPE).value('.','varchar(max)'),1,2, '') AS CountDescription,
			MIN(CAST(STLI.ManualCountVerified AS INT)) AS ManualCountVerified,
			MAX(STLI.ManualCountRecordedOn) AS LastCountRecordedOn,
			CASE WHEN @CountByBatch = 1 THEN SUM(STLI.ManualCountDecimalValue) ELSE (SELECT SUM(ManualCountDecimalValue) FROM StockTakeLineItem STLI2 WHERE STLI2.Item = INV.Item AND IsNull(STLI.SerialNumber, '') = IsNull(INV.SerialNumber, '') AND STLI2.GCRecord Is Null) END AS TotalManualCount,
			CASE WHEN @CountByBatch = 1 THEN CASE WHEN MFPC.Item Is Null THEN [dbo].[ItemByBatchQuantity](BLI.Item, BLI.Batch, INV.SerialNumber) ELSE MFPC.CurrentSystemCount END ELSE I.InventoryQuantityDecimalValue END AS CurrentSystemCount,
			--See how the next line grabes the last entry's system count for this item/batch by taking the max date
			CONVERT(DECIMAL(19, 5), MAX(CAST(STLI.ManualCountRecordedOn AS FLOAT) + STLI.SystemCountWhenManualCountRecordedDecimalValue) - MAX(CAST(STLI.ManualCountRecordedOn AS FLOAT))) AS SystemCountWhenManualCountRecorded,
			CASE WHEN MFPC.Item Is Null THEN CASE WHEN CASE WHEN @CountByBatch = 1 THEN SUM(STLI.ManualCountDecimalValue) ELSE (SELECT SUM(ManualCountDecimalValue) FROM StockTakeLineItem STLI2 WHERE STLI2.Item = INV.Item AND IsNull(STLI.SerialNumber, '') = IsNull(INV.SerialNumber, '') AND STLI2.GCRecord Is Null) END = CASE WHEN @CountByBatch = 1 THEN [dbo].[ItemByBatchQuantity](BLI.Item, BLI.Batch, INV.SerialNumber) ELSE I.InventoryQuantityDecimalValue END THEN 1 ELSE 0 END END
	FROM	Item I
			INNER JOIN Inventory INV ON I.Oid = INV.Item
			LEFT JOIN BatchLineItem BLI ON BLI.Oid = INV.BatchLineItem AND @CountByBatch = 1
			INNER JOIN AccountingGroup AG ON AG.Oid = I.AccountingGroup AND AG.TrackQuantities = 1
			LEFT JOIN StockTakeLineItem STLI ON STLI.StockTake = @StockTake AND STLI.Item = INV.Item AND ((@CountByBatch <> 1 AND IsNull(STLI.SerialNumber, '') = IsNull(INV.SerialNumber, '')) OR (@CountByBatch = 1 AND (STLI.Batch = BLI.Batch AND IsNull(STLI.SerialNumber, '') = IsNull(INV.SerialNumber, '') OR (STLI.Batch Is Null AND IsNull(STLI.SerialNumber, '') = IsNull(INV.SerialNumber, '')))))
			LEFT JOIN @MatchesFromPreviousCounts MFPC ON MFPC.Item = INV.Item AND ((@CountByBatch <> 1 AND IsNull(STLI.SerialNumber, '') = IsNull(INV.SerialNumber, '')) OR (@CountByBatch = 1 AND (MFPC.Batch = BLI.Batch AND IsNull(MFPC.SerialNumber, '') = IsNull(INV.SerialNumber, '') OR (MFPC.Batch Is Null AND IsNull(MFPC.SerialNumber, '') = IsNull(INV.SerialNumber, '')))))
	WHERE	(INV.QuantityDecimalValue > 0 OR Not STLI.Oid Is Null)
			AND	(MFPC.Item Is Null OR STLI.Item Is Not Null)
			AND INV.GCRecord Is Null
			AND BLI.GCRecord Is Null
			AND STLI.GCRecord Is Null
	GROUP BY STLI.StockTake, INV.Item, BLI.Item, I.InventoryQuantityDecimalValue, MFPC.Item, BLI.Batch, INV.SerialNumber, STLI.SerialNumber, MFPC.CurrentSystemCount
	--ORDER BY TotalManualCount DESC

END
GO
