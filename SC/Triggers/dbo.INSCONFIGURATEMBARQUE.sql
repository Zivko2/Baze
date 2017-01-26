SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO































CREATE TRIGGER [INSCONFIGURATEMBARQUE] ON dbo.TEMBARQUE
FOR INSERT
AS
BEGIN
	if not exists(select * from configuratembarque where tq_codigo in (select tq_codigo from inserted))
	INSERT INTO CONFIGURATEMBARQUE (TQ_CODIGO, CFQ_TIPO)
	SELECT TEMBARQUE.TQ_CODIGO, ''  from tembarque
	where tq_codigo in (select tq_codigo FROM INSERTED) and tq_codigo is not null
END































GO
