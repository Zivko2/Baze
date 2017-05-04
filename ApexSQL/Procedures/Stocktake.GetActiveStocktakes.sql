SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Stocktake].[GetActiveStocktakes]
AS
BEGIN

	select st.Oid StocktakeId, st.Name, g.CountByBatch from StockTake st
	join StockTakeGroup g on g.Oid = st.StockTakeGroup
	where [Status] = 10 --InProgress
		 
END
GO
