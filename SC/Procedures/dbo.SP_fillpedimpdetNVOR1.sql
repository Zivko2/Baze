SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE [dbo].[SP_fillpedimpdetNVOR1] (@picodigo int, @ccp_tipo varchar(5), @user int)   as

SET NOCOUNT ON 
declare @pid_indiced int, @pi_tip_cam decimal(38,6),  @pi_ft_adu decimal(38,9), @maximo int, @FechaActual varchar(10), @hora varchar(15),
@kap_indiced_ped int, @pid_saldogenr decimal(38,6),  @pid_can_genr decimal(38,6),@Sumkap_CantDesc decimal(38,6), @em_codigo int

	ALTER TABLE PEDIMPDET DISABLE TRIGGER insert_pedimpdet

	select @em_codigo=em_codigo from intradeglobal.dbo.empresa where em_corto in
	(select replace(convert(sysname,db_name()),'intrade',''))


select @FechaActual = convert(varchar(10), getdate(),101)
select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

	select @pi_tip_cam=pi_tip_cam, @pi_ft_adu=pi_ft_adu from pedimp where pi_codigo=@picodigo

	select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

	insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
	values (@user, 2, 'Llenando tabla temporal de detalle ', 'Filling Temporary Detail Table ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)


		TRUNCATE TABLE TempPedImpDet

		--print 'borrando detalles temp'

	dbcc checkident (TempPedimpdet, reseed, 1) WITH NO_INFOMSGS

	SELECT     @maximo= isnull(MAX(PID_INDICED),0)+1
	FROM         PEDIMPDET

	update factimpdet
	set FID_RATEEXPFO=0
	where fi_codigo in (select fi_codigo from factimp where pi_codigo=@picodigo or pi_rectifica=@picodigo)
	and (FID_RATEEXPFO<>0 or FID_RATEEXPFO is null)

	IF (SELECT PICF_SAAIDETDIVFACT FROM PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='S'
	begin
		if @ccp_tipo<>'RE'
		begin
			insert into TempPedImpDet(PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CANT, PID_CTOT_DLS, ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
					AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
					PA_PROCEDE, ME_GENERICO, PR_CODIGO, PID_ORD_COMP,
					PID_DESCARGABLE, PID_IMPRIMIR, CS_CODIGO, PID_COS_UNIVA, PID_COS_UNIMATGRA, PID_NOPARTEAUX, PID_CODIGOFACT)
			
			SELECT     @picodigo, ISNULL(dbo.FACTIMPDET.MA_CODIGO,0), isnull(dbo.FACTIMPDET.FID_NOPARTE,''), MAX(dbo.FACTIMPDET.FID_NOMBRE), MAX(dbo.FACTIMPDET.FID_NAME), 
			                      SUM(isnull(dbo.FACTIMPDET.FID_CANT_ST,0)), SUM(isnull(dbo.FACTIMPDET.FID_COS_TOT,0)), 
			                      dbo.FACTIMPDET.ME_CODIGO, isnull(dbo.FACTIMPDET.MA_GENERICO,0), 
			                      max(isnull(dbo.FACTIMPDET.EQ_GEN, 1)), max(isnull(dbo.FACTIMPDET.EQ_IMPMX, 1)), isnull(max(dbo.FACTIMPDET.AR_IMPMX),0), isnull(max(dbo.FACTIMPDET.AR_EXPFO),0), 
			                      0, dbo.FACTIMPDET.FID_SEC_IMP, isnull(dbo.FACTIMPDET.FID_DEF_TIP, 'G'), isnull(dbo.FACTIMPDET.FID_POR_DEF,-1), 
			                      MAX(isnull(dbo.FACTIMPDET.TI_CODIGO,10)), dbo.FACTIMPDET.PA_CODIGO, dbo.FACTIMPDET.SPI_CODIGO, dbo.MAESTRO.PA_PROCEDE, 
			                      max(dbo.FACTIMPDET.ME_GEN), MAX(dbo.FACTIMPDET.PR_CODIGO), isnull(dbo.FACTIMPDET.FID_ORD_COMP,0),
						'descargable'=case when FID_PADREKITINSERT='N' then (case when isnull(dbo.FACTIMPDET.CS_CODIGO,8)=2 then 'N' else 'S' end)
						else 'S' end, 'S', isnull(dbo.FACTIMPDET.CS_CODIGO,8), 0, 0, isnull(dbo.FACTIMPDET.FID_NOPARTEAUX,''), dbo.FACTIMPDET.FI_CODIGO
			FROM         dbo.FACTIMP LEFT OUTER JOIN
			                      dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO LEFT OUTER JOIN
			                      dbo.MAESTRO ON dbo.FACTIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
				        dbo.ARANCEL ON dbo.FACTIMPDET.AR_IMPMX = dbo.ARANCEL.AR_CODIGO
			WHERE     (dbo.FACTIMP.PI_CODIGO = @picodigo) and (dbo.FACTIMPDET.MA_CODIGO is not null)
			GROUP BY dbo.FACTIMPDET.MA_CODIGO, dbo.FACTIMPDET.FID_NOPARTE, 
			                      dbo.FACTIMPDET.ME_CODIGO, dbo.FACTIMPDET.MA_GENERICO, 
				        dbo.FACTIMPDET.FID_SEC_IMP, dbo.FACTIMPDET.FID_ORD_COMP, 
			                      dbo.FACTIMPDET.FID_DEF_TIP, dbo.FACTIMPDET.FID_POR_DEF, dbo.FACTIMPDET.PA_CODIGO, 
			                      dbo.FACTIMPDET.SPI_CODIGO, dbo.MAESTRO.PA_PROCEDE, 
			                      isnull(dbo.FACTIMPDET.CS_CODIGO,8), dbo.FACTIMPDET.FID_PADREKITINSERT,
				        dbo.FACTIMPDET.FID_NOPARTEAUX, dbo.FACTIMPDET.FI_CODIGO, dbo.ARANCEL.AR_FRACCION
			ORDER BY dbo.ARANCEL.AR_FRACCION, isnull(dbo.FACTIMPDET.FID_NOPARTE,''), MAX(dbo.FACTIMPDET.FID_NOMBRE)

			if exists (select * from factimpdet, factimp where factimp.pi_codigo=@picodigo and factimpdet.cs_codigo=2 and factimpdet.FID_PADREKITINSERT='N'
			and factimp.fi_codigo=factimpdet.fi_codigo)
		
			-- si FID_PADREKITINSERT='N' significa que inserta el padre pero como no descargable, y los componentes como si descargables
			exec fillpedimpdetkit @picodigo, @user
	
			---si la empresa no quiere llevar el control del empaque que importa como desperdicio estan los empaques que regresan vacios
			exec fillpedimpemp @picodigo, @user		/*inserta en el detalle los empaques de la factura */
	
	
	
		end
		else
		begin

			insert into TempPedImpDet(PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CANT, PID_CTOT_DLS, ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
					AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
					PA_PROCEDE, ME_GENERICO, PR_CODIGO, PID_ORD_COMP,
					PID_DESCARGABLE, PID_IMPRIMIR, CS_CODIGO, PID_COS_UNIVA, PID_COS_UNIMATGRA, PID_NOPARTEAUX, PID_CODIGOFACT, PID_INDICEDORIG)
			
			SELECT     @picodigo, ISNULL(dbo.FACTIMPDET.MA_CODIGO,0), isnull(dbo.FACTIMPDET.FID_NOPARTE,''), MAX(dbo.FACTIMPDET.FID_NOMBRE), MAX(dbo.FACTIMPDET.FID_NAME), 
			                      SUM(isnull(dbo.FACTIMPDET.FID_CANT_ST,0)), SUM(isnull(dbo.FACTIMPDET.FID_COS_TOT,0)), 
			                      dbo.FACTIMPDET.ME_CODIGO, isnull(dbo.FACTIMPDET.MA_GENERICO,0), 
			                      max(isnull(dbo.FACTIMPDET.EQ_GEN, 1)), max(isnull(dbo.FACTIMPDET.EQ_IMPMX, 1)), isnull(max(dbo.FACTIMPDET.AR_IMPMX),0), isnull(max(dbo.FACTIMPDET.AR_EXPFO),0), 
			                      0, dbo.FACTIMPDET.FID_SEC_IMP, isnull(dbo.FACTIMPDET.FID_DEF_TIP, 'G'), isnull(dbo.FACTIMPDET.FID_POR_DEF,-1), 
			                      MAX(isnull(dbo.FACTIMPDET.TI_CODIGO,10)), dbo.FACTIMPDET.PA_CODIGO, dbo.FACTIMPDET.SPI_CODIGO, dbo.MAESTRO.PA_PROCEDE, 
			                      max(dbo.FACTIMPDET.ME_GEN), MAX(dbo.FACTIMPDET.PR_CODIGO), isnull(dbo.FACTIMPDET.FID_ORD_COMP,0),
						'descargable'=case when FID_PADREKITINSERT='N' then (case when isnull(dbo.FACTIMPDET.CS_CODIGO,8)=2 then 'N' else 'S' end)
						else 'S' end, 'S', isnull(dbo.FACTIMPDET.CS_CODIGO,8), 0, 0, dbo.FACTIMPDET.FID_NOPARTEAUX, dbo.FACTIMPDET.FI_CODIGO, dbo.FACTIMPDET.PID_INDICEDLIGA 
			FROM         dbo.FACTIMP LEFT OUTER JOIN
			                      dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO LEFT OUTER JOIN
			                      dbo.MAESTRO ON dbo.FACTIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
				        dbo.ARANCEL ON dbo.FACTIMPDET.AR_IMPMX = dbo.ARANCEL.AR_CODIGO
			WHERE     (dbo.FACTIMP.PI_RECTIFICA = @picodigo) and (dbo.FACTIMPDET.MA_CODIGO is not null)
			GROUP BY dbo.FACTIMPDET.MA_CODIGO, dbo.FACTIMPDET.FID_NOPARTE, 
			                      dbo.FACTIMPDET.ME_CODIGO, dbo.FACTIMPDET.MA_GENERICO, 
					dbo.FACTIMPDET.FID_SEC_IMP, dbo.FACTIMPDET.FID_ORD_COMP, 
			                      dbo.FACTIMPDET.FID_DEF_TIP, dbo.FACTIMPDET.FID_POR_DEF, dbo.FACTIMPDET.PA_CODIGO, 
			                      dbo.FACTIMPDET.SPI_CODIGO, dbo.MAESTRO.PA_PROCEDE, 
			                      isnull(dbo.FACTIMPDET.CS_CODIGO,8), dbo.FACTIMPDET.FID_PADREKITINSERT,
				        dbo.FACTIMPDET.FID_NOPARTEAUX, dbo.FACTIMPDET.FI_CODIGO, dbo.ARANCEL.AR_FRACCION, dbo.FACTIMPDET.PID_INDICEDLIGA
			ORDER BY dbo.ARANCEL.AR_FRACCION, isnull(dbo.FACTIMPDET.FID_NOPARTE,''), MAX(dbo.FACTIMPDET.FID_NOMBRE)

			if exists (select * from factimpdet, factimp where factimp.pi_rectifica=@picodigo and factimpdet.cs_codigo=2 and factimpdet.FID_PADREKITINSERT='N'
			and factimp.fi_codigo=factimpdet.fi_codigo)
			-- si FID_PADREKITINSERT='N' significa que inserta el padre pero como no descargable, y los componentes como si descargables
		
			exec fillpedimpdetKit_rect @picodigo, @user
	
			exec fillpedimpemp_rect @picodigo, @user		--inserta en el detalle los empaques de la factura

		end
	end
	else
	begin
		if @ccp_tipo<>'RE'
		begin
			insert into TempPedImpDet(PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CANT, PID_CTOT_DLS, ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
					AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
					PA_PROCEDE, ME_GENERICO, PR_CODIGO, PID_ORD_COMP,
					PID_DESCARGABLE, PID_IMPRIMIR, CS_CODIGO, PID_COS_UNIVA, PID_COS_UNIMATGRA, PID_NOPARTEAUX)
			
			SELECT     @picodigo, ISNULL(dbo.FACTIMPDET.MA_CODIGO,0), isnull(dbo.FACTIMPDET.FID_NOPARTE,''), MAX(dbo.FACTIMPDET.FID_NOMBRE), MAX(dbo.FACTIMPDET.FID_NAME), 
			                      SUM(isnull(dbo.FACTIMPDET.FID_CANT_ST,0)), SUM(isnull(dbo.FACTIMPDET.FID_COS_TOT,0)), 
			                      dbo.FACTIMPDET.ME_CODIGO, isnull(dbo.FACTIMPDET.MA_GENERICO,0), 
			                      max(isnull(dbo.FACTIMPDET.EQ_GEN, 1)), max(isnull(dbo.FACTIMPDET.EQ_IMPMX, 1)), isnull(max(dbo.FACTIMPDET.AR_IMPMX),0), isnull(max(dbo.FACTIMPDET.AR_EXPFO),0), 
			                      0, dbo.FACTIMPDET.FID_SEC_IMP, isnull(dbo.FACTIMPDET.FID_DEF_TIP, 'G'), isnull(dbo.FACTIMPDET.FID_POR_DEF,-1), 
			                      MAX(isnull(dbo.FACTIMPDET.TI_CODIGO,10)), dbo.FACTIMPDET.PA_CODIGO, dbo.FACTIMPDET.SPI_CODIGO, dbo.MAESTRO.PA_PROCEDE, 
			                      max(dbo.FACTIMPDET.ME_GEN), MAX(dbo.FACTIMPDET.PR_CODIGO), isnull(dbo.FACTIMPDET.FID_ORD_COMP,0),
						'descargable'=case when FID_PADREKITINSERT='N' then (case when isnull(dbo.FACTIMPDET.CS_CODIGO,8)=2 then 'N' else 'S' end)
						else 'S' end, 'S', isnull(dbo.FACTIMPDET.CS_CODIGO,8), 0, 0, isnull(dbo.FACTIMPDET.FID_NOPARTEAUX,'')
			FROM         dbo.FACTIMP LEFT OUTER JOIN
			                      dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO LEFT OUTER JOIN
			                      dbo.MAESTRO ON dbo.FACTIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
				        dbo.ARANCEL ON dbo.FACTIMPDET.AR_IMPMX = dbo.ARANCEL.AR_CODIGO
			WHERE     (dbo.FACTIMP.PI_CODIGO = @picodigo) and (dbo.FACTIMPDET.MA_CODIGO is not null)
			GROUP BY dbo.FACTIMPDET.MA_CODIGO, dbo.FACTIMPDET.FID_NOPARTE, 
			                      dbo.FACTIMPDET.ME_CODIGO, dbo.FACTIMPDET.MA_GENERICO, 
				        dbo.FACTIMPDET.FID_SEC_IMP, dbo.FACTIMPDET.FID_ORD_COMP, 
			                      dbo.FACTIMPDET.FID_DEF_TIP, dbo.FACTIMPDET.FID_POR_DEF, dbo.FACTIMPDET.PA_CODIGO, 
			                      dbo.FACTIMPDET.SPI_CODIGO, dbo.MAESTRO.PA_PROCEDE, 
			                      isnull(dbo.FACTIMPDET.CS_CODIGO,8), dbo.FACTIMPDET.FID_PADREKITINSERT,
				        dbo.FACTIMPDET.FID_NOPARTEAUX, dbo.ARANCEL.AR_FRACCION
			ORDER BY dbo.ARANCEL.AR_FRACCION, isnull(dbo.FACTIMPDET.FID_NOPARTE,''), MAX(dbo.FACTIMPDET.FID_NOMBRE)

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
	
			insert into TempPedImpDet(PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CANT, PID_CTOT_DLS, ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
					AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
					PA_PROCEDE, ME_GENERICO, PR_CODIGO, PID_ORD_COMP,
					PID_DESCARGABLE, PID_IMPRIMIR, CS_CODIGO, PID_COS_UNIVA, PID_COS_UNIMATGRA, PID_NOPARTEAUX, PID_INDICEDORIG)
			
			SELECT     @picodigo, ISNULL(dbo.FACTIMPDET.MA_CODIGO,0), isnull(dbo.FACTIMPDET.FID_NOPARTE,''), MAX(dbo.FACTIMPDET.FID_NOMBRE), MAX(dbo.FACTIMPDET.FID_NAME), 
			                      SUM(isnull(dbo.FACTIMPDET.FID_CANT_ST,0)), SUM(isnull(dbo.FACTIMPDET.FID_COS_TOT,0)), 
			                      dbo.FACTIMPDET.ME_CODIGO, isnull(dbo.FACTIMPDET.MA_GENERICO,0), 
			                      max(isnull(dbo.FACTIMPDET.EQ_GEN, 1)), max(isnull(dbo.FACTIMPDET.EQ_IMPMX, 1)), isnull(max(dbo.FACTIMPDET.AR_IMPMX),0), isnull(max(dbo.FACTIMPDET.AR_EXPFO),0), 
			                      0, dbo.FACTIMPDET.FID_SEC_IMP, isnull(dbo.FACTIMPDET.FID_DEF_TIP, 'G'), isnull(dbo.FACTIMPDET.FID_POR_DEF,-1), 
			                      MAX(isnull(dbo.FACTIMPDET.TI_CODIGO,10)), dbo.FACTIMPDET.PA_CODIGO, dbo.FACTIMPDET.SPI_CODIGO, dbo.MAESTRO.PA_PROCEDE, 
			                      max(dbo.FACTIMPDET.ME_GEN), MAX(dbo.FACTIMPDET.PR_CODIGO), isnull(dbo.FACTIMPDET.FID_ORD_COMP,0),
						'descargable'=case when FID_PADREKITINSERT='N' then (case when isnull(dbo.FACTIMPDET.CS_CODIGO,8)=2 then 'N' else 'S' end)
						else 'S' end, 'S', isnull(dbo.FACTIMPDET.CS_CODIGO,8), 0, 0, dbo.FACTIMPDET.FID_NOPARTEAUX, dbo.FACTIMPDET.PID_INDICEDLIGA 
			FROM         dbo.FACTIMP LEFT OUTER JOIN
			                      dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO LEFT OUTER JOIN
			                      dbo.MAESTRO ON dbo.FACTIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
				        dbo.ARANCEL ON dbo.FACTIMPDET.AR_IMPMX = dbo.ARANCEL.AR_CODIGO
			WHERE     (dbo.FACTIMP.PI_RECTIFICA = @picodigo) and (dbo.FACTIMPDET.MA_CODIGO is not null)
			GROUP BY dbo.FACTIMPDET.MA_CODIGO, dbo.FACTIMPDET.FID_NOPARTE, 
			                      dbo.FACTIMPDET.ME_CODIGO, dbo.FACTIMPDET.MA_GENERICO, 
					dbo.FACTIMPDET.FID_SEC_IMP, dbo.FACTIMPDET.FID_ORD_COMP, 
			                      dbo.FACTIMPDET.FID_DEF_TIP, dbo.FACTIMPDET.FID_POR_DEF, dbo.FACTIMPDET.PA_CODIGO, 
			                      dbo.FACTIMPDET.SPI_CODIGO, dbo.MAESTRO.PA_PROCEDE, 
			                      isnull(dbo.FACTIMPDET.CS_CODIGO,8), dbo.FACTIMPDET.FID_PADREKITINSERT,
				        dbo.FACTIMPDET.FID_NOPARTEAUX, dbo.ARANCEL.AR_FRACCION, dbo.FACTIMPDET.PID_INDICEDLIGA 
			ORDER BY dbo.ARANCEL.AR_FRACCION, isnull(dbo.FACTIMPDET.FID_NOPARTE,''), MAX(dbo.FACTIMPDET.FID_NOMBRE)
	
			if exists (select * from factimpdet, factimp where factimp.pi_rectifica=@picodigo and factimpdet.cs_codigo=2 and factimpdet.FID_PADREKITINSERT='N'
			and factimp.fi_codigo=factimpdet.fi_codigo)
			-- si FID_PADREKITINSERT='N' significa que inserta el padre pero como no descargable, y los componentes como si descargables
		
			exec fillpedimpdetKit_rect @picodigo, @user
	
	
	--		IF (SELECT CF_EMPDESPIMP FROM CONFIGURACION)='S' /* si la empresa quiere llevar el control del empaque que importa como desperdicio */
			exec fillpedimpemp_rect @picodigo, @user		/*inserta en el detalle los empaques de la factura*/
	
		end
	end	

	update Temppedimpdet
	set ME_ARIMPMX=(select me_codigo from arancel where ar_codigo=Temppedimpdet.AR_IMPMX)

	update Temppedimpdet
	set EQ_GENERICO=1 
	where EQ_GENERICO is null or EQ_GENERICO=0


	update Temppedimpdet
	set PID_COS_UNI=round((PID_CTOT_DLS)/PID_CANT,6),
	PID_COS_UNIgen= round(((PID_CTOT_DLS)/PID_CANT)/ EQ_GENERICO,6),
	PID_COS_UNIADU= round(round(PID_CTOT_DLS * @PI_TIP_CAM * @pi_ft_adu,0)/isnull(PID_CANT,0),6)/EQ_GENERICO,
--	PID_COS_UNIADU= round(round(((PID_CTOT_DLS/PID_CANT) / isnull(EQ_GENERICO,1)),6) * @PI_TIP_CAM * @pi_ft_adu,6),
	PID_CAN_GEN = round(isnull(PID_CANT,0) * isnull(EQ_GENERICO,1),6),
	PID_CAN_AR =round(PID_CANT * EQ_IMPMX,6),
	PID_VAL_ADU= round(PID_CTOT_DLS * @PI_TIP_CAM * @pi_ft_adu,0)
	where PID_CANT >0 and PID_CTOT_DLS>0 and pi_codigo=@picodigo and pid_imprimir='S'


	update Temppedimpdet
	set PID_COS_UNI=round((PID_CTOT_DLS)/PID_CANT,6),
	PID_COS_UNIgen= round(((PID_CTOT_DLS)/PID_CANT)/ EQ_GENERICO,6),
	PID_COS_UNIADU= round(round(PID_CTOT_DLS * @PI_TIP_CAM,0)/isnull(PID_CANT,0),6)/EQ_GENERICO,
--	PID_COS_UNIADU= round(round(((PID_CTOT_DLS/PID_CANT) / isnull(EQ_GENERICO,1)),6) * @PI_TIP_CAM,6),
	PID_CAN_GEN = round(isnull(PID_CANT,0) * isnull(EQ_GENERICO,1),6),
	PID_CAN_AR =round(PID_CANT * EQ_IMPMX,6),
	PID_VAL_ADU= round(PID_CTOT_DLS * @PI_TIP_CAM,0)
	where PID_CANT >0 and PID_CTOT_DLS>0 and pi_codigo=@picodigo and pid_imprimir<>'S'


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
	set PID_COS_UNI=round(PID_CTOT_DLS,6),
	PID_COS_UNIgen= round((PID_CTOT_DLS)/ EQ_GENERICO,6),
--	PID_COS_UNIADU= round(((PID_CTOT_DLS) / EQ_GENERICO) * @PI_TIP_CAM * @pi_ft_adu,6),
	PID_COS_UNIADU= round(PID_CTOT_DLS * @PI_TIP_CAM * @pi_ft_adu,0)/EQ_GENERICO,
	PID_CAN_GEN = 0,
	PID_CAN_AR =0,
	PID_VAL_ADU= round(PID_CTOT_DLS* @PI_TIP_CAM * @pi_ft_adu,0)
	where PID_CANT =0 and PID_CTOT_DLS>0 and pi_codigo=@picodigo and pid_imprimir='S'

	update Temppedimpdet
	set PID_COS_UNI=round(PID_CTOT_DLS,6),
	PID_COS_UNIgen= round((PID_CTOT_DLS)/ EQ_GENERICO,6),
--	PID_COS_UNIADU= round(((PID_CTOT_DLS) / EQ_GENERICO) * @PI_TIP_CAM,6),
	PID_COS_UNIADU= round(PID_CTOT_DLS* @PI_TIP_CAM,0)/EQ_GENERICO,
	PID_CAN_GEN = 0,
	PID_CAN_AR =0,
	PID_VAL_ADU= round(PID_CTOT_DLS* @PI_TIP_CAM,0)
	where PID_CANT =0 and PID_CTOT_DLS>0 and pi_codigo=@picodigo and pid_imprimir<>'S'

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

if @ccp_tipo in ('IT', 'IV', 'OC', 'TR', 'VT', 'RG', 'IR', 'IB', 'RE', 'IA', 'IM', 'ED')
exec FillPIDescarga @picodigo, @user


	if @ccp_tipo='RE'
	begin
		-- cambia los pid_indiced del pedimento original a los nuevos para que el nuevo quede con los viejos y no tener que cambiar el kardesped
		UPDATE PEDIMPDET
		SET     PEDIMPDET.PID_INDICED= TempPedImpDet.PID_INDICED
		FROM         TempPedImpDet INNER JOIN
		                      PEDIMPDET ON TempPedImpDet.PID_INDICEDORIG = PEDIMPDET.PID_INDICED
		WHERE     (TempPedImpDet.PI_CODIGO = @picodigo)
		and TempPedImpDet.PID_INDICED is not null
	end
	

	INSERT INTO PEDIMPDET(PI_CODIGO, PID_INDICED, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_COS_UNI, PID_COS_UNIADU, PID_COS_UNIGEN, 
	                      PID_COS_UNIVA, PID_COS_UNIMATGRA, PID_CANT, PID_CAN_AR, PID_CAN_GEN, PID_VAL_ADU, PID_CTOT_DLS, PID_ORD_COMP,
	                      ME_CODIGO, ME_GENERICO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, AR_IMPMX, ME_ARIMPMX, AR_EXPFO, 
	                      PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, CS_CODIGO, TI_CODIGO, PA_ORIGEN, PA_PROCEDE,  SPI_CODIGO, PR_CODIGO, PID_IMPRIMIR, 
		         PID_DESCARGABLE, PID_PAGACONTRIB, PID_NOPARTEAUX, PID_CODIGOFACT, PID_SECUENCIA, PID_INDICEDORIG)
	
	SELECT     PI_CODIGO, PID_INDICED+@maximo, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_COS_UNI, PID_COS_UNIADU, PID_COS_UNIGEN, 
	                      PID_COS_UNIVA, PID_COS_UNIMATGRA, PID_CANT, PID_CAN_AR, PID_CAN_GEN, PID_VAL_ADU, PID_CTOT_DLS, PID_ORD_COMP,
	                      ME_CODIGO, ME_GENERICO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, AR_IMPMX, ME_ARIMPMX, AR_EXPFO, 
	                      PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, CS_CODIGO, TI_CODIGO, PA_ORIGEN, PA_PROCEDE, SPI_CODIGO, PR_CODIGO, PID_IMPRIMIR, 
		         PID_DESCARGABLE, PID_PAGACONTRIB, PID_NOPARTEAUX, PID_CODIGOFACT, PID_INDICED, isnull(PID_INDICEDORIG,0)
	FROM         TempPedImpDet
	where pi_codigo=@picodigo  
	ORDER BY pid_indiced


	if exists (select * from TempPedImpDet where PID_ORD_COMP is not null and PID_ORD_COMP<>'')
	EXEC SP_SECUENCIAPO @picodigo

select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

	insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
	values (@user, 2, 'Ligando detalle Pedimento - Detalle Factura ', 'Linking Pedimento Detail - Invoice Detail ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)

/* se hace la liga con detalles de facturas */
	if @ccp_tipo<>'RE'
	begin

		IF (SELECT PICF_SAAIDETDIVFACT FROM PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='S'
		begin
			UPDATE dbo.FACTIMPDET
			SET     dbo.FACTIMPDET.PID_INDICEDLIGA =dbo.PEDIMPDET.PID_INDICED
			FROM         dbo.FACTIMPDET INNER JOIN
	                      dbo.PEDIMPDET ON dbo.FACTIMPDET.MA_CODIGO = dbo.PEDIMPDET.MA_CODIGO 			AND dbo.FACTIMPDET.FID_NOPARTE = dbo.PEDIMPDET.PID_NOPARTE 
			AND  ISNULL(dbo.FACTIMPDET.ME_CODIGO, 0) = ISNULL(dbo.PEDIMPDET.ME_CODIGO, 0) 
			AND ISNULL(dbo.FACTIMPDET.MA_GENERICO, 0) = ISNULL(dbo.PEDIMPDET.MA_GENERICO, 0) 
			AND ISNULL(dbo.FACTIMPDET.FID_ORD_COMP, 0) = ISNULL(dbo.PEDIMPDET.PID_ORD_COMP, 0) 
			AND ISNULL(dbo.FACTIMPDET.AR_IMPMX, 0) = ISNULL(dbo.PEDIMPDET.AR_IMPMX, 0) 
	--		AND ISNULL(dbo.FACTIMPDET.AR_EXPFO, 0) = ISNULL(dbo.PEDIMPDET.AR_EXPFO, 0) 			
	    -- Correción Descargas 11-Nov-09 Manuel G.
	    AND ISNULL(dbo.FACTIMPDET.FID_RATEEXPFO, - 1) = ISNULL(dbo.PEDIMPDET.PID_RATEEXPFO, - 1) 
			AND ISNULL(dbo.FACTIMPDET.FID_SEC_IMP, 0) = ISNULL(dbo.PEDIMPDET.PID_SEC_IMP, 0) 
			AND ISNULL(dbo.FACTIMPDET.FID_DEF_TIP, 'G') = ISNULL(dbo.PEDIMPDET.PID_DEF_TIP, 'G') 
			AND ISNULL(dbo.FACTIMPDET.FID_POR_DEF, - 1) = ISNULL(dbo.PEDIMPDET.PID_POR_DEF, - 1) 
			AND ISNULL(dbo.FACTIMPDET.PA_CODIGO, 0) = ISNULL(dbo.PEDIMPDET.PA_ORIGEN, 0) 
			AND ISNULL(dbo.FACTIMPDET.SPI_CODIGO, 0) = ISNULL(dbo.PEDIMPDET.SPI_CODIGO, 0) 
			AND ISNULL(dbo.FACTIMPDET.CS_CODIGO, 8) = isnull(dbo.PEDIMPDET.CS_CODIGO ,8)			AND isnull(dbo.FACTIMPDET.FID_NOPARTEAUX,'')=isnull(dbo.PEDIMPDET.PID_NOPARTEAUX,'')
			AND isnull(dbo.PEDIMPDET.PID_CODIGOFACT, 0) = isnull(dbo.FACTIMPDET.FI_CODIGO, 0)
			INNER JOIN	                      dbo.FACTIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.FACTIMP.PI_CODIGO AND dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
			LEFT OUTER JOIN  dbo.ARANCEL ON dbo.FACTIMPDET.AR_IMPMX = dbo.ARANCEL.AR_CODIGO
			LEFT OUTER JOIN  dbo.ARANCEL ARANCEL_1 ON dbo.PEDIMPDET.AR_IMPMX = ARANCEL_1.AR_CODIGO			WHERE dbo.PEDIMPDET.PI_CODIGO=@picodigo
		end
		else
		begin
			UPDATE dbo.FACTIMPDET
			SET     dbo.FACTIMPDET.PID_INDICEDLIGA =dbo.PEDIMPDET.PID_INDICED
			FROM         dbo.FACTIMPDET INNER JOIN
	                      dbo.PEDIMPDET ON dbo.FACTIMPDET.MA_CODIGO = dbo.PEDIMPDET.MA_CODIGO 			AND dbo.FACTIMPDET.FID_NOPARTE = dbo.PEDIMPDET.PID_NOPARTE 
			AND  ISNULL(dbo.FACTIMPDET.ME_CODIGO, 0) = ISNULL(dbo.PEDIMPDET.ME_CODIGO, 0) 
			AND ISNULL(dbo.FACTIMPDET.MA_GENERICO, 0) = ISNULL(dbo.PEDIMPDET.MA_GENERICO, 0) 
			AND ISNULL(dbo.FACTIMPDET.FID_ORD_COMP, 0) = ISNULL(dbo.PEDIMPDET.PID_ORD_COMP, 0) 
			AND ISNULL(dbo.FACTIMPDET.AR_IMPMX, 0) = ISNULL(dbo.PEDIMPDET.AR_IMPMX, 0) 
	--		AND ISNULL(dbo.FACTIMPDET.AR_EXPFO, 0) = ISNULL(dbo.PEDIMPDET.AR_EXPFO, 0) 			
	-- Correción descargas 11-Nov-09 Manuel G.
	AND ISNULL(dbo.FACTIMPDET.FID_RATEEXPFO, - 1) = ISNULL(dbo.PEDIMPDET.PID_RATEEXPFO, - 1) 
			AND ISNULL(dbo.FACTIMPDET.FID_SEC_IMP, 0) = ISNULL(dbo.PEDIMPDET.PID_SEC_IMP, 0) 
			AND ISNULL(dbo.FACTIMPDET.FID_DEF_TIP, 'G') = ISNULL(dbo.PEDIMPDET.PID_DEF_TIP, 'G') 
			AND ISNULL(dbo.FACTIMPDET.FID_POR_DEF, - 1) = ISNULL(dbo.PEDIMPDET.PID_POR_DEF, - 1) 
			AND ISNULL(dbo.FACTIMPDET.PA_CODIGO, 0) = ISNULL(dbo.PEDIMPDET.PA_ORIGEN, 0) 
			AND ISNULL(dbo.FACTIMPDET.SPI_CODIGO, 0) = ISNULL(dbo.PEDIMPDET.SPI_CODIGO, 0) 
			AND ISNULL(dbo.FACTIMPDET.CS_CODIGO, 8) = isnull(dbo.PEDIMPDET.CS_CODIGO ,8)			
			AND isnull(dbo.FACTIMPDET.FID_NOPARTEAUX,'')=isnull(dbo.PEDIMPDET.PID_NOPARTEAUX,'')
			INNER JOIN	                      
			dbo.FACTIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.FACTIMP.PI_CODIGO AND dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
			LEFT OUTER JOIN  dbo.ARANCEL ON dbo.FACTIMPDET.AR_IMPMX = dbo.ARANCEL.AR_CODIGO
			LEFT OUTER JOIN  dbo.ARANCEL ARANCEL_1 ON dbo.PEDIMPDET.AR_IMPMX = ARANCEL_1.AR_CODIGO			
			WHERE dbo.PEDIMPDET.PI_CODIGO=@picodigo

		end
	end
	else	
	begin


		-- no se actualiza con el pid_indiced porque el que los que tiene el r1 son los pid_indiced viejos, por lo tanto se estaria repitiendo la informacion
		-- en PID_INDICEDLIGA y PID_INDICEDLIGAR1, lo que se tiene que hacer adicionalmente es intercambiarlos los que esta en PID_INDICEDLIGAR1 copiarlos a PID_INDICEDLIGA y viceversa
		IF (SELECT PICF_SAAIDETDIVFACT FROM PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='S'
		begin
			UPDATE dbo.FACTIMPDET
			SET     dbo.FACTIMPDET.PID_INDICEDLIGAR1 =dbo.PEDIMPDET.PID_INDICEDORIG
			FROM         dbo.FACTIMPDET INNER JOIN
	                      dbo.PEDIMPDET ON dbo.FACTIMPDET.MA_CODIGO = dbo.PEDIMPDET.MA_CODIGO 
			AND dbo.FACTIMPDET.FID_NOPARTE = dbo.PEDIMPDET.PID_NOPARTE 
			AND  ISNULL(dbo.FACTIMPDET.ME_CODIGO, 0) = ISNULL(dbo.PEDIMPDET.ME_CODIGO, 0) 
			AND ISNULL(dbo.FACTIMPDET.MA_GENERICO, 0) = ISNULL(dbo.PEDIMPDET.MA_GENERICO, 0) 
			AND ISNULL(dbo.FACTIMPDET.FID_ORD_COMP, 0) = ISNULL(dbo.PEDIMPDET.PID_ORD_COMP, 0) 
			AND ISNULL(dbo.FACTIMPDET.AR_IMPMX, 0) = ISNULL(dbo.PEDIMPDET.AR_IMPMX, 0) 
	--		AND ISNULL(dbo.FACTIMPDET.AR_EXPFO, 0) = ISNULL(dbo.PEDIMPDET.AR_EXPFO, 0) 
			AND ISNULL(dbo.FACTIMPDET.FID_RATEEXPFO, - 1) = ISNULL(dbo.PEDIMPDET.PID_RATEEXPFO, - 1) 
			AND ISNULL(dbo.FACTIMPDET.FID_SEC_IMP, 0) = ISNULL(dbo.PEDIMPDET.PID_SEC_IMP, 0) 
			AND ISNULL(dbo.FACTIMPDET.FID_DEF_TIP, 'G') = ISNULL(dbo.PEDIMPDET.PID_DEF_TIP, 'G') 
			AND ISNULL(dbo.FACTIMPDET.FID_POR_DEF, - 1) = ISNULL(dbo.PEDIMPDET.PID_POR_DEF, - 1) 			AND ISNULL(dbo.FACTIMPDET.PA_CODIGO, 0) = ISNULL(dbo.PEDIMPDET.PA_ORIGEN, 0) 
			AND ISNULL(dbo.FACTIMPDET.SPI_CODIGO, 0) = ISNULL(dbo.PEDIMPDET.SPI_CODIGO, 0) 
			AND ISNULL(dbo.FACTIMPDET.CS_CODIGO, 8) = isnull(dbo.PEDIMPDET.CS_CODIGO ,8)
			AND isnull(dbo.FACTIMPDET.FID_NOPARTEAUX,'')=isnull(dbo.PEDIMPDET.PID_NOPARTEAUX,'')
			AND isnull(dbo.PEDIMPDET.PID_CODIGOFACT, 0) = isnull(dbo.FACTIMPDET.FI_CODIGO, 0)
			INNER JOIN
	                      dbo.FACTIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.FACTIMP.PI_RECTIFICA AND dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
			LEFT OUTER JOIN  dbo.ARANCEL ON dbo.FACTIMPDET.AR_IMPMX = dbo.ARANCEL.AR_CODIGO
			LEFT OUTER JOIN  dbo.ARANCEL ARANCEL_1 ON dbo.PEDIMPDET.AR_IMPMX = ARANCEL_1.AR_CODIGO			WHERE dbo.PEDIMPDET.PI_CODIGO=@picodigo
		end
		else
		begin
			UPDATE dbo.FACTIMPDET
			SET     dbo.FACTIMPDET.PID_INDICEDLIGAR1 =dbo.PEDIMPDET.PID_INDICEDORIG
			FROM         dbo.FACTIMPDET INNER JOIN
	                      dbo.PEDIMPDET ON dbo.FACTIMPDET.MA_CODIGO = dbo.PEDIMPDET.MA_CODIGO 
			AND dbo.FACTIMPDET.FID_NOPARTE = dbo.PEDIMPDET.PID_NOPARTE 
			AND  ISNULL(dbo.FACTIMPDET.ME_CODIGO, 0) = ISNULL(dbo.PEDIMPDET.ME_CODIGO, 0) 
			AND ISNULL(dbo.FACTIMPDET.MA_GENERICO, 0) = ISNULL(dbo.PEDIMPDET.MA_GENERICO, 0) 
			AND ISNULL(dbo.FACTIMPDET.FID_ORD_COMP, 0) = ISNULL(dbo.PEDIMPDET.PID_ORD_COMP, 0) 
			AND ISNULL(dbo.FACTIMPDET.AR_IMPMX, 0) = ISNULL(dbo.PEDIMPDET.AR_IMPMX, 0) 
	--		AND ISNULL(dbo.FACTIMPDET.AR_EXPFO, 0) = ISNULL(dbo.PEDIMPDET.AR_EXPFO, 0) 
			AND ISNULL(dbo.FACTIMPDET.FID_RATEEXPFO, - 1) = ISNULL(dbo.PEDIMPDET.PID_RATEEXPFO, - 1) 
			AND ISNULL(dbo.FACTIMPDET.FID_SEC_IMP, 0) = ISNULL(dbo.PEDIMPDET.PID_SEC_IMP, 0) 
			AND ISNULL(dbo.FACTIMPDET.FID_DEF_TIP, 'G') = ISNULL(dbo.PEDIMPDET.PID_DEF_TIP, 'G') 
			AND ISNULL(dbo.FACTIMPDET.FID_POR_DEF, - 1) = ISNULL(dbo.PEDIMPDET.PID_POR_DEF, - 1) 			AND ISNULL(dbo.FACTIMPDET.PA_CODIGO, 0) = ISNULL(dbo.PEDIMPDET.PA_ORIGEN, 0) 
			AND ISNULL(dbo.FACTIMPDET.SPI_CODIGO, 0) = ISNULL(dbo.PEDIMPDET.SPI_CODIGO, 0) 
			AND ISNULL(dbo.FACTIMPDET.CS_CODIGO, 8) = isnull(dbo.PEDIMPDET.CS_CODIGO ,8)
			AND isnull(dbo.FACTIMPDET.FID_NOPARTEAUX,'')=isnull(dbo.PEDIMPDET.PID_NOPARTEAUX,'')
			INNER JOIN
	                      dbo.FACTIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.FACTIMP.PI_RECTIFICA AND dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
			LEFT OUTER JOIN  dbo.ARANCEL ON dbo.FACTIMPDET.AR_IMPMX = dbo.ARANCEL.AR_CODIGO
			LEFT OUTER JOIN  dbo.ARANCEL ARANCEL_1 ON dbo.PEDIMPDET.AR_IMPMX = ARANCEL_1.AR_CODIGO			WHERE dbo.PEDIMPDET.PI_CODIGO=@picodigo
		end

		EXEC SP_DROPTABLE 'RELFACTRECT'

		SELECT     FACTIMPDET.PID_INDICEDLIGA, FACTIMPDET.PID_INDICEDLIGAR1, FACTIMPDET.FID_INDICED
		INTO dbo.RELFACTRECT
		FROM         FACTIMPDET INNER JOIN
		                      FACTIMP ON FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
		WHERE     (FACTIMP.PI_RECTIFICA = @picodigo)

		UPDATE FACTIMPDET
		SET FACTIMPDET.PID_INDICEDLIGA=RELFACTRECT.PID_INDICEDLIGAR1,
		        FACTIMPDET.PID_INDICEDLIGAR1=RELFACTRECT.PID_INDICEDLIGA
		FROM FACTIMPDET INNER JOIN RELFACTRECT ON FACTIMPDET.FID_INDICED=RELFACTRECT.FID_INDICED


		if exists(select * from pedimp where pi_updaterect='N' and pi_codigo=@picodigo)
		begin
	
			select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)
			
			insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
			values (@user, 2, 'Actualizando saldos de Detalles R1 ', 'Updating R1 Detail Balances ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)
			
	
			/* cursor para actualizar saldos del redimento R1*/
			declare cur_actualizasaldorect cursor for
				SELECT dbo.KARDESPED.KAP_INDICED_PED, isnull(PIDESCARGA.PID_SALDOGEN,0), 
					isnull(round(dbo.PEDIMPDET.PID_CAN_GEN,0),0), isnull(round(SUM(dbo.KARDESPED.KAP_CANTDESC),0),0)
				FROM         dbo.KARDESPED INNER JOIN
			                      dbo.PEDIMPDET ON dbo.KARDESPED.KAP_INDICED_PED = dbo.PEDIMPDET.PID_INDICED
					LEFT OUTER JOIN PIDESCARGA ON dbo.PEDIMPDET.PID_INDICED=PIDESCARGA.PID_INDICED
				WHERE dbo.PEDIMPDET.PI_CODIGO=@picodigo
				GROUP BY PIDESCARGA.PID_SALDOGEN, dbo.PEDIMPDET.PID_CAN_GEN, dbo.KARDESPED.KAP_INDICED_PED
			open cur_actualizasaldorect
		
				fetch next from cur_actualizasaldorect into @kap_indiced_ped, @pid_saldogenr, @pid_can_genr, @Sumkap_CantDesc 
					WHILE (@@FETCH_STATUS = 0) 
				BEGIN
			
		
					if @Sumkap_CantDesc<>0 and (@pid_saldogenr <> (@pid_can_genr-@Sumkap_CantDesc))
					update pidescarga
					set pid_saldogen = isnull((@pid_can_genr-@Sumkap_CantDesc),0)
					Where pid_indiced =  @kap_indiced_ped
		
					
					fetch next from cur_actualizasaldorect into @kap_indiced_ped, @pid_saldogenr, @pid_can_genr, @Sumkap_CantDesc 
				END
				CLOSE cur_actualizasaldorect
				DEALLOCATE cur_actualizasaldorect
	
		end

	end



	exec ReemplazaDescargasR1 @picodigo, @user, @ccp_tipo



select @Pid_indiced= max(pid_indiced) from pedimpdet

	update consecutivo
	set cv_codigo =  isnull(@pid_indiced,0) + 1
	where cv_tipo = 'PID'


	ALTER TABLE PEDIMPDET ENABLE TRIGGER insert_pedimpdet
GO
