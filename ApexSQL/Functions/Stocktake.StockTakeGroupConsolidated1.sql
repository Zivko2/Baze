SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- Alter Function StockTakeGroupConsolidated1
/*** We use a function so that we can get and use these results in table variables within other stored procedures ***/
CREATE FUNCTION [Stocktake].[StockTakeGroupConsolidated1](@StockTakeGroup UNIQUEIDENTIFIER)
RETURNS @StockTakeGroupConsolidated TABLE 
(
	Oid UNIQUEIDENTIFIER,
	StockTake UNIQUEIDENTIFIER,
	Item UNIQUEIDENTIFIER,
	Batch UNIQUEIDENTIFIER,
	SerialNumber NVARCHAR(100),
	LandedUnitCost DECIMAL(19, 4),
	CountDescription VARCHAR(MAX),
	ManualCountVerified INT,
	LastCountRecordedOn DATETIME,
	TotalManualCount DECIMAL(19, 5),
	CurrentSystemCount DECIMAL(19, 5),
	SystemCountWhenManualCountRecorded DECIMAL(19, 5),
	MatchesSystemOrPreviousManualCount INT
)
AS 
BEGIN

DECLARE @SuperSet TABLE (
	Item UNIQUEIDENTIFIER,
	Batch UNIQUEIDENTIFIER,
	SerialNumber NVARCHAR(100),
	LastCountRecordedOn DATETIME,
	CurrentSystemCount DECIMAL(19, 5),
	LandedUnitCost DECIMAL(19, 4))

--SELECT * FROM [Stocktake].[StockTakeGroupConsolidated]('79628BA7-C140-4CD5-BB0C-4D8F61F61A78') ORDER BY LastCountRecordedOn DESC
--DECLARE @StockTakeGroup UNIQUEIDENTIFIER
	--SELECT * FROM StockTakeGroup
--SET @StockTakeGroup = '79628BA7-C140-4CD5-BB0C-4D8F61F61A78'

	--The assumption here is that we are going to get the last counts which will be the ones we are considering.
	INSERT INTO @SuperSet
		SELECT	BLI.Item, 
				BLI.Batch,
				INV.SerialNumber,
				MAX(STLI.ManualCountRecordedOn) AS LastCountRecordedOn,
				[dbo].[ItemByBatchQuantity](BLI.Item, BLI.Batch, INV.SerialNumber) AS CurrentSystemCount,
				AVG(INV.ReceivedTotalCost / CASE WHEN INV.ReceivedQuantityDecimalValue = 0 THEN 1 ELSE INV.ReceivedQuantityDecimalValue END) AS LandedUnitCost
		FROM	Inventory INV
				INNER JOIN BatchLineItem BLI ON BLI.Oid = INV.BatchLineItem
				INNER JOIN Item I ON I.Oid = BLI.Item
				INNER JOIN AccountingGroup AG ON AG.Oid = I.AccountingGroup AND AG.TrackQuantities = 1
				LEFT JOIN StockTakeLineItem STLI ON STLI.StockTake IN (SELECT Oid FROM StockTake WHERE StockTakeGroup = @StockTakeGroup) AND STLI.Item = INV.Item AND (STLI.Batch = BLI.Batch AND IsNull(STLI.SerialNumber, '') = IsNull(INV.SerialNumber, '') OR (STLI.Batch Is Null AND IsNull(STLI.SerialNumber, '') = IsNull(INV.SerialNumber, '')))
		WHERE	(INV.QuantityDecimalValue > 0 OR Not STLI.Oid Is Null)
				AND INV.GCRecord Is Null
				AND BLI.GCRecord Is Null
				AND STLI.GCRecord Is Null
				AND ((SELECT AdjustUncountedItemsToZeroQuantity FROM StockTakeGroup WHERE Oid = @StockTakeGroup) = 1 OR STLI.Oid Is Not Null)
				AND BLI.BatchLineItemStatus IN (55, 60)
		GROUP BY BLI.Item, BlI.Batch, INV.SerialNumber

		DECLARE @ItemOid UNIQUEIDENTIFIER, @BatchOid  UNIQUEIDENTIFIER, @SerialNumber NVARCHAR(100), @LastCountRecordedOn DATETIME, @CurrentSystemCount DECIMAL(19, 5), @LandedUnitCost DECIMAL(19, 4)
		DECLARE @StockTakeOid UNIQUEIDENTIFIER, @CountDescription VARCHAR(MAX), @ManualCountVerified INT, @TotalManualCount DECIMAL(19, 5), @SystemCountWhenManualCountRecorded DECIMAL(19, 5), @MatchesSystemOrPreviousManualCount INT

		DECLARE c_Consolidated CURSOR FOR
			SELECT	Item, Batch, SerialNumber, LastCountRecordedOn, CurrentSystemCount, LandedUnitCost
			FROM	@SuperSet
		
		OPEN c_Consolidated 	

		FETCH NEXT FROM c_Consolidated INTO
			@ItemOid, @BatchOid, @SerialNumber, @LastCountRecordedOn, @CurrentSystemCount, @LandedUnitCost

		WHILE (@@FETCH_STATUS <> -1) BEGIN

			SET @CountDescription = 
			STUFF((		SELECT CHAR(13) + CHAR(10) + 'Count Of: "' + dbo.FormatDecimalToString(STLI2.ManualCountDecimalValue) + '" Taken By: "' + SSU.UserName + '" On: "' + CONVERT(VARCHAR(20), STLI2.ManualCountRecordedOn, 22) + '"'
						FROM	StockTakeLineItem STLI2
								LEFT JOIN SecuritySystemUser SSU ON SSU.Oid = STLI2.ManualCountRecordedBy
						WHERE	STLI2.StockTake IN (SELECT Oid FROM StockTake WHERE StockTakeGroup = @StockTakeGroup)
								AND STLI2.Item = @ItemOid
								AND STLI2.Batch = @BatchOid
								AND STLI2.GCRecord Is Null
						ORDER BY STLI2.ManualCountRecordedOn
						FOR XML PATH(''), TYPE).value('.','varchar(max)'),1,2, '')
	
			SELECT	@StockTakeOid = NULL, @ManualCountVerified = 0, @TotalManualCount = 0, @SystemCountWhenManualCountRecorded = 0, @MatchesSystemOrPreviousManualCount = 0

			SELECT	@StockTakeOid = STLI.StockTake,
					@ManualCountVerified = MIN(CAST(STLI.ManualCountVerified AS INT)),
					@SystemCountWhenManualCountRecorded = CONVERT(DECIMAL(19, 5), MAX(CAST(STLI.ManualCountRecordedOn AS FLOAT) + STLI.SystemCountWhenManualCountRecordedDecimalValue) - MAX(CAST(STLI.ManualCountRecordedOn AS FLOAT)))
			FROM	StockTake ST 
					INNER JOIN StockTakeLineItem STLI ON STLI.StockTake = ST.Oid
			WHERE	ST.StockTakeGroup = @StockTakeGroup
					AND STLI.Item = @ItemOid AND (STLI.Batch = @BatchOid AND IsNull(STLI.SerialNumber, '') = IsNull(@SerialNumber, '') OR (STLI.Batch Is Null AND IsNull(STLI.SerialNumber, '') = IsNull(@SerialNumber, '')))
					AND STLI.ManualCountRecordedOn = @LastCountRecordedOn
			GROUP BY STLI.StockTake, STLI.Item, STLI.Batch, STLI.SerialNumber

			SELECT	@TotalManualCount = SUM(STLI.ManualCountDecimalValue)
			FROM	StockTakeLineItem STLI
			WHERE	STLI.StockTake = @StockTakeOid
					AND STLI.Item = @ItemOid AND (STLI.Batch = @BatchOid AND IsNull(STLI.SerialNumber, '') = IsNull(@SerialNumber, '') OR (STLI.Batch Is Null AND IsNull(STLI.SerialNumber, '') = IsNull(@SerialNumber, '')))

			SELECT	@MatchesSystemOrPreviousManualCount = CASE WHEN @TotalManualCount = @CurrentSystemCount THEN 1 ELSE 0 END


			IF EXISTS (
				SELECT	STLI.StockTake, STLI.Item, STLI.Batch, STLI.SerialNumber
				FROM	StockTake ST 
						INNER JOIN StockTakeLineItem STLI ON STLI.StockTake = ST.Oid
				WHERE	ST.StockTakeGroup = @StockTakeGroup
						AND ST.Oid <> @StockTakeOid
						AND STLI.Item = @ItemOid AND (STLI.Batch = @BatchOid AND IsNull(STLI.SerialNumber, '') = IsNull(@SerialNumber, '') OR (STLI.Batch Is Null AND IsNull(STLI.SerialNumber, '') = IsNull(@SerialNumber, '')))
				GROUP BY STLI.StockTake, STLI.Item, STLI.Batch, STLI.SerialNumber
				HAVING SUM(STLI.ManualCountDecimalValue) = @TotalManualCount)
				SET @MatchesSystemOrPreviousManualCount = 1

			INSERT INTO @StockTakeGroupConsolidated
				SELECT	NULL AS Oid,
						@StockTakeOid,
						@ItemOid, 
						@BatchOid,
						@SerialNumber,
						@LandedUnitCost,
						@CountDescription,
						@ManualCountVerified,
						@LastCountRecordedOn,
						@TotalManualCount,
						@CurrentSystemCount,
						@SystemCountWhenManualCountRecorded,
						@MatchesSystemOrPreviousManualCount 
		
			FETCH NEXT FROM c_Consolidated INTO
				@ItemOid, @BatchOid, @SerialNumber, @LastCountRecordedOn, @CurrentSystemCount, @LandedUnitCost
		END
		
		CLOSE c_Consolidated
		DEALLOCATE c_Consolidated

	RETURN

END
GO
