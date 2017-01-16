SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.[fillpedimpdetBPa] (@picodigo int, @pi_movimiento char(1), @user int)   as

SET NOCOUNT ON 
declare   @FechaActual VARCHAR(10), @hora varchar(15), @em_codigo int, @CCP_TIPO varchar(5), @CF_PAGOCONTRIBUCION CHAR(1)

	SET @FechaActual = convert(varchar(10), getdate(),101)

	select @em_codigo=em_codigo from intradeglobal.dbo.empresa where em_corto in
	(select replace(convert(sysname,db_name()),'intrade',''))

	select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

	insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
	values (@user, 2, 'Llenando tabla temporal de agrupacion SAAI ', 'Filling SAAI Group temporary table ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)


	SELECT @CCP_TIPO=CCP_TIPO FROM CONFIGURACLAVEPED WHERE CP_CODIGO
	IN (SELECT CP_CODIGO FROM PEDIMP WHERE PI_CODIGO=@picodigo)


	SELECT @CF_PAGOCONTRIBUCION=CF_PAGOCONTRIBUCION FROM CONFIGURACION


	TRUNCATE TABLE temppedimpdetb 

	dbcc checkident (TempPedimpdetb, reseed, 1) WITH NO_INFOMSGS


	If @pi_movimiento='E'
	begin
		IF (SELECT PICF_SAAIDETDIVFACT FROM PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='S'
		begin--2
			IF (SELECT PICF_SAAIDIVDESC from PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='N'
			begin--3
				insert into TempPEDIMPDETB ( PI_CODIGO, MA_GENERICO, AR_IMPMX, ME_ARIMPMX, ME_GENERICO, PIB_CAN_GEN, PIB_CAN_AR, 
					PA_PROCEDE, ES_ORIGEN, ES_DESTINO, ES_COMPRADOR, ES_VENDEDOR, PIB_VAL_ADU, PIB_VAL_US, 
					 PIB_VAL_FAC,  AR_EXPFO, PIB_RATEEXPFO, PIB_COS_UNIGRA, PIB_COS_UNIVA, EQ_EXPFO,
					PIB_CANT, PIB_POR_DEF, PIB_DESTNAFTA, PA_ORIGEN, PIB_NOMBRE, PIB_PAGACONTRIB, PIB_SEC_IMP, PIB_DEF_TIP, 
					SPI_CODIGO, PIB_CTOT_MN, PIB_VAL_RET, PIB_GENERA_EMPDET, PIB_SERVICIO, PIB_CODIGOFACT)
		
				SELECT     @picodigo, MA_GENERICO, AR_IMPMX, MAX(ME_ARIMPMX), MAX(ME_GENERICO), round(SUM(PID_CAN_GEN),3), 
				                      round(SUM(PID_CAN_AR),3), max(PA_PROCEDE), max(ES_ORIGEN), max(ES_DESTINO), max(ES_COMPRADOR), max(ES_VENDEDOR), 0 
				                      , SUM(PID_CTOT_DLS), 0, max(AR_EXPFO), max(PID_RATEEXPFO), 
						'a'=case when SUM(PID_CANT)>0 then sum(PIB_COS_UNIGRA*PID_CANT)/SUM(PID_CANT) else 0 end, 
						case when SUM(PID_CANT)>0 then round(sum(PID_COS_UNIVA*PID_CANT)/sum(PID_CANT),6) else 0 end, 
					         EQ_EXPFO, round(sum(PID_CANT),3), PID_POR_DEF, PIB_DESTNAFTA, 
				                      PA_ORIGEN, UPPER(MAX(PID_NOMBRE)), PID_PAGACONTRIB, PID_SEC_IMP, PID_DEF_TIP, SPI_CODIGO, SUM(PID_CTOT_MN), SUM(PID_VAL_RET),
						PIB_GENERA_EMPDET, PID_SERVICIO, PID_CODIGOFACT
				FROM         VFillPedImpDetB
				WHERE     PI_CODIGO = @picodigo
				GROUP BY MA_GENERICO, AR_IMPMX, 
				                      EQ_EXPFO, PID_POR_DEF, PIB_DESTNAFTA, PA_ORIGEN, AR_FRACCION, PID_PAGACONTRIB, PID_SEC_IMP, PID_DEF_TIP, SPI_CODIGO,
					        PA_SAAIM3, IDENTIFICADOR, ME_CLA_PED, PIB_GENERA_EMPDET, PID_SERVICIO, PID_CODIGOFACT
				ORDER BY PID_CODIGOFACT, AR_FRACCION, UPPER(MAX(PID_NOMBRE)), PA_SAAIM3, IDENTIFICADOR, ME_CLA_PED, AR_IMPMX, MA_GENERICO
			end--3
			else
			begin--4
				insert into TempPEDIMPDETB ( PI_CODIGO, MA_GENERICO, AR_IMPMX, ME_ARIMPMX, ME_GENERICO, PIB_CAN_GEN, PIB_CAN_AR, 
					PA_PROCEDE, ES_ORIGEN, ES_DESTINO, ES_COMPRADOR, ES_VENDEDOR, PIB_VAL_ADU, PIB_VAL_US, 
					 PIB_VAL_FAC,  AR_EXPFO, PIB_RATEEXPFO, PIB_COS_UNIGRA, PIB_COS_UNIVA, EQ_EXPFO,
					PIB_CANT, PIB_POR_DEF, PIB_DESTNAFTA, PA_ORIGEN, PIB_NOMBRE, PIB_PAGACONTRIB, PIB_SEC_IMP, PIB_DEF_TIP, 
					SPI_CODIGO, PIB_CTOT_MN, PIB_VAL_RET, PIB_GENERA_EMPDET, PIB_SERVICIO, PIB_CODIGOFACT)
		
				SELECT     @picodigo, MA_GENERICO, AR_IMPMX, MAX(ME_ARIMPMX), MAX(ME_GENERICO), round(SUM(PID_CAN_GEN),3), 
				                      round(SUM(PID_CAN_AR),3), max(PA_PROCEDE), max(ES_ORIGEN), max(ES_DESTINO), max(ES_COMPRADOR), max(ES_VENDEDOR),0
				                      , SUM(PID_CTOT_DLS), 0, max(AR_EXPFO), max(PID_RATEEXPFO), 
						'a'=case when SUM(PID_CANT)>0 then sum(PIB_COS_UNIGRA*PID_CANT)/SUM(PID_CANT) else 0 end, 
						case when SUM(PID_CANT)>0 then round(sum(PID_COS_UNIVA*PID_CANT)/sum(PID_CANT),6) else 0 end, 
						EQ_EXPFO, round(sum(PID_CANT),3), PID_POR_DEF, PIB_DESTNAFTA, 
				                      PA_ORIGEN, UPPER(PID_NOMBRE), PID_PAGACONTRIB, PID_SEC_IMP, PID_DEF_TIP, SPI_CODIGO, SUM(PID_CTOT_MN), SUM(PID_VAL_RET), PIB_GENERA_EMPDET,
						PID_SERVICIO, PID_CODIGOFACT
				FROM         VFillPedImpDetB
				WHERE     PI_CODIGO = @picodigo
				GROUP BY MA_GENERICO, AR_IMPMX, 
				                      EQ_EXPFO, PID_POR_DEF, PIB_DESTNAFTA, PA_ORIGEN, AR_FRACCION, PID_PAGACONTRIB, PID_SEC_IMP, PID_DEF_TIP, SPI_CODIGO, UPPER(PID_NOMBRE),
					        PA_SAAIM3, IDENTIFICADOR, ME_CLA_PED, PIB_GENERA_EMPDET, PID_SERVICIO, PID_CODIGOFACT
				ORDER BY PID_CODIGOFACT, AR_FRACCION, UPPER(PID_NOMBRE), PA_SAAIM3, IDENTIFICADOR, ME_CLA_PED, AR_IMPMX, MA_GENERICO
	
			end--4

		end--2
		else -- sin agrupacion por factura
		begin
			IF (SELECT PICF_SAAIDIVDESC from PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='N'
			begin
				insert into TempPEDIMPDETB ( PI_CODIGO, MA_GENERICO, AR_IMPMX, ME_ARIMPMX, ME_GENERICO, PIB_CAN_GEN, PIB_CAN_AR, 
					PA_PROCEDE, ES_ORIGEN, ES_DESTINO, ES_COMPRADOR, ES_VENDEDOR, PIB_VAL_ADU, PIB_VAL_US, 
					 PIB_VAL_FAC,  AR_EXPFO, PIB_RATEEXPFO, PIB_COS_UNIGRA, PIB_COS_UNIVA, EQ_EXPFO,
					PIB_CANT, PIB_POR_DEF, PIB_DESTNAFTA, PA_ORIGEN, PIB_NOMBRE, PIB_PAGACONTRIB, PIB_SEC_IMP, PIB_DEF_TIP, 
					SPI_CODIGO, PIB_CTOT_MN, PIB_VAL_RET, PIB_GENERA_EMPDET, PIB_SERVICIO)
		
				SELECT     @picodigo, MA_GENERICO, AR_IMPMX, MAX(ME_ARIMPMX), MAX(ME_GENERICO), round(SUM(PID_CAN_GEN),3), 
				                      round(SUM(PID_CAN_AR),3), max(PA_PROCEDE), max(ES_ORIGEN), max(ES_DESTINO), max(ES_COMPRADOR), max(ES_VENDEDOR), 0 
				                      , SUM(PID_CTOT_DLS), 0, max(AR_EXPFO), max(PID_RATEEXPFO), 
						'a'=case when SUM(PID_CANT)>0 then sum(PIB_COS_UNIGRA*PID_CANT)/SUM(PID_CANT) else 0 end, 
						case when SUM(PID_CANT)>0 then round(sum(PID_COS_UNIVA*PID_CANT)/sum(PID_CANT),6) else 0 end, 
					         EQ_EXPFO, round(sum(PID_CANT),3), PID_POR_DEF, PIB_DESTNAFTA, 
				                      PA_ORIGEN, UPPER(MAX(PID_NOMBRE)), PID_PAGACONTRIB, PID_SEC_IMP, PID_DEF_TIP, SPI_CODIGO, SUM(PID_CTOT_MN), SUM(PID_VAL_RET),
						PIB_GENERA_EMPDET, PID_SERVICIO
				FROM         VFillPedImpDetB
				WHERE     PI_CODIGO = @picodigo
				GROUP BY MA_GENERICO, AR_IMPMX, 
				                      EQ_EXPFO, PID_POR_DEF, PIB_DESTNAFTA, PA_ORIGEN, AR_FRACCION, PID_PAGACONTRIB, PID_SEC_IMP, PID_DEF_TIP, SPI_CODIGO,
					        PA_SAAIM3, IDENTIFICADOR, ME_CLA_PED, PIB_GENERA_EMPDET, PID_SERVICIO
				ORDER BY AR_FRACCION, UPPER(MAX(PID_NOMBRE)), PA_SAAIM3, IDENTIFICADOR, ME_CLA_PED, AR_IMPMX, MA_GENERICO
			end
			else
			begin
				insert into TempPEDIMPDETB ( PI_CODIGO, MA_GENERICO, AR_IMPMX, ME_ARIMPMX, ME_GENERICO, PIB_CAN_GEN, PIB_CAN_AR, 
					PA_PROCEDE, ES_ORIGEN, ES_DESTINO, ES_COMPRADOR, ES_VENDEDOR, PIB_VAL_ADU, PIB_VAL_US, 
					 PIB_VAL_FAC,  AR_EXPFO, PIB_RATEEXPFO, PIB_COS_UNIGRA, PIB_COS_UNIVA, EQ_EXPFO,
					PIB_CANT, PIB_POR_DEF, PIB_DESTNAFTA, PA_ORIGEN, PIB_NOMBRE, PIB_PAGACONTRIB, PIB_SEC_IMP, PIB_DEF_TIP, 
					SPI_CODIGO, PIB_CTOT_MN, PIB_VAL_RET, PIB_GENERA_EMPDET, PIB_SERVICIO)
		
				SELECT     @picodigo, MA_GENERICO, AR_IMPMX, MAX(ME_ARIMPMX), MAX(ME_GENERICO), round(SUM(PID_CAN_GEN),3), 
				                      round(SUM(PID_CAN_AR),3), max(PA_PROCEDE), max(ES_ORIGEN), max(ES_DESTINO), max(ES_COMPRADOR), max(ES_VENDEDOR),0
				                      , SUM(PID_CTOT_DLS), 0, max(AR_EXPFO), max(PID_RATEEXPFO), 
						'a'=case when SUM(PID_CANT)>0 then sum(PIB_COS_UNIGRA*PID_CANT)/SUM(PID_CANT) else 0 end, 
						case when SUM(PID_CANT)>0 then round(sum(PID_COS_UNIVA*PID_CANT)/sum(PID_CANT),6) else 0 end, 
						EQ_EXPFO, round(sum(PID_CANT),3), PID_POR_DEF, PIB_DESTNAFTA, 
				                      PA_ORIGEN, UPPER(PID_NOMBRE), PID_PAGACONTRIB, PID_SEC_IMP, PID_DEF_TIP, SPI_CODIGO, SUM(PID_CTOT_MN), SUM(PID_VAL_RET), PIB_GENERA_EMPDET,
						PID_SERVICIO
				FROM         VFillPedImpDetB
				WHERE     PI_CODIGO = @picodigo
				GROUP BY MA_GENERICO, AR_IMPMX, 
				                      EQ_EXPFO, PID_POR_DEF, PIB_DESTNAFTA, PA_ORIGEN, AR_FRACCION, PID_PAGACONTRIB, PID_SEC_IMP, PID_DEF_TIP, SPI_CODIGO, UPPER(PID_NOMBRE),
					        PA_SAAIM3, IDENTIFICADOR, ME_CLA_PED, PIB_GENERA_EMPDET, PID_SERVICIO
				ORDER BY AR_FRACCION, UPPER(PID_NOMBRE), PA_SAAIM3, IDENTIFICADOR, ME_CLA_PED, AR_IMPMX, MA_GENERICO
	
			end
		end
	end
	else	begin
		-- en el pago a la entrada no se toma en cuenta la fraccion usa para la agrupacion
		if @CF_PAGOCONTRIBUCION='E' 
		begin

			IF (SELECT PICF_SAAIDETDIVFACT FROM PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='S'
			begin--3
	
				IF (SELECT PICF_SAAIDIVDESC from PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='N'
				begin--4
					insert into TempPEDIMPDETB ( PI_CODIGO, MA_GENERICO, AR_IMPMX, ME_ARIMPMX, ME_GENERICO, PIB_CAN_GEN, PIB_CAN_AR, 
						PA_PROCEDE, ES_ORIGEN, ES_DESTINO, ES_COMPRADOR, ES_VENDEDOR, PIB_VAL_ADU, PIB_VAL_US, 
						 PIB_VAL_FAC,  AR_EXPFO, PIB_RATEEXPFO, PIB_COS_UNIGRA, PIB_COS_UNIVA, EQ_EXPFO,
						PIB_CANT, PIB_POR_DEF, PIB_DESTNAFTA, PA_ORIGEN, PIB_NOMBRE, PIB_PAGACONTRIB, PIB_SEC_IMP, PIB_DEF_TIP, 
						SPI_CODIGO, PIB_CTOT_MN, PIB_VAL_RET, PIB_GENERA_EMPDET, PIB_SERVICIO, PIB_CODIGOFACT)
			
					SELECT     @picodigo, MA_GENERICO, AR_IMPMX, MAX(ME_ARIMPMX), MAX(ME_GENERICO), round(SUM(PID_CAN_GEN),3), 
					                      round(SUM(PID_CAN_AR),3), max(PA_PROCEDE), max(ES_ORIGEN), max(ES_DESTINO), max(ES_COMPRADOR), max(ES_VENDEDOR), 0
					                      , SUM(PID_CTOT_DLS), 0, max(AR_EXPFO), max(PID_RATEEXPFO), 
							'a'=case when SUM(PID_CANT)>0 then sum(PIB_COS_UNIGRA*PID_CANT)/SUM(PID_CANT) else 0 end, 
							case when SUM(PID_CANT)>0 then round(sum(PID_COS_UNIVA*PID_CANT)/sum(PID_CANT),6) else 0 end,
							 EQ_EXPFO, round(sum(PID_CANT),3), PID_POR_DEF, PIB_DESTNAFTA, 
					                      PA_ORIGEN, UPPER(MAX(PID_NOMBRE)), PID_PAGACONTRIB, max(PID_SEC_IMP), max(PID_DEF_TIP), max(SPI_CODIGO), SUM(PID_CTOT_MN), SUM(PID_VAL_RET), PIB_GENERA_EMPDET,
							PID_SERVICIO, PID_CODIGOFACT
					FROM         VFillPedImpDetB
					WHERE     PI_CODIGO = @picodigo
					GROUP BY MA_GENERICO, AR_IMPMX, EQ_EXPFO, PID_POR_DEF, PIB_DESTNAFTA, PA_ORIGEN, AR_FRACCION, PID_PAGACONTRIB,
						        PA_SAAIM3, IDENTIFICADOR, ME_CLA_PED, PIB_GENERA_EMPDET, PID_SERVICIO, PID_CODIGOFACT
					ORDER BY PID_CODIGOFACT, AR_FRACCION, UPPER(MAX(PID_NOMBRE)), PA_SAAIM3, IDENTIFICADOR, ME_CLA_PED, AR_IMPMX, MA_GENERICO
				end--4
				else
				begin--5
					insert into TempPEDIMPDETB ( PI_CODIGO, MA_GENERICO, AR_IMPMX, ME_ARIMPMX, ME_GENERICO, PIB_CAN_GEN, PIB_CAN_AR, 
						PA_PROCEDE, ES_ORIGEN, ES_DESTINO, ES_COMPRADOR, ES_VENDEDOR, PIB_VAL_ADU, PIB_VAL_US, 
						 PIB_VAL_FAC,  AR_EXPFO, PIB_RATEEXPFO, PIB_COS_UNIGRA, PIB_COS_UNIVA, EQ_EXPFO,
						PIB_CANT, PIB_POR_DEF, PIB_DESTNAFTA, PA_ORIGEN, PIB_NOMBRE, PIB_PAGACONTRIB, PIB_SEC_IMP, PIB_DEF_TIP, 
						SPI_CODIGO, PIB_CTOT_MN, PIB_VAL_RET, PIB_GENERA_EMPDET, PIB_SERVICIO, PIB_CODIGOFACT)
			
					SELECT     @picodigo, MA_GENERICO, AR_IMPMX, MAX(ME_ARIMPMX), MAX(ME_GENERICO), round(SUM(PID_CAN_GEN),3), 
					                      round(SUM(PID_CAN_AR),3), max(PA_PROCEDE), max(ES_ORIGEN), max(ES_DESTINO), max(ES_COMPRADOR), max(ES_VENDEDOR), 0 
					                      , SUM(PID_CTOT_DLS), 0, max(AR_EXPFO), max(PID_RATEEXPFO), 
							'a'=case when SUM(PID_CANT)>0 then sum(PIB_COS_UNIGRA*PID_CANT)/SUM(PID_CANT) else 0 end, 
							case when SUM(PID_CANT)>0 then round(sum(PID_COS_UNIVA*PID_CANT)/sum(PID_CANT),6) else 0 end, 
							EQ_EXPFO, round(sum(PID_CANT),3), PID_POR_DEF, PIB_DESTNAFTA, 
					                      PA_ORIGEN, UPPER(PID_NOMBRE), PID_PAGACONTRIB, max(PID_SEC_IMP), max(PID_DEF_TIP), max(SPI_CODIGO), SUM(PID_CTOT_MN), SUM(PID_VAL_RET), PIB_GENERA_EMPDET,
							PID_SERVICIO, PID_CODIGOFACT
					FROM         VFillPedImpDetB
					WHERE     PI_CODIGO = @picodigo
					GROUP BY MA_GENERICO, AR_IMPMX, 
					                      EQ_EXPFO, PID_POR_DEF, PIB_DESTNAFTA, PA_ORIGEN, AR_FRACCION, PID_PAGACONTRIB, UPPER(PID_NOMBRE),
						        PA_SAAIM3, IDENTIFICADOR, ME_CLA_PED, PIB_GENERA_EMPDET, PID_SERVICIO, PID_CODIGOFACT
					ORDER BY PID_CODIGOFACT, AR_FRACCION, UPPER(PID_NOMBRE), PA_SAAIM3, IDENTIFICADOR, ME_CLA_PED, AR_IMPMX, MA_GENERICO
				end--5
			end--3
			else -- sin agrupacion por factura
			begin
				IF (SELECT PICF_SAAIDIVDESC from PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='N'
				begin
					insert into TempPEDIMPDETB ( PI_CODIGO, MA_GENERICO, AR_IMPMX, ME_ARIMPMX, ME_GENERICO, PIB_CAN_GEN, PIB_CAN_AR, 
						PA_PROCEDE, ES_ORIGEN, ES_DESTINO, ES_COMPRADOR, ES_VENDEDOR, PIB_VAL_ADU, PIB_VAL_US, 
						 PIB_VAL_FAC,  AR_EXPFO, PIB_RATEEXPFO, PIB_COS_UNIGRA, PIB_COS_UNIVA, EQ_EXPFO,
						PIB_CANT, PIB_POR_DEF, PIB_DESTNAFTA, PA_ORIGEN, PIB_NOMBRE, PIB_PAGACONTRIB, PIB_SEC_IMP, PIB_DEF_TIP, 
						SPI_CODIGO, PIB_CTOT_MN, PIB_VAL_RET, PIB_GENERA_EMPDET, PIB_SERVICIO)
			
					SELECT     @picodigo, MA_GENERICO, AR_IMPMX, MAX(ME_ARIMPMX), MAX(ME_GENERICO), round(SUM(PID_CAN_GEN),3), 
					                      round(SUM(PID_CAN_AR),3), max(PA_PROCEDE), max(ES_ORIGEN), max(ES_DESTINO), max(ES_COMPRADOR), max(ES_VENDEDOR), 0
					                      , SUM(PID_CTOT_DLS), 0, max(AR_EXPFO), max(PID_RATEEXPFO), 
							'a'=case when SUM(PID_CANT)>0 then sum(PIB_COS_UNIGRA*PID_CANT)/SUM(PID_CANT) else 0 end, 
							case when SUM(PID_CANT)>0 then round(sum(PID_COS_UNIVA*PID_CANT)/sum(PID_CANT),6) else 0 end,
							 EQ_EXPFO, round(sum(PID_CANT),3), PID_POR_DEF, PIB_DESTNAFTA, 
					                      PA_ORIGEN, UPPER(MAX(PID_NOMBRE)), PID_PAGACONTRIB, max(PID_SEC_IMP), max(PID_DEF_TIP), max(SPI_CODIGO), SUM(PID_CTOT_MN), SUM(PID_VAL_RET), PIB_GENERA_EMPDET,
							PID_SERVICIO
					FROM         VFillPedImpDetB
					WHERE     PI_CODIGO = @picodigo
					GROUP BY MA_GENERICO, AR_IMPMX, 
					                      EQ_EXPFO, PID_POR_DEF, PIB_DESTNAFTA, PA_ORIGEN, AR_FRACCION, PID_PAGACONTRIB,
						        PA_SAAIM3, IDENTIFICADOR, ME_CLA_PED, PIB_GENERA_EMPDET, PID_SERVICIO
					ORDER BY AR_FRACCION, UPPER(MAX(PID_NOMBRE)), PA_SAAIM3, IDENTIFICADOR, ME_CLA_PED, AR_IMPMX, MA_GENERICO
				end
				else
				begin
					insert into TempPEDIMPDETB ( PI_CODIGO, MA_GENERICO, AR_IMPMX, ME_ARIMPMX, ME_GENERICO, PIB_CAN_GEN, PIB_CAN_AR, 
						PA_PROCEDE, ES_ORIGEN, ES_DESTINO, ES_COMPRADOR, ES_VENDEDOR, PIB_VAL_ADU, PIB_VAL_US, 
						 PIB_VAL_FAC,  AR_EXPFO, PIB_RATEEXPFO, PIB_COS_UNIGRA, PIB_COS_UNIVA, EQ_EXPFO,
						PIB_CANT, PIB_POR_DEF, PIB_DESTNAFTA, PA_ORIGEN, PIB_NOMBRE, PIB_PAGACONTRIB, PIB_SEC_IMP, PIB_DEF_TIP, 
						SPI_CODIGO, PIB_CTOT_MN, PIB_VAL_RET, PIB_GENERA_EMPDET, PIB_SERVICIO)
			
					SELECT     @picodigo, MA_GENERICO, AR_IMPMX, MAX(ME_ARIMPMX), MAX(ME_GENERICO), round(SUM(PID_CAN_GEN),3), 
					                      round(SUM(PID_CAN_AR),3), max(PA_PROCEDE), max(ES_ORIGEN), max(ES_DESTINO), max(ES_COMPRADOR), max(ES_VENDEDOR), 0 
					                      , SUM(PID_CTOT_DLS), 0, max(AR_EXPFO), max(PID_RATEEXPFO), 
							'a'=case when SUM(PID_CANT)>0 then sum(PIB_COS_UNIGRA*PID_CANT)/SUM(PID_CANT) else 0 end, 
							case when SUM(PID_CANT)>0 then round(sum(PID_COS_UNIVA*PID_CANT)/sum(PID_CANT),6) else 0 end, 
							EQ_EXPFO, round(sum(PID_CANT),3), PID_POR_DEF, PIB_DESTNAFTA, 
					                      PA_ORIGEN, UPPER(PID_NOMBRE), PID_PAGACONTRIB, max(PID_SEC_IMP), max(PID_DEF_TIP), max(SPI_CODIGO), SUM(PID_CTOT_MN), SUM(PID_VAL_RET), PIB_GENERA_EMPDET,
							PID_SERVICIO
					FROM         VFillPedImpDetB
					WHERE     PI_CODIGO = @picodigo
					GROUP BY MA_GENERICO, AR_IMPMX, 
					                      EQ_EXPFO, PID_POR_DEF, PIB_DESTNAFTA, PA_ORIGEN, AR_FRACCION, PID_PAGACONTRIB, UPPER(PID_NOMBRE),
						        PA_SAAIM3, IDENTIFICADOR, ME_CLA_PED, PIB_GENERA_EMPDET, PID_SERVICIO
					ORDER BY AR_FRACCION, UPPER(PID_NOMBRE), PA_SAAIM3, IDENTIFICADOR, ME_CLA_PED, AR_IMPMX, MA_GENERICO
				end
			end

		end
		else
		begin


	
			IF (SELECT PICF_SAAIDETDIVFACT FROM PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='S'
			begin--3
	
				IF (SELECT PICF_SAAIDIVDESC from PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='N'
				begin--4
					insert into TempPEDIMPDETB ( PI_CODIGO, MA_GENERICO, AR_IMPMX, ME_ARIMPMX, ME_GENERICO, PIB_CAN_GEN, PIB_CAN_AR, 
						PA_PROCEDE, ES_ORIGEN, ES_DESTINO, ES_COMPRADOR, ES_VENDEDOR, PIB_VAL_ADU, PIB_VAL_US, 
						 PIB_VAL_FAC,  AR_EXPFO, PIB_RATEEXPFO, PIB_COS_UNIGRA, PIB_COS_UNIVA, EQ_EXPFO,
						PIB_CANT, PIB_POR_DEF, PIB_DESTNAFTA, PA_ORIGEN, PIB_NOMBRE, PIB_PAGACONTRIB, PIB_SEC_IMP, PIB_DEF_TIP, 
						SPI_CODIGO, PIB_CTOT_MN, PIB_VAL_RET, PIB_GENERA_EMPDET, PIB_SERVICIO, PIB_CODIGOFACT)
			
					SELECT     @picodigo, MA_GENERICO, AR_IMPMX, MAX(ME_ARIMPMX), MAX(ME_GENERICO), round(SUM(PID_CAN_GEN),3), 
					                      round(SUM(PID_CAN_AR),3), max(PA_PROCEDE), max(ES_ORIGEN), max(ES_DESTINO), max(ES_COMPRADOR), max(ES_VENDEDOR), 0
					                      , SUM(PID_CTOT_DLS), 0, AR_EXPFO, PID_RATEEXPFO, 
							'a'=case when SUM(PID_CANT)>0 then sum(PIB_COS_UNIGRA*PID_CANT)/SUM(PID_CANT) else 0 end, 
							case when SUM(PID_CANT)>0 then round(sum(PID_COS_UNIVA*PID_CANT)/sum(PID_CANT),6) else 0 end,
							 EQ_EXPFO, round(sum(PID_CANT),3), PID_POR_DEF, PIB_DESTNAFTA, 
					                      PA_ORIGEN, UPPER(MAX(PID_NOMBRE)), PID_PAGACONTRIB, max(PID_SEC_IMP), max(PID_DEF_TIP), max(SPI_CODIGO), SUM(PID_CTOT_MN), SUM(PID_VAL_RET), PIB_GENERA_EMPDET,
							PID_SERVICIO, PID_CODIGOFACT
					FROM         VFillPedImpDetB
					WHERE     PI_CODIGO = @picodigo
					GROUP BY MA_GENERICO, AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, 
					                      EQ_EXPFO, PID_POR_DEF, PIB_DESTNAFTA, PA_ORIGEN, AR_FRACCION, PID_PAGACONTRIB,
						        PA_SAAIM3, IDENTIFICADOR, ME_CLA_PED, PIB_GENERA_EMPDET, PID_SERVICIO, PID_CODIGOFACT
					ORDER BY PID_CODIGOFACT, AR_FRACCION, UPPER(MAX(PID_NOMBRE)), PA_SAAIM3, IDENTIFICADOR, ME_CLA_PED, AR_IMPMX, MA_GENERICO
				end--4
				else
				begin--5
					insert into TempPEDIMPDETB ( PI_CODIGO, MA_GENERICO, AR_IMPMX, ME_ARIMPMX, ME_GENERICO, PIB_CAN_GEN, PIB_CAN_AR, 
						PA_PROCEDE, ES_ORIGEN, ES_DESTINO, ES_COMPRADOR, ES_VENDEDOR, PIB_VAL_ADU, PIB_VAL_US, 
						 PIB_VAL_FAC,  AR_EXPFO, PIB_RATEEXPFO, PIB_COS_UNIGRA, PIB_COS_UNIVA, EQ_EXPFO,
						PIB_CANT, PIB_POR_DEF, PIB_DESTNAFTA, PA_ORIGEN, PIB_NOMBRE, PIB_PAGACONTRIB, PIB_SEC_IMP, PIB_DEF_TIP, 
						SPI_CODIGO, PIB_CTOT_MN, PIB_VAL_RET, PIB_GENERA_EMPDET, PIB_SERVICIO, PIB_CODIGOFACT)
			
					SELECT     @picodigo, MA_GENERICO, AR_IMPMX, MAX(ME_ARIMPMX), MAX(ME_GENERICO), round(SUM(PID_CAN_GEN),3), 
					                      round(SUM(PID_CAN_AR),3), max(PA_PROCEDE), max(ES_ORIGEN), max(ES_DESTINO), max(ES_COMPRADOR), max(ES_VENDEDOR), 0 
					                      , SUM(PID_CTOT_DLS), 0, AR_EXPFO, PID_RATEEXPFO, 
							'a'=case when SUM(PID_CANT)>0 then sum(PIB_COS_UNIGRA*PID_CANT)/SUM(PID_CANT) else 0 end, 
							case when SUM(PID_CANT)>0 then round(sum(PID_COS_UNIVA*PID_CANT)/sum(PID_CANT),6) else 0 end, 
							EQ_EXPFO, round(sum(PID_CANT),3), PID_POR_DEF, PIB_DESTNAFTA, 
					                      PA_ORIGEN, UPPER(PID_NOMBRE), PID_PAGACONTRIB, max(PID_SEC_IMP), max(PID_DEF_TIP), max(SPI_CODIGO), SUM(PID_CTOT_MN), SUM(PID_VAL_RET), PIB_GENERA_EMPDET,
							PID_SERVICIO, PID_CODIGOFACT
					FROM         VFillPedImpDetB
					WHERE     PI_CODIGO = @picodigo
					GROUP BY MA_GENERICO, AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, 
					                      EQ_EXPFO, PID_POR_DEF, PIB_DESTNAFTA, PA_ORIGEN, AR_FRACCION, PID_PAGACONTRIB, UPPER(PID_NOMBRE),
						        PA_SAAIM3, IDENTIFICADOR, ME_CLA_PED, PIB_GENERA_EMPDET, PID_SERVICIO, PID_CODIGOFACT
					ORDER BY PID_CODIGOFACT, AR_FRACCION, UPPER(PID_NOMBRE), PA_SAAIM3, IDENTIFICADOR, ME_CLA_PED, AR_IMPMX, MA_GENERICO
				end--5
			end--3
			else -- sin agrupacion por factura
			begin
				IF (SELECT PICF_SAAIDIVDESC from PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='N'
				begin
					insert into TempPEDIMPDETB ( PI_CODIGO, MA_GENERICO, AR_IMPMX, ME_ARIMPMX, ME_GENERICO, PIB_CAN_GEN, PIB_CAN_AR, 
						PA_PROCEDE, ES_ORIGEN, ES_DESTINO, ES_COMPRADOR, ES_VENDEDOR, PIB_VAL_ADU, PIB_VAL_US, 
						 PIB_VAL_FAC,  AR_EXPFO, PIB_RATEEXPFO, PIB_COS_UNIGRA, PIB_COS_UNIVA, EQ_EXPFO,
						PIB_CANT, PIB_POR_DEF, PIB_DESTNAFTA, PA_ORIGEN, PIB_NOMBRE, PIB_PAGACONTRIB, PIB_SEC_IMP, PIB_DEF_TIP, 
						SPI_CODIGO, PIB_CTOT_MN, PIB_VAL_RET, PIB_GENERA_EMPDET, PIB_SERVICIO)
			
					SELECT     @picodigo, MA_GENERICO, AR_IMPMX, MAX(ME_ARIMPMX), MAX(ME_GENERICO), round(SUM(PID_CAN_GEN),3), 
					                      round(SUM(PID_CAN_AR),3), max(PA_PROCEDE), max(ES_ORIGEN), max(ES_DESTINO), max(ES_COMPRADOR), max(ES_VENDEDOR), 0
					                      , SUM(PID_CTOT_DLS), 0, AR_EXPFO, PID_RATEEXPFO, 
							'a'=case when SUM(PID_CANT)>0 then sum(PIB_COS_UNIGRA*PID_CANT)/SUM(PID_CANT) else 0 end, 
							case when SUM(PID_CANT)>0 then round(sum(PID_COS_UNIVA*PID_CANT)/sum(PID_CANT),6) else 0 end,
							 EQ_EXPFO, round(sum(PID_CANT),3), PID_POR_DEF, PIB_DESTNAFTA, 
					                      PA_ORIGEN, UPPER(MAX(PID_NOMBRE)), PID_PAGACONTRIB, max(PID_SEC_IMP), max(PID_DEF_TIP), max(SPI_CODIGO), SUM(PID_CTOT_MN), SUM(PID_VAL_RET), PIB_GENERA_EMPDET,
							PID_SERVICIO
					FROM         VFillPedImpDetB
					WHERE     PI_CODIGO = @picodigo
					GROUP BY MA_GENERICO, AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, 
					                      EQ_EXPFO, PID_POR_DEF, PIB_DESTNAFTA, PA_ORIGEN, AR_FRACCION, PID_PAGACONTRIB,
						        PA_SAAIM3, IDENTIFICADOR, ME_CLA_PED, PIB_GENERA_EMPDET, PID_SERVICIO
					ORDER BY AR_FRACCION, UPPER(MAX(PID_NOMBRE)), PA_SAAIM3, IDENTIFICADOR, ME_CLA_PED, AR_IMPMX, MA_GENERICO
				end
				else
				begin
					insert into TempPEDIMPDETB ( PI_CODIGO, MA_GENERICO, AR_IMPMX, ME_ARIMPMX, ME_GENERICO, PIB_CAN_GEN, PIB_CAN_AR, 
						PA_PROCEDE, ES_ORIGEN, ES_DESTINO, ES_COMPRADOR, ES_VENDEDOR, PIB_VAL_ADU, PIB_VAL_US, 
						 PIB_VAL_FAC,  AR_EXPFO, PIB_RATEEXPFO, PIB_COS_UNIGRA, PIB_COS_UNIVA, EQ_EXPFO,
						PIB_CANT, PIB_POR_DEF, PIB_DESTNAFTA, PA_ORIGEN, PIB_NOMBRE, PIB_PAGACONTRIB, PIB_SEC_IMP, PIB_DEF_TIP, 
						SPI_CODIGO, PIB_CTOT_MN, PIB_VAL_RET, PIB_GENERA_EMPDET, PIB_SERVICIO)
			
					SELECT     @picodigo, MA_GENERICO, AR_IMPMX, MAX(ME_ARIMPMX), MAX(ME_GENERICO), round(SUM(PID_CAN_GEN),3), 
					                      round(SUM(PID_CAN_AR),3), max(PA_PROCEDE), max(ES_ORIGEN), max(ES_DESTINO), max(ES_COMPRADOR), max(ES_VENDEDOR), 0 
					                      , SUM(PID_CTOT_DLS), 0, AR_EXPFO, PID_RATEEXPFO, 
							'a'=case when SUM(PID_CANT)>0 then sum(PIB_COS_UNIGRA*PID_CANT)/SUM(PID_CANT) else 0 end, 
							case when SUM(PID_CANT)>0 then round(sum(PID_COS_UNIVA*PID_CANT)/sum(PID_CANT),6) else 0 end, 
							EQ_EXPFO, round(sum(PID_CANT),3), PID_POR_DEF, PIB_DESTNAFTA, 
					                      PA_ORIGEN, UPPER(PID_NOMBRE), PID_PAGACONTRIB, max(PID_SEC_IMP), max(PID_DEF_TIP), max(SPI_CODIGO), SUM(PID_CTOT_MN), SUM(PID_VAL_RET), PIB_GENERA_EMPDET,
							PID_SERVICIO
					FROM         VFillPedImpDetB
					WHERE     PI_CODIGO = @picodigo
					GROUP BY MA_GENERICO, AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, 
					                      EQ_EXPFO, PID_POR_DEF, PIB_DESTNAFTA, PA_ORIGEN, AR_FRACCION, PID_PAGACONTRIB, UPPER(PID_NOMBRE),
						        PA_SAAIM3, IDENTIFICADOR, ME_CLA_PED, PIB_GENERA_EMPDET, PID_SERVICIO
					ORDER BY AR_FRACCION, UPPER(PID_NOMBRE), PA_SAAIM3, IDENTIFICADOR, ME_CLA_PED, AR_IMPMX, MA_GENERICO
				end
			end
		end
	end

		update TempPedimpDetB
		set PIB_COS_UNIGEN= PIB_VAL_FAC/PIB_CAN_GEN
		where PIB_CAN_GEN>0

		update TempPedimpDetB
		set PIB_COS_UNIGEN= 0
		where PIB_CAN_GEN=0 or PIB_CAN_GEN is null

		-- el 1 de septiembre cambia el calculo del valor comercial o valor pagado en la exportacion (valor factura)
		/*if (select PI_FEC_PAG from pedimp where pi_codigo=@picodigo) >= '05/01/2007' and @pi_movimiento='S'
		begin

			update TempPedimpDetB
			set PIB_VAL_ADU= round(PIB_CTOT_MN* isnull(PI_FT_ADU,1),0,0), 
			     PIB_VAL_FAC=round(PIB_CTOT_MN,0)
			from TempPedimpDetB inner join Pedimp on TempPedimpDetB.pi_codigo=Pedimp.pi_codigo
			where pedimp.PI_CODIGO = @picodigo and PIB_COS_UNIVA = 0


			update TempPedimpDetB
			set PIB_VAL_ADU= round(PIB_CTOT_MN* isnull(PI_FT_ADU,1),0,0), 
			     PIB_VAL_FAC=round(PIB_COS_UNIVA*PIB_CAN_GEN,0)
			from TempPedimpDetB inner join Pedimp on TempPedimpDetB.pi_codigo=Pedimp.pi_codigo
			where pedimp.PI_CODIGO = @picodigo and PIB_COS_UNIVA > 0
		end
		else*/
		begin
			update TempPedimpDetB
			set PIB_VAL_ADU= round(PIB_CTOT_MN* isnull(PI_FT_ADU,1),0,0), 
			     PIB_VAL_FAC=round(PIB_CTOT_MN,0)
			from TempPedimpDetB inner join Pedimp on TempPedimpDetB.pi_codigo=Pedimp.pi_codigo
			where pedimp.PI_CODIGO = @picodigo
		end


		update TempPedimpDetB
		set PIB_VAL_ADU= 1, 
		      PIB_CAN_GEN=0,
		      PIB_CAN_AR=.25,
		     PIB_VAL_FAC=round(PIB_CTOT_MN/PIB_VAL_US,4)
		from TempPedimpDetB inner join Pedimp on TempPedimpDetB.pi_codigo=Pedimp.pi_codigo
		where PIB_GENERA_EMPDET<>'D' and pedimp.PI_CODIGO = @picodigo



	select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

	insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
	values (@user, 2, 'Llenando agrupacion SAAI ', 'Filling SAAI Group ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)
	


	if (select pi_llenaSecuenciaDetb from configurapedimento)='S'
	begin

		insert into PEDIMPDETB (PI_CODIGO, MA_GENERICO, AR_IMPMX, ME_ARIMPMX, ME_GENERICO, PIB_CAN_GEN, PIB_CAN_AR, 
			PA_PROCEDE, ES_ORIGEN, ES_DESTINO, ES_COMPRADOR, ES_VENDEDOR, PIB_VAL_ADU, PIB_VAL_US, 
			 PIB_VAL_FAC,  AR_EXPFO, PIB_RATEEXPFO, PIB_COS_UNIGRA, PIB_COS_UNIVA, EQ_EXPFO,
			PIB_CANT, PIB_POR_DEF, PIB_DESTNAFTA, PA_ORIGEN, PIB_NOMBRE, PIB_SECUENCIA, PIB_COS_UNIGEN, PIB_PAGACONTRIB,
			PIB_SEC_IMP, PIB_DEF_TIP, SPI_CODIGO, PIB_CODIGOFACT, PIB_VAL_RET, PIB_GENERA_EMPDET, PIB_SERVICIO)

		select PI_CODIGO, MA_GENERICO, AR_IMPMX, ME_ARIMPMX, ME_GENERICO, PIB_CAN_GEN, PIB_CAN_AR, 
			PA_PROCEDE, ES_ORIGEN, ES_DESTINO, ES_COMPRADOR, ES_VENDEDOR, PIB_VAL_ADU, PIB_VAL_US, 
			 PIB_VAL_FAC,  AR_EXPFO, PIB_RATEEXPFO, PIB_COS_UNIGRA, PIB_COS_UNIVA, EQ_EXPFO,
			PIB_CANT, PIB_POR_DEF, PIB_DESTNAFTA, PA_ORIGEN, PIB_NOMBRE, PIB_SECUENCIA, case when PIB_CAN_GEN>0 THEN round(PIB_VAL_US/PIB_CAN_GEN,5) ELSE 0 END, PIB_PAGACONTRIB,
			PIB_SEC_IMP, PIB_DEF_TIP, SPI_CODIGO, PIB_CODIGOFACT, PIB_VAL_RET, PIB_GENERA_EMPDET, PIB_SERVICIO
		from TempPedimpDetB
		order by PIB_SECUENCIA

	end
	else
	begin


		insert into PEDIMPDETB (PI_CODIGO, MA_GENERICO, AR_IMPMX, ME_ARIMPMX, ME_GENERICO, PIB_CAN_GEN, PIB_CAN_AR, 
			PA_PROCEDE, ES_ORIGEN, ES_DESTINO, ES_COMPRADOR, ES_VENDEDOR, PIB_VAL_ADU, PIB_VAL_US, 
			 PIB_VAL_FAC,  AR_EXPFO, PIB_RATEEXPFO, PIB_COS_UNIGRA, PIB_COS_UNIVA, EQ_EXPFO,
			PIB_CANT, PIB_POR_DEF, PIB_DESTNAFTA, PA_ORIGEN, PIB_NOMBRE, PIB_SECUENCIA, PIB_COS_UNIGEN, PIB_PAGACONTRIB,
			PIB_SEC_IMP, PIB_DEF_TIP, SPI_CODIGO, PIB_CODIGOFACT, PIB_VAL_RET, PIB_GENERA_EMPDET, PIB_SERVICIO)

		select PI_CODIGO, MA_GENERICO, AR_IMPMX, ME_ARIMPMX, ME_GENERICO, PIB_CAN_GEN, PIB_CAN_AR, 
			PA_PROCEDE, ES_ORIGEN, ES_DESTINO, ES_COMPRADOR, ES_VENDEDOR, PIB_VAL_ADU, PIB_VAL_US, 
			 PIB_VAL_FAC,  AR_EXPFO, PIB_RATEEXPFO, PIB_COS_UNIGRA, PIB_COS_UNIVA, EQ_EXPFO,
			PIB_CANT, PIB_POR_DEF, PIB_DESTNAFTA, PA_ORIGEN, PIB_NOMBRE, 0, case when PIB_CAN_GEN>0 THEN round(PIB_VAL_US/PIB_CAN_GEN,5) ELSE 0 END, PIB_PAGACONTRIB,
			PIB_SEC_IMP, PIB_DEF_TIP, SPI_CODIGO, PIB_CODIGOFACT, PIB_VAL_RET, PIB_GENERA_EMPDET, PIB_SERVICIO
		from TempPedimpDetB


	end
--if exists (select * from sysobjects where id = object_id(N'[TempPedImpDetB'+@pi_codigo+']') and OBJECTPROPERTY(id, N'IsTable') = 1)
--exec('DROP TABLE [TempPedImpDetB'+@pi_codigo+']')

/*=========================== Inicio actualizacion de la liga entre detalle y agrupacion ============================*/

	select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

	insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
	values (@user, 2, 'Ligando detalle Agrupacion SAAI - Detalle Pedimento ', 'Linking SAAI Group Detail - Pedimento Detail ', convert(varchar(10),@FechaActual,101),  @hora, @em_codigo)
	


	IF @pi_movimiento='E'
	begin
		IF (SELECT PICF_SAAIDETDIVFACT FROM PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='S'
		begin

			IF (SELECT PICF_SAAIDIVDESC from PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='N'
			begin
			-- Actualizacion del PIB_INDICEB
				UPDATE dbo.PEDIMPDET
				SET     dbo.PEDIMPDET.PIB_INDICEB= dbo.PEDIMPDETB.PIB_INDICEB
				FROM         dbo.PEDIMPDET, dbo.PEDIMPDETB 
				WHERE     (dbo.PEDIMPDETB.PI_CODIGO = @picodigo) and
				dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMPDETB.PI_CODIGO AND 
	--		             isnull(dbo.PEDIMPDET.MA_GENERICO,0) = isnull(dbo.PEDIMPDETB.MA_GENERICO,0) AND
			             isnull(dbo.PEDIMPDET.ME_GENERICO,0) = isnull(dbo.PEDIMPDETB.ME_GENERICO,0) AND
			             isnull(dbo.PEDIMPDET.AR_IMPMX,0) = isnull(dbo.PEDIMPDETB.AR_IMPMX,0) AND
	--		             isnull(dbo.PEDIMPDET.PA_PROCEDE,0) = isnull(dbo.PEDIMPDETB.PA_PROCEDE,0) and 
				isnull(dbo.PEDIMPDET.PA_ORIGEN,0) = isnull(dbo.PEDIMPDETB.PA_ORIGEN,0) and
	--			isnull(dbo.PEDIMPDET.AR_EXPFO,0)=isnull(dbo.PEDIMPDETB.AR_EXPFO,0) and 
	--			isnull(dbo.PEDIMPDET.PID_RATEEXPFO,0)=isnull(dbo.PEDIMPDETB.PIB_RATEEXPFO,0) and
				isnull(dbo.PEDIMPDET.EQ_EXPFO,1)=isnull(dbo.PEDIMPDETB.EQ_EXPFO,1) and 
				isnull(dbo.PEDIMPDET.PID_POR_DEF,-1)=isnull(dbo.PEDIMPDETB.PIB_POR_DEF,-1) and
				dbo.PEDIMPDET.PID_PAGACONTRIB=dbo.PEDIMPDETB.PIB_PAGACONTRIB and
				isnull(dbo.PEDIMPDET.PID_SEC_IMP,0)=isnull(dbo.PEDIMPDETB.PIB_SEC_IMP,0) and
				isnull(dbo.PEDIMPDET.PID_DEF_TIP,0)=isnull(dbo.PEDIMPDETB.PIB_DEF_TIP,0) and
				isnull(dbo.PEDIMPDET.SPI_CODIGO,0)=isnull(dbo.PEDIMPDETB.SPI_CODIGO,0) and
				isnull(dbo.PEDIMPDET.PID_GENERA_EMPDET,0)=isnull(dbo.PEDIMPDETB.PIB_GENERA_EMPDET,0) and
				isnull(dbo.PEDIMPDET.PID_SERVICIO,'N')=isnull(dbo.PEDIMPDETB.PIB_SERVICIO,'N') and
				isnull(dbo.PEDIMPDET.PID_CODIGOFACT,0)=isnull(dbo.PEDIMPDETB.PIB_CODIGOFACT,0)			
				AND dbo.PEDIMPDET.PID_IMPRIMIR='S'


	
			end
			else
			begin
				UPDATE dbo.PEDIMPDET
				SET     dbo.PEDIMPDET.PIB_INDICEB= dbo.PEDIMPDETB.PIB_INDICEB 
				FROM         dbo.PEDIMPDET, dbo.PEDIMPDETB 
				WHERE     (dbo.PEDIMPDETB.PI_CODIGO = @picodigo) and
				dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMPDETB.PI_CODIGO AND 
	--		             isnull(dbo.PEDIMPDET.MA_GENERICO,0) = isnull(dbo.PEDIMPDETB.MA_GENERICO,0) AND
			             isnull(dbo.PEDIMPDET.ME_GENERICO,0) = isnull(dbo.PEDIMPDETB.ME_GENERICO,0) AND
			             isnull(dbo.PEDIMPDET.AR_IMPMX,0) = isnull(dbo.PEDIMPDETB.AR_IMPMX,0) AND
	--		             isnull(dbo.PEDIMPDET.PA_PROCEDE,0) = isnull(dbo.PEDIMPDETB.PA_PROCEDE,0) and 
				isnull(dbo.PEDIMPDET.PA_ORIGEN,0) = isnull(dbo.PEDIMPDETB.PA_ORIGEN,0) and
				isnull(dbo.PEDIMPDET.EQ_EXPFO,1)=isnull(dbo.PEDIMPDETB.EQ_EXPFO,1) and 
				isnull(dbo.PEDIMPDET.PID_POR_DEF,-1)=isnull(dbo.PEDIMPDETB.PIB_POR_DEF,-1) and
				dbo.PEDIMPDET.PID_PAGACONTRIB=dbo.PEDIMPDETB.PIB_PAGACONTRIB and
				isnull(dbo.PEDIMPDET.PID_SEC_IMP,0)=isnull(dbo.PEDIMPDETB.PIB_SEC_IMP,0) and
				isnull(dbo.PEDIMPDET.PID_DEF_TIP,0)=isnull(dbo.PEDIMPDETB.PIB_DEF_TIP,0) and
				isnull(dbo.PEDIMPDET.SPI_CODIGO,0)=isnull(dbo.PEDIMPDETB.SPI_CODIGO,0) and
				isnull(dbo.PEDIMPDET.PID_NOMBRE,'')=isnull(dbo.PEDIMPDETB.PIB_NOMBRE,'') and
				isnull(dbo.PEDIMPDET.PID_GENERA_EMPDET,0)=isnull(dbo.PEDIMPDETB.PIB_GENERA_EMPDET,0) and
				isnull(dbo.PEDIMPDET.PID_SERVICIO,'N')=isnull(dbo.PEDIMPDETB.PIB_SERVICIO,'N') and		
				isnull(dbo.PEDIMPDET.PID_CODIGOFACT,0)=isnull(dbo.PEDIMPDETB.PIB_CODIGOFACT,0)			
				AND dbo.PEDIMPDET.PID_IMPRIMIR='S'
			end
		end
		else -- sin agrupacion por factura
		begin
			IF (SELECT PICF_SAAIDIVDESC from PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='N'
			begin
			-- Actualizacion del PIB_INDICEB
				UPDATE dbo.PEDIMPDET
				SET     dbo.PEDIMPDET.PIB_INDICEB= dbo.PEDIMPDETB.PIB_INDICEB
				FROM         dbo.PEDIMPDET, dbo.PEDIMPDETB 
				WHERE     (dbo.PEDIMPDETB.PI_CODIGO = @picodigo) and
				dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMPDETB.PI_CODIGO AND 
	--		             isnull(dbo.PEDIMPDET.MA_GENERICO,0) = isnull(dbo.PEDIMPDETB.MA_GENERICO,0) AND
			             isnull(dbo.PEDIMPDET.ME_GENERICO,0) = isnull(dbo.PEDIMPDETB.ME_GENERICO,0) AND
			             isnull(dbo.PEDIMPDET.AR_IMPMX,0) = isnull(dbo.PEDIMPDETB.AR_IMPMX,0) AND
	--		             isnull(dbo.PEDIMPDET.PA_PROCEDE,0) = isnull(dbo.PEDIMPDETB.PA_PROCEDE,0) and 
				isnull(dbo.PEDIMPDET.PA_ORIGEN,0) = isnull(dbo.PEDIMPDETB.PA_ORIGEN,0) and
	--			isnull(dbo.PEDIMPDET.AR_EXPFO,0)=isnull(dbo.PEDIMPDETB.AR_EXPFO,0) and 
	--			isnull(dbo.PEDIMPDET.PID_RATEEXPFO,0)=isnull(dbo.PEDIMPDETB.PIB_RATEEXPFO,0) and
				isnull(dbo.PEDIMPDET.EQ_EXPFO,1)=isnull(dbo.PEDIMPDETB.EQ_EXPFO,1) and 
				isnull(dbo.PEDIMPDET.PID_POR_DEF,-1)=isnull(dbo.PEDIMPDETB.PIB_POR_DEF,-1) and
				dbo.PEDIMPDET.PID_PAGACONTRIB=dbo.PEDIMPDETB.PIB_PAGACONTRIB and
				isnull(dbo.PEDIMPDET.PID_SEC_IMP,0)=isnull(dbo.PEDIMPDETB.PIB_SEC_IMP,0) and
				isnull(dbo.PEDIMPDET.PID_DEF_TIP,0)=isnull(dbo.PEDIMPDETB.PIB_DEF_TIP,0) and
				isnull(dbo.PEDIMPDET.SPI_CODIGO,0)=isnull(dbo.PEDIMPDETB.SPI_CODIGO,0) and
				isnull(dbo.PEDIMPDET.PID_GENERA_EMPDET,0)=isnull(dbo.PEDIMPDETB.PIB_GENERA_EMPDET,0) and
				isnull(dbo.PEDIMPDET.PID_SERVICIO,'N')=isnull(dbo.PEDIMPDETB.PIB_SERVICIO,'N') 		
				AND dbo.PEDIMPDET.PID_IMPRIMIR='S'
	
			end
			else
			begin
				UPDATE dbo.PEDIMPDET
				SET     dbo.PEDIMPDET.PIB_INDICEB= dbo.PEDIMPDETB.PIB_INDICEB
				FROM         dbo.PEDIMPDET, dbo.PEDIMPDETB 
				WHERE     (dbo.PEDIMPDETB.PI_CODIGO = @picodigo) and
				dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMPDETB.PI_CODIGO AND 
	--		             isnull(dbo.PEDIMPDET.MA_GENERICO,0) = isnull(dbo.PEDIMPDETB.MA_GENERICO,0) AND
			             isnull(dbo.PEDIMPDET.ME_GENERICO,0) = isnull(dbo.PEDIMPDETB.ME_GENERICO,0) AND
			             isnull(dbo.PEDIMPDET.AR_IMPMX,0) = isnull(dbo.PEDIMPDETB.AR_IMPMX,0) AND
	--		             isnull(dbo.PEDIMPDET.PA_PROCEDE,0) = isnull(dbo.PEDIMPDETB.PA_PROCEDE,0) and 
				isnull(dbo.PEDIMPDET.PA_ORIGEN,0) = isnull(dbo.PEDIMPDETB.PA_ORIGEN,0) and
				isnull(dbo.PEDIMPDET.EQ_EXPFO,1)=isnull(dbo.PEDIMPDETB.EQ_EXPFO,1) and 
				isnull(dbo.PEDIMPDET.PID_POR_DEF,-1)=isnull(dbo.PEDIMPDETB.PIB_POR_DEF,-1) and
				dbo.PEDIMPDET.PID_PAGACONTRIB=dbo.PEDIMPDETB.PIB_PAGACONTRIB and
				isnull(dbo.PEDIMPDET.PID_SEC_IMP,0)=isnull(dbo.PEDIMPDETB.PIB_SEC_IMP,0) and
				isnull(dbo.PEDIMPDET.PID_DEF_TIP,0)=isnull(dbo.PEDIMPDETB.PIB_DEF_TIP,0) and
				isnull(dbo.PEDIMPDET.SPI_CODIGO,0)=isnull(dbo.PEDIMPDETB.SPI_CODIGO,0) and				isnull(dbo.PEDIMPDET.PID_NOMBRE,'')=isnull(dbo.PEDIMPDETB.PIB_NOMBRE,'') and
				isnull(dbo.PEDIMPDET.PID_GENERA_EMPDET,0)=isnull(dbo.PEDIMPDETB.PIB_GENERA_EMPDET,0) and
				isnull(dbo.PEDIMPDET.PID_SERVICIO,'N')=isnull(dbo.PEDIMPDETB.PIB_SERVICIO,'N') 		
				AND dbo.PEDIMPDET.PID_IMPRIMIR='S'
			end

		end
	end
	else
	begin
		if @CF_PAGOCONTRIBUCION='E' 
		begin

			IF (SELECT PICF_SAAIDETDIVFACT FROM PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='S'
			begin
	
				IF (SELECT PICF_SAAIDIVDESC from PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='N'
				begin
				-- Actualizacion del PIB_INDICEB
					UPDATE dbo.PEDIMPDET
					SET     dbo.PEDIMPDET.PIB_INDICEB= dbo.PEDIMPDETB.PIB_INDICEB
					FROM         PEDIMP INNER JOIN
				                      PEDIMPDET ON PEDIMP.PI_CODIGO = PEDIMP.PI_CODIGO 
					        CROSS JOIN dbo.PEDIMPDETB
					WHERE     (dbo.PEDIMPDETB.PI_CODIGO = @picodigo) and
					dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMPDETB.PI_CODIGO AND 
				             isnull(dbo.PEDIMPDET.ME_GENERICO,0) = isnull(dbo.PEDIMPDETB.ME_GENERICO,0) AND
				             isnull(dbo.PEDIMPDET.AR_IMPMX,0) = isnull(dbo.PEDIMPDETB.AR_IMPMX,0) AND
					isnull(dbo.PEDIMPDET.PA_ORIGEN,0) = isnull(dbo.PEDIMPDETB.PA_ORIGEN,0) and
					isnull(dbo.PEDIMPDET.EQ_EXPFO,1)=isnull(dbo.PEDIMPDETB.EQ_EXPFO,1) and 
					isnull(dbo.PEDIMPDET.PID_POR_DEF,-1)=isnull(dbo.PEDIMPDETB.PIB_POR_DEF,-1) 
					and (case when PEDIMP.PI_MOVIMIENTO='S' then (case when isnull(PEDIMPDET.PID_REGIONFIN, 'F')='N' or isnull(PEDIMPDET.PID_REGIONFIN, 'F')='M'
					then (case when PEDIMPDET.PID_DEF_TIP<>'S' and PEDIMPDET.PID_SERVICIO<>'S'
					then 'S' else 'N' end) else 'N' end) else (case when isnull(PEDIMPDET.PID_DEF_TIP, 'G')='P' then 'S'else 'N' end) end) = (dbo.PEDIMPDETB.PIB_DESTNAFTA) and
					isnull(dbo.PEDIMPDET.PID_GENERA_EMPDET,0)=isnull(dbo.PEDIMPDETB.PIB_GENERA_EMPDET,0) and
					isnull(dbo.PEDIMPDET.PID_SERVICIO,'N')=isnull(dbo.PEDIMPDETB.PIB_SERVICIO,'N')and 		
					isnull(dbo.PEDIMPDET.PID_CODIGOFACT,0)=isnull(dbo.PEDIMPDETB.PIB_CODIGOFACT,0)			
					AND dbo.PEDIMPDET.PID_IMPRIMIR='S'
				end
				else
				begin
					UPDATE dbo.PEDIMPDET
					SET     dbo.PEDIMPDET.PIB_INDICEB= dbo.PEDIMPDETB.PIB_INDICEB
					FROM         PEDIMP INNER JOIN
				                      PEDIMPDET ON PEDIMP.PI_CODIGO = PEDIMP.PI_CODIGO 
					        CROSS JOIN dbo.PEDIMPDETB
					WHERE     (dbo.PEDIMPDETB.PI_CODIGO = @picodigo) and
					dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMPDETB.PI_CODIGO AND 
				             isnull(dbo.PEDIMPDET.ME_GENERICO,0) = isnull(dbo.PEDIMPDETB.ME_GENERICO,0) AND
				             isnull(dbo.PEDIMPDET.AR_IMPMX,0) = isnull(dbo.PEDIMPDETB.AR_IMPMX,0) AND
					isnull(dbo.PEDIMPDET.PA_ORIGEN,0) = isnull(dbo.PEDIMPDETB.PA_ORIGEN,0) and
					isnull(dbo.PEDIMPDET.EQ_EXPFO,1)=isnull(dbo.PEDIMPDETB.EQ_EXPFO,1) and 
					isnull(dbo.PEDIMPDET.PID_POR_DEF,-1)=isnull(dbo.PEDIMPDETB.PIB_POR_DEF,-1) 
					and (case when PEDIMP.PI_MOVIMIENTO='S' then (case when isnull(PEDIMPDET.PID_REGIONFIN, 'F')='N' or isnull(PEDIMPDET.PID_REGIONFIN, 'F')='M'
					then (case when PEDIMPDET.PID_DEF_TIP<>'S' and PEDIMPDET.PID_SERVICIO<>'S'
					then 'S' else 'N' end) else 'N' end) else (case when isnull(PEDIMPDET.PID_DEF_TIP, 'G')='P' then 'S'else 'N' end) end) = (dbo.PEDIMPDETB.PIB_DESTNAFTA) and
					isnull(dbo.PEDIMPDET.PID_NOMBRE,'')=isnull(dbo.PEDIMPDETB.PIB_NOMBRE,'') and
					isnull(dbo.PEDIMPDET.PID_GENERA_EMPDET,0)=isnull(dbo.PEDIMPDETB.PIB_GENERA_EMPDET,0) and
					isnull(dbo.PEDIMPDET.PID_SERVICIO,'N')=isnull(dbo.PEDIMPDETB.PIB_SERVICIO,'N') and		
					isnull(dbo.PEDIMPDET.PID_CODIGOFACT,0)=isnull(dbo.PEDIMPDETB.PIB_CODIGOFACT,0)			
					AND dbo.PEDIMPDET.PID_IMPRIMIR='S'
				end
			end
			else -- sin agrupacion por factura
			begin
				IF (SELECT PICF_SAAIDIVDESC from PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='N'
				begin
				-- Actualizacion del PIB_INDICEB
					UPDATE dbo.PEDIMPDET
					SET     dbo.PEDIMPDET.PIB_INDICEB= dbo.PEDIMPDETB.PIB_INDICEB
					FROM         PEDIMP INNER JOIN
				                      PEDIMPDET ON PEDIMP.PI_CODIGO = PEDIMP.PI_CODIGO 
					        CROSS JOIN dbo.PEDIMPDETB
					WHERE     (dbo.PEDIMPDETB.PI_CODIGO = @picodigo) and
					dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMPDETB.PI_CODIGO AND 
				             isnull(dbo.PEDIMPDET.ME_GENERICO,0) = isnull(dbo.PEDIMPDETB.ME_GENERICO,0) AND
				             isnull(dbo.PEDIMPDET.AR_IMPMX,0) = isnull(dbo.PEDIMPDETB.AR_IMPMX,0) AND
					isnull(dbo.PEDIMPDET.PA_ORIGEN,0) = isnull(dbo.PEDIMPDETB.PA_ORIGEN,0) and
					isnull(dbo.PEDIMPDET.EQ_EXPFO,1)=isnull(dbo.PEDIMPDETB.EQ_EXPFO,1) and 
					isnull(dbo.PEDIMPDET.PID_POR_DEF,-1)=isnull(dbo.PEDIMPDETB.PIB_POR_DEF,-1) 
					and (case when PEDIMP.PI_MOVIMIENTO='S' then (case when isnull(PEDIMPDET.PID_REGIONFIN, 'F')='N' or isnull(PEDIMPDET.PID_REGIONFIN, 'F')='M'
					then (case when PEDIMPDET.PID_DEF_TIP<>'S' and PEDIMPDET.PID_SERVICIO<>'S'
					then 'S' else 'N' end) else 'N' end) else (case when isnull(PEDIMPDET.PID_DEF_TIP, 'G')='P' then 'S'else 'N' end) end) = (dbo.PEDIMPDETB.PIB_DESTNAFTA) and
					isnull(dbo.PEDIMPDET.PID_GENERA_EMPDET,0)=isnull(dbo.PEDIMPDETB.PIB_GENERA_EMPDET,0) and
					isnull(dbo.PEDIMPDET.PID_SERVICIO,'N')=isnull(dbo.PEDIMPDETB.PIB_SERVICIO,'N') 		
					AND dbo.PEDIMPDET.PID_IMPRIMIR='S'
				end
				else
				begin
					UPDATE dbo.PEDIMPDET
					SET     dbo.PEDIMPDET.PIB_INDICEB= dbo.PEDIMPDETB.PIB_INDICEB
					FROM         PEDIMP INNER JOIN
				                      PEDIMPDET ON PEDIMP.PI_CODIGO = PEDIMP.PI_CODIGO 
					        CROSS JOIN dbo.PEDIMPDETB
					WHERE     (dbo.PEDIMPDETB.PI_CODIGO = @picodigo) and
					dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMPDETB.PI_CODIGO AND 
				             isnull(dbo.PEDIMPDET.ME_GENERICO,0) = isnull(dbo.PEDIMPDETB.ME_GENERICO,0) AND
				             isnull(dbo.PEDIMPDET.AR_IMPMX,0) = isnull(dbo.PEDIMPDETB.AR_IMPMX,0) AND
					isnull(dbo.PEDIMPDET.PA_ORIGEN,0) = isnull(dbo.PEDIMPDETB.PA_ORIGEN,0) and
					isnull(dbo.PEDIMPDET.EQ_EXPFO,1)=isnull(dbo.PEDIMPDETB.EQ_EXPFO,1) and 
					isnull(dbo.PEDIMPDET.PID_POR_DEF,-1)=isnull(dbo.PEDIMPDETB.PIB_POR_DEF,-1) 
					and (case when PEDIMP.PI_MOVIMIENTO='S' then (case when isnull(PEDIMPDET.PID_REGIONFIN, 'F')='N' or isnull(PEDIMPDET.PID_REGIONFIN, 'F')='M'
					then (case when PEDIMPDET.PID_DEF_TIP<>'S' and PEDIMPDET.PID_SERVICIO<>'S'
					then 'S' else 'N' end) else 'N' end) else (case when isnull(PEDIMPDET.PID_DEF_TIP, 'G')='P' then 'S'else 'N' end) end) = (dbo.PEDIMPDETB.PIB_DESTNAFTA) and
					isnull(dbo.PEDIMPDET.PID_NOMBRE,'')=isnull(dbo.PEDIMPDETB.PIB_NOMBRE,'') and
					isnull(dbo.PEDIMPDET.PID_GENERA_EMPDET,0)=isnull(dbo.PEDIMPDETB.PIB_GENERA_EMPDET,0) and
					isnull(dbo.PEDIMPDET.PID_SERVICIO,'N')=isnull(dbo.PEDIMPDETB.PIB_SERVICIO,'N') 		
					AND dbo.PEDIMPDET.PID_IMPRIMIR='S'
				end
	
			end
		end
		else
		begin

			IF (SELECT PICF_SAAIDETDIVFACT FROM PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='S'
			begin
	
				IF (SELECT PICF_SAAIDIVDESC from PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='N'
				begin
				-- Actualizacion del PIB_INDICEB
					UPDATE dbo.PEDIMPDET
					SET     dbo.PEDIMPDET.PIB_INDICEB= dbo.PEDIMPDETB.PIB_INDICEB
					FROM         PEDIMP INNER JOIN
				                      PEDIMPDET ON PEDIMP.PI_CODIGO = PEDIMP.PI_CODIGO 
					        CROSS JOIN dbo.PEDIMPDETB
					WHERE     (dbo.PEDIMPDETB.PI_CODIGO = @picodigo) and
					dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMPDETB.PI_CODIGO AND 
		--		             isnull(dbo.PEDIMPDET.MA_GENERICO,0) = isnull(dbo.PEDIMPDETB.MA_GENERICO,0) AND
				             isnull(dbo.PEDIMPDET.ME_GENERICO,0) = isnull(dbo.PEDIMPDETB.ME_GENERICO,0) AND
				             isnull(dbo.PEDIMPDET.AR_IMPMX,0) = isnull(dbo.PEDIMPDETB.AR_IMPMX,0) AND
		--		             isnull(dbo.PEDIMPDET.PA_PROCEDE,0) = isnull(dbo.PEDIMPDETB.PA_PROCEDE,0) and 
					isnull(dbo.PEDIMPDET.PA_ORIGEN,0) = isnull(dbo.PEDIMPDETB.PA_ORIGEN,0) and
					isnull(dbo.PEDIMPDET.AR_EXPFO,0)=isnull(dbo.PEDIMPDETB.AR_EXPFO,0) and 
					isnull(dbo.PEDIMPDET.PID_RATEEXPFO,0)=isnull(dbo.PEDIMPDETB.PIB_RATEEXPFO,0) and
					isnull(dbo.PEDIMPDET.EQ_EXPFO,1)=isnull(dbo.PEDIMPDETB.EQ_EXPFO,1) and 
					isnull(dbo.PEDIMPDET.PID_POR_DEF,-1)=isnull(dbo.PEDIMPDETB.PIB_POR_DEF,-1) 
					and (case when PEDIMP.PI_MOVIMIENTO='S' then (case when isnull(PEDIMPDET.PID_REGIONFIN, 'F')='N' or isnull(PEDIMPDET.PID_REGIONFIN, 'F')='M'
					then (case when PEDIMPDET.PID_DEF_TIP<>'S' and PEDIMPDET.PID_SERVICIO<>'S'
					then 'S' else 'N' end) else 'N' end) else (case when isnull(PEDIMPDET.PID_DEF_TIP, 'G')='P' then 'S'else 'N' end) end) = (dbo.PEDIMPDETB.PIB_DESTNAFTA) and
					isnull(dbo.PEDIMPDET.PID_GENERA_EMPDET,0)=isnull(dbo.PEDIMPDETB.PIB_GENERA_EMPDET,0) and
					isnull(dbo.PEDIMPDET.PID_SERVICIO,'N')=isnull(dbo.PEDIMPDETB.PIB_SERVICIO,'N')and 		
					isnull(dbo.PEDIMPDET.PID_CODIGOFACT,0)=isnull(dbo.PEDIMPDETB.PIB_CODIGOFACT,0)			
					AND dbo.PEDIMPDET.PID_IMPRIMIR='S'
				end
				else
				begin
					UPDATE dbo.PEDIMPDET
					SET     dbo.PEDIMPDET.PIB_INDICEB= dbo.PEDIMPDETB.PIB_INDICEB
					FROM         PEDIMP INNER JOIN
				                      PEDIMPDET ON PEDIMP.PI_CODIGO = PEDIMP.PI_CODIGO
					        CROSS JOIN dbo.PEDIMPDETB
					WHERE     (dbo.PEDIMPDETB.PI_CODIGO = @picodigo) and
					dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMPDETB.PI_CODIGO AND 
		--		             isnull(dbo.PEDIMPDET.MA_GENERICO,0) = isnull(dbo.PEDIMPDETB.MA_GENERICO,0) AND
				             isnull(dbo.PEDIMPDET.ME_GENERICO,0) = isnull(dbo.PEDIMPDETB.ME_GENERICO,0) AND
				             isnull(dbo.PEDIMPDET.AR_IMPMX,0) = isnull(dbo.PEDIMPDETB.AR_IMPMX,0) AND
		--		             isnull(dbo.PEDIMPDET.PA_PROCEDE,0) = isnull(dbo.PEDIMPDETB.PA_PROCEDE,0) and 
					isnull(dbo.PEDIMPDET.PA_ORIGEN,0) = isnull(dbo.PEDIMPDETB.PA_ORIGEN,0) and
					isnull(dbo.PEDIMPDET.AR_EXPFO,0)=isnull(dbo.PEDIMPDETB.AR_EXPFO,0) and 
					isnull(dbo.PEDIMPDET.PID_RATEEXPFO,0)=isnull(dbo.PEDIMPDETB.PIB_RATEEXPFO,0) and
					isnull(dbo.PEDIMPDET.EQ_EXPFO,1)=isnull(dbo.PEDIMPDETB.EQ_EXPFO,1) and 
					isnull(dbo.PEDIMPDET.PID_POR_DEF,-1)=isnull(dbo.PEDIMPDETB.PIB_POR_DEF,-1) 
					and (case when PEDIMP.PI_MOVIMIENTO='S' then (case when isnull(PEDIMPDET.PID_REGIONFIN, 'F')='N' or isnull(PEDIMPDET.PID_REGIONFIN, 'F')='M'
					then (case when PEDIMPDET.PID_DEF_TIP<>'S' and PEDIMPDET.PID_SERVICIO<>'S'
					then 'S' else 'N' end) else 'N' end) else (case when isnull(PEDIMPDET.PID_DEF_TIP, 'G')='P' then 'S'else 'N' end) end) = (dbo.PEDIMPDETB.PIB_DESTNAFTA) and
					isnull(dbo.PEDIMPDET.PID_NOMBRE,'')=isnull(dbo.PEDIMPDETB.PIB_NOMBRE,'') and
					isnull(dbo.PEDIMPDET.PID_GENERA_EMPDET,0)=isnull(dbo.PEDIMPDETB.PIB_GENERA_EMPDET,0) and
					isnull(dbo.PEDIMPDET.PID_SERVICIO,'N')=isnull(dbo.PEDIMPDETB.PIB_SERVICIO,'N') and		
					isnull(dbo.PEDIMPDET.PID_CODIGOFACT,0)=isnull(dbo.PEDIMPDETB.PIB_CODIGOFACT,0)			
					AND dbo.PEDIMPDET.PID_IMPRIMIR='S'
				end
			end
			else -- sin agrupacion por factura
			begin
				IF (SELECT PICF_SAAIDIVDESC from PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='N'
				begin
				-- Actualizacion del PIB_INDICEB
					UPDATE dbo.PEDIMPDET
					SET     dbo.PEDIMPDET.PIB_INDICEB= dbo.PEDIMPDETB.PIB_INDICEB
					FROM         PEDIMP INNER JOIN
				                      PEDIMPDET ON PEDIMP.PI_CODIGO = PEDIMPDET.PI_CODIGO 
					        CROSS JOIN dbo.PEDIMPDETB
					WHERE     (dbo.PEDIMPDETB.PI_CODIGO = @picodigo) and
					dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMPDETB.PI_CODIGO AND 
				             isnull(dbo.PEDIMPDET.ME_GENERICO,0) = isnull(dbo.PEDIMPDETB.ME_GENERICO,0) AND
				             isnull(dbo.PEDIMPDET.AR_IMPMX,0) = isnull(dbo.PEDIMPDETB.AR_IMPMX,0) AND
					isnull(dbo.PEDIMPDET.PA_ORIGEN,0) = isnull(dbo.PEDIMPDETB.PA_ORIGEN,0) and
					isnull(dbo.PEDIMPDET.AR_EXPFO,0)=isnull(dbo.PEDIMPDETB.AR_EXPFO,0) and 
					isnull(dbo.PEDIMPDET.PID_RATEEXPFO,0)=isnull(dbo.PEDIMPDETB.PIB_RATEEXPFO,0) and
					isnull(dbo.PEDIMPDET.EQ_EXPFO,1)=isnull(dbo.PEDIMPDETB.EQ_EXPFO,1) and 
					isnull(dbo.PEDIMPDET.PID_POR_DEF,-1)=isnull(dbo.PEDIMPDETB.PIB_POR_DEF,-1) 
					and (case when PEDIMP.PI_MOVIMIENTO='S' then (case when isnull(PEDIMPDET.PID_REGIONFIN, 'F')='N' or isnull(PEDIMPDET.PID_REGIONFIN, 'F')='M'
					then (case when PEDIMPDET.PID_DEF_TIP<>'S' and PEDIMPDET.PID_SERVICIO<>'S'
					then 'S' else 'N' end) else 'N' end) else (case when isnull(PEDIMPDET.PID_DEF_TIP, 'G')='P' then 'S'else 'N' end) end) = (PEDIMPDETB.PIB_DESTNAFTA) and
					--isnull(PEDIMPDET.PID_GENERA_EMPDET,0) = (dbo.PEDIMPDETB.PIB_DESTNAFTA) and
					isnull(dbo.PEDIMPDET.PID_GENERA_EMPDET,0)=isnull(dbo.PEDIMPDETB.PIB_GENERA_EMPDET,0) and
					isnull(dbo.PEDIMPDET.PID_SERVICIO,'N')=isnull(dbo.PEDIMPDETB.PIB_SERVICIO,'N') 		
					AND dbo.PEDIMPDET.PID_IMPRIMIR='S'
				end
				else
				begin
					UPDATE dbo.PEDIMPDET
					SET     dbo.PEDIMPDET.PIB_INDICEB= dbo.PEDIMPDETB.PIB_INDICEB
					FROM         PEDIMP INNER JOIN
				                      PEDIMPDET ON PEDIMP.PI_CODIGO = PEDIMP.PI_CODIGO
					        CROSS JOIN dbo.PEDIMPDETB
					WHERE     (dbo.PEDIMPDETB.PI_CODIGO = @picodigo) and
					dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMPDETB.PI_CODIGO AND 
		--		             isnull(dbo.PEDIMPDET.MA_GENERICO,0) = isnull(dbo.PEDIMPDETB.MA_GENERICO,0) AND
				             isnull(dbo.PEDIMPDET.ME_GENERICO,0) = isnull(dbo.PEDIMPDETB.ME_GENERICO,0) AND
				             isnull(dbo.PEDIMPDET.AR_IMPMX,0) = isnull(dbo.PEDIMPDETB.AR_IMPMX,0) AND
		--		             isnull(dbo.PEDIMPDET.PA_PROCEDE,0) = isnull(dbo.PEDIMPDETB.PA_PROCEDE,0) and 
					isnull(dbo.PEDIMPDET.PA_ORIGEN,0) = isnull(dbo.PEDIMPDETB.PA_ORIGEN,0) and
					isnull(dbo.PEDIMPDET.AR_EXPFO,0)=isnull(dbo.PEDIMPDETB.AR_EXPFO,0) and 
					isnull(dbo.PEDIMPDET.PID_RATEEXPFO,0)=isnull(dbo.PEDIMPDETB.PIB_RATEEXPFO,0) and
					isnull(dbo.PEDIMPDET.EQ_EXPFO,1)=isnull(dbo.PEDIMPDETB.EQ_EXPFO,1) and 
					isnull(dbo.PEDIMPDET.PID_POR_DEF,-1)=isnull(dbo.PEDIMPDETB.PIB_POR_DEF,-1) 
					and (case when PEDIMP.PI_MOVIMIENTO='S' then (case when isnull(PEDIMPDET.PID_REGIONFIN, 'F')='N' or isnull(PEDIMPDET.PID_REGIONFIN, 'F')='M'
					then (case when PEDIMPDET.PID_DEF_TIP<>'S' and PEDIMPDET.PID_SERVICIO<>'S'
					then 'S' else 'N' end) else 'N' end) else (case when isnull(PEDIMPDET.PID_DEF_TIP, 'G')='P' then 'S'else 'N' end) end) = (dbo.PEDIMPDETB.PIB_DESTNAFTA) and
					isnull(dbo.PEDIMPDET.PID_NOMBRE,'')=isnull(dbo.PEDIMPDETB.PIB_NOMBRE,'') and
					isnull(dbo.PEDIMPDET.PID_GENERA_EMPDET,0)=isnull(dbo.PEDIMPDETB.PIB_GENERA_EMPDET,0) and
					isnull(dbo.PEDIMPDET.PID_SERVICIO,'N')=isnull(dbo.PEDIMPDETB.PIB_SERVICIO,'N') 		
					AND dbo.PEDIMPDET.PID_IMPRIMIR='S'
				end
	
			end

		end
	end


	IF (SELECT PICF_SAAIDIVDESC from PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='N'
	exec SP_UNENOMBREPIB @picodigo
GO
