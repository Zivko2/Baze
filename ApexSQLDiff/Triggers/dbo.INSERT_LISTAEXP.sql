SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


















































CREATE TRIGGER dbo.[INSERT_LISTAEXP] ON dbo.LISTAEXP 
FOR INSERT
AS
SET NOCOUNT ON 


	UPDATE LISTAEXP
	SET LE_FOLIO=UPPER(RTRIM(LE_FOLIO))
	WHERE LE_CODIGO IN (SELECT LE_CODIGO FROM INSERTED)



































































GO
