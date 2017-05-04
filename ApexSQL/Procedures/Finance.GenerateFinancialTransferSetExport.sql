SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- Create Procedure GenerateFinancialTransferSetExport
CREATE PROCEDURE [Finance].[GenerateFinancialTransferSetExport] 
	@SystemName VARCHAR(100), 
	@SetStartDate DATETIME, 
	@SetEndDate DATETIME, 
	@Currency VARCHAR(3)
AS
BEGIN
	SET NOCOUNT ON;


DECLARE @DirectCustomerSalesTotal DECIMAL(19, 4)
DECLARE @WorkOrderSalesTotal DECIMAL(19, 4)
DECLARE @TotalValueReceivedIntoInventory DECIMAL(19, 4)
DECLARE @TotalCurrentInventoryValue DECIMAL(19, 4)

DECLARE @SetBalanced BIT = 0

--DECLARE	@SystemName VARCHAR(100) 
--DECLARE	@SetStartDate DATETIME
--DECLARE	@SetEndDate DATETIME 
--DECLARE	@Currency VARCHAR(3)
---- SELECT * FROM FinancialTransferSet
--	SELECT @SetStartDate = '2015-09-01 00:00:00.000', @SetEndDate = '2015-09-30 23:59:59.000', @Currency = 'USD', @SystemName = 'ApexTest '

	DECLARE @CompanyCode VARCHAR(100)

	IF @Currency <> (SELECT TOP 1 BaseCurrency FROM GlobalSetting)
	BEGIN
		RAISERROR (N'Currency "%s" is not implemented.'
			, 16
			, 1
			, @Currency);
	END ELSE BEGIN
		IF NOT EXISTS(SELECT * FROM FinancialTransferSet WHERE SetStartDate = @SetStartDate AND SetEndDate = @SetEndDate) 
		BEGIN
			DECLARE @SetRange VARCHAR(50)
			SET @SetRange = CONVERT(VARCHAR(20), @SetStartDate) + ' ending ' + CONVERT(VARCHAR(20), @SetEndDate)
			RAISERROR (N'Could not find financial transfer set starting on "%s"'
				, 16
				, 1
				, @SetRange);

		END ELSE BEGIN
	
			DECLARE @prevFTS UNIQUEIDENTIFIER, @SubmittedBy UNIQUEIDENTIFIER, @StockTakeGroup UNIQUEIDENTIFIER, @DefaultDescription VARCHAR(100)
			DECLARE @CashReconciliationOverShortAccount UNIQUEIDENTIFIER, @ClearingCashSalesAccount UNIQUEIDENTIFIER
			SELECT	TOP 1 
					@DefaultDescription = DefaultFinancialTransferDescription, 
					@CompanyCode = IsNull(UPPER(LEFT(CompanyIdentificationCodeForFinance, 2)), UPPER(LEFT(@SystemName, 2))), --Use CompanyCode instead of system name if one is specified
					@CashReconciliationOverShortAccount = CashReconciliationOverShortAccount,
					@ClearingCashSalesAccount = ClearingCashSalesAccount
			FROM	GlobalSetting

			--If they are attempting to gather sales before the previous has been submitted, then error out
			SELECT @StockTakeGroup = StockTakeGroup FROM FinancialTransferSet WHERE SetStartDate = @SetStartDate AND SetEndDate = @SetEndDate AND GCRecord Is Null
			SELECT @prevFTS = Oid, @SubmittedBy = SubmittedBy FROM FinancialTransferSet WHERE SetStartDate = (SELECT MAX(SetStartDate) FROM FinancialTransferSet WHERE SetStartDate < @SetStartDate) AND GCRecord Is Null
			IF (@SubmittedBy Is Null AND @prevFTS Is Not Null AND @StockTakeGroup Is Null)
			BEGIN
				RAISERROR (N'Cannot gather financial activity for this set until the previous set has been submitted to finance.'
					, 16
					, 1);
			END ELSE BEGIN			
				
				DECLARE @FTS UNIQUEIDENTIFIER, @SalesGatheredOn DATETIME
				
				SELECT @FTS = Oid, @SalesGatheredOn = SalesGatheredOn FROM FinancialTransferSet WHERE SetStartDate = @SetStartDate AND SetEndDate = @SetEndDate AND GCRecord Is Null
				
				--Account for regathering sales if already gathered previously
				IF @SalesGatheredOn < @SetEndDate SET @SetEndDate = @SalesGatheredOn
				
				PRINT @SalesGatheredOn
				PRINT @SetEndDate
				
				--Ok, first check to see if we are running this for the first time and need
				--to gather up all the sales for this financial transfer set
				
				IF NOT EXISTS(SELECT * FROM Sale WHERE FinancialTransferSet = @FTS)
				BEGIN
					PRINT 'Gathering Sales'
					--We need to collect all the sales that are not already assigned to a 
					--period end and assign them now.
					UPDATE	Sale 
						SET FinancialTransferSet = @FTS 
					WHERE	FinancialTransferSet Is Null 
							AND Sale.TransactionDate >= @SetStartDate --Only get sales that happenned after the period end start date
							AND Sale.TransactionDate < @SetEndDate
							AND Sale.GCRecord Is Null
				END ELSE BEGIN 
					PRINT 'Sales already gathered'
				END
			
				--Do the same for things received in this period
				IF NOT EXISTS(SELECT * FROM BatchLineItem WHERE FinancialTransferSet = @FTS)
				BEGIN
					PRINT 'Gathering Receiving'
					--We need to collect all the batch line items that are not already assigned to a 
					--financial transfer set and assign them now.
					UPDATE	BatchLineItem 
						SET FinancialTransferSet = @FTS 
					WHERE	FinancialTransferSet Is Null 
							AND BatchLineItem.ReceivedOn >= @SetStartDate --Only get items that were received after the period end start date
							AND BatchLineItem.ReceivedOn < @SetEndDate 
							AND BatchLineItem.GCRecord Is Null
				END ELSE BEGIN 
					PRINT 'Receiving already gathered'
				END

				--Gather any line item cost adjustments that were created "Post Received" to adjust inventory and COGS
				IF NOT EXISTS(SELECT * FROM LineItemCost WHERE FinancialTransferSet = @FTS)
				BEGIN
					PRINT 'Gathering Receiving Adjustments'
					--We need to collect all the batch line items that are not already assigned to a 
					--financial transfer set and assign them now.
					UPDATE	LineItemCost 
						SET FinancialTransferSet = @FTS 
						--SELECT * FROM LineItemCost
					WHERE	FinancialTransferSet Is Null 
							AND CreatedPostReceived = 1
							AND ActualCostEnteredOn >= @SetStartDate --Only get items that had actual costs entered after the period end start date
							AND ActualCostEnteredOn < @SetEndDate 
							AND GCRecord Is Null
				END ELSE BEGIN 
					PRINT 'Receiving Adjustments already gathered'
				END

				--Gather cash drawer reconciliations for this FTS period
				IF NOT EXISTS(SELECT * FROM CashDrawerReconciliation WHERE FinancialTransferSet = @FTS)
				BEGIN
					PRINT 'Gathering Cash Drawer Reconciliations'
					--We need to collect all the cash drawer reconciliations that are not already assigned to a 
					--financial transfer set and assign them now.
					UPDATE	CashDrawerReconciliation 
						SET FinancialTransferSet = @FTS 
					WHERE	FinancialTransferSet Is Null 
							AND CompletedOn >= @SetStartDate --Only get reconciliations that completed after the period end start date
							AND CompletedOn < @SetEndDate 
							AND GCRecord Is Null
				END ELSE BEGIN 
					PRINT 'Cash Drawer Reconciliations already gathered'
				END

				--Generate transfers from customers accounts 
				DECLARE @SalesByWorkOrder TABLE  (WorkOrderNumber VARCHAR(100), Description VARCHAR(100), CustomerAccountNumber VARCHAR(100), IncomeAccountNumber VARCHAR(100), TotalSaleAmount MONEY, Currency VARCHAR(3))
				INSERT INTO @SalesByWorkOrder
					SELECT	CASE WHEN RT.AggregateSalesInFinancialTransferSet = 1 THEN 
								IsNull(WO.WorkOrderNumber + IsNull(S.TransactionDescription, ''), IsNull(S.TransactionDescription, 'APEX ' + IsNull(@DefaultDescription, ''))) 
							ELSE
								S.SaleNumber + ' ' +IsNull(WO.WorkOrderNumber, '') + IsNull(S.TransactionDescription, 'APEX ' + IsNull(@DefaultDescription, ''))
							END,
							null,
							IsNull(GLAC.AccountNumber, 'NO CUSTOMER ACCT [?Commercial?]') AS CustomerAccountNumber,
							IsNull(GLA.AccountNumber, 'NO INCOME ACCT ERR') AS IncomeAccountNumber,
							--Avoid rounding errors: When there is no income account, it is meant to indicate that we are selling at cost
							--We calculate cost to 4 decimal places, but we can only sell in real currency denominations (i.e. 2 decimal places for USD)
							--Therefore when we sell at cost, use the actual COGSAdjustment value instead of the derived sale price to avoid rounding errors.
							--Another approach would be to use the sale price (to ensure that we never show a different sale amount on the receipt vs this transaction)
							--and add a rounding error line to the GL file.
							--If the ItemHistoryType is an Adjustment (IH.ItemHistoryType = 50), then the COGS will be zero, so in this case, we use the LandedUnitCost
							CASE WHEN INCA.Oid Is Not Null OR IH.ItemHistoryType = 50 THEN 
								CASE WHEN SLIT.IsForReturns = 1 THEN -1 ELSE 1 END * IsNull(IsNull(IH.LandedUnitCost, 0) * SLI.QuantityDecimalValue, 0) 
							ELSE
								-1 * IsNull(ROUND(IH.COGSAdjustment, 2), 0)
							END,
							@Currency
					FROM	Sale S
							LEFT JOIN SaleLineItem SLI ON SLI.Sale = S.Oid
							LEFT JOIN Customer C ON C.Oid = S.Customer
							LEFT JOIN GLAccount GLAC ON GLAC.AccountNumber = C.AccountNumberReference
							LEFT JOIN RateType RT ON RT.Oid = S.RateType
							LEFT JOIN PaymentMethod PM ON PM.Oid = S.PaymentMethod
							LEFT JOIN Item I ON I.Oid = SLI.Item
							LEFT JOIN IncomeAccount IA ON IA.AccountingGroup = I.AccountingGroup AND IA.RateType = RT.Oid
							LEFT JOIN GLAccount GLA ON GLA.Oid = IA.IncomeGLAccount
							
							LEFT JOIN ItemHistory IH ON IH.SaleLineItem = SLI.Oid
							LEFT JOIN Inventory INV ON INV.Oid = IH.Inventory
							LEFT JOIN BatchLineItem BLI ON BLI.Oid = INV.BatchLineItem
							LEFT JOIN InventoryAccount INVA ON INVA.Oid = BLI.InventoryAccount
							LEFT JOIN AccountingGroup AG ON AG.Oid = I.AccountingGroup
							LEFT JOIN InventoryAccount INVA2 ON INVA2.Oid = AG.DefaultInventoryAccount
							LEFT JOIN IncomeAccount INCA ON INCA.AccountingGroup = I.AccountingGroup AND INCA.RateType = S.RateType
							
							LEFT JOIN WorkOrder WO ON WO.Oid = S.WorkOrder
							LEFT JOIN SaleLineItemType SLIT ON SLIT.Oid = SLI.SaleLineItemType
					WHERE	S.FinancialTransferSet = @FTS
							AND IsNull(PM.IncludeInFinancialTransferSet, 0) = 1 -- only involve payment methods that require a transfer (i.e. not cash or cheque, etc.)
							AND GLAC.Oid Is Not Null -- exclude anything that doesn't map to an account. It will be accounted for outside this system.
							AND IA.GCRecord Is Null AND S.GCRecord Is Null AND SLI.GCRecord Is null AND RT.GCRecord Is null
							AND GLAC.Oid <> IsNull(INVA.InventoryGLAccount, INVA2.InventoryGLAccount)
			
				--Next, we group up all the sales for this period end and build the output
				DECLARE @TransferSetExport TABLE
					(TransactionLabel VARCHAR(100), [Description] VARCHAR(100), AccountNumber VARCHAR(100), AccountName VARCHAR(100), Amount MONEY, Currency VARCHAR(3))
				
				INSERT INTO @TransferSetExport 
					SELECT	WorkOrderNumber,
							SBWO.[Description],
							SBWO.CustomerAccountNumber,
							GLA.Name,
							SUM(TotalSaleAmount),
							Currency
					FROM	@SalesByWorkOrder SBWO
							LEFT JOIN GlAccount GLA ON GLA.AccountNumber = SBWO.CustomerAccountNumber
					GROUP BY SBWO.CustomerAccountNumber, GLA.Name, Currency, WorkOrderNumber, SBWO.[Description]
		
				--Generate transfers to the income accounts
				INSERT INTO @TransferSetExport 
					SELECT	'',
							null,
							SBWO.IncomeAccountNumber,
							GLA.Name,
							-SUM(TotalSaleAmount),
							Currency
					FROM	@SalesByWorkOrder SBWO
							LEFT JOIN GlAccount GLA ON GLA.AccountNumber = SBWO.IncomeAccountNumber
					WHERE	GLA.Oid Is Not Null
					GROUP BY SBWO.IncomeAccountNumber, GLA.Name, Currency
				
				--Generate transfers from the cost type debit accounts
				INSERT INTO @TransferSetExport
					SELECT	null, CT.Name, GLA.AccountNumber, GLA.Name, SUM(LIC.ActualCostBaseAmount), @Currency
					FROM	LineItemCost LIC
							JOIN CostType CT ON CT.Oid = LIC.CostType
							JOIN GLAccount GLA ON GLA.Oid = CT.DefaultGLAccount
							JOIN BatchLineItem BLI ON BLI.Oid = LIC.BatchLineItem
					WHERE	(LIC.FinancialTransferSet = @FTS OR (LIC.FinancialTransferSet Is Null AND BLI.FinancialTransferSet = @FTS)) 
							AND CT.GenerateAccountTransfers = 1
					GROUP BY GLA.AccountNumber, GLA.Name, CT.Name
				
				--Generate transfers to the cost type credit accounts
				INSERT INTO @TransferSetExport
					SELECT	null, CT.Name, GLA.AccountNumber, GLA.Name, -SUM(LIC.ActualCostBaseAmount), @Currency
					FROM	LineItemCost LIC
							JOIN CostType CT ON CT.Oid = LIC.CostType
							JOIN GLAccount GLA ON GLA.Oid = CT.AccountToCredit
							JOIN BatchLineItem BLI ON BLI.Oid = LIC.BatchLineItem
					WHERE	(LIC.FinancialTransferSet = @FTS OR (LIC.FinancialTransferSet Is Null AND BLI.FinancialTransferSet = @FTS)) 
							AND CT.GenerateAccountTransfers = 1
					GROUP BY GLA.AccountNumber, GLA.Name, CT.Name
				
				--Now Create the COGS entry
				DECLARE @COGSTable TABLE (COGSAccountNumber VARCHAR(100), COGSAccountName VARCHAR(100), INVAccountNumber VARCHAR(100), INVAccountName VARCHAR(100), COGSAmount DECIMAL(19, 5), INVAmount DECIMAL(19, 5))

				--When studying this COGS section, note that only sales using rate types that are assinged to an accounting group 
				--will be included in cogs. For Example, when a department sells to itself, it is not included in the COGS
				INSERT INTO @COGSTable
					SELECT	IsNull(COGS_GLA.AccountNumber, COGS_GLA2.AccountNumber), 
							IsNull(COGS_GLA.Name, COGS_GLA2.Name), 
							IsNull(INV_GLA.AccountNumber, INV_GLA2.AccountNumber), 
							IsNull(INV_GLA.Name, INV_GLA2.Name),
							SUM(CASE WHEN INCA.Oid Is Null THEN 0 ELSE 1 END * ROUND(IH.COGSAdjustment, 2)),
							--Consider both COGS adjustmets to debit inventory as well as quantity adjustments (i.e. ItemHistoryType 50)
							--Unless the adjustment was made directly to the inventory GL account as in the case of changing received quantity
							SUM(ROUND(IH.COGSAdjustment, 2) + 
								CASE WHEN IH.ItemHistoryType = 50 AND GLA_C.Oid <> IsNull(IA.InventoryGLAccount, IA2.InventoryGLAccount) THEN 
									IsNull(IH.QuantityDecimalValue, 0) * IsNull(IH.LandedUnitCost, 0) ELSE 0 END)
					FROM	Sale S
							LEFT JOIN SaleLineItem SLI ON SLI.Sale = S.Oid
							LEFT JOIN Customer C ON C.Oid = S.Customer
							LEFT JOIN GLAccount GLA_C ON GLA_C.AccountNumber = C.AccountNumberReference
							LEFT JOIN SaleLineItemType SLIT ON SLIT.Oid = SLI.SaleLineItemType
							LEFT JOIN RateType RT ON RT.Oid = S.RateType
							LEFT JOIN ItemHistory IH ON IH.SaleLineItem = SLI.Oid
							LEFT JOIN Inventory INV ON INV.Oid = IH.Inventory
							LEFT JOIN BatchLineItem BLI ON BLI.Oid = INV.BatchLineItem
							LEFT JOIN InventoryAccount IA ON IA.Oid = BLI.InventoryAccount
							LEFT JOIN GLAccount COGS_GLA ON COGS_GLA.Oid = IA.COGSGLAccount
							LEFT JOIN GLAccount INV_GLA ON INV_GLA.Oid = IA.InventoryGLAccount
							LEFT JOIN Item I ON I.Oid = SLI.Item
							LEFT JOIN AccountingGroup AG ON AG.Oid = I.AccountingGroup
							LEFT JOIN IncomeAccount INCA ON INCA.AccountingGroup = I.AccountingGroup AND INCA.RateType = S.RateType
							LEFT JOIN InventoryAccount IA2 ON IA2.Oid = AG.DefaultInventoryAccount
							LEFT JOIN GLAccount COGS_GLA2 ON COGS_GLA2.Oid = IA2.COGSGLAccount
							LEFT JOIN GLAccount INV_GLA2 ON INV_GLA2.Oid = IA2.InventoryGLAccount
					WHERE	S.FinancialTransferSet = @FTS
							AND IsNull(COGS_GLA.AccountNumber, COGS_GLA2.AccountNumber) Is Not Null
							AND IA.GCRecord Is Null AND S.GCRecord Is Null AND SLI.GCRecord Is null 
							AND INCA.GCRecord Is null
					GROUP BY IsNull(COGS_GLA.AccountNumber, COGS_GLA2.AccountNumber),
							 IsNull(COGS_GLA.Name, COGS_GLA2.Name), 
							 IsNull(INV_GLA.AccountNumber, INV_GLA2.AccountNumber), 
							 IsNull(INV_GLA.Name, INV_GLA2.Name),
							 IsNull(BLI.InventoryAccount, IA2.Oid)

				--PRINT 'Collecting Receiving Adjustments...'
				--Account for line item cost adjustments to COGS for any sold items
				INSERT INTO @COGSTable
					SELECT	 IsNull(COGS_GLA.AccountNumber, COGS_GLA2.AccountNumber), 
							 IsNull(COGS_GLA.Name, COGS_GLA2.Name), 
							 IsNull(INV_GLA.AccountNumber, INV_GLA2.AccountNumber), 
							 IsNull(INV_GLA.Name, INV_GLA2.Name),
							 SUM(IsNull(IH.COGSAdjustment, 0)),
							 SUM(IsNull(IH.COGSAdjustment, 0)) 
					FROM	LineItemCost LIC
							LEFT JOIN BatchLineItem BLI ON BLI.Oid = LIC.BatchLineItem
							LEFT JOIN Inventory INV ON INV.Oid = BLI.Inventory
							LEFT JOIN ItemHistory IH ON IH.LineItemCost = LIC.Oid AND ItemHistoryType = 60
							LEFT JOIN SaleLineItem SLI ON SLI.Oid = IH.SaleLineItem
							LEFT JOIN Sale S ON S.Oid = SLI.Sale
							LEFT JOIN SaleLineItemType SLIT ON SLIT.Oid = SLI.SaleLineItemType
							LEFT JOIN RateType RT ON RT.Oid = S.RateType
							LEFT JOIN InventoryAccount IA ON IA.Oid = BLI.InventoryAccount
							LEFT JOIN GLAccount COGS_GLA ON COGS_GLA.Oid = IA.COGSGLAccount
							LEFT JOIN GLAccount INV_GLA ON INV_GLA.Oid = IA.InventoryGLAccount
							LEFT JOIN Item I ON I.Oid = BLI.Item
							LEFT JOIN AccountingGroup AG ON AG.Oid = I.AccountingGroup
							LEFT JOIN IncomeAccount INCA ON INCA.AccountingGroup = I.AccountingGroup AND INCA.RateType = S.RateType
							LEFT JOIN InventoryAccount IA2 ON IA2.Oid = AG.DefaultInventoryAccount
							LEFT JOIN GLAccount COGS_GLA2 ON COGS_GLA2.Oid = IA2.COGSGLAccount
							LEFT JOIN GLAccount INV_GLA2 ON INV_GLA2.Oid = IA2.InventoryGLAccount
					WHERE	LIC.FinancialTransferSet = @FTS
							AND IA.GCRecord Is Null AND S.GCRecord Is Null AND SLI.GCRecord Is null 
							--AND S.FinancialTransferSet <> @FTS AND S.FinancialTransferSet Is Not Null
							--AND INCA.GCRecord Is null AND LIC.GCRecord Is Null
							--AND S.TransactionDate Is Not Null AND S.TransactionDate < LIC.ActualCostEnteredOn -- only get sales that happened in a previous FTS
					GROUP BY IsNull(COGS_GLA.AccountNumber, COGS_GLA2.AccountNumber),
							 IsNull(COGS_GLA.Name, COGS_GLA2.Name), 
							 IsNull(INV_GLA.AccountNumber, INV_GLA2.AccountNumber), 
							 IsNull(INV_GLA.Name, INV_GLA2.Name),
							 IsNull(BLI.InventoryAccount, IA2.Oid)

						  
				--Collect COGS activity
				INSERT INTO @TransferSetExport 
					SELECT	'',
							@SystemName + 'COGS-' + @Currency,
							COGSAccountNumber,
							COGSAccountName,
							-1 * SUM(COGSAmount), 
							@Currency
					FROM	@COGSTable
					WHERE	COGSAccountNumber Is Not Null
					GROUP BY COGSAccountNumber, COGSAccountName, INVAccountNumber, INVAccountName
							
				--And the debit to inventory of COGS
				INSERT INTO @TransferSetExport 
					SELECT	'',
							@SystemName + 'INV-' + @Currency,
							INVAccountNumber,
							INVAccountName,
							SUM(INVAmount), 
							@Currency
					FROM	@COGSTable
					WHERE	COGSAccountNumber Is Not Null
					GROUP BY COGSAccountNumber, COGSAccountName, INVAccountNumber, INVAccountName

				--Cash Drawer Reconciliation GL entries
				INSERT INTO @TransferSetExport 
					SELECT TransactionLabel, [Description], AccountNumber, AccountName, SUM(Amount), Currency
					FROM (
						SELECT	'' AS TransactionLabel,
								@SystemName + 'CSHDWR-' + CE.Currency AS [Description],
								IsNULL(GLA.AccountNumber, '[NO CLEARING ACCT]') AS AccountNumber,
								IsNULL(GLA.Name, 'Cash Drawer Reconciliation Account') AS AccountName,
								FinalBalance - (StartingBalance + SUM(CashIn - CashOut)) AS Amount, 
								CE.Currency AS Currency
						FROM	CashDrawerReconciliation CDR
								LEFT JOIN ( SELECT source.Oid, source.CashDrawer, source.DateTime, source.Type, source.Reason, source.Cashier, source.Currency, source.CashIn, source.CashOut, main_source.Oid AS Reconciliation, source.Sale, source.OptimisticLockField, source.GCRecord FROM [dbo].[CashEvent] AS source INNER JOIN [dbo].[CashDrawerReconciliation] AS main_source ON source.CashDrawerReconciliationID = main_source.CashDrawerReconciliationID ) CE ON CE.Reconciliation = CDR.Oid
								LEFT JOIN GLAccount GLA ON GLA.Oid = @ClearingCashSalesAccount
						WHERE	CDR.FinancialTransferSet  = @FTS
						GROUP BY CE.Currency, CDR.Oid, CDR.StartingBalance, CDR.FinalBalance, GLA.AccountNumber, GLA.Name) AS CR
					GROUP BY TransactionLabel, [Description], AccountNumber, AccountName, Currency

				INSERT INTO @TransferSetExport 
					SELECT TransactionLabel, [Description], AccountNumber, AccountName, SUM(Amount), Currency
					FROM (
						SELECT	'' AS TransactionLabel,
								@SystemName + 'CSHDWR-' + CE.Currency AS [Description],
								IsNULL(GLA.AccountNumber, '[NO OVER SHORT ACCT]') AS AccountNumber,
								IsNULL(GLA.Name, 'Cash Reconciliation Over/Short Account') AS AccountName,
								-(FinalBalance - (StartingBalance + SUM(CashIn - CashOut))) AS Amount, 
								CE.Currency AS Currency
						FROM	CashDrawerReconciliation CDR
								LEFT JOIN ( SELECT source.Oid, source.CashDrawer, source.DateTime, source.Type, source.Reason, source.Cashier, source.Currency, source.CashIn, source.CashOut, main_source.Oid AS Reconciliation, source.Sale, source.OptimisticLockField, source.GCRecord FROM [dbo].[CashEvent] AS source INNER JOIN [dbo].[CashDrawerReconciliation] AS main_source ON source.CashDrawerReconciliationID = main_source.CashDrawerReconciliationID ) CE ON CE.Reconciliation = CDR.Oid
								LEFT JOIN GLAccount GLA ON GLA.Oid = @CashReconciliationOverShortAccount
						WHERE	CDR.FinancialTransferSet  = @FTS
						GROUP BY CE.Currency, CDR.Oid, CDR.StartingBalance, CDR.FinalBalance, GLA.AccountNumber, GLA.Name) AS CR
					GROUP BY TransactionLabel, [Description], AccountNumber, AccountName, Currency

					
				--Now we are ready to concatenate the export data from the summarized records

				DECLARE @Description VARCHAR(100), @AccountNumber VARCHAR(100), @AccountName VARCHAR(100), @Reference VARCHAR(100)
				DECLARE @Amount MONEY
				--DECLARE @Currency VARCHAR(3)
				
				--SELECT * FROM @TransferSetExport
				
				DECLARE tse_cursor CURSOR FOR
					SELECT TransactionLabel, [Description], AccountNumber, AccountName, Amount, Currency FROM @TransferSetExport WHERE Amount <> 0

				OPEN tse_cursor
				FETCH NEXT FROM tse_cursor INTO @Reference, @Description, @AccountNumber, @AccountName, @Amount, @Currency;

				DECLARE @ExportData VARCHAR(MAX)
				SET @ExportData = ''
				
				WHILE @@FETCH_STATUS = 0
				BEGIN
		 
					SET @ExportData = @ExportData
						+ '"1","'
						+ CONVERT(VARCHAR(10), CAST(@SetEndDate as DATE), 112)
						+ '","","' + @CompanyCode + '","' + LEFT(COALESCE(@Description, @DefaultDescription, @SystemName + ' Charges'), 26) + '","'
						+ LEFT(ISNULL(@AccountName, ''), 16)
						+ '","","","","'
						+ IsNull(@AccountNumber, 'NOACCT')
						+ '","'
						+ LEFT(IsNull(@Reference, @SystemName), 16)
						+ '","'
						+ IsNull(CONVERT(VARCHAR(50), @Amount), '0.00')
						+ '","'
						+ @Currency + '"'
						+ CHAR(13)
						+ CHAR(10)
			
					FETCH NEXT FROM tse_cursor INTO @Reference, @Description, @AccountNumber, @AccountName, @Amount, @Currency;
				END
				
				CLOSE tse_cursor
				DEALLOCATE tse_cursor

				UPDATE FinancialTransferSet 
					SET TransferSetExport = @ExportData
					WHERE Oid = @FTS 
							
				SELECT @ExportData

				SELECT	@DirectCustomerSalesTotal = 
						IsNull(SUM(CASE WHEN SLIT.IsForReturns = 1 THEN -1 ELSE 1 END * SLI.UnitWholesaleValue * SLI.QuantityDecimalValue), 0)
				FROM	Sale S 
						LEFT JOIN SaleLineItem SLI ON SLI.Sale = S.Oid
						LEFT JOIN SaleLineItemType SLIT ON SLIT.Oid = SLI.SaleLineItemType
						INNER JOIN Item I ON I.Oid = SLI.Item
						INNER JOIN AccountingGroup AG ON AG.Oid = I.AccountingGroup
				WHERE	FinancialTransferSet = @FTS 
						AND AG.TrackQuantities = 1
						AND S.WorkOrder Is Null
						AND S.GCRecord Is Null
						AND SLI.GCRecord Is Null
						AND SLIT.GCRecord Is Null
						
				SELECT	@WorkOrderSalesTotal = 
						IsNull(SUM(CASE WHEN SLIT.IsForReturns = 1 THEN -1 ELSE 1 END * SLI.UnitWholesaleValue * SLI.QuantityDecimalValue), 0)
				FROM	Sale S
						LEFT JOIN SaleLineItem SLI ON SLI.Sale = S.Oid
						LEFT JOIN SaleLineItemType SLIT ON SLIT.Oid = SLI.SaleLineItemType
						INNER JOIN Item I ON I.Oid = SLI.Item
						INNER JOIN AccountingGroup AG ON AG.Oid = I.AccountingGroup
				WHERE	FinancialTransferSet = @FTS 
						AND AG.TrackQuantities = 1
						And S.WorkOrder Is Not Null
						AND S.GCRecord Is Null
						AND SLI.GCRecord Is Null
						AND SLIT.GCRecord Is Null

				SELECT	@TotalValueReceivedIntoInventory = IsNull(SUM(ReceivedTotalCost), 0)
				FROM	BatchLineItem BLI
						LEFT JOIN Inventory INV ON INV.Oid = BLI.Inventory
						INNER JOIN Item I ON I.Oid = INV.Item
						INNER JOIN AccountingGroup AG ON AG.Oid = I.AccountingGroup
				WHERE	FinancialTransferSet = @FTS
						AND AG.TrackQuantities = 1
						AND BLI.GCRecord Is Null
						AND INV.GCRecord Is Null

				SELECT	@TotalCurrentInventoryValue = IsNull(SUM(ReceivedTotalCost), 0)
				FROM	Inventory INV
						LEFT JOIN Item I ON I.Oid = INV.Item
						LEFT JOIN AccountingGroup AG ON AG.Oid = I.AccountingGroup
				WHERE	QuantityDecimalValue > 0
						AND AG.TrackQuantities = 1
						AND INV.GCRecord Is Null

				;WITH CurrencyBalance as (
					SELECT Currency, SUM(Amount) Balance FROM @TransferSetExport
					GROUP BY Currency
				)
				SELECT @SetBalanced = CASE WHEN SUM(ABS(Balance)) = 0 THEN 1 ELSE 0 END FROM CurrencyBalance

				SELECT	@DirectCustomerSalesTotal,
						@WorkOrderSalesTotal,
						@TotalValueReceivedIntoInventory,
						@TotalCurrentInventoryValue,
						@SetBalanced
			END
		END
	END
END
GO
