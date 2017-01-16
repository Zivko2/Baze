SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_AFECTAPERMISO] (@FID_INDICED int, @CPE_CODIGO int, @PA_CODIGO int, @FID_COS_TOT decimal(38,6), @Cantidad decimal(38,6), @PE_CODIGOUso int, @Fir_codigo int) with encryption as
declare @fi_codigo int, @QtyADescargar decimal(38,6), @RestaDescargar decimal(38,6), @pe_codigo int, @ped_indiced int, @ped_saldo decimal(38,6), @ped_saldocostot decimal(38,6), @ar_impmx9802 int,
@consecutivo int, @fi_fecha datetime, @cfm_paishijo char(1), @me_codigo int, @kar_cantdesc decimal(38,6), @ar_impmx int, @ar_fraccion varchar(4), @ma_codigo int, @FIDINDICED varchar(50),
@cfr_saldo char(1), @cfr_saldocaratula char(1), @kar_cantdescCost decimal(38,6), @RestaDescargarCost decimal(38,6), @QtyADescargarCost decimal(38,6), @eq_cant decimal(28,14), @pa_origen int,
@pe_fecha datetime


	select @fi_codigo=fi_codigo, @ar_impmx=ar_impmx, @ma_codigo=ma_codigo, @pa_origen=pa_codigo,  @FIDINDICED=convert(varchar(50),fid_indiced) from factimpdet where fid_indiced=@FID_INDICED

	select @ar_fraccion=left(ar_fraccion,4) from arancel where ar_codigo=@ar_impmx

	set @ar_impmx9802=0

	if @ar_fraccion ='9802'
	set @ar_impmx9802=@ar_impmx


	select @fi_fecha=fi_fecha from factimp where fi_codigo=@fi_codigo

	select @eq_cant= eq_cant from factimpperm where fir_codigo=@Fir_codigo


	   set @RestaDescargar=round(@Cantidad,6)
	   set @QtyADescargar = @ped_saldo


 	  set @QtyADescargarCost = @ped_saldocostot		
               set @RestaDescargarCost=round(@FID_COS_TOT,6)


	DELETE     FACTIMPPERM
	FROM         FACTIMPPERM INNER JOIN
	                      FACTIMPPERM FACTIMPPERM_1 ON FACTIMPPERM.FID_INDICED = FACTIMPPERM_1.FID_INDICED INNER JOIN
	                      PERMISO ON FACTIMPPERM.PE_CODIGO = PERMISO.PE_CODIGO INNER JOIN
	                      PERMISO PERMISO_1 ON FACTIMPPERM_1.PE_CODIGO = PERMISO_1.PE_CODIGO left outer join
 		        CONFIGURAPERMISOREL on PERMISO.IDE_CODIGO = CONFIGURAPERMISOREL.IDE_CODIGO
	WHERE     (FACTIMPPERM.FIP_ESTATUSAFECTA = 0 OR
	                      FACTIMPPERM.FIP_ESTATUSAFECTA = 2) AND (FACTIMPPERM.FID_INDICED = @FID_INDICED) 
		AND (CFR_SALDO='S' or CFR_SALDOCARATULA='S')

	-- descarga el resto
	if @RestaDescargar >0 
	begin
		IF (SELECT CONFIGURAPERMISO.CFM_PAISHIJO FROM CONFIGURAPERMISO INNER JOIN IDENTIFICA ON CONFIGURAPERMISO.IDE_CODIGO = IDENTIFICA.IDE_CODIGO left outer join
		     CONFIGURAPERMISOREL ON CONFIGURAPERMISO.IDE_CODIGO = CONFIGURAPERMISOREL.IDE_CODIGO
		     WHERE CFR_SALDO='S' and IDENTIFICA.IDE_CLAVE = 'C1')='S'
		begin

			if @ar_impmx9802 <> 0 
			begin
				declare cur_Saldo cursor for
					select distinct permisodet.pe_codigo, ped_indiced, 'ped_saldo'=case when CFR_SALDO='S' then ped_saldo else pe_saldo end,
					     cfm_paishijo, me_com, isnull(CFR_SALDO,'N'), ped_saldocostot, pe_fecha
					from permisodet inner join permiso on permisodet.pe_codigo = permiso.pe_codigo left outer join
						configurapermiso on permiso.ide_codigo = configurapermiso.ide_codigo left outer join
						configurapermisorel on permiso.ide_codigo = configurapermisorel.ide_codigo
					where permisodet.pe_codigo > 0
						and ma_generico =@CPE_CODIGO 
						and ((CFR_SALDO='S' and ped_saldo>0 and ped_saldocostot>0) or (CFR_SALDOCARATULA='S' and pe_saldo>0 and pe_saldocostot>0))
						and permiso.pe_aprobado = 'S'
						--Yolanda Avila (2009-07-02)
						and (pe_fechavenc is null or pe_fechavenc>=@fi_fecha) and pe_fecha<=@fi_fecha 
						and permiso.pe_estatus='A'
						and permiso.ar_codigo=@ar_impmx9802
					             and permiso.pe_codigo in (select pe_codigo from permisopais where pa_codigo =@pa_origen)
					order by pe_fecha, permisodet.pe_codigo
			end
			else
			begin
				declare cur_Saldo cursor for
					select distinct permisodet.pe_codigo, ped_indiced, 'ped_saldo'=case when CFR_SALDO='S' then ped_saldo else pe_saldo end,
					     cfm_paishijo, me_com, isnull(CFR_SALDO,'N'), ped_saldocostot, pe_fecha
					from permisodet inner join permiso on permisodet.pe_codigo = permiso.pe_codigo left outer join
						configurapermiso on permiso.ide_codigo = configurapermiso.ide_codigo left outer join
						configurapermisorel on permiso.ide_codigo = configurapermisorel.ide_codigo
					where permisodet.pe_codigo > 0
						and ma_generico =@CPE_CODIGO 
						and ((CFR_SALDO='S' and ped_saldo>0 and ped_saldocostot>0) or (CFR_SALDOCARATULA='S' and pe_saldo>0 and pe_saldocostot>0))
						and permiso.pe_aprobado = 'S'
						--Yolanda Avila (2009-07-02)
						and (pe_fechavenc is null or pe_fechavenc>=@fi_fecha) and pe_fecha<=@fi_fecha 
					             and permiso.pe_codigo in (select pe_codigo from permisopais where pa_codigo =@pa_origen)
						and permiso.pe_estatus='A'
					order by pe_fecha, permisodet.pe_codigo
			end
		end
		else
		begin

			if @ar_impmx9802 <> 0 
			begin
				declare cur_Saldo cursor for
					select distinct permisodet.pe_codigo, ped_indiced, 'ped_saldo'=case when CFR_SALDO='S' then ped_saldo else pe_saldo end,
					     cfm_paishijo, me_com, isnull(CFR_SALDO,'N'), ped_saldocostot, pe_fecha
					from permisodet inner join permiso on permisodet.pe_codigo = permiso.pe_codigo left outer join
						configurapermiso on permiso.ide_codigo = configurapermiso.ide_codigo left outer join
						configurapermisorel on permiso.ide_codigo = configurapermisorel.ide_codigo
					where permisodet.pe_codigo > 0
						and ma_generico =@CPE_CODIGO 
						and ((CFR_SALDO='S' and ped_saldo>0 and ped_saldocostot>0) or (CFR_SALDOCARATULA='S' and pe_saldo>0 and pe_saldocostot>0))
						and permiso.pe_aprobado = 'S'
						--Yolanda Avila (2009-07-02)
						and (pe_fechavenc is null or pe_fechavenc>=@fi_fecha) and pe_fecha<=@fi_fecha 
						and permiso.pe_estatus='A'
						and permiso.ar_codigo=@ar_impmx9802
--					             and permiso.pe_codigo in (select pe_codigo from permisopais where pa_codigo =@pa_origen)
					order by pe_fecha, permisodet.pe_codigo
			end
			else
			begin
				declare cur_Saldo cursor for
					select distinct permisodet.pe_codigo, ped_indiced, 'ped_saldo'=case when CFR_SALDO='S' then ped_saldo else pe_saldo end,
					     cfm_paishijo, me_com, isnull(CFR_SALDO,'N'), ped_saldocostot, pe_fecha
					from permisodet inner join permiso on permisodet.pe_codigo = permiso.pe_codigo left outer join
						configurapermiso on permiso.ide_codigo = configurapermiso.ide_codigo left outer join
						configurapermisorel on permiso.ide_codigo = configurapermisorel.ide_codigo
					where permisodet.pe_codigo > 0
						and ma_generico =@CPE_CODIGO 
						and ((CFR_SALDO='S' and ped_saldo>0 and ped_saldocostot>0) or (CFR_SALDOCARATULA='S' and pe_saldo>0 and pe_saldocostot>0))
						and permiso.pe_aprobado = 'S'
						--Yolanda Avila (2009-07-02)
						and (pe_fechavenc is null or pe_fechavenc>=@fi_fecha) and pe_fecha<=@fi_fecha 
--					             and permiso.pe_codigo in (select pe_codigo from permisopais where pa_codigo =@pa_origen)
						and permiso.pe_estatus='A'
					order by pe_fecha, permisodet.pe_codigo
			end

		end
		open cur_Saldo
			FETCH NEXT FROM cur_Saldo INTO @pe_codigo, @ped_indiced, @ped_saldo, @cfm_paishijo, @me_codigo, @CFR_SALDO, @ped_saldocostot, @pe_fecha
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
								set pe_saldo= round(round(pe_saldo,6) - round(@QtyADescargar,6),6), PE_ENUSO='S'
								where pe_codigo=@pe_codigo

							end
							else
								update permiso
								set pe_saldo= round(round(pe_saldo,6) - round(@QtyADescargar,6),6), PE_ENUSO='S'
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

								/*update permiso
								set pe_saldo= 0, PE_ENUSO='S'
								where pe_codigo=@pe_codigo*/



								update permiso
								set pe_saldo= round(round(pe_saldo,6) - round(@QtyADescargar,6),6), PE_ENUSO='S'
								where pe_codigo=@pe_codigo

							end
							else
							begin
								/*update permiso
								set pe_saldo= 0, PE_ENUSO='S'
								where pe_codigo=@pe_codigo*/

								update permiso
								set pe_saldo= round(round(pe_saldo,6) - round(@QtyADescargar,6),6), PE_ENUSO='S'
								where pe_codigo=@pe_codigo

							end
						end
			
		
		
						if not exists(select * from factimpperm where ped_indiced=@ped_indiced and fid_indiced=@FID_INDICED)
						begin
							 EXEC SP_GETCONSECUTIVO @TIPO='FIR', @VALUE=@CONSECUTIVO OUTPUT
		

							insert into factimpperm (fir_codigo, fid_indiced, fi_codigo, ped_indiced, pe_codigo, FIP_ESTATUSAFECTA, CPE_CODIGO, eq_cant)
							values(@consecutivo, @fid_indiced, @fi_codigo, @ped_indiced, @pe_codigo, '1', @CPE_CODIGO, @eq_cant)
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
								set pe_saldocostot= round(round(pe_saldocostot,6) - round(@QtyADescargarCost,6),6),
								pe_enusocostot='S'
								where pe_codigo=@pe_codigo
	
							end
							else
	
								update permiso
								set pe_saldocostot= round(round(pe_saldocostot,6) - round(@QtyADescargarCost,6),6),
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
	
								/*update permiso
								set pe_saldocostot= 0, 
								pe_enusocostot='S'
								where pe_codigo=@pe_codigo*/

								update permiso
								set pe_saldocostot= round(round(pe_saldocostot,6) - round(@QtyADescargarCost,6),6),
								pe_enusocostot='S'
								where pe_codigo=@pe_codigo

	
							end
							else
								update permiso
								set pe_saldocostot= round(round(pe_saldocostot,6) - round(@QtyADescargarCost,6),6),
								pe_enusocostot='S'
								where pe_codigo=@pe_codigo

								/*update permiso
								set pe_saldocostot= 0, 
								pe_enusocostot='S'
								where pe_codigo=@pe_codigo*/
			
						end
			
						if not exists(select * from factimpperm where ped_indiced=@ped_indiced and fid_indiced=@FID_INDICED)
						begin
							 EXEC SP_GETCONSECUTIVO @TIPO='FIR', @VALUE=@CONSECUTIVO OUTPUT
		
							insert into factimpperm (fir_codigo, fid_indiced, fi_codigo, ped_indiced, pe_codigo, FIP_ESTATUSAFECTA, CPE_CODIGO, eq_cant)
							values(@consecutivo, @fid_indiced, @fi_codigo, @ped_indiced, @pe_codigo, '1', @CPE_CODIGO, @eq_cant)
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
		
			FETCH NEXT FROM cur_Saldo INTO @pe_codigo, @ped_indiced, @ped_saldo, @cfm_paishijo, @me_codigo, @CFR_SALDO, @ped_saldocostot, @pe_fecha
		
		END
		
		CLOSE cur_Saldo
		DEALLOCATE cur_Saldo



	end

	

	UPDATE FACTIMPPERM
	SET PED_INDICED=(SELECT     MIN(PED_INDICED) 
			FROM         KARDESPERMISO
			GROUP BY FIR_CODIGO
			HAVING      FIR_CODIGO = FACTIMPPERM.FIR_CODIGO)
	WHERE FACTIMPPERM.FIP_CANT >0 AND FACTIMPPERM.FID_INDICED=@FID_INDICED 

	UPDATE FACTIMPPERM
	SET     FACTIMPPERM.PE_CODIGO= PERMISODET.PE_CODIGO
	FROM         FACTIMPPERM INNER JOIN
	                      PERMISODET ON FACTIMPPERM.PED_INDICED = PERMISODET.PED_INDICED 
	WHERE FACTIMPPERM.FID_INDICED=@FID_INDICED 
	AND (FACTIMPPERM.PE_CODIGO <> PERMISODET.PE_CODIGO OR FACTIMPPERM.PE_CODIGO IS NULL)


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



	DELETE     FACTIMPPERM
	FROM         FACTIMPPERM INNER JOIN
	                      FACTIMPPERM FACTIMPPERM_1 ON FACTIMPPERM.FID_INDICED = FACTIMPPERM_1.FID_INDICED INNER JOIN
	                      PERMISO ON FACTIMPPERM.PE_CODIGO = PERMISO.PE_CODIGO INNER JOIN
	                      PERMISO PERMISO_1 ON FACTIMPPERM_1.PE_CODIGO = PERMISO_1.PE_CODIGO left outer join
 		        CONFIGURAPERMISOREL on PERMISO.IDE_CODIGO = CONFIGURAPERMISOREL.IDE_CODIGO
	WHERE     (FACTIMPPERM.FIP_ESTATUSAFECTA = 0 OR
	                      FACTIMPPERM.FIP_ESTATUSAFECTA = 2) AND (FACTIMPPERM.FID_INDICED = @FID_INDICED) 
		AND (FACTIMPPERM_1.FIP_ESTATUSAFECTA = 1)
		AND (CFR_SALDO='S' or CFR_SALDOCARATULA='S')

GO
