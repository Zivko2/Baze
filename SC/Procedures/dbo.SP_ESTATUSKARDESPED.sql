SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_ESTATUSKARDESPED] (@kap_codigo int, @tipo char(1)='D')   as

SET NOCOUNT ON 
declare @KAP_Saldo_FED decimal(38,6), @KAP_CantTotADescargar decimal(38,6), @ma_generico int, @kap_factrans int,@kap_fiscomp char(1),
@KAP_TIPO_DESC varchar(2), @KAP_TIPO_DESCb varchar(2), @fed_retrabajo char(1), @fed_indiced int, @terminodescarga char(1), @kap_padremain int,
@KAP_PADRESUST int, @KAP_CANTDESC decimal(38,6)

	DECLARE @KAP_INDICED_FACT INT, @MA_HIJO INT, @SUMKAP_CANTDESC decimal(38,6), --@KAP_CantTotADescargar1 decimal(38,6),
	@CF_USAEQUIVALENTE CHAR(1), @CF_DESCARGASBUS CHAR(1)

	update KARDESPEDTemp
	set KAP_PADRESUST=0
	where KAP_PADRESUST is null
	and kap_codigo=@kap_codigo


	SELECT     @KAP_Saldo_FED = KAP_Saldo_FED, @KAP_CantTotADescargar = round(KAP_CantTotADescargar,6), @KAP_TIPO_DESC =KAP_TIPO_DESC,
		     @kap_fiscomp=KAP_FISCOMP, @KAP_INDICED_FACT =KAP_INDICED_FACT, @MA_HIJO = ma_hijo, @kap_factrans =KAP_FACTRANS,
		     @kap_padremain=kap_padremain, @KAP_PADRESUST=KAP_PADRESUST, @KAP_CANTDESC=KAP_CANTDESC
	from KARDESPEDTemp where kap_codigo= @kap_codigo


	select @fed_retrabajo=fed_retrabajo, @fed_indiced=fed_indiced from factexpdet where fed_indiced =@kap_indiced_fact

	if @KAP_TIPO_DESC='M' or @KAP_TIPO_DESC='MS'
	set @KAP_TIPO_DESCb='M'

	if @KAP_TIPO_DESC='N' or @KAP_TIPO_DESC='NS'
	set @KAP_TIPO_DESCb='N'

	if @KAP_TIPO_DESC='D' or @KAP_TIPO_DESC='DS'
	set @KAP_TIPO_DESCb='D'

/* descarga manual */
	if @KAP_TIPO_DESC='MN'
	set @KAP_TIPO_DESCb='N'

	SELECT     @CF_USAEQUIVALENTE = CF_USAEQUIVALENTE, @CF_DESCARGASBUS = CF_DESCARGASBUS
	FROM         dbo.CONFIGURACION


/* total que se lleva descargado por hijo, unque use o no use equivalentes */	
	if @KAP_PADRESUST=0 or @KAP_PADRESUST is null
	begin
		SELECT @SUMKAP_CANTDESC = round(SUM(KAP_CANTDESC),6)
		FROM dbo.KARDESPEDTemp WHERE (KAP_INDICED_FACT = @KAP_INDICED_FACT) 
		and ((ma_hijo = @MA_HIJO and (KAP_PADRESUST is null or KAP_PADRESUST=0)) or KAP_PADRESUST= @MA_HIJO)
		and (KAP_TIPO_DESC = @KAP_TIPO_DESCb OR KAP_TIPO_DESC = @KAP_TIPO_DESCb+'S')
		and kap_fiscomp='N'

	end
	else
	begin
		SELECT @SUMKAP_CANTDESC = round(SUM(KAP_CANTDESC),6)
		FROM dbo.KARDESPEDTemp WHERE (KAP_INDICED_FACT = @KAP_INDICED_FACT) 
		and ((ma_hijo = @KAP_PADRESUST and (KAP_PADRESUST is null or KAP_PADRESUST=0)) or KAP_PADRESUST= @KAP_PADRESUST)
		and (KAP_TIPO_DESC = @KAP_TIPO_DESCb OR KAP_TIPO_DESC = @KAP_TIPO_DESCb+'S')
		and kap_fiscomp='N'
	end

	if @SUMKAP_CANTDESC is null
	set @SUMKAP_CANTDESC= @KAP_CANTDESC


/* total adescargar por hijo */
	/*if (@KAP_Saldo_FED) is not null and (@KAP_CantTotADescargar) is not null and (@kap_fiscomp='N') and
	not exists (select * from kardespedtemp where KAP_INDICED_FACT =@KAP_INDICED_FACT 
							and (ma_hijo=@ma_hijo and (KAP_PADRESUST=0 or KAP_PADRESUST is null)) 
							and (KAP_TIPO_DESC = @KAP_TIPO_DESCb OR KAP_TIPO_DESC = @KAP_TIPO_DESCb+'S')
							and KAP_ESTATUS='P')
	begin*/
		if @CF_DESCARGASBUS='I'
		begin
	
			IF @CF_USAEQUIVALENTE <>'S'	
			begin

				if @KAP_PADRESUST=0 or @KAP_PADRESUST is null
				begin
					print 'descarga individual - sin equivalentes'
					if @KAP_Saldo_FED = @KAP_CantTotADescargar
					UPDATE KARDESPEDTemp
					SET KAP_ESTATUS='N'
					WHERE KAP_CODIGO =@kap_codigo 
						
					if (@KAP_Saldo_FED < @KAP_CantTotADescargar)
					AND (@KAP_Saldo_FED <> 0) and  (@KAP_Saldo_FED) is not null
					UPDATE KARDESPEDTemp
					SET KAP_ESTATUS='P'
					WHERE KAP_CODIGO =@kap_codigo 
	
					if @KAP_Saldo_FED = 0 or @SUMKAP_CANTDESC=@KAP_CantTotADescargar
					UPDATE KARDESPEDTemp
					SET KAP_ESTATUS='D'
					WHERE MA_HIJO =@MA_HIJO
					AND KAP_INDICED_FACT =@KAP_INDICED_FACT
					and (@KAP_PADRESUST=0 or @KAP_PADRESUST is null) 
					and kap_fiscomp='N'
				end
				else
				begin
						print 'descarga pendientes'
						if @SUMKAP_CANTDESC=0		
						update dbo.KARDESPEDTemp
						set KAP_ESTATUS='N'
						WHERE (KAP_INDICED_FACT = @KAP_INDICED_FACT) 
						and ((ma_hijo = @KAP_PADRESUST and (KAP_PADRESUST is null or KAP_PADRESUST=0)) or KAP_PADRESUST= @KAP_PADRESUST)
						and (KAP_TIPO_DESC = @KAP_TIPO_DESCb OR KAP_TIPO_DESC = @KAP_TIPO_DESCb+'S')	
						
						if @SUMKAP_CANTDESC< @KAP_CantTotADescargar AND @SUMKAP_CANTDESC<>0
						update dbo.KARDESPEDTemp
						set KAP_ESTATUS='P'
						WHERE (KAP_INDICED_FACT = @KAP_INDICED_FACT)  
						and ((ma_hijo = @KAP_PADRESUST and (KAP_PADRESUST is null or KAP_PADRESUST=0)) or KAP_PADRESUST= @KAP_PADRESUST)
						and (KAP_TIPO_DESC = @KAP_TIPO_DESCb OR KAP_TIPO_DESC = @KAP_TIPO_DESCb+'S')


						if @SUMKAP_CANTDESC= @KAP_CantTotADescargar
	 					update dbo.KARDESPEDTemp
						set KAP_ESTATUS='D'
						WHERE (KAP_INDICED_FACT = @KAP_INDICED_FACT) 
						and ((ma_hijo = @KAP_PADRESUST and (KAP_PADRESUST is null or KAP_PADRESUST=0)) or KAP_PADRESUST= @KAP_PADRESUST)
						and (KAP_TIPO_DESC = @KAP_TIPO_DESCb OR KAP_TIPO_DESC = @KAP_TIPO_DESCb+'S')
				end
			end
			else 
			begin
	
				print 'descarga individual - con equivalentes'
				-- padre equivalente antes de haber insertado los componentes
				if (@KAP_PADRESUST is null or @KAP_PADRESUST=0) and not exists
				(select * from KARDESPEDTemp where kap_padresust=@MA_HIJO and KAP_INDICED_FACT =@KAP_INDICED_FACT)
				begin
					
					if @KAP_Saldo_FED = @KAP_CantTotADescargar
					UPDATE KARDESPEDTemp
					SET KAP_ESTATUS='N'
					WHERE KAP_CODIGO =@kap_codigo 
				
					if @KAP_Saldo_FED = 0
					UPDATE KARDESPEDTemp
					SET KAP_ESTATUS='D'
					WHERE KAP_CODIGO =@kap_codigo 

					
					if (@KAP_Saldo_FED < @KAP_CantTotADescargar)
					AND (@KAP_Saldo_FED <> 0) and  (@KAP_Saldo_FED) is not null
					UPDATE KARDESPEDTemp
					SET KAP_ESTATUS='P'
					WHERE KAP_CODIGO =@kap_codigo 
				end
				else
				begin
					print 'componentes descarga individual - equivalentes'
					if exists (select * from KARDESPEDTemp where kap_saldo_fed=0 and KAP_INDICED_FACT =@KAP_INDICED_FACT 
					      and (KAP_PADRESUST=@KAP_PADRESUST or MA_HIJO=@KAP_PADRESUST))
						UPDATE KARDESPEDTemp
						SET KAP_ESTATUS='D'
						where KAP_CODIGO =@kap_codigo and KAP_INDICED_FACT =@KAP_INDICED_FACT 
						and (ma_hijo =@kap_padresust or kap_padresust=@kap_padresust) 
						and (KAP_TIPO_DESC = @KAP_TIPO_DESCb OR KAP_TIPO_DESC = @KAP_TIPO_DESCb+'S')
					else
					begin	
						UPDATE KARDESPEDTemp
						SET KAP_ESTATUS='P'
						where KAP_CODIGO =@kap_codigo and KAP_INDICED_FACT =@KAP_INDICED_FACT 
						and (KAP_PADRESUST=@kap_padresust)			
						and (KAP_TIPO_DESC = @KAP_TIPO_DESCb OR KAP_TIPO_DESC = @KAP_TIPO_DESCb+'S')
						and KAP_Saldo_FED < KAP_CantTotADescargar and kap_saldo_fed>0
					end
				end

				-- Padre equivalente, despues de haber insertado los componentes
				if exists (SELECT * FROM KARDESPEDTemp WHERE (KAP_CODIGO IN
				                          (SELECT     MAX(KAP_CODIGO) AS kap_codigo
				                            FROM          KARDESPEDTemp
				                            GROUP BY MA_HIJO, KAP_INDICED_FACT, KAP_PADRESUST
				                            HAVING      (KAP_INDICED_FACT = @KAP_INDICED_FACT) AND (KAP_PADRESUST = @kap_padresust))) AND (KAP_Saldo_FED= 0))

					UPDATE KARDESPEDTemp
					SET KAP_ESTATUS='D'
					WHERE MA_HIJO =@kap_padresust
					AND KAP_INDICED_FACT =@KAP_INDICED_FACT
					AND (KAP_PADRESUST=0 OR KAP_PADRESUST IS NULL)
				else 
					if exists (select * from KARDESPEDTemp where (KAP_INDICED_FACT = @KAP_INDICED_FACT) AND (KAP_PADRESUST = @kap_padresust)
						and kap_cantdesc >0)
					begin
						UPDATE KARDESPEDTemp
						SET KAP_ESTATUS='P'
						WHERE MA_HIJO =@kap_padresust
						AND KAP_INDICED_FACT =@KAP_INDICED_FACT
						AND (KAP_PADRESUST=0 OR KAP_PADRESUST IS NULL)
					end
					else
					begin
						UPDATE KARDESPEDTemp
						SET KAP_ESTATUS='N'
						WHERE MA_HIJO =@kap_padresust
						AND KAP_INDICED_FACT =@KAP_INDICED_FACT
						AND (KAP_PADRESUST=0 OR KAP_PADRESUST IS NULL)
					end
			end
			
		end
		else
		begin
			-- descarga = busqueda por grupo generico
				--print 'descarga generica'
			
			if exists (select * from KARDESPEDTemp where kap_saldo_fed=0 and KAP_INDICED_FACT =@KAP_INDICED_FACT 
					      and (KAP_PADRESUST=@KAP_PADRESUST))
				begin
					UPDATE KARDESPEDTemp
					SET KAP_ESTATUS='D'
					where KAP_INDICED_FACT =@KAP_INDICED_FACT 
					and (KAP_PADRESUST=@KAP_PADRESUST)
					and (KAP_TIPO_DESC = @KAP_TIPO_DESCb OR KAP_TIPO_DESC = @KAP_TIPO_DESCb+'S')
				end
				else
					if exists (select * from KARDESPEDTemp where kap_saldo_fed>0 and KAP_INDICED_FACT =@KAP_INDICED_FACT 
					      and (KAP_PADRESUST=@KAP_PADRESUST))
					and 
					exists (select * from KARDESPEDTemp where KAP_CANTDESC>0 and KAP_INDICED_FACT =@KAP_INDICED_FACT 
					      and  (KAP_PADRESUST=@KAP_PADRESUST))
					
						UPDATE KARDESPEDTemp
						SET KAP_ESTATUS='P'
						where  KAP_INDICED_FACT =@KAP_INDICED_FACT 
						and (KAP_PADRESUST=@KAP_PADRESUST)			
						and (KAP_TIPO_DESC = @KAP_TIPO_DESCb OR KAP_TIPO_DESC = @KAP_TIPO_DESCb+'S')
					else
						UPDATE KARDESPEDTemp
						SET KAP_ESTATUS='N'
						where KAP_INDICED_FACT =@KAP_INDICED_FACT 
						and (KAP_PADRESUST=@KAP_PADRESUST)		
						and (KAP_TIPO_DESC = @KAP_TIPO_DESCb OR KAP_TIPO_DESC = @KAP_TIPO_DESCb+'S')

		end
	/*end
	else
	begin
			-- tipo de descarga fisico -comprado 
			if @kap_fiscomp <>'X'
			begin

				if @kap_padremain is null or @kap_padremain=0
				begin
					-- padre antes de haber insertado los componentes
					if @KAP_PADRESUST is null or @KAP_PADRESUST=0
					begin
						if @KAP_Saldo_FED = @KAP_CantTotADescargar
						UPDATE KARDESPEDTemp
						SET KAP_ESTATUS='N'
						WHERE KAP_CODIGO =@kap_codigo 
					
						if @KAP_Saldo_FED = 0
						begin
							UPDATE KARDESPEDTemp
							SET KAP_ESTATUS='D'
							WHERE KAP_CODIGO =@kap_codigo 

							-- si la descarga fue todo como comprado, para que actualice los que quedaron parciales
							UPDATE KARDESPEDTemp
							SET KAP_ESTATUS='D'
							where KAP_INDICED_FACT =@KAP_INDICED_FACT 
							and (ma_hijo=@ma_hijo and (KAP_PADRESUST=0 or KAP_PADRESUST is null)) 
							and (KAP_TIPO_DESC = @KAP_TIPO_DESCb OR KAP_TIPO_DESC = @KAP_TIPO_DESCb+'S')
							and KAP_ESTATUS='P'


						end
						
						if (@KAP_Saldo_FED < @KAP_CantTotADescargar)
						AND (@KAP_Saldo_FED <> 0) and  (@KAP_Saldo_FED) is not null
						UPDATE KARDESPEDTemp
						SET KAP_ESTATUS='P'
						WHERE KAP_CODIGO =@kap_codigo 
					end
					else
					begin
						--componentes 'descarga individual - fisico -comprado'
	
							UPDATE KARDESPEDTemp
							SET KAP_ESTATUS='D'
							where kap_fiscomp='S' and KAP_INDICED_FACT =@KAP_INDICED_FACT 
							and ((ma_hijo=@ma_hijo and (KAP_PADRESUST>0 and KAP_PADRESUST is not null)) or KAP_PADRESUST=@kap_padresust)
							and kap_saldo_fed=0
							and (KAP_TIPO_DESC = @KAP_TIPO_DESCb OR KAP_TIPO_DESC = @KAP_TIPO_DESCb+'S')
	
							UPDATE KARDESPEDTemp
							SET KAP_ESTATUS='P'
							where kap_fiscomp='S' and KAP_INDICED_FACT =@KAP_INDICED_FACT 
							and ((ma_hijo=@ma_hijo and (KAP_PADRESUST>0 and KAP_PADRESUST is not null)) or KAP_PADRESUST=@kap_padresust)
							and (KAP_TIPO_DESC = @KAP_TIPO_DESCb OR KAP_TIPO_DESC = @KAP_TIPO_DESCb+'S')
							and KAP_Saldo_FED < KAP_CantTotADescargar and kap_saldo_fed>0
	
							UPDATE KARDESPEDTemp
							SET KAP_ESTATUS='N'
							where kap_fiscomp='S' and KAP_INDICED_FACT =@KAP_INDICED_FACT 
							and ((ma_hijo=@ma_hijo and (KAP_PADRESUST>0 and KAP_PADRESUST is not null)) or KAP_PADRESUST=@kap_padresust)
							and (KAP_TIPO_DESC = @KAP_TIPO_DESCb OR KAP_TIPO_DESC = @KAP_TIPO_DESCb+'S')
							and KAP_Saldo_FED = KAP_CantTotADescargar
					end
	
				end
				else
				begin
--					print 'los componentes se descargan por equivalentes o x grupo'
					if exists (select * from KARDESPEDTemp where kap_saldo_fed=0 and KAP_INDICED_FACT =@KAP_INDICED_FACT 
					      and kap_fiscomp='S' and (kap_padremain=@kap_padremain) and kap_padresust=@kap_padresust)
					begin
						UPDATE KARDESPEDTemp
						SET KAP_ESTATUS='D'
						where kap_fiscomp='S' and KAP_INDICED_FACT =@KAP_INDICED_FACT 
						and (ma_hijo=@kap_padremain or kap_padremain=@kap_padremain) and (kap_padresust=@kap_padresust) 
						and (KAP_TIPO_DESC = @KAP_TIPO_DESCb OR KAP_TIPO_DESC = @KAP_TIPO_DESCb+'S')
					end
					else
					begin

						if exists (select * from KARDESPEDTemp where kap_saldo_fed>0 and KAP_INDICED_FACT =@KAP_INDICED_FACT 
						      and kap_fiscomp='S' and (kap_padremain=@kap_padremain and isnull(kap_padresust,0)=@kap_padresust))
						begin
							if exists (select * from KARDESPEDTemp where KAP_CANTDESC>0 and KAP_INDICED_FACT =@KAP_INDICED_FACT 
							      and kap_fiscomp='S' and (kap_padremain=@kap_padremain and kap_padresust=@kap_padresust))
							begin

								UPDATE KARDESPEDTemp
								SET KAP_ESTATUS='P'
								where kap_fiscomp='S' and KAP_INDICED_FACT =@KAP_INDICED_FACT and (ma_hijo=@kap_padremain or kap_padremain=@kap_padremain)			
								and kap_padresust=@kap_padresust
								and (KAP_TIPO_DESC = @KAP_TIPO_DESCb OR KAP_TIPO_DESC = @KAP_TIPO_DESCb+'S')
							end
							else
							begin

								UPDATE KARDESPEDTemp
								SET KAP_ESTATUS='N'
								where kap_fiscomp='S' and KAP_INDICED_FACT =@KAP_INDICED_FACT 
								and (ma_hijo=@kap_padremain or kap_padremain=@kap_padremain)		
								and kap_padresust=@kap_padresust
								and (KAP_TIPO_DESC = @KAP_TIPO_DESCb OR KAP_TIPO_DESC = @KAP_TIPO_DESCb+'S')	
							end
						end

					end

				end			


				-- Padre, despues de haber insertado los componentes

				-- los registros hijos que se descargan equivalentes de los componentes
				if not exists (SELECT * FROM KARDESPEDTemp WHERE (KAP_CODIGO IN
				                          (SELECT     MAX(KAP_CODIGO) AS kap_codigo
				                            FROM          KARDESPEDTemp
				                            GROUP BY KAP_PADREMAIN, KAP_INDICED_FACT, KAP_PADRESUST
				                            HAVING      (KAP_PADREMAIN IS NOT NULL AND KAP_PADREMAIN<>0) AND (KAP_INDICED_FACT = @KAP_INDICED_FACT) AND (KAP_PADRESUST = @kap_padresust))) AND (KAP_Saldo_FED > 0))
				-- los registros hijos que se descargan directamente del bom del fisico comprado no como equivalentes
				and not exists (SELECT * FROM KARDESPEDTemp WHERE (KAP_CODIGO IN
				                          (SELECT     MAX(KAP_CODIGO) AS kap_codigo
				                            FROM          KARDESPEDTemp
						 WHERE (KAP_PADREMAIN IS NULL OR KAP_PADREMAIN=0) 
				                            GROUP BY MA_HIJO, KAP_INDICED_FACT, KAP_PADRESUST
				                            HAVING      (KAP_INDICED_FACT = @KAP_INDICED_FACT) AND (KAP_PADRESUST = @kap_padresust))) AND (KAP_Saldo_FED > 0))

					UPDATE KARDESPEDTemp
					SET KAP_ESTATUS='D'
					WHERE MA_HIJO =@kap_padresust
					AND KAP_INDICED_FACT =@KAP_INDICED_FACT
					AND kap_fiscomp='S' and (KAP_PADRESUST=0 OR KAP_PADRESUST IS NULL)
				else 
					if exists (select * from KARDESPEDTemp where (KAP_INDICED_FACT = @KAP_INDICED_FACT) AND (KAP_PADRESUST = @kap_padresust)
						and kap_cantdesc >0)
					begin
						UPDATE KARDESPEDTemp
						SET KAP_ESTATUS='P'
						WHERE MA_HIJO =@kap_padresust
						AND KAP_INDICED_FACT =@KAP_INDICED_FACT
						AND kap_fiscomp='S' and (KAP_PADRESUST=0 OR KAP_PADRESUST IS NULL)
					end
					else
					begin
						UPDATE KARDESPEDTemp
						SET KAP_ESTATUS='N'
						WHERE MA_HIJO =@kap_padresust
						AND KAP_INDICED_FACT =@KAP_INDICED_FACT
						AND kap_fiscomp='S' and (KAP_PADRESUST=0 OR KAP_PADRESUST IS NULL)
					end


			end
			else
			begin		

				if @kap_padremain is null or @kap_padremain=0
				begin
					if @KAP_Saldo_FED = @KAP_CantTotADescargar
					UPDATE KARDESPEDTemp
					SET KAP_ESTATUS='N'
					WHERE KAP_CODIGO =@kap_codigo 
	
				
					if @KAP_Saldo_FED = 0
					UPDATE KARDESPEDTemp
					SET KAP_ESTATUS='D'
					WHERE KAP_CODIGO =@kap_codigo 
	
				
					if (@KAP_Saldo_FED < @KAP_CantTotADescargar)
					AND (@KAP_Saldo_FED <> 0) and  (@KAP_Saldo_FED) is not null
					UPDATE KARDESPEDTemp
					SET KAP_ESTATUS='P'
					WHERE KAP_CODIGO =@kap_codigo 
				end
				else
				begin
--				print 'descarga individual - equivalentes - subensambles'

					if not exists (select * from KARDESPEDTemp where kap_saldo_fed>0 and KAP_INDICED_FACT =@KAP_INDICED_FACT 
					      and kap_fiscomp='X' and ( kap_padremain=@ma_hijo))
					begin
						UPDATE KARDESPEDTemp
						SET KAP_ESTATUS='D'
						where kap_fiscomp='X' and KAP_INDICED_FACT =@KAP_INDICED_FACT 
						and (ma_hijo=@ma_hijo or kap_padremain=@ma_hijo) and kap_saldo_fed=0
						and (KAP_TIPO_DESC = @KAP_TIPO_DESCb OR KAP_TIPO_DESC = @KAP_TIPO_DESCb+'S')
					end
					else
					begin
						if exists (select * from KARDESPEDTemp where kap_saldo_fed>0 and KAP_INDICED_FACT =@KAP_INDICED_FACT 
						      and kap_fiscomp='X' and ( kap_padremain=@ma_hijo) and KAP_PADRESUST>0)
						and 
						exists (select * from KARDESPEDTemp where KAP_CANTDESC>0 and KAP_INDICED_FACT =@KAP_INDICED_FACT 
						      and kap_fiscomp='X' and ( kap_padremain=@ma_hijo))
						begin
							UPDATE KARDESPEDTemp
							SET KAP_ESTATUS='P'
							where kap_fiscomp='X' and KAP_INDICED_FACT =@KAP_INDICED_FACT and (ma_hijo=@ma_hijo or kap_padremain=@ma_hijo)			
							and (KAP_TIPO_DESC = @KAP_TIPO_DESCb OR KAP_TIPO_DESC = @KAP_TIPO_DESCb+'S')
						end
						else
						begin
							UPDATE KARDESPEDTemp
							SET KAP_ESTATUS='N'
							where kap_fiscomp='X' and KAP_INDICED_FACT =@KAP_INDICED_FACT 
							and (ma_hijo=@ma_hijo or kap_padremain=@ma_hijo)		
							and (KAP_TIPO_DESC = @KAP_TIPO_DESCb OR KAP_TIPO_DESC = @KAP_TIPO_DESCb+'S')	
						end
					end

				end
			end
	end*/



GO
