SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [DEL_PAIS] ON dbo.PAIS 
FOR DELETE 
AS

	if not exists (select * from paisdel where pa_codigo in (select pa_codigo from deleted))
	INSERT INTO PAISDEL(PA_CODIGO, PA_CORTO)
	SELECT PA_CODIGO, PA_CORTO FROM DELETED








































GO
