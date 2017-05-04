SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- Alter Procedure GetTransferFileText
CREATE PROCEDURE [Finance].[GetTransferFileText] @SubmittedFileName1 nvarchar(100)
AS
BEGIN

	set nocount on;
	select TransferSetExport from FinancialTransferSet where SubmittedFileName = @SubmittedFileName1
		 
END
GO
