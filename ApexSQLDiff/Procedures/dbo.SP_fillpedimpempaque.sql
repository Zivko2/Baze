SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_fillpedimpempaque] (@picodigo int, @user int)   as

SET NOCOUNT ON 
declare @CF_MAN_EMPAQUE char(1), @CF_EMPDESPIMP char(1), @hora varchar(15), @FechaActual varchar(10), 
@pi_tip_cam decimal(38,6), @pi_ft_adu decimal(38,9), @em_codigo int, @maximo int, @ccp_tipo varchar(5)

	SELECT     @CF_MAN_EMPAQUE= CF_MAN_EMPAQUE, @CF_EMPDESPIMP=CF_EMPDESPIMP
	FROM         CONFIGURACION
	

	select @em_codigo=em_codigo from intradeglobal.dbo.empresa where em_corto in
	(select replace(convert(sysname,db_name()),'intrade',''))

	select @FechaActual = convert(varchar(10), getdate(),101)
	select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

	select @ccp_tipo=@ccp_tipo from configuraclaveped where cp_codigo in
	(select cp_codigo from pedimp where pi_codigo=@picodigo)

	select @pi_tip_cam=pi_tip_cam, @pi_ft_adu=pi_ft_adu from pedimp where pi_codigo=@picodigo



	if exists( select * from pedimpdet where pi_codigo=@picodigo and pid_imprimir='N' and
	ti_codigo in (select ti_codigo from configuratipo where cft_tipo='E'))
	delete from pedimpdet where pi_codigo=@picodigo and pid_imprimir='N' and
	ti_codigo in (select ti_codigo from configuratipo where cft_tipo='E')


	TRUNCATE TABLE TempPedImpDet


	dbcc checkident (TempPedimpdet, reseed, 1) WITH NO_INFOMSGS

	SELECT     @maximo= isnull(MAX(PID_INDICED),0)+1
	FROM         PEDIMPDET

	IF @CF_EMPDESPIMP='S' /* si la empresa quiere llevar el control del empaque que importa como desperdicio */
	begin
			if @ccp_tipo<>'RE'
  				exec fillpedimpemp @picodigo, @user		
			else
				exec fillpedimpemp_rect @picodigo, @user		

			if exists (select * from pedimpdet where pi_codigo= @picodigo and pid_imprimir='N' )  /*inserta en almacendesp los empaques del pedimpdet */
			exec fillpedimpempalm  @picodigo, @user


			update Temppedimpdet
			set ME_ARIMPMX=(select me_codigo from arancel where ar_codigo=Temppedimpdet.AR_IMPMX)
		
			update Temppedimpdet
			set EQ_GENERICO=1 
			where EQ_GENERICO is null or EQ_GENERICO=0
		
		
				/* el valor en aduana debe de estar en la unidad de medida del grupo generico por esto se divide entre el eq_generico*/
				update Temppedimpdet
				set PID_COS_UNI=round((PID_CTOT_DLS)/PID_CANT,6),
				PID_COS_UNIgen= round(((PID_CTOT_DLS)/PID_CANT)/ EQ_GENERICO,6),
		--		PID_COS_UNIADU= round(round(PID_CTOT_DLS * @PI_TIP_CAM * @pi_ft_adu,0)/isnull(PID_CANT,0),6)/EQ_GENERICO,
				PID_COS_UNIADU= round(round(PID_CTOT_MN * @pi_ft_adu,0)/isnull(PID_CANT,0),6)/EQ_GENERICO,
				PID_CAN_GEN = round(isnull(PID_CANT,0) * isnull(EQ_GENERICO,1),6),
				PID_CAN_AR =round(PID_CANT * EQ_IMPMX,6),
				PID_VAL_ADU= round(PID_CTOT_MN * @pi_ft_adu,0)
		--		PID_VAL_ADU= round(PID_CTOT_DLS * @PI_TIP_CAM * @pi_ft_adu,0)
				where PID_CANT >0 and PID_CTOT_DLS>0 and pi_codigo=@picodigo and pid_imprimir='S'
			
			
				update Temppedimpdet
				set PID_COS_UNI=round((PID_CTOT_DLS)/PID_CANT,6),
				PID_COS_UNIgen= round(((PID_CTOT_DLS)/PID_CANT)/ EQ_GENERICO,6),
		--		PID_COS_UNIADU= round(round(PID_CTOT_DLS * @PI_TIP_CAM,0)/isnull(PID_CANT,0),6)/EQ_GENERICO,
				PID_COS_UNIADU= round(round(PID_CTOT_MN,0)/isnull(PID_CANT,0),6)/EQ_GENERICO,
				PID_CAN_GEN = round(isnull(PID_CANT,0) * isnull(EQ_GENERICO,1),6),
				PID_CAN_AR =round(PID_CANT * EQ_IMPMX,6),
		--		PID_VAL_ADU= round(PID_CTOT_DLS * @PI_TIP_CAM,0)
				PID_VAL_ADU= round(PID_CTOT_MN,0)
				where PID_CANT >0 and PID_CTOT_DLS>0 and pi_codigo=@picodigo and pid_imprimir<>'S'
			
				update Temppedimpdet
				set PID_COS_UNI=round(PID_CTOT_DLS,6),
				PID_COS_UNIgen= round((PID_CTOT_DLS)/ EQ_GENERICO,6),
		--		PID_COS_UNIADU= round(PID_CTOT_DLS * @PI_TIP_CAM * @pi_ft_adu,0)/EQ_GENERICO,
				PID_COS_UNIADU= round(PID_CTOT_MN * @pi_ft_adu,0)/EQ_GENERICO,
				PID_CAN_GEN = 0,
				PID_CAN_AR =0,
		--		PID_VAL_ADU= round(PID_CTOT_DLS* @PI_TIP_CAM * @pi_ft_adu,0)
				PID_VAL_ADU= round(PID_CTOT_MN * @pi_ft_adu,0)
				where PID_CANT =0 and PID_CTOT_DLS>0 and pi_codigo=@picodigo and pid_imprimir='S'
			
				update Temppedimpdet
				set PID_COS_UNI=round(PID_CTOT_DLS,6),
				PID_COS_UNIgen= round((PID_CTOT_DLS)/ EQ_GENERICO,6),
		--		PID_COS_UNIADU= round(PID_CTOT_DLS* @PI_TIP_CAM,0)/EQ_GENERICO,
				PID_COS_UNIADU= round(PID_CTOT_MN,0)/EQ_GENERICO,
				PID_CAN_GEN = 0,
				PID_CAN_AR =0,
		--		PID_VAL_ADU= round(PID_CTOT_DLS* @PI_TIP_CAM,0)
				PID_VAL_ADU= round(PID_CTOT_MN,0)
				where PID_CANT =0 and PID_CTOT_DLS>0 and pi_codigo=@picodigo and pid_imprimir<>'S'
		
		
		
		
			update Temppedimpdet
			set PID_COS_UNI=0,
			PID_COS_UNIgen= 0,
			PID_COS_UNIADU=0,
			PID_CAN_GEN = round(isnull(PID_CANT,0) * isnull(EQ_GENERICO,1),6),
			PID_CAN_AR =round(PID_CANT * EQ_IMPMX,6),
			PID_VAL_ADU= 0
			where PID_CANT >0 and PID_CTOT_DLS=0 and pi_codigo=@picodigo 
		
		
		
			/*actualizando saldo */
			update Temppedimpdet  
			set pid_saldogen = round(isnull(PID_CANT,0) * isnull(EQ_GENERICO,1),6)
			where pid_descargable<>'N'
		
			update Temppedimpdet  
			set pid_saldogen = 0
			where pid_descargable='N'	
		
			update Temppedimpdet
			set PID_COS_UNI=0,
			PID_COS_UNIgen= 0,
			PID_COS_UNIADU= 0,
			PID_CAN_GEN = 0,
			PID_CAN_AR =0,
			PID_VAL_ADU= 0
			where PID_CANT =0 and PID_CTOT_DLS=0 and pi_codigo=@picodigo 
		
		
		select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)
		
			insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
			values (@user, 2, 'Llenando detalle Pedimento ', 'Filling Detail Pedimento ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)
		
		exec SP_ACTUALIZAPI_PAGACONTRIB @picodigo
		
		
			-- llenado de la tabla pidescarga
			if @ccp_tipo in ('IT', 'IV', 'OC', 'TR', 'VT', 'RG', 'IR', 'IB', 'RE', 'IA', 'IM', 'ED')
			exec FillPIDescarga @picodigo, @user
			
			exec ReemplazaDescargasR1 @picodigo, @user, @ccp_tipo
		
		INSERT INTO PEDIMPDET(PI_CODIGO, PID_INDICED, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_COS_UNI, PID_COS_UNIADU, PID_COS_UNIGEN, 
		                      PID_COS_UNIVA, PID_COS_UNIMATGRA, PID_CANT, PID_CAN_AR, PID_CAN_GEN, PID_VAL_ADU, PID_CTOT_DLS, PID_ORD_COMP,
		                      ME_CODIGO, ME_GENERICO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, AR_IMPMX, ME_ARIMPMX, AR_EXPFO, 
		                      PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, CS_CODIGO, TI_CODIGO, PA_ORIGEN, PA_PROCEDE,  SPI_CODIGO, PR_CODIGO, PID_IMPRIMIR, 
			         PID_DESCARGABLE, PID_PAGACONTRIB, PID_NOPARTEAUX, PID_CODIGOFACT, PID_SECUENCIA)
		
		SELECT     PI_CODIGO, PID_INDICED+@maximo, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_COS_UNI, PID_COS_UNIADU, PID_COS_UNIGEN, 
		                      PID_COS_UNIVA, PID_COS_UNIMATGRA, PID_CANT, PID_CAN_AR, PID_CAN_GEN, PID_VAL_ADU, PID_CTOT_DLS, PID_ORD_COMP,
		                      ME_CODIGO, ME_GENERICO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, AR_IMPMX, ME_ARIMPMX, AR_EXPFO, 
		                      PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, CS_CODIGO, TI_CODIGO, PA_ORIGEN, PA_PROCEDE, SPI_CODIGO, PR_CODIGO, PID_IMPRIMIR, 
			         PID_DESCARGABLE, PID_PAGACONTRIB, PID_NOPARTEAUX, PID_CODIGOFACT, PID_INDICED
		FROM         TempPedImpDet
		where pi_codigo=@picodigo  
		ORDER BY pid_indiced
	


	end


























GO
