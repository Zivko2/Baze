SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

























CREATE TRIGGER [UPDATE_IDENTIFICA] ON dbo.IDENTIFICA 
FOR UPDATE
AS
declare @ide_tipo char(1)

	select @ide_tipo = ide_tipo from inserted

	IF update(ide_tipo) 
	begin
	
		if @ide_tipo<>2 and exists (select * from identificadet where ide_codigo in (select ide_codigo from inserted))
	
		delete from identificadet where ide_codigo in 
		(select ide_codigo from inserted)
		
		if @ide_tipo<>3

		update identifica
		set ide_tabla=0, ide_campo=0, ide_campo2=0
		where ide_codigo in 
		(select ide_codigo from inserted)

	end

























GO
