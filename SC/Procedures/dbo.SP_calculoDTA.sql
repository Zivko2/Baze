SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[SP_calculoDTA] (@picodigo int, @pi_movimiento char(1), @ccp_tipo char(2), @user int, @tipodta varchar(3)='OM' output)   as

SET NOCOUNT ON 
declare @valdta decimal(38,6), @cfijadta decimal(38,6), @tta_codigo int, @pi_fec_pag datetime, @pi_val_adu decimal(38,6), @CP_PAGODTA CHAR(1), @PG_CODIGO int,
@pi_numvehiculos int, @FechaActual varchar(10), @hora varchar(15), @registrosno int, @em_codigo int, @pit_contribpor decimal(38,6), @pi_rectifica int,
@pg_codigo2 int, @CP_CODIGO int, @ccp_tipo2 char(2), @cp_rectifica int

	select  @pi_movimiento=pi_movimiento, @pi_rectifica=pi_rectifica, 
	@cp_rectifica=cp_rectifica, @pi_fec_pag=pi_fec_pag, @CP_CODIGO=CP_CODIGO from pedimp where pi_codigo=@picodigo


	SET @FechaActual = convert(varchar(10), getdate(),101)

	select @em_codigo=em_codigo from intradeglobal.dbo.empresa where em_corto in
	(select replace(convert(sysname,db_name()),'intrade',''))

	select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

	insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
	values (@user, 2, 'Calculando DTA ', 'Calculating DTA ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)




	select @ccp_tipo2=ccp_tipo from configuraclaveped where cp_codigo=@cp_rectifica


	if (select cp_usanaftadta from claveped where cp_codigo in (select cp_codigo from pedimp where pi_codigo=@picodigo))='S'
	begin
		SELECT     @pi_val_adu=SUM(ROUND(PID_VAL_ADU, 2)) 
		FROM  dbo.PEDIMPDET
		WHERE dbo.PEDIMPDET.PID_IMPRIMIR = 'S'
		GROUP BY PI_CODIGO
		HAVING      (PI_CODIGO = @picodigo)

		select @registrosno=count(*) from pedimpdet where  pi_codigo=@picodigo  
	end
	else
	begin
		SELECT     @pi_val_adu=SUM(ROUND(PID_VAL_ADU, 2)) 
		FROM  VSPIVALADU
		GROUP BY PI_CODIGO
		HAVING      (PI_CODIGO = @picodigo)

 	             select @registrosno=count(*) from pedimpdet where  pi_codigo=@picodigo  and pid_def_tip<>'P' and spi_codigo not in (select spi_codigo from spi where spi_clave='nafta')
	end


	if @ccp_tipo= 'RE' 
		SELECT     @CP_PAGODTA=CLAVEPED.CP_PAGODTA FROM  CLAVEPED INNER JOIN PEDIMP ON CLAVEPED.CP_CODIGO = PEDIMP.CP_CODIGO
		WHERE     (PEDIMP.PI_CODIGO = @pi_rectifica)
	else
		SELECT     @CP_PAGODTA=CLAVEPED.CP_PAGODTA FROM  CLAVEPED INNER JOIN PEDIMP ON CLAVEPED.CP_CODIGO = PEDIMP.CP_CODIGO
		WHERE     (PEDIMP.PI_CODIGO = @picodigo)


	if (@pi_movimiento='E')
		select @cfijadta=cof_valor from contribucionfija where con_codigo in(select con_codigo from contribucion where con_clave='1') and cof_perini<=@pi_fec_pag and cof_perfin>=@pi_fec_pag
		and cof_tipo='I'
	else
		select @cfijadta=cof_valor from contribucionfija where con_codigo in(select con_codigo from contribucion where con_clave='1') and cof_perini<=@pi_fec_pag and cof_perfin>=@pi_fec_pag
		and cof_tipo='E'


	if (select isnull(fc_codigo,0) from pedimp where pi_codigo=@picodigo)> 0 and (SELECT CF_DTAMASUNOALCERRAR FROM CONFIGURACION)='S'
  	  select @pi_numvehiculos=isnull(pi_numvehiculos,1)+1 from pedimp where pi_codigo=@picodigo
	else
	  select @pi_numvehiculos=isnull(pi_numvehiculos,1) from pedimp where pi_codigo=@picodigo



	SELECT     @pg_codigo2=PG_CODIGO
	FROM         CONFIGURACONTRIBTPAGO
	WHERE     (CP_CODIGO = @CP_CODIGO) AND (CFC_MOVIMIENTO = @pi_movimiento) AND CON_CODIGO in (select con_codigo from contribucion where con_clave='1')

	if @pg_codigo2 is null
	set @pg_codigo2=0



	--print '@registrosno'
	--print @registrosno



		if @pi_movimiento='E' 
		begin
			if @CP_PAGODTA='O'  -- 8 al millar
			begin
				if (@pi_val_adu*.008)<@cfijadta or @pi_val_adu is null
				begin
					set @valdta=@cfijadta
					set @tta_codigo=(SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '3')
					set @pit_contribpor=@cfijadta

					 if @pg_codigo2<>0
					    set @pg_codigo=@pg_codigo2
					 else
					 begin
						if @ccp_tipo='ED'
						    set @PG_CODIGO=(SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='6')
						else
					                 set @PG_CODIGO=(SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0')
					end

					set @tipodta='CFM'
				end
				else
				begin
					set @valdta=@pi_val_adu*.008
					set @tta_codigo=(SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '7')
					set @pit_contribpor=8

					 if @pg_codigo2<>0
					    set @pg_codigo=@pg_codigo2
					 else
					 begin
						if @ccp_tipo='ED'
						    set @PG_CODIGO=(SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='6')
						else
					                 set @PG_CODIGO=(SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0')
					end


					set @tipodta='OM'
				end
			end
			else
			begin
				if @CP_PAGODTA='U' --1.76 al millar
				begin
					if (@pi_val_adu*.00176)<@cfijadta or @pi_val_adu is null
					begin
						set @valdta=@cfijadta
						set @tta_codigo=(SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '3')
						set @pit_contribpor=@cfijadta

						 if @pg_codigo2<>0
						    set @pg_codigo=@pg_codigo2
						 else
						 begin
							if @ccp_tipo='ED'
							    set @PG_CODIGO=(SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='6')
							else
						                 set @PG_CODIGO=(SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0')
						end

						set @tipodta='CFM'
					end
					else
					begin
						set @valdta=@pi_val_adu*.00176
						set @tta_codigo=(SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '7')
						set @pit_contribpor=1.76
	

						 if @pg_codigo2<>0
						    set @pg_codigo=@pg_codigo2
						 else
						 begin
							if @ccp_tipo='ED'
							    set @PG_CODIGO=(SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='6')
							else
						                 set @PG_CODIGO=(SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0')
						end	
			
						set @tipodta='SM'
					end
				end
				else
				begin
					if @CP_PAGODTA='C' -- cuota fija
					begin
						set @valdta=@cfijadta
						set @tta_codigo=(SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '4')
						set @pit_contribpor=@cfijadta

						 if @pg_codigo2<>0
						    set @pg_codigo=@pg_codigo2
						 else
						 begin
							if @ccp_tipo='ED'
							    set @PG_CODIGO=(SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='6')
							else
						                 set @PG_CODIGO=(SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0')
						end	

						set @tipodta='CF'
					end  
					else
					begin
						if @CP_PAGODTA='V' -- cuota fija por el no. de vehiculos
						begin
							set @valdta=@cfijadta*isnull(@pi_numvehiculos,1)
							set @tta_codigo=(SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '4')
							set @pit_contribpor=@cfijadta

							 if @pg_codigo2<>0
							    set @pg_codigo=@pg_codigo2
							 else
							 begin
								if @ccp_tipo='ED'
								    set @PG_CODIGO=(SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='6')
								else
							                 set @PG_CODIGO=(SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0')
							end
	
							set @tipodta='CFV'
						end
						else
						begin
	
							if @CP_PAGODTA='A'  -- insumos cuotafija, actijo fijo 8 al millar
							begin
								/*if exists(select * from vspivaladu where cft_tipo in ('Q', 'X', 'P') and pi_codigo = @picodigo)
								begin*/
									if (@pi_val_adu*.008)<@cfijadta
									begin
										set @valdta=@cfijadta
										set @tta_codigo=(SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '3')
										set @pit_contribpor=@cfijadta

										 if @pg_codigo2<>0
										    set @pg_codigo=@pg_codigo2
										 else
										 begin
											if @ccp_tipo='ED'
											    set @PG_CODIGO=(SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='6')
											else
										                 set @PG_CODIGO=(SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0')
										end	

										set @tipodta='CFM'
									end
									else
									begin
										set @valdta=@pi_val_adu*.008
										set @tta_codigo=(SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '7')
										set @pit_contribpor=8

										 if @pg_codigo2<>0
										    set @pg_codigo=@pg_codigo2
										 else
										 begin
											if @ccp_tipo='ED'
											    set @PG_CODIGO=(SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='6')
											else
										                 set @PG_CODIGO=(SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0')
										end

										set @tipodta='OM'
									end
								/*end
								else
								begin
									set @valdta=@cfijadta
									set @tta_codigo=(SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '4')
									set @pit_contribpor=@cfijadta
				
									 if @pg_codigo2<>0
									    set @pg_codigo=@pg_codigo2
									 else
									 begin
										if @ccp_tipo='ED'
										    set @PG_CODIGO=(SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='6')
										else
									                 set @PG_CODIGO=(SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0')
									end				

									set @tipodta='CF'
								end*/
							end
							else
							begin
								set @valdta=0
								set @tta_codigo=0
								set @pit_contribpor=0


								 if @pg_codigo2<>0
								    set @pg_codigo=@pg_codigo2
								 else
								 begin
									if @ccp_tipo='ED'
									    set @PG_CODIGO=(SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='6')
									else
								                 set @PG_CODIGO=(SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='9')
								end


								set @tipodta='SIN'	
							end
						end
					end
				end
			end
		end
		else
		begin
			if @CP_PAGODTA='N' -- no paga dta
			begin
				set @valdta=0
				set @tta_codigo=0
				set @pit_contribpor=0


				 if @pg_codigo2<>0
				    set @pg_codigo=@pg_codigo2
				 else
			                 set @PG_CODIGO=(SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0')
	
				set @tipodta='SIN'
			end
			else	-- cuota fija para exportaciones
			begin
				if @CP_PAGODTA='V' -- cuota fija por el no. de vehiculos
				begin
					set @valdta=@cfijadta*isnull(@pi_numvehiculos,1)
					set @tta_codigo=(SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '4')
					set @pit_contribpor=@cfijadta

					 if @pg_codigo2<>0
					    set @pg_codigo=@pg_codigo2
					 else
				                 set @PG_CODIGO=(SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0')


					set @tipodta='CFV'
				end
				else
				begin
					set @valdta=@cfijadta
					set @tta_codigo=(SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '4')
					set @pit_contribpor=@cfijadta

					 if @pg_codigo2<>0
					    set @pg_codigo=@pg_codigo2
					 else
				                 set @PG_CODIGO=(SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0')


					set @tipodta='CF'
				end
			end
		end



	if @ccp_tipo in ('VT', 'ER', 'EV') and @pi_movimiento='S'
	set @pg_codigo=10
		

	if @ccp_tipo2 in ('VT', 'ER', 'EV') and @pi_movimiento='S'
	set @pg_codigo=10




		--print convert(varchar(10),@valdta) + 'val dta'
	if exists(select * from pedimpcontribucion where con_codigo in(select con_codigo from contribucion where con_clave='1') and PIT_CONTRIBTOTMN<>round(@valdta,0) and pi_codigo=@picodigo)
	delete from pedimpcontribucion where con_codigo in(select con_codigo from contribucion where con_clave='1') and PIT_CONTRIBTOTMN<>round(@valdta,0) and pi_codigo=@picodigo

	
	if @registrosno>0  and @pi_val_adu is not null
	begin
	
		if not exists(select * from pedimpcontribucion where con_codigo in(select con_codigo from contribucion where con_clave='1') and pi_codigo=@picodigo)
		insert into pedimpcontribucion(PI_CODIGO, PG_CODIGO, TTA_CODIGO, CON_CODIGO, PIT_CONTRIBPOR, PIT_CONTRIBTOTMN, PIT_TIPO)	
		select @picodigo, @PG_CODIGO, @tta_codigo, (select con_codigo from contribucion where con_clave='1'), @pit_contribpor, isnull(round(@valdta,0),0), 'N'


	end

	-- prevalidacion
	--if @ccp_tipo<> 'RE' 
	begin
		set @pg_codigo2=0

		SELECT     @pg_codigo2=PG_CODIGO
		FROM         CONFIGURACONTRIBTPAGO
		WHERE     (CP_CODIGO = @CP_CODIGO) AND (CFC_MOVIMIENTO = @pi_movimiento) AND CON_CODIGO in (select con_codigo from contribucion where con_clave='15')

		if @pg_codigo2 is null
		set @pg_codigo2=0

		if not exists(select * from pedimpcontribucion where con_codigo in (select con_codigo from contribucion where con_clave='15') and pi_codigo=@picodigo)
		--Nueva contribución 205 Manuel G. 5-ene-2012
		if exists (select * from CONTRIBUCIONFIJA where COF_PERINI <= @pi_fec_pag and CONTRIBUCIONFIJA.CON_CODIGO in(select con_codigo from contribucion where con_clave='15'))
		insert into pedimpcontribucion(PI_CODIGO, PG_CODIGO, TTA_CODIGO, CON_CODIGO, PIT_CONTRIBPOR, PIT_CONTRIBTOTMN, PIT_TIPO)	
		SELECT     @picodigo, case when @pg_codigo2= 0 then (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0') else @pg_codigo2 end, (SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '2'), (select con_codigo from contribucion where con_clave='15'), 
					210/*205 140 CONTRIBUCIONFIJA.COF_PORCENTFIJA*/, floor(round(CONTRIBUCIONFIJA.COF_VALOR,0)), 'N'
		FROM         CONTRIBUCIONFIJA INNER JOIN
		                      CONTRIBUCION ON CONTRIBUCIONFIJA.CON_CODIGO = CONTRIBUCION.CON_CODIGO
		WHERE     (CONTRIBUCIONFIJA.COF_PERINI <= @pi_fec_pag) AND 
		                      (CONTRIBUCIONFIJA.COF_PERFIN >= @pi_fec_pag) AND (CONTRIBUCIONFIJA.CON_CODIGO in(select con_codigo from contribucion where con_clave='15'))
		GROUP BY CONTRIBUCIONFIJA.COF_VALOR, CONTRIBUCIONFIJA.COF_PORCENTFIJA
	end

GO
