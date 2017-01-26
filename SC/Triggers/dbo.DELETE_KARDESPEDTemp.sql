SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




































CREATE TRIGGER [DELETE_KARDESPEDTemp] ON dbo.KARDESPEDtemp 
FOR DELETE 
AS
SET NOCOUNT ON
declare @consecutivo int

	SELECT @consecutivo = isnull(MAX(KAP_CODIGO),0)+1 FROM KARDESPED 

	if not exists (select * from kardespedtemp where kap_codigo >@consecutivo)
	dbcc checkident (kardespedtemp, reseed, @consecutivo) WITH NO_INFOMSGS




































GO
