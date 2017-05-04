SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Finance].[UnsubmitTransferSet] @SubmittedFileName nvarchar(100)
AS
BEGIN
	
	update FinancialTransferSet set SubmittedFileName = null, SubmittedOn = null, SubmittedBy = null, UnsubmittedOn = GetDate() where SubmittedFileName = @SubmittedFileName
		 
END
GO
