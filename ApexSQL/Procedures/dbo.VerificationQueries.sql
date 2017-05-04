SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[VerificationQueries] @RaiseErrorOnAlerts TINYINT = 0 AS
BEGIN

	--Place queries in this stored procedure that validate the integrity of the Apex data
	--It will raise an error if any of these queries return anything and the job that runs it will
	--send an email out to technical support to investigate.

	DECLARE @Results TABLE (Message VARCHAR(500))

	--Verify that all inventory records have a batchlineitem in a valid state
	SELECT B.BatchNumber, BLI.BatchLineItemStatus, *
	FROM	Inventory INV
			LEFT JOIN BatchLineItem BLI ON BLI.Oid = INV.BatchLineItem
			LEFT JOIN Batch B ON B.Oid = BLI.Batch
	WHERE	INV.GCRecord Is Null
			AND BLI.GCRecord Is Null
			AND BLI.BatchLineItemStatus NOT IN (55, 60)

	IF @@ROWCOUNT > 0 INSERT INTO @Results VALUES ('Apex Integrity Alert: Not all inventory records have a Batch Line Item in a valid state.')

	--Verify that all the inventory records have a batch in a valid state
	SELECT	B.BatchNumber, B.BatchStatus, *
	FROM	Inventory INV
			LEFT JOIN BatchLineItem BLI ON BLI.Oid = INV.BatchLineItem
			LEFT JOIN Batch B ON B.Oid = BLI.Batch
	WHERE	INV.GCRecord Is Null
			AND B.BatchStatus NOT IN (55, 60)

	IF @@ROWCOUNT > 0 INSERT INTO @Results VALUES ('Apex Integrity Alert: Not all inventory records have a Batch in a valid state.')

	--Check that the Inventory and related BatchLineItem point to the same Item
	SELECT	* 
	FROM	Inventory INV
			LEFT JOIN BatchLineItem BLI ON BLI.Oid = INV.BatchLineItem
	WHERE	INV.Item <> BLI.Item

	IF @@ROWCOUNT > 0 INSERT INTO @Results VALUES ('Apex Integrity Alert: Inventory and related Batch Line Item reference different Items!')

	--Check that the Item from SaleLineItem matches the item in the Inventory record
	SELECT * 
	FROM	SaleLineItem SLI
			LEFT JOIN BatchLineItem BLI ON BLI.Oid = SLI.BatchLineItem
			LEFT JOIN Inventory INV ON INV.Oid = BLI.Inventory
	WHERE	INV.Item <> SLI.Item

	IF @@ROWCOUNT > 0 INSERT INTO @Results VALUES ('Apex Integrity Alert: Sale Line Item and Inventory reference different Items!')

	--Check to see if Item History Jives with Sale Line Items and Inventory	
	SELECT  SLI.Item, IH.Item, INV.Item, * 
	FROM	SaleLineItem SLI
			LEFT JOIN ItemHistory IH ON IH.SaleLineItem = SLI.Oid
			LEFT JOIN Inventory INV ON INV.Oid = IH.Inventory
	WHERE	INV.Item <> SLI.Item OR SLI.Item <> IH.Item

	IF @@ROWCOUNT > 0 INSERT INTO @Results VALUES ('Apex Integrity Alert: ItemHistory, Sale Line Item and Inventory do not all reference the sale Items!')

	--Check to see if the ItemHistory accounts for the current inventory quantity
	SELECT	QTY.*
	FROM	(
			SELECT	IH.Item, InventoryLevel, SUM(QuantityDecimalValue) AS CalculatedInventoryQuantity
			FROM	ItemHistory IH
					LEFT JOIN (
						SELECT	INV.Item, SUM(INV.QuantityDecimalValue) AS InventoryLevel
						FROM	Item I
								LEFT JOIN Inventory INV ON INV.Item = I.Oid AND INV.GCRecord Is Null
								LEFT JOIN AccountingGroup AG ON AG.Oid = I.AccountingGroup 
						WHERE	AG.TrackQuantities = 1
						GROUP BY INV.Item) IQ ON IQ.Item = IH.Item
			WHERE IH.GCRecord Is Null
			GROUP BY IH.Item, InventoryLevel) QTY
	WHERE	QTY.InventoryLevel <> QTY.CalculatedInventoryQuantity

	IF @@ROWCOUNT > 0 INSERT INTO @Results VALUES ('Apex Integrity Alert: Item History cannot account for all Inventory Quantities!')

	--Compare the Batch Quantity with the received Inventory quantity, or if inventory received quantity is zero
	SELECT	I.ItemNumber, INV.Oid, BLI.Oid, INV.ReceivedQuantityDecimalValue, BLI.QuantityDecimalValue
	FROM	Inventory INV
			LEFT JOIN BatchLineItem BLI ON BLI.Oid = INV.BatchLineItem
			LEFT JOIN Item I ON I.Oid = INV.Item
	WHERE	INV.BatchLineItem Is not Null 
			AND INV.GCRecord Is null
			AND BLI.GCRecord Is Null
			AND ((INV.ReceivedQuantityDecimalValue = 0 AND BLI.QuantityDecimalValue > 0) 
				OR
				 (INV.ReceivedQuantityDecimalValue <> BLI.QuantityDecimalValue))

	IF @@ROWCOUNT > 0 INSERT INTO @Results VALUES ('Apex Integrity Alert: There are Inventory Received Quantities that do NOT MATCH their batch line item Quantity!')

	--Find any customers without AccountNumberReference
	SELECT	*
	FROM	Customer
	WHERE	AccountNumberReference Is Null
			AND GCRecord Is Null
			AND [Enabled] = 1

	IF @@ROWCOUNT > 0 INSERT INTO @Results VALUES ('Apex Integrity Alert: There are Customer records without an Account Number Reference!')

	SELECT SaleLineItem, Inventory FROM ItemHistory WHERE SaleLineItem Is Not Null GROUP BY SaleLineItem, Inventory HAVING COUNT(*) > 1

	IF @@ROWCOUNT > 0 INSERT INTO @Results VALUES ('Apex Integrity Alert: There are duplicate Sale ItemHistory records detected!')

	--Now that we have run all the validation checks, decide if we should throw any errors based on results
	SELECT * FROM @Results

	IF EXISTS(SELECT * FROM @Results) AND @RaiseErrorOnAlerts = 1 RAISERROR ('Apex Integrity Alert: There were validation alerts from the VerificationQueries sproc. Please investigate!', 16, 1)

END
GO
