SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



/* cursor para todos detalles de la factura a descargar */
CREATE PROCEDURE [dbo].[SP_descargaMain]  (@CodigoFactura int, @MetodoDescarga Varchar(4), @tipodescarga varchar(2), @Concilia char(1)='N', @tipo char(1))    as

SET NOCOUNT ON 
declare @fed_indiced int, @fe_fecha varchar(10), @CF_DESCARGAVENCIDOS char(1), @CF_DESCARGASBUS char(1),
@CF_DESCDESPFAM CHAR(1), @TEmbarque CHAR(1)

declare @fedindiced table (FED_INDICED int)


	select @fe_fecha=convert(varchar(10),fe_fecha,101) from factexp where fe_codigo =@CodigoFactura 

	SELECT     @CF_DESCARGAVENCIDOS=CF_DESCARGAVENCIDOS, @CF_DESCARGASBUS=CF_DESCARGASBUS,		
		@CF_DESCDESPFAM=CF_DESCDESPFAM
	FROM         dbo.CONFIGURACION

	SELECT     @TEmbarque = dbo.CONFIGURATEMBARQUE.CFQ_TIPO
	FROM         dbo.FACTEXP LEFT OUTER JOIN
                      dbo.CONFIGURATEMBARQUE ON dbo.FACTEXP.TQ_CODIGO = dbo.CONFIGURATEMBARQUE.TQ_CODIGO
	GROUP BY dbo.CONFIGURATEMBARQUE.CFQ_TIPO, dbo.FACTEXP.FE_CODIGO, dbo.FACTEXP.FE_TIPO
	HAVING      (dbo.FACTEXP.FE_CODIGO = @CodigoFactura)





	insert into @fedindiced(FED_INDICED)
	SELECT     FED_INDICED
	FROM FACTEXPDET
	WHERE FE_CODIGO=@CodigoFactura
	order by fed_indiced


	declare cur_descargafed cursor for
		SELECT     FED_INDICED
		FROM @fedindiced
		order by fed_indiced
	open cur_descargafed
	
	
		FETCH NEXT FROM cur_descargafed INTO @fed_indiced
	
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN
	
				



			if @CF_DESCDESPFAM='S' and @TEmbarque='D'
			begin
				Exec sp_descargaFam @fed_indiced, @MetodoDescarga, @tipodescarga
			end
			else
			if @CF_DESCARGASBUS='G' 
			begin
				Exec sp_descargaGr @fed_indiced, @MetodoDescarga, @tipodescarga
			end
			else
			begin
				EXEC sp_descarga @fed_indiced, @MetodoDescarga, @tipodescarga, @tipo
			
			end




			if @Concilia<>'S'
			begin

				--actualiza estatus
				exec SP_ESTATUSKARDESPEDFED @fed_indiced, 'P'

				--print 'inicia pendientes'
				if @CF_DESCARGASBUS<>'G' and
				   (SELECT CF_PENDGR FROM  CONFIGURACION)='S' and
				exists(select kap_codigo from vkardespedtempn where  kap_indiced_fact=@fed_indiced)
				begin
			
					--print 'entra a SP_FILL_KARDESPED I'
					if exists (select * from kardespedtemp where kap_indiced_fact=@fed_indiced and kap_estatus='D')
					EXEC SP_FILL_KARDESPED 'I'

					--exec SP_CreaVPIDescargaHijoGr @tipo, @fe_fecha, @fed_indiced		
					exec sp_DescargaPendDetalleGr @fed_indiced, @MetodoDescarga, @tipodescarga


				end


				--actualiza estatus
				exec SP_ESTATUSKARDESPEDFED @fed_indiced, 'P'

				--print 'inicia pendientes'
				if @CF_DESCARGASBUS<>'G' and
				   (SELECT CF_USAEQUIVALENTEGR FROM  CONFIGURACION)='S' and
				exists(select kap_codigo from vkardespedtempn where  kap_indiced_fact=@fed_indiced)
				begin
			
					--print 'entra a SP_FILL_KARDESPED I'
					if exists (select * from kardespedtemp where kap_indiced_fact=@fed_indiced and kap_estatus='D')
					EXEC SP_FILL_KARDESPED 'I'

					--exec SP_CreaVPIDescargaHijoGr @tipo, @fe_fecha, @fed_indiced		
					exec sp_DescargaPendDetalleGrGr @fed_indiced, @MetodoDescarga, @tipodescarga


				end

			end
			--print 'estatus descargados normal'
			exec SP_ESTATUSKARDESPEDFED @fed_indiced
	
			EXEC SP_FILL_KARDESPED				


			update factexpdet
			set fed_descargado ='S' where fed_indiced  = @fed_indiced and fed_descargado ='N'

			delete from bom_desctemp where fed_indiced  = @fed_indiced

		FETCH NEXT FROM cur_descargafed INTO @fed_indiced
	
	END
	
	CLOSE cur_descargafed
	DEALLOCATE cur_descargafed
GO
