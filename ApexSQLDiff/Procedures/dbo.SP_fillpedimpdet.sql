SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_fillpedimpdet] (@picodigo int, @ccp_tipo varchar(5), @user int)    as

SET NOCOUNT ON 
declare @pid_indiced int, @pi_tip_cam decimal(38,6),  @pi_ft_adu decimal(38,9), @maximo int, @FechaActual varchar(10), @hora varchar(15),
@kap_indiced_ped int, @pid_saldogenr decimal(38,6),  @pid_can_genr decimal(38,6),@Sumkap_CantDesc decimal(38,6), @em_codigo int, @PI_USA_TIP_CAMFACT char(1),
@cp_rectifica int, @ccp_tipo2 varchar(5), @PICF_SAAIDETDIVPO char(1)

	ALTER TABLE PEDIMPDET DISABLE TRIGGER insert_pedimpdet

	select @em_codigo=em_codigo from intradeglobal.dbo.empresa where em_corto in
	(select replace(convert(sysname,db_name()),'intrade',''))



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


		TRUNCATE TABLE TempPedImpDet

		--print 'borrando detalles temp'

	dbcc checkident (TempPedimpdet, reseed, 1) WITH NO_INFOMSGS

	update factimpdet
	set FID_RATEEXPFO=0
	where fi_codigo in (select fi_codigo from factimp where pi_codigo=@picodigo or pi_rectifica=@picodigo)
	and (FID_RATEEXPFO<>0 or FID_RATEEXPFO is null)


	/* comentado ya que nunca debe cambiar la fraccion de la factura al ligar con el pedimento.
	if (select CF_VAL_PED from configuracion) ='S' 
	if  (@ccp_tipo in ('IE', 'RG', 'SI', 'CN') 
	and ((select PI_GENERASALDOF4 from pedimp where pi_codigo =@picodigo)<>'S') 
                       and ((select PI_DESP_EQUIPO from pedimp where pi_codigo =@picodigo)<>'S')) or @ccp_tipo not in ('IE', 'RG', 'SI', 'CN', 'IM', 'IB') 
		if (SELECT COUNT(*) FROM FACTIMP INNER JOIN TEMBARQUE ON FACTIMP.TQ_CODIGO = TEMBARQUE.TQ_CODIGO
		     WHERE TEMBARQUE.TQ_NOMBRE LIKE '%CASO ESPECIAL%' AND (FACTIMP.PI_CODIGO = @picodigo or FACTIMP.PI_RECTIFICA = @picodigo))=0

			update factimpdet
			set AR_IMPMX=(SELECT min(fi1.ar_impmx) from factimpdet fi1 inner join factimp fi2 on fi1.fi_codigo=fi2.fi_codigo where (fi2.pi_codigo=@picodigo or fi2.pi_rectifica=@picodigo) and fi1.ma_codigo=factimpdet.ma_codigo)
			where fi_codigo in (select fi_codigo from factimp where pi_codigo=@picodigo or pi_rectifica=@picodigo)
			and  isnull((SELECT min(fi1.ar_impmx) from factimpdet fi1 inner join factimp fi2 on fi1.fi_codigo=fi2.fi_codigo where (fi2.pi_codigo=@picodigo or fi2.pi_rectifica=@picodigo) and fi1.ma_codigo=factimpdet.ma_codigo),0)>0

	*/


	SELECT @PICF_SAAIDETDIVPO=PICF_SAAIDETDIVPO  FROM PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo



	IF (SELECT PICF_PEDIMPSECFACT FROM PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='S'--  la secuencia viene de la factura
	update PEDIMPSAAICONFIG
	set PICF_PEDIMPSINAGRUP='S', PICF_AGRUPASAAISEC='S'
	where  PI_CODIGO=@picodigo


	IF (SELECT PICF_PEDIMPSINAGRUP FROM PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='S'--  no se hace ninguna agrupacion
	begin

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
		                      0, VFillPedImpDet.FID_SEC_IMP,ISNULL(CASE WHEN VFillPedImpDet.FID_DEF_TIP = 'E' THEN 'G' ELSE VFillPedImpDet.FID_DEF_TIP END,'G'),isnull(CASE WHEN VFillPedImpDet.FID_DEF_TIP = 'E' THEN 0 ELSE VFillPedImpDet.FID_POR_DEF END,-1), 
		                      isnull(VFillPedImpDet.TI_CODIGO,10), VFillPedImpDet.PA_CODIGO, VFillPedImpDet.SPI_CODIGO,isnull(DIR_CLIENTE.PA_CODIGO,233), --MAESTRO.PA_PROCEDE, 
		                      CASE WHEN VFillPedImpDet.ME_GEN=0 OR VFillPedImpDet.ME_GEN IS NULL THEN VFillPedImpDet.ME_CODIGO ELSE VFillPedImpDet.ME_GEN END, VFillPedImpDet.PR_CODIGO, 
					isnull(VFillPedImpDet.FID_ORD_COMP,0),
					'descargable'=case when FID_PADREKITINSERT='N' then (case when isnull(VFillPedImpDet.CS_CODIGO,8)=2 then 'N' else 'S' end)
					else 'S' end, 'S', isnull(VFillPedImpDet.CS_CODIGO,8), 0, 0, isnull(VFillPedImpDet.FID_NOPARTEAUX,''), VFillPedImpDet.FID_INDICED, 
				'PID_CTOT_MN'=case when factimp.mo_codigo IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154) then isnull(VFillPedImpDet.FID_COS_TOT,0) else (case when @PI_USA_TIP_CAMFACT<>'S' and factimp.mo_codigo IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 233) then  isnull(VFillPedImpDet.FID_COS_TOT,0)*@PI_TIP_CAM else isnull(VFillPedImpDet.FID_COS_TOT,0)*FACTIMP.FI_TIPOCAMBIO end) end,
				 round(isnull(VFillPedImpDet.FID_CANT_ST,0)*isnull(VFillPedImpDet.EQ_GEN,1),6),
				 'PID_CAN_AR'=case when VFillPedImpDet.FID_CANT_ST=0 and VFillPedImpDet.ME_ARIMPMX in (select ME_KILOGRAMOS from configuracion) then VFillPedImpDet.FID_PES_NET
				else round(isnull(VFillPedImpDet.FID_CANT_ST,0)*isnull(VFillPedImpDet.EQ_IMPMX,1),6) end, FID_GENERA_EMPDET, VFillPedImpDet.PID_PES_UNIKG,
				CASE WHEN VFillPedImpDet.fid_def_tip = 'E' THEN 'S' ELSE 'N' END, VFillPedImpDet.ME_ARIMPMX, isnull(FID_PIDSECUENCIA,0)
		FROM         FACTIMP LEFT OUTER JOIN
		                      DIR_CLIENTE ON FACTIMP.DI_PROVEE = DIR_CLIENTE.DI_INDICE LEFT OUTER JOIN
		                      VFillPedImpDet ON FACTIMP.FI_CODIGO = VFillPedImpDet.FI_CODIGO LEFT OUTER JOIN
		                      MAESTRO ON VFillPedImpDet.MA_CODIGO = MAESTRO.MA_CODIGO 
		WHERE     (FACTIMP.PI_CODIGO = @picodigo or FACTIMP.PI_RECTIFICA = @picodigo) and (VFillPedImpDet.MA_CODIGO is not null)
		ORDER BY FACTIMP.FI_CODIGO, VFillPedImpDet.FID_INDICED

		if exists (select * from factimpdet, factimp where factimp.pi_codigo=@picodigo and factimpdet.cs_codigo=2 and factimpdet.FID_PADREKITINSERT='N'
		and factimp.fi_codigo=factimpdet.fi_codigo)
	
		exec fillpedimpdetkit @picodigo, @user

		begin
			exec fillpedimpemp @picodigo, @user		/*inserta en el detalle los empaques de la factura */
		end

	end
	else  -- se agrupa el detalle del pedimento
	begin
		IF (SELECT PICF_SAAIDETDIVFACT FROM PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='S'
		begin
	
			
	
			if @ccp_tipo in ('IA', 'IM') or ((select PI_DESP_EQUIPO from pedimp where pi_codigo=@picodigo) ='S' and @ccp_tipo in ('VT', 'IV', 'EV', 'IE'))
			or (SELECT COUNT(*) FROM FACTIMP INNER JOIN TEMBARQUE ON FACTIMP.TQ_CODIGO = TEMBARQUE.TQ_CODIGO
			     WHERE TEMBARQUE.TQ_NOMBRE LIKE '%CASO ESPECIAL%' AND (FACTIMP.PI_CODIGO = @picodigo or FACTIMP.PI_RECTIFICA = @picodigo))>0
			-- activo fijo, la diferencia es que agrupa por desc. en espaniol y costo unitario
			begin
					insert into TempPedImpDet(PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CANT, PID_CTOT_DLS, ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
							AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
							PA_PROCEDE, ME_GENERICO, PR_CODIGO, PID_ORD_COMP,
							PID_DESCARGABLE, PID_IMPRIMIR, CS_CODIGO, PID_COS_UNIVA, PID_COS_UNIMATGRA, PID_NOPARTEAUX, PID_CODIGOFACT, PID_CTOT_MN,
							PID_CAN_GEN, PID_CAN_AR, PID_GENERA_EMPDET, PID_PES_UNIKG, PID_SERVICIO, ME_ARIMPMX)
					
					SELECT     @picodigo, ISNULL(VFillPedImpDet.MA_CODIGO,0), isnull(VFillPedImpDet.FID_NOPARTE,''), VFillPedImpDet.FID_NOMBRE, MAX(VFillPedImpDet.FID_NAME), 
					                      SUM(isnull(VFillPedImpDet.FID_CANT_ST,0)), 
		   				        'PID_CTOT_DLS'=case when max(factimp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO <> 154 AND MONEDA.PA_CODIGO <> 233) 
							then SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)*FACTIMP.FI_TIPOCAMBIO)/@PI_TIP_CAM else SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)) end,
					                      VFillPedImpDet.ME_CODIGO, isnull(VFillPedImpDet.MA_GENERICO,0), 
					                      1, 1, isnull(max(VFillPedImpDet.AR_IMPMX),0), isnull(max(VFillPedImpDet.AR_EXPFO),0), 
					                      0, VFillPedImpDet.FID_SEC_IMP,ISNULL(CASE WHEN VFillPedImpDet.FID_DEF_TIP = 'E' THEN 'G' ELSE VFillPedImpDet.FID_DEF_TIP END,'G'),isnull(CASE WHEN VFillPedImpDet.FID_DEF_TIP = 'E' THEN 0 ELSE VFillPedImpDet.FID_POR_DEF END,-1), 
					                      MAX(isnull(VFillPedImpDet.TI_CODIGO,10)), VFillPedImpDet.PA_CODIGO, VFillPedImpDet.SPI_CODIGO,isnull(DIR_CLIENTE.PA_CODIGO,233), --MAESTRO.PA_PROCEDE, 
					                      CASE WHEN max(VFillPedImpDet.ME_GEN)=0 OR max(VFillPedImpDet.ME_GEN) IS NULL THEN max(VFillPedImpDet.ME_CODIGO) ELSE max(VFillPedImpDet.ME_GEN) END, MAX(VFillPedImpDet.PR_CODIGO), 
								CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(VFillPedImpDet.FID_ORD_COMP,0) else 0 end,
								'descargable'=case when FID_PADREKITINSERT='N' then (case when isnull(VFillPedImpDet.CS_CODIGO,8)=2 then 'N' else 'S' end)
								else 'S' end, 'S', isnull(VFillPedImpDet.CS_CODIGO,8), 0, 0, max(isnull(VFillPedImpDet.FID_NOPARTEAUX,'')), VFillPedImpDet.FI_CODIGO, 
							'PID_CTOT_MN'=case when max(factimp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154) then SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)) else (case when @PI_USA_TIP_CAMFACT<>'S' and max(factimp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 233) then  SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)*@PI_TIP_CAM) else SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)*FACTIMP.FI_TIPOCAMBIO) end) end,
							 round(SUM(isnull(VFillPedImpDet.FID_CANT_ST,0)*isnull(VFillPedImpDet.EQ_GEN,1)),6),
							 'PID_CAN_AR'=case when SUM(isnull(VFillPedImpDet.FID_CANT_ST,0))=0 and MAX(VFillPedImpDet.ME_ARIMPMX) in (select ME_KILOGRAMOS from configuracion) then round(SUM(isnull(VFillPedImpDet.FID_PES_NET,0)),6) 
							else round(SUM(isnull(VFillPedImpDet.FID_CANT_ST,0)*isnull(VFillPedImpDet.EQ_IMPMX,1)),6) end,
							MAX(FID_GENERA_EMPDET), MAX(VFillPedImpDet.PID_PES_UNIKG),
							CASE WHEN VFillPedImpDet.fid_def_tip = 'E' THEN 'S' ELSE 'N' END, MAX(VFillPedImpDet.ME_ARIMPMX)
					FROM         FACTIMP LEFT OUTER JOIN
					                      DIR_CLIENTE ON FACTIMP.DI_PROVEE = DIR_CLIENTE.DI_INDICE LEFT OUTER JOIN
					                      VFillPedImpDet ON FACTIMP.FI_CODIGO = VFillPedImpDet.FI_CODIGO LEFT OUTER JOIN
					                      MAESTRO ON VFillPedImpDet.MA_CODIGO = MAESTRO.MA_CODIGO LEFT OUTER JOIN
					                      ARANCEL ON VFillPedImpDet.AR_IMPMX = ARANCEL.AR_CODIGO
					WHERE     (FACTIMP.PI_CODIGO = @picodigo or FACTIMP.PI_RECTIFICA = @picodigo) and (VFillPedImpDet.MA_CODIGO is not null)
					GROUP BY VFillPedImpDet.MA_CODIGO, VFillPedImpDet.FID_NOPARTE, VFillPedImpDet.FID_NOMBRE,
					                      VFillPedImpDet.ME_CODIGO, VFillPedImpDet.MA_GENERICO, 
						        VFillPedImpDet.FID_SEC_IMP, CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(VFillPedImpDet.FID_ORD_COMP,0) else 0 end, 
					                      VFillPedImpDet.FID_DEF_TIP, VFillPedImpDet.FID_POR_DEF, VFillPedImpDet.PA_CODIGO, 
					                      VFillPedImpDet.SPI_CODIGO, isnull(DIR_CLIENTE.PA_CODIGO,233), --ROUND(ISNULL(VFillPedImpDet.FID_COS_UNI, 0),6,1),
					                      isnull(VFillPedImpDet.CS_CODIGO,8), (case when FID_PADREKITINSERT='N' then (case when isnull(VFillPedImpDet.CS_CODIGO,8)=2 then 'N' else 'S' end)
								else 'S' end), VFillPedImpDet.FI_CODIGO, ARANCEL.AR_FRACCION
					ORDER BY ARANCEL.AR_FRACCION, MAX(VFillPedImpDet.FID_NOMBRE), isnull(VFillPedImpDet.FID_NOPARTE,'')
		
					if exists (select * from factimpdet, factimp where factimp.pi_codigo=@picodigo and factimpdet.cs_codigo=2 and factimpdet.FID_PADREKITINSERT='N'
					and factimp.fi_codigo=factimpdet.fi_codigo)
				
					exec fillpedimpdetkit @picodigo, @user
			
					begin
						exec fillpedimpemp @picodigo, @user		/*inserta en el detalle los empaques de la factura */
					end
	
	
			end
			else
			begin
				if @ccp_tipo<>'RE'
				begin
					insert into TempPedImpDet(PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CANT, PID_CTOT_DLS, ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
							AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
							PA_PROCEDE, ME_GENERICO, PR_CODIGO, PID_ORD_COMP,
							PID_DESCARGABLE, PID_IMPRIMIR, CS_CODIGO, PID_COS_UNIVA, PID_COS_UNIMATGRA, PID_NOPARTEAUX, PID_CODIGOFACT, PID_CTOT_MN,
							PID_CAN_GEN, PID_CAN_AR, PID_GENERA_EMPDET, PID_PES_UNIKG, PID_SERVICIO, ME_ARIMPMX)
					
					SELECT     @picodigo, ISNULL(VFillPedImpDet.MA_CODIGO,0), isnull(VFillPedImpDet.FID_NOPARTE,''), MAX(VFillPedImpDet.FID_NOMBRE), MAX(VFillPedImpDet.FID_NAME), 
					                      SUM(isnull(VFillPedImpDet.FID_CANT_ST,0)), 
		   				        'PID_CTOT_DLS'=case when max(factimp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO <> 154 AND MONEDA.PA_CODIGO <> 233) 
							then SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)*FACTIMP.FI_TIPOCAMBIO)/@PI_TIP_CAM else SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)) end,
					                      VFillPedImpDet.ME_CODIGO, isnull(VFillPedImpDet.MA_GENERICO,0), 
					                      1, 1, isnull(max(VFillPedImpDet.AR_IMPMX),0), isnull(max(VFillPedImpDet.AR_EXPFO),0), 
					                      0, VFillPedImpDet.FID_SEC_IMP,ISNULL(CASE WHEN VFillPedImpDet.FID_DEF_TIP = 'E' THEN 'G' ELSE VFillPedImpDet.FID_DEF_TIP END,'G'),isnull(CASE WHEN VFillPedImpDet.FID_DEF_TIP = 'E' THEN 0 ELSE VFillPedImpDet.FID_POR_DEF END,-1), 
					                      MAX(isnull(VFillPedImpDet.TI_CODIGO,10)), VFillPedImpDet.PA_CODIGO, VFillPedImpDet.SPI_CODIGO,isnull(DIR_CLIENTE.PA_CODIGO,233),
					                      CASE WHEN max(VFillPedImpDet.ME_GEN)=0 OR max(VFillPedImpDet.ME_GEN) IS NULL THEN max(VFillPedImpDet.ME_CODIGO) ELSE max(VFillPedImpDet.ME_GEN) END,
							 MAX(VFillPedImpDet.PR_CODIGO), CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(VFillPedImpDet.FID_ORD_COMP,0) else 0 end,
								'descargable'=case when FID_PADREKITINSERT='N' then (case when isnull(VFillPedImpDet.CS_CODIGO,8)=2 then 'N' else 'S' end)
								else 'S' end, 'S', isnull(VFillPedImpDet.CS_CODIGO,8), 0, 0, max(isnull(VFillPedImpDet.FID_NOPARTEAUX,'')), VFillPedImpDet.FI_CODIGO, 
							'PID_CTOT_MN'=case when max(factimp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154) then SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)) else (case when @PI_USA_TIP_CAMFACT<>'S' and max(factimp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 233) then  SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)*@PI_TIP_CAM) else SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)*FACTIMP.FI_TIPOCAMBIO) end) end,
							 round(SUM(isnull(VFillPedImpDet.FID_CANT_ST,0)*isnull(VFillPedImpDet.EQ_GEN,1)),6),
							 'PID_CAN_AR'=case when SUM(isnull(VFillPedImpDet.FID_CANT_ST,0))=0 and MAX(VFillPedImpDet.ME_ARIMPMX) in (select ME_KILOGRAMOS from configuracion) then round(SUM(isnull(VFillPedImpDet.FID_PES_NET,0)),6) 
							else round(SUM(isnull(VFillPedImpDet.FID_CANT_ST,0)*isnull(VFillPedImpDet.EQ_IMPMX,1)),6) end,
							 MAX(FID_GENERA_EMPDET), MAX(VFillPedImpDet.PID_PES_UNIKG),
							CASE WHEN VFillPedImpDet.fid_def_tip = 'E' THEN 'S' ELSE 'N' END, MAX(VFillPedImpDet.ME_ARIMPMX)
					FROM         FACTIMP LEFT OUTER JOIN
					                      DIR_CLIENTE ON FACTIMP.DI_PROVEE = DIR_CLIENTE.DI_INDICE LEFT OUTER JOIN
					                      VFillPedImpDet ON FACTIMP.FI_CODIGO = VFillPedImpDet.FI_CODIGO LEFT OUTER JOIN
					                      MAESTRO ON VFillPedImpDet.MA_CODIGO = MAESTRO.MA_CODIGO LEFT OUTER JOIN					                      
							ARANCEL ON VFillPedImpDet.AR_IMPMX = ARANCEL.AR_CODIGO
					WHERE     (FACTIMP.PI_CODIGO = @picodigo) and (VFillPedImpDet.MA_CODIGO is not null)					
					GROUP BY VFillPedImpDet.MA_CODIGO, VFillPedImpDet.FID_NOPARTE, 
					                      VFillPedImpDet.ME_CODIGO, VFillPedImpDet.MA_GENERICO, 
						        VFillPedImpDet.FID_SEC_IMP, CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(VFillPedImpDet.FID_ORD_COMP,0) else 0 end, 
					                      VFillPedImpDet.FID_DEF_TIP, VFillPedImpDet.FID_POR_DEF, VFillPedImpDet.PA_CODIGO, 
					                      VFillPedImpDet.SPI_CODIGO, isnull(DIR_CLIENTE.PA_CODIGO,233), 
					                      isnull(VFillPedImpDet.CS_CODIGO,8), (case when FID_PADREKITINSERT='N' then (case when isnull(VFillPedImpDet.CS_CODIGO,8)=2 then 'N' else 'S' end)
								else 'S' end), VFillPedImpDet.FI_CODIGO, ARANCEL.AR_FRACCION
					ORDER BY ARANCEL.AR_FRACCION, MAX(VFillPedImpDet.FID_NOMBRE), isnull(VFillPedImpDet.FID_NOPARTE,'')
		
					if exists (select * from factimpdet, factimp where factimp.pi_codigo=@picodigo and factimpdet.cs_codigo=2 and factimpdet.FID_PADREKITINSERT='N'
					and factimp.fi_codigo=factimpdet.fi_codigo)
				
					-- si FID_PADREKITINSERT='N' significa que inserta el padre pero como no descargable, y los componentes como si descargables
					exec fillpedimpdetkit @picodigo, @user
			
		--			if (SELECT CF_EMPDESPIMP FROM CONFIGURACION)='S' /* si la empresa quiere llevar el control del empaque que importa como desperdicio */
					begin
						exec fillpedimpemp @picodigo, @user		/*inserta en el detalle los empaques de la factura */
					end
			
			
			
				end
				else
				begin
					-- rectificacion de un pedimento de activo fijo
					if (@ccp_tipo='RE' and @ccp_tipo2 in ('IA', 'IM')) or
					((select PI_DESP_EQUIPO from pedimp where pi_codigo=@picodigo) ='S' and @ccp_tipo2 in ('VT', 'IV', 'EV', 'IE'))
					or (SELECT COUNT(*) FROM FACTIMP INNER JOIN TEMBARQUE ON FACTIMP.TQ_CODIGO = TEMBARQUE.TQ_CODIGO
					     WHERE TEMBARQUE.TQ_NOMBRE LIKE '%CASO ESPECIAL%' AND (FACTIMP.PI_CODIGO = @picodigo or FACTIMP.PI_RECTIFICA = @picodigo))>0

					begin
						insert into TempPedImpDet(PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CANT, PID_CTOT_DLS, ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
								AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
								PA_PROCEDE, ME_GENERICO, PR_CODIGO, PID_ORD_COMP,
								PID_DESCARGABLE, PID_IMPRIMIR, CS_CODIGO, PID_COS_UNIVA, PID_COS_UNIMATGRA, PID_NOPARTEAUX, PID_CODIGOFACT, PID_CTOT_MN,
							PID_CAN_GEN, PID_CAN_AR, PID_GENERA_EMPDET, PID_PES_UNIKG, PID_SERVICIO, ME_ARIMPMX)
						
						SELECT     @picodigo, ISNULL(VFillPedImpDet.MA_CODIGO,0), isnull(VFillPedImpDet.FID_NOPARTE,''), VFillPedImpDet.FID_NOMBRE, MAX(VFillPedImpDet.FID_NAME), 
						                      SUM(isnull(VFillPedImpDet.FID_CANT_ST,0)), 
		   				        'PID_CTOT_DLS'=case when max(factimp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO <> 154 AND MONEDA.PA_CODIGO <> 233) 
							then SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)*FACTIMP.FI_TIPOCAMBIO)/@PI_TIP_CAM else SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)) end,
						                      VFillPedImpDet.ME_CODIGO, isnull(VFillPedImpDet.MA_GENERICO,0), 
						                      1, 1, isnull(max(VFillPedImpDet.AR_IMPMX),0), isnull(max(VFillPedImpDet.AR_EXPFO),0), 
						                      0, VFillPedImpDet.FID_SEC_IMP,ISNULL(CASE WHEN VFillPedImpDet.FID_DEF_TIP = 'E' THEN 'G' ELSE VFillPedImpDet.FID_DEF_TIP END,'G'),isnull(CASE WHEN VFillPedImpDet.FID_DEF_TIP = 'E' THEN 0 ELSE VFillPedImpDet.FID_POR_DEF END,-1), 
						                      MAX(isnull(VFillPedImpDet.TI_CODIGO,10)), VFillPedImpDet.PA_CODIGO, VFillPedImpDet.SPI_CODIGO,isnull(DIR_CLIENTE.PA_CODIGO,233), 
						                      CASE WHEN max(VFillPedImpDet.ME_GEN)=0 OR max(VFillPedImpDet.ME_GEN) IS NULL THEN max(VFillPedImpDet.ME_CODIGO) ELSE max(VFillPedImpDet.ME_GEN) END, 
								MAX(VFillPedImpDet.PR_CODIGO), CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(VFillPedImpDet.FID_ORD_COMP,0) else 0 end,
									'descargable'=case when FID_PADREKITINSERT='N' then (case when isnull(VFillPedImpDet.CS_CODIGO,8)=2 then 'N' else 'S' end)
									else 'S' end, 'S', isnull(VFillPedImpDet.CS_CODIGO,8), 0, 0, max(VFillPedImpDet.FID_NOPARTEAUX), VFillPedImpDet.FI_CODIGO, 
							'PID_CTOT_MN'=case when max(factimp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154) then SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)) else (case when @PI_USA_TIP_CAMFACT<>'S' and max(factimp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 233) then  SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)*@PI_TIP_CAM) else SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)*FACTIMP.FI_TIPOCAMBIO) end) end,
							 round(SUM(isnull(VFillPedImpDet.FID_CANT_ST,0)*isnull(VFillPedImpDet.EQ_GEN,1)),6),
							 'PID_CAN_AR'=case when SUM(isnull(VFillPedImpDet.FID_CANT_ST,0))=0 and MAX(VFillPedImpDet.ME_ARIMPMX) in (select ME_KILOGRAMOS from configuracion) then round(SUM(isnull(VFillPedImpDet.FID_PES_NET,0)),6) 
							else round(SUM(isnull(VFillPedImpDet.FID_CANT_ST,0)*isnull(VFillPedImpDet.EQ_IMPMX,1)),6) end, MAX(FID_GENERA_EMPDET), MAX(VFillPedImpDet.PID_PES_UNIKG),
							CASE WHEN VFillPedImpDet.fid_def_tip = 'E' THEN 'S' ELSE 'N' END, MAX(VFillPedImpDet.ME_ARIMPMX)
						FROM         FACTIMP LEFT OUTER JOIN
						                      DIR_CLIENTE ON FACTIMP.DI_PROVEE = DIR_CLIENTE.DI_INDICE LEFT OUTER JOIN
						                      VFillPedImpDet ON FACTIMP.FI_CODIGO = VFillPedImpDet.FI_CODIGO LEFT OUTER JOIN
						                      MAESTRO ON VFillPedImpDet.MA_CODIGO = MAESTRO.MA_CODIGO LEFT OUTER JOIN
						                      ARANCEL ON VFillPedImpDet.AR_IMPMX = ARANCEL.AR_CODIGO
						WHERE     (FACTIMP.PI_RECTIFICA = @picodigo or FACTIMP.PI_CODIGO = @picodigo) and (VFillPedImpDet.MA_CODIGO is not null)
						GROUP BY VFillPedImpDet.MA_CODIGO, VFillPedImpDet.FID_NOPARTE, VFillPedImpDet.FID_NOMBRE,
						                      VFillPedImpDet.ME_CODIGO, VFillPedImpDet.MA_GENERICO, 
								VFillPedImpDet.FID_SEC_IMP, CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(VFillPedImpDet.FID_ORD_COMP,0) else 0 end, 
						                      VFillPedImpDet.FID_DEF_TIP, VFillPedImpDet.FID_POR_DEF, VFillPedImpDet.PA_CODIGO, 
						                      VFillPedImpDet.SPI_CODIGO, isnull(DIR_CLIENTE.PA_CODIGO,233), 
						                      isnull(VFillPedImpDet.CS_CODIGO,8), (case when FID_PADREKITINSERT='N' then (case when isnull(VFillPedImpDet.CS_CODIGO,8)=2 then 'N' else 'S' end)
									else 'S' end), VFillPedImpDet.FI_CODIGO, ARANCEL.AR_FRACCION
						ORDER BY ARANCEL.AR_FRACCION, isnull(VFillPedImpDet.FID_NOPARTE,''), MAX(VFillPedImpDet.FID_NOMBRE)
	
	
					end
					else
					begin
						insert into TempPedImpDet(PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CANT, PID_CTOT_DLS, ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
								AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
								PA_PROCEDE, ME_GENERICO, PR_CODIGO, PID_ORD_COMP,
								PID_DESCARGABLE, PID_IMPRIMIR, CS_CODIGO, PID_COS_UNIVA, PID_COS_UNIMATGRA, PID_NOPARTEAUX, PID_CODIGOFACT, PID_CTOT_MN,
							PID_CAN_GEN, PID_CAN_AR, PID_GENERA_EMPDET, PID_PES_UNIKG, PID_SERVICIO, ME_ARIMPMX)
						
						SELECT     @picodigo, ISNULL(VFillPedImpDet.MA_CODIGO,0), isnull(VFillPedImpDet.FID_NOPARTE,''), MAX(VFillPedImpDet.FID_NOMBRE), MAX(VFillPedImpDet.FID_NAME), 
						                      SUM(isnull(VFillPedImpDet.FID_CANT_ST,0)), 
		   				        'PID_CTOT_DLS'=case when max(factimp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO <> 154 AND MONEDA.PA_CODIGO <> 233) 
							then SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)*FACTIMP.FI_TIPOCAMBIO)/@PI_TIP_CAM else SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)) end,
						                      VFillPedImpDet.ME_CODIGO, isnull(VFillPedImpDet.MA_GENERICO,0), 
						                      1, 1, isnull(max(VFillPedImpDet.AR_IMPMX),0), isnull(max(VFillPedImpDet.AR_EXPFO),0), 
						                      0, VFillPedImpDet.FID_SEC_IMP,ISNULL(CASE WHEN VFillPedImpDet.FID_DEF_TIP = 'E' THEN 'G' ELSE VFillPedImpDet.FID_DEF_TIP END,'G'),isnull(CASE WHEN VFillPedImpDet.FID_DEF_TIP = 'E' THEN 0 ELSE VFillPedImpDet.FID_POR_DEF END,-1), 
						                      MAX(isnull(VFillPedImpDet.TI_CODIGO,10)), VFillPedImpDet.PA_CODIGO, VFillPedImpDet.SPI_CODIGO,isnull(DIR_CLIENTE.PA_CODIGO,233), 
						                      CASE WHEN max(VFillPedImpDet.ME_GEN)=0 OR max(VFillPedImpDet.ME_GEN) IS NULL THEN max(VFillPedImpDet.ME_CODIGO) ELSE max(VFillPedImpDet.ME_GEN) END, 
								MAX(VFillPedImpDet.PR_CODIGO), CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(VFillPedImpDet.FID_ORD_COMP,0) else 0 end,
									'descargable'=case when FID_PADREKITINSERT='N' then (case when isnull(VFillPedImpDet.CS_CODIGO,8)=2 then 'N' else 'S' end)
									else 'S' end, 'S', isnull(VFillPedImpDet.CS_CODIGO,8), 0, 0, max(VFillPedImpDet.FID_NOPARTEAUX), VFillPedImpDet.FI_CODIGO, 
							'PID_CTOT_MN'=case when max(factimp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154) then SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)) else (case when @PI_USA_TIP_CAMFACT<>'S' and max(factimp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 233) then  SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)*@PI_TIP_CAM) else SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)*FACTIMP.FI_TIPOCAMBIO) end) end,
							 round(SUM(isnull(VFillPedImpDet.FID_CANT_ST,0)*isnull(VFillPedImpDet.EQ_GEN,1)),6),
							 'PID_CAN_AR'=case when SUM(isnull(VFillPedImpDet.FID_CANT_ST,0))=0 and MAX(VFillPedImpDet.ME_ARIMPMX) in (select ME_KILOGRAMOS from configuracion) then round(SUM(isnull(VFillPedImpDet.FID_PES_NET,0)),6) 
							else round(SUM(isnull(VFillPedImpDet.FID_CANT_ST,0)*isnull(VFillPedImpDet.EQ_IMPMX,1)),6) end, MAX(FID_GENERA_EMPDET), MAX(VFillPedImpDet.PID_PES_UNIKG),
							CASE WHEN VFillPedImpDet.fid_def_tip = 'E' THEN 'S' ELSE 'N' END, MAX(VFillPedImpDet.ME_ARIMPMX)
						FROM         FACTIMP LEFT OUTER JOIN
						                      DIR_CLIENTE ON FACTIMP.DI_PROVEE = DIR_CLIENTE.DI_INDICE LEFT OUTER JOIN
						                      VFillPedImpDet ON FACTIMP.FI_CODIGO = VFillPedImpDet.FI_CODIGO LEFT OUTER JOIN
						                      MAESTRO ON VFillPedImpDet.MA_CODIGO = MAESTRO.MA_CODIGO LEFT OUTER JOIN
						                      ARANCEL ON VFillPedImpDet.AR_IMPMX = ARANCEL.AR_CODIGO
						WHERE     (FACTIMP.PI_RECTIFICA = @picodigo) and (VFillPedImpDet.MA_CODIGO is not null)
						GROUP BY VFillPedImpDet.MA_CODIGO, VFillPedImpDet.FID_NOPARTE, 
						                      VFillPedImpDet.ME_CODIGO, VFillPedImpDet.MA_GENERICO, 
								VFillPedImpDet.FID_SEC_IMP, CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(VFillPedImpDet.FID_ORD_COMP,0) else 0 end, 
						                      VFillPedImpDet.FID_DEF_TIP, VFillPedImpDet.FID_POR_DEF, VFillPedImpDet.PA_CODIGO, 
						                      VFillPedImpDet.SPI_CODIGO, isnull(DIR_CLIENTE.PA_CODIGO,233), 
						                      isnull(VFillPedImpDet.CS_CODIGO,8), (case when FID_PADREKITINSERT='N' then (case when isnull(VFillPedImpDet.CS_CODIGO,8)=2 then 'N' else 'S' end)
									else 'S' end), VFillPedImpDet.FI_CODIGO, ARANCEL.AR_FRACCION
						ORDER BY ARANCEL.AR_FRACCION, isnull(VFillPedImpDet.FID_NOPARTE,''), MAX(VFillPedImpDet.FID_NOMBRE)
			
					end			
						if exists (select * from factimpdet, factimp where factimp.pi_rectifica=@picodigo and factimpdet.cs_codigo=2 and factimpdet.FID_PADREKITINSERT='N'
						and factimp.fi_codigo=factimpdet.fi_codigo)
						-- si FID_PADREKITINSERT='N' significa que inserta el padre pero como no descargable, y los componentes como si descargables
					
						exec fillpedimpdetKit_rect @picodigo, @user
				
				
				--		IF (SELECT CF_EMPDESPIMP FROM CONFIGURACION)='S' /* si la empresa quiere llevar el control del empaque que importa como desperdicio */
						exec fillpedimpemp_rect @picodigo, @user		/*inserta en el detalle los empaques de la factura*/
	
				end
			end
	
		end
		else -- else de division por factura
		begin

			if @ccp_tipo in ('IA', 'IM') or ((select PI_DESP_EQUIPO from pedimp where pi_codigo=@picodigo) ='S' and @ccp_tipo in ('VT', 'IV', 'EV', 'IE'))
			or (SELECT COUNT(*) FROM FACTIMP INNER JOIN TEMBARQUE ON FACTIMP.TQ_CODIGO = TEMBARQUE.TQ_CODIGO
			     WHERE TEMBARQUE.TQ_NOMBRE LIKE '%CASO ESPECIAL%' AND (FACTIMP.PI_CODIGO = @picodigo or FACTIMP.PI_RECTIFICA = @picodigo))>0


			begin
				insert into TempPedImpDet(PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CANT, PID_CTOT_DLS, ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
						AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
						PA_PROCEDE, ME_GENERICO, PR_CODIGO, PID_ORD_COMP,
						PID_DESCARGABLE, PID_IMPRIMIR, CS_CODIGO, PID_COS_UNIVA, PID_COS_UNIMATGRA, PID_NOPARTEAUX, PID_CTOT_MN,
							PID_CAN_GEN, PID_CAN_AR, PID_GENERA_EMPDET, PID_PES_UNIKG, PID_SERVICIO, ME_ARIMPMX)
				
				SELECT     @picodigo, ISNULL(VFillPedImpDet.MA_CODIGO,0), isnull(VFillPedImpDet.FID_NOPARTE,''), VFillPedImpDet.FID_NOMBRE, MAX(VFillPedImpDet.FID_NAME), 
				                      SUM(isnull(VFillPedImpDet.FID_CANT_ST,0)), 
	   				        'PID_CTOT_DLS'=case when max(factimp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO <> 154 AND MONEDA.PA_CODIGO <> 233) 
						then SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)*FACTIMP.FI_TIPOCAMBIO)/@PI_TIP_CAM else SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)) end,
				                      VFillPedImpDet.ME_CODIGO, isnull(VFillPedImpDet.MA_GENERICO,0), 
				                      1, 1, isnull(max(VFillPedImpDet.AR_IMPMX),0), isnull(max(VFillPedImpDet.AR_EXPFO),0), 
				                      0, VFillPedImpDet.FID_SEC_IMP,ISNULL(CASE WHEN VFillPedImpDet.FID_DEF_TIP = 'E' THEN 'G' ELSE VFillPedImpDet.FID_DEF_TIP END,'G'),isnull(CASE WHEN VFillPedImpDet.FID_DEF_TIP = 'E' THEN 0 ELSE VFillPedImpDet.FID_POR_DEF END,-1), 
				                      MAX(isnull(VFillPedImpDet.TI_CODIGO,10)), VFillPedImpDet.PA_CODIGO, VFillPedImpDet.SPI_CODIGO,isnull(DIR_CLIENTE.PA_CODIGO,233), 
				                      CASE WHEN max(VFillPedImpDet.ME_GEN)=0 OR max(VFillPedImpDet.ME_GEN) IS NULL THEN max(VFillPedImpDet.ME_CODIGO) ELSE max(VFillPedImpDet.ME_GEN) END, 
						MAX(VFillPedImpDet.PR_CODIGO), CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(VFillPedImpDet.FID_ORD_COMP,0) else 0 end,
							'descargable'=case when FID_PADREKITINSERT='N' then (case when isnull(VFillPedImpDet.CS_CODIGO,8)=2 then 'N' else 'S' end)
							else 'S' end, 'S', isnull(VFillPedImpDet.CS_CODIGO,8), 0, 0, max(isnull(VFillPedImpDet.FID_NOPARTEAUX,'')), 
							'PID_CTOT_MN'=case when max(factimp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154) then SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)) else (case when @PI_USA_TIP_CAMFACT<>'S' and max(factimp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 233) then  SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)*@PI_TIP_CAM) else SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)*FACTIMP.FI_TIPOCAMBIO) end) end,
							 round(SUM(isnull(VFillPedImpDet.FID_CANT_ST,0)*isnull(VFillPedImpDet.EQ_GEN,1)),6),
							 'PID_CAN_AR'=case when SUM(isnull(VFillPedImpDet.FID_CANT_ST,0))=0 and MAX(VFillPedImpDet.ME_ARIMPMX) in (select ME_KILOGRAMOS from configuracion) then round(SUM(isnull(VFillPedImpDet.FID_PES_NET,0)),6) 
							else round(SUM(isnull(VFillPedImpDet.FID_CANT_ST,0)*isnull(VFillPedImpDet.EQ_IMPMX,1)),6) end, MAX(FID_GENERA_EMPDET), MAX(VFillPedImpDet.PID_PES_UNIKG),
						CASE WHEN VFillPedImpDet.fid_def_tip = 'E' THEN 'S' ELSE 'N' END, MAX(VFillPedImpDet.ME_ARIMPMX)
				FROM         FACTIMP LEFT OUTER JOIN
				                      DIR_CLIENTE ON FACTIMP.DI_PROVEE = DIR_CLIENTE.DI_INDICE LEFT OUTER JOIN
				                      VFillPedImpDet ON FACTIMP.FI_CODIGO = VFillPedImpDet.FI_CODIGO LEFT OUTER JOIN
				                      MAESTRO ON VFillPedImpDet.MA_CODIGO = MAESTRO.MA_CODIGO LEFT OUTER JOIN
				                     ARANCEL ON VFillPedImpDet.AR_IMPMX = ARANCEL.AR_CODIGO
				WHERE     (FACTIMP.PI_CODIGO = @picodigo or FACTIMP.PI_RECTIFICA = @picodigo) and (VFillPedImpDet.MA_CODIGO is not null)
				GROUP BY VFillPedImpDet.MA_CODIGO, VFillPedImpDet.FID_NOPARTE, VFillPedImpDet.FID_NOMBRE,
				                      VFillPedImpDet.ME_CODIGO, VFillPedImpDet.MA_GENERICO, 
					        VFillPedImpDet.FID_SEC_IMP, CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(VFillPedImpDet.FID_ORD_COMP,0) else 0 end, --ROUND(ISNULL(VFillPedImpDet.FID_COS_UNI, 0),6,1),
				                      VFillPedImpDet.FID_DEF_TIP, VFillPedImpDet.FID_POR_DEF, VFillPedImpDet.PA_CODIGO, 
				                      VFillPedImpDet.SPI_CODIGO, isnull(DIR_CLIENTE.PA_CODIGO,233), 
				                      isnull(VFillPedImpDet.CS_CODIGO,8), (case when FID_PADREKITINSERT='N' then (case when isnull(VFillPedImpDet.CS_CODIGO,8)=2 then 'N' else 'S' end)
							else 'S' end), ARANCEL.AR_FRACCION
				ORDER BY ARANCEL.AR_FRACCION, isnull(VFillPedImpDet.FID_NOPARTE,''), MAX(VFillPedImpDet.FID_NOMBRE)
	
				if exists (select * from factimpdet, factimp where factimp.pi_codigo=@picodigo and factimpdet.cs_codigo=2 and factimpdet.FID_PADREKITINSERT='N'
				and factimp.fi_codigo=factimpdet.fi_codigo)
			
				exec fillpedimpdetkit @picodigo, @user
		
				begin
					exec fillpedimpemp @picodigo, @user		--inserta en el detalle los empaques de la factura 
				end
		
	
	
	
			end
			else
			begin
	
				if @ccp_tipo<>'RE'
				begin
					insert into TempPedImpDet(PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CANT, PID_CTOT_DLS, ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
							AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
							PA_PROCEDE, ME_GENERICO, PR_CODIGO, PID_ORD_COMP,
							PID_DESCARGABLE, PID_IMPRIMIR, CS_CODIGO, PID_COS_UNIVA, PID_COS_UNIMATGRA, PID_NOPARTEAUX, PID_CTOT_MN,
							PID_CAN_GEN, PID_CAN_AR, PID_GENERA_EMPDET, PID_PES_UNIKG, PID_SERVICIO, ME_ARIMPMX)
					
					SELECT     @picodigo, ISNULL(VFillPedImpDet.MA_CODIGO,0), isnull(VFillPedImpDet.FID_NOPARTE,''), MAX(VFillPedImpDet.FID_NOMBRE), MAX(VFillPedImpDet.FID_NAME), 
					                      SUM(isnull(VFillPedImpDet.FID_CANT_ST,0)), 
		   				        'PID_CTOT_DLS'=case when max(factimp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO <> 154 AND MONEDA.PA_CODIGO <> 233) 
							then SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)*FACTIMP.FI_TIPOCAMBIO)/@PI_TIP_CAM else SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)) end,
					                      VFillPedImpDet.ME_CODIGO, isnull(VFillPedImpDet.MA_GENERICO,0), 
					                      1, 1, isnull(max(VFillPedImpDet.AR_IMPMX),0), isnull(max(VFillPedImpDet.AR_EXPFO),0), 
					                      0, VFillPedImpDet.FID_SEC_IMP,ISNULL(CASE WHEN VFillPedImpDet.FID_DEF_TIP = 'E' THEN 'G' ELSE VFillPedImpDet.FID_DEF_TIP END,'G'),isnull(CASE WHEN VFillPedImpDet.FID_DEF_TIP = 'E' THEN 0 ELSE VFillPedImpDet.FID_POR_DEF END,-1), 
					                      MAX(isnull(VFillPedImpDet.TI_CODIGO,10)), VFillPedImpDet.PA_CODIGO, VFillPedImpDet.SPI_CODIGO,isnull(DIR_CLIENTE.PA_CODIGO,233), 
					                      CASE WHEN max(VFillPedImpDet.ME_GEN)=0 OR max(VFillPedImpDet.ME_GEN) IS NULL THEN max(VFillPedImpDet.ME_CODIGO) ELSE max(VFillPedImpDet.ME_GEN) END, 
							MAX(VFillPedImpDet.PR_CODIGO), CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(VFillPedImpDet.FID_ORD_COMP,0) else 0 end,
								'descargable'=case when FID_PADREKITINSERT='N' then (case when isnull(VFillPedImpDet.CS_CODIGO,8)=2 then 'N' else 'S' end)
								else 'S' end, 'S', isnull(VFillPedImpDet.CS_CODIGO,8), 0, 0, max(isnull(VFillPedImpDet.FID_NOPARTEAUX,'')), 
							'PID_CTOT_MN'=case when max(factimp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154) then SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)) else (case when @PI_USA_TIP_CAMFACT<>'S' and max(factimp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 233) then  SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)*@PI_TIP_CAM) else SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)*FACTIMP.FI_TIPOCAMBIO) end) end,
							 round(SUM(isnull(VFillPedImpDet.FID_CANT_ST,0)*isnull(VFillPedImpDet.EQ_GEN,1)),6),
							 'PID_CAN_AR'=case when SUM(isnull(VFillPedImpDet.FID_CANT_ST,0))=0 and MAX(VFillPedImpDet.ME_ARIMPMX) in (select ME_KILOGRAMOS from configuracion) then round(SUM(isnull(VFillPedImpDet.FID_PES_NET,0)),6) 
							else round(SUM(isnull(VFillPedImpDet.FID_CANT_ST,0)*isnull(VFillPedImpDet.EQ_IMPMX,1)),6) end, MAX(FID_GENERA_EMPDET), MAX(VFillPedImpDet.PID_PES_UNIKG),
							CASE WHEN VFillPedImpDet.fid_def_tip = 'E' THEN 'S' ELSE 'N' END, MAX(VFillPedImpDet.ME_ARIMPMX)
					FROM         FACTIMP LEFT OUTER JOIN
					                      DIR_CLIENTE ON FACTIMP.DI_PROVEE = DIR_CLIENTE.DI_INDICE LEFT OUTER JOIN
					                      VFillPedImpDet ON FACTIMP.FI_CODIGO = VFillPedImpDet.FI_CODIGO LEFT OUTER JOIN
					                      MAESTRO ON VFillPedImpDet.MA_CODIGO = MAESTRO.MA_CODIGO LEFT OUTER JOIN
				                     ARANCEL ON VFillPedImpDet.AR_IMPMX = ARANCEL.AR_CODIGO
					WHERE     (FACTIMP.PI_CODIGO = @picodigo) and (VFillPedImpDet.MA_CODIGO is not null)
					GROUP BY VFillPedImpDet.MA_CODIGO, VFillPedImpDet.FID_NOPARTE, 
					                      VFillPedImpDet.ME_CODIGO, VFillPedImpDet.MA_GENERICO, 
						        VFillPedImpDet.FID_SEC_IMP, CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(VFillPedImpDet.FID_ORD_COMP,0) else 0 end, 
					                      VFillPedImpDet.FID_DEF_TIP, VFillPedImpDet.FID_POR_DEF, VFillPedImpDet.PA_CODIGO, 
					                      VFillPedImpDet.SPI_CODIGO, isnull(DIR_CLIENTE.PA_CODIGO,233), 
					                      isnull(VFillPedImpDet.CS_CODIGO,8), (case when FID_PADREKITINSERT='N' then (case when isnull(VFillPedImpDet.CS_CODIGO,8)=2 then 'N' else 'S' end)
								else 'S' end), ARANCEL.AR_FRACCION
					ORDER BY ARANCEL.AR_FRACCION, isnull(VFillPedImpDet.FID_NOPARTE,''), MAX(VFillPedImpDet.FID_NOMBRE)
		
					if exists (select * from factimpdet, factimp where factimp.pi_codigo=@picodigo and factimpdet.cs_codigo=2 and factimpdet.FID_PADREKITINSERT='N'
					and factimp.fi_codigo=factimpdet.fi_codigo)
				
					-- si FID_PADREKITINSERT='N' significa que inserta el padre pero como no descargable, y los componentes como si descargables
					exec fillpedimpdetkit @picodigo, @user
			
			--		if (SELECT CF_EMPDESPIMP FROM CONFIGURACION)='S' /* si la empresa quiere llevar el control del empaque que importa como desperdicio */
					begin
						exec fillpedimpemp @picodigo, @user		/*inserta en el detalle los empaques de la factura */
					end
			
			
			
				end
				else
				begin
					-- rectificacion de un pedimento de activo fijo
					if (@ccp_tipo='RE' and @ccp_tipo2 in ('IA', 'IM')) or
					((select PI_DESP_EQUIPO from pedimp where pi_codigo=@picodigo) ='S' and @ccp_tipo2 in ('VT', 'IV', 'EV', 'IE'))
					or (SELECT COUNT(*) FROM FACTIMP INNER JOIN TEMBARQUE ON FACTIMP.TQ_CODIGO = TEMBARQUE.TQ_CODIGO
					     WHERE TEMBARQUE.TQ_NOMBRE LIKE '%CASO ESPECIAL%' AND (FACTIMP.PI_CODIGO = @picodigo or FACTIMP.PI_RECTIFICA = @picodigo))>0

					--if exists(select cp_codigo from pedimp where pi_codigo in
					--(select pi_rectifica from pedimp where pi_codigo=@picodigo) and cp_codigo in (select cp_codigo from configuraclaveped where ccp_tipo in ('IA', 'IM')))
					begin
						insert into TempPedImpDet(PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CANT, PID_CTOT_DLS, ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
								AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
								PA_PROCEDE, ME_GENERICO, PR_CODIGO, PID_ORD_COMP,
								PID_DESCARGABLE, PID_IMPRIMIR, CS_CODIGO, PID_COS_UNIVA, PID_COS_UNIMATGRA, PID_NOPARTEAUX, PID_CTOT_MN,
							PID_CAN_GEN, PID_CAN_AR, PID_GENERA_EMPDET, PID_PES_UNIKG, PID_SERVICIO, ME_ARIMPMX)
						
						SELECT     @picodigo, ISNULL(VFillPedImpDet.MA_CODIGO,0), isnull(VFillPedImpDet.FID_NOPARTE,''), VFillPedImpDet.FID_NOMBRE, MAX(VFillPedImpDet.FID_NAME), 
						                      SUM(isnull(VFillPedImpDet.FID_CANT_ST,0)), 
		   				                     'PID_CTOT_DLS'=case when max(factimp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO <> 154 AND MONEDA.PA_CODIGO <> 233) 
							        then SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)*FACTIMP.FI_TIPOCAMBIO)/@PI_TIP_CAM else SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)) end,
						                      VFillPedImpDet.ME_CODIGO, isnull(VFillPedImpDet.MA_GENERICO,0), 
						                      1, 1, isnull(max(VFillPedImpDet.AR_IMPMX),0), isnull(max(VFillPedImpDet.AR_EXPFO),0), 
						                      0, VFillPedImpDet.FID_SEC_IMP,ISNULL(CASE WHEN VFillPedImpDet.FID_DEF_TIP = 'E' THEN 'G' ELSE VFillPedImpDet.FID_DEF_TIP END,'G'),isnull(CASE WHEN VFillPedImpDet.FID_DEF_TIP = 'E' THEN 0 ELSE VFillPedImpDet.FID_POR_DEF END,-1), 
						                      MAX(isnull(VFillPedImpDet.TI_CODIGO,10)), VFillPedImpDet.PA_CODIGO, VFillPedImpDet.SPI_CODIGO,isnull(DIR_CLIENTE.PA_CODIGO,233), 
						                      CASE WHEN max(VFillPedImpDet.ME_GEN)=0 OR max(VFillPedImpDet.ME_GEN) IS NULL THEN max(VFillPedImpDet.ME_CODIGO) ELSE max(VFillPedImpDet.ME_GEN) END, 
								MAX(VFillPedImpDet.PR_CODIGO), CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(VFillPedImpDet.FID_ORD_COMP,0) else 0 end,
									'descargable'=case when FID_PADREKITINSERT='N' then (case when isnull(VFillPedImpDet.CS_CODIGO,8)=2 then 'N' else 'S' end)
									else 'S' end, 'S', isnull(VFillPedImpDet.CS_CODIGO,8), 0, 0, max(VFillPedImpDet.FID_NOPARTEAUX), 
							'PID_CTOT_MN'=case when max(factimp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154) then SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)) else (case when @PI_USA_TIP_CAMFACT<>'S' and max(factimp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 233) then  SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)*@PI_TIP_CAM) else SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)*FACTIMP.FI_TIPOCAMBIO) end) end,
							 round(SUM(isnull(VFillPedImpDet.FID_CANT_ST,0)*isnull(VFillPedImpDet.EQ_GEN,1)),6),
							 'PID_CAN_AR'=case when SUM(isnull(VFillPedImpDet.FID_CANT_ST,0))=0 and MAX(VFillPedImpDet.ME_ARIMPMX) in (select ME_KILOGRAMOS from configuracion) then round(SUM(isnull(VFillPedImpDet.FID_PES_NET,0)),6) 
							else round(SUM(isnull(VFillPedImpDet.FID_CANT_ST,0)*isnull(VFillPedImpDet.EQ_IMPMX,1)),6) end, MAX(FID_GENERA_EMPDET), MAX(VFillPedImpDet.PID_PES_UNIKG),
							CASE WHEN VFillPedImpDet.fid_def_tip = 'E' THEN 'S' ELSE 'N' END, MAX(VFillPedImpDet.ME_ARIMPMX)
						FROM         FACTIMP LEFT OUTER JOIN    
						                      DIR_CLIENTE ON FACTIMP.DI_PROVEE = DIR_CLIENTE.DI_INDICE LEFT OUTER JOIN
						                      VFillPedImpDet ON FACTIMP.FI_CODIGO = VFillPedImpDet.FI_CODIGO LEFT OUTER JOIN
						                      MAESTRO ON VFillPedImpDet.MA_CODIGO = MAESTRO.MA_CODIGO LEFT OUTER JOIN
						                      ARANCEL ON VFillPedImpDet.AR_IMPMX = ARANCEL.AR_CODIGO
						WHERE     (FACTIMP.PI_RECTIFICA = @picodigo or FACTIMP.PI_CODIGO = @picodigo) and (VFillPedImpDet.MA_CODIGO is not null)
						GROUP BY VFillPedImpDet.MA_CODIGO, VFillPedImpDet.FID_NOPARTE, VFillPedImpDet.FID_NOMBRE,	
						                      VFillPedImpDet.ME_CODIGO, VFillPedImpDet.MA_GENERICO, 
								VFillPedImpDet.FID_SEC_IMP, CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(VFillPedImpDet.FID_ORD_COMP,0) else 0 end, 
						                      VFillPedImpDet.FID_DEF_TIP, VFillPedImpDet.FID_POR_DEF, VFillPedImpDet.PA_CODIGO, 
						                      VFillPedImpDet.SPI_CODIGO, isnull(DIR_CLIENTE.PA_CODIGO,233), 
						                      isnull(VFillPedImpDet.CS_CODIGO,8), (case when FID_PADREKITINSERT='N' then (case when isnull(VFillPedImpDet.CS_CODIGO,8)=2 then 'N' else 'S' end)
									else 'S' end), ARANCEL.AR_FRACCION
						ORDER BY ARANCEL.AR_FRACCION, isnull(VFillPedImpDet.FID_NOPARTE,''), MAX(VFillPedImpDet.FID_NOMBRE)
				
					end
					else
					begin
	
						insert into TempPedImpDet(PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CANT, PID_CTOT_DLS, ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
								AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
								PA_PROCEDE, ME_GENERICO, PR_CODIGO, PID_ORD_COMP,
								PID_DESCARGABLE, PID_IMPRIMIR, CS_CODIGO, PID_COS_UNIVA, PID_COS_UNIMATGRA, PID_NOPARTEAUX, PID_CTOT_MN,
							PID_CAN_GEN, PID_CAN_AR, PID_GENERA_EMPDET, PID_PES_UNIKG, PID_SERVICIO, ME_ARIMPMX)
						
						SELECT     @picodigo, ISNULL(VFillPedImpDet.MA_CODIGO,0), isnull(VFillPedImpDet.FID_NOPARTE,''), MAX(VFillPedImpDet.FID_NOMBRE), MAX(VFillPedImpDet.FID_NAME), 
						                      SUM(isnull(VFillPedImpDet.FID_CANT_ST,0)), 
		   				                      'PID_CTOT_DLS'=case when max(factimp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO <> 154 AND MONEDA.PA_CODIGO <> 233) 
							         then SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)*FACTIMP.FI_TIPOCAMBIO)/@PI_TIP_CAM else SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)) end,
						                      VFillPedImpDet.ME_CODIGO, isnull(VFillPedImpDet.MA_GENERICO,0), 
						                      1, 1, isnull(max(VFillPedImpDet.AR_IMPMX),0), isnull(max(VFillPedImpDet.AR_EXPFO),0), 
						                      0, VFillPedImpDet.FID_SEC_IMP,ISNULL(CASE WHEN VFillPedImpDet.FID_DEF_TIP = 'E' THEN 'G' ELSE VFillPedImpDet.FID_DEF_TIP END,'G'),isnull(CASE WHEN VFillPedImpDet.FID_DEF_TIP = 'E' THEN 0 ELSE VFillPedImpDet.FID_POR_DEF END,-1), 
						                      MAX(isnull(VFillPedImpDet.TI_CODIGO,10)), VFillPedImpDet.PA_CODIGO, VFillPedImpDet.SPI_CODIGO,isnull(DIR_CLIENTE.PA_CODIGO,233), 
						                      CASE WHEN max(VFillPedImpDet.ME_GEN)=0 OR max(VFillPedImpDet.ME_GEN) IS NULL THEN max(VFillPedImpDet.ME_CODIGO) ELSE max(VFillPedImpDet.ME_GEN) END, 
								MAX(VFillPedImpDet.PR_CODIGO), CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(VFillPedImpDet.FID_ORD_COMP,0) else 0 end,
									'descargable'=case when FID_PADREKITINSERT='N' then (case when isnull(VFillPedImpDet.CS_CODIGO,8)=2 then 'N' else 'S' end)
									else 'S' end, 'S', isnull(VFillPedImpDet.CS_CODIGO,8), 0, 0, max(VFillPedImpDet.FID_NOPARTEAUX), 
							'PID_CTOT_MN'=case when max(factimp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154) then SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)) else (case when @PI_USA_TIP_CAMFACT<>'S' and max(factimp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 233) then  SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)*@PI_TIP_CAM) else SUM(isnull(VFillPedImpDet.FID_COS_TOT,0)*FACTIMP.FI_TIPOCAMBIO) end) end,
							 round(SUM(isnull(VFillPedImpDet.FID_CANT_ST,0)*isnull(VFillPedImpDet.EQ_GEN,1)),6),
							 'PID_CAN_AR'=case when SUM(isnull(VFillPedImpDet.FID_CANT_ST,0))=0 and MAX(VFillPedImpDet.ME_ARIMPMX) in (select ME_KILOGRAMOS from configuracion) then round(SUM(isnull(VFillPedImpDet.FID_PES_NET,0)),6) 
							else round(SUM(isnull(VFillPedImpDet.FID_CANT_ST,0)*isnull(VFillPedImpDet.EQ_IMPMX,1)),6) end, MAX(FID_GENERA_EMPDET), MAX(VFillPedImpDet.PID_PES_UNIKG),
							CASE WHEN VFillPedImpDet.fid_def_tip = 'E' THEN 'S' ELSE 'N' END, MAX(VFillPedImpDet.ME_ARIMPMX)
						FROM         FACTIMP LEFT OUTER JOIN
						                      DIR_CLIENTE ON FACTIMP.DI_PROVEE = DIR_CLIENTE.DI_INDICE LEFT OUTER JOIN
						                      VFillPedImpDet ON FACTIMP.FI_CODIGO = VFillPedImpDet.FI_CODIGO LEFT OUTER JOIN
						                      MAESTRO ON VFillPedImpDet.MA_CODIGO = MAESTRO.MA_CODIGO LEFT OUTER JOIN
						                      ARANCEL ON VFillPedImpDet.AR_IMPMX = ARANCEL.AR_CODIGO	
						WHERE     (FACTIMP.PI_RECTIFICA = @picodigo) and (VFillPedImpDet.MA_CODIGO is not null)
						GROUP BY VFillPedImpDet.MA_CODIGO, VFillPedImpDet.FID_NOPARTE, 
						                      VFillPedImpDet.ME_CODIGO, VFillPedImpDet.MA_GENERICO, 
								VFillPedImpDet.FID_SEC_IMP, CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(VFillPedImpDet.FID_ORD_COMP,0) else 0 end, 
						                      VFillPedImpDet.FID_DEF_TIP, VFillPedImpDet.FID_POR_DEF, VFillPedImpDet.PA_CODIGO, 
						                      VFillPedImpDet.SPI_CODIGO, isnull(DIR_CLIENTE.PA_CODIGO,233), 
						                      isnull(VFillPedImpDet.CS_CODIGO,8), (case when FID_PADREKITINSERT='N' then (case when isnull(VFillPedImpDet.CS_CODIGO,8)=2 then 'N' else 'S' end)
									else 'S' end), ARANCEL.AR_FRACCION
						ORDER BY ARANCEL.AR_FRACCION, isnull(VFillPedImpDet.FID_NOPARTE,''), MAX(VFillPedImpDet.FID_NOMBRE)
	
					end
				
					if exists (select * from factimpdet, factimp where factimp.pi_rectifica=@picodigo and factimpdet.cs_codigo=2 and factimpdet.FID_PADREKITINSERT='N'
					and factimp.fi_codigo=factimpdet.fi_codigo)
					-- si FID_PADREKITINSERT='N' significa que inserta el padre pero como no descargable, y los componentes como si descargables
				
					exec fillpedimpdetKit_rect @picodigo, @user
			
			
			--		IF (SELECT CF_EMPDESPIMP FROM CONFIGURACION)='S' /* si la empresa quiere llevar el control del empaque que importa como desperdicio */	
					exec fillpedimpemp_rect @picodigo, @user		/*inserta en el detalle los empaques de la factura*/
			
				end
			end
		end	
	
	end


	select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

	insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
	values (@user, 2, 'Generando calculos (detalle Pedimento)', 'Generating calculations (Detail Pedimento) ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)


	/*update Temppedimpdet
	set ME_ARIMPMX=(select me_codigo from arancel where ar_codigo=Temppedimpdet.AR_IMPMX)
	*/

	IF (SELECT PICF_PEDIMPSINAGRUP FROM PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='S'--  no se hace ninguna agrupacion
	begin
		update Temppedimpdet  
		set EQ_GENERICO= round(PID_CAN_GEN/PID_CANT,6),	
		      EQ_IMPMX=round(PID_CAN_AR/PID_CANT,6)
		where PID_CANT >0
	end
	else
	begin
		update Temppedimpdet  
		set EQ_GENERICO= round(PID_CAN_GEN/PID_CANT,6),	
		    EQ_IMPMX=round(PID_CAN_AR/PID_CANT,6)
		where PID_CANT >0

		update Temppedimpdet  
		set PID_PES_UNIKG=round(PID_CAN_AR/PID_CANT,6)
		--Correción descargas 11-Nov-09 Manuel G.
		where PID_CANT >0 AND ME_ARIMPMX IN (SELECT ME_KILOGRAMOS FROM CONFIGURACION)

	end

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
	where fid_def_tip<>'P' and fi_codigo in
	(select fi_codigo from factimp where pi_codigo=@picodigo or pi_rectifica=@picodigo)



	update factimpdet
	set fid_sec_imp=0
	where fid_def_tip<>'S' and fi_codigo in
	(select fi_codigo from factimp where pi_codigo=@picodigo or pi_rectifica=@picodigo)


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
		exec FillPIDescarga @picodigo, @user
		
		
		
		if  @ccp_tipo in ('IE', 'RG', 'SI', 'CN') 
		and (select PI_GENERASALDOF4 from pedimp where pi_codigo =@picodigo)='S'
		begin
			--if (select CF_USASALDOPEDIMPDEFINITO from configuracion)='S' or 
			--(select cp_descargable from claveped where cp_codigo in (select cp_codigo from pedimp where pi_codigo=@picodigo))='S'
			exec FillPIDescarga @picodigo, @user
		
		end
	end

	if (select min(pid_indiced) from TempPedImpDet)=0
	SELECT     @maximo= isnull(MAX(PID_INDICED),0)+1
	FROM         PEDIMPDET
	else
	SELECT     @maximo= isnull(MAX(PID_INDICED),1)
	FROM         PEDIMPDET

	
/* INSERCION COMPLETA SUSTITUIDA POR EL STORED sp_FillDetalle

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
*/



exec sp_CalculaTPago @picodigo, 'E'




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



	insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
	values (@user, 2, 'Llenando secuencia Orden Compra ', 'Filling PO Secuencial No. ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)

--	if exists (select * from TempPedImpDet where PID_ORD_COMP is not null and PID_ORD_COMP<>'')
	EXEC SP_SECUENCIAPO @picodigo

	select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

	insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
	values (@user, 2, 'Ligando detalle Pedimento - Detalle Factura ', 'Linking Pedimento Detail - Invoice Detail ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)


-- se hace la liga con detalles de facturas 

	EXEC LigaPedDetalle @picodigo
/*	IF (SELECT PICF_PEDIMPSINAGRUP FROM PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='S'--  no se hace ninguna agrupacion
	begin
		-- En el campo PID_CODIGOFACT se guarda temporalmente el fid_indiced
			if @ccp_tipo<>'RE'
			begin

				UPDATE FACTIMPDET
				SET     FACTIMPDET.PID_INDICEDLIGA =PEDIMPDET.PID_INDICED
 				FROM         FACTIMPDET INNER JOIN
	  	                            PEDIMPDET ON FACTIMPDET.FID_INDICED = PEDIMPDET.PID_CODIGOFACT 			
				WHERE PEDIMPDET.PI_CODIGO=@picodigo 


				UPDATE PEDIMPDET 
				SET     PEDIMPDET.PID_CODIGOFACT =FACTIMPDET.FI_CODIGO
 				FROM         FACTIMPDET INNER JOIN
	  	                            PEDIMPDET ON FACTIMPDET.PID_INDICEDLIGA = PEDIMPDET.PID_INDICED 			
				WHERE PEDIMPDET.PI_CODIGO=@picodigo 

			end
			else
			begin
				UPDATE FACTIMPDET
				SET     FACTIMPDET.PID_INDICEDLIGAR1 =PEDIMPDET.PID_INDICED
 				FROM         FACTIMPDET INNER JOIN
	  	                            PEDIMPDET ON FACTIMPDET.FID_INDICED = PEDIMPDET.PID_CODIGOFACT 			
				WHERE PEDIMPDET.PI_CODIGO=@picodigo 


				UPDATE PEDIMPDET 
				SET     PEDIMPDET.PID_CODIGOFACT =FACTIMPDET.FI_CODIGO
 				FROM         FACTIMPDET INNER JOIN
	  	                            PEDIMPDET ON FACTIMPDET.PID_INDICEDLIGAR1 = PEDIMPDET.PID_INDICED 			
				WHERE PEDIMPDET.PI_CODIGO=@picodigo 


			end
	end
	else
	begin

		if (SELECT PICF_SAAIDETDIVPO  FROM PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='S'
		begin
				-- activo fijo, la diferencia es que agrupa por desc. en espanol
				if @ccp_tipo in ('IA', 'IM') or ((select PI_DESP_EQUIPO from pedimp where pi_codigo=@picodigo) ='S' and @ccp_tipo in ('VT', 'IV', 'EV', 'IE'))
				or (SELECT COUNT(*) FROM FACTIMP INNER JOIN TEMBARQUE ON FACTIMP.TQ_CODIGO = TEMBARQUE.TQ_CODIGO
				     WHERE TEMBARQUE.TQ_NOMBRE LIKE '%CASO ESPECIAL%' AND (FACTIMP.PI_CODIGO = @picodigo or FACTIMP.PI_RECTIFICA = @picodigo))>0

				begin
		
		
						IF (SELECT PICF_SAAIDETDIVFACT FROM PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='S'
						begin
							begin tran			
							UPDATE FACTIMPDET
							SET     FACTIMPDET.PID_INDICEDLIGA =PEDIMPDET.PID_INDICED
			 				FROM         FACTIMPDET INNER JOIN
				  	                            PEDIMPDET ON FACTIMPDET.MA_CODIGO = PEDIMPDET.MA_CODIGO 			
							AND FACTIMPDET.FID_NOPARTE = PEDIMPDET.PID_NOPARTE 
							AND FACTIMPDET.FID_NOMBRE = PEDIMPDET.PID_NOMBRE
							AND  ISNULL(FACTIMPDET.ME_CODIGO, 0) = ISNULL(PEDIMPDET.ME_CODIGO, 0) 
							AND ISNULL(FACTIMPDET.MA_GENERICO, 0) = ISNULL(PEDIMPDET.MA_GENERICO, 0) 
							AND ISNULL(FACTIMPDET.FID_ORD_COMP, 0) = ISNULL(PEDIMPDET.PID_ORD_COMP, 0) 
							AND ISNULL(FACTIMPDET.AR_IMPMX, 0) = ISNULL(PEDIMPDET.AR_IMPMX, 0) 
							AND ISNULL(FACTIMPDET.FID_RATEEXPFO, - 1) = ISNULL(PEDIMPDET.PID_RATEEXPFO, - 1) 
							AND ISNULL(FACTIMPDET.FID_SEC_IMP, 0) = ISNULL(PEDIMPDET.PID_SEC_IMP, 0) 
							AND ISNULL(FACTIMPDET.FID_DEF_TIP, 'G') = ISNULL(PEDIMPDET.PID_DEF_TIP, 'G') 
							AND ISNULL(FACTIMPDET.FID_POR_DEF, - 1) = ISNULL(PEDIMPDET.PID_POR_DEF, - 1) 
							AND ISNULL(FACTIMPDET.PA_CODIGO, 0) = ISNULL(PEDIMPDET.PA_ORIGEN, 0) 
							AND ISNULL(FACTIMPDET.SPI_CODIGO, 0) = ISNULL(PEDIMPDET.SPI_CODIGO, 0) 
							AND ISNULL(FACTIMPDET.CS_CODIGO, 8) = isnull(PEDIMPDET.CS_CODIGO ,8)			
							AND isnull(PEDIMPDET.PID_CODIGOFACT, 0) = isnull(FACTIMPDET.FI_CODIGO, 0)
							AND (case when FID_PADREKITINSERT='N' then (case when isnull(FACTIMPDET.CS_CODIGO,8)=2 then 'N' else 'S' end)
									else 'S' end)= PEDIMPDET.PID_DESCARGABLE
							AND PEDIMPDET.PID_IMPRIMIR ='S'
							INNER JOIN FACTIMP ON PEDIMPDET.PI_CODIGO = FACTIMP.PI_CODIGO AND FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
							WHERE PEDIMPDET.PI_CODIGO=@picodigo and factimp.mo_codigo not IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154)
								AND PEDIMPDET.PA_PROCEDE = isnull((SELECT DIR_CLIENTE.PA_CODIGO FROM DIR_CLIENTE WHERE DI_INDICE=FACTIMP.DI_PROVEE),233)			
							commit tran
			
			
			
		
							begin tran
							UPDATE FACTIMPDET
							SET     FACTIMPDET.PID_INDICEDLIGA =PEDIMPDET.PID_INDICED
							FROM         FACTIMPDET INNER JOIN
					                            PEDIMPDET ON FACTIMPDET.MA_CODIGO = PEDIMPDET.MA_CODIGO 			
							AND FACTIMPDET.FID_NOPARTE = PEDIMPDET.PID_NOPARTE 
							AND FACTIMPDET.FID_NOMBRE = PEDIMPDET.PID_NOMBRE
							AND  ISNULL(FACTIMPDET.ME_CODIGO, 0) = ISNULL(PEDIMPDET.ME_CODIGO, 0) 
							AND ISNULL(FACTIMPDET.MA_GENERICO, 0) = ISNULL(PEDIMPDET.MA_GENERICO, 0) 
							AND ISNULL(FACTIMPDET.FID_ORD_COMP, 0) = ISNULL(PEDIMPDET.PID_ORD_COMP, 0) 
							AND ISNULL(FACTIMPDET.AR_IMPMX, 0) = ISNULL(PEDIMPDET.AR_IMPMX, 0) 
							AND ISNULL(FACTIMPDET.FID_RATEEXPFO, - 1) = ISNULL(PEDIMPDET.PID_RATEEXPFO, - 1) 
							AND ISNULL(FACTIMPDET.FID_SEC_IMP, 0) = ISNULL(PEDIMPDET.PID_SEC_IMP, 0) 	
							AND ISNULL(FACTIMPDET.FID_DEF_TIP, 'G') = ISNULL(PEDIMPDET.PID_DEF_TIP, 'G') 
							AND ISNULL(FACTIMPDET.FID_POR_DEF, - 1) = ISNULL(PEDIMPDET.PID_POR_DEF, - 1) 
							AND ISNULL(FACTIMPDET.PA_CODIGO, 0) = ISNULL(PEDIMPDET.PA_ORIGEN, 0) 
							AND ISNULL(FACTIMPDET.SPI_CODIGO, 0) = ISNULL(PEDIMPDET.SPI_CODIGO, 0) 
							AND ISNULL(FACTIMPDET.CS_CODIGO, 8) = isnull(PEDIMPDET.CS_CODIGO ,8)			
							AND isnull(PEDIMPDET.PID_CODIGOFACT, 0) = isnull(FACTIMPDET.FI_CODIGO, 0)
							AND PEDIMPDET.PID_IMPRIMIR ='S'
							AND (case when FID_PADREKITINSERT='N' then (case when isnull(FACTIMPDET.CS_CODIGO,8)=2 then 'N' else 'S' end)			
									else 'S' end)= PEDIMPDET.PID_DESCARGABLE
			
							INNER JOIN FACTIMP ON PEDIMPDET.PI_CODIGO = FACTIMP.PI_CODIGO AND FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
							WHERE PEDIMPDET.PI_CODIGO=@picodigo and factimp.mo_codigo IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154)
									AND PEDIMPDET.PA_PROCEDE = isnull((SELECT DIR_CLIENTE.PA_CODIGO FROM DIR_CLIENTE WHERE DI_INDICE=FACTIMP.DI_PROVEE),233)			
							commit tran
			
			
						end				
						else
						begin
							begin tran
							UPDATE FACTIMPDET
							SET     FACTIMPDET.PID_INDICEDLIGA =PEDIMPDET.PID_INDICED
							FROM         FACTIMPDET INNER JOIN
					                            PEDIMPDET ON FACTIMPDET.MA_CODIGO = PEDIMPDET.MA_CODIGO 			
							AND FACTIMPDET.FID_NOPARTE = PEDIMPDET.PID_NOPARTE 
							AND FACTIMPDET.FID_NOMBRE = PEDIMPDET.PID_NOMBRE 
							INNER JOIN FACTIMP ON PEDIMPDET.PI_CODIGO = FACTIMP.PI_CODIGO AND FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
							WHERE PEDIMPDET.PI_CODIGO=@picodigo and factimp.mo_codigo not IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154)
							AND  ISNULL(FACTIMPDET.ME_CODIGO, 0) = ISNULL(PEDIMPDET.ME_CODIGO, 0) 
							AND ISNULL(FACTIMPDET.MA_GENERICO, 0) = ISNULL(PEDIMPDET.MA_GENERICO, 0) 
							AND ISNULL(FACTIMPDET.FID_ORD_COMP, 0) = ISNULL(PEDIMPDET.PID_ORD_COMP, 0) 
							AND ISNULL(FACTIMPDET.AR_IMPMX, 0) = ISNULL(PEDIMPDET.AR_IMPMX, 0) 
							AND ISNULL(FACTIMPDET.FID_RATEEXPFO, - 1) = ISNULL(PEDIMPDET.PID_RATEEXPFO, - 1) 
							AND ISNULL(FACTIMPDET.FID_SEC_IMP, 0) = ISNULL(PEDIMPDET.PID_SEC_IMP, 0) 
			--				AND ROUND(ISNULL(FACTIMPDET.FID_COS_UNI, 0),6,1) = ROUND(ISNULL(PEDIMPDET.PID_COS_UNI, 0),6,1)
							AND ISNULL(FACTIMPDET.FID_DEF_TIP, 'G') = ISNULL(PEDIMPDET.PID_DEF_TIP, 'G') 		
							AND ISNULL(FACTIMPDET.FID_POR_DEF, - 1) = ISNULL(PEDIMPDET.PID_POR_DEF, - 1) 
							AND ISNULL(FACTIMPDET.PA_CODIGO, 0) = ISNULL(PEDIMPDET.PA_ORIGEN, 0) 
							AND ISNULL(FACTIMPDET.SPI_CODIGO, 0) = ISNULL(PEDIMPDET.SPI_CODIGO, 0) 
							AND ISNULL(FACTIMPDET.CS_CODIGO, 8) = isnull(PEDIMPDET.CS_CODIGO ,8)			
							AND PEDIMPDET.PID_IMPRIMIR ='S' 
							AND (case when FID_PADREKITINSERT='N' then (case when isnull(FACTIMPDET.CS_CODIGO,8)=2 then 'N' else 'S' end)
								else 'S' end)= PEDIMPDET.PID_DESCARGABLE
							AND PEDIMPDET.PA_PROCEDE = isnull((SELECT DIR_CLIENTE.PA_CODIGO FROM DIR_CLIENTE WHERE DI_INDICE=FACTIMP.DI_PROVEE),233)			
			
							commit tran
			
							begin tran
							UPDATE FACTIMPDET
							SET     FACTIMPDET.PID_INDICEDLIGA =PEDIMPDET.PID_INDICED
							FROM         FACTIMPDET INNER JOIN
					                            PEDIMPDET ON FACTIMPDET.MA_CODIGO = PEDIMPDET.MA_CODIGO 			
							AND FACTIMPDET.FID_NOPARTE = PEDIMPDET.PID_NOPARTE 
							AND FACTIMPDET.FID_NOMBRE = PEDIMPDET.PID_NOMBRE 
							AND  ISNULL(FACTIMPDET.ME_CODIGO, 0) = ISNULL(PEDIMPDET.ME_CODIGO, 0) 
							AND ISNULL(FACTIMPDET.MA_GENERICO, 0) = ISNULL(PEDIMPDET.MA_GENERICO, 0) 
							AND ISNULL(FACTIMPDET.FID_ORD_COMP, 0) = ISNULL(PEDIMPDET.PID_ORD_COMP, 0) 
							AND ISNULL(FACTIMPDET.AR_IMPMX, 0) = ISNULL(PEDIMPDET.AR_IMPMX, 0) 
							AND ISNULL(FACTIMPDET.FID_RATEEXPFO, - 1) = ISNULL(PEDIMPDET.PID_RATEEXPFO, - 1) 
							AND ISNULL(FACTIMPDET.FID_SEC_IMP, 0) = ISNULL(PEDIMPDET.PID_SEC_IMP, 0) 
			--				AND ROUND(ISNULL(FACTIMPDET.FID_COS_UNI, 0),6,1) = ROUND(ISNULL(PEDIMPDET.PID_COS_UNI*@PI_TIP_CAM, 0),6,1)
							AND ISNULL(FACTIMPDET.FID_DEF_TIP, 'G') = ISNULL(PEDIMPDET.PID_DEF_TIP, 'G') 		
							AND ISNULL(FACTIMPDET.FID_POR_DEF, - 1) = ISNULL(PEDIMPDET.PID_POR_DEF, - 1) 
							AND ISNULL(FACTIMPDET.PA_CODIGO, 0) = ISNULL(PEDIMPDET.PA_ORIGEN, 0) 
							AND ISNULL(FACTIMPDET.SPI_CODIGO, 0) = ISNULL(PEDIMPDET.SPI_CODIGO, 0) 
							AND ISNULL(FACTIMPDET.CS_CODIGO, 8) = isnull(PEDIMPDET.CS_CODIGO ,8)			
							AND PEDIMPDET.PID_IMPRIMIR ='S' 
							AND (case when FID_PADREKITINSERT='N' then (case when isnull(FACTIMPDET.CS_CODIGO,8)=2 then 'N' else 'S' end)
									else 'S' end)= PEDIMPDET.PID_DESCARGABLE
							INNER JOIN FACTIMP ON PEDIMPDET.PI_CODIGO = FACTIMP.PI_CODIGO AND FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
							WHERE PEDIMPDET.PI_CODIGO=@picodigo and FACTIMP.mo_codigo IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154)
								AND PEDIMPDET.PA_PROCEDE = isnull((SELECT DIR_CLIENTE.PA_CODIGO FROM DIR_CLIENTE WHERE DI_INDICE=FACTIMP.DI_PROVEE),233)			
							commit tran
			
			
			
						end
			
			
		
				end
			else
			begin
		
					if @ccp_tipo<>'RE'		
					begin
				
				
							IF (SELECT PICF_SAAIDETDIVFACT FROM PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='S'
							begin
								begin  tran
								UPDATE FACTIMPDET
								SET     FACTIMPDET.PID_INDICEDLIGA =PEDIMPDET.PID_INDICED
								FROM         FACTIMPDET INNER JOIN
						                      PEDIMPDET ON FACTIMPDET.MA_CODIGO = PEDIMPDET.MA_CODIGO 			
								AND FACTIMPDET.FID_NOPARTE = PEDIMPDET.PID_NOPARTE 
								AND  ISNULL(FACTIMPDET.ME_CODIGO, 0) = ISNULL(PEDIMPDET.ME_CODIGO, 0) 
								AND ISNULL(FACTIMPDET.MA_GENERICO, 0) = ISNULL(PEDIMPDET.MA_GENERICO, 0) 
								AND ISNULL(FACTIMPDET.FID_ORD_COMP, 0) = ISNULL(PEDIMPDET.PID_ORD_COMP, 0) 
								AND ISNULL(FACTIMPDET.AR_IMPMX, 0) = ISNULL(PEDIMPDET.AR_IMPMX, 0) 
								AND ISNULL(FACTIMPDET.FID_RATEEXPFO, - 1) = ISNULL(PEDIMPDET.PID_RATEEXPFO, - 1) 
								AND ISNULL(FACTIMPDET.FID_SEC_IMP, 0) = ISNULL(PEDIMPDET.PID_SEC_IMP, 0) 
								AND ISNULL(FACTIMPDET.FID_DEF_TIP, 'G') = ISNULL(PEDIMPDET.PID_DEF_TIP, 'G') 
								AND ISNULL(FACTIMPDET.FID_POR_DEF, - 1) = ISNULL(PEDIMPDET.PID_POR_DEF, - 1) 
								AND ISNULL(FACTIMPDET.PA_CODIGO, 0) = ISNULL(PEDIMPDET.PA_ORIGEN, 0) 
								AND ISNULL(FACTIMPDET.SPI_CODIGO, 0) = ISNULL(PEDIMPDET.SPI_CODIGO, 0) 
								AND ISNULL(FACTIMPDET.CS_CODIGO, 8) = isnull(PEDIMPDET.CS_CODIGO ,8)			
				--				AND isnull(FACTIMPDET.FID_NOPARTEAUX,'')=isnull(PEDIMPDET.PID_NOPARTEAUX,'')
								AND isnull(PEDIMPDET.PID_CODIGOFACT, 0) = isnull(FACTIMPDET.FI_CODIGO, 0)
								AND PEDIMPDET.PID_IMPRIMIR ='S'
								AND (case when FID_PADREKITINSERT='N' then (case when isnull(FACTIMPDET.CS_CODIGO,8)=2 then 'N' else 'S' end)
										else 'S' end)= PEDIMPDET.PID_DESCARGABLE
								INNER JOIN FACTIMP ON PEDIMPDET.PI_CODIGO = FACTIMP.PI_CODIGO AND FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
								WHERE PEDIMPDET.PI_CODIGO=@picodigo
									AND PEDIMPDET.PA_PROCEDE = isnull((SELECT DIR_CLIENTE.PA_CODIGO FROM DIR_CLIENTE WHERE DI_INDICE=FACTIMP.DI_PROVEE),233)			
								commit tran
							end
							else
							begin
								begin tran
								UPDATE FACTIMPDET
								SET     FACTIMPDET.PID_INDICEDLIGA =PEDIMPDET.PID_INDICED
								FROM         FACTIMPDET INNER JOIN
						                      PEDIMPDET ON FACTIMPDET.MA_CODIGO = PEDIMPDET.MA_CODIGO 			
								AND FACTIMPDET.FID_NOPARTE = PEDIMPDET.PID_NOPARTE 
								AND  ISNULL(FACTIMPDET.ME_CODIGO, 0) = ISNULL(PEDIMPDET.ME_CODIGO, 0) 
								AND ISNULL(FACTIMPDET.MA_GENERICO, 0) = ISNULL(PEDIMPDET.MA_GENERICO, 0) 
								AND ISNULL(FACTIMPDET.FID_ORD_COMP, 0) = ISNULL(PEDIMPDET.PID_ORD_COMP, 0) 
								AND ISNULL(FACTIMPDET.AR_IMPMX, 0) = ISNULL(PEDIMPDET.AR_IMPMX, 0) 
								AND ISNULL(FACTIMPDET.FID_RATEEXPFO, - 1) = ISNULL(PEDIMPDET.PID_RATEEXPFO, - 1) 
								AND ISNULL(FACTIMPDET.FID_SEC_IMP, 0) = ISNULL(PEDIMPDET.PID_SEC_IMP, 0) 
								AND ISNULL(FACTIMPDET.FID_DEF_TIP, 'G') = ISNULL(PEDIMPDET.PID_DEF_TIP, 'G') 			
								AND ISNULL(FACTIMPDET.FID_POR_DEF, - 1) = ISNULL(PEDIMPDET.PID_POR_DEF, - 1) 
								AND ISNULL(FACTIMPDET.PA_CODIGO, 0) = ISNULL(PEDIMPDET.PA_ORIGEN, 0) 
								AND ISNULL(FACTIMPDET.SPI_CODIGO, 0) = ISNULL(PEDIMPDET.SPI_CODIGO, 0) 
								AND ISNULL(FACTIMPDET.CS_CODIGO, 8) = isnull(PEDIMPDET.CS_CODIGO ,8)			
				--				AND isnull(FACTIMPDET.FID_NOPARTEAUX,'')=isnull(PEDIMPDET.PID_NOPARTEAUX,'')
				 				AND PEDIMPDET.PID_IMPRIMIR ='S'
								AND (case when FID_PADREKITINSERT='N' then (case when isnull(FACTIMPDET.CS_CODIGO,8)=2 then 'N' else 'S' end)
										else 'S' end)= PEDIMPDET.PID_DESCARGABLE
								INNER JOIN FACTIMP ON PEDIMPDET.PI_CODIGO = FACTIMP.PI_CODIGO AND FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
								WHERE PEDIMPDET.PI_CODIGO=@picodigo
									AND PEDIMPDET.PA_PROCEDE = isnull((SELECT DIR_CLIENTE.PA_CODIGO FROM DIR_CLIENTE WHERE DI_INDICE=FACTIMP.DI_PROVEE),233)			
								commit tran
							end
					end
					else	-- else del <>RE
					begin
			
						-- rectificacion de un pedimento de activo fijo
						if (@ccp_tipo='RE' and @ccp_tipo2 in ('IA', 'IM')) or
						((select PI_DESP_EQUIPO from pedimp where pi_codigo=@picodigo) ='S' and @ccp_tipo2 in ('VT', 'IV', 'EV', 'IE'))
	
						or (SELECT COUNT(*) FROM FACTIMP INNER JOIN TEMBARQUE ON FACTIMP.TQ_CODIGO = TEMBARQUE.TQ_CODIGO
						     WHERE TEMBARQUE.TQ_NOMBRE LIKE '%CASO ESPECIAL%' AND (FACTIMP.PI_CODIGO = @picodigo or FACTIMP.PI_RECTIFICA = @picodigo))>0
	
						--if exists(select cp_codigo from pedimp where pi_codigo in
						--(select pi_rectifica from pedimp where pi_codigo=@picodigo) and cp_codigo in (select cp_codigo from configuraclaveped where ccp_tipo in ('IA', 'IM')))
						begin		
							IF (SELECT PICF_SAAIDETDIVFACT FROM PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='S'
							begin
								begin tran
								UPDATE FACTIMPDET
								SET     FACTIMPDET.PID_INDICEDLIGAR1 =PEDIMPDET.PID_INDICED
								FROM         FACTIMPDET INNER JOIN
						                            PEDIMPDET ON FACTIMPDET.MA_CODIGO = PEDIMPDET.MA_CODIGO 
								AND FACTIMPDET.FID_NOPARTE = PEDIMPDET.PID_NOPARTE 
								AND FACTIMPDET.FID_NOMBRE = PEDIMPDET.PID_NOMBRE
								AND  ISNULL(FACTIMPDET.ME_CODIGO, 0) = ISNULL(PEDIMPDET.ME_CODIGO, 0) 
								AND ISNULL(FACTIMPDET.MA_GENERICO, 0) = ISNULL(PEDIMPDET.MA_GENERICO, 0) 
								AND ISNULL(FACTIMPDET.FID_ORD_COMP, 0) = ISNULL(PEDIMPDET.PID_ORD_COMP, 0) 				
								AND ISNULL(FACTIMPDET.AR_IMPMX, 0) = ISNULL(PEDIMPDET.AR_IMPMX, 0) 
								AND ISNULL(FACTIMPDET.FID_RATEEXPFO, - 1) = ISNULL(PEDIMPDET.PID_RATEEXPFO, - 1) 
								AND ISNULL(FACTIMPDET.FID_SEC_IMP, 0) = ISNULL(PEDIMPDET.PID_SEC_IMP, 0) 
		--						AND ROUND(ISNULL(FACTIMPDET.FID_COS_UNI, 0),6,1) = ROUND(ISNULL(PEDIMPDET.PID_COS_UNI, 0),6,1)
								AND ISNULL(FACTIMPDET.FID_DEF_TIP, 'G') = ISNULL(PEDIMPDET.PID_DEF_TIP, 'G') 
								AND ISNULL(FACTIMPDET.FID_POR_DEF, - 1) = ISNULL(PEDIMPDET.PID_POR_DEF, - 1) 			
								AND ISNULL(FACTIMPDET.PA_CODIGO, 0) = ISNULL(PEDIMPDET.PA_ORIGEN, 0) 
								AND ISNULL(FACTIMPDET.SPI_CODIGO, 0) = ISNULL(PEDIMPDET.SPI_CODIGO, 0) 
								AND ISNULL(FACTIMPDET.CS_CODIGO, 8) = isnull(PEDIMPDET.CS_CODIGO ,8)
			 					AND isnull(PEDIMPDET.PID_CODIGOFACT, 0) = isnull(FACTIMPDET.FI_CODIGO, 0)
		 		 				AND PEDIMPDET.PID_IMPRIMIR ='S'
								AND (case when FID_PADREKITINSERT='N' then (case when isnull(FACTIMPDET.CS_CODIGO,8)=2 then 'N' else 'S' end)
										else 'S' end)= PEDIMPDET.PID_DESCARGABLE
								INNER JOIN
						                            FACTIMP ON PEDIMPDET.PI_CODIGO = FACTIMP.PI_RECTIFICA AND FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
								WHERE PEDIMPDET.PI_CODIGO=@picodigo and factimp.mo_codigo not IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154)
								AND PEDIMPDET.PA_PROCEDE = isnull((SELECT DIR_CLIENTE.PA_CODIGO FROM DIR_CLIENTE WHERE DI_INDICE=FACTIMP.DI_PROVEE),233)			
								commit tran
		
		
								begin tran
								UPDATE FACTIMPDET
								SET     FACTIMPDET.PID_INDICEDLIGAR1 =PEDIMPDET.PID_INDICED
								FROM         FACTIMPDET INNER JOIN
						                            PEDIMPDET ON FACTIMPDET.MA_CODIGO = PEDIMPDET.MA_CODIGO 
								AND FACTIMPDET.FID_NOPARTE = PEDIMPDET.PID_NOPARTE 
								AND FACTIMPDET.FID_NOMBRE = PEDIMPDET.PID_NOMBRE
								AND  ISNULL(FACTIMPDET.ME_CODIGO, 0) = ISNULL(PEDIMPDET.ME_CODIGO, 0) 
								AND ISNULL(FACTIMPDET.MA_GENERICO, 0) = ISNULL(PEDIMPDET.MA_GENERICO, 0) 
								AND ISNULL(FACTIMPDET.FID_ORD_COMP, 0) = ISNULL(PEDIMPDET.PID_ORD_COMP, 0) 				
								AND ISNULL(FACTIMPDET.AR_IMPMX, 0) = ISNULL(PEDIMPDET.AR_IMPMX, 0) 
								AND ISNULL(FACTIMPDET.FID_RATEEXPFO, - 1) = ISNULL(PEDIMPDET.PID_RATEEXPFO, - 1) 
								AND ISNULL(FACTIMPDET.FID_SEC_IMP, 0) = ISNULL(PEDIMPDET.PID_SEC_IMP, 0) 
		--						AND ROUND(ISNULL(FACTIMPDET.FID_COS_UNI, 0),6,1) = ROUND(ISNULL(PEDIMPDET.PID_COS_UNI*@PI_TIP_CAM, 0),6,1)
								AND ISNULL(FACTIMPDET.FID_DEF_TIP, 'G') = ISNULL(PEDIMPDET.PID_DEF_TIP, 'G') 
								AND ISNULL(FACTIMPDET.FID_POR_DEF, - 1) = ISNULL(PEDIMPDET.PID_POR_DEF, - 1) 			
								AND ISNULL(FACTIMPDET.PA_CODIGO, 0) = ISNULL(PEDIMPDET.PA_ORIGEN, 0) 
								AND ISNULL(FACTIMPDET.SPI_CODIGO, 0) = ISNULL(PEDIMPDET.SPI_CODIGO, 0) 
								AND ISNULL(FACTIMPDET.CS_CODIGO, 8) = isnull(PEDIMPDET.CS_CODIGO ,8)
			 					AND isnull(PEDIMPDET.PID_CODIGOFACT, 0) = isnull(FACTIMPDET.FI_CODIGO, 0)
		 		 				AND PEDIMPDET.PID_IMPRIMIR ='S'
								AND (case when FID_PADREKITINSERT='N' then (case when isnull(FACTIMPDET.CS_CODIGO,8)=2 then 'N' else 'S' end)
									else 'S' end)= PEDIMPDET.PID_DESCARGABLE
								INNER JOIN
						                            FACTIMP ON PEDIMPDET.PI_CODIGO = FACTIMP.PI_RECTIFICA AND FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
								WHERE PEDIMPDET.PI_CODIGO=@picodigo and factimp.mo_codigo IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154)
								AND PEDIMPDET.PA_PROCEDE = isnull((SELECT DIR_CLIENTE.PA_CODIGO FROM DIR_CLIENTE WHERE DI_INDICE=FACTIMP.DI_PROVEE),233)			
								commit tran		
				
				
							end
							else
							begin
								begin tran
								UPDATE FACTIMPDET
								SET     FACTIMPDET.PID_INDICEDLIGAR1 =PEDIMPDET.PID_INDICED
								FROM         FACTIMPDET INNER JOIN
						                      PEDIMPDET ON FACTIMPDET.MA_CODIGO = PEDIMPDET.MA_CODIGO 
								AND FACTIMPDET.FID_NOPARTE = PEDIMPDET.PID_NOPARTE 
								AND FACTIMPDET.FID_NOMBRE = PEDIMPDET.PID_NOMBRE
								AND  ISNULL(FACTIMPDET.ME_CODIGO, 0) = ISNULL(PEDIMPDET.ME_CODIGO, 0) 
								AND ISNULL(FACTIMPDET.MA_GENERICO, 0) = ISNULL(PEDIMPDET.MA_GENERICO, 0) 
								AND ISNULL(FACTIMPDET.FID_ORD_COMP, 0) = ISNULL(PEDIMPDET.PID_ORD_COMP, 0) 
								AND ISNULL(FACTIMPDET.AR_IMPMX, 0) = ISNULL(PEDIMPDET.AR_IMPMX, 0) 
								AND ISNULL(FACTIMPDET.FID_RATEEXPFO, - 1) = ISNULL(PEDIMPDET.PID_RATEEXPFO, - 1) 
								AND ISNULL(FACTIMPDET.FID_SEC_IMP, 0) = ISNULL(PEDIMPDET.PID_SEC_IMP, 0) 
		--						AND ROUND(ISNULL(FACTIMPDET.FID_COS_UNI, 0),6,1) = ROUND(ISNULL(PEDIMPDET.PID_COS_UNI, 0),6,1)
								AND ISNULL(FACTIMPDET.FID_DEF_TIP, 'G') = ISNULL(PEDIMPDET.PID_DEF_TIP, 'G') 
								AND ISNULL(FACTIMPDET.FID_POR_DEF, - 1) = ISNULL(PEDIMPDET.PID_POR_DEF, - 1) 			
								AND ISNULL(FACTIMPDET.PA_CODIGO, 0) = ISNULL(PEDIMPDET.PA_ORIGEN, 0) 
								AND ISNULL(FACTIMPDET.SPI_CODIGO, 0) = ISNULL(PEDIMPDET.SPI_CODIGO, 0) 
								AND ISNULL(FACTIMPDET.CS_CODIGO, 8) = isnull(PEDIMPDET.CS_CODIGO ,8)
								AND PEDIMPDET.PID_IMPRIMIR ='S'
								AND (case when FID_PADREKITINSERT='N' then (case when isnull(FACTIMPDET.CS_CODIGO,8)=2 then 'N' else 'S' end)
										else 'S' end)= PEDIMPDET.PID_DESCARGABLE
								INNER JOIN FACTIMP ON PEDIMPDET.PI_CODIGO = FACTIMP.PI_RECTIFICA AND FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
								WHERE PEDIMPDET.PI_CODIGO=@picodigo and factimp.mo_codigo not IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154)
								AND PEDIMPDET.PA_PROCEDE = isnull((SELECT DIR_CLIENTE.PA_CODIGO FROM DIR_CLIENTE WHERE DI_INDICE=FACTIMP.DI_PROVEE),233)
								commit tran
		
		
								begin tran
								UPDATE FACTIMPDET
								SET     FACTIMPDET.PID_INDICEDLIGAR1 =PEDIMPDET.PID_INDICED
								FROM         FACTIMPDET INNER JOIN
						                      PEDIMPDET ON FACTIMPDET.MA_CODIGO = PEDIMPDET.MA_CODIGO 
								AND FACTIMPDET.FID_NOPARTE = PEDIMPDET.PID_NOPARTE 
								AND FACTIMPDET.FID_NOMBRE = PEDIMPDET.PID_NOMBRE
								AND  ISNULL(FACTIMPDET.ME_CODIGO, 0) = ISNULL(PEDIMPDET.ME_CODIGO, 0) 
								AND ISNULL(FACTIMPDET.MA_GENERICO, 0) = ISNULL(PEDIMPDET.MA_GENERICO, 0) 
								AND ISNULL(FACTIMPDET.FID_ORD_COMP, 0) = ISNULL(PEDIMPDET.PID_ORD_COMP, 0) 
								AND ISNULL(FACTIMPDET.AR_IMPMX, 0) = ISNULL(PEDIMPDET.AR_IMPMX, 0) 
								AND ISNULL(FACTIMPDET.FID_RATEEXPFO, - 1) = ISNULL(PEDIMPDET.PID_RATEEXPFO, - 1) 
								AND ISNULL(FACTIMPDET.FID_SEC_IMP, 0) = ISNULL(PEDIMPDET.PID_SEC_IMP, 0) 
		--						AND ROUND(ISNULL(FACTIMPDET.FID_COS_UNI, 0),6,1) = ROUND(ISNULL(PEDIMPDET.PID_COS_UNI*@PI_TIP_CAM, 0),6,1)
								AND ISNULL(FACTIMPDET.FID_DEF_TIP, 'G') = ISNULL(PEDIMPDET.PID_DEF_TIP, 'G') 
								AND ISNULL(FACTIMPDET.FID_POR_DEF, - 1) = ISNULL(PEDIMPDET.PID_POR_DEF, - 1) 			
								AND ISNULL(FACTIMPDET.PA_CODIGO, 0) = ISNULL(PEDIMPDET.PA_ORIGEN, 0) 
								AND ISNULL(FACTIMPDET.SPI_CODIGO, 0) = ISNULL(PEDIMPDET.SPI_CODIGO, 0) 
								AND ISNULL(FACTIMPDET.CS_CODIGO, 8) = isnull(PEDIMPDET.CS_CODIGO ,8)
								AND PEDIMPDET.PID_IMPRIMIR ='S'
								AND (case when FID_PADREKITINSERT='N' then (case when isnull(FACTIMPDET.CS_CODIGO,8)=2 then 'N' else 'S' end)
									else 'S' end)= PEDIMPDET.PID_DESCARGABLE		
								INNER JOIN FACTIMP ON PEDIMPDET.PI_CODIGO = FACTIMP.PI_RECTIFICA AND FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
								WHERE PEDIMPDET.PI_CODIGO=@picodigo and factimp.mo_codigo IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154)
								AND PEDIMPDET.PA_PROCEDE = isnull((SELECT DIR_CLIENTE.PA_CODIGO FROM DIR_CLIENTE WHERE DI_INDICE=FACTIMP.DI_PROVEE),233)			
								commit tran
		
		
		
		
		
							end
			
			
						end
						else
						begin
				
							IF (SELECT PICF_SAAIDETDIVFACT FROM PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='S'
							begin
								begin tran
								UPDATE FACTIMPDET
								SET     FACTIMPDET.PID_INDICEDLIGAR1 =PEDIMPDET.PID_INDICED
								FROM         FACTIMPDET INNER JOIN
						                      PEDIMPDET ON FACTIMPDET.MA_CODIGO = PEDIMPDET.MA_CODIGO 
								AND FACTIMPDET.FID_NOPARTE = PEDIMPDET.PID_NOPARTE 
								AND  ISNULL(FACTIMPDET.ME_CODIGO, 0) = ISNULL(PEDIMPDET.ME_CODIGO, 0) 
								AND ISNULL(FACTIMPDET.MA_GENERICO, 0) = ISNULL(PEDIMPDET.MA_GENERICO, 0) 
								AND ISNULL(FACTIMPDET.FID_ORD_COMP, 0) = ISNULL(PEDIMPDET.PID_ORD_COMP, 0) 
								AND ISNULL(FACTIMPDET.AR_IMPMX, 0) = ISNULL(PEDIMPDET.AR_IMPMX, 0) 		
								AND ISNULL(FACTIMPDET.FID_RATEEXPFO, - 1) = ISNULL(PEDIMPDET.PID_RATEEXPFO, - 1) 
								AND ISNULL(FACTIMPDET.FID_SEC_IMP, 0) = ISNULL(PEDIMPDET.PID_SEC_IMP, 0) 
								AND ISNULL(FACTIMPDET.FID_DEF_TIP, 'G') = ISNULL(PEDIMPDET.PID_DEF_TIP, 'G') 
								AND ISNULL(FACTIMPDET.FID_POR_DEF, - 1) = ISNULL(PEDIMPDET.PID_POR_DEF, - 1) 			
								AND ISNULL(FACTIMPDET.PA_CODIGO, 0) = ISNULL(PEDIMPDET.PA_ORIGEN, 0) 
								AND ISNULL(FACTIMPDET.SPI_CODIGO, 0) = ISNULL(PEDIMPDET.SPI_CODIGO, 0) 
								AND ISNULL(FACTIMPDET.CS_CODIGO, 8) = isnull(PEDIMPDET.CS_CODIGO ,8)
								AND isnull(PEDIMPDET.PID_CODIGOFACT, 0) = isnull(FACTIMPDET.FI_CODIGO, 0)
								AND PEDIMPDET.PID_IMPRIMIR ='S'
								AND (case when FID_PADREKITINSERT='N' then (case when isnull(FACTIMPDET.CS_CODIGO,8)=2 then 'N' else 'S' end)
									else 'S' end)= PEDIMPDET.PID_DESCARGABLE
								INNER JOIN FACTIMP ON PEDIMPDET.PI_CODIGO = FACTIMP.PI_RECTIFICA AND FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
								WHERE PEDIMPDET.PI_CODIGO=@picodigo
								AND PEDIMPDET.PA_PROCEDE = isnull((SELECT DIR_CLIENTE.PA_CODIGO FROM DIR_CLIENTE WHERE DI_INDICE=FACTIMP.DI_PROVEE),233)			
								commit tran
							end
							else
							begin
								begin tran
								UPDATE FACTIMPDET
								SET     FACTIMPDET.PID_INDICEDLIGAR1 =PEDIMPDET.PID_INDICED
								FROM         FACTIMPDET INNER JOIN
						                      PEDIMPDET ON FACTIMPDET.MA_CODIGO = PEDIMPDET.MA_CODIGO 
								AND FACTIMPDET.FID_NOPARTE = PEDIMPDET.PID_NOPARTE 
								AND  ISNULL(FACTIMPDET.ME_CODIGO, 0) = ISNULL(PEDIMPDET.ME_CODIGO, 0) 
								AND ISNULL(FACTIMPDET.MA_GENERICO, 0) = ISNULL(PEDIMPDET.MA_GENERICO, 0) 
								AND ISNULL(FACTIMPDET.FID_ORD_COMP, 0) = ISNULL(PEDIMPDET.PID_ORD_COMP, 0) 
								AND ISNULL(FACTIMPDET.AR_IMPMX, 0) = ISNULL(PEDIMPDET.AR_IMPMX, 0) 
								AND ISNULL(FACTIMPDET.FID_RATEEXPFO, - 1) = ISNULL(PEDIMPDET.PID_RATEEXPFO, - 1) 
								AND ISNULL(FACTIMPDET.FID_SEC_IMP, 0) = ISNULL(PEDIMPDET.PID_SEC_IMP, 0) 
								AND ISNULL(FACTIMPDET.FID_DEF_TIP, 'G') = ISNULL(PEDIMPDET.PID_DEF_TIP, 'G') 
								AND ISNULL(FACTIMPDET.FID_POR_DEF, - 1) = ISNULL(PEDIMPDET.PID_POR_DEF, - 1) 			
								AND ISNULL(FACTIMPDET.PA_CODIGO, 0) = ISNULL(PEDIMPDET.PA_ORIGEN, 0) 
								AND ISNULL(FACTIMPDET.SPI_CODIGO, 0) = ISNULL(PEDIMPDET.SPI_CODIGO, 0) 
								AND ISNULL(FACTIMPDET.CS_CODIGO, 8) = isnull(PEDIMPDET.CS_CODIGO ,8)
								AND PEDIMPDET.PID_IMPRIMIR ='S'
								AND (case when FID_PADREKITINSERT='N' then (case when isnull(FACTIMPDET.CS_CODIGO,8)=2 then 'N' else 'S' end)
									else 'S' end)= PEDIMPDET.PID_DESCARGABLE
								INNER JOIN FACTIMP ON PEDIMPDET.PI_CODIGO = FACTIMP.PI_RECTIFICA AND FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
								WHERE PEDIMPDET.PI_CODIGO=@picodigo
								AND PEDIMPDET.PA_PROCEDE = isnull((SELECT DIR_CLIENTE.PA_CODIGO FROM DIR_CLIENTE WHERE DI_INDICE=FACTIMP.DI_PROVEE),233)			
								commit tran
							end
						end
					end
			end




		end
		else  ------------------------------------------------------------------------------------------------------------------------- con sin PO
		begin

			-- activo fijo, la diferencia es que agrupa por desc. en espaol
			if @ccp_tipo in ('IA', 'IM') or ((select PI_DESP_EQUIPO from pedimp where pi_codigo=@picodigo) ='S' and @ccp_tipo in ('VT', 'IV', 'EV', 'IE'))
			or (SELECT COUNT(*) FROM FACTIMP INNER JOIN TEMBARQUE ON FACTIMP.TQ_CODIGO = TEMBARQUE.TQ_CODIGO
			     WHERE TEMBARQUE.TQ_NOMBRE LIKE '%CASO ESPECIAL%' AND (FACTIMP.PI_CODIGO = @picodigo or FACTIMP.PI_RECTIFICA = @picodigo))>0

			begin
	
	
					IF (SELECT PICF_SAAIDETDIVFACT FROM PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='S'
					begin
						begin tran		
						UPDATE FACTIMPDET
						SET     FACTIMPDET.PID_INDICEDLIGA =PEDIMPDET.PID_INDICED
		 				FROM         FACTIMPDET INNER JOIN
			  	                            PEDIMPDET ON FACTIMPDET.MA_CODIGO = PEDIMPDET.MA_CODIGO 			
						AND FACTIMPDET.FID_NOPARTE = PEDIMPDET.PID_NOPARTE 
						AND FACTIMPDET.FID_NOMBRE = PEDIMPDET.PID_NOMBRE
						AND  ISNULL(FACTIMPDET.ME_CODIGO, 0) = ISNULL(PEDIMPDET.ME_CODIGO, 0) 
						AND ISNULL(FACTIMPDET.MA_GENERICO, 0) = ISNULL(PEDIMPDET.MA_GENERICO, 0) 
						AND ISNULL(FACTIMPDET.AR_IMPMX, 0) = ISNULL(PEDIMPDET.AR_IMPMX, 0) 
						AND ISNULL(FACTIMPDET.FID_RATEEXPFO, - 1) = ISNULL(PEDIMPDET.PID_RATEEXPFO, - 1) 
						AND ISNULL(FACTIMPDET.FID_SEC_IMP, 0) = ISNULL(PEDIMPDET.PID_SEC_IMP, 0) 
						AND ISNULL(FACTIMPDET.FID_DEF_TIP, 'G') = ISNULL(PEDIMPDET.PID_DEF_TIP, 'G') 
						AND ISNULL(FACTIMPDET.FID_POR_DEF, - 1) = ISNULL(PEDIMPDET.PID_POR_DEF, - 1) 
						AND ISNULL(FACTIMPDET.PA_CODIGO, 0) = ISNULL(PEDIMPDET.PA_ORIGEN, 0) 
						AND ISNULL(FACTIMPDET.SPI_CODIGO, 0) = ISNULL(PEDIMPDET.SPI_CODIGO, 0) 
						AND ISNULL(FACTIMPDET.CS_CODIGO, 8) = isnull(PEDIMPDET.CS_CODIGO ,8)			
						AND isnull(PEDIMPDET.PID_CODIGOFACT, 0) = isnull(FACTIMPDET.FI_CODIGO, 0)
						AND (case when FID_PADREKITINSERT='N' then (case when isnull(FACTIMPDET.CS_CODIGO,8)=2 then 'N' else 'S' end)
								else 'S' end)= PEDIMPDET.PID_DESCARGABLE
						AND PEDIMPDET.PID_IMPRIMIR ='S'
						INNER JOIN FACTIMP ON PEDIMPDET.PI_CODIGO = FACTIMP.PI_CODIGO AND FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
						WHERE PEDIMPDET.PI_CODIGO=@picodigo and factimp.mo_codigo not IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154)
							AND PEDIMPDET.PA_PROCEDE = isnull((SELECT DIR_CLIENTE.PA_CODIGO FROM DIR_CLIENTE WHERE DI_INDICE=FACTIMP.DI_PROVEE),233)			
						commit tran
		
		
		
		
		 
		
						begin tran
						UPDATE FACTIMPDET
						SET     FACTIMPDET.PID_INDICEDLIGA =PEDIMPDET.PID_INDICED
						FROM         FACTIMPDET INNER JOIN
				                            PEDIMPDET ON FACTIMPDET.MA_CODIGO = PEDIMPDET.MA_CODIGO 			
						AND FACTIMPDET.FID_NOPARTE = PEDIMPDET.PID_NOPARTE 
						AND FACTIMPDET.FID_NOMBRE = PEDIMPDET.PID_NOMBRE
						AND  ISNULL(FACTIMPDET.ME_CODIGO, 0) = ISNULL(PEDIMPDET.ME_CODIGO, 0) 
						AND ISNULL(FACTIMPDET.MA_GENERICO, 0) = ISNULL(PEDIMPDET.MA_GENERICO, 0) 
						AND ISNULL(FACTIMPDET.AR_IMPMX, 0) = ISNULL(PEDIMPDET.AR_IMPMX, 0) 
						AND ISNULL(FACTIMPDET.FID_RATEEXPFO, - 1) = ISNULL(PEDIMPDET.PID_RATEEXPFO, - 1) 
						AND ISNULL(FACTIMPDET.FID_SEC_IMP, 0) = ISNULL(PEDIMPDET.PID_SEC_IMP, 0) 		
						AND ISNULL(FACTIMPDET.FID_DEF_TIP, 'G') = ISNULL(PEDIMPDET.PID_DEF_TIP, 'G') 
						AND ISNULL(FACTIMPDET.FID_POR_DEF, - 1) = ISNULL(PEDIMPDET.PID_POR_DEF, - 1) 
						AND ISNULL(FACTIMPDET.PA_CODIGO, 0) = ISNULL(PEDIMPDET.PA_ORIGEN, 0) 
						AND ISNULL(FACTIMPDET.SPI_CODIGO, 0) = ISNULL(PEDIMPDET.SPI_CODIGO, 0) 
						AND ISNULL(FACTIMPDET.CS_CODIGO, 8) = isnull(PEDIMPDET.CS_CODIGO ,8)			
						AND isnull(PEDIMPDET.PID_CODIGOFACT, 0) = isnull(FACTIMPDET.FI_CODIGO, 0)
						AND PEDIMPDET.PID_IMPRIMIR ='S'
						AND (case when FID_PADREKITINSERT='N' then (case when isnull(FACTIMPDET.CS_CODIGO,8)=2 then 'N' else 'S' end)		
								else 'S' end)= PEDIMPDET.PID_DESCARGABLE
		
						INNER JOIN FACTIMP ON PEDIMPDET.PI_CODIGO = FACTIMP.PI_CODIGO AND FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
						WHERE PEDIMPDET.PI_CODIGO=@picodigo and factimp.mo_codigo IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154)
								AND PEDIMPDET.PA_PROCEDE = isnull((SELECT DIR_CLIENTE.PA_CODIGO FROM DIR_CLIENTE WHERE DI_INDICE=FACTIMP.DI_PROVEE),233)			
						commit tran
		
		
					end		
					else
					begin
						begin tran
						UPDATE FACTIMPDET
						SET     FACTIMPDET.PID_INDICEDLIGA =PEDIMPDET.PID_INDICED
						FROM         FACTIMPDET INNER JOIN
				                            PEDIMPDET ON FACTIMPDET.MA_CODIGO = PEDIMPDET.MA_CODIGO 			
						AND FACTIMPDET.FID_NOPARTE = PEDIMPDET.PID_NOPARTE 
						AND FACTIMPDET.FID_NOMBRE = PEDIMPDET.PID_NOMBRE 
						INNER JOIN FACTIMP ON PEDIMPDET.PI_CODIGO = FACTIMP.PI_CODIGO AND FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
						WHERE PEDIMPDET.PI_CODIGO=@picodigo and factimp.mo_codigo not IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154)
						AND  ISNULL(FACTIMPDET.ME_CODIGO, 0) = ISNULL(PEDIMPDET.ME_CODIGO, 0) 
						AND ISNULL(FACTIMPDET.MA_GENERICO, 0) = ISNULL(PEDIMPDET.MA_GENERICO, 0) 
						AND ISNULL(FACTIMPDET.AR_IMPMX, 0) = ISNULL(PEDIMPDET.AR_IMPMX, 0) 
						AND ISNULL(FACTIMPDET.FID_RATEEXPFO, - 1) = ISNULL(PEDIMPDET.PID_RATEEXPFO, - 1) 
						AND ISNULL(FACTIMPDET.FID_SEC_IMP, 0) = ISNULL(PEDIMPDET.PID_SEC_IMP, 0) 
						AND ISNULL(FACTIMPDET.FID_DEF_TIP, 'G') = ISNULL(PEDIMPDET.PID_DEF_TIP, 'G') 		
						AND ISNULL(FACTIMPDET.FID_POR_DEF, - 1) = ISNULL(PEDIMPDET.PID_POR_DEF, - 1) 
						AND ISNULL(FACTIMPDET.PA_CODIGO, 0) = ISNULL(PEDIMPDET.PA_ORIGEN, 0) 
						AND ISNULL(FACTIMPDET.SPI_CODIGO, 0) = ISNULL(PEDIMPDET.SPI_CODIGO, 0) 
						AND ISNULL(FACTIMPDET.CS_CODIGO, 8) = isnull(PEDIMPDET.CS_CODIGO ,8)			
						AND PEDIMPDET.PID_IMPRIMIR ='S' 
						AND (case when FID_PADREKITINSERT='N' then (case when isnull(FACTIMPDET.CS_CODIGO,8)=2 then 'N' else 'S' end)
							else 'S' end)= PEDIMPDET.PID_DESCARGABLE
						AND PEDIMPDET.PA_PROCEDE = isnull((SELECT DIR_CLIENTE.PA_CODIGO FROM DIR_CLIENTE WHERE DI_INDICE=FACTIMP.DI_PROVEE),233)			
		
						commit tran
		
						begin tran
						UPDATE FACTIMPDET
						SET     FACTIMPDET.PID_INDICEDLIGA =PEDIMPDET.PID_INDICED
						FROM         FACTIMPDET INNER JOIN
				                            PEDIMPDET ON FACTIMPDET.MA_CODIGO = PEDIMPDET.MA_CODIGO 			
						AND FACTIMPDET.FID_NOPARTE = PEDIMPDET.PID_NOPARTE 
						AND FACTIMPDET.FID_NOMBRE = PEDIMPDET.PID_NOMBRE 
						AND  ISNULL(FACTIMPDET.ME_CODIGO, 0) = ISNULL(PEDIMPDET.ME_CODIGO, 0) 
						AND ISNULL(FACTIMPDET.MA_GENERICO, 0) = ISNULL(PEDIMPDET.MA_GENERICO, 0) 
						AND ISNULL(FACTIMPDET.AR_IMPMX, 0) = ISNULL(PEDIMPDET.AR_IMPMX, 0) 
						AND ISNULL(FACTIMPDET.FID_RATEEXPFO, - 1) = ISNULL(PEDIMPDET.PID_RATEEXPFO, - 1) 
						AND ISNULL(FACTIMPDET.FID_SEC_IMP, 0) = ISNULL(PEDIMPDET.PID_SEC_IMP, 0) 
						AND ISNULL(FACTIMPDET.FID_DEF_TIP, 'G') = ISNULL(PEDIMPDET.PID_DEF_TIP, 'G') 		
						AND ISNULL(FACTIMPDET.FID_POR_DEF, - 1) = ISNULL(PEDIMPDET.PID_POR_DEF, - 1) 
						AND ISNULL(FACTIMPDET.PA_CODIGO, 0) = ISNULL(PEDIMPDET.PA_ORIGEN, 0) 
						AND ISNULL(FACTIMPDET.SPI_CODIGO, 0) = ISNULL(PEDIMPDET.SPI_CODIGO, 0) 
						AND ISNULL(FACTIMPDET.CS_CODIGO, 8) = isnull(PEDIMPDET.CS_CODIGO ,8)			
						AND PEDIMPDET.PID_IMPRIMIR ='S' 
						AND (case when FID_PADREKITINSERT='N' then (case when isnull(FACTIMPDET.CS_CODIGO,8)=2 then 'N' else 'S' end)
								else 'S' end)= PEDIMPDET.PID_DESCARGABLE
						INNER JOIN FACTIMP ON PEDIMPDET.PI_CODIGO = FACTIMP.PI_CODIGO AND FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
						WHERE PEDIMPDET.PI_CODIGO=@picodigo and FACTIMP.mo_codigo IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154)
							AND PEDIMPDET.PA_PROCEDE = isnull((SELECT DIR_CLIENTE.PA_CODIGO FROM DIR_CLIENTE WHERE DI_INDICE=FACTIMP.DI_PROVEE),233)			
						commit tran
		
		
		
					end
		
		
	
			end
		else
		begin
	
				if @ccp_tipo<>'RE'	
				begin
			
			
						IF (SELECT PICF_SAAIDETDIVFACT FROM PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='S'
						begin
							begin  tran
							UPDATE FACTIMPDET
							SET     FACTIMPDET.PID_INDICEDLIGA =PEDIMPDET.PID_INDICED
							FROM         FACTIMPDET INNER JOIN
					                      PEDIMPDET ON FACTIMPDET.MA_CODIGO = PEDIMPDET.MA_CODIGO 			
							AND FACTIMPDET.FID_NOPARTE = PEDIMPDET.PID_NOPARTE 
							AND  ISNULL(FACTIMPDET.ME_CODIGO, 0) = ISNULL(PEDIMPDET.ME_CODIGO, 0) 
							AND ISNULL(FACTIMPDET.MA_GENERICO, 0) = ISNULL(PEDIMPDET.MA_GENERICO, 0) 
							AND ISNULL(FACTIMPDET.AR_IMPMX, 0) = ISNULL(PEDIMPDET.AR_IMPMX, 0) 
							AND ISNULL(FACTIMPDET.FID_RATEEXPFO, - 1) = ISNULL(PEDIMPDET.PID_RATEEXPFO, - 1) 
							AND ISNULL(FACTIMPDET.FID_SEC_IMP, 0) = ISNULL(PEDIMPDET.PID_SEC_IMP, 0) 
							AND ISNULL(FACTIMPDET.FID_DEF_TIP, 'G') = ISNULL(PEDIMPDET.PID_DEF_TIP, 'G') 
							AND ISNULL(FACTIMPDET.FID_POR_DEF, - 1) = ISNULL(PEDIMPDET.PID_POR_DEF, - 1) 
							AND ISNULL(FACTIMPDET.PA_CODIGO, 0) = ISNULL(PEDIMPDET.PA_ORIGEN, 0) 
							AND ISNULL(FACTIMPDET.SPI_CODIGO, 0) = ISNULL(PEDIMPDET.SPI_CODIGO, 0) 
							AND ISNULL(FACTIMPDET.CS_CODIGO, 8) = isnull(PEDIMPDET.CS_CODIGO ,8)			
							AND isnull(PEDIMPDET.PID_CODIGOFACT, 0) = isnull(FACTIMPDET.FI_CODIGO, 0)
							AND PEDIMPDET.PID_IMPRIMIR ='S'
							AND (case when FID_PADREKITINSERT='N' then (case when isnull(FACTIMPDET.CS_CODIGO,8)=2 then 'N' else 'S' end)
									else 'S' end)= PEDIMPDET.PID_DESCARGABLE
							INNER JOIN FACTIMP ON PEDIMPDET.PI_CODIGO = FACTIMP.PI_CODIGO AND FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
							WHERE PEDIMPDET.PI_CODIGO=@picodigo
								AND PEDIMPDET.PA_PROCEDE = isnull((SELECT DIR_CLIENTE.PA_CODIGO FROM DIR_CLIENTE WHERE DI_INDICE=FACTIMP.DI_PROVEE),233)			
							commit tran
						end
						else
						begin
							begin tran
							UPDATE FACTIMPDET
							SET     FACTIMPDET.PID_INDICEDLIGA =PEDIMPDET.PID_INDICED
							FROM         FACTIMPDET INNER JOIN
					                      PEDIMPDET ON FACTIMPDET.MA_CODIGO = PEDIMPDET.MA_CODIGO 			
							AND FACTIMPDET.FID_NOPARTE = PEDIMPDET.PID_NOPARTE 
							AND  ISNULL(FACTIMPDET.ME_CODIGO, 0) = ISNULL(PEDIMPDET.ME_CODIGO, 0) 
							AND ISNULL(FACTIMPDET.MA_GENERICO, 0) = ISNULL(PEDIMPDET.MA_GENERICO, 0) 
							AND ISNULL(FACTIMPDET.AR_IMPMX, 0) = ISNULL(PEDIMPDET.AR_IMPMX, 0) 
							AND ISNULL(FACTIMPDET.FID_RATEEXPFO, - 1) = ISNULL(PEDIMPDET.PID_RATEEXPFO, - 1) 
							AND ISNULL(FACTIMPDET.FID_SEC_IMP, 0) = ISNULL(PEDIMPDET.PID_SEC_IMP, 0) 
							AND ISNULL(FACTIMPDET.FID_DEF_TIP, 'G') = ISNULL(PEDIMPDET.PID_DEF_TIP, 'G') 			
							AND ISNULL(FACTIMPDET.FID_POR_DEF, - 1) = ISNULL(PEDIMPDET.PID_POR_DEF, - 1) 
							AND ISNULL(FACTIMPDET.PA_CODIGO, 0) = ISNULL(PEDIMPDET.PA_ORIGEN, 0) 
							AND ISNULL(FACTIMPDET.SPI_CODIGO, 0) = ISNULL(PEDIMPDET.SPI_CODIGO, 0) 
							AND ISNULL(FACTIMPDET.CS_CODIGO, 8) = isnull(PEDIMPDET.CS_CODIGO ,8)			
			 				AND PEDIMPDET.PID_IMPRIMIR ='S'
							AND (case when FID_PADREKITINSERT='N' then (case when isnull(FACTIMPDET.CS_CODIGO,8)=2 then 'N' else 'S' end)
									else 'S' end)= PEDIMPDET.PID_DESCARGABLE
							INNER JOIN FACTIMP ON PEDIMPDET.PI_CODIGO = FACTIMP.PI_CODIGO AND FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
							WHERE PEDIMPDET.PI_CODIGO=@picodigo
								AND PEDIMPDET.PA_PROCEDE = isnull((SELECT DIR_CLIENTE.PA_CODIGO FROM DIR_CLIENTE WHERE DI_INDICE=FACTIMP.DI_PROVEE),233)			
							commit tran
						end
				end
				else	-- else del <>RE
				begin
		
					-- rectificacion de un pedimento de activo fijo
					if (@ccp_tipo='RE' and @ccp_tipo2 in ('IA', 'IM')) or
					((select PI_DESP_EQUIPO from pedimp where pi_codigo=@picodigo) ='S' and @ccp_tipo2 in ('VT', 'IV', 'EV', 'IE'))
					or (SELECT COUNT(*) FROM FACTIMP INNER JOIN TEMBARQUE ON FACTIMP.TQ_CODIGO = TEMBARQUE.TQ_CODIGO
					     WHERE TEMBARQUE.TQ_NOMBRE LIKE '%CASO ESPECIAL%' AND (FACTIMP.PI_CODIGO = @picodigo or FACTIMP.PI_RECTIFICA = @picodigo))>0
	
					--if exists(select cp_codigo from pedimp where pi_codigo in
					--(select pi_rectifica from pedimp where pi_codigo=@picodigo) and cp_codigo in (select cp_codigo from configuraclaveped where ccp_tipo in ('IA', 'IM')))
					begin	
						IF (SELECT PICF_SAAIDETDIVFACT FROM PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='S'
						begin
							begin tran
							UPDATE FACTIMPDET
							SET     FACTIMPDET.PID_INDICEDLIGAR1 =PEDIMPDET.PID_INDICED
							FROM         FACTIMPDET INNER JOIN
					                            PEDIMPDET ON FACTIMPDET.MA_CODIGO = PEDIMPDET.MA_CODIGO 
							AND FACTIMPDET.FID_NOPARTE = PEDIMPDET.PID_NOPARTE 
							AND FACTIMPDET.FID_NOMBRE = PEDIMPDET.PID_NOMBRE
							AND  ISNULL(FACTIMPDET.ME_CODIGO, 0) = ISNULL(PEDIMPDET.ME_CODIGO, 0) 
							AND ISNULL(FACTIMPDET.MA_GENERICO, 0) = ISNULL(PEDIMPDET.MA_GENERICO, 0) 
							AND ISNULL(FACTIMPDET.AR_IMPMX, 0) = ISNULL(PEDIMPDET.AR_IMPMX, 0) 
							AND ISNULL(FACTIMPDET.FID_RATEEXPFO, - 1) = ISNULL(PEDIMPDET.PID_RATEEXPFO, - 1) 
							AND ISNULL(FACTIMPDET.FID_SEC_IMP, 0) = ISNULL(PEDIMPDET.PID_SEC_IMP, 0) 
							AND ISNULL(FACTIMPDET.FID_DEF_TIP, 'G') = ISNULL(PEDIMPDET.PID_DEF_TIP, 'G') 
							AND ISNULL(FACTIMPDET.FID_POR_DEF, - 1) = ISNULL(PEDIMPDET.PID_POR_DEF, - 1) 			
							AND ISNULL(FACTIMPDET.PA_CODIGO, 0) = ISNULL(PEDIMPDET.PA_ORIGEN, 0) 
							AND ISNULL(FACTIMPDET.SPI_CODIGO, 0) = ISNULL(PEDIMPDET.SPI_CODIGO, 0) 
							AND ISNULL(FACTIMPDET.CS_CODIGO, 8) = isnull(PEDIMPDET.CS_CODIGO ,8)
		 					AND isnull(PEDIMPDET.PID_CODIGOFACT, 0) = isnull(FACTIMPDET.FI_CODIGO, 0)
	 		 				AND PEDIMPDET.PID_IMPRIMIR ='S'
							AND (case when FID_PADREKITINSERT='N' then (case when isnull(FACTIMPDET.CS_CODIGO,8)=2 then 'N' else 'S' end)
									else 'S' end)= PEDIMPDET.PID_DESCARGABLE
							INNER JOIN
					                            FACTIMP ON PEDIMPDET.PI_CODIGO = FACTIMP.PI_RECTIFICA AND FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
							WHERE PEDIMPDET.PI_CODIGO=@picodigo and factimp.mo_codigo not IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154)
							AND PEDIMPDET.PA_PROCEDE = isnull((SELECT DIR_CLIENTE.PA_CODIGO FROM DIR_CLIENTE WHERE DI_INDICE=FACTIMP.DI_PROVEE),233)			
							commit tran
	
	
							begin tran
							UPDATE FACTIMPDET
							SET     FACTIMPDET.PID_INDICEDLIGAR1 =PEDIMPDET.PID_INDICED
							FROM         FACTIMPDET INNER JOIN
					                            PEDIMPDET ON FACTIMPDET.MA_CODIGO = PEDIMPDET.MA_CODIGO 
							AND FACTIMPDET.FID_NOPARTE = PEDIMPDET.PID_NOPARTE 
							AND FACTIMPDET.FID_NOMBRE = PEDIMPDET.PID_NOMBRE
							AND  ISNULL(FACTIMPDET.ME_CODIGO, 0) = ISNULL(PEDIMPDET.ME_CODIGO, 0) 
							AND ISNULL(FACTIMPDET.MA_GENERICO, 0) = ISNULL(PEDIMPDET.MA_GENERICO, 0) 
							AND ISNULL(FACTIMPDET.AR_IMPMX, 0) = ISNULL(PEDIMPDET.AR_IMPMX, 0) 
							AND ISNULL(FACTIMPDET.FID_RATEEXPFO, - 1) = ISNULL(PEDIMPDET.PID_RATEEXPFO, - 1) 
							AND ISNULL(FACTIMPDET.FID_SEC_IMP, 0) = ISNULL(PEDIMPDET.PID_SEC_IMP, 0) 
							AND ISNULL(FACTIMPDET.FID_DEF_TIP, 'G') = ISNULL(PEDIMPDET.PID_DEF_TIP, 'G') 
							AND ISNULL(FACTIMPDET.FID_POR_DEF, - 1) = ISNULL(PEDIMPDET.PID_POR_DEF, - 1) 			
							AND ISNULL(FACTIMPDET.PA_CODIGO, 0) = ISNULL(PEDIMPDET.PA_ORIGEN, 0) 
							AND ISNULL(FACTIMPDET.SPI_CODIGO, 0) = ISNULL(PEDIMPDET.SPI_CODIGO, 0) 
							AND ISNULL(FACTIMPDET.CS_CODIGO, 8) = isnull(PEDIMPDET.CS_CODIGO ,8)
		 					AND isnull(PEDIMPDET.PID_CODIGOFACT, 0) = isnull(FACTIMPDET.FI_CODIGO, 0)
	 		 				AND PEDIMPDET.PID_IMPRIMIR ='S'
							AND (case when FID_PADREKITINSERT='N' then (case when isnull(FACTIMPDET.CS_CODIGO,8)=2 then 'N' else 'S' end)
								else 'S' end)= PEDIMPDET.PID_DESCARGABLE
							INNER JOIN
					                            FACTIMP ON PEDIMPDET.PI_CODIGO = FACTIMP.PI_RECTIFICA AND FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
							WHERE PEDIMPDET.PI_CODIGO=@picodigo and factimp.mo_codigo IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154)
							AND PEDIMPDET.PA_PROCEDE = isnull((SELECT DIR_CLIENTE.PA_CODIGO FROM DIR_CLIENTE WHERE DI_INDICE=FACTIMP.DI_PROVEE),233)			
							commit tran	
		
		
						end
						else
						begin
							begin tran
							UPDATE FACTIMPDET
							SET     FACTIMPDET.PID_INDICEDLIGAR1 =PEDIMPDET.PID_INDICED
							FROM         FACTIMPDET INNER JOIN
					                      PEDIMPDET ON FACTIMPDET.MA_CODIGO = PEDIMPDET.MA_CODIGO 
							AND FACTIMPDET.FID_NOPARTE = PEDIMPDET.PID_NOPARTE 
							AND FACTIMPDET.FID_NOMBRE = PEDIMPDET.PID_NOMBRE
							AND  ISNULL(FACTIMPDET.ME_CODIGO, 0) = ISNULL(PEDIMPDET.ME_CODIGO, 0) 
							AND ISNULL(FACTIMPDET.MA_GENERICO, 0) = ISNULL(PEDIMPDET.MA_GENERICO, 0) 
							AND ISNULL(FACTIMPDET.AR_IMPMX, 0) = ISNULL(PEDIMPDET.AR_IMPMX, 0) 
							AND ISNULL(FACTIMPDET.FID_RATEEXPFO, - 1) = ISNULL(PEDIMPDET.PID_RATEEXPFO, - 1) 
							AND ISNULL(FACTIMPDET.FID_SEC_IMP, 0) = ISNULL(PEDIMPDET.PID_SEC_IMP, 0) 
							AND ISNULL(FACTIMPDET.FID_DEF_TIP, 'G') = ISNULL(PEDIMPDET.PID_DEF_TIP, 'G') 
							AND ISNULL(FACTIMPDET.FID_POR_DEF, - 1) = ISNULL(PEDIMPDET.PID_POR_DEF, - 1) 			
							AND ISNULL(FACTIMPDET.PA_CODIGO, 0) = ISNULL(PEDIMPDET.PA_ORIGEN, 0) 
							AND ISNULL(FACTIMPDET.SPI_CODIGO, 0) = ISNULL(PEDIMPDET.SPI_CODIGO, 0) 
							AND ISNULL(FACTIMPDET.CS_CODIGO, 8) = isnull(PEDIMPDET.CS_CODIGO ,8)
							AND PEDIMPDET.PID_IMPRIMIR ='S'
							AND (case when FID_PADREKITINSERT='N' then (case when isnull(FACTIMPDET.CS_CODIGO,8)=2 then 'N' else 'S' end)
									else 'S' end)= PEDIMPDET.PID_DESCARGABLE
							INNER JOIN FACTIMP ON PEDIMPDET.PI_CODIGO = FACTIMP.PI_RECTIFICA AND FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
							WHERE PEDIMPDET.PI_CODIGO=@picodigo and factimp.mo_codigo not IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154)
							AND PEDIMPDET.PA_PROCEDE = isnull((SELECT DIR_CLIENTE.PA_CODIGO FROM DIR_CLIENTE WHERE DI_INDICE=FACTIMP.DI_PROVEE),233)
							commit tran
	
	
							begin tran
							UPDATE FACTIMPDET
							SET     FACTIMPDET.PID_INDICEDLIGAR1 =PEDIMPDET.PID_INDICED
							FROM         FACTIMPDET INNER JOIN
					                      PEDIMPDET ON FACTIMPDET.MA_CODIGO = PEDIMPDET.MA_CODIGO 
							AND FACTIMPDET.FID_NOPARTE = PEDIMPDET.PID_NOPARTE 
							AND FACTIMPDET.FID_NOMBRE = PEDIMPDET.PID_NOMBRE
							AND  ISNULL(FACTIMPDET.ME_CODIGO, 0) = ISNULL(PEDIMPDET.ME_CODIGO, 0) 
							AND ISNULL(FACTIMPDET.MA_GENERICO, 0) = ISNULL(PEDIMPDET.MA_GENERICO, 0) 
							AND ISNULL(FACTIMPDET.AR_IMPMX, 0) = ISNULL(PEDIMPDET.AR_IMPMX, 0) 
							AND ISNULL(FACTIMPDET.FID_RATEEXPFO, - 1) = ISNULL(PEDIMPDET.PID_RATEEXPFO, - 1) 
							AND ISNULL(FACTIMPDET.FID_SEC_IMP, 0) = ISNULL(PEDIMPDET.PID_SEC_IMP, 0) 
							AND ISNULL(FACTIMPDET.FID_DEF_TIP, 'G') = ISNULL(PEDIMPDET.PID_DEF_TIP, 'G') 
							AND ISNULL(FACTIMPDET.FID_POR_DEF, - 1) = ISNULL(PEDIMPDET.PID_POR_DEF, - 1) 			
							AND ISNULL(FACTIMPDET.PA_CODIGO, 0) = ISNULL(PEDIMPDET.PA_ORIGEN, 0) 
							AND ISNULL(FACTIMPDET.SPI_CODIGO, 0) = ISNULL(PEDIMPDET.SPI_CODIGO, 0) 
							AND ISNULL(FACTIMPDET.CS_CODIGO, 8) = isnull(PEDIMPDET.CS_CODIGO ,8)
							AND PEDIMPDET.PID_IMPRIMIR ='S'
							AND (case when FID_PADREKITINSERT='N' then (case when isnull(FACTIMPDET.CS_CODIGO,8)=2 then 'N' else 'S' end)
								else 'S' end)= PEDIMPDET.PID_DESCARGABLE	
							INNER JOIN FACTIMP ON PEDIMPDET.PI_CODIGO = FACTIMP.PI_RECTIFICA AND FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
							WHERE PEDIMPDET.PI_CODIGO=@picodigo and factimp.mo_codigo IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154)
							AND PEDIMPDET.PA_PROCEDE = isnull((SELECT DIR_CLIENTE.PA_CODIGO FROM DIR_CLIENTE WHERE DI_INDICE=FACTIMP.DI_PROVEE),233)			
							commit tran
	
	
	
	
	
						end
		
		
					end
					else
					begin
			
						IF (SELECT PICF_SAAIDETDIVFACT FROM PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='S'
						begin
							begin tran
							UPDATE FACTIMPDET
							SET     FACTIMPDET.PID_INDICEDLIGAR1 =PEDIMPDET.PID_INDICED
							FROM         FACTIMPDET INNER JOIN
					                      PEDIMPDET ON FACTIMPDET.MA_CODIGO = PEDIMPDET.MA_CODIGO 
							AND FACTIMPDET.FID_NOPARTE = PEDIMPDET.PID_NOPARTE 
							AND  ISNULL(FACTIMPDET.ME_CODIGO, 0) = ISNULL(PEDIMPDET.ME_CODIGO, 0) 
							AND ISNULL(FACTIMPDET.MA_GENERICO, 0) = ISNULL(PEDIMPDET.MA_GENERICO, 0) 
							AND ISNULL(FACTIMPDET.AR_IMPMX, 0) = ISNULL(PEDIMPDET.AR_IMPMX, 0) 
							AND ISNULL(FACTIMPDET.FID_RATEEXPFO, - 1) = ISNULL(PEDIMPDET.PID_RATEEXPFO, - 1) 
							AND ISNULL(FACTIMPDET.FID_SEC_IMP, 0) = ISNULL(PEDIMPDET.PID_SEC_IMP, 0) 
							AND ISNULL(FACTIMPDET.FID_DEF_TIP, 'G') = ISNULL(PEDIMPDET.PID_DEF_TIP, 'G') 
							AND ISNULL(FACTIMPDET.FID_POR_DEF, - 1) = ISNULL(PEDIMPDET.PID_POR_DEF, - 1) 			
							AND ISNULL(FACTIMPDET.PA_CODIGO, 0) = ISNULL(PEDIMPDET.PA_ORIGEN, 0) 
							AND ISNULL(FACTIMPDET.SPI_CODIGO, 0) = ISNULL(PEDIMPDET.SPI_CODIGO, 0) 
							AND ISNULL(FACTIMPDET.CS_CODIGO, 8) = isnull(PEDIMPDET.CS_CODIGO ,8)
							AND isnull(PEDIMPDET.PID_CODIGOFACT, 0) = isnull(FACTIMPDET.FI_CODIGO, 0)
							AND PEDIMPDET.PID_IMPRIMIR ='S'
							AND (case when FID_PADREKITINSERT='N' then (case when isnull(FACTIMPDET.CS_CODIGO,8)=2 then 'N' else 'S' end)
								else 'S' end)= PEDIMPDET.PID_DESCARGABLE
							INNER JOIN FACTIMP ON PEDIMPDET.PI_CODIGO = FACTIMP.PI_RECTIFICA AND FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
							WHERE PEDIMPDET.PI_CODIGO=@picodigo
							AND PEDIMPDET.PA_PROCEDE = isnull((SELECT DIR_CLIENTE.PA_CODIGO FROM DIR_CLIENTE WHERE DI_INDICE=FACTIMP.DI_PROVEE),233)			
							commit tran
						end
						else
						begin
							begin tran
							UPDATE FACTIMPDET
							SET     FACTIMPDET.PID_INDICEDLIGAR1 =PEDIMPDET.PID_INDICED
							FROM         FACTIMPDET INNER JOIN
					                      PEDIMPDET ON FACTIMPDET.MA_CODIGO = PEDIMPDET.MA_CODIGO 
							AND FACTIMPDET.FID_NOPARTE = PEDIMPDET.PID_NOPARTE 
							AND  ISNULL(FACTIMPDET.ME_CODIGO, 0) = ISNULL(PEDIMPDET.ME_CODIGO, 0) 
							AND ISNULL(FACTIMPDET.MA_GENERICO, 0) = ISNULL(PEDIMPDET.MA_GENERICO, 0) 
							AND ISNULL(FACTIMPDET.AR_IMPMX, 0) = ISNULL(PEDIMPDET.AR_IMPMX, 0) 
							AND ISNULL(FACTIMPDET.FID_RATEEXPFO, - 1) = ISNULL(PEDIMPDET.PID_RATEEXPFO, - 1) 
							AND ISNULL(FACTIMPDET.FID_SEC_IMP, 0) = ISNULL(PEDIMPDET.PID_SEC_IMP, 0) 
							AND ISNULL(FACTIMPDET.FID_DEF_TIP, 'G') = ISNULL(PEDIMPDET.PID_DEF_TIP, 'G') 
							AND ISNULL(FACTIMPDET.FID_POR_DEF, - 1) = ISNULL(PEDIMPDET.PID_POR_DEF, - 1) 			
							AND ISNULL(FACTIMPDET.PA_CODIGO, 0) = ISNULL(PEDIMPDET.PA_ORIGEN, 0) 
							AND ISNULL(FACTIMPDET.SPI_CODIGO, 0) = ISNULL(PEDIMPDET.SPI_CODIGO, 0) 
							AND ISNULL(FACTIMPDET.CS_CODIGO, 8) = isnull(PEDIMPDET.CS_CODIGO ,8)
							AND PEDIMPDET.PID_IMPRIMIR ='S'
							AND (case when FID_PADREKITINSERT='N' then (case when isnull(FACTIMPDET.CS_CODIGO,8)=2 then 'N' else 'S' end)
								else 'S' end)= PEDIMPDET.PID_DESCARGABLE
							INNER JOIN FACTIMP ON PEDIMPDET.PI_CODIGO = FACTIMP.PI_RECTIFICA AND FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
							WHERE PEDIMPDET.PI_CODIGO=@picodigo
							AND PEDIMPDET.PA_PROCEDE = isnull((SELECT DIR_CLIENTE.PA_CODIGO FROM DIR_CLIENTE WHERE DI_INDICE=FACTIMP.DI_PROVEE),233)			
							commit tran
						end
					end
				end
			end
		end



	end*/



	exec ReemplazaDescargasR1 @picodigo, @user, @ccp_tipo



ALTER TABLE FACTIMPDET ENABLE trigger Update_FactImpDet


select @Pid_indiced= max(pid_indiced) from pedimpdet

	update consecutivo
	set cv_codigo =  isnull(@pid_indiced,0) + 1
	where cv_tipo = 'PID'


	ALTER TABLE PEDIMPDET ENABLE TRIGGER insert_pedimpdet
GO
