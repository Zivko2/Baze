SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO































CREATE TRIGGER [DEL_MEDIDA] ON dbo.MEDIDA 
FOR DELETE 
AS

	if not exists (select * from medidadel where me_codigo in (select me_codigo from deleted))
	insert into medidadel(me_codigo, me_corto)
	select me_codigo, me_corto from deleted































GO
