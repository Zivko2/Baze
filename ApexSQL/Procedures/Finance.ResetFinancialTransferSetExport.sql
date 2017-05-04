SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Finance].[ResetFinancialTransferSetExport] @FinancialTransferSet UNIQUEIDENTIFIER
AS
BEGIN

	UPDATE Sale SET FinancialTransferSet = NULL WHERE FinancialTransferSet = @FinancialTransferSet
	UPDATE BatchLineItem SET FinancialTransferSet = NULL WHERE FinancialTransferSet = @FinancialTransferSet
	UPDATE LineItemCost SET FinancialTransferSet = NULL WHERE FinancialTransferSet = @FinancialTransferSet
	UPDATE CashDrawerReconciliation SET FinancialTransferSet = NULL WHERE FinancialTransferSet = @FinancialTransferSet

END
GO
