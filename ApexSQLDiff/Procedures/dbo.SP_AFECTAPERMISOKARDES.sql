SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE [dbo].[SP_AFECTAPERMISOKARDES] (@KAP_CODIGO int, @FE_CODIGO int, @CPE_CODIGO int, @PA_CODIGO int, @FED_COS_TOT decimal(38,6), @Cantidad decimal(38,6))   as

declare @QtyADescargar decimal(38,6), @RestaDescargar decimal(38,6), @pe_codigo int, @ped_indiced int, @ped_saldo decimal(38,6), @ped_saldocostot decimal(38,6),
@consecutivo int, @fe_fecha datetime, @cfm_paishijo char(1), @me_codigo int, @kar_cantdesc decimal(38,6),
@cfr_saldo char(1), @cfr_saldocaratula char(1)



	select @fe_fecha=fe_fecha from factexp where fe_codigo=@fe_codigo



	-- esta seccion es para el registro que ya esta capturado en la tabla de factimpperm
	set @RestaDescargar=round(@Cantidad ,6)


	if @RestaDescargar >0 
	begin
		declare cur_Saldo cursor for
			select distinct permisodet.pe_codigo, ped_indiced, 'ped_saldo'=case when CFR_SALDO='S' then ped_saldo else pe_saldo end,
			     cfm_paishijo, me_com, CFR_SALDO
			from permisodet inner join permiso on permisodet.pe_codigo = permiso.pe_codigo left outer join
				configurapermiso on permiso.ide_codigo = configurapermiso.ide_codigo left outer join
				configurapermisorel on permiso.ide_codigo = configurapermisorel.ide_codigo
			where permisodet.pe_codigo > 0
				and ma_generico =@CPE_CODIGO 
				and ((CFR_SALDO='S' and ped_saldo>0) or (CFR_SALDOCARATULA='S' and pe_saldo>0))
				and permiso.pe_aprobado = 'S'
				--and (pe_fechavenc is null or pe_fechavenc<=@fe_fecha)
				--Yolanda Avila (2009-07-02)
				and (pe_fechavenc is null or pe_fechavenc>=@fe_fecha) and pe_fecha<=@fe_fecha 
				and permiso.pe_estatus='A'
			order by permisodet.pe_codigo desc
		open cur_Saldo
			FETCH NEXT FROM cur_Saldo INTO @pe_codigo, @ped_indiced, @ped_saldo, @cfm_paishijo, @me_codigo, @CFR_SALDO
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN
		
				if (@cfm_paishijo ='S' and @PA_CODIGO in 
				(select pa_codigo from permisopais where pe_codigo=@pe_codigo)) or
				@cfm_paishijo <>'S'
				begin

				--print @RestaDescargar

					if @RestaDescargar>0
					begin

	
						if @ped_saldo >=@RestaDescargar 
						begin
							SET @QtyADescargar = round(@RestaDescargar,6)   
							SET @RestaDescargar = 0
		
							--print round(round(@ped_saldo,6) - round(@QtyADescargar,6),6)
							--print @ped_indiced

							if @CFR_SALDO='S'
							begin
								update permisodet
								set ped_saldo= round(round(@ped_saldo,6) - round(@QtyADescargar,6),6), PED_ENUSO='S'
								where ped_indiced=@ped_indiced

								update permiso
								set pe_saldo= round(round(@ped_saldo,6) - round(@QtyADescargar,6),6), PE_ENUSO='S'
								where pe_codigo=@pe_codigo

							end
							else
								update permiso
								set pe_saldo= round(round(@ped_saldo,6) - round(@QtyADescargar,6),6), PE_ENUSO='S'
								where pe_codigo=@pe_codigo

						end
						else
						begin 					
							SET @QtyADescargar =  round(@ped_saldo,6) 
							SET @RestaDescargar = round(@RestaDescargar-@ped_saldo,6)

							if @CFR_SALDO='S'		
							begin
								update permisodet
								set ped_saldo= 0, PED_ENUSO='S'
								where ped_indiced=@ped_indiced

								update permiso
								set pe_saldo= 0, PE_ENUSO='S'
								where pe_codigo=@pe_codigo

							end
							else
							begin
								update permiso
								set pe_saldo= 0, PE_ENUSO='S'
								where pe_codigo=@pe_codigo
							end
						end
			
		
		
						if @QtyADescargar >0 
						begin
							if not exists(select * from kardespermiso where fir_codigo=@CONSECUTIVO and kar_tipo='C' and ped_indiced=@ped_indiced and KAR_FACTIMP='N')
							insert into kardespermiso (fir_codigo, fid_indiced, fi_codigo, ped_indiced, kar_cantdesc, kar_cantTotADescargar, kar_saldo_Fid, kar_tipo, me_categoria, KAR_FACTIMP)
							values(-1, @KAP_CODIGO, @fe_codigo, @ped_indiced, @QtyADescargar, @Cantidad, @RestaDescargar, 'C', @me_codigo, 'N') 


						end
			
					end

				end
		
			FETCH NEXT FROM cur_Saldo INTO @pe_codigo, @ped_indiced, @ped_saldo, @cfm_paishijo, @me_codigo, @CFR_SALDO
		
		END
		
		CLOSE cur_Saldo
		DEALLOCATE cur_Saldo



	end




-- afecta valores

	set @RestaDescargar=round(@FED_COS_TOT,6)

	declare cur_SaldoValor cursor for		
		select distinct permisodet.pe_codigo, ped_indiced, 'ped_saldocostot'=case when CFR_SALDO='S' then ped_saldocostot else pe_saldocostot end, 
			cfm_paishijo, me_com, CFR_SALDO
		from permisodet inner join permiso on permisodet.pe_codigo = permiso.pe_codigo left outer join
			configurapermiso on permiso.ide_codigo = configurapermiso.ide_codigo left outer join
			configurapermisorel on permiso.ide_codigo = configurapermisorel.ide_codigo
		where permisodet.pe_codigo > 0
			and ma_generico =@CPE_CODIGO 
			and ((CFR_SALDO='S' and ped_saldocostot>0) or (CFR_SALDOCARATULA='S' and pe_saldocostot>0))
			and permiso.pe_aprobado = 'S'
			--and (pe_fechavenc is null or pe_fechavenc<=@fe_fecha)
			--Yolanda Avila (2009-07-02)
			and (pe_fechavenc is null or pe_fechavenc>=@fe_fecha) and pe_fecha<=@fe_fecha 
			and permiso.pe_estatus='A'
		order by permisodet.pe_codigo desc
	open cur_SaldoValor
		FETCH NEXT FROM cur_SaldoValor INTO @pe_codigo, @ped_indiced, @ped_saldocostot, @cfm_paishijo, @me_codigo, @CFR_SALDO
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN
	

			if (@cfm_paishijo ='S' and @PA_CODIGO in 
			(select pa_codigo from permisopais where pe_codigo=@pe_codigo)) or
			@cfm_paishijo <>'S'
			begin

	
				if @RestaDescargar>0
				begin
	
					if @ped_saldocostot >=@RestaDescargar 
					begin
						SET @QtyADescargar = round(@RestaDescargar,6)   
						SET @RestaDescargar = 0
	
						if @CFR_SALDO='S'
						begin
							update permisodet
							set ped_saldocostot= round(round(@ped_saldocostot,6) - round(@QtyADescargar,6),6),
							ped_enusocostot='S'
							where ped_indiced=@ped_indiced

							update permiso
							set pe_saldocostot= round(round(@ped_saldocostot,6) - round(@QtyADescargar,6),6),
							pe_enusocostot='S'
							where pe_codigo=@pe_codigo

						end
						else

							update permiso
							set pe_saldocostot= round(round(@ped_saldocostot,6) - round(@QtyADescargar,6),6),
							pe_enusocostot='S'
							where pe_codigo=@pe_codigo
	
					end
					else
					begin
						SET @QtyADescargar =  round(@ped_saldocostot,6) 
						SET @RestaDescargar = round(@RestaDescargar-@ped_saldocostot,6)

						if @CFR_SALDO='S'	
						begin
							update permisodet
							set ped_saldocostot= 0,
							ped_enusocostot='S'
							where ped_indiced=@ped_indiced

							update permiso
							set pe_saldocostot= 0, 
							pe_enusocostot='S'
							where pe_codigo=@pe_codigo

						end
						else
							update permiso
							set pe_saldocostot= 0, 
							pe_enusocostot='S'
							where pe_codigo=@pe_codigo
		
					end


					if @QtyADescargar >0 
					begin
						if not exists(select * from kardespermiso where fir_codigo=@CONSECUTIVO and kar_tipo='V' and ped_indiced=@ped_indiced and KAR_FACTIMP='N')
						insert into kardespermiso (fir_codigo, fid_indiced, fi_codigo, ped_indiced, kar_cantdesc, kar_cantTotADescargar, kar_saldo_Fid, kar_tipo, me_categoria, KAR_FACTIMP)
						values(-1, @KAP_CODIGO, @fe_codigo, @ped_indiced, @QtyADescargar, @FED_COS_TOT, @RestaDescargar, 'V', @me_codigo, 'N') 

					end

		
				end
			end
		
		FETCH NEXT FROM cur_SaldoValor INTO @pe_codigo, @ped_indiced, @ped_saldocostot, @cfm_paishijo, @me_codigo, @CFR_SALDO
	
	END
	
	CLOSE cur_SaldoValor
	DEALLOCATE cur_SaldoValor



	UPDATE KARDESPEDPPS
	SET     KAP_SALDOAFECTADO='S'
	WHERE KAP_CODIGO=@KAP_CODIGO
	AND KAP_CODIGO NOT IN (SELECT fid_indiced FROM KARDESPERMISO WHERE fi_codigo=@fe_codigo AND KAR_FACTIMP='N' AND KAR_Saldo_FID > 0)


	if @KAP_CODIGO IN (SELECT fid_indiced FROM KARDESPERMISO WHERE fi_codigo=@fe_codigo AND KAR_FACTIMP='N' AND KAR_Saldo_FID > 0)
	exec sp_DescargaCancelaPermisoKap @Kap_codigo


	UPDATE PERMISO
	SET PE_ESTATUS='C'
	WHERE PE_SALDO=0 
		AND PE_CODIGO IN 
		(SELECT     PERMISODET.PE_CODIGO
		FROM         KARDESPERMISO INNER JOIN
		                      PERMISODET ON KARDESPERMISO.PED_INDICED = PERMISODET.PED_INDICED
		WHERE  FI_CODIGO=@fe_codigo
		GROUP BY PERMISODET.PE_CODIGO)

	
	
	UPDATE PERMISO
	SET PE_ESTATUS='C'
	WHERE PE_SALDOCOSTOT=0 
		AND PE_CODIGO IN 
		(SELECT     PERMISODET.PE_CODIGO
		FROM         KARDESPERMISO INNER JOIN
		                      PERMISODET ON KARDESPERMISO.PED_INDICED = PERMISODET.PED_INDICED
		WHERE  FI_CODIGO=@fe_codigo
		GROUP BY PERMISODET.PE_CODIGO)


	-- actualiza las tasas que no se encuentran en pps, (Regla Octava)
	UPDATE KARDESPEDPPS
	SET    KARDESPEDPPS.SPI_CODIGO=0,
		KARDESPEDPPS.KAP_DEF_TIP='R', KARDESPEDPPS.KAP_SECIMP=0,
		KARDESPEDPPS.KAP_TASAFINAL= ARANCEL.AR_PORCENT_8VA
	FROM         KARDESPEDPPS INNER JOIN
	                      KARDESPED ON KARDESPEDPPS.KAP_CODIGO = KARDESPED.KAP_CODIGO INNER JOIN
	                      PEDIMPDET ON KARDESPED.KAP_INDICED_PED = PEDIMPDET.PID_INDICED INNER JOIN
	                      ARANCEL ON PEDIMPDET.AR_IMPMX = ARANCEL.AR_CODIGO
	WHERE     (KARDESPED.KAP_CODIGO = @KAP_CODIGO) AND (KARDESPEDPPS.KAP_DEF_TIP = 'R') AND (ARANCEL.AR_PORCENT_8VA <> - 1)
	and KAP_SALDOAFECTADO='S'











GO
