SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Finance].[ConfirmTransferSetSubmission]
AS
BEGIN
	
	set nocount on;
	
	select CompanyIdentificationCodeForFinance + '-' + CONVERT(varchar(8), SetEndDate, 112) + BaseCurrency + '.txt'
	from  GlobalSetting, FinancialTransferSet
	where SubmittedFileName is null and SubmittedOn is not null

	update fts set SubmittedFileName = gs.CompanyIdentificationCodeForFinance + '-' + CONVERT(varchar(8), SetEndDate, 112) + BaseCurrency + '.txt'
	from FinancialTransferSet fts, GlobalSetting gs
	where SubmittedFileName is null and SubmittedOn is not null
		 
END
GO
