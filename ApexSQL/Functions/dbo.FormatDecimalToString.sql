SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FormatDecimalToString](@DecimalValue DECIMAL(19, 5)) 
RETURNS VARCHAR(50)
AS
BEGIN

	DECLARE @StringDecimal VARCHAR(50)
	SET @StringDecimal = CONVERT(VARCHAR(50), @DecimalValue)
	IF @StringDecimal = '0.00000' SET @StringDecimal = '0'
	RETURN CASE WHEN PATINDEX('%[1-9]%', REVERSE(@StringDecimal)) < PATINDEX('%.%', REVERSE(@StringDecimal)) THEN LEFT(@StringDecimal, LEN(@StringDecimal) - PATINDEX('%[1-9]%', REVERSE(@StringDecimal)) + 1) ELSE LEFT(@StringDecimal, LEN(@StringDecimal) - PATINDEX('%.%', REVERSE(@StringDecimal))) END

END
GO
