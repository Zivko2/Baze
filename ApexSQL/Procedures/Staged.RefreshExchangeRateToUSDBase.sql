SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Staged].[RefreshExchangeRateToUSDBase]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	MERGE [Staged].[ExchangeRateToUSDBase]
	USING [Staged].[ExchangeRateToUSDBaseForStaging] AS Source
	ON	ExchangeRateToUSDBase.SourceCurrency = Source.SourceCurrency
		AND ExchangeRateToUSDBase.StartDate = Source.StartDate
	WHEN MATCHED AND ExchangeRateToUSDBase.Rate <> Source.Rate
		  THEN UPDATE SET ExchangeRateToUSDBase.Rate = Source.Rate
	WHEN NOT MATCHED BY TARGET
		  THEN INSERT (SourceCurrency
					 , StartDate
					 , Rate) VALUES (Source.SourceCurrency , 
									 Source.StartDate , 
									 Source.Rate) 
	WHEN NOT MATCHED BY SOURCE
		  THEN DELETE
	OUTPUT $action
		 , inserted.SourceCurrency
		 , inserted.StartDate
		 , inserted.Rate
		 , deleted.SourceCurrency
		 , deleted.StartDate
		 , deleted.Rate
		   INTO [Staged].[ExchangeRateToUSDBaseChangeLog]
				 (ChangeType
				, NewSourceCurrency
				, NewStartDate
				, NewRate
				, OldSourceCurrency
				, OldStartDate
				, OldRate) ;
END;
GO
