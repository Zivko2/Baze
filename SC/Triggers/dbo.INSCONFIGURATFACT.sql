SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





























CREATE TRIGGER [INSCONFIGURATFACT] ON dbo.TFACTURA
FOR INSERT
AS
BEGIN
	--print 'hola'

	if not exists(select * from configuratfact where tf_codigo in (select tf_codigo from inserted))
	SELECT TFACTURA.TF_CODIGO, ''  from tfactura
	where tf_codigo in (select tf_codigo FROM INSERTED) 
		and tf_codigo is not null


END





























GO
