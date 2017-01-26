SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_AGREGAFACTURA] (@picodigo int, @ficodigo int, @user int)    as

SET NOCOUNT ON 
declare @pid_indiced int, @pi_tip_cam decimal(38,6),  @pi_ft_adu decimal(38,9), @maximo int, @FechaActual varchar(10), @hora varchar(15),
@kap_indiced_ped int, @pid_saldogenr decimal(38,6),  @pid_can_genr decimal(38,6),@Sumkap_CantDesc decimal(38,6), @em_codigo int, @PI_USA_TIP_CAMFACT char(1),
@cp_rectifica int, @ccp_tipo2 varchar(5), @ccp_tipo varchar(5)


	select @ccp_tipo=ccp_tipo from configuraclaveped where cp_codigo in (select cp_codigo from pedimp where pi_codigo=@picodigo)


	ALTER TABLE PEDIMPDET DISABLE TRIGGER insert_pedimpdet

	select @em_codigo=em_codigo from intradeglobal.dbo.empresa where em_corto in
	(select replace(convert(sysname,db_name()),'intrade',''))



	IF (SELECT FC_CODIGO FROM PEDIMP WHERE PI_CODIGO=@picodigo) IS NOT NULL
	UPDATE FACTIMP
	SET FC_CODIGO=(SELECT FC_CODIGO FROM PEDIMP WHERE PI_CODIGO=@picodigo)
	WHERE FI_CODIGO=@ficodigo AND ISNULL(FC_CODIGO,0)<=0


select @FechaActual = convert(varchar(10), getdate(),101)
select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

	select @pi_tip_cam=pi_tip_cam, @pi_ft_adu=pi_ft_adu, @PI_USA_TIP_CAMFACT=PI_USA_TIP_CAMFACT,
	@cp_rectifica=cp_rectifica from pedimp where pi_codigo=@picodigo

	select @ccp_tipo2=ccp_tipo from configuraclaveped where cp_codigo=@cp_rectifica

	if @ccp_tipo='RE'
	UPDATE PEDIMP
	SET PEDIMP.PI_DESP_EQUIPO=isnull((SELECT pedimp1.PI_DESP_EQUIPO FROM PEDIMP pedimp1 WHERE pedimp1.PI_CODIGO=PEDIMP.PI_RECTIFICA),'N')
	WHERE PEDIMP.PI_CODIGO=@picodigo

	select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

	insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
	values (@user, 2, 'Llenando tabla temporal de detalle ', 'Filling Temporary Detail Table ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)


	if exists (select * from TempPedImpDet)
	begin
		TRUNCATE TABLE  TempPedImpDet

		--print 'borrando detalles temp'
	end

	dbcc checkident (TempPedimpdet, reseed, 1) WITH NO_INFOMSGS

	update factimpdet
	set FID_RATEEXPFO=0
	where fi_codigo =@ficodigo
	and (FID_RATEEXPFO<>0 or FID_RATEEXPFO is null)



		insert into TempPedImpDet(PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CANT, PID_CTOT_DLS, ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
				AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
				PA_PROCEDE, ME_GENERICO, PR_CODIGO, PID_ORD_COMP,
				PID_DESCARGABLE, PID_IMPRIMIR, CS_CODIGO, PID_COS_UNIVA, PID_COS_UNIMATGRA, PID_NOPARTEAUX, PID_CODIGOFACT, PID_CTOT_MN,
				PID_CAN_GEN, PID_CAN_AR, PID_GENERA_EMPDET, PID_PES_UNIKG, PID_SERVICIO, ME_ARIMPMX, PID_SECUENCIA)
		
		SELECT     @picodigo, ISNULL(VFillPedImpDet.MA_CODIGO,0), isnull(VFillPedImpDet.FID_NOPARTE,''), VFillPedImpDet.FID_NOMBRE, VFillPedImpDet.FID_NAME, 
		                      isnull(VFillPedImpDet.FID_CANT_ST,0), 
				        'PID_CTOT_DLS'=case when factimp.mo_codigo IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO <> 154 AND MONEDA.PA_CODIGO <> 233) 
				then isnull(VFillPedImpDet.FID_COS_TOT,0)*FACTIMP.FI_TIPOCAMBIO/@PI_TIP_CAM else isnull(VFillPedImpDet.FID_COS_TOT,0) end,
		                      VFillPedImpDet.ME_CODIGO, isnull(VFillPedImpDet.MA_GENERICO,0), 
		                      1, 1, isnull(VFillPedImpDet.AR_IMPMX,0), isnull(VFillPedImpDet.AR_EXPFO,0), 
		                      0, VFillPedImpDet.FID_SEC_IMP, isnull(VFillPedImpDet.FID_DEF_TIP, 'G'), isnull(VFillPedImpDet.FID_POR_DEF,-1), 
		                      isnull(VFillPedImpDet.TI_CODIGO,10), VFillPedImpDet.PA_CODIGO, VFillPedImpDet.SPI_CODIGO,isnull(DIR_CLIENTE.PA_CODIGO,233), --MAESTRO.PA_PROCEDE, 
		                      CASE WHEN VFillPedImpDet.ME_GEN=0 OR VFillPedImpDet.ME_GEN IS NULL THEN VFillPedImpDet.ME_CODIGO ELSE VFillPedImpDet.ME_GEN END, VFillPedImpDet.PR_CODIGO, 
					isnull(VFillPedImpDet.FID_ORD_COMP,0),
					'descargable'=case when FID_PADREKITINSERT='N' then (case when isnull(VFillPedImpDet.CS_CODIGO,8)=2 then 'N' else 'S' end)
					else 'S' end, 'S', isnull(VFillPedImpDet.CS_CODIGO,8), 0, 0, isnull(VFillPedImpDet.FID_NOPARTEAUX,''), VFillPedImpDet.FID_INDICED, 
				'PID_CTOT_MN'=case when factimp.mo_codigo IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154) then isnull(VFillPedImpDet.FID_COS_TOT,0) else (case when @PI_USA_TIP_CAMFACT<>'S' and factimp.mo_codigo IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 233) then  isnull(VFillPedImpDet.FID_COS_TOT,0)*@PI_TIP_CAM else isnull(VFillPedImpDet.FID_COS_TOT,0)*FACTIMP.FI_TIPOCAMBIO end) end,
				 round(isnull(VFillPedImpDet.FID_CANT_ST,0)*isnull(VFillPedImpDet.EQ_GEN,1),6),
				 'PID_CAN_AR'=case when VFillPedImpDet.FID_CANT_ST=0 and VFillPedImpDet.ME_ARIMPMX in (select ME_KILOGRAMOS from configuracion) then VFillPedImpDet.FID_PES_NET
				else round(isnull(VFillPedImpDet.FID_CANT_ST,0)*isnull(VFillPedImpDet.EQ_IMPMX,1),6) end, FID_GENERA_EMPDET, VFillPedImpDet.PID_PES_UNIKG,
				ISNULL(MAESTRO.MA_SERVICIO,'N'), VFillPedImpDet.ME_ARIMPMX, isnull(FID_PIDSECUENCIA,0)
		FROM         FACTIMP LEFT OUTER JOIN
		                      DIR_CLIENTE ON FACTIMP.DI_PROVEE = DIR_CLIENTE.DI_INDICE LEFT OUTER JOIN
		                      VFillPedImpDet ON FACTIMP.FI_CODIGO = VFillPedImpDet.FI_CODIGO LEFT OUTER JOIN
		                      MAESTRO ON VFillPedImpDet.MA_CODIGO = MAESTRO.MA_CODIGO 
		WHERE     (FACTIMP.FI_CODIGO = @ficodigo) and (VFillPedImpDet.MA_CODIGO is not null)
		ORDER BY FACTIMP.FI_CODIGO, VFillPedImpDet.FID_INDICED






	select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

	insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
	values (@user, 2, 'Generando calculos (detalle Pedimento)', 'Generating calculations (Detail Pedimento) ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)


	update Temppedimpdet
	set ME_ARIMPMX=(select me_codigo from arancel where ar_codigo=Temppedimpdet.AR_IMPMX)


	update Temppedimpdet  
	set EQ_GENERICO= round(PID_CAN_GEN/PID_CANT,6),
	 EQ_IMPMX=round(PID_CAN_AR/PID_CANT,6)
	where PID_CANT >0


	update Temppedimpdet
	set EQ_GENERICO=1 
	where EQ_GENERICO is null or EQ_GENERICO=0


	if exists (select fi_codigo from factimp where (pi_codigo=@picodigo or pi_rectifica=@picodigo) and mo_codigo IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154))
	begin

		/* el valor en aduana debe de estar en la unidad de medida del grupo generico por esto se divide entre el eq_generico*/
		update Temppedimpdet
		set PID_COS_UNI=round(((PID_CTOT_DLS)/@PI_TIP_CAM)/PID_CANT,6,6),
		PID_COS_UNIgen= round((((PID_CTOT_DLS)/@PI_TIP_CAM)/PID_CANT)/ EQ_GENERICO,6,6),
		PID_COS_UNIADU= round(round(round(PID_CTOT_MN * @pi_ft_adu,0)/isnull(PID_CANT,1),6)/EQ_GENERICO,6,6),
		PID_VAL_ADU= round(PID_CTOT_MN * @pi_ft_adu,0,0)
		where PID_CANT >0 and PID_CTOT_DLS>0 and pi_codigo=@picodigo and pid_imprimir='S'
	
	
		update Temppedimpdet
		set PID_COS_UNI=round(((PID_CTOT_DLS)/@PI_TIP_CAM)/PID_CANT,6,6),
		PID_COS_UNIgen= round((((PID_CTOT_DLS)/@PI_TIP_CAM)/PID_CANT)/ EQ_GENERICO,6,6),
		PID_COS_UNIADU= round(round(round(PID_CTOT_MN,0)/isnull(PID_CANT,0),6)/EQ_GENERICO,6,6),
		PID_VAL_ADU= round(PID_CTOT_MN,0,0)
		where PID_CANT >0 and PID_CTOT_DLS>0 and pi_codigo=@picodigo and pid_imprimir<>'S'
	
		update Temppedimpdet
		set PID_COS_UNI=round(PID_CTOT_DLS/@PI_TIP_CAM,6,6),
		PID_COS_UNIgen= round(((PID_CTOT_DLS)/@PI_TIP_CAM)/ EQ_GENERICO,6,6),
		PID_COS_UNIADU= round(round(PID_CTOT_MN * @pi_ft_adu,0)/EQ_GENERICO,6,6),
		PID_VAL_ADU= round(PID_CTOT_MN * @pi_ft_adu,0,0)
		where PID_CANT =0 and PID_CTOT_DLS>0 and pi_codigo=@picodigo and pid_imprimir='S'
	
		update Temppedimpdet
		set PID_COS_UNI=round(PID_CTOT_DLS/@PI_TIP_CAM,6,6),
		PID_COS_UNIgen= round(((PID_CTOT_DLS)/@PI_TIP_CAM)/ EQ_GENERICO,6,6),
		PID_COS_UNIADU= round(round(PID_CTOT_MN,0)/EQ_GENERICO,6,6),
		PID_VAL_ADU= round(PID_CTOT_MN,0,0)
		where PID_CANT =0 and PID_CTOT_DLS>0 and pi_codigo=@picodigo and pid_imprimir<>'S'


		update Temppedimpdet
		set PID_CTOT_DLS=round((PID_CTOT_DLS)/@PI_TIP_CAM,6,6)
		where PID_CANT >0 and PID_CTOT_DLS>0 and pi_codigo=@picodigo 

	end
	else
	begin
		/* el valor en aduana debe de estar en la unidad de medida del grupo generico por esto se divide entre el eq_generico*/
		update Temppedimpdet
		set PID_COS_UNI=round((PID_CTOT_DLS)/PID_CANT,6,6),
		PID_COS_UNIgen= round(((PID_CTOT_DLS)/PID_CANT)/ EQ_GENERICO,6,6),
		PID_COS_UNIADU= round(round(round(PID_CTOT_MN * @pi_ft_adu,0)/isnull(PID_CANT,0),6)/EQ_GENERICO,6,6),
		PID_VAL_ADU= round(PID_CTOT_MN * @pi_ft_adu,0,0)
		where PID_CANT >0 and PID_CTOT_DLS>0 and pi_codigo=@picodigo and pid_imprimir='S'
	
	
		update Temppedimpdet
		set PID_COS_UNI=round((PID_CTOT_DLS)/PID_CANT,6,6),
		PID_COS_UNIgen= round(((PID_CTOT_DLS)/PID_CANT)/ EQ_GENERICO,6,6),
		PID_COS_UNIADU= round(round(round(PID_CTOT_MN,0)/isnull(PID_CANT,0),6)/EQ_GENERICO,6,6),
		PID_VAL_ADU= round(PID_CTOT_MN,0,0)
		where PID_CANT >0 and PID_CTOT_DLS>0 and pi_codigo=@picodigo and pid_imprimir<>'S'
	
		update Temppedimpdet
		set PID_COS_UNI=round(PID_CTOT_DLS,6,6),
		PID_COS_UNIgen= round((PID_CTOT_DLS)/ EQ_GENERICO,6,6),
		PID_COS_UNIADU= round(round(PID_CTOT_MN * @pi_ft_adu,0)/EQ_GENERICO,6,6),
		PID_VAL_ADU= round(PID_CTOT_MN * @pi_ft_adu,0,0)
		where PID_CANT =0 and PID_CTOT_DLS>0 and pi_codigo=@picodigo and pid_imprimir='S'
	
		update Temppedimpdet
		set PID_COS_UNI=round(PID_CTOT_DLS,6,6),
		PID_COS_UNIgen= round((PID_CTOT_DLS)/ EQ_GENERICO,6,6),
		PID_COS_UNIADU= round(round(PID_CTOT_MN,0)/EQ_GENERICO,6,6),
		PID_VAL_ADU= round(PID_CTOT_MN,0,0)
		where PID_CANT =0 and PID_CTOT_DLS>0 and pi_codigo=@picodigo and pid_imprimir<>'S'

	end


	update Temppedimpdet
	set PID_COS_UNI=0,
	PID_COS_UNIgen= 0,
	PID_COS_UNIADU=0,
	PID_VAL_ADU= 0
	where PID_CANT >0 and PID_CTOT_DLS=0 and pi_codigo=@picodigo 

	

	/*actualizando saldo */
	update Temppedimpdet  
	set pid_saldogen = round(isnull(PID_CANT,0) * isnull(EQ_GENERICO,1),6,6)
	where pid_descargable<>'N'

	update Temppedimpdet  
	set pid_saldogen = 0
	where pid_descargable='N'	


	update Temppedimpdet
	set PID_COS_UNI=0,
	PID_COS_UNIgen= 0,
	PID_COS_UNIADU= 0,
--	PID_CAN_GEN = 0,
--	PID_CAN_AR =0,
	PID_VAL_ADU= 0
	where PID_CANT =0 and PID_CTOT_DLS=0 and pi_codigo=@picodigo 



	update factimpdet
	set spi_codigo=0
	where fid_def_tip<>'P' and fi_codigo =@ficodigo



	update factimpdet
	set fid_sec_imp=0
	where fid_def_tip<>'S' and fi_codigo =@ficodigo


	update Temppedimpdet
	set SPI_CODIGO= 0
	where PID_DEF_TIP<>'P' and pi_codigo=@picodigo 

	update Temppedimpdet
	set PID_SEC_IMP= 0
	where PID_DEF_TIP<>'S' and pi_codigo=@picodigo 



	select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

	insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
	values (@user, 2, 'Llenando Campo:Paga Contribuciones (detalle Pedimento)', 'Filling Field:Pay Duties (Detail Pedimento) ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)

		if (select pi_llenacheckPagaContrib from configurapedimento)='S'
		exec SP_ACTUALIZAPI_PAGACONTRIB @picodigo


	if (select cf_descargas from configuracion)<>'N'
	begin


		select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)
	
		insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
		values (@user, 2, 'Llenando Saldos de Pedimento ', 'Filling Pedimento Balance', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)
	
		-- llenado de la tabla pidescarga
		if @ccp_tipo in ('IT', 'IV', 'OC', 'TR', 'VT', 'RG', 'IR', 'IB', 'RE', 'IA', 'IM', 'ED')
		exec AgregaFacturaFillPIDescarga @picodigo, @user
		
		
		
		if  @ccp_tipo in ('IE', 'RG', 'SI') 
		begin
			if (select CF_USASALDOPEDIMPDEFINITO from configuracion)='S' or (select cp_descargable from claveped where cp_codigo in (select cp_codigo from pedimp where pi_codigo=@picodigo))='S'
			exec AgregaFacturaFillPIDescarga @picodigo, @user
		
		end
	end

	if (select min(pid_indiced) from TempPedImpDet)=0
	SELECT     @maximo= isnull(MAX(PID_INDICED),0)+1
	FROM         PEDIMPDET
	else
	SELECT     @maximo= isnull(MAX(PID_INDICED),1)
	FROM         PEDIMPDET

	


ALTER TABLE FACTIMPDET DISABLE trigger Update_FactImpDet


	insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
	values (@user, 2, 'Borrando Liga anterior en Facturas ', 'Deleting previous link in Invoices ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)

declare @pidindicedmin int, @pidindicedmax int

select @pidindicedmin =min(pid_indiced)+@maximo from TempPedImpDet
select @pidindicedmax =min(pid_indiced)+@maximo from TempPedImpDet



select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

	insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
	values (@user, 2, 'Llenando detalle Pedimento ', 'Filling Detail Pedimento ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)



	exec sp_FillDetalle @picodigo, @maximo, @user


	select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

	insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
	values (@user, 2, 'Ligando detalle Pedimento - Detalle Factura ', 'Linking Pedimento Detail - Invoice Detail ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)


	if @ccp_tipo<>'RE'
		begin

			UPDATE FACTIMPDET
			SET     FACTIMPDET.PID_INDICEDLIGA =PEDIMPDET.PID_INDICED
				FROM         FACTIMPDET INNER JOIN
  	                            PEDIMPDET ON FACTIMPDET.FID_INDICED = PEDIMPDET.PID_CODIGOFACT 			
			WHERE PEDIMPDET.PI_CODIGO=@picodigo AND FACTIMPDET.FI_CODIGO=@ficodigo


			UPDATE PEDIMPDET 
			SET     PEDIMPDET.PID_CODIGOFACT =FACTIMPDET.FI_CODIGO
			FROM         FACTIMPDET INNER JOIN
  	                            PEDIMPDET ON FACTIMPDET.PID_INDICEDLIGA = PEDIMPDET.PID_INDICED 			
			WHERE PEDIMPDET.PI_CODIGO=@picodigo AND FACTIMPDET.FI_CODIGO=@ficodigo

		end
		else
		begin
			UPDATE FACTIMPDET
			SET     FACTIMPDET.PID_INDICEDLIGAR1 =PEDIMPDET.PID_INDICED
			FROM         FACTIMPDET INNER JOIN
  	                            PEDIMPDET ON FACTIMPDET.FID_INDICED = PEDIMPDET.PID_CODIGOFACT 			
			WHERE PEDIMPDET.PI_CODIGO=@picodigo AND FACTIMPDET.FI_CODIGO=@ficodigo


			UPDATE PEDIMPDET 
			SET     PEDIMPDET.PID_CODIGOFACT =FACTIMPDET.FI_CODIGO
			FROM         FACTIMPDET INNER JOIN
  	                            PEDIMPDET ON FACTIMPDET.PID_INDICEDLIGAR1 = PEDIMPDET.PID_INDICED 			
			WHERE PEDIMPDET.PI_CODIGO=@picodigo AND FACTIMPDET.FI_CODIGO=@ficodigo


		end	


ALTER TABLE FACTIMPDET ENABLE trigger Update_FactImpDet

--	end



select @Pid_indiced= max(pid_indiced) from pedimpdet

	update consecutivo
	set cv_codigo =  isnull(@pid_indiced,0) + 1
	where cv_tipo = 'PID'


	ALTER TABLE PEDIMPDET ENABLE TRIGGER insert_pedimpdet




	if (select CF_GENAUTFACTEXPPO from configuracion)='S'
	begin
		select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)
	
		Insert Into IntradeGlobal.dbo.Avance (sysuslst_id,ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
		values(@user,2.1,'Generando Documentos de Salida Base PO ','Generating Export Documents basis PO ',@FechaActual,@Hora, @em_codigo)

		--exec SP_GENAUTFACTEXPPOFI @picodigo, @ficodigo
		
		--Yolanda 2008-12-31	
   		exec SP_GENAUTFACTEXPPO @picodigo, @ficodigo, 2

	end



	exec SP_ACTUALIZAESTATUSPEDIMP @picodigo

GO
