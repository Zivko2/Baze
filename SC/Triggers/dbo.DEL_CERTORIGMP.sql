SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO












CREATE TRIGGER [DEL_CERTORIGMP] ON dbo.CERTORIGMP 
FOR DELETE 
AS
	if exists(select * from certorigmpdet where cmp_codigo in (select cmp_codigo from deleted))
	delete from certorigmpdet where cmp_codigo in (select cmp_codigo from deleted)












GO
