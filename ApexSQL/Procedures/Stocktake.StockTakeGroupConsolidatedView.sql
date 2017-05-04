SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- Create Procedure StockTakeGroupConsolidatedView
CREATE PROCEDURE [Stocktake].[StockTakeGroupConsolidatedView] @StockTakeGroup UNIQUEIDENTIFIER AS
BEGIN

	SELECT * FROM [Stocktake].[StockTakeGroupConsolidated1](@StockTakeGroup)

END
GO
