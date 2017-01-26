SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

































CREATE TRIGGER DEL_ENTRYSUM ON dbo.ENTRYSUM  FOR DELETE AS
declare @et_codigo int, @etc_codigo int

	select @et_codigo=et_codigo, @etc_codigo=etc_codigo from deleted


	--Borrar el EntrySumAra
	if exists (select * from entrysumara where ET_CODIGO IN (SELECT ET_CODIGO FROM DELETED))
	DELETE FROM ENTRYSUMARA WHERE ET_CODIGO IN (SELECT ET_CODIGO FROM DELETED)


	update factexp
	set et_codigo=-1
	where et_codigo =@et_codigo




	update entrycons
	set etc_estatus='A'
	where etc_codigo =@etc_codigo




































GO
