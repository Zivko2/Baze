SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_fillpedimpdetReg] (@picodigo int, @user int, @piafectado int=0, @fecodigo int=0)  as
SET NOCOUNT ON 
declare @maximo int, @pi_ft_adu decimal(38,9), @VINPCMAX decimal(38,6), @pi_fec_sal datetime, @pi_tip_cam decimal(38,6), @Pid_indiced int, @FechaActual varchar(10), @hora varchar(15), @em_codigo int,
@ccp_tipo varchar(5), @PI_USA_TIP_CAMFACT CHAR(1), @cp_codigo int, @cp_clave varchar(20), @cp_rectifica int, @ccp_tipo2 varchar(5), @Vencido char(1)


-- SI EL @piafectado VIENE MAYOR QUE CERO, SIGNIFICA QUE VA A SER EN BASE AL KARDESPED

	ALTER TABLE PEDIMPDET DISABLE TRIGGER insert_pedimpdet

	select @em_codigo=em_codigo from intradeglobal.dbo.empresa where em_corto in
	(select replace(convert(sysname,db_name()),'intrade',''))

	select @cp_codigo=cp_codigo, @cp_rectifica=cp_rectifica from pedimp where pi_codigo=@picodigo

	select @ccp_tipo=ccp_tipo from configuraclaveped where cp_codigo =@cp_codigo


	select @cp_clave=cp_clave from claveped where cp_codigo=@cp_codigo




	select @ccp_tipo2=ccp_tipo from configuraclaveped where cp_codigo=@cp_rectifica

	set @Vencido='N'

	if (@ccp_tipo='RG' or @ccp_tipo2='RG') and (select PI_DESP_EQUIPO from pedimp where pi_codigo=@picodigo)='S'
	set @Vencido='S'




SET @FechaActual = convert(varchar(10), getdate(),101)
select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

/*===================== inicio incrementables ======================*/


	insert into  intradeglobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
	values (@user, 2, 'Llenando tabla temporal de detalle ', 'Filling Deail temporary table ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)


	select @pi_tip_cam=PI_TIP_CAM, @pi_ft_adu=pi_ft_adu, @pi_fec_sal=pi_fec_ent, @PI_USA_TIP_CAMFACT=PI_USA_TIP_CAMFACT from pedimp where pi_codigo=@picodigo


	TRUNCATE TABLE TempPedImpDetF4
	
	SELECT     @maximo= MAX(PID_INDICED)+1
	FROM         PEDIMPDET

	dbcc checkident (TempPedImpDetF4, reseed, 1) WITH NO_INFOMSGS


	-- cuando ANX_VID_YEAR es nulo asigna como default 10 anios para que no genere error de division entre zero
	UPDATE ANEXO24
	SET ANEXO24.ANX_VID_YEAR=10
	FROM  ANEXO24 
	WHERE MA_CODIGO IN
		(SELECT MA_HIJO FROM KARDESPED LEFT OUTER JOIN
	                      FACTEXPDET ON KARDESPED.KAP_INDICED_FACT = FACTEXPDET.FED_INDICED LEFT OUTER JOIN 
	                      FACTEXP ON FACTEXPDET.FE_CODIGO = FACTEXP.FE_CODIGO WHERE FACTEXP.PI_CODIGO = @picodigo)
	AND ANX_VID_YEAR=0


	IF (SELECT /*PICF_SAAIDETDIVFACT */ PICF_PEDIMPSINAGRUP FROM PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='S'
	begin
		if @ccp_tipo not in ('RE','CN')
		begin
			INSERT INTO TempPedImpDetF4 (PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_COS_UNI, 
				PID_CANT, PID_CTOT_DLS, ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
				AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
				PA_PROCEDE, ME_GENERICO, ME_ARIMPMX, PID_CAN_GEN, PID_CAN_AR, PID_COS_UNIVA, PID_COS_UNIMATGRA, 
				PI_FEC_ENTPI, PID_NOPARTEAUX, PID_CODIGOFACT, PID_CTOT_MN, PID_PEDF4ORIG, PID_PES_UNIKG)
		        -- 26/Enero/2010 Manuel G. Se modifico agregando validacion para el valor de PID_CTOT_DLS, validando que exita un registro en ANEXO24 (ANEXO24.MA_CODIGO is not null) 
			SELECT     @picodigo, KARDESPED.MA_HIJO, PEDIMPDET.PID_NOPARTE, MAX(PEDIMPDET.PID_NOMBRE), MAX(PEDIMPDET.PID_NAME), 
			                     0, round(SUM(KARDESPED.KAP_CANTDESC/isnull(PEDIMPDET.EQ_GENERICO,1)),6), case when @cp_clave='F5' and isnull(max(isnull(ANEXO24.ANX_VID_YEAR,10)),0)>0 and ANEXO24.MA_CODIGO is not null then
				round(SUM((KARDESPED.KAP_CANTDESC * PEDIMPDET.PID_COS_UNIGEN) - 
				((KARDESPED.KAP_CANTDESC * PEDIMPDET.PID_COS_UNIGEN) / (isnull(ANEXO24.ANX_VID_YEAR,10) * 365))* convert(int,GETDATE() - PEDIMP.PI_FEC_ENT)),6) 
				else round(SUM(KARDESPED.KAP_CANTDESC * ISNULL(PEDIMPDET.PID_COS_UNIGEN, 0)),6) end,
			                       PEDIMPDET.ME_CODIGO, PEDIMPDET.MA_GENERICO, 
			                      1, 1, ISNULL(PEDIMPDET.AR_IMPMX, 0), ISNULL(MAESTRO_2.AR_IMPFO, 0), 
			                      dbo.GetAdvalorem(MAESTRO_2.AR_IMPFO, 0, 'G', 0, 0), case when @Vencido='S' then 0 else PEDIMPDET.PID_SEC_IMP end, 'PID_DEF_TIP'=case when @Vencido='S' then 'G' else isnull(PEDIMPDET.PID_DEF_TIP, 'G') end, 
					'PID_POR_DEF'=case when @Vencido='S' then dbo.GetAdvalorem(PEDIMPDET.AR_IMPMX, 0, 'G', 0, 0) else PEDIMPDET.PID_POR_DEF end, 
			                      ISNULL(PEDIMPDET.TI_CODIGO, 10), PEDIMPDET.PA_ORIGEN, case when @Vencido='S' then 0 else PEDIMPDET.SPI_CODIGO end, (SELECT CF_PAIS_MX FROM CONFIGURACION), 
			                      max(PEDIMPDET.ME_GENERICO), max(PEDIMPDET.ME_ARIMPMX), round(SUM(KARDESPED.KAP_CANTDESC),6), round(SUM((KARDESPED.KAP_CANTDESC/isnull(PEDIMPDET.EQ_GENERICO,1))* isnull(PEDIMPDET.EQ_IMPMX,1)),6), 0, 0, PEDIMP.PI_FEC_ENT,
					isnull(MAESTRO_2.MA_NOPARTEAUX,''), FACTEXPDET.FED_INDICED,
				    'PID_CTOT_MN'=case when @PI_USA_TIP_CAMFACT<>'S' then round(SUM(KARDESPED.KAP_CANTDESC * ISNULL(PEDIMPDET.PID_COS_UNIGEN * @PI_TIP_CAM, 0)),6) else round(SUM(KARDESPED.KAP_CANTDESC * ISNULL(PEDIMPDET.PID_COS_UNIGEN * FACTEXP.FE_TIPOCAMBIO, 0)),6) end,
				PEDIMPDET.PI_CODIGO, MAX(PID_PES_UNIKG)
			FROM         KARDESPED LEFT OUTER JOIN
			                      PEDIMPDET LEFT OUTER JOIN
			                      PEDIMP ON PEDIMPDET.PI_CODIGO = PEDIMP.PI_CODIGO ON 
			                      KARDESPED.KAP_INDICED_PED = PEDIMPDET.PID_INDICED RIGHT OUTER JOIN
			                      FACTEXPDET ON KARDESPED.KAP_INDICED_FACT = FACTEXPDET.FED_INDICED LEFT OUTER JOIN
			                      MAESTRO MAESTRO_2 ON KARDESPED.MA_HIJO = MAESTRO_2.MA_CODIGO RIGHT OUTER JOIN
			                      FACTEXP ON FACTEXPDET.FE_CODIGO = FACTEXP.FE_CODIGO LEFT OUTER JOIN 
				         ANEXO24 ON PEDIMPDET.MA_CODIGO = ANEXO24.MA_CODIGO
			WHERE     (FACTEXP.PI_CODIGO = @picodigo or (FACTEXP.PI_CODIGO = @picodigo and
					KARDESPED.KAP_INDICED_PED IN
					(SELECT     FACTEXPDET.FED_INDICED
					FROM         PEDIMPRELTRANS INNER JOIN
					                      PEDIMPDET ON PEDIMPRELTRANS.PID_INDICED = PEDIMPDET.PID_INDICED INNER JOIN
					                      FACTEXPDET ON PEDIMPRELTRANS.FED_INDICED = FACTEXPDET.FED_INDICED
					WHERE     PEDIMPDET.PID_REGIONFIN = 'M' GROUP BY FACTEXPDET.FED_INDICED)))
					 AND (KARDESPED.MA_HIJO IS NOT NULL) AND (PEDIMP.PI_TIPO<>'T')
			GROUP BY KARDESPED.MA_HIJO, PEDIMPDET.PID_NOPARTE, PEDIMPDET.PID_COS_UNIGEN, 
			                      PEDIMPDET.MA_GENERICO, PEDIMPDET.AR_IMPMX, 
			                      MAESTRO_2.AR_IMPFO, PEDIMPDET.PID_SEC_IMP, PEDIMPDET.PID_DEF_TIP, 
			                      PEDIMPDET.PID_POR_DEF, PEDIMPDET.TI_CODIGO, PEDIMPDET.PA_ORIGEN, PEDIMPDET.SPI_CODIGO, 
			                      PEDIMPDET.ME_CODIGO, PEDIMP.PI_FEC_ENT, MAESTRO_2.MA_NOPARTEAUX, FACTEXPDET.FED_INDICED, PEDIMPDET.PI_CODIGO, ANEXO24.MA_CODIGO
			HAVING      (SUM(KARDESPED.KAP_CANTDESC) > 0)


		end
		else
		begin
			--Se agrego opcion para los cambios de regimen, ya que el costo debera ser tomado de la factura de exportacion
			--y no del pedimento afectado en la descarga. Manuel G. 24-Oct-2012 requerimiento de soporte
			if  @ccp_tipo = 'CN'
				begin
				
					INSERT INTO TempPedImpDetF4 (PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_COS_UNI, 
						PID_CANT, PID_CTOT_DLS, ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
						AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
						PA_PROCEDE, ME_GENERICO, ME_ARIMPMX, PID_CAN_GEN, PID_CAN_AR, PID_COS_UNIVA, PID_COS_UNIMATGRA, 
						PI_FEC_ENTPI, PID_NOPARTEAUX, PID_CODIGOFACT, PID_CTOT_MN, PID_PEDF4ORIG, PID_PES_UNIKG)
						-- 26/Enero/2010 Manuel G. Se modifico agregando validacion para el valor de PID_CTOT_DLS, validando que exita un registro en ANEXO24 (ANEXO24.MA_CODIGO is not null) 
						-- 7/Marzo/2013 Manuel G. se modifico para el pid_cant ya que el redondeo esta erroneo,
						-- 7/Marzo/2013 Manuel G. se modifico para el pid_ctot_dls ya que la cantidad debe ser de la factura de exportacion.
						-- 15/Marzo/2013 Manuel G. se modifico para el pid_ctot_dls poniendo nuevamente la cantidad descarga entre el factor de conversion de GG
						--21/Marzo/2013 Manuel G. se cambio nuevamente a lo siguiente:
						--													* Si es F5 y tiene informacion de vida util (depreciacion), el C.U. debera tomarlo del pedimento
						--													* Si solo es F5, sin datos de vida util, el C.U. debera tomarlo de la factura
						--													* Si es F4, el C.U. debera tomarlo del pedimento
					SELECT     @picodigo, KARDESPED.MA_HIJO, PEDIMPDET.PID_NOPARTE, MAX(PEDIMPDET.PID_NOMBRE), MAX(PEDIMPDET.PID_NAME), 
										 0, SUM(KARDESPED.KAP_CANTDESC)/sum(round(isnull(PEDIMPDET.EQ_GENERICO,1),6)),
										 case when @cp_clave='F5' and isnull(max(isnull(ANEXO24.ANX_VID_YEAR,10)),0)>0 and ANEXO24.MA_CODIGO is not null then
						round(SUM((KARDESPED.KAP_CANTDESC * PEDIMPDET.PID_COS_UNIGEN) - 
						((KARDESPED.KAP_CANTDESC * PEDIMPDET.PID_COS_UNIGEN) / (isnull(ANEXO24.ANX_VID_YEAR,10) * 365))* convert(int,GETDATE() - PEDIMP.PI_FEC_ENT)),6) 
						else 
							--(round(SUM(pedimpdet.pid_cant)/*/ sum(factexpdet.EQ_GEN)*/,6)) * sum(round(ISNULL(factexpdet.fed_cos_uni, 0),6))
							case when @cp_clave = 'F5' then
								SUM(KARDESPED.KAP_CANTDESC)* sum(ISNULL(factexpdet.fed_cos_uni, 0))
							else
								--para los F4
						     (SUM(KARDESPED.KAP_CANTDESC)/ round(sum(pedimpdet.eq_generico),6)) *  sum(ISNULL(PEDIMPDET.PID_COS_UNI, 0))

							end
						end,
										   PEDIMPDET.ME_CODIGO, PEDIMPDET.MA_GENERICO , 
										  1, 1, ISNULL(PEDIMPDET.AR_IMPMX, 0), ISNULL(MAESTRO_2.AR_IMPFO, 0), 
										  dbo.GetAdvalorem(MAESTRO_2.AR_IMPFO, 0, 'G', 0, 0), case when @Vencido='S' then 0 else PEDIMPDET.PID_SEC_IMP end, 'PID_DEF_TIP'=case when @Vencido='S' then 'G' else isnull(PEDIMPDET.PID_DEF_TIP, 'G') end, 
							'PID_POR_DEF'=case when @Vencido='S' then dbo.GetAdvalorem(PEDIMPDET.AR_IMPMX, 0, 'G', 0, 0) else PEDIMPDET.PID_POR_DEF end, 
										  ISNULL(PEDIMPDET.TI_CODIGO, 10), PEDIMPDET.PA_ORIGEN, case when @Vencido='S' then 0 else PEDIMPDET.SPI_CODIGO end, (SELECT CF_PAIS_MX FROM CONFIGURACION), 
										  max(PEDIMPDET.ME_GENERICO), max(PEDIMPDET.ME_ARIMPMX), round(SUM(KARDESPED.KAP_CANTDESC),6), round(SUM((KARDESPED.KAP_CANTDESC/isnull(PEDIMPDET.EQ_GENERICO,1))* isnull(PEDIMPDET.EQ_IMPMX,1)),6), 0, 0, PEDIMP.PI_FEC_ENT,
							isnull(MAESTRO_2.MA_NOPARTEAUX,''), FACTEXPDET.FED_INDICED,
							'PID_CTOT_MN'=case when @PI_USA_TIP_CAMFACT<>'S' 
											then 
												case when @cp_clave = 'F5' then
													round(SUM(KARDESPED.KAP_CANTDESC * ISNULL(FACTEXPDET.FED_COS_UNI* @PI_TIP_CAM, 0)),6) 
												else
													round(SUM(KARDESPED.KAP_CANTDESC * ISNULL(PEDIMPDET.PID_COS_UNIGEN* @PI_TIP_CAM, 0)),6) 
												end
											else 
												case when @cp_clave = 'F5' then
													round(SUM(KARDESPED.KAP_CANTDESC * ISNULL(FACTEXPDET.FED_COS_UNI* @PI_TIP_CAM, 0)),6) 
												else
													round(SUM(KARDESPED.KAP_CANTDESC * ISNULL(PEDIMPDET.PID_COS_UNIGEN * FACTEXP.FE_TIPOCAMBIO, 0)),6) 
												end
										   end,
						PEDIMPDET.PI_CODIGO, MAX(PID_PES_UNIKG)
					FROM         KARDESPED LEFT OUTER JOIN
										  PEDIMPDET LEFT OUTER JOIN
										  PEDIMP ON PEDIMPDET.PI_CODIGO = PEDIMP.PI_CODIGO ON 
										  KARDESPED.KAP_INDICED_PED = PEDIMPDET.PID_INDICED RIGHT OUTER JOIN
										  FACTEXPDET ON KARDESPED.KAP_INDICED_FACT = FACTEXPDET.FED_INDICED LEFT OUTER JOIN
										  MAESTRO MAESTRO_2 ON KARDESPED.MA_HIJO = MAESTRO_2.MA_CODIGO RIGHT OUTER JOIN
										  FACTEXP ON FACTEXPDET.FE_CODIGO = FACTEXP.FE_CODIGO LEFT OUTER JOIN 
								 ANEXO24 ON PEDIMPDET.MA_CODIGO = ANEXO24.MA_CODIGO
					WHERE     (FACTEXP.PI_CODIGO = @picodigo or (FACTEXP.PI_CODIGO = @picodigo and
							KARDESPED.KAP_INDICED_PED IN
							(SELECT     FACTEXPDET.FED_INDICED
							FROM         PEDIMPRELTRANS INNER JOIN
												  PEDIMPDET ON PEDIMPRELTRANS.PID_INDICED = PEDIMPDET.PID_INDICED INNER JOIN
												  FACTEXPDET ON PEDIMPRELTRANS.FED_INDICED = FACTEXPDET.FED_INDICED
							WHERE     PEDIMPDET.PID_REGIONFIN = 'M' GROUP BY FACTEXPDET.FED_INDICED)))
							 AND (KARDESPED.MA_HIJO IS NOT NULL) AND (PEDIMP.PI_TIPO<>'T')
					GROUP BY KARDESPED.MA_HIJO, PEDIMPDET.PID_NOPARTE, /*PEDIMPDET.PID_COS_UNIGEN*/factexpdet.fed_cos_uni, 
										  PEDIMPDET.MA_GENERICO, PEDIMPDET.AR_IMPMX, 
										  MAESTRO_2.AR_IMPFO, PEDIMPDET.PID_SEC_IMP, PEDIMPDET.PID_DEF_TIP, 
										  PEDIMPDET.PID_POR_DEF, PEDIMPDET.TI_CODIGO, PEDIMPDET.PA_ORIGEN, PEDIMPDET.SPI_CODIGO, 
										  PEDIMPDET.ME_CODIGO, PEDIMP.PI_FEC_ENT, MAESTRO_2.MA_NOPARTEAUX, FACTEXPDET.FED_INDICED, PEDIMPDET.PI_CODIGO, ANEXO24.MA_CODIGO
					HAVING      (SUM(KARDESPED.KAP_CANTDESC) > 0)				
				
				end
			else
				begin
					INSERT INTO TempPedImpDetF4 (PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_COS_UNI, 
						PID_CANT, PID_CTOT_DLS, ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
						AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
						PA_PROCEDE, ME_GENERICO, ME_ARIMPMX, PID_CAN_GEN, PID_CAN_AR, PID_COS_UNIVA, PID_COS_UNIMATGRA, 
						PI_FEC_ENTPI, PID_NOPARTEAUX, PID_CODIGOFACT, PID_CTOT_MN, PID_PEDF4ORIG, PID_PES_UNIKG)
								-- 26/Enero/2010 Manuel G. Se modifico agregando validacion para el valor de PID_CTOT_DLS, validando que exita un registro en ANEXO24 (ANEXO24.MA_CODIGO is not null) 		
					SELECT     @picodigo, KARDESPED.MA_HIJO, PEDIMPDET.PID_NOPARTE, MAX(PEDIMPDET.PID_NOMBRE), MAX(PEDIMPDET.PID_NAME), 
										  0, round(SUM(KARDESPED.KAP_CANTDESC/isnull(PEDIMPDET.EQ_GENERICO,1)),6), 
										   case when @cp_clave='F5' and isnull(max(isnull(ANEXO24.ANX_VID_YEAR,10)),0)>0 and ANEXO24.MA_CODIGO is not null then
						round(SUM((KARDESPED.KAP_CANTDESC * PEDIMPDET.PID_COS_UNIGEN) - 
						((KARDESPED.KAP_CANTDESC * PEDIMPDET.PID_COS_UNIGEN) / (isnull(ANEXO24.ANX_VID_YEAR,10) * 365))* convert(int,GETDATE() - PEDIMP.PI_FEC_ENT)),6) 
						else round(SUM(KARDESPED.KAP_CANTDESC * ISNULL(PEDIMPDET.PID_COS_UNIGEN, 0)),6) end,
								  PEDIMPDET.ME_CODIGO, PEDIMPDET.MA_GENERICO, 
										  1, 1, ISNULL(PEDIMPDET.AR_IMPMX, 0), ISNULL(MAESTRO_2.AR_IMPFO, 0), 
										  dbo.GetAdvalorem(MAESTRO_2.AR_IMPFO, 0, 'G', 0, 0), case when @Vencido='S' then 0 else PEDIMPDET.PID_SEC_IMP end, 'PID_DEF_TIP'=case when @Vencido='S' then 'G' else isnull(PEDIMPDET.PID_DEF_TIP, 'G') end, 
							'PID_POR_DEF'=case when @Vencido='S' then dbo.GetAdvalorem(PEDIMPDET.AR_IMPMX, 0, 'G', 0, 0) else PEDIMPDET.PID_POR_DEF end, 
										  ISNULL(PEDIMPDET.TI_CODIGO, 10), PEDIMPDET.PA_ORIGEN, case when @Vencido='S' then 0 else PEDIMPDET.SPI_CODIGO end, (SELECT CF_PAIS_MX FROM CONFIGURACION), 
										  max(PEDIMPDET.ME_GENERICO), max(PEDIMPDET.ME_ARIMPMX), round(SUM(KARDESPED.KAP_CANTDESC),6), round(SUM((KARDESPED.KAP_CANTDESC/isnull(PEDIMPDET.EQ_GENERICO,1))* isnull(PEDIMPDET.EQ_IMPMX,1)),6), 0, 0, PEDIMP.PI_FEC_ENT,
							isnull(MAESTRO_2.MA_NOPARTEAUX,''), FACTEXPDET.FED_INDICED,
							'PID_CTOT_MN'=case when @PI_USA_TIP_CAMFACT<>'S' then round(SUM(KARDESPED.KAP_CANTDESC * ISNULL(PEDIMPDET.PID_COS_UNIGEN * @PI_TIP_CAM, 0)),6) else round(SUM(KARDESPED.KAP_CANTDESC * ISNULL(PEDIMPDET.PID_COS_UNIGEN * FACTEXP.FE_TIPOCAMBIO, 0)),6) end,
						PEDIMPDET.PI_CODIGO, MAX(PID_PES_UNIKG)
					FROM         KARDESPED LEFT OUTER JOIN
										  PEDIMPDET LEFT OUTER JOIN
										  PEDIMP ON PEDIMPDET.PI_CODIGO = PEDIMP.PI_CODIGO ON 
										  KARDESPED.KAP_INDICED_PED = PEDIMPDET.PID_INDICED RIGHT OUTER JOIN
										  FACTEXPDET ON KARDESPED.KAP_INDICED_FACT = FACTEXPDET.FED_INDICED LEFT OUTER JOIN
										  MAESTRO MAESTRO_2 ON KARDESPED.MA_HIJO = MAESTRO_2.MA_CODIGO RIGHT OUTER JOIN
										  FACTEXP ON FACTEXPDET.FE_CODIGO = FACTEXP.FE_CODIGO LEFT OUTER JOIN 
								 ANEXO24 ON PEDIMPDET.MA_CODIGO = ANEXO24.MA_CODIGO
					WHERE     (FACTEXP.PI_RECTIFICA = @picodigo or (FACTEXP.PI_RECTIFICA = @picodigo and
							KARDESPED.KAP_INDICED_PED IN
							(SELECT     FACTEXPDET.FED_INDICED
							FROM         PEDIMPRELTRANS INNER JOIN
												  PEDIMPDET ON PEDIMPRELTRANS.PID_INDICED = PEDIMPDET.PID_INDICED INNER JOIN
												  FACTEXPDET ON PEDIMPRELTRANS.FED_INDICED = FACTEXPDET.FED_INDICED
							WHERE     PEDIMPDET.PID_REGIONFIN = 'M' GROUP BY FACTEXPDET.FED_INDICED)))
							 AND (KARDESPED.MA_HIJO IS NOT NULL) AND (PEDIMP.PI_TIPO<>'T')
					GROUP BY KARDESPED.MA_HIJO, PEDIMPDET.PID_NOPARTE, PEDIMPDET.PID_COS_UNIGEN, 
										  PEDIMPDET.MA_GENERICO, PEDIMPDET.AR_IMPMX, PEDIMPDET.PI_CODIGO,
										  MAESTRO_2.AR_IMPFO, PEDIMPDET.PID_SEC_IMP, PEDIMPDET.PID_DEF_TIP, 
										  PEDIMPDET.PID_POR_DEF, PEDIMPDET.TI_CODIGO, PEDIMPDET.PA_ORIGEN, PEDIMPDET.SPI_CODIGO, 
										  PEDIMPDET.ME_CODIGO, PEDIMP.PI_FEC_ENT, MAESTRO_2.MA_NOPARTEAUX, FACTEXPDET.FED_INDICED, ANEXO24.MA_CODIGO
					HAVING      (SUM(KARDESPED.KAP_CANTDESC) > 0)
				end
		end
	end
	else
	begin
		if @ccp_tipo not in ('RE','CN')
		begin
			INSERT INTO TempPedImpDetF4 (PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_COS_UNI, 
				PID_CANT, PID_CTOT_DLS, ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
				AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
				PA_PROCEDE, ME_GENERICO, ME_ARIMPMX, PID_CAN_GEN, PID_CAN_AR, PID_COS_UNIVA, PID_COS_UNIMATGRA, PI_FEC_ENTPI, 
				PID_NOPARTEAUX, PID_CTOT_MN, PID_PEDF4ORIG, PID_PES_UNIKG, PID_CODIGOFACT)
                        -- 26/Enero/2010 Manuel G. Se modifico agregando validacion para el valor de PID_CTOT_DLS, validando que exita un registro en ANEXO24 (ANEXO24.MA_CODIGO is not null) 		
			SELECT     @picodigo, KARDESPED.MA_HIJO, PEDIMPDET.PID_NOPARTE, MAX(PEDIMPDET.PID_NOMBRE), MAX(PEDIMPDET.PID_NAME), 
			                      0, round(SUM(KARDESPED.KAP_CANTDESC/isnull(PEDIMPDET.EQ_GENERICO,1)),6), 
			                       case when @cp_clave='F5' and isnull(max(isnull(ANEXO24.ANX_VID_YEAR,10)),0)>0 and ANEXO24.MA_CODIGO is not null then round(SUM((KARDESPED.KAP_CANTDESC * PEDIMPDET.PID_COS_UNIGEN) - 
				((KARDESPED.KAP_CANTDESC * PEDIMPDET.PID_COS_UNIGEN) / (isnull(ANEXO24.ANX_VID_YEAR,10) * 365))* convert(int,GETDATE() - PEDIMP.PI_FEC_ENT)),6) 
				else round(SUM(KARDESPED.KAP_CANTDESC * ISNULL(PEDIMPDET.PID_COS_UNIGEN, 0)),6) end, PEDIMPDET.ME_CODIGO, PEDIMPDET.MA_GENERICO, 
			                      1, 1, ISNULL(PEDIMPDET.AR_IMPMX, 0), ISNULL(MAESTRO_2.AR_IMPFO, 0), 
			                      dbo.GetAdvalorem(MAESTRO_2.AR_IMPFO, 0, 'G', 0, 0), case when @Vencido='S' then 0 else PEDIMPDET.PID_SEC_IMP end, 'PID_DEF_TIP'=case when @Vencido='S' then 'G' else isnull(PEDIMPDET.PID_DEF_TIP, 'G') end,
				         'PID_POR_DEF'=case when @Vencido='S' then dbo.GetAdvalorem(PEDIMPDET.AR_IMPMX, 0, 'G', 0, 0) else PEDIMPDET.PID_POR_DEF end, 
			                      ISNULL(PEDIMPDET.TI_CODIGO, 10), PEDIMPDET.PA_ORIGEN, case when @Vencido='S' then 0 else PEDIMPDET.SPI_CODIGO end, (SELECT CF_PAIS_MX FROM CONFIGURACION), 
			                      max(PEDIMPDET.ME_GENERICO), max(PEDIMPDET.ME_ARIMPMX), round(SUM(KARDESPED.KAP_CANTDESC),6), round(SUM((KARDESPED.KAP_CANTDESC/isnull(PEDIMPDET.EQ_GENERICO,1))* isnull(PEDIMPDET.EQ_IMPMX,1)),6), 0, 0, PEDIMP.PI_FEC_ENT,
					isnull(MAESTRO_2.MA_NOPARTEAUX,''),
				    'PID_CTOT_MN'=case when @PI_USA_TIP_CAMFACT<>'S' then round(SUM(KARDESPED.KAP_CANTDESC * ISNULL(PEDIMPDET.PID_COS_UNIGEN * @PI_TIP_CAM, 0)),6) else round(SUM(KARDESPED.KAP_CANTDESC * ISNULL(PEDIMPDET.PID_COS_UNIGEN * FACTEXP.FE_TIPOCAMBIO, 0)),6) end,
				PEDIMPDET.PI_CODIGO, MAX(PID_PES_UNIKG), FACTEXPDET.FE_CODIGO
			FROM         KARDESPED LEFT OUTER JOIN
			                      PEDIMPDET LEFT OUTER JOIN
			                      PEDIMP ON PEDIMPDET.PI_CODIGO = PEDIMP.PI_CODIGO ON 
			                      KARDESPED.KAP_INDICED_PED = PEDIMPDET.PID_INDICED RIGHT OUTER JOIN
			                      FACTEXPDET ON KARDESPED.KAP_INDICED_FACT = FACTEXPDET.FED_INDICED LEFT OUTER JOIN
			                      MAESTRO MAESTRO_2 ON KARDESPED.MA_HIJO = MAESTRO_2.MA_CODIGO RIGHT OUTER JOIN
			                      FACTEXP ON FACTEXPDET.FE_CODIGO = FACTEXP.FE_CODIGO LEFT OUTER JOIN 
				         ANEXO24 ON PEDIMPDET.MA_CODIGO = ANEXO24.MA_CODIGO
			WHERE     (FACTEXP.PI_CODIGO = @picodigo or (FACTEXP.PI_CODIGO = @picodigo and
					KARDESPED.KAP_INDICED_PED IN
					(SELECT     FACTEXPDET.FED_INDICED
					FROM         PEDIMPRELTRANS INNER JOIN
					                      PEDIMPDET ON PEDIMPRELTRANS.PID_INDICED = PEDIMPDET.PID_INDICED INNER JOIN
					                      FACTEXPDET ON PEDIMPRELTRANS.FED_INDICED = FACTEXPDET.FED_INDICED
					WHERE     PEDIMPDET.PID_REGIONFIN = 'M' GROUP BY FACTEXPDET.FED_INDICED)))
					 AND (KARDESPED.MA_HIJO IS NOT NULL) AND (PEDIMP.PI_TIPO<>'T')
			GROUP BY KARDESPED.MA_HIJO, PEDIMPDET.PID_NOPARTE, PEDIMPDET.PID_COS_UNIGEN, 
			                      PEDIMPDET.MA_GENERICO, PEDIMPDET.AR_IMPMX, 
			                      MAESTRO_2.AR_IMPFO, PEDIMPDET.PID_SEC_IMP, PEDIMPDET.PID_DEF_TIP, 
			                      PEDIMPDET.PID_POR_DEF, PEDIMPDET.TI_CODIGO, PEDIMPDET.PA_ORIGEN, PEDIMPDET.SPI_CODIGO, 
			                      PEDIMPDET.ME_CODIGO, PEDIMP.PI_FEC_ENT, MAESTRO_2.MA_NOPARTEAUX, PEDIMPDET.PI_CODIGO, ANEXO24.MA_CODIGO, FACTEXPDET.FE_CODIGO
			HAVING      (SUM(KARDESPED.KAP_CANTDESC) > 0)
		end
		else
		begin
			if @ccp_tipo = 'CN'
				begin
					INSERT INTO TempPedImpDetF4 (PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_COS_UNI, 
						PID_CANT, PID_CTOT_DLS, ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
						AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
						PA_PROCEDE, ME_GENERICO, ME_ARIMPMX, PID_CAN_GEN, PID_CAN_AR, PID_COS_UNIVA, PID_COS_UNIMATGRA, PI_FEC_ENTPI, 
						PID_NOPARTEAUX, PID_CTOT_MN, PID_PEDF4ORIG, PID_PES_UNIKG, PID_CODIGOFACT)
					   -- 26/Enero/2010 Manuel G. Se modifico agregando validacion para el valor de PID_CTOT_DLS, validando que exita un registro en ANEXO24 (ANEXO24.MA_CODIGO is not null) 		
  					   -- 7/Marzo/2013 Manuel G. se modifico para el pid_cant ya que el redondeo esta erroneo,
					   -- 7/Marzo/2013 Manuel G. se modifico para el pid_ctot_dls ya que la cantidad debe ser de la factura de exportacion.
					   -- 15/Marzo/2013 Manuel G. se modifico para el pid_ctot_dls poniendo nuevamente la cantidad descarga entre el factor de conversion
					   --21/Marzo/2013 Manuel G. se cambio nuevamente a lo siguiente:
					   --													* Si es F5 y tiene informacion de vida util (depreciacion), el C.U. debera tomarlo del pedimento
					   --													* Si solo es F5, sin datos de vida util, el C.U. debera tomarlo de la factura
					   --													* Si es F4, el C.U. debera tomarlo del pedimento
						
					SELECT     @picodigo, KARDESPED.MA_HIJO, PEDIMPDET.PID_NOPARTE, MAX(PEDIMPDET.PID_NOMBRE), MAX(PEDIMPDET.PID_NAME), 
										  0, 
										  SUM(KARDESPED.KAP_CANTDESC)/sum(round(isnull(PEDIMPDET.EQ_GENERICO,1),6)),
										   case when @cp_clave='F5' and isnull(max(isnull(ANEXO24.ANX_VID_YEAR,10)),0)>0 and ANEXO24.MA_CODIGO is not null then 
										   round(SUM((KARDESPED.KAP_CANTDESC * PEDIMPDET.PID_COS_UNIGEN) - 
										((KARDESPED.KAP_CANTDESC * PEDIMPDET.PID_COS_UNIGEN) / (isnull(ANEXO24.ANX_VID_YEAR,10) * 365))* convert(int,GETDATE() - PEDIMP.PI_FEC_ENT)),6) 
						else 
								--SUM(factexpdet.fed_cant/*KARDESPED.KAP_CANTDESC*/) * sum(round(ISNULL(factexpdet.fed_cos_uni, 0),6))
								--(round(SUM(pedimpdet.pid_cant)/*/ sum(factexpdet.EQ_GEN)*/,6)) * sum(round(ISNULL(factexpdet.fed_cos_uni, 0),6))
								case when @cp_clave = 'F5' then
							     SUM(KARDESPED.KAP_CANTDESC)* sum(ISNULL(factexpdet.fed_cos_uni, 0))
							     else
							     (SUM(KARDESPED.KAP_CANTDESC)/ round(sum(pedimpdet.eq_generico),6)) *  sum(ISNULL(PEDIMPDET.PID_COS_UNI, 0))
							    end
						end, 
						PEDIMPDET.ME_CODIGO, PEDIMPDET.MA_GENERICO, 
										  1, 1, ISNULL(PEDIMPDET.AR_IMPMX, 0), ISNULL(MAESTRO_2.AR_IMPFO, 0), 
										  dbo.GetAdvalorem(MAESTRO_2.AR_IMPFO, 0, 'G', 0, 0), case when @Vencido='S' then 0 else PEDIMPDET.PID_SEC_IMP end, 'PID_DEF_TIP'=case when @Vencido='S' then 'G' else isnull(PEDIMPDET.PID_DEF_TIP, 'G') end,
								 'PID_POR_DEF'=case when @Vencido='S' then dbo.GetAdvalorem(PEDIMPDET.AR_IMPMX, 0, 'G', 0, 0) else PEDIMPDET.PID_POR_DEF end, 
										  ISNULL(PEDIMPDET.TI_CODIGO, 10), PEDIMPDET.PA_ORIGEN, case when @Vencido='S' then 0 else PEDIMPDET.SPI_CODIGO end, (SELECT CF_PAIS_MX FROM CONFIGURACION), 
										  max(PEDIMPDET.ME_GENERICO), max(PEDIMPDET.ME_ARIMPMX), round(SUM(KARDESPED.KAP_CANTDESC),6), round(SUM((KARDESPED.KAP_CANTDESC/isnull(PEDIMPDET.EQ_GENERICO,1))* isnull(PEDIMPDET.EQ_IMPMX,1)),6), 0, 0, PEDIMP.PI_FEC_ENT,
							isnull(MAESTRO_2.MA_NOPARTEAUX,''),
							'PID_CTOT_MN'=case when @PI_USA_TIP_CAMFACT<>'S' 
												then 
													case when @cp_clave = 'F5' then
														round(SUM(KARDESPED.KAP_CANTDESC * ISNULL(FACTEXPDET.FED_COS_UNI * @PI_TIP_CAM, 0)),6) 
													else
														round(SUM(KARDESPED.KAP_CANTDESC * ISNULL(PEDIMPDET.PID_COS_UNIGEN * @PI_TIP_CAM, 0)),6) 
													end
												else 
													case when @cp_clave = 'F5' then
														round(SUM(KARDESPED.KAP_CANTDESC * ISNULL(FACTEXPDET.FED_COS_UNI * @PI_TIP_CAM, 0)),6) 
													else
														round(SUM(KARDESPED.KAP_CANTDESC * ISNULL(PEDIMPDET.PID_COS_UNIGEN * FACTEXP.FE_TIPOCAMBIO, 0)),6) 
													end
											end,
						PEDIMPDET.PI_CODIGO, MAX(PID_PES_UNIKG), FACTEXPDET.FE_CODIGO
					FROM         KARDESPED LEFT OUTER JOIN
										  PEDIMPDET LEFT OUTER JOIN
										  PEDIMP ON PEDIMPDET.PI_CODIGO = PEDIMP.PI_CODIGO ON 
										  KARDESPED.KAP_INDICED_PED = PEDIMPDET.PID_INDICED RIGHT OUTER JOIN
										  FACTEXPDET ON KARDESPED.KAP_INDICED_FACT = FACTEXPDET.FED_INDICED LEFT OUTER JOIN
										  MAESTRO MAESTRO_2 ON KARDESPED.MA_HIJO = MAESTRO_2.MA_CODIGO RIGHT OUTER JOIN
										  FACTEXP ON FACTEXPDET.FE_CODIGO = FACTEXP.FE_CODIGO LEFT OUTER JOIN 
								 ANEXO24 ON PEDIMPDET.MA_CODIGO = ANEXO24.MA_CODIGO
					WHERE     (FACTEXP.PI_CODIGO = @picodigo or (FACTEXP.PI_CODIGO = @picodigo and
							KARDESPED.KAP_INDICED_PED IN
							(SELECT     FACTEXPDET.FED_INDICED
							FROM         PEDIMPRELTRANS INNER JOIN
												  PEDIMPDET ON PEDIMPRELTRANS.PID_INDICED = PEDIMPDET.PID_INDICED INNER JOIN
												  FACTEXPDET ON PEDIMPRELTRANS.FED_INDICED = FACTEXPDET.FED_INDICED
							WHERE     PEDIMPDET.PID_REGIONFIN = 'M' GROUP BY FACTEXPDET.FED_INDICED)))
							 AND (KARDESPED.MA_HIJO IS NOT NULL) AND (PEDIMP.PI_TIPO<>'T')
					GROUP BY KARDESPED.MA_HIJO, PEDIMPDET.PID_NOPARTE, /*PEDIMPDET.PID_COS_UNIGEN*/factexpdet.fed_cos_uni, 
										  PEDIMPDET.MA_GENERICO, PEDIMPDET.AR_IMPMX, 
										  MAESTRO_2.AR_IMPFO, PEDIMPDET.PID_SEC_IMP, PEDIMPDET.PID_DEF_TIP, 
										  PEDIMPDET.PID_POR_DEF, PEDIMPDET.TI_CODIGO, PEDIMPDET.PA_ORIGEN, PEDIMPDET.SPI_CODIGO, 
										  PEDIMPDET.ME_CODIGO, PEDIMP.PI_FEC_ENT, MAESTRO_2.MA_NOPARTEAUX, PEDIMPDET.PI_CODIGO, ANEXO24.MA_CODIGO, FACTEXPDET.FE_CODIGO
					HAVING      (SUM(KARDESPED.KAP_CANTDESC) > 0)
				end
			else
				begin
					INSERT INTO TempPedImpDetF4 (PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_COS_UNI, 
						PID_CANT, PID_CTOT_DLS, ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
						AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
						PA_PROCEDE, ME_GENERICO, ME_ARIMPMX, PID_CAN_GEN, PID_CAN_AR, PID_COS_UNIVA, PID_COS_UNIMATGRA, 
						PI_FEC_ENTPI, PID_NOPARTEAUX, PID_CTOT_MN, PID_PEDF4ORIG, PID_PES_UNIKG, PID_CODIGOFACT)
				
					SELECT     @picodigo, KARDESPED.MA_HIJO, PEDIMPDET.PID_NOPARTE, MAX(PEDIMPDET.PID_NOMBRE), MAX(PEDIMPDET.PID_NAME), 
										  0, round(SUM(KARDESPED.KAP_CANTDESC/isnull(PEDIMPDET.EQ_GENERICO,1)),6), 
										   case when @cp_clave='F5' and isnull(max(isnull(ANEXO24.ANX_VID_YEAR,10)),0)>0 AND ANEXO24.MA_CODIGO is not null then round(SUM((KARDESPED.KAP_CANTDESC * PEDIMPDET.PID_COS_UNIGEN) - 
								((KARDESPED.KAP_CANTDESC * PEDIMPDET.PID_COS_UNIGEN) / (isnull(ANEXO24.ANX_VID_YEAR,10) * 365))* convert(int,GETDATE() - PEDIMP.PI_FEC_ENT)),6) 
								else round(SUM(KARDESPED.KAP_CANTDESC * ISNULL(PEDIMPDET.PID_COS_UNIGEN, 0)),6) end,
							 PEDIMPDET.ME_CODIGO, PEDIMPDET.MA_GENERICO, 
										  1, 1, ISNULL(PEDIMPDET.AR_IMPMX, 0), ISNULL(MAESTRO_2.AR_IMPFO, 0), 
										  dbo.GetAdvalorem(MAESTRO_2.AR_IMPFO, 0, 'G', 0, 0), case when @Vencido='S' then 0 else PEDIMPDET.PID_SEC_IMP end, 'PID_DEF_TIP'=case when @Vencido='S' then 'G' else isnull(PEDIMPDET.PID_DEF_TIP, 'G') end,
							'PID_POR_DEF'=case when @Vencido='S' then dbo.GetAdvalorem(PEDIMPDET.AR_IMPMX, 0, 'G', 0, 0) else PEDIMPDET.PID_POR_DEF end, 
										  ISNULL(PEDIMPDET.TI_CODIGO, 10), PEDIMPDET.PA_ORIGEN, case when @Vencido='S' then 0 else PEDIMPDET.SPI_CODIGO end, (SELECT CF_PAIS_MX FROM CONFIGURACION), 
										  max(PEDIMPDET.ME_GENERICO), max(PEDIMPDET.ME_ARIMPMX), round(SUM(KARDESPED.KAP_CANTDESC),6), round(SUM((KARDESPED.KAP_CANTDESC/isnull(PEDIMPDET.EQ_GENERICO,1))* isnull(PEDIMPDET.EQ_IMPMX,1)),6), 0, 0, PEDIMP.PI_FEC_ENT,
							isnull(MAESTRO_2.MA_NOPARTEAUX,''),
							'PID_CTOT_MN'=case when @PI_USA_TIP_CAMFACT<>'S' then round(SUM(KARDESPED.KAP_CANTDESC * ISNULL(PEDIMPDET.PID_COS_UNIGEN * @PI_TIP_CAM, 0)),6) else round(SUM(KARDESPED.KAP_CANTDESC * ISNULL(PEDIMPDET.PID_COS_UNIGEN * FACTEXP.FE_TIPOCAMBIO, 0)),6) end,
							PEDIMPDET.PI_CODIGO, MAX(PID_PES_UNIKG), FACTEXPDET.FE_CODIGO
					FROM         KARDESPED LEFT OUTER JOIN
										  PEDIMPDET LEFT OUTER JOIN
										  PEDIMP ON PEDIMPDET.PI_CODIGO = PEDIMP.PI_CODIGO ON 
										  KARDESPED.KAP_INDICED_PED = PEDIMPDET.PID_INDICED RIGHT OUTER JOIN
										  FACTEXPDET ON KARDESPED.KAP_INDICED_FACT = FACTEXPDET.FED_INDICED LEFT OUTER JOIN
										  MAESTRO MAESTRO_2 ON KARDESPED.MA_HIJO = MAESTRO_2.MA_CODIGO RIGHT OUTER JOIN
										  FACTEXP ON FACTEXPDET.FE_CODIGO = FACTEXP.FE_CODIGO LEFT OUTER JOIN 
								 ANEXO24 ON PEDIMPDET.MA_CODIGO = ANEXO24.MA_CODIGO
					WHERE     (FACTEXP.PI_RECTIFICA = @picodigo or (FACTEXP.PI_RECTIFICA = @picodigo and
							KARDESPED.KAP_INDICED_PED IN
							(SELECT     FACTEXPDET.FED_INDICED
							FROM         PEDIMPRELTRANS INNER JOIN
												  PEDIMPDET ON PEDIMPRELTRANS.PID_INDICED = PEDIMPDET.PID_INDICED INNER JOIN
												  FACTEXPDET ON PEDIMPRELTRANS.FED_INDICED = FACTEXPDET.FED_INDICED
							WHERE     PEDIMPDET.PID_REGIONFIN = 'M' GROUP BY FACTEXPDET.FED_INDICED)))
							 AND (KARDESPED.MA_HIJO IS NOT NULL) AND (PEDIMP.PI_TIPO<>'T')
					GROUP BY KARDESPED.MA_HIJO, PEDIMPDET.PID_NOPARTE, PEDIMPDET.PID_COS_UNIGEN, 
										  PEDIMPDET.MA_GENERICO, PEDIMPDET.AR_IMPMX, 
										  MAESTRO_2.AR_IMPFO, PEDIMPDET.PID_SEC_IMP, PEDIMPDET.PID_DEF_TIP, 
										  PEDIMPDET.PID_POR_DEF, PEDIMPDET.TI_CODIGO, PEDIMPDET.PA_ORIGEN, PEDIMPDET.SPI_CODIGO, 
										  PEDIMPDET.ME_CODIGO, PEDIMP.PI_FEC_ENT, MAESTRO_2.MA_NOPARTEAUX, PEDIMPDET.PI_CODIGO, ANEXO24.MA_CODIGO, FACTEXPDET.FE_CODIGO
					HAVING      (SUM(KARDESPED.KAP_CANTDESC) > 0)
				end
		end

	end	





	update TempPedImpDetF4  
	set EQ_GENERICO= round(PID_CAN_GEN/PID_CANT,6),
	 EQ_IMPMX=round(PID_CAN_AR/PID_CANT,6)
	where PID_CANT >0


	update TempPedImpDetF4 
	set eq_generico=1
	where eq_generico=0

	


	update TempPedImpDetF4 
	set PID_COS_UNI=round(PID_CTOT_DLS/PID_CANT,6),
	PID_COS_UNIgen= round((PID_CTOT_DLS/PID_CANT)/ EQ_GENERICO,6),
	PID_COS_UNIADU= round(((PID_CTOT_MN/PID_CANT) / isnull(EQ_GENERICO,1)) * @pi_ft_adu,6),	
	--5-Jul-2011 Manuel G. el valor aduana no lo generaba correctamente al cuando se descargaba UM diferentes
	--PID_VAL_ADU= round(PID_CTOT_MN * EQ_GENERICO * @pi_ft_adu,0)
	PID_VAL_ADU= round(PID_CTOT_DLS * @pi_tip_cam * @pi_ft_adu,0)
	where PID_CANT >0 and pi_codigo=@picodigo


	update TempPedImpDetF4 
	set PID_COS_UNI=PID_CTOT_DLS,
	PID_COS_UNIADU= round(((PID_CTOT_MN) / EQ_GENERICO) * @pi_ft_adu,6),
	PID_COS_UNIgen= round((PID_CTOT_DLS)* EQ_GENERICO,6),
	PID_VAL_ADU= round(PID_CTOT_MN * EQ_GENERICO * @pi_ft_adu,0)
	where PID_CANT =0 and pi_codigo=@picodigo




	update TemppedimpdetF4
	set pid_saldogen = 0
	where pi_codigo=@picodigo



--===================================== 2do cursor para agrupacion ========================================

	--if (SELECT CF_USASALDOPEDIMPDEFINITO FROM CONFIGURACION)='S'
	begin
		if @ccp_tipo='RE' and (select PI_GENERASALDOF4 from pedimp where pi_codigo in (select pi_rectifica from pedimp where pi_codigo=@picodigo))='S'
			exec FillPIDescarga @picodigo, @user
		else 
		if  (select PI_GENERASALDOF4 from pedimp where pi_codigo=@picodigo)='S'
			exec FillPIDescarga @picodigo, @user
	end


	exec sp_CalculaTPago @picodigo, 'E'


	exec ReemplazaDescargasR1 @picodigo, @user, @ccp_tipo


select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)
	insert into intradeglobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
	values (@user, 2, 'Llenando detalle Pedimento ', 'Filling Detail Pedimento ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)

	
	INSERT INTO PEDIMPDET(PI_CODIGO, PID_INDICED, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_COS_UNI, PID_COS_UNIADU, PID_COS_UNIGEN, 
	                      PID_COS_UNIVA, PID_COS_UNIMATGRA, PID_CANT, PID_CAN_AR, PID_CAN_GEN, PID_VAL_ADU, PID_CTOT_DLS, 
	                      ME_CODIGO, ME_GENERICO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, AR_IMPMX, ME_ARIMPMX, AR_EXPFO, 
	                      PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, CS_CODIGO, TI_CODIGO, PA_ORIGEN, PA_PROCEDE, 
	                      SPI_CODIGO, PR_CODIGO, PID_IMPRIMIR, PID_DESCARGABLE, PID_NOPARTEAUX, PID_SECUENCIA, PID_CTOT_MN, PID_PEDF4ORIG, PG_CODIGO, PID_PES_UNIKG, PID_CODIGOFACT)
	
	SELECT PI_CODIGO, PID_INDICED+@maximo, MA_CODIGO, PID_NOPARTE, max(PID_NOMBRE), max(PID_NAME), PID_COS_UNI, PID_COS_UNIADU, PID_COS_UNIGEN, 
	              PID_COS_UNIVA, PID_COS_UNIMATGRA, sum(PID_CANT), sum(PID_CAN_AR), sum(PID_CAN_GEN), sum(PID_VAL_ADU), sum(PID_CTOT_DLS), 
	              max(ME_CODIGO), max(ME_GENERICO), MA_GENERICO, EQ_GENERICO, EQ_IMPMX, AR_IMPMX, max(ME_ARIMPMX), AR_EXPFO, 
	              PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, CS_CODIGO, max(TI_CODIGO), PA_ORIGEN, PA_PROCEDE, 
	             SPI_CODIGO, PR_CODIGO, PID_IMPRIMIR, PID_DESCARGABLE, PID_NOPARTEAUX, PID_INDICED, SUM(PID_CTOT_MN), PID_PEDF4ORIG, PG_CODIGO, PID_PES_UNIKG, PID_CODIGOFACT
	FROM TempPedImpDetF4 
	WHERE PI_CODIGO=@picodigo
	GROUP BY PI_CODIGO, PID_INDICED, MA_CODIGO, PID_NOPARTE, PID_COS_UNI, PID_COS_UNIADU, PID_COS_UNIGEN, 
	              PID_COS_UNIVA, PID_COS_UNIMATGRA, 
	              MA_GENERICO, EQ_GENERICO, EQ_IMPMX, AR_IMPMX, AR_EXPFO, 
	              PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, CS_CODIGO, PA_ORIGEN, PA_PROCEDE, 
	               SPI_CODIGO, PR_CODIGO, PID_IMPRIMIR, PID_DESCARGABLE, PID_NOPARTEAUX, PID_PEDF4ORIG, PG_CODIGO, PID_PES_UNIKG, PID_CODIGOFACT


	ALTER TABLE PEDIMPDET ENABLE TRIGGER insert_pedimpdet

select @Pid_indiced= max(pid_indiced) from pedimpdet


	update consecutivo
	set cv_codigo =  isnull(@pid_indiced,0) + 1
	where cv_tipo = 'PID'

--liga los detalles de pedimentos
EXEC LigaPedDetalle @picodigo
GO
