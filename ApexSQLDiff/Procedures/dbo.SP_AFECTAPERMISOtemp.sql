SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






















CREATE PROCEDURE [dbo].[SP_AFECTAPERMISOtemp] (@FID_INDICED int, @CPE_CODIGO int, @PA_CODIGO int, @FID_COS_TOT decimal(38,6), @Cantidad decimal(38,6), @PE_CODIGOUso int, @Fir_codigo int) with encryption as
declare @fi_codigo int, @QtyADescargar decimal(38,6), @RestaDescargar decimal(38,6), @pe_codigo int, @ped_indiced int, @ped_saldo decimal(38,6), @ped_saldocostot decimal(38,6), @ar_impmx9802 int,
@consecutivo int, @fi_fecha datetime, @cfm_paishijo char(1), @me_codigo int, @kar_cantdesc decimal(38,6), @ar_impmx int, @ar_fraccion varchar(4), @ma_codigo int, 
@cfr_saldo char(1), @cfr_saldocaratula char(1), @kar_cantdescCost decimal(38,6), @RestaDescargarCost decimal(38,6), @QtyADescargarCost decimal(38,6)


	select @fi_codigo=fi_codigo, @ar_impmx=ar_impmx, @ma_codigo=ma_codigo from factimpdet where fid_indiced=@FID_INDICED

	select @ar_fraccion=left(ar_fraccion,4) from arancel where ar_codigo=@ar_impmx

	set @ar_impmx9802=0

	if @ar_fraccion ='9802'
	set @ar_impmx9802=@ar_impmx


	select @fi_fecha=fi_fecha from factimp where fi_codigo=@fi_codigo



	-- esta seccion es para el registro que ya esta capturado en la tabla de factimpperm
	if @PE_CODIGOUso > 0 and exists (select pe_codigo from permiso where pe_codigo=@PE_CODIGOUso and ide_codigo 
				in (select ConfiguraPermisoRel.ide_codigo from ConfiguraPermisoRel inner join identifica on
		  					ConfiguraPermisoRel.ide_codigo=identifica.ide_codigo where CFR_SALDO='S' or CFR_SALDOCARATULA='S'))

	begin
			-- si ya se habia descargado pero no tenia el estatus correcto
			if exists(select ped_indiced from kardespermiso where fid_indiced=@FID_INDICED and kar_tipo='C')
			begin
	
				select @ped_indiced=ped_indiced from factimpperm where fid_indiced=@FID_INDICED and pe_codigo=@PE_CODIGOUso
	
				select @kar_cantdesc=round(sum(kar_cantdesc),6) from kardespermiso where fid_indiced=@FID_INDICED and kar_tipo='C'
	
				set @Cantidad=round(@Cantidad-isnull(@kar_cantdesc,0),6)
	
			end
	
	
			select @cfr_saldo=cfr_saldo, @cfr_saldocaratula=cfr_saldocaratula from ConfiguraPermisoRel where ide_codigo in
			(select ide_codigo from permiso where pe_codigo=@PE_CODIGOUso)
	
	
			if (exists(select ped_indiced from permisodet where pe_codigo=@PE_CODIGOUso and ma_generico=@CPE_CODIGO and ped_saldo>0) and @cfr_saldo='S')
			or (exists(select ped_indiced from permisodet inner join permiso on permisodet.pe_codigo = permiso.pe_codigo where permisodet.pe_codigo=@PE_CODIGOUso and ma_generico=@CPE_CODIGO and pe_saldo>0) and @cfr_saldocaratula='S')
			begin
				if @cfr_saldo='S'
				select @ped_saldo=ped_saldo, @ped_indiced=ped_indiced, @pe_codigo=pe_codigo, @me_codigo=me_com from permisodet where pe_codigo=@PE_CODIGOUso and ma_generico=@CPE_CODIGO and ped_saldo>0
	
				if @cfr_saldocaratula='S'
				select @ped_saldo=pe_saldo, @ped_indiced=ped_indiced, @pe_codigo=permisodet.pe_codigo, @me_codigo=me_com from permisodet inner join permiso on permisodet.pe_codigo = permiso.pe_codigo
				where permisodet.pe_codigo=@PE_CODIGOUso and ma_generico=@CPE_CODIGO and pe_saldo>0
	
		
				if @ped_saldo < 0
				set @ped_saldo=0
	
				if @ped_saldo>=@Cantidad	
				begin
	   			    set @RestaDescargar=0
	 			    set @QtyADescargar = @Cantidad		
				end
				else
				begin
				    set @RestaDescargar=round(@Cantidad-isnull(@ped_saldo,0),6)
	 			    set @QtyADescargar = @ped_saldo
						
				end
	
	
					if exists(select * from factimpperm where ped_indiced=0 and fid_indiced=@FID_INDICED and pe_codigo=@pe_codigo)
					update factimpperm
					set ped_indiced=@ped_indiced
					where ped_indiced=0 and fid_indiced=@FID_INDICED and pe_codigo=@pe_codigo
	
	
	
					if @cfr_saldo='S' and exists(select ped_saldo from permisodet where ROUND(ped_saldo,6) >= round(@Cantidad,6) and ped_indiced=@ped_indiced)
					update permisodet
					set ped_saldo= ROUND(ROUND(ped_saldo,6) - round(@Cantidad,6),6), PED_ENUSO='S'
					where ped_indiced=@ped_indiced
	
					if @cfr_saldo='S' and exists(select ped_saldo from permisodet where ROUND(ped_saldo,6) < round(@Cantidad,6) and ped_indiced=@ped_indiced)
					update permisodet
					set ped_saldo= 0, PED_ENUSO='S'
					where ped_indiced=@ped_indiced
	
	
					if exists(select pe_saldo from permiso where ROUND(pe_saldo,6) >= round(@Cantidad,6) and pe_codigo=@pe_codigo)
						update permiso
						set pe_saldo= ROUND(ROUND(pe_saldo,6) - round(@Cantidad,6),6), PE_ENUSO='S'
						where pe_codigo=@pe_codigo
	
					else
						update permiso
						set pe_saldo= 0, PE_ENUSO='S'
						where pe_codigo=@pe_codigo
	
	
	--				select @CONSECUTIVO=fir_codigo from factimpperm where  ped_indiced=@ped_indiced and fid_indiced=@FID_INDICED				
	
					if @QtyADescargar >0 
					begin
						if not exists(select * from kardespermiso where fir_codigo=@CONSECUTIVO and kar_tipo='C' and ped_indiced=@ped_indiced)
						insert into kardespermiso (fir_codigo, fid_indiced, fi_codigo, ped_indiced, kar_cantdesc, kar_cantTotADescargar, kar_saldo_Fid, kar_tipo, me_categoria)
						values(@fir_codigo, @fid_indiced, @fi_codigo, @ped_indiced, @QtyADescargar, @Cantidad, @RestaDescargar, 'C', @me_codigo) 
					end
	
	
			end

	end
	else
	set @RestaDescargar=round(@Cantidad ,6)

	-- afecta valores

	if @PE_CODIGOUso > 0 
	begin
		if exists(select ped_indiced from permisodet where pe_codigo=@PE_CODIGOUso and ma_generico=@CPE_CODIGO and ped_saldocostot>0)
		begin

			if @cfr_saldo='S'
			select @ped_saldocostot=ped_saldocostot, @ped_indiced=ped_indiced, @pe_codigo=pe_codigo, @me_codigo=me_com from permisodet where pe_codigo=@PE_CODIGOUso and ma_generico=@CPE_CODIGO and ped_saldocostot>0

			if @cfr_saldocaratula='S'
			select @ped_saldocostot=pe_saldocostot, @ped_indiced=ped_indiced, @pe_codigo=permisodet.pe_codigo, @me_codigo=me_com from permisodet inner join permiso on permisodet.pe_codigo = permiso.pe_codigo
			where permisodet.pe_codigo=@PE_CODIGOUso and ma_generico=@CPE_CODIGO and ped_saldocostot>0



			select @kar_cantdescCost=round(sum(kar_cantdesc),6) from kardespermiso where fid_indiced=@FID_INDICED and kar_tipo='V'

			set @FID_COS_TOT=round(@FID_COS_TOT-isnull(@kar_cantdescCost,0),6)


			if @ped_saldocostot < 0
			set @ped_saldocostot=0


			if @ped_saldocostot>=@FID_COS_TOT	
			begin
				set @RestaDescargarCost=0
				set @QtyADescargarCost = @FID_COS_TOT		
			end
			else
			begin
 				set @QtyADescargarCost = @ped_saldocostot		
			             set @RestaDescargarCost=round(@FID_COS_TOT-@ped_saldocostot,6)
			end

				if exists(select * from factimpperm where ped_indiced=0 and fid_indiced=@FID_INDICED and pe_codigo=@pe_codigo)
				update factimpperm
				set ped_indiced=@ped_indiced
				where ped_indiced=0 and fid_indiced=@FID_INDICED and pe_codigo=@pe_codigo


				if @cfr_saldo='S' and exists(select ped_saldocostot from permisodet where ROUND(ped_saldocostot,6) >= round(@FID_COS_TOT,6) and ped_indiced=@ped_indiced)
				update permisodet
				set ped_saldocostot= ROUND(ROUND(ped_saldocostot,6) - round(@FID_COS_TOT,6),6),
				ped_enusocostot='S'
				where ped_indiced=@ped_indiced

				if @cfr_saldo='S' and exists(select ped_saldocostot from permisodet where ROUND(ped_saldocostot,6) < round(@FID_COS_TOT,6) and ped_indiced=@ped_indiced)
				update permisodet
				set ped_saldocostot= 0,
				ped_enusocostot='S'
				where ped_indiced=@ped_indiced


				if exists(select pe_saldocostot from permiso where ROUND(pe_saldocostot,6) >= round(@FID_COS_TOT,6) and pe_codigo=@pe_codigo)
					update permiso
					set pe_saldocostot= ROUND(ROUND(pe_saldocostot,6) - round(@FID_COS_TOT,6),6),
					pe_enusocostot='S'
					where pe_codigo=@pe_codigo
				else
					update permiso
					set pe_saldocostot= 0, pe_enusocostot='S'
					where pe_codigo=@pe_codigo


				if @QtyADescargarCost >0 
				begin	
					if not exists(select * from kardespermiso where fir_codigo=@CONSECUTIVO and kar_tipo='V' and ped_indiced=@ped_indiced)
					insert into kardespermiso (fir_codigo, fid_indiced, fi_codigo, ped_indiced, kar_cantdesc, kar_cantTotADescargar, kar_saldo_Fid, kar_tipo, me_categoria)
					values(@fir_codigo, @fid_indiced, @fi_codigo, @ped_indiced, @QtyADescargarCost, @FID_COS_TOT, @RestaDescargarCost, 'V', @me_codigo) 
				end

		end

	end
	else
	set @RestaDescargarCost=round(@FID_COS_TOT,6)


	-- descarga el resto
	if @RestaDescargar >0 
	begin

		if @ar_impmx9802 <> 0 
		begin
			declare cur_Saldo cursor for
				select distinct permisodet.pe_codigo, ped_indiced, 'ped_saldo'=case when CFR_SALDO='S' then ped_saldo else pe_saldo end,
				     cfm_paishijo, me_com, CFR_SALDO, ped_saldocostot
				from permisodet inner join permiso on permisodet.pe_codigo = permiso.pe_codigo left outer join
					configurapermiso on permiso.ide_codigo = configurapermiso.ide_codigo left outer join
					configurapermisorel on permiso.ide_codigo = configurapermisorel.ide_codigo
				where permisodet.pe_codigo > 0
					and ma_generico =@CPE_CODIGO 
					and ((CFR_SALDO='S' and ped_saldo>0 and ped_saldocostot>0) or (CFR_SALDOCARATULA='S' and pe_saldo>0 and pe_saldocostot>0))
					and permiso.pe_aprobado = 'S'
					--and (pe_fechavenc is null or pe_fechavenc<=@fi_fecha)
					--Yolanda Avila (2009-07-02)
					and (pe_fechavenc is null or pe_fechavenc>=@fi_fecha) and pe_fecha<=@fi_fecha 

						and permiso.pe_estatus='A'
					and permiso.ar_codigo=@ar_impmx9802
				order by permisodet.pe_codigo desc
		end
		else
		begin
			declare cur_Saldo cursor for
				select distinct permisodet.pe_codigo, ped_indiced, 'ped_saldo'=case when CFR_SALDO='S' then ped_saldo else pe_saldo end,
				     cfm_paishijo, me_com, CFR_SALDO, ped_saldocostot
				from permisodet inner join permiso on permisodet.pe_codigo = permiso.pe_codigo left outer join
					configurapermiso on permiso.ide_codigo = configurapermiso.ide_codigo left outer join
					configurapermisorel on permiso.ide_codigo = configurapermisorel.ide_codigo
				where permisodet.pe_codigo > 0
					and ma_generico =@CPE_CODIGO 
					and ((CFR_SALDO='S' and ped_saldo>0 and ped_saldocostot>0) or (CFR_SALDOCARATULA='S' and pe_saldo>0 and pe_saldocostot>0))
					and permiso.pe_aprobado = 'S'
					--and (pe_fechavenc is null or pe_fechavenc<=@fi_fecha)
					--Yolanda Avila (2009-07-02)
					and (pe_fechavenc is null or pe_fechavenc>=@fi_fecha) and pe_fecha<=@fi_fecha 
					and permiso.pe_estatus='A'
				order by permisodet.pe_codigo desc
		end
		open cur_Saldo
			FETCH NEXT FROM cur_Saldo INTO @pe_codigo, @ped_indiced, @ped_saldo, @cfm_paishijo, @me_codigo, @CFR_SALDO, @ped_saldocostot
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
			
		
		
						if not exists(select * from factimpperm where ped_indiced=@ped_indiced and fid_indiced=@FID_INDICED)
						begin
							 EXEC SP_GETCONSECUTIVO @TIPO='FIR', @VALUE=@CONSECUTIVO OUTPUT
		

							insert into factimpperm (fir_codigo, fid_indiced, fi_codigo, ped_indiced, pe_codigo, FIP_ESTATUSAFECTA)
							values(@consecutivo, @fid_indiced, @fi_codigo, @ped_indiced, @pe_codigo, '1')
						end
						else
						begin
	
							select @CONSECUTIVO=fir_codigo from factimpperm where  ped_indiced=@ped_indiced and fid_indiced=@FID_INDICED				
						end
		
						if @QtyADescargar >0 
						begin
							if not exists(select * from kardespermiso where fir_codigo=@CONSECUTIVO and kar_tipo='C' and ped_indiced=@ped_indiced)
							insert into kardespermiso (fir_codigo, fid_indiced, fi_codigo, ped_indiced, kar_cantdesc, kar_cantTotADescargar, kar_saldo_Fid, kar_tipo, me_categoria)
							values(@CONSECUTIVO, @fid_indiced, @fi_codigo, @ped_indiced, @QtyADescargar, @Cantidad, @RestaDescargar, 'C', @me_codigo) 


						end
			
					end



	

					if @RestaDescargarCost>0
					begin
		
						if @ped_saldocostot >=@RestaDescargarCost 
						begin
							SET @QtyADescargarCost = round(@RestaDescargarCost,6)   
							SET @RestaDescargarCost = 0
		
							if @CFR_SALDO='S'
							begin
								update permisodet
								set ped_saldocostot= round(round(@ped_saldocostot,6) - round(@QtyADescargarCost,6),6),
								ped_enusocostot='S'
								where ped_indiced=@ped_indiced
	
								update permiso
								set pe_saldocostot= round(round(@ped_saldocostot,6) - round(@QtyADescargarCost,6),6),
								pe_enusocostot='S'
								where pe_codigo=@pe_codigo
	
							end
							else
	
								update permiso
								set pe_saldocostot= round(round(@ped_saldocostot,6) - round(@QtyADescargarCost,6),6),
								pe_enusocostot='S'
								where pe_codigo=@pe_codigo
		
						end
						else
						begin
							SET @QtyADescargarCost =  round(@ped_saldocostot,6) 
							SET @RestaDescargarCost = round(@RestaDescargarCost-@ped_saldocostot,6)
	
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
			
						if not exists(select * from factimpperm where ped_indiced=@ped_indiced and fid_indiced=@FID_INDICED)
						begin
							 EXEC SP_GETCONSECUTIVO @TIPO='FIR', @VALUE=@CONSECUTIVO OUTPUT
		
							insert into factimpperm (fir_codigo, fid_indiced, fi_codigo, ped_indiced, pe_codigo, FIP_ESTATUSAFECTA)
							values(@consecutivo, @fid_indiced, @fi_codigo, @ped_indiced, @pe_codigo, '1')
						end
						else
						begin
							select @CONSECUTIVO=fir_codigo from factimpperm where  ped_indiced=@ped_indiced and fid_indiced=@FID_INDICED				
						end
	
	
						if @QtyADescargarCost >0 
						begin
							if not exists(select * from kardespermiso where fir_codigo=@CONSECUTIVO and kar_tipo='V' and ped_indiced=@ped_indiced)
							insert into kardespermiso (fir_codigo, fid_indiced, fi_codigo, ped_indiced, kar_cantdesc, kar_cantTotADescargar, kar_saldo_Fid, kar_tipo, me_categoria)
							values(@CONSECUTIVO, @fid_indiced, @fi_codigo, @ped_indiced, @QtyADescargarCost, @FID_COS_TOT, @RestaDescargarCost, 'V', @me_codigo) 
	
						end
					end	
			
				end
		
			FETCH NEXT FROM cur_Saldo INTO @pe_codigo, @ped_indiced, @ped_saldo, @cfm_paishijo, @me_codigo, @CFR_SALDO
		
		END
		
		CLOSE cur_Saldo
		DEALLOCATE cur_Saldo



	end







	UPDATE FACTIMPPERM
	SET     FIP_ESTATUSAFECTA=1
	WHERE FID_INDICED=@FID_INDICED
	AND FIR_CODIGO IN (SELECT FIR_CODIGO FROM KARDESPERMISO WHERE FID_INDICED=@FID_INDICED)

	UPDATE FACTIMPPERM
	SET     FACTIMPPERM.FIP_ESTATUSAFECTA=2
	FROM         PERMISO INNER JOIN
	                      FACTIMPPERM ON PERMISO.PE_CODIGO = FACTIMPPERM.PE_CODIGO INNER JOIN
	                      CONFIGURAPERMISOREL ON PERMISO.IDE_CODIGO = CONFIGURAPERMISOREL.IDE_CODIGO LEFT OUTER JOIN
	                      KARDESPERMISO ON FACTIMPPERM.FIR_CODIGO = KARDESPERMISO.FIR_CODIGO
	WHERE (KARDESPERMISO.KAR_Saldo_FID > 0 OR KARDESPERMISO.FID_INDICED IS NULL) AND 
	    (CONFIGURAPERMISOREL.CFR_SALDO = 'S' OR CONFIGURAPERMISOREL.CFR_SALDOCARATULA = 'S')
	AND FACTIMPPERM.FID_INDICED=@FID_INDICED


	UPDATE PERMISO
	SET PE_ESTATUS='C'
	WHERE PE_SALDO=0 
		AND PE_CODIGO IN 
		(SELECT     PERMISODET.PE_CODIGO
		FROM         KARDESPERMISO INNER JOIN
		                      PERMISODET ON KARDESPERMISO.PED_INDICED = PERMISODET.PED_INDICED
		WHERE  FI_CODIGO=@fi_codigo
		GROUP BY PERMISODET.PE_CODIGO)

	
	
	UPDATE PERMISO
	SET PE_ESTATUS='C'
	WHERE PE_SALDOCOSTOT=0 
		AND PE_CODIGO IN 
		(SELECT     PERMISODET.PE_CODIGO
		FROM         KARDESPERMISO INNER JOIN
		                      PERMISODET ON KARDESPERMISO.PED_INDICED = PERMISODET.PED_INDICED
		WHERE  FI_CODIGO=@fi_codigo
		GROUP BY PERMISODET.PE_CODIGO)

	UPDATE FACTIMPPERM
	SET FIP_CANT =ISNULL((SELECT SUM(ROUND(KARDESPERMISO.KAR_CANTDESC, 6))
	FROM         KARDESPERMISO 
	WHERE KARDESPERMISO.FID_INDICED = FACTIMPPERM.FID_INDICED AND 
	                      KARDESPERMISO.PED_INDICED = FACTIMPPERM.PED_INDICED
	AND     (KARDESPERMISO.KAR_TIPO = 'C')
	GROUP BY FACTIMPPERM.FIR_CODIGO),0)
	WHERE FACTIMPPERM.FID_INDICED=@FID_INDICED
	AND ISNULL((SELECT SUM(ROUND(KARDESPERMISO.KAR_CANTDESC, 6))
		FROM         KARDESPERMISO 
		WHERE KARDESPERMISO.FID_INDICED = FACTIMPPERM.FID_INDICED AND 
		                      KARDESPERMISO.PED_INDICED = FACTIMPPERM.PED_INDICED
		AND     (KARDESPERMISO.KAR_TIPO = 'C')
		GROUP BY FACTIMPPERM.FIR_CODIGO),0)>0


	UPDATE FACTIMPPERM
	SET FIP_VALOR =ISNULL((SELECT SUM(ROUND(KARDESPERMISO.KAR_CANTDESC, 6))
	FROM         KARDESPERMISO 
	WHERE KARDESPERMISO.FID_INDICED = FACTIMPPERM.FID_INDICED AND 
	                      KARDESPERMISO.PED_INDICED = FACTIMPPERM.PED_INDICED
	AND     (KARDESPERMISO.KAR_TIPO = 'V')
	GROUP BY FACTIMPPERM.FIR_CODIGO),0)
	WHERE FACTIMPPERM.FID_INDICED=@FID_INDICED
	AND ISNULL((SELECT SUM(ROUND(KARDESPERMISO.KAR_CANTDESC, 6))
		FROM         KARDESPERMISO 
		WHERE KARDESPERMISO.FID_INDICED = FACTIMPPERM.FID_INDICED AND 
		                      KARDESPERMISO.PED_INDICED = FACTIMPPERM.PED_INDICED
		AND     (KARDESPERMISO.KAR_TIPO = 'V')
		GROUP BY FACTIMPPERM.FIR_CODIGO),0)>0






















GO
