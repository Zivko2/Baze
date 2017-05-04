SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT * FROM Item WHERE ItemNumber = 'BC410-2'
DECLARE	@CrossReferences VARCHAR(500)
DECLARE	@BatchesWithInventory VARCHAR(500)
DECLARE @LinkedInventoryLocations VARCHAR(500)
DECLARE	@XRefInventoryQuantity INT
DECLARE	@XRefOnOrderQuantity INT
DECLARE	@OnOrderQuantity INT
DECLARE	@InventoryQuantity INT
DECLARE @AvailableInventoryQuantity INT
DECLARE	@WantListQuantity INT
DECLARE	@LastEventOccurredOn DATETIME
DECLARE	@LastReceivedOn DATETIME
	
EXEC Staged.ResetCachedItemProperties null, 
	@CrossReferences OUTPUT,
	@BatchesWithInventory OUTPUT,
	@LinkedInventoryLocations OUTPUT,
	@XRefInventoryQuantity OUTPUT,
	@XRefOnOrderQuantity OUTPUT,
	@OnOrderQuantity OUTPUT,
	@InventoryQuantity OUTPUT,
	@AvailableInventoryQuantity OUTPUT,
	@WantListQuantity OUTPUT,
	@LastEventOccurredOn OUTPUT,
	@LastReceivedOn OUTPUT

PRINT	@CrossReferences
PRINT	@BatchesWithInventory
PRINT	@LinkedInventoryLocations
PRINT	@XRefInventoryQuantity
PRINT	@XRefOnOrderQuantity
PRINT	@OnOrderQuantity
PRINT	@InventoryQuantity
PRINT   @AvailableInventoryQuantity
PRINT	@WantListQuantity
PRINT	@LastEventOccurredOn
PRINT	@LastReceivedOn
*/

CREATE PROCEDURE [Staged].[ResetCachedItemProperties] @Item UNIQUEIDENTIFIER = NULL,
	@CrossReferences VARCHAR(500) = NULL OUTPUT,
	@BatchesWithInventory VARCHAR(500) = NULL OUTPUT,
	@LinkedInventoryLocations VARCHAR(500) = NULL OUTPUT,
	@XRefInventoryQuantity DECIMAL(19, 5) = NULL OUTPUT,
	@XRefOnOrderQuantity DECIMAL(19, 5) = NULL OUTPUT,
	@OnOrderQuantity DECIMAL(19, 5) = NULL OUTPUT,
	@InventoryQuantity DECIMAL(19, 5) = NULL OUTPUT,
	@AvailableInventoryQuantity DECIMAL(19, 5) = NULL OUTPUT,
	@WantListQuantity DECIMAL(19, 5) = NULL OUTPUT,
	@LastEventOccurredOn DATETIME = NULL OUTPUT,
	@LastReceivedOn DATETIME = NULL OUTPUT,
	@TotalInventoryValue MONEY = NULL OUTPUT,
	@ItemOidList AS dbo.OidList READONLY
AS
BEGIN

	SET NOCOUNT ON

	DECLARE @Items TABLE (Oid UNIQUEIDENTIFIER PRIMARY KEY)
	
	IF Not EXISTS(SELECT * FROM @ItemOidList)
		IF @Item Is Null
			INSERT INTO @Items SELECT Oid FROM Item WHERE GCRecord Is Null
		ELSE 
			INSERT INTO @Items VALUES (@Item)
	ELSE
		INSERT INTO @Items SELECT Oid FROM Item WHERE Oid IN (SELECT Oid FROM @ItemOidList)
	
	UPDATE Item SET LastEventOccurredOn = 
			(SELECT MAX(MovementOccurredOn)
			FROM	Item I
					LEFT JOIN ItemHistory IH ON IH.Item = I.Oid
			WHERE	I.Oid = Item.Oid
					AND IH.GCRecord Is Null
			GROUP BY ItemNumber)
	WHERE Oid IN (SELECT Oid FROM @Items)

	UPDATE Item SET LastEventOccurredOn = 
			(SELECT 
			CASE WHEN MAX(I.LastEventOccurredOn) > MAX(MovementOccurredOn) THEN
				MAX(I.LastEventOccurredOn)
			ELSE 
				MAX(MovementOccurredOn)
			END 
	FROM	Item I
			LEFT JOIN Inventory INV ON INV.Item = I.Oid
			LEFT JOIN ItemHistory IH ON IH.Inventory = INV.Oid
	WHERE I.Oid = Item.Oid AND IH.Item Is Null
			AND IH.GCRecord Is Null
			AND I.GCRecord Is Null
	GROUP BY ItemNumber)
	WHERE Oid IN (SELECT Oid FROM @Items) 

	UPDATE Item SET InventoryQuantityDecimalValue = (SELECT SUM(QuantityDecimalValue) FROM Inventory INV WHERE INV.QuantityDecimalValue > 0 AND INV.Item = Item.Oid AND INV.GCRecord Is Null GROUP BY INV.Item)
	WHERE Oid IN (SELECT Oid FROM @Items)

	UPDATE Item SET AvailableInventoryQuantityDecimalValue = InventoryQuantityDecimalValue - 
	   (SELECT	SUM(SLI.QuantityDecimalValue)
		FROM	SaleLineItem SLI
				INNER JOIN Sale S ON S.Oid = SLI.Sale
		WHERE	SLI.Item = Item.Oid
				AND S.CompletedBy Is Null
				AND (S.ReserveItemsOnThisSale = 1 OR SLI.ReserveItemQuantity = 1)				
				AND SLI.GCRecord Is Null
				AND S.GCRecord Is Null
		GROUP BY SLI.Item)
	WHERE Oid IN (SELECT Oid FROM @Items)

	--Total Inventory Value
	DECLARE @TempTotalInventoryValue TABLE (Item UNIQUEIDENTIFIER, TotalInventoryValue DECIMAL(19, 4))
	INSERT INTO @TempTotalInventoryValue 
		SELECT	INV.Item, SUM(BaseValue) 
		FROM	ItemHistory IH
				LEFT JOIN Inventory INV ON INV.Oid = IH.Inventory
		WHERE	IH.GCRecord Is Null AND IH.Item IN (SELECT Oid FROM @Items) OR INV.Item IN (SELECT Oid FROM @Items)
		GROUP BY INV.Item 

	UPDATE Item SET TotalInventoryValue = TTIV.TotalInventoryValue
		FROM	Item I
				LEFT JOIN @TempTotalInventoryValue TTIV ON TTIV.Item = I.Oid
		WHERE	I.Oid IN (SELECT Oid FROM @Items)

	UPDATE Item SET LastReceivedOn = (SELECT MAX(ReceivedOn) FROM Inventory INV WHERE INV.Item = Item.Oid AND INV.GCRecord Is Null GROUP BY INV.Item)
	WHERE Oid IN (SELECT Oid FROM @Items)

	UPDATE Item SET OnOrderQuantityDecimalValue = (
		SELECT  SUM(QuantityOrderedDecimalValue) 
		FROM	PurchaseOrderLineItem POLI 
				LEFT JOIN PurchaseOrder PO ON PO.Oid = POLI.PurchaseOrder
		WHERE	--PO.PurchaseOrderStatus <= 80
				POLI.QuantityReceivedDecimalValue + POLI.QuantityUnfulfilledDecimalValue < POLI.QuantityOrderedDecimalValue
				AND POLI.Item = Item.Oid
				AND POLI.GCRecord Is Null
				AND PO.GCRecord Is Null
		GROUP BY POLI.Item)
	WHERE Oid IN (SELECT Oid FROM @Items)

	UPDATE Item SET AvailableInventoryQuantityDecimalValue = InventoryQuantityDecimalValue - 
		(SELECT  SUM(QuantityOrderedDecimalValue) 
			FROM	PurchaseOrderLineItem POLI 
					LEFT JOIN PurchaseOrder PO ON PO.Oid = POLI.PurchaseOrder
					left join Inventory inv on inv.Oid = poli.Inventory
			WHERE	--PO.PurchaseOrderStatus <= 80
					POLI.QuantityReceivedDecimalValue + POLI.QuantityUnfulfilledDecimalValue < POLI.QuantityOrderedDecimalValue
					AND Poli.Inventory = inv.Oid
					and Inv.Item = Item.Oid
					AND POLI.GCRecord Is Null
					AND PO.GCRecord Is Null
					and po.PurchaseOrderType = 10
		GROUP BY POLI.Inventory)
	WHERE Oid IN (SELECT Oid FROM @Items)

	UPDATE Item SET WantListQuantityDecimalValue = 
		(SELECT SUM(CASE WHEN PurchaserAssignedQuantityDecimalValue > 0 THEN PurchaserAssignedQuantityDecimalValue ELSE RequestedQuantityDecimalValue END ) 
	 	 FROM	WantListItem WLI 
		 WHERE	WLI.Item = Item.Oid 
				AND WLI.GCRecord Is Null
				AND PurchaseOrderLineItem Is Null
				AND IsCancelled = 0
				AND IsNull(DeferAutoOrderUntil, GETDATE()) <= GETDATE()
				AND IsLegacy = 0)
	WHERE Oid IN (SELECT Oid FROM @Items)

	-- Cross References 
	UPDATE Item SET CrossReferences = NULL, BatchesWithInventory = NULL, 
			LinkedInventoryLocations = NULL, XRefInventoryQuantityDecimalValue = 0, XRefOnOrderQuantityDecimalValue = 0
	WHERE Oid IN (SELECT Oid FROM @Items)

	DECLARE @ItemOid UNIQUEIDENTIFIER, @XRefItemNumber VARCHAR(100), @Item2Oid UNIQUEIDENTIFIER

	DECLARE c_AllItems CURSOR FOR
		SELECT	I.Oid, I2.ItemNumber, I2.Oid
		FROM	Item I
				INNER JOIN ItemCrossReference IXR ON IXR.Item = I.Oid
				INNER JOIN Item I2 ON I2.Oid = IXR.CrossReferencedItem
		WHERE I.Oid IN (SELECT Oid FROM @Items) AND IXR.GCRecord Is Null
		UNION
		SELECT	I.Oid, I2.ItemNumber, I2.Oid
		FROM	Item I
				INNER JOIN ItemCrossReference IXR ON IXR.CrossReferencedItem = I.Oid
				INNER JOIN Item I2 ON I2.Oid = IXR.Item
		WHERE I.Oid IN (SELECT Oid FROM @Items) AND IXR.GCRecord Is Null
		
	OPEN c_AllItems	

	FETCH NEXT FROM c_AllItems INTO
		@ItemOid, @XRefItemNumber, @Item2Oid

	WHILE (@@FETCH_STATUS <> -1) BEGIN

		UPDATE Item SET 
			CrossReferences = CASE WHEN CrossReferences Is Null THEN @XRefItemNumber ELSE CrossReferences + '; ' + @XRefItemNumber END,
			XRefInventoryQuantityDecimalValue = IsNull(XRefInventoryQuantityDecimalValue, 0) + IsNull((SELECT SUM(QuantityDecimalValue) FROM Inventory WHERE Item = @Item2Oid AND GCRecord Is Null), 0),
			XRefOnOrderQuantityDecimalValue = IsNull(XRefOnOrderQuantityDecimalValue, 0) + IsNull((SELECT SUM(QuantityOrderedDecimalValue) FROM PurchaseOrderLineItem POLI LEFT JOIN PurchaseOrder PO ON PO.Oid = POLI.PurchaseOrder WHERE Item = @Item2Oid AND PO.PurchaseOrderStatus < 80 AND PO.GCRecord Is Null AND POLI.GCRecord Is Null), 0)
		WHERE Oid = @ItemOid
		
		FETCH NEXT FROM c_AllItems INTO
			@ItemOid, @XRefItemNumber, @Item2Oid
	END

	CLOSE c_AllItems
	DEALLOCATE c_AllItems

	DECLARE @BatchId UNIQUEIDENTIFIER, @SerialNumber VARCHAR(100), @BatchNumber VARCHAR(100), @InventoryLocationName VARCHAR(100), @BQuantity DECIMAL(19, 2), @ILQuantity DECIMAL(19, 5)
	
	-- Batches With Inventory
	DECLARE c_AllItemsWithBatches CURSOR FOR
	SELECT	DISTINCT tI.Oid, B.Oid, INV.SerialNumber, B.BatchNumber, IL.Name, INV2.QuantityDecimalValue
		FROM	@Items tI
				LEFT JOIN Inventory INV ON INV.Item = tI.Oid AND INV.QuantityDecimalValue > 0
				LEFT JOIN BatchLineItem BLI ON BLI.Oid = INV.BatchLineItem
				LEFT JOIN Batch B ON B.Oid = BLI.Batch
				LEFT JOIN ItemInventoryLocation IIL ON IIL.Item = tI.Oid AND IIL.GCRecord Is Null
				LEFT JOIN Inventory INV2 ON INV2.Item = tI.Oid AND INV2.InventoryLocation = IIL.InventoryLocation
				LEFT JOIN InventoryLocation IL ON IL.Oid = IIL.InventoryLocation --AND IL.GCRecord Is Null
		WHERE	INV.GCRecord Is Null
				AND BLI.GCRecord Is Null
				AND B.GCRecord Is Null
		
	OPEN c_AllItemsWithBatches	

	FETCH NEXT FROM c_AllItemsWithBatches INTO
		@ItemOid, @BatchId, @SerialNumber, @BatchNumber, @InventoryLocationName, @ILQuantity

	WHILE (@@FETCH_STATUS <> -1) BEGIN

		UPDATE Item SET 
			BatchesWithInventory = LEFT(
				CASE WHEN  BatchesWithInventory Is Null THEN 
					@BatchNumber + '(' + dbo.FormatDecimalToString(dbo.ItemByBatchQuantity(@ItemOid, @BatchId, @SerialNumber)) + ')'
				ELSE 
					BatchesWithInventory + '; ' + @BatchNumber + '(' + dbo.FormatDecimalToString(dbo.ItemByBatchQuantity(@ItemOid, @BatchId, @SerialNumber)) + ')'
				END
				, 500)
		WHERE	Oid = @ItemOid
				AND (BatchesWithInventory Is Null OR Not BatchesWithInventory Like '%' + @BatchNumber + '(%')
				AND LEN(IsNull(BatchesWithInventory, '')) < 500

		IF @ILQuantity <> 0
			UPDATE Item SET 
				LinkedInventoryLocations = LEFT(
					CASE WHEN  LinkedInventoryLocations Is Null THEN 
						'(' + @InventoryLocationName + ')'
					ELSE 
						LinkedInventoryLocations + ' Or (' + @InventoryLocationName + ')'
					END
					, 500)
			WHERE	Oid = @ItemOid
					AND (LinkedInventoryLocations Is Null Or Not LinkedInventoryLocations Like '%(' + @InventoryLocationName + ')%')
					AND LEN(IsNull(LinkedInventoryLocations, '')) < 500
				
		FETCH NEXT FROM c_AllItemsWithBatches INTO
			@ItemOid, @BatchId, @SerialNumber, @BatchNumber, @InventoryLocationName, @ILQuantity
	END

	CLOSE c_AllItemsWithBatches
	DEALLOCATE c_AllItemsWithBatches
	
	UPDATE Item SET InventoryQuantityDecimalValue = 0 WHERE Oid IN (SELECT Oid FROM @Items) AND InventoryQuantityDecimalValue is null 
	UPDATE Item SET AvailableInventoryQuantityDecimalValue = InventoryQuantityDecimalValue WHERE Oid IN (SELECT Oid FROM @Items) AND AvailableInventoryQuantityDecimalValue is null 
	UPDATE Item SET OnOrderQuantityDecimalValue = 0 WHERE Oid IN (SELECT Oid FROM @Items) AND OnOrderQuantityDecimalValue is null
	UPDATE Item SET WantListQuantityDecimalValue = 0 WHERE Oid IN (SELECT Oid FROM @Items) AND WantListQuantityDecimalValue is null
	UPDATE Item SET XRefInventoryQuantityDecimalValue = 0 WHERE Oid IN (SELECT Oid FROM @Items) AND XRefInventoryQuantityDecimalValue is null
	UPDATE Item SET XRefOnOrderQuantityDecimalValue = 0 WHERE Oid IN (SELECT Oid FROM @Items) AND XRefOnOrderQuantityDecimalValue is null
	UPDATE Item SET CrossReferences = '' WHERE CrossReferences Is Null
	UPDATE Item SET BatchesWithInventory = '' WHERE BatchesWithInventory Is Null
	UPDATE Item SET LinkedInventoryLocations = '' WHERE LinkedInventoryLocations Is Null
	UPDATE Item SET TotalInventoryValue = 0  WHERE Oid IN (SELECT Oid FROM @Items) AND TotalInventoryValue is null 
	
	UPDATE Item SET 
		InventoryQuantityStringValue = dbo.FormatDecimalToString(InventoryQuantityDecimalValue),
		AvailableInventoryQuantityStringValue = dbo.FormatDecimalToString(AvailableInventoryQuantityDecimalValue),
		OnOrderQuantityStringValue = dbo.FormatDecimalToString(OnOrderQuantityDecimalValue),
		WantListQuantityStringValue = dbo.FormatDecimalToString(WantListQuantityDecimalValue),
		XRefInventoryQuantityStringValue = dbo.FormatDecimalToString(XRefInventoryQuantityDecimalValue),
		XRefOnOrderQuantityStringValue = dbo.FormatDecimalToString(XRefOnOrderQuantityDecimalValue)
	WHERE Oid IN (SELECT Oid FROM @Items)

	SELECT	@CrossReferences = CrossReferences, 
			@BatchesWithInventory = BatchesWithInventory,
			@LinkedInventoryLocations = LinkedInventoryLocations,
			@XRefInventoryQuantity = XRefInventoryQuantityDecimalValue, 
			@XRefOnOrderQuantity = XRefOnOrderQuantityDecimalValue, 
			@OnOrderQuantity = OnOrderQuantityDecimalValue, 
			@InventoryQuantity = InventoryQuantityDecimalValue, 
			@AvailableInventoryQuantity = AvailableInventoryQuantityDecimalValue,
			@WantListQuantity = WantListQuantityDecimalValue,
			@LastEventOccurredOn = LastEventOccurredOn, 
			@LastReceivedOn = LastReceivedOn,
			@TotalInventoryValue = TotalInventoryValue
	FROM Item
	WHERE Oid = @Item

END
GO
