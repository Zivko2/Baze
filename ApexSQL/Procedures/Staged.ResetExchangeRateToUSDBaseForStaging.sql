SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Staged].[ResetExchangeRateToUSDBaseForStaging]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	TRUNCATE TABLE [Staged].ExchangeRateToUSDBaseForStaging
	INSERT INTO [Staged].ExchangeRateToUSDBaseForStaging (StartDate, SourceCurrency, Rate)
		SELECT CONVERT(DATETIME, CONVERT(VARCHAR(8), StartDate)), SourceCurrency, Rate FROM [PNGBRANCH_FOR_APEX].[Par].[Apex].[ExchangeRateToBase]
	
	-- add check to see that there is "recent" exchange rate data
	DECLARE @DaysToExpireExchangeRates INT
	SELECT @DaysToExpireExchangeRates = DaysToExpireExchangeRates FROM GlobalSetting

	IF	@DaysToExpireExchangeRates > 0 AND
		NOT EXISTS(SELECT * FROM [Staged].ExchangeRateToUSDBaseForStaging WHERE StartDate > GETDATE() - @DaysToExpireExchangeRates)
	BEGIN
		RAISERROR (N'Exchange rates are older than set maximum days of %d.', 
           16, -- Severity,
           1, -- State,
           @DaysToExpireExchangeRates); 

	END ELSE BEGIN
		PRINT 'Recent Exchange Rate Detected'
	END
	
END
GO
