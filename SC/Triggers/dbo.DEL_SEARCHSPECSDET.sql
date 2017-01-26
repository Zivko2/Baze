SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


























CREATE TRIGGER [DEL_SEARCHSPECSDET] ON dbo.SEARCHSPECSDET 
FOR  DELETE 
AS

	if exists(select * from searchspecsitem where ssd_codigo in (select ssd_codigo from deleted))
	delete from searchspecsitem where ssd_codigo in (select ssd_codigo from deleted)




























GO
