SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE ActualizarZona as
	update zona set zo_desc = b.zo_desc
	from zona
		inner join original.dbo.zona b on zona.zo_codigo = b.zo_codigo
		
	set identity_insert zona on
	insert into zona (zo_codigo, zo_desc, pa_codigo, zo_iva	)
	select * from original.dbo.zona
	where zo_codigo not in (select zo_codigo from zona) 	
	set identity_insert zona off

GO
