SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





























CREATE TRIGGER [INSCONFIGURATIPO] ON dbo.TIPO
FOR INSERT
AS
BEGIN


	if not exists(select * from configuratipo where ti_codigo in (select ti_codigo from inserted))

	INSERT INTO CONFIGURATIPO (TI_CODIGO, CFT_TIPO, CFT_COSTSUB)
	SELECT TIPO.TI_CODIGO, '', ''  from tipo
	where ti_codigo in (select ti_codigo FROM INSERTED)

END





























GO
