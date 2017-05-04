SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Stocktake].[PivotCounts] @StockTakeGroup UNIQUEIDENTIFIER AS
BEGIN


	IF OBJECT_ID('tempdb..#PivotCountResults') IS NOT NULL
		DROP TABLE #PivotCountResults

	CREATE TABLE #PivotCountResults
	(
		Oid UNIQUEIDENTIFIER,
		StockTake UNIQUEIDENTIFIER,    
		Item UNIQUEIDENTIFIER,
		Batch UNIQUEIDENTIFIER,
		SerialNumber NVARCHAR(200),
		LandedUnitCost DECIMAL(19, 4),
		CountDescription NVARCHAR(MAX),
		ManualCountVerified INT,
		LastCountRecordedOn DATETIME,
		TotalManualCount DECIMAL(19, 4),
		CurrentSystemCount DECIMAL(19, 4),
		SystemCountWhenManualCountRecorded DECIMAL(19, 4),
		MatchesSystemOrPreviousManualCount INT
	)

	DECLARE @StocktakeCountName TABLE (StockTakeOid UNIQUEIDENTIFIER, InternalCountName VARCHAR(100))

	DECLARE @StockTakeOid UNIQUEIDENTIFIER, @Index INT

	SET @Index = 0

	DECLARE c_GetStockTakeCounts CURSOR FOR
		SELECT	ST.Oid
		FROM	StockTake ST
		WHERE	StockTakeGroup = @StockTakeGroup
		ORDER BY InProgressOn
	
	OPEN c_GetStockTakeCounts

	FETCH NEXT FROM c_GetStockTakeCounts INTO
		@StockTakeOid

	WHILE (@@FETCH_STATUS <> -1) BEGIN
		SET @Index = @Index + 1
		--For each count, get the aggregated count lines from the stock take inventory view and load them into a temp table
		INSERT INTO @StocktakeCountName VALUES (@StockTakeOid, 'Count ' + CONVERT(VARCHAR(10), @Index))
		INSERT INTO #PivotCountResults
			EXEC [Stocktake].[StockTakeInventoryView] @StockTakeOid

		FETCH NEXT FROM c_GetStockTakeCounts INTO
			@StockTakeOid
	
	END

	CLOSE c_GetStockTakeCounts
	DEALLOCATE c_GetStockTakeCounts


	SELECT Item, Batch, SerialNumber, CurrentSystemCount, MAX(LastCountRecordedOn) AS LastCountRecordedOn, SUM([Count 1]) AS [Count 1], SUM([Count 2]) AS [Count 2], SUM([Count 3]) AS [Count 3]
	FROM (
		SELECT	SCN.InternalCountName, PCR.* 
		FROM	#PivotCountResults PCR
				LEFT JOIN @StocktakeCountName SCN ON SCN.StockTakeOid = PCR.StockTake
		WHERE	TotalManualCount <> CurrentSystemCount AND IsNull(ManualCountVerified, 0) = 0 ) up
	PIVOT (SUM(TotalManualCount) FOR InternalCountName IN ([Count 1], [Count 2], [Count 3])) AS pvt
	GROUP BY Item, Batch, SerialNumber, CurrentSystemCount
	HAVING NOT (IsNull(SUM([Count 1]), 0) = ISnull(SUM([Count 2]), 0) OR Isnull(SUM([Count 1]), 0) = IsNull(SUM([Count 3]), 0) OR ISnull(SUM([Count 2]), 0) = IsNull(SUM([Count 3]), 0))
	ORDER BY Item, Batch, SerialNumber, MAX(LastCountRecordedOn) DESC

	--SELECT I.ItemNumber, I.[Description], B.BatchNumber, IsNull(SerialNumber, '') AS SerialNumber, I.LinkedInventoryLocations, CurrentSystemCount, MAX(LastCountRecordedOn) AS LastCountRecordedOn, 
	--IsNull(CONVERT(VARCHAR(100), SUM([Count 1])), '') AS [Count 1], IsNull(CONVERT(VARCHAR(100), SUM([Count 2])), '') AS [Count 2], IsNull(CONVERT(VARCHAR(100), SUM([Count 3])), '') AS [Count 3]
	--FROM (
	--	SELECT	SCN.InternalCountName, PCR.* 
	--	FROM	#PivotCountResults PCR
	--			LEFT JOIN @StocktakeCountName SCN ON SCN.StockTakeOid = PCR.StockTake
	--	WHERE	TotalManualCount <> CurrentSystemCount AND IsNull(ManualCountVerified, 0) = 0 ) up
	--PIVOT (SUM(TotalManualCount) FOR InternalCountName IN ([Count 1], [Count 2], [Count 3])) AS pvt
	--	LEFT JOIN Item I ON I.Oid = Item
	--	LEFT JOIN Batch B ON B.Oid = Batch
	--GROUP BY Item, Batch, I.ItemNumber, I.[Description], B.BatchNumber, SerialNumber, I.LinkedInventoryLocations, CurrentSystemCount
	--HAVING NOT (IsNull(SUM([Count 1]), 0) = ISnull(SUM([Count 2]), 0) OR Isnull(SUM([Count 1]), 0) = IsNull(SUM([Count 3]), 0) OR ISnull(SUM([Count 2]), 0) = IsNull(SUM([Count 3]), 0))
	--ORDER BY Item, Batch, I.ItemNumber, I.[Description], B.BatchNumber,SerialNumber, I.LinkedInventoryLocations, MAX(LastCountRecordedOn) DESC
	

	DROP TABLE #PivotCountResults

END
GO
