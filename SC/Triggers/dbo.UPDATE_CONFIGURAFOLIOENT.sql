SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [UPDATE_CONFIGURAFOLIOENT] ON [dbo].[CONFIGURAFOLIOENT] 
FOR  UPDATE
AS
declare @cfe_tipo varchar(2), @tf_codigo int, @cfe_prefijo varchar(5), @cfe_contador int, @cfe_entsal varchar(1)

select @cfe_tipo = cfe_tipo, @tf_codigo = tf_codigo, @cfe_prefijo = cfe_prefijo, @cfe_contador = cfe_contador, @cfe_entsal = cfe_entsal
from inserted

if @cfe_prefijo = 'REM' and @cfe_entsal = 'S' and (select cf_servicios from configuracion) = 'S'
begin
   if @cfe_tipo = 'V' 
   begin
	
	       	update configurafolioent
	       	set cfe_contador = @cfe_contador 
	   	where (cfe_tipo = 'F' and tf_codigo = 29 and cfe_prefijo = 'REM')
		   --OR (cfe_tipo = 'F' and tf_codigo = 36 and cfe_prefijo = 'REM')
	
	       	update configurafolioent
	       	set cfe_contador = @cfe_contador 
	   	where (cfe_tipo = 'F' and tf_codigo = 36 and cfe_prefijo = 'REM')


	--print '1'
   end
   ELSE
   if @cfe_tipo = 'F'  and  @tf_codigo = 29
   begin
	
	       	update configurafolioent
		set cfe_contador = @cfe_contador 
		where (cfe_tipo = 'V' and tf_codigo = 12 and cfe_prefijo = 'REM')
		   --OR (cfe_tipo = 'F' and tf_codigo = 36 and cfe_prefijo = 'REM')

	       	update configurafolioent
		set cfe_contador = @cfe_contador 
		where (cfe_tipo = 'F' and tf_codigo = 36 and cfe_prefijo = 'REM')

	
	--print '2'
   end
   else
   	if @cfe_tipo = 'F'  and  @tf_codigo = 36
	begin
		
		    	update configurafolioent
			set cfe_contador = @cfe_contador 
			where (cfe_tipo = 'V' and tf_codigo = 12 and cfe_prefijo = 'REM')
			   --OR (cfe_tipo = 'F' and tf_codigo = 29 and cfe_prefijo = 'REM')
		

		    	update configurafolioent
			set cfe_contador = @cfe_contador 
			where (cfe_tipo = 'F' and tf_codigo = 29 and cfe_prefijo = 'REM')

		--print '3'
	end

end

GO
