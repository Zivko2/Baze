SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ParseCommaDelimitedString] (@CommaSeparatedStr nvarchar(1000) = NULL)
RETURNS @myTable TABLE ([Id] [int] NOT NULL)
AS
BEGIN
	DECLARE @pos int, @piece varchar(500)
	-- Need to tack a delimiter onto the end of the input string if one doesn't exist
	if RIGHT(RTRIM(@CommaSeparatedStr ),1) <> ','
	SET @CommaSeparatedStr = @CommaSeparatedStr + ','
	SET @pos = PATINDEX('%,%' , @CommaSeparatedStr )
	WHILE @pos <> 0 
	BEGIN
		SET @piece = left(@CommaSeparatedStr , @pos - 1)
		-- You have a piece of data, so insert it, print it, do whatever you want to with it.
		INSERT @myTable SELECT @piece 

		SET @CommaSeparatedStr = stuff(@CommaSeparatedStr , 1, @pos, '')
		SET @pos = patindex('%,%' , @CommaSeparatedStr )
	END
	-- tada, a useless comment to cause change for DB upgrade process testing
	RETURN
END
GO
