SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- Author:		Chad Michael
-- Create date: April 23, 2013
-- Description:	Based on the date and from and to 
--	currencies specified, calculate the exchange rate.
-- Note: This function is not used by APEX and is only 
--  here to help visualize exchange rates.
-- ====================================================
/* Usage:
DECLARE @Rate DECIMAL(18, 4)
SET @Rate = [Staged].GetExchangeRate('AUD', 'USD', '1/1/2010')
PRINT @Rate

-- For testing purposes, here is a query that can be used to show several exchange rates over 
-- time using this function
SELECT	StartDate, 
		dbo.GetExchangeRate('USD', 'PGK', StartDate) AS USDToPGK,
		dbo.GetExchangeRate('USD', 'AUD', StartDate) AS USDToAUD,
		dbo.GetExchangeRate('PGK', 'USD', StartDate) AS PGKToUSD,
		dbo.GetExchangeRate('AUD', 'USD', StartDate) AS AUDToUSD,
		dbo.GetExchangeRate('PGK', 'AUD', StartDate) AS PGKToAUD,
		dbo.GetExchangeRate('AUD', 'PGK', StartDate) AS AUDToPGK
FROM	[Staged].ExchangeRateToUSDBase
GROUP BY StartDate
ORDER BY StartDate DESC

*/
CREATE FUNCTION [Staged].[GetExchangeRate](@FromCurrency CHAR(3), @ToCurrency CHAR(3), @RateAsOf DATETIME) 
RETURNS DECIMAL(18, 4)
AS
BEGIN
	/*
	DECLARE @FromCurrency VARCHAR(10)
	DECLARE @ToCurrency VARCHAR(10)
	DECLARE @RateAsOf DATETIME
	SELECT @FromCurrency = 'PGK', @ToCurrency = 'AUD', @RateAsOf = '1/1/2010'
	*/	

	DECLARE @Rate DECIMAL(18, 4)
	DECLARE @USDToFromCurrencyRate DECIMAL(18, 4)
	DECLARE @USDToToCurrencyRate DECIMAL(18, 4)
	DECLARE @ReturnInverse TINYINT

	--We want the exchange rate as of the datetime specified.
	--Add one second to be sure to get it and not the one before it.
	SET @RateAsOf = DATEADD(second, 1, @RateAsOf)

	IF @FromCurrency = @ToCurrency BEGIN
		SET @Rate = 1
	END ELSE BEGIN
		-- If converting from USD, we want to take the inverse of the calculated rate.
		-- set the toggle now and check it at the end and inverse if needed.
		IF @FromCurrency = 'USD' BEGIN
			--switch the from and to and process normally. At the end, take the inverse.
			SELECT	@ReturnInverse = 1,
					@FromCurrency = @ToCurrency,
					@ToCurrency = 'USD'
		END	ELSE BEGIN
			SET @ReturnInverse = 0
		END
		
		--Isolate the rate for the date specified
		SELECT	TOP 1 @USDToFromCurrencyRate = Rate
		FROM	[Staged].[ExchangeRateToUSDBase]
		WHERE	StartDate < @RateAsOf
				AND SourceCurrency IN (@FromCurrency)
		ORDER BY StartDate DESC

		IF @ToCurrency = 'USD' BEGIN
			SET @USDToToCurrencyRate = 1
		END ELSE BEGIN
			SELECT	TOP 1 @USDToToCurrencyRate = Rate
			FROM	[Staged].[ExchangeRateToUSDBase]
			WHERE	StartDate < @RateAsOf
					AND SourceCurrency IN (@ToCurrency)
			ORDER BY StartDate DESC
		END
		
		IF @ReturnInverse = 1 BEGIN
			SELECT @Rate = CAST(ROUND(1 / CAST(ROUND(@USDToToCurrencyRate / @USDToFromCurrencyRate, 4) AS decimal(18, 4)), 4) AS decimal(18, 4))
		END ELSE BEGIN
			SELECT @Rate = CAST(ROUND(@USDToToCurrencyRate / @USDToFromCurrencyRate, 4) AS decimal(18, 4))
		END

	END
	/*
	PRINT @USDToFromCurrencyRate
	PRINT @USDToToCurrencyRate
	PRINT @Rate
	*/
	RETURN @Rate

END
GO
