SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


/* cursor para todos detalles de la factura a descargar */
CREATE PROCEDURE [dbo].[SP_descargaMainInv]  (@CodigoFactura int, @MetodoDescarga Varchar(4), @tipodescarga varchar(2))   as

SET NOCOUNT ON 
declare @fed_indiced int, @fe_fecha varchar(10), @CF_DESCARGAVENCIDOS char(1), @CF_DESCARGASBUS char(1)


	select @fe_fecha=convert(varchar(10),fe_fecha,101) from factexp where fe_codigo =@CodigoFactura 


	if (select fe_cuentadet from factexp where fe_codigo=@CodigoFactura)=1
	begin

		SELECT  @fed_indiced= FED_INDICED FROM FACTEXPDET WHERE FE_CODIGO=@CodigoFactura


		Exec sp_descargaGrInv @fed_indiced, @MetodoDescarga, @tipodescarga


		--print 'estatus descargados normal'
		exec SP_ESTATUSKARDESPEDFED @fed_indiced

		if exists (select * from kardespedtemp where kap_indiced_fact=@fed_indiced)
		EXEC SP_FILL_KARDESPED	

		update factexpdet
		set fed_descargado ='S' where fed_indiced  = @fed_indiced and fed_descargado ='N'
	end
	else
	begin
		exec sp_droptable 'fedindiced'

			SELECT     FED_INDICED
			INTO dbo.FEDINDICED
			FROM FACTEXPDET
			WHERE FE_CODIGO=@CodigoFactura
			order by fed_indiced


		declare cur_descargafed cursor for
			SELECT     FED_INDICED
			FROM FEDINDICED
			order by fed_indiced
		open cur_descargafed
		
		
			FETCH NEXT FROM cur_descargafed INTO @fed_indiced
		
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN
	
				Exec sp_descargaGrInv @fed_indiced, @MetodoDescarga, @tipodescarga

				--print 'estatus descargados normal'
				exec SP_ESTATUSKARDESPEDFED @fed_indiced
		
				if exists (select * from kardespedtemp where kap_indiced_fact=@fed_indiced)
				EXEC SP_FILL_KARDESPED	
	
				update factexpdet
				set fed_descargado ='S' where fed_indiced  = @fed_indiced and fed_descargado ='N'
	
			FETCH NEXT FROM cur_descargafed INTO @fed_indiced
		
		END
		
		CLOSE cur_descargafed
		DEALLOCATE cur_descargafed
	end



























GO
