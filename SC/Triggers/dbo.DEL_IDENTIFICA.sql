SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

























CREATE TRIGGER [DEL_IDENTIFICA] ON dbo.IDENTIFICA 
FOR DELETE 
AS

	IF EXISTS (SELECT * FROM IDENTIFICADET WHERE IDE_CODIGO IN (SELECT IDE_CODIGO FROM DELETED))

	DELETE FROM IDENTIFICADET WHERE IDE_CODIGO IN
	(SELECT IDE_CODIGO FROM DELETED)

























GO