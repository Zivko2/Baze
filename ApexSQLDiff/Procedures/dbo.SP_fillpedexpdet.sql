SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_fillpedexpdet] (@picodigo int, @ccp_tipo varchar(5), @user int)   as

SET NOCOUNT ON 

declare @MA_CODIGO int, @PID_NOPARTE varchar(30), @PID_NOMBRE varchar(150), @PID_NAME varchar(150), @PID_COS_UNI decimal(38,6), 
@PID_CANT_ST decimal(38,6), @PID_COS_TOT decimal(38,6), @ME_CODIGO int, 
@MA_GENERICO int, @EQ_GEN decimal(28,14), @EQ_EXPMX decimal(28,14), @AR_IMPMX int, @AR_EXPFO int, @PID_RATEEXPFO decimal(38,6),  
@TI_CODIGO smallint, @PA_CODIGO int, @SPI_CODIGO smallint, @PA_PROCEDE int, 
@ME_GEN int, @ME_ARIMPMX int, @CONSECUTIVO INT, @PID_INDICED int, @PID_COS_UNIVA decimal(38,6), @me_arancel int, @es_orig_vend int, 
@es_dest_comp int, @PID_COS_UNIMATGRA decimal(38,6), @PID_CAN_GEN decimal(38,6), @SE_CODIGO smallint, @PID_DESTNAFTA char(1),
@CF_PEDEXPVAUSA char(1), @PI_TIP_CAM decimal(38,6), @maximo INT, @pi_ft_adu decimal(38,9), @FechaActual varchar(10), @hora varchar(15), @em_codigo int,
@PI_USA_TIP_CAMFACT CHAR(1), @PICF_SAAIDETDIVPO char(1)

	ALTER TABLE PEDIMPDET DISABLE TRIGGER insert_pedimpdet


select @CF_PEDEXPVAUSA=CF_PEDEXPVAUSA from configuracion

	select @em_codigo=em_codigo from intradeglobal.dbo.empresa where em_corto in
	(select replace(convert(sysname,db_name()),'intrade',''))

/*===================================*/

	select @PI_TIP_CAM=PI_TIP_CAM, @pi_ft_adu=pi_ft_adu, @PI_USA_TIP_CAMFACT=PI_USA_TIP_CAMFACT from pedimp where pi_codigo=@picodigo 



	TRUNCATE TABLE TempPedImpDet

	dbcc checkident (TempPedImpdet, reseed, 1) WITH NO_INFOMSGS

	SET @FechaActual = convert(varchar(10), getdate(),101)
	select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)
	
	insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
	values (@user, 2, 'Llenando tabla temporal de detalle ', 'Filling Temporary Detail Table ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)


	/*if (select CF_VAL_PED from configuracion) ='S' 
	update factexpdet
	set ar_expmx=(SELECT min(fe1.ar_expmx) from factexpdet fe1 inner join factexp fe2 on fe1.fe_codigo=fe2.fe_codigo where (fe2.pi_codigo=@picodigo or fe2.pi_rectifica=@picodigo) and fe1.ma_codigo=factexpdet.ma_codigo)
	where fe_codigo in (select fe_codigo from factexp where pi_codigo=@picodigo or pi_rectifica=@picodigo)
	and  isnull((SELECT min(fe1.ar_expmx) from factexpdet fe1 inner join factexp fe2 on fe1.fe_codigo=fe2.fe_codigo where (fe2.pi_codigo=@picodigo or fe2.pi_rectifica=@picodigo) and fe1.ma_codigo=factexpdet.ma_codigo),0)>0
	*/

	SELECT @PICF_SAAIDETDIVPO=PICF_SAAIDETDIVPO  FROM PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo



	IF (SELECT PICF_PEDIMPSECFACT FROM PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='S'--  la secuencia viene de la factura
	update PEDIMPSAAICONFIG
	set PICF_PEDIMPSINAGRUP='S', PICF_AGRUPASAAISEC='S'
	where  PI_CODIGO=@picodigo


	IF (SELECT PICF_PEDIMPSINAGRUP FROM PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='S'--  no se hace ninguna agrupacion
	begin
		if @CF_PEDEXPVAUSA='N'
		begin
			if @ccp_tipo<>'RE'
			begin
				INSERT INTO TempPedImpDet(PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CANT,  
					PID_CTOT_DLS,  ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
					AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
					PA_PROCEDE, ME_GENERICO, PID_COS_UNIVA, PID_COS_UNIMATGRA, SE_CODIGO, PID_REGIONFIN, PID_NOPARTEAUX, PID_CODIGOFACT, PID_ORD_COMP, PID_CTOT_MN,
					PID_CAN_GEN, PID_CAN_AR, PID_GENERA_EMPDET, PID_PES_UNIKG, PID_SECUENCIA, PID_SERVICIO)
	
				SELECT     @picodigo, VFillPedExpDet.MA_CODIGO, FED_NOPARTE, FED_NOMBRE, FED_NAME, FED_CANT, 
					         'PID_CTOT_DLS'=case when factexp.mo_codigo IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO <> 154 AND MONEDA.PA_CODIGO <> 233) then (FED_COS_TOT*FACTEXP.FE_TIPOCAMBIO)/@PI_TIP_CAM else FED_COS_TOT end,
				                      VFillPedExpDet.ME_CODIGO, VFillPedExpDet.MA_GENERICO, 
				                      1, 1,  ISNULL(VFillPedExpDet.AR_EXPMX, 0), ISNULL(VFillPedExpDet.AR_IMPFO, 0), 
				                      FED_RATEIMPFO, 0, FED_DEF_TIP, 
					         0, VFillPedExpDet.TI_CODIGO,  case when @ccp_tipo='CN' AND (select PI_DESP_EQUIPO from pedimp where pi_codigo=@picodigo)='S' then VFillPedExpDet.PA_CODIGO ELSE
						isnull(VPID_DESTNAFTA.PA_CODIGO,233) END, VFillPedExpDet.SPI_CODIGO, isnull(DIR_CLIENTE.PA_CODIGO,233), 
				                      isnull(VFillPedExpDet.ME_GENERICO, VFillPedExpDet.ME_CODIGO), 
					        'PID_COS_UNIVA'=case when @ccp_tipo='IR' or FED_CANT=0 then 0 else (case when @PI_USA_TIP_CAMFACT<>'S' and factexp.mo_codigo IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 233) then round(PID_COS_UNIVAUSD*FED_CANT*@PI_TIP_CAM/FED_CANT,6) else round(PID_COS_UNIVAUSD*FED_CANT*FACTEXP.FE_TIPOCAMBIO/FED_CANT,6)  end) end, 
					        'PID_COS_UNIMATGRA'= case when FED_CANT=0 then 0 else (case when factexp.mo_codigo IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO <> 154 AND MONEDA.PA_CODIGO <> 233) then
							 round(((FED_GRA_EMP + FED_GRA_ADD + FED_GRA_MP + (FED_NG_MP + FED_NG_ADD - (isnull(FED_NG_USA,0)+isnull(FED_NG_MX,0))))*FED_CANT/FED_CANT)/@PI_TIP_CAM,6) else 
							round((FED_GRA_EMP + FED_GRA_ADD + FED_GRA_MP + (FED_NG_MP + FED_NG_ADD - (isnull(FED_NG_USA,0)+isnull(FED_NG_MX,0))))*FED_CANT/FED_CANT,6) end) end,
	
				                      VFillPedExpDet.SE_CODIGO, VPID_DESTNAFTA.PID_DESTNAFTA, isnull(FED_NOPARTEAUX,''), VFillPedExpDet.FED_INDICED, CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(VFillPedExpDet.FED_ORD_COMP,'') else '' end,
						'PID_CTOT_MN'=case when factexp.mo_codigo IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154) then isnull(VFillPedExpDet.FED_COS_TOT,0) else (case when @PI_USA_TIP_CAMFACT<>'S' and factexp.mo_codigo IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 233) then round(FED_COS_TOT*@PI_TIP_CAM,6) else round(FED_COS_TOT*FACTEXP.FE_TIPOCAMBIO,6) end) end,
						 round(isnull(VFillPedExpDet.FED_CANT,0)*isnull(VFillPedExpDet.EQ_GEN,1),6),
						'PID_CAN_AR'=case when isnull(VFillPedExpDet.FED_CANT,0)=0 and VFillPedExpDet.ME_AREXPMX in (select ME_KILOGRAMOS from configuracion) then isnull(VFillPedExpDet.FED_PES_NET,0) 
									else round(isnull(VFillPedExpDet.FED_CANT,0)*isnull(VFillPedExpDet.EQ_EXPMX,1),6) end,
						FED_GENERA_EMPDET, VFillPedExpDet.PID_PES_UNIKG, isnull(VFillPedExpDet.FED_PIDSECUENCIA,0), isnull(VFillPedExpDet.MA_SERVICIO,'N')
				FROM         DIR_CLIENTE RIGHT OUTER JOIN
				                      FACTEXP ON DIR_CLIENTE.DI_INDICE = FACTEXP.DI_DESTINI LEFT OUTER JOIN
				                      VPID_DESTNAFTA RIGHT OUTER JOIN
				                      VFillPedExpDet ON VPID_DESTNAFTA.FED_INDICED = VFillPedExpDet.FED_INDICED ON 
				                      FACTEXP.FE_CODIGO = VFillPedExpDet.FE_CODIGO LEFT OUTER JOIN
				                      MAESTRO ON VFillPedExpDet.MA_CODIGO = MAESTRO.MA_CODIGO
				WHERE     (FACTEXP.PI_CODIGO = @picodigo or (FACTEXP.PI_CODIGO = @picodigo and
					VFillPedExpDet.FED_INDICED IN
					(SELECT     FACTEXPDET.FED_INDICED
					FROM         PEDIMPRELTRANS INNER JOIN
					                      PEDIMPDET ON PEDIMPRELTRANS.PID_INDICED = PEDIMPDET.PID_INDICED INNER JOIN
					                      FACTEXPDET ON PEDIMPRELTRANS.FED_INDICED = FACTEXPDET.FED_INDICED
					WHERE     PEDIMPDET.PID_REGIONFIN <> 'M' GROUP BY FACTEXPDET.FED_INDICED)))
				AND (VFillPedExpDet.MA_CODIGO IS NOT NULL)
				ORDER BY FACTEXP.FE_CODIGO, VFillPedExpDet.FED_INDICED
			end
			else
			begin
	
				INSERT INTO TempPedImpDet(PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CANT,  
					PID_CTOT_DLS,  ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
					AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
					PA_PROCEDE, ME_GENERICO, PID_COS_UNIVA, PID_COS_UNIMATGRA, SE_CODIGO, PID_REGIONFIN, PID_NOPARTEAUX, PID_CODIGOFACT, PID_ORD_COMP, PID_CTOT_MN,
					PID_CAN_GEN, PID_CAN_AR, PID_GENERA_EMPDET, PID_PES_UNIKG, PID_SERVICIO)
				SELECT     @picodigo, VFillPedExpDet.MA_CODIGO, FED_NOPARTE, FED_NOMBRE, FED_NAME, 
						      FED_CANT, 
					         'PID_CTOT_DLS'=case when factexp.mo_codigo IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO <> 154 AND MONEDA.PA_CODIGO <> 233) then (FED_COS_TOT*FACTEXP.FE_TIPOCAMBIO)/@PI_TIP_CAM else FED_COS_TOT end,
				                      VFillPedExpDet.ME_CODIGO, VFillPedExpDet.MA_GENERICO, 
				                      1, 1,  ISNULL(VFillPedExpDet.AR_EXPMX, 0), ISNULL(VFillPedExpDet.AR_IMPFO, 0), 
				                      FED_RATEIMPFO, 0, FED_DEF_TIP, 
					         0, VFillPedExpDet.TI_CODIGO,  case when @ccp_tipo='CN' AND (select PI_DESP_EQUIPO from pedimp where pi_codigo=@picodigo)='S' then VFillPedExpDet.PA_CODIGO ELSE
						isnull(VPID_DESTNAFTA.PA_CODIGO,233) END, VFillPedExpDet.SPI_CODIGO, isnull(DIR_CLIENTE.PA_CODIGO,233), 
				                      isnull(VFillPedExpDet.ME_GENERICO, VFillPedExpDet.ME_CODIGO), 
					        'PID_COS_UNIVA'=case when @ccp_tipo='IR' or FED_CANT=0 then 0 else (case when @PI_USA_TIP_CAMFACT<>'S' and factexp.mo_codigo IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 233) then round(PID_COS_UNIVAUSD*FED_CANT*@PI_TIP_CAM/FED_CANT,6) else round(PID_COS_UNIVAUSD*FED_CANT*FACTEXP.FE_TIPOCAMBIO/FED_CANT,6)  end) end, 
					        'PID_COS_UNIMATGRA'= case when FED_CANT=0 then 0 else (case when factexp.mo_codigo IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO <> 154 AND MONEDA.PA_CODIGO <> 233) then 
						 round(((FED_GRA_EMP + FED_GRA_ADD + FED_GRA_MP + (FED_NG_MP + FED_NG_ADD - (isnull(FED_NG_USA,0)+isnull(FED_NG_MX,0))))*FED_CANT/FED_CANT)/@PI_TIP_CAM,6) else 
						round((FED_GRA_EMP + FED_GRA_ADD + FED_GRA_MP + (FED_NG_MP + FED_NG_ADD - (isnull(FED_NG_USA,0)+isnull(FED_NG_MX,0))))*FED_CANT/FED_CANT,6) end) end,
				                      VFillPedExpDet.SE_CODIGO, VPID_DESTNAFTA.PID_DESTNAFTA, isnull(FED_NOPARTEAUX,''), VFillPedExpDet.FED_INDICED, CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(VFillPedExpDet.FED_ORD_COMP,'') else '' end,
						'PID_CTOT_MN'=case when factexp.mo_codigo IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154) then isnull(VFillPedExpDet.FED_COS_TOT,0) else (case when @PI_USA_TIP_CAMFACT<>'S' and factexp.mo_codigo IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 233) then round(FED_COS_TOT*@PI_TIP_CAM,6) else round(FED_COS_TOT*FACTEXP.FE_TIPOCAMBIO,6) end) end,
						 round(isnull(VFillPedExpDet.FED_CANT,0)*isnull(VFillPedExpDet.EQ_GEN,1),6),
	 					'PID_CAN_AR'=case when isnull(VFillPedExpDet.FED_CANT,0)=0 and VFillPedExpDet.ME_AREXPMX in (select ME_KILOGRAMOS from configuracion) then isnull(VFillPedExpDet.FED_PES_NET,0) 
						else round(isnull(VFillPedExpDet.FED_CANT,0)*isnull(VFillPedExpDet.EQ_EXPMX,1),6) end, FED_GENERA_EMPDET, VFillPedExpDet.PID_PES_UNIKG, isnull(VFillPedExpDet.MA_SERVICIO,'N')
				FROM         DIR_CLIENTE RIGHT OUTER JOIN
				                      FACTEXP ON DIR_CLIENTE.DI_INDICE = FACTEXP.DI_DESTINI LEFT OUTER JOIN
				                      VPID_DESTNAFTA RIGHT OUTER JOIN
				                      VFillPedExpDet ON VPID_DESTNAFTA.FED_INDICED = VFillPedExpDet.FED_INDICED ON 
				                      FACTEXP.FE_CODIGO = VFillPedExpDet.FE_CODIGO LEFT OUTER JOIN
				                      MAESTRO ON VFillPedExpDet.MA_CODIGO = MAESTRO.MA_CODIGO
				WHERE     (FACTEXP.PI_RECTIFICA = @picodigo or (FACTEXP.PI_RECTIFICA = @picodigo and
					VFillPedExpDet.FED_INDICED IN
					(SELECT     FACTEXPDET.FED_INDICED
					FROM         PEDIMPRELTRANS INNER JOIN
					                      PEDIMPDET ON PEDIMPRELTRANS.PID_INDICED = PEDIMPDET.PID_INDICED INNER JOIN
					                      FACTEXPDET ON PEDIMPRELTRANS.FED_INDICED = FACTEXPDET.FED_INDICED
					WHERE     PEDIMPDET.PID_REGIONFIN <> 'M' GROUP BY FACTEXPDET.FED_INDICED)))
				AND (VFillPedExpDet.MA_CODIGO IS NOT NULL)
				ORDER BY FACTEXP.FE_CODIGO, VFillPedExpDet.FED_INDICED
	
		
	
			end
		end
		else
		begin
			if @ccp_tipo<>'RE'
			begin
				INSERT INTO TempPedImpDet(PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CANT,  
					PID_CTOT_DLS,  ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
					AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
					PA_PROCEDE, ME_GENERICO, PID_COS_UNIVA, PID_COS_UNIMATGRA, SE_CODIGO, PID_REGIONFIN, PID_NOPARTEAUX, PID_CODIGOFACT, PID_ORD_COMP, PID_CTOT_MN,
					PID_CAN_GEN, PID_CAN_AR, PID_GENERA_EMPDET, PID_PES_UNIKG, PID_SECUENCIA, PID_SERVICIO)
	
				SELECT     @picodigo, VFillPedExpDet.MA_CODIGO, FED_NOPARTE, FED_NOMBRE, FED_NAME, FED_CANT, 
					         'PID_CTOT_DLS'=case when factexp.mo_codigo IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO <> 154 AND MONEDA.PA_CODIGO <> 233) then (FED_COS_TOT*FACTEXP.FE_TIPOCAMBIO)/@PI_TIP_CAM else FED_COS_TOT end,
				                      VFillPedExpDet.ME_CODIGO, VFillPedExpDet.MA_GENERICO, 
				                      1, 1,  ISNULL(VFillPedExpDet.AR_EXPMX, 0), ISNULL(VFillPedExpDet.AR_IMPFO, 0), 
				                      FED_RATEIMPFO, 0, FED_DEF_TIP, 
					         0, VFillPedExpDet.TI_CODIGO,  case when @ccp_tipo='CN' AND (select PI_DESP_EQUIPO from pedimp where pi_codigo=@picodigo)='S' then VFillPedExpDet.PA_CODIGO ELSE
						isnull(VPID_DESTNAFTA.PA_CODIGO,233) END, VFillPedExpDet.SPI_CODIGO, isnull(DIR_CLIENTE.PA_CODIGO,233), 
				                      isnull(VFillPedExpDet.ME_GENERICO, VFillPedExpDet.ME_CODIGO), 
					        'PID_COS_UNIVA'=case when @ccp_tipo='IR' or FED_CANT=0 then 0 else (case when @PI_USA_TIP_CAMFACT<>'S' and factexp.mo_codigo IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 233) then round(PID_COS_UNIVAUSDGI*FED_CANT*@PI_TIP_CAM/FED_CANT,6) else round(PID_COS_UNIVAUSDGI*FED_CANT*FACTEXP.FE_TIPOCAMBIO/FED_CANT,6)  end) end, 
					        'PID_COS_UNIMATGRA'= case when FED_CANT=0 then 0 else (case when factexp.mo_codigo IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO <> 154 AND MONEDA.PA_CODIGO <> 233) then
							 round(((FED_GRA_EMP + FED_GRA_ADD + FED_GRA_MP + (FED_NG_MP + FED_NG_ADD - (isnull(FED_NG_USA,0)+isnull(FED_NG_MX,0))))*FED_CANT/FED_CANT)/@PI_TIP_CAM,6) else 
							round((FED_GRA_EMP + FED_GRA_ADD + FED_GRA_MP + (FED_NG_MP + FED_NG_ADD - (isnull(FED_NG_USA,0)+isnull(FED_NG_MX,0))))*FED_CANT/FED_CANT,6) end) end,
	
				                      VFillPedExpDet.SE_CODIGO, VPID_DESTNAFTA.PID_DESTNAFTA, isnull(FED_NOPARTEAUX,''), VFillPedExpDet.FED_INDICED, CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(VFillPedExpDet.FED_ORD_COMP,'') else '' end,
						'PID_CTOT_MN'=case when factexp.mo_codigo IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154) then isnull(VFillPedExpDet.FED_COS_TOT,0) else (case when @PI_USA_TIP_CAMFACT<>'S' and factexp.mo_codigo IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 233) then round(FED_COS_TOT*@PI_TIP_CAM,6) else round(FED_COS_TOT*FACTEXP.FE_TIPOCAMBIO,6) end) end,
						 round(isnull(VFillPedExpDet.FED_CANT,0)*isnull(VFillPedExpDet.EQ_GEN,1),6),
						'PID_CAN_AR'=case when isnull(VFillPedExpDet.FED_CANT,0)=0 and VFillPedExpDet.ME_AREXPMX in (select ME_KILOGRAMOS from configuracion) then isnull(VFillPedExpDet.FED_PES_NET,0) 
									else round(isnull(VFillPedExpDet.FED_CANT,0)*isnull(VFillPedExpDet.EQ_EXPMX,1),6) end,
						FED_GENERA_EMPDET, VFillPedExpDet.PID_PES_UNIKG, isnull(VFillPedExpDet.FED_PIDSECUENCIA,0), isnull(VFillPedExpDet.MA_SERVICIO,'N')
				FROM         DIR_CLIENTE RIGHT OUTER JOIN
				                      FACTEXP ON DIR_CLIENTE.DI_INDICE = FACTEXP.DI_DESTINI LEFT OUTER JOIN
				                      VPID_DESTNAFTA RIGHT OUTER JOIN
				                      VFillPedExpDet ON VPID_DESTNAFTA.FED_INDICED = VFillPedExpDet.FED_INDICED ON 
				                      FACTEXP.FE_CODIGO = VFillPedExpDet.FE_CODIGO LEFT OUTER JOIN
				                      MAESTRO ON VFillPedExpDet.MA_CODIGO = MAESTRO.MA_CODIGO
				WHERE     (FACTEXP.PI_CODIGO = @picodigo or (FACTEXP.PI_CODIGO = @picodigo and
					VFillPedExpDet.FED_INDICED IN
					(SELECT     FACTEXPDET.FED_INDICED
					FROM         PEDIMPRELTRANS INNER JOIN
					                      PEDIMPDET ON PEDIMPRELTRANS.PID_INDICED = PEDIMPDET.PID_INDICED INNER JOIN
					                      FACTEXPDET ON PEDIMPRELTRANS.FED_INDICED = FACTEXPDET.FED_INDICED
					WHERE     PEDIMPDET.PID_REGIONFIN <> 'M' GROUP BY FACTEXPDET.FED_INDICED)))
				AND (VFillPedExpDet.MA_CODIGO IS NOT NULL)
				ORDER BY FACTEXP.FE_CODIGO, VFillPedExpDet.FED_INDICED
			end
			else
			begin
	
				INSERT INTO TempPedImpDet(PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CANT,  
					PID_CTOT_DLS,  ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
					AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
					PA_PROCEDE, ME_GENERICO, PID_COS_UNIVA, PID_COS_UNIMATGRA, SE_CODIGO, PID_REGIONFIN, PID_NOPARTEAUX, PID_CODIGOFACT, PID_ORD_COMP, PID_CTOT_MN,
					PID_CAN_GEN, PID_CAN_AR, PID_GENERA_EMPDET, PID_PES_UNIKG, PID_SERVICIO)
				SELECT     @picodigo, VFillPedExpDet.MA_CODIGO, FED_NOPARTE, FED_NOMBRE, FED_NAME, 
						      FED_CANT, 
					         'PID_CTOT_DLS'=case when factexp.mo_codigo IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO <> 154 AND MONEDA.PA_CODIGO <> 233) then (FED_COS_TOT*FACTEXP.FE_TIPOCAMBIO)/@PI_TIP_CAM else FED_COS_TOT end,
				                      VFillPedExpDet.ME_CODIGO, VFillPedExpDet.MA_GENERICO, 
				                      1, 1,  ISNULL(VFillPedExpDet.AR_EXPMX, 0), ISNULL(VFillPedExpDet.AR_IMPFO, 0), 
				                      FED_RATEIMPFO, 0, FED_DEF_TIP, 
					         0, VFillPedExpDet.TI_CODIGO,  case when @ccp_tipo='CN' AND (select PI_DESP_EQUIPO from pedimp where pi_codigo=@picodigo)='S' then VFillPedExpDet.PA_CODIGO ELSE
						isnull(VPID_DESTNAFTA.PA_CODIGO,233) END, VFillPedExpDet.SPI_CODIGO, isnull(DIR_CLIENTE.PA_CODIGO,233), 
				                      isnull(VFillPedExpDet.ME_GENERICO, VFillPedExpDet.ME_CODIGO), 
					        'PID_COS_UNIVA'=case when @ccp_tipo='IR' or FED_CANT=0 then 0 else (case when @PI_USA_TIP_CAMFACT<>'S' and factexp.mo_codigo IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 233) then round(PID_COS_UNIVAUSDGI*FED_CANT*@PI_TIP_CAM/FED_CANT,6) else round(PID_COS_UNIVAUSDGI*FED_CANT*FACTEXP.FE_TIPOCAMBIO/FED_CANT,6)  end) end, 
					        'PID_COS_UNIMATGRA'= case when FED_CANT=0 then 0 else (case when factexp.mo_codigo IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO <> 154 AND MONEDA.PA_CODIGO <> 233) then 
						 round(((FED_GRA_EMP + FED_GRA_ADD + FED_GRA_MP + (FED_NG_MP + FED_NG_ADD - (isnull(FED_NG_USA,0)+isnull(FED_NG_MX,0))))*FED_CANT/FED_CANT)/@PI_TIP_CAM,6) else 
						round((FED_GRA_EMP + FED_GRA_ADD + FED_GRA_MP + (FED_NG_MP + FED_NG_ADD - (isnull(FED_NG_USA,0)+isnull(FED_NG_MX,0))))*FED_CANT/FED_CANT,6) end) end,
				                      VFillPedExpDet.SE_CODIGO, VPID_DESTNAFTA.PID_DESTNAFTA, isnull(FED_NOPARTEAUX,''), VFillPedExpDet.FED_INDICED, CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(VFillPedExpDet.FED_ORD_COMP,'') else '' end,
						'PID_CTOT_MN'=case when factexp.mo_codigo IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154) then isnull(VFillPedExpDet.FED_COS_TOT,0) else (case when @PI_USA_TIP_CAMFACT<>'S' and factexp.mo_codigo IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 233) then round(FED_COS_TOT*@PI_TIP_CAM,6) else round(FED_COS_TOT*FACTEXP.FE_TIPOCAMBIO,6) end) end,
						 round(isnull(VFillPedExpDet.FED_CANT,0)*isnull(VFillPedExpDet.EQ_GEN,1),6),
	 					'PID_CAN_AR'=case when isnull(VFillPedExpDet.FED_CANT,0)=0 and VFillPedExpDet.ME_AREXPMX in (select ME_KILOGRAMOS from configuracion) then isnull(VFillPedExpDet.FED_PES_NET,0) 
						else round(isnull(VFillPedExpDet.FED_CANT,0)*isnull(VFillPedExpDet.EQ_EXPMX,1),6) end, FED_GENERA_EMPDET, VFillPedExpDet.PID_PES_UNIKG, isnull(VFillPedExpDet.MA_SERVICIO,'N')
				FROM         DIR_CLIENTE RIGHT OUTER JOIN
				                      FACTEXP ON DIR_CLIENTE.DI_INDICE = FACTEXP.DI_DESTINI LEFT OUTER JOIN
				                      VPID_DESTNAFTA RIGHT OUTER JOIN
				                      VFillPedExpDet ON VPID_DESTNAFTA.FED_INDICED = VFillPedExpDet.FED_INDICED ON 
				                      FACTEXP.FE_CODIGO = VFillPedExpDet.FE_CODIGO LEFT OUTER JOIN
				                      MAESTRO ON VFillPedExpDet.MA_CODIGO = MAESTRO.MA_CODIGO
				WHERE     (FACTEXP.PI_RECTIFICA = @picodigo or (FACTEXP.PI_RECTIFICA = @picodigo and
					VFillPedExpDet.FED_INDICED IN
					(SELECT     FACTEXPDET.FED_INDICED
					FROM         PEDIMPRELTRANS INNER JOIN
					                      PEDIMPDET ON PEDIMPRELTRANS.PID_INDICED = PEDIMPDET.PID_INDICED INNER JOIN
					                      FACTEXPDET ON PEDIMPRELTRANS.FED_INDICED = FACTEXPDET.FED_INDICED
					WHERE     PEDIMPDET.PID_REGIONFIN <> 'M' GROUP BY FACTEXPDET.FED_INDICED)))
				AND (VFillPedExpDet.MA_CODIGO IS NOT NULL)
				ORDER BY FACTEXP.FE_CODIGO, VFillPedExpDet.FED_INDICED
	
		
	
			end
		end

	end
	else
	begin

		IF (SELECT PICF_SAAIDETDIVFACT FROM PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='S'
		begin
	
			if @CF_PEDEXPVAUSA='N'
			-- en esta opcion no considera los gastos indirectos usa en el valor agregado, y en el costo total se le resta el empaque no gravable y los gatsos indirectos usa
			begin
			
				-- en el pedimento de exportacion el campo PID_DEF_TIP es para saber si es normal o desperdicio
	
				--el FED_NG_MX no se incluye en el PID_COS_UNIMATGRA porque ya esta incluido en el Valor Agregado 
				
				if @ccp_tipo<>'RE'
				begin
					INSERT INTO TempPedImpDet(PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CANT,  
						PID_CTOT_DLS,  ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
						AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
						PA_PROCEDE, ME_GENERICO, PID_COS_UNIVA, PID_COS_UNIMATGRA, SE_CODIGO, PID_REGIONFIN, PID_NOPARTEAUX, PID_CODIGOFACT, PID_ORD_COMP, PID_CTOT_MN,
						PID_CAN_GEN, PID_CAN_AR, PID_GENERA_EMPDET, PID_PES_UNIKG, PID_SERVICIO)
	
					SELECT     @picodigo, VFillPedExpDet.MA_CODIGO, FED_NOPARTE, MAX(FED_NOMBRE), MAX(FED_NAME), 
	  					      SUM(FED_CANT), 
						         'PID_CTOT_DLS'=case when max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO <> 154 AND MONEDA.PA_CODIGO <> 233) then (SUM(FED_COS_TOT)*max(FACTEXP.FE_TIPOCAMBIO))/@PI_TIP_CAM else SUM(FED_COS_TOT) end,
					                      VFillPedExpDet.ME_CODIGO, VFillPedExpDet.MA_GENERICO, 
					                      1, 1,  ISNULL(max(VFillPedExpDet.AR_EXPMX), 0), ISNULL(max(VFillPedExpDet.AR_IMPFO), 0), 
					                      FED_RATEIMPFO, 0, FED_DEF_TIP, 
						         0, max(VFillPedExpDet.TI_CODIGO), case when @ccp_tipo='CN' AND (select PI_DESP_EQUIPO from pedimp where pi_codigo=@picodigo)='S' then VFillPedExpDet.PA_CODIGO ELSE
							isnull(VPID_DESTNAFTA.PA_CODIGO,233) END, VFillPedExpDet.SPI_CODIGO, isnull(DIR_CLIENTE.PA_CODIGO,233), 
					                      isnull(max(VFillPedExpDet.ME_GENERICO), VFillPedExpDet.ME_CODIGO), 
						        'PID_COS_UNIVA'=case when @ccp_tipo='IR' or sum(FED_CANT)=0 then 0 else (case when @PI_USA_TIP_CAMFACT<>'S' and max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 233) then round(sum(PID_COS_UNIVAUSD*FED_CANT)*@PI_TIP_CAM/sum(FED_CANT),6) else round(sum(PID_COS_UNIVAUSD*FED_CANT)*max(FACTEXP.FE_TIPOCAMBIO)/sum(FED_CANT),6)  end) end, 
						        'PID_COS_UNIMATGRA'= case when sum(FED_CANT)=0 then 0 else (case when max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO <> 154 AND MONEDA.PA_CODIGO <> 233) then
							 round((sum((FED_GRA_EMP + FED_GRA_ADD + FED_GRA_MP + (FED_NG_MP + FED_NG_ADD - (isnull(FED_NG_USA,0)+isnull(FED_NG_MX,0))))*FED_CANT)/sum(FED_CANT))/@PI_TIP_CAM,6) else 
							round(sum((FED_GRA_EMP + FED_GRA_ADD + FED_GRA_MP + (FED_NG_MP + FED_NG_ADD - (isnull(FED_NG_USA,0)+isnull(FED_NG_MX,0))))*FED_CANT)/sum(FED_CANT),6) end)end,
					                      VFillPedExpDet.SE_CODIGO, VPID_DESTNAFTA.PID_DESTNAFTA, max(isnull(FED_NOPARTEAUX,'')), VFillPedExpDet.FE_CODIGO, CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(FED_ORD_COMP,'') else '' end,
							'PID_CTOT_MN'=case when max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154) then SUM(isnull(VFillPedExpDet.FED_COS_TOT,0)) else (case when @PI_USA_TIP_CAMFACT<>'S' and max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 233) then round(SUM(FED_COS_TOT)*@PI_TIP_CAM,6) else round(SUM(FED_COS_TOT)*max(FACTEXP.FE_TIPOCAMBIO),6) end) end,
							 round(SUM(isnull(VFillPedExpDet.FED_CANT,0)*isnull(VFillPedExpDet.EQ_GEN,1)),6),						  
							'PID_CAN_AR'=case when SUM(isnull(VFillPedExpDet.FED_CANT,0))=0 and MAX(VFillPedExpDet.ME_AREXPMX) in (select ME_KILOGRAMOS from configuracion) then round(SUM(isnull(VFillPedExpDet.FED_PES_NET,0)),6) 
								else round(SUM(isnull(VFillPedExpDet.FED_CANT,0)*isnull(VFillPedExpDet.EQ_EXPMX,1)),6) end,
							MAX(FED_GENERA_EMPDET),max(VFillPedExpDet.PID_PES_UNIKG), isnull(VFillPedExpDet.MA_SERVICIO,'N')
					FROM         DIR_CLIENTE RIGHT OUTER JOIN
					                      FACTEXP ON DIR_CLIENTE.DI_INDICE = FACTEXP.DI_DESTINI LEFT OUTER JOIN
					                      VPID_DESTNAFTA RIGHT OUTER JOIN
					                      VFillPedExpDet ON VPID_DESTNAFTA.FED_INDICED = VFillPedExpDet.FED_INDICED ON 
					                      FACTEXP.FE_CODIGO = VFillPedExpDet.FE_CODIGO LEFT OUTER JOIN
					                      MAESTRO ON VFillPedExpDet.MA_CODIGO = MAESTRO.MA_CODIGO
					WHERE     (FACTEXP.PI_CODIGO = @picodigo or (FACTEXP.PI_CODIGO = @picodigo and
						VFillPedExpDet.FED_INDICED IN
						(SELECT     FACTEXPDET.FED_INDICED
						FROM         PEDIMPRELTRANS INNER JOIN
						                      PEDIMPDET ON PEDIMPRELTRANS.PID_INDICED = PEDIMPDET.PID_INDICED INNER JOIN
						                      FACTEXPDET ON PEDIMPRELTRANS.FED_INDICED = FACTEXPDET.FED_INDICED
						WHERE     PEDIMPDET.PID_REGIONFIN <> 'M' GROUP BY FACTEXPDET.FED_INDICED)))
					AND (VFillPedExpDet.MA_CODIGO IS NOT NULL)
					GROUP BY VPID_DESTNAFTA.PA_CODIGO, VFillPedExpDet.MA_CODIGO, FED_NOPARTE,
					                      VFillPedExpDet.ME_CODIGO, VFillPedExpDet.MA_GENERICO, VFillPedExpDet.PA_CODIGO,
					                      FED_RATEIMPFO, FED_DEF_TIP/*, VFillPedExpDet.PID_PES_UNIKG*/,
					                      VFillPedExpDet.SPI_CODIGO, isnull(DIR_CLIENTE.PA_CODIGO,233), CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(FED_ORD_COMP,'') else '' end, 
					                      VFillPedExpDet.SE_CODIGO, VPID_DESTNAFTA.PID_DESTNAFTA, VFillPedExpDet.FE_CODIGO, VFillPedExpDet.Ar_fraccion, isnull(VFillPedExpDet.MA_SERVICIO,'N')
					ORDER BY VFillPedExpDet.Ar_fraccion, FED_NOPARTE, MAX(FED_NOMBRE)
				end
				else
				begin
			
					INSERT INTO TempPedImpDet(PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CANT,  
						PID_CTOT_DLS,  ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
						AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
						PA_PROCEDE, ME_GENERICO, PID_COS_UNIVA, PID_COS_UNIMATGRA, SE_CODIGO, PID_REGIONFIN, PID_NOPARTEAUX, PID_CODIGOFACT, PID_ORD_COMP, PID_CTOT_MN,
						PID_CAN_GEN, PID_CAN_AR, PID_GENERA_EMPDET, PID_PES_UNIKG, PID_SERVICIO)
					
					SELECT     @picodigo, VFillPedExpDet.MA_CODIGO, VFillPedExpDet.FED_NOPARTE, MAX(VFillPedExpDet.FED_NOMBRE), MAX(VFillPedExpDet.FED_NAME), 
	  					      SUM(FED_CANT), 
						         'PID_CTOT_DLS'=case when max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO <> 154 AND MONEDA.PA_CODIGO <> 233) then (SUM(FED_COS_TOT)*max(FACTEXP.FE_TIPOCAMBIO))/@PI_TIP_CAM else SUM(FED_COS_TOT) end,
					                      VFillPedExpDet.ME_CODIGO, VFillPedExpDet.MA_GENERICO, 
					                      1, 1, ISNULL(max(VFillPedExpDet.AR_EXPMX), 0), ISNULL(max(VFillPedExpDet.AR_IMPFO), 0), 
					                      VFillPedExpDet.FED_RATEIMPFO, 0, FED_DEF_TIP, 
							0, max(VFillPedExpDet.TI_CODIGO),case when @ccp_tipo='CN' AND (select PI_DESP_EQUIPO from pedimp where pi_codigo=@picodigo)='S' then VFillPedExpDet.PA_CODIGO ELSE
							isnull(VPID_DESTNAFTA.PA_CODIGO,233) END, VFillPedExpDet.SPI_CODIGO, isnull(DIR_CLIENTE.PA_CODIGO,233), 
					                      isnull(max(VFillPedExpDet.ME_GENERICO), VFillPedExpDet.ME_CODIGO), 
						        'PID_COS_UNIVA'=case when @ccp_tipo='IR' or sum(FED_CANT)=0 then 0 else (case when @PI_USA_TIP_CAMFACT<>'S' and max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 233) then round(sum(PID_COS_UNIVAUSD*FED_CANT)*@PI_TIP_CAM/sum(FED_CANT),6) else round(sum(PID_COS_UNIVAUSD*FED_CANT)*max(FACTEXP.FE_TIPOCAMBIO)/sum(FED_CANT),6)  end) end, 
						        'PID_COS_UNIMATGRA'= case when sum(FED_CANT)=0 then 0 else (case when max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO <> 154 AND MONEDA.PA_CODIGO <> 233) then 
							round((sum((FED_GRA_EMP + FED_GRA_ADD + FED_GRA_MP + (FED_NG_MP + FED_NG_ADD - (isnull(FED_NG_USA,0)+isnull(FED_NG_MX,0))))*FED_CANT)/sum(FED_CANT))/@PI_TIP_CAM,6) else 
							round(sum((FED_GRA_EMP + FED_GRA_ADD + FED_GRA_MP + (FED_NG_MP + FED_NG_ADD - (isnull(FED_NG_USA,0)+isnull(FED_NG_MX,0))))*FED_CANT)/sum(FED_CANT),6) end) end,
					                      VFillPedExpDet.SE_CODIGO, VPID_DESTNAFTA.PID_DESTNAFTA, max(isnull(VFillPedExpDet.FED_NOPARTEAUX, '')), VFillPedExpDet.FE_CODIGO, CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(FED_ORD_COMP,'') else '' end,
							'PID_CTOT_MN'=case when max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154) then SUM(isnull(VFillPedExpDet.FED_COS_TOT,0)) else (case when @PI_USA_TIP_CAMFACT<>'S' and max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 233) then round(SUM(FED_COS_TOT)*@PI_TIP_CAM,6) else round(SUM(FED_COS_TOT)*max(FACTEXP.FE_TIPOCAMBIO),6) end) end,
							 round(SUM(isnull(VFillPedExpDet.FED_CANT,0)*isnull(VFillPedExpDet.EQ_GEN,1)),6),
							'PID_CAN_AR'=case when SUM(isnull(VFillPedExpDet.FED_CANT,0))=0 and MAX(VFillPedExpDet.ME_AREXPMX) in (select ME_KILOGRAMOS from configuracion) then round(SUM(isnull(VFillPedExpDet.FED_PES_NET,0)),6) 
								else round(SUM(isnull(VFillPedExpDet.FED_CANT,0)*isnull(VFillPedExpDet.EQ_EXPMX,1)),6) end,
							 MAX(FED_GENERA_EMPDET), max(VFillPedExpDet.PID_PES_UNIKG), isnull(VFillPedExpDet.MA_SERVICIO,'N')
	
					FROM         DIR_CLIENTE RIGHT OUTER JOIN
					                      FACTEXP ON DIR_CLIENTE.DI_INDICE = FACTEXP.DI_DESTINI LEFT OUTER JOIN
					                      VPID_DESTNAFTA RIGHT OUTER JOIN
					                      VFillPedExpDet ON VPID_DESTNAFTA.FED_INDICED = VFillPedExpDet.FED_INDICED ON 
					                      FACTEXP.FE_CODIGO = VFillPedExpDet.FE_CODIGO LEFT OUTER JOIN
					                      MAESTRO ON VFillPedExpDet.MA_CODIGO = MAESTRO.MA_CODIGO
					WHERE     (FACTEXP.PI_RECTIFICA =@picodigo or (FACTEXP.PI_RECTIFICA = @picodigo and
						VFillPedExpDet.FED_INDICED IN
						(SELECT     FACTEXPDET.FED_INDICED
						FROM         PEDIMPRELTRANS INNER JOIN
						                      PEDIMPDET ON PEDIMPRELTRANS.PID_INDICED = PEDIMPDET.PID_INDICED INNER JOIN
						                      FACTEXPDET ON PEDIMPRELTRANS.FED_INDICED = FACTEXPDET.FED_INDICED
						WHERE     PEDIMPDET.PID_REGIONFIN <> 'M' GROUP BY FACTEXPDET.FED_INDICED)))
						AND (VFillPedExpDet.MA_CODIGO IS NOT NULL)
					GROUP BY VPID_DESTNAFTA.PA_CODIGO, VFillPedExpDet.MA_CODIGO, VFillPedExpDet.FED_NOPARTE, 
					                      VFillPedExpDet.ME_CODIGO, VFillPedExpDet.MA_GENERICO, VFillPedExpDet.PA_CODIGO,
					                      VFillPedExpDet.FED_RATEIMPFO/*, VFillPedExpDet.PID_PES_UNIKG*/,
					                      VFillPedExpDet.SPI_CODIGO, isnull(DIR_CLIENTE.PA_CODIGO,233), FED_DEF_TIP,
					                      VFillPedExpDet.SE_CODIGO, VPID_DESTNAFTA.PID_DESTNAFTA, VFillPedExpDet.FE_CODIGO, CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(FED_ORD_COMP,'') else '' end, VFillPedExpDet.Ar_fraccion, isnull(VFillPedExpDet.MA_SERVICIO,'N')
					ORDER BY VFillPedExpDet.Ar_fraccion, FED_NOPARTE, MAX(FED_NOMBRE)
				end
			end
			else
			begin
				if @ccp_tipo<>'RE'
				begin
					INSERT INTO TempPedImpDet(PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CANT,  
						PID_CTOT_DLS,  ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
						AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
						PA_PROCEDE, ME_GENERICO, PID_COS_UNIVA, PID_COS_UNIMATGRA, SE_CODIGO, PID_REGIONFIN, PID_NOPARTEAUX, PID_CODIGOFACT, PID_ORD_COMP, PID_CTOT_MN,
						PID_CAN_GEN, PID_CAN_AR, PID_GENERA_EMPDET, PID_PES_UNIKG, PID_SERVICIO)
				
					SELECT     @picodigo, VFillPedExpDet.MA_CODIGO, VFillPedExpDet.FED_NOPARTE, MAX(VFillPedExpDet.FED_NOMBRE), MAX(VFillPedExpDet.FED_NAME), 
	  					      SUM(FED_CANT), 
						         'PID_CTOT_DLS'=case when max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO <> 154 AND MONEDA.PA_CODIGO <> 233) then (SUM(FED_COS_TOT)*max(FACTEXP.FE_TIPOCAMBIO))/@PI_TIP_CAM else SUM(FED_COS_TOT) end,
							VFillPedExpDet.ME_CODIGO, VFillPedExpDet.MA_GENERICO, 
					                      1, 1, ISNULL(max(VFillPedExpDet.AR_EXPMX), 0), ISNULL(max(VFillPedExpDet.AR_IMPFO), 0), 
					                      VFillPedExpDet.FED_RATEIMPFO, 0, FED_DEF_TIP,
							0, max(VFillPedExpDet.TI_CODIGO),case when @ccp_tipo='CN' AND (select PI_DESP_EQUIPO from pedimp where pi_codigo=@picodigo)='S' then VFillPedExpDet.PA_CODIGO ELSE
					isnull(VPID_DESTNAFTA.PA_CODIGO,233) END, VFillPedExpDet.SPI_CODIGO, isnull(DIR_CLIENTE.PA_CODIGO,233), 
					                      isnull(max(VFillPedExpDet.ME_GENERICO), VFillPedExpDet.ME_CODIGO), 
						        'PID_COS_UNIVA'=case when @ccp_tipo='IR' or sum(FED_CANT)=0 then 0 else (case when @PI_USA_TIP_CAMFACT<>'S' and max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 233) then round(sum(PID_COS_UNIVAUSDGI*FED_CANT)*@PI_TIP_CAM/sum(FED_CANT),6) else round(sum(PID_COS_UNIVAUSDGI*FED_CANT)*max(FACTEXP.FE_TIPOCAMBIO)/sum(FED_CANT),6)  end) end, 
						        'PID_COS_UNIMATGRA'= case when sum(FED_CANT)=0 then 0 else (case when max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO <> 154 AND MONEDA.PA_CODIGO <> 233) then 
							round((sum((FED_GRA_EMP + FED_GRA_ADD + FED_GRA_MP + (FED_NG_MP + FED_NG_ADD - (isnull(FED_NG_USA,0)+isnull(FED_NG_MX,0))))*FED_CANT)/sum(FED_CANT))/@PI_TIP_CAM,6) else 
							round(sum((FED_GRA_EMP + FED_GRA_ADD + FED_GRA_MP + (FED_NG_MP + FED_NG_ADD - (isnull(FED_NG_USA,0)+isnull(FED_NG_MX,0))))*FED_CANT)/sum(FED_CANT),6) end) end,
					                      VFillPedExpDet.SE_CODIGO, VPID_DESTNAFTA.PID_DESTNAFTA, max(isnull(VFillPedExpDet.FED_NOPARTEAUX,'')), VFillPedExpDet.FE_CODIGO, CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(FED_ORD_COMP,'') else '' end,
							'PID_CTOT_MN'=case when max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154) then SUM(isnull(VFillPedExpDet.FED_COS_TOT,0)) else (case when @PI_USA_TIP_CAMFACT<>'S' and max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 233) then round(SUM(FED_COS_TOT)*@PI_TIP_CAM,6) else round(SUM(FED_COS_TOT)*max(FACTEXP.FE_TIPOCAMBIO),6) end) end,
							 round(SUM(isnull(VFillPedExpDet.FED_CANT,0)*isnull(VFillPedExpDet.EQ_GEN,1)),6),
						          'PID_CAN_AR'=case when SUM(isnull(VFillPedExpDet.FED_CANT,0))=0 and MAX(VFillPedExpDet.ME_AREXPMX) in (select ME_KILOGRAMOS from configuracion) then round(SUM(isnull(VFillPedExpDet.FED_PES_NET,0)),6) 
								else round(SUM(isnull(VFillPedExpDet.FED_CANT,0)*isnull(VFillPedExpDet.EQ_EXPMX,1)),6) end,
							 MAX(FED_GENERA_EMPDET), max(VFillPedExpDet.PID_PES_UNIKG), isnull(VFillPedExpDet.MA_SERVICIO,'N')
	
					FROM         DIR_CLIENTE RIGHT OUTER JOIN
					                      FACTEXP ON DIR_CLIENTE.DI_INDICE = FACTEXP.DI_DESTINI LEFT OUTER JOIN
					                      VPID_DESTNAFTA RIGHT OUTER JOIN
					                      VFillPedExpDet ON VPID_DESTNAFTA.FED_INDICED = VFillPedExpDet.FED_INDICED ON 
					                      FACTEXP.FE_CODIGO = VFillPedExpDet.FE_CODIGO LEFT OUTER JOIN
					                      MAESTRO ON VFillPedExpDet.MA_CODIGO = MAESTRO.MA_CODIGO
					WHERE     (FACTEXP.PI_CODIGO = @picodigo or (FACTEXP.PI_CODIGO = @picodigo and
						VFillPedExpDet.FED_INDICED IN
						(SELECT     FACTEXPDET.FED_INDICED
						FROM         PEDIMPRELTRANS INNER JOIN
						                      PEDIMPDET ON PEDIMPRELTRANS.PID_INDICED = PEDIMPDET.PID_INDICED INNER JOIN
						                      FACTEXPDET ON PEDIMPRELTRANS.FED_INDICED = FACTEXPDET.FED_INDICED
						WHERE     PEDIMPDET.PID_REGIONFIN <> 'M' GROUP BY FACTEXPDET.FED_INDICED)))
						AND (VFillPedExpDet.MA_CODIGO IS NOT NULL)
					GROUP BY VPID_DESTNAFTA.PA_CODIGO, VFillPedExpDet.MA_CODIGO, VFillPedExpDet.FED_NOPARTE, 
					                      VFillPedExpDet.ME_CODIGO, VFillPedExpDet.MA_GENERICO, VFillPedExpDet.PA_CODIGO,
					                      VFillPedExpDet.FED_RATEIMPFO/*, VFillPedExpDet.PID_PES_UNIKG*/,
					                      VFillPedExpDet.SPI_CODIGO, isnull(DIR_CLIENTE.PA_CODIGO,233), FED_DEF_TIP,			                      
					                      VFillPedExpDet.SE_CODIGO, VPID_DESTNAFTA.PID_DESTNAFTA, VFillPedExpDet.FE_CODIGO, CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(FED_ORD_COMP,'') else '' end, VFillPedExpDet.Ar_fraccion, isnull(VFillPedExpDet.MA_SERVICIO,'N')
					ORDER BY VFillPedExpDet.Ar_fraccion, FED_NOPARTE, MAX(FED_NOMBRE)
				end
				else
				begin
					INSERT INTO TempPedImpDet(PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CANT,  
						PID_CTOT_DLS,  ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
						AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
						PA_PROCEDE, ME_GENERICO, PID_COS_UNIVA, PID_COS_UNIMATGRA, SE_CODIGO, PID_REGIONFIN, PID_NOPARTEAUX, PID_CODIGOFACT, PID_ORD_COMP, PID_CTOT_MN,
						PID_CAN_GEN, PID_CAN_AR, PID_GENERA_EMPDET, PID_PES_UNIKG, PID_SERVICIO)
				
					SELECT     @picodigo, VFillPedExpDet.MA_CODIGO, VFillPedExpDet.FED_NOPARTE, MAX(VFillPedExpDet.FED_NOMBRE), MAX(VFillPedExpDet.FED_NAME), 
	  					      SUM(FED_CANT), 
						         'PID_CTOT_DLS'=case when max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO <> 154 AND MONEDA.PA_CODIGO <> 233) then (SUM(FED_COS_TOT)*max(FACTEXP.FE_TIPOCAMBIO))/@PI_TIP_CAM else SUM(FED_COS_TOT) end,
							 VFillPedExpDet.ME_CODIGO, VFillPedExpDet.MA_GENERICO, 
					                      1, 1, ISNULL(max(VFillPedExpDet.AR_EXPMX), 0), ISNULL(max(VFillPedExpDet.AR_IMPFO), 0), VFillPedExpDet.FED_RATEIMPFO, 0, FED_DEF_TIP,
						          0, max(VFillPedExpDet.TI_CODIGO),case when @ccp_tipo='CN' AND (select PI_DESP_EQUIPO from pedimp where pi_codigo=@picodigo)='S' then VFillPedExpDet.PA_CODIGO ELSE
					isnull(VPID_DESTNAFTA.PA_CODIGO,233) END, VFillPedExpDet.SPI_CODIGO, isnull(DIR_CLIENTE.PA_CODIGO,233), 
					                      isnull(max(VFillPedExpDet.ME_GENERICO), VFillPedExpDet.ME_CODIGO), 
						        'PID_COS_UNIVA'=case when @ccp_tipo='IR' or sum(FED_CANT)=0 then 0 else (case when @PI_USA_TIP_CAMFACT<>'S' and max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 233) then round(sum(PID_COS_UNIVAUSDGI*FED_CANT)*@PI_TIP_CAM/sum(FED_CANT),6) else round(sum(PID_COS_UNIVAUSDGI*FED_CANT)*max(FACTEXP.FE_TIPOCAMBIO)/sum(FED_CANT),6)  end) end, 
						        'PID_COS_UNIMATGRA'= case when sum(FED_CANT)=0 then 0 else (case when max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO <> 154 AND MONEDA.PA_CODIGO <> 233) then 
							round((sum((FED_GRA_EMP + FED_GRA_ADD + FED_GRA_MP + (FED_NG_MP + FED_NG_ADD - (isnull(FED_NG_USA,0)+isnull(FED_NG_MX,0))))*FED_CANT)/sum(FED_CANT))/@PI_TIP_CAM,6) else 
							round(sum((FED_GRA_EMP + FED_GRA_ADD + FED_GRA_MP + (FED_NG_MP + FED_NG_ADD - (isnull(FED_NG_USA,0)+isnull(FED_NG_MX,0))))*FED_CANT)/sum(FED_CANT),6) end) end,
					                      VFillPedExpDet.SE_CODIGO, VPID_DESTNAFTA.PID_DESTNAFTA, max(isnull(VFillPedExpDet.FED_NOPARTEAUX,'')), VFillPedExpDet.FE_CODIGO, CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(FED_ORD_COMP,'') else '' end,
							'PID_CTOT_MN'=case when max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154) then SUM(isnull(VFillPedExpDet.FED_COS_TOT,0)) else (case when @PI_USA_TIP_CAMFACT<>'S' and max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 233) then round(SUM(FED_COS_TOT)*@PI_TIP_CAM,6) else round(SUM(FED_COS_TOT)*max(FACTEXP.FE_TIPOCAMBIO),6) end) end,
							 round(SUM(isnull(VFillPedExpDet.FED_CANT,0)*isnull(VFillPedExpDet.EQ_GEN,1)),6),
							'PID_CAN_AR'=case when SUM(isnull(VFillPedExpDet.FED_CANT,0))=0 and MAX(VFillPedExpDet.ME_AREXPMX) in (select ME_KILOGRAMOS from configuracion) then round(SUM(isnull(VFillPedExpDet.FED_PES_NET,0)),6) 
								else round(SUM(isnull(VFillPedExpDet.FED_CANT,0)*isnull(VFillPedExpDet.EQ_EXPMX,1)),6) end,
							 MAX(FED_GENERA_EMPDET), max(VFillPedExpDet.PID_PES_UNIKG), isnull(VFillPedExpDet.MA_SERVICIO,'N')
					FROM         DIR_CLIENTE RIGHT OUTER JOIN
					                      FACTEXP ON DIR_CLIENTE.DI_INDICE = FACTEXP.DI_DESTINI LEFT OUTER JOIN
					                      VPID_DESTNAFTA RIGHT OUTER JOIN
					                      VFillPedExpDet ON VPID_DESTNAFTA.FED_INDICED = VFillPedExpDet.FED_INDICED ON 
					                      FACTEXP.FE_CODIGO = VFillPedExpDet.FE_CODIGO LEFT OUTER JOIN
					                      MAESTRO ON VFillPedExpDet.MA_CODIGO = MAESTRO.MA_CODIGO
					WHERE     (FACTEXP.PI_RECTIFICA =@picodigo or (FACTEXP.PI_RECTIFICA = @picodigo and
						VFillPedExpDet.FED_INDICED IN
						(SELECT     FACTEXPDET.FED_INDICED
						FROM         PEDIMPRELTRANS INNER JOIN
						                      PEDIMPDET ON PEDIMPRELTRANS.PID_INDICED = PEDIMPDET.PID_INDICED INNER JOIN
						                      FACTEXPDET ON PEDIMPRELTRANS.FED_INDICED = FACTEXPDET.FED_INDICED
						WHERE     PEDIMPDET.PID_REGIONFIN <> 'M' GROUP BY FACTEXPDET.FED_INDICED)))
						AND (VFillPedExpDet.MA_CODIGO IS NOT NULL)
					GROUP BY VPID_DESTNAFTA.PA_CODIGO, VFillPedExpDet.MA_CODIGO, VFillPedExpDet.FED_NOPARTE, 
					                      VFillPedExpDet.ME_CODIGO, VFillPedExpDet.MA_GENERICO, VFillPedExpDet.PA_CODIGO,
					                      VFillPedExpDet.FED_RATEIMPFO, FED_DEF_TIP/*, VFillPedExpDet.PID_PES_UNIKG*/,
					                      VFillPedExpDet.SPI_CODIGO, isnull(DIR_CLIENTE.PA_CODIGO,233),
					                      VFillPedExpDet.SE_CODIGO, VPID_DESTNAFTA.PID_DESTNAFTA, VFillPedExpDet.FE_CODIGO, CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(FED_ORD_COMP,'') else '' end, VFillPedExpDet.Ar_fraccion, isnull(VFillPedExpDet.MA_SERVICIO,'N')
					ORDER BY VFillPedExpDet.Ar_fraccion, FED_NOPARTE, MAX(FED_NOMBRE)
				end
			
			end
		end		
		else -- CF_SAAIDETDIVFACT=N
		begin
	
			if @CF_PEDEXPVAUSA='N'
			-- en esta opcion no considera los gastos indirectos usa en el valor agregado, y en el costo total se le resta el empaque no gravable y los gatsos indirectos usa
			begin
			
				if @ccp_tipo<>'RE'
				begin
					INSERT INTO TempPedImpDet(PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CANT,  
						PID_CTOT_DLS,  ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
						AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
						PA_PROCEDE, ME_GENERICO, PID_COS_UNIVA, PID_COS_UNIMATGRA, SE_CODIGO, PID_REGIONFIN, PID_NOPARTEAUX, PID_ORD_COMP, PID_CTOT_MN,
						PID_CAN_GEN, PID_CAN_AR, PID_GENERA_EMPDET, PID_PES_UNIKG, PID_SERVICIO, pid_codigofact) 
						-- Se agrego pid_codigofact manuel G. 14-Sep-2010
					
					SELECT     @picodigo, VFillPedExpDet.MA_CODIGO, VFillPedExpDet.FED_NOPARTE, MAX(VFillPedExpDet.FED_NOMBRE), MAX(VFillPedExpDet.FED_NAME), 
	  					      SUM(FED_CANT), 
						             'PID_CTOT_DLS'=case when max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO <> 154 AND MONEDA.PA_CODIGO <> 233) then (SUM(FED_COS_TOT)*max(FACTEXP.FE_TIPOCAMBIO))/@PI_TIP_CAM else SUM(FED_COS_TOT) end,
					                      VFillPedExpDet.ME_CODIGO, VFillPedExpDet.MA_GENERICO, 
					                      1, 1, ISNULL(max(VFillPedExpDet.AR_EXPMX), 0), ISNULL(max(VFillPedExpDet.AR_IMPFO), 0), 
					                      VFillPedExpDet.FED_RATEIMPFO, 0, FED_DEF_TIP,
							0, max(VFillPedExpDet.TI_CODIGO),case when @ccp_tipo='CN' AND (select PI_DESP_EQUIPO from pedimp where pi_codigo=@picodigo)='S' then VFillPedExpDet.PA_CODIGO ELSE
					isnull(VPID_DESTNAFTA.PA_CODIGO,233) END, VFillPedExpDet.SPI_CODIGO, isnull(DIR_CLIENTE.PA_CODIGO,233), 
					                      isnull(max(VFillPedExpDet.ME_GENERICO), VFillPedExpDet.ME_CODIGO), 
						        'PID_COS_UNIVA'=case when @ccp_tipo='IR' or sum(FED_CANT)=0 then 0 else (case when @PI_USA_TIP_CAMFACT<>'S' and max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 233) then round(sum(PID_COS_UNIVAUSD*FED_CANT)*@PI_TIP_CAM/sum(FED_CANT),6) else round(sum(PID_COS_UNIVAUSD*FED_CANT)*max(FACTEXP.FE_TIPOCAMBIO)/sum(FED_CANT),6)  end) end, 
						        'PID_COS_UNIMATGRA'= case when sum(FED_CANT)=0 then 0 else (case when max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO <> 154 AND MONEDA.PA_CODIGO <> 233) then 
							round((sum((FED_GRA_EMP + FED_GRA_ADD + FED_GRA_MP + (FED_NG_MP + FED_NG_ADD - (isnull(FED_NG_USA,0)+isnull(FED_NG_MX,0))))*FED_CANT)/sum(FED_CANT))/@PI_TIP_CAM,6) else 
							round(sum((FED_GRA_EMP + FED_GRA_ADD + FED_GRA_MP + (FED_NG_MP + FED_NG_ADD - (isnull(FED_NG_USA,0)+isnull(FED_NG_MX,0))))*FED_CANT)/sum(FED_CANT),6) end) end,
					                      VFillPedExpDet.SE_CODIGO, VPID_DESTNAFTA.PID_DESTNAFTA, max(isnull(VFillPedExpDet.FED_NOPARTEAUX,'')), CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(FED_ORD_COMP,'') else '' end,
							'PID_CTOT_MN'=case when max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154) then SUM(isnull(VFillPedExpDet.FED_COS_TOT,0)) else (case when @PI_USA_TIP_CAMFACT<>'S' and max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 233) then round(SUM(FED_COS_TOT)*@PI_TIP_CAM,6) else round(SUM(FED_COS_TOT)*max(FACTEXP.FE_TIPOCAMBIO),6) end) end,
							 round(SUM(isnull(VFillPedExpDet.FED_CANT,0)*isnull(VFillPedExpDet.EQ_GEN,1)),6),
 							'PID_CAN_AR'=case when SUM(isnull(VFillPedExpDet.FED_CANT,0))=0 and MAX(VFillPedExpDet.ME_AREXPMX) in (select ME_KILOGRAMOS from configuracion) then round(SUM(isnull(VFillPedExpDet.FED_PES_NET,0)),6) 
								else round(SUM(isnull(VFillPedExpDet.FED_CANT,0)*isnull(VFillPedExpDet.EQ_EXPMX,1)),6) end, MAX(FED_GENERA_EMPDET),max(VFillPedExpDet.PID_PES_UNIKG), isnull(VFillPedExpDet.MA_SERVICIO,'N'), factexp.fe_codigo
	
					FROM         DIR_CLIENTE RIGHT OUTER JOIN
					                      FACTEXP ON DIR_CLIENTE.DI_INDICE = FACTEXP.DI_DESTINI LEFT OUTER JOIN
					                      VPID_DESTNAFTA RIGHT OUTER JOIN
					                      VFillPedExpDet ON VPID_DESTNAFTA.FED_INDICED = VFillPedExpDet.FED_INDICED ON 
					                      FACTEXP.FE_CODIGO = VFillPedExpDet.FE_CODIGO LEFT OUTER JOIN
					                      MAESTRO ON VFillPedExpDet.MA_CODIGO = MAESTRO.MA_CODIGO
					WHERE     (FACTEXP.PI_CODIGO = @picodigo or (FACTEXP.PI_CODIGO = @picodigo and
						VFillPedExpDet.FED_INDICED IN
						(SELECT     FACTEXPDET.FED_INDICED
						FROM         PEDIMPRELTRANS INNER JOIN
						                      PEDIMPDET ON PEDIMPRELTRANS.PID_INDICED = PEDIMPDET.PID_INDICED INNER JOIN
						                      FACTEXPDET ON PEDIMPRELTRANS.FED_INDICED = FACTEXPDET.FED_INDICED
						WHERE     PEDIMPDET.PID_REGIONFIN <> 'M' GROUP BY FACTEXPDET.FED_INDICED)))
					AND (VFillPedExpDet.MA_CODIGO IS NOT NULL)
					GROUP BY VPID_DESTNAFTA.PA_CODIGO, VFillPedExpDet.MA_CODIGO, VFillPedExpDet.FED_NOPARTE,
					                      VFillPedExpDet.ME_CODIGO, VFillPedExpDet.MA_GENERICO, VFillPedExpDet.PA_CODIGO,
					                      VFillPedExpDet.FED_RATEIMPFO, FED_DEF_TIP/*, VFillPedExpDet.PID_PES_UNIKG*/,
					                      VFillPedExpDet.SPI_CODIGO, isnull(DIR_CLIENTE.PA_CODIGO,233),
					                      VFillPedExpDet.SE_CODIGO, VPID_DESTNAFTA.PID_DESTNAFTA, CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(FED_ORD_COMP,'') else '' end, VFillPedExpDet.Ar_fraccion, isnull(VFillPedExpDet.MA_SERVICIO,'N'), factexp.fe_codigo
					ORDER BY VFillPedExpDet.Ar_fraccion, FED_NOPARTE, MAX(FED_NOMBRE)
				end
				else
				begin
			
					INSERT INTO TempPedImpDet(PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CANT,  
						PID_CTOT_DLS,  ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
						AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, PA_PROCEDE, 
						ME_GENERICO, PID_COS_UNIVA, PID_COS_UNIMATGRA, SE_CODIGO, PID_REGIONFIN, PID_NOPARTEAUX, PID_ORD_COMP, PID_CTOT_MN,
						PID_CAN_GEN, PID_CAN_AR, PID_GENERA_EMPDET, PID_PES_UNIKG, PID_SERVICIO, pid_codigofact) 
						-- Se agrego pid_codigofact manuel G. 14-Sep-2010
					
					SELECT     @picodigo, VFillPedExpDet.MA_CODIGO, VFillPedExpDet.FED_NOPARTE, MAX(VFillPedExpDet.FED_NOMBRE), MAX(VFillPedExpDet.FED_NAME), 
					      SUM(FED_CANT), 
						         'PID_CTOT_DLS'=case when max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO <> 154 AND MONEDA.PA_CODIGO <> 233) then (SUM(FED_COS_TOT)*max(FACTEXP.FE_TIPOCAMBIO))/@PI_TIP_CAM else SUM(FED_COS_TOT) end,
					                      VFillPedExpDet.ME_CODIGO, VFillPedExpDet.MA_GENERICO, 
					                      1, 1, ISNULL(max(VFillPedExpDet.AR_EXPMX), 0), ISNULL(max(VFillPedExpDet.AR_IMPFO), 0), 
					                      VFillPedExpDet.FED_RATEIMPFO, 0, FED_DEF_TIP, 
							0, max(VFillPedExpDet.TI_CODIGO),case when @ccp_tipo='CN' AND (select PI_DESP_EQUIPO from pedimp where pi_codigo=@picodigo)='S' then VFillPedExpDet.PA_CODIGO ELSE
					isnull(VPID_DESTNAFTA.PA_CODIGO,233) END, VFillPedExpDet.SPI_CODIGO, isnull(DIR_CLIENTE.PA_CODIGO,233), 
					                      isnull(max(VFillPedExpDet.ME_GENERICO), VFillPedExpDet.ME_CODIGO), 
						        'PID_COS_UNIVA'=case when @ccp_tipo='IR' or sum(FED_CANT)=0 then 0 else (case when @PI_USA_TIP_CAMFACT<>'S' and max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 233) then round(sum(PID_COS_UNIVAUSD*FED_CANT)*@PI_TIP_CAM/sum(FED_CANT),6) else round(sum(PID_COS_UNIVAUSD*FED_CANT)*max(FACTEXP.FE_TIPOCAMBIO)/sum(FED_CANT),6)  end) end, 
						        'PID_COS_UNIMATGRA'= case when sum(FED_CANT)=0 then 0 else (case when max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO <> 154 AND MONEDA.PA_CODIGO <> 233) then 
							round((sum((FED_GRA_EMP + FED_GRA_ADD + FED_GRA_MP + (FED_NG_MP + FED_NG_ADD - (isnull(FED_NG_USA,0)+isnull(FED_NG_MX,0))))*FED_CANT)/sum(FED_CANT))/@PI_TIP_CAM,6) else 
							round(sum((FED_GRA_EMP + FED_GRA_ADD + FED_GRA_MP + (FED_NG_MP + FED_NG_ADD - (isnull(FED_NG_USA,0)+isnull(FED_NG_MX,0))))*FED_CANT)/sum(FED_CANT),6) end) end,
					                      VFillPedExpDet.SE_CODIGO, VPID_DESTNAFTA.PID_DESTNAFTA, max(isnull(VFillPedExpDet.FED_NOPARTEAUX, '')), CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(FED_ORD_COMP,'') else '' end,
							'PID_CTOT_MN'=case when max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154) then SUM(isnull(VFillPedExpDet.FED_COS_TOT,0)) else (case when @PI_USA_TIP_CAMFACT<>'S' and max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 233) then round(SUM(FED_COS_TOT)*@PI_TIP_CAM,6) else round(SUM(FED_COS_TOT)*max(FACTEXP.FE_TIPOCAMBIO),6) end) end,
							 round(SUM(isnull(VFillPedExpDet.FED_CANT,0)*isnull(VFillPedExpDet.EQ_GEN,1)),6),
							'PID_CAN_AR'=case when SUM(isnull(VFillPedExpDet.FED_CANT,0))=0 and MAX(VFillPedExpDet.ME_AREXPMX) in (select ME_KILOGRAMOS from configuracion) then round(SUM(isnull(VFillPedExpDet.FED_PES_NET,0)),6) 
								else round(SUM(isnull(VFillPedExpDet.FED_CANT,0)*isnull(VFillPedExpDet.EQ_EXPMX,1)),6) end,
							MAX(FED_GENERA_EMPDET), max(VFillPedExpDet.PID_PES_UNIKG), isnull(VFillPedExpDet.MA_SERVICIO,'N'), factexp.fe_codigo
	
					FROM         DIR_CLIENTE RIGHT OUTER JOIN
					                      FACTEXP ON DIR_CLIENTE.DI_INDICE = FACTEXP.DI_DESTINI LEFT OUTER JOIN
					                      VPID_DESTNAFTA RIGHT OUTER JOIN
					                      VFillPedExpDet ON VPID_DESTNAFTA.FED_INDICED = VFillPedExpDet.FED_INDICED ON 
					                      FACTEXP.FE_CODIGO = VFillPedExpDet.FE_CODIGO LEFT OUTER JOIN
					                      MAESTRO ON VFillPedExpDet.MA_CODIGO = MAESTRO.MA_CODIGO
					WHERE     (FACTEXP.PI_RECTIFICA =@picodigo or (FACTEXP.PI_RECTIFICA = @picodigo and
						VFillPedExpDet.FED_INDICED IN
						(SELECT     FACTEXPDET.FED_INDICED
						FROM         PEDIMPRELTRANS INNER JOIN
						                      PEDIMPDET ON PEDIMPRELTRANS.PID_INDICED = PEDIMPDET.PID_INDICED INNER JOIN
						                      FACTEXPDET ON PEDIMPRELTRANS.FED_INDICED = FACTEXPDET.FED_INDICED
						WHERE     PEDIMPDET.PID_REGIONFIN <> 'M' GROUP BY FACTEXPDET.FED_INDICED)))
					AND (VFillPedExpDet.MA_CODIGO IS NOT NULL)
					GROUP BY VPID_DESTNAFTA.PA_CODIGO, VFillPedExpDet.MA_CODIGO, VFillPedExpDet.FED_NOPARTE, 
					                      VFillPedExpDet.ME_CODIGO, VFillPedExpDet.MA_GENERICO, VFillPedExpDet.PA_CODIGO,
					                      VFillPedExpDet.FED_RATEIMPFO, FED_DEF_TIP/*, VFillPedExpDet.PID_PES_UNIKG*/,
					                      VFillPedExpDet.SPI_CODIGO, isnull(DIR_CLIENTE.PA_CODIGO,233),
					                      VFillPedExpDet.SE_CODIGO, VPID_DESTNAFTA.PID_DESTNAFTA, CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(FED_ORD_COMP,'') else '' end, VFillPedExpDet.Ar_fraccion, isnull(VFillPedExpDet.MA_SERVICIO,'N'), factexp.fe_codigo
					ORDER BY VFillPedExpDet.Ar_fraccion, FED_NOPARTE, MAX(FED_NOMBRE)
				end
			end
			else
			begin
				if @ccp_tipo<>'RE'
				begin
					INSERT INTO TempPedImpDet(PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CANT,  
						PID_CTOT_DLS,  ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
						AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
						PA_PROCEDE, ME_GENERICO, PID_COS_UNIVA, PID_COS_UNIMATGRA, SE_CODIGO, PID_REGIONFIN, PID_NOPARTEAUX, PID_ORD_COMP, PID_CTOT_MN,
						PID_CAN_GEN, PID_CAN_AR, PID_GENERA_EMPDET, PID_PES_UNIKG, PID_SERVICIO, pid_codigofact) 
						-- Se agrego pid_codigofact manuel G. 14-Sep-2010
				
					SELECT     @picodigo, VFillPedExpDet.MA_CODIGO, VFillPedExpDet.FED_NOPARTE, MAX(VFillPedExpDet.FED_NOMBRE), MAX(VFillPedExpDet.FED_NAME), 
	  					      SUM(FED_CANT), 
						         'PID_CTOT_DLS'=case when max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO <> 154 AND MONEDA.PA_CODIGO <> 233) then (SUM(FED_COS_TOT)*max(FACTEXP.FE_TIPOCAMBIO))/@PI_TIP_CAM else SUM(FED_COS_TOT) end,
							 VFillPedExpDet.ME_CODIGO, VFillPedExpDet.MA_GENERICO, 
					                      1, 1, ISNULL(max(VFillPedExpDet.AR_EXPMX), 0), ISNULL(max(VFillPedExpDet.AR_IMPFO), 0), 
					                      VFillPedExpDet.FED_RATEIMPFO, 0, FED_DEF_TIP, 
							0, max(VFillPedExpDet.TI_CODIGO),case when @ccp_tipo='CN' AND (select PI_DESP_EQUIPO from pedimp where pi_codigo=@picodigo)='S' then VFillPedExpDet.PA_CODIGO ELSE
					isnull(VPID_DESTNAFTA.PA_CODIGO,233) END, VFillPedExpDet.SPI_CODIGO, isnull(DIR_CLIENTE.PA_CODIGO,233), 
					                      isnull(max(VFillPedExpDet.ME_GENERICO), VFillPedExpDet.ME_CODIGO), 
						        'PID_COS_UNIVA'=case when @ccp_tipo='IR' or sum(FED_CANT)=0 then 0 else (case when @PI_USA_TIP_CAMFACT<>'S' and max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 233) then round(sum(PID_COS_UNIVAUSDGI*FED_CANT)*@PI_TIP_CAM/sum(FED_CANT),6) else round(sum(PID_COS_UNIVAUSDGI*FED_CANT)*max(FACTEXP.FE_TIPOCAMBIO)/sum(FED_CANT),6)  end) end, 
						        'PID_COS_UNIMATGRA'= case when sum(FED_CANT)=0 then 0 else (case when max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO <> 154 AND MONEDA.PA_CODIGO <> 233) then 
							round((sum((FED_GRA_EMP + FED_GRA_ADD + FED_GRA_MP + (FED_NG_MP + FED_NG_ADD - (isnull(FED_NG_USA,0)+isnull(FED_NG_MX,0))))*FED_CANT)/sum(FED_CANT))/@PI_TIP_CAM,6) else 
							round(sum((FED_GRA_EMP + FED_GRA_ADD + FED_GRA_MP + (FED_NG_MP + FED_NG_ADD - (isnull(FED_NG_USA,0)+isnull(FED_NG_MX,0))))*FED_CANT)/sum(FED_CANT),6) end) end,

					                      VFillPedExpDet.SE_CODIGO, VPID_DESTNAFTA.PID_DESTNAFTA, max(isnull(VFillPedExpDet.FED_NOPARTEAUX,'')), CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(FED_ORD_COMP,'') else '' end,
							'PID_CTOT_MN'=case when max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154) then SUM(isnull(VFillPedExpDet.FED_COS_TOT,0)) else (case when @PI_USA_TIP_CAMFACT<>'S' and max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 233) then round(SUM(FED_COS_TOT)*@PI_TIP_CAM,6) else round(SUM(FED_COS_TOT)*max(FACTEXP.FE_TIPOCAMBIO),6) end) end,
							 round(SUM(isnull(VFillPedExpDet.FED_CANT,0)*isnull(VFillPedExpDet.EQ_GEN,1)),6),
							'PID_CAN_AR'=case when SUM(isnull(VFillPedExpDet.FED_CANT,0))=0 and MAX(VFillPedExpDet.ME_AREXPMX) in (select ME_KILOGRAMOS from configuracion) then round(SUM(isnull(VFillPedExpDet.FED_PES_NET,0)),6) 
								else round(SUM(isnull(VFillPedExpDet.FED_CANT,0)*isnull(VFillPedExpDet.EQ_EXPMX,1)),6) end,
							 MAX(FED_GENERA_EMPDET),max(VFillPedExpDet.PID_PES_UNIKG), isnull(VFillPedExpDet.MA_SERVICIO,'N'), factexp.fe_codigo
					FROM         DIR_CLIENTE RIGHT OUTER JOIN
					                      FACTEXP ON DIR_CLIENTE.DI_INDICE = FACTEXP.DI_DESTINI LEFT OUTER JOIN
					                      VPID_DESTNAFTA RIGHT OUTER JOIN
					                      VFillPedExpDet ON VPID_DESTNAFTA.FED_INDICED = VFillPedExpDet.FED_INDICED ON 
					                      FACTEXP.FE_CODIGO = VFillPedExpDet.FE_CODIGO LEFT OUTER JOIN
					                      MAESTRO ON VFillPedExpDet.MA_CODIGO = MAESTRO.MA_CODIGO
					WHERE     (FACTEXP.PI_CODIGO = @picodigo or (FACTEXP.PI_CODIGO = @picodigo and
						VFillPedExpDet.FED_INDICED IN
						(SELECT     FACTEXPDET.FED_INDICED
						FROM         PEDIMPRELTRANS INNER JOIN
						                      PEDIMPDET ON PEDIMPRELTRANS.PID_INDICED = PEDIMPDET.PID_INDICED INNER JOIN
						                      FACTEXPDET ON PEDIMPRELTRANS.FED_INDICED = FACTEXPDET.FED_INDICED
						WHERE     PEDIMPDET.PID_REGIONFIN <> 'M' GROUP BY FACTEXPDET.FED_INDICED)))
					AND (VFillPedExpDet.MA_CODIGO IS NOT NULL)
					GROUP BY VPID_DESTNAFTA.PA_CODIGO, VFillPedExpDet.MA_CODIGO, VFillPedExpDet.FED_NOPARTE, 
					                      VFillPedExpDet.ME_CODIGO, VFillPedExpDet.MA_GENERICO, VFillPedExpDet.PA_CODIGO,
					                      VFillPedExpDet.FED_RATEIMPFO, FED_DEF_TIP/*, VFillPedExpDet.PID_PES_UNIKG*/,
					                      VFillPedExpDet.SPI_CODIGO, isnull(DIR_CLIENTE.PA_CODIGO,233),
					                      VFillPedExpDet.SE_CODIGO, VPID_DESTNAFTA.PID_DESTNAFTA,  CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(FED_ORD_COMP,'') else '' end, VFillPedExpDet.Ar_fraccion, isnull(VFillPedExpDet.MA_SERVICIO,'N'), factexp.fe_codigo
					ORDER BY VFillPedExpDet.Ar_fraccion, FED_NOPARTE, MAX(FED_NOMBRE)
				end
				else
				begin
					INSERT INTO TempPedImpDet(PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CANT,  
						PID_CTOT_DLS,  ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
						AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
						PA_PROCEDE, ME_GENERICO, PID_COS_UNIVA, PID_COS_UNIMATGRA, SE_CODIGO, PID_REGIONFIN, PID_NOPARTEAUX, PID_ORD_COMP, PID_CTOT_MN,
						PID_CAN_GEN, PID_CAN_AR, PID_GENERA_EMPDET, PID_PES_UNIKG, PID_SERVICIO, pid_codigofact) 
						-- Se agrego pid_codigofact manuel G. 14-Sep-2010
				
					SELECT     @picodigo, VFillPedExpDet.MA_CODIGO, VFillPedExpDet.FED_NOPARTE, MAX(VFillPedExpDet.FED_NOMBRE), MAX(VFillPedExpDet.FED_NAME), 
	  					      SUM(FED_CANT), 
						         'PID_CTOT_DLS'=case when max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO <> 154 AND MONEDA.PA_CODIGO <> 233) then (SUM(FED_COS_TOT)*max(FACTEXP.FE_TIPOCAMBIO))/@PI_TIP_CAM else SUM(FED_COS_TOT) end,
							 VFillPedExpDet.ME_CODIGO, VFillPedExpDet.MA_GENERICO, 
					                      1, 1, ISNULL(max(VFillPedExpDet.AR_EXPMX), 0), ISNULL(max(VFillPedExpDet.AR_IMPFO), 0), 
					                      VFillPedExpDet.FED_RATEIMPFO, 0, FED_DEF_TIP, 
							0, max(VFillPedExpDet.TI_CODIGO),case when @ccp_tipo='CN' AND (select PI_DESP_EQUIPO from pedimp where pi_codigo=@picodigo)='S' then VFillPedExpDet.PA_CODIGO ELSE
					isnull(VPID_DESTNAFTA.PA_CODIGO,233) END, VFillPedExpDet.SPI_CODIGO, isnull(DIR_CLIENTE.PA_CODIGO,233), 
					                      isnull(max(VFillPedExpDet.ME_GENERICO), VFillPedExpDet.ME_CODIGO), 
						        'PID_COS_UNIVA'=case when @ccp_tipo='IR' or sum(FED_CANT)=0 then 0 else (case when @PI_USA_TIP_CAMFACT<>'S' and max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 233) then round(sum(PID_COS_UNIVAUSDGI*FED_CANT)*@PI_TIP_CAM/sum(FED_CANT),6) else round(sum(PID_COS_UNIVAUSDGI*FED_CANT)*max(FACTEXP.FE_TIPOCAMBIO)/sum(FED_CANT),6)  end) end, 
						        'PID_COS_UNIMATGRA'= case when sum(FED_CANT)=0 then 0 else (case when max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO <> 154 AND MONEDA.PA_CODIGO <> 233) then 
							round((sum((FED_GRA_EMP + FED_GRA_ADD + FED_GRA_MP + (FED_NG_MP + FED_NG_ADD - (isnull(FED_NG_USA,0)+isnull(FED_NG_MX,0))))*FED_CANT)/sum(FED_CANT))/@PI_TIP_CAM,6) else 
							round(sum((FED_GRA_EMP + FED_GRA_ADD + FED_GRA_MP + (FED_NG_MP + FED_NG_ADD - (isnull(FED_NG_USA,0)+isnull(FED_NG_MX,0))))*FED_CANT)/sum(FED_CANT),6) end) end,
					                      VFillPedExpDet.SE_CODIGO, VPID_DESTNAFTA.PID_DESTNAFTA, max(isnull(VFillPedExpDet.FED_NOPARTEAUX,'')), CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(FED_ORD_COMP,'') else '' end,
							'PID_CTOT_MN'=case when max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154) then SUM(isnull(VFillPedExpDet.FED_COS_TOT,0)) else (case when @PI_USA_TIP_CAMFACT<>'S' and max(factexp.mo_codigo) IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 233) then round(SUM(FED_COS_TOT)*@PI_TIP_CAM,6) else round(SUM(FED_COS_TOT)*max(FACTEXP.FE_TIPOCAMBIO),6) end) end,
							 round(SUM(isnull(VFillPedExpDet.FED_CANT,0)*isnull(VFillPedExpDet.EQ_GEN,1)),6),
							'PID_CAN_AR'=case when SUM(isnull(VFillPedExpDet.FED_CANT,0))=0 and MAX(VFillPedExpDet.ME_AREXPMX) in (select ME_KILOGRAMOS from configuracion) then round(SUM(isnull(VFillPedExpDet.FED_PES_NET,0)),6) 
								else round(SUM(isnull(VFillPedExpDet.FED_CANT,0)*isnull(VFillPedExpDet.EQ_EXPMX,1)),6) end,
							 MAX(FED_GENERA_EMPDET),max(VFillPedExpDet.PID_PES_UNIKG), isnull(VFillPedExpDet.MA_SERVICIO,'N'), factexp.fe_codigo
						FROM         DIR_CLIENTE RIGHT OUTER JOIN
					                      FACTEXP ON DIR_CLIENTE.DI_INDICE = FACTEXP.DI_DESTINI LEFT OUTER JOIN
					                      VPID_DESTNAFTA RIGHT OUTER JOIN
					                      VFillPedExpDet ON VPID_DESTNAFTA.FED_INDICED = VFillPedExpDet.FED_INDICED ON 
					                      FACTEXP.FE_CODIGO = VFillPedExpDet.FE_CODIGO LEFT OUTER JOIN
					                      MAESTRO ON VFillPedExpDet.MA_CODIGO = MAESTRO.MA_CODIGO
					WHERE     (FACTEXP.PI_RECTIFICA =@picodigo or (FACTEXP.PI_RECTIFICA = @picodigo and
						VFillPedExpDet.FED_INDICED IN
						(SELECT     FACTEXPDET.FED_INDICED
						FROM         PEDIMPRELTRANS INNER JOIN
						                      PEDIMPDET ON PEDIMPRELTRANS.PID_INDICED = PEDIMPDET.PID_INDICED INNER JOIN
						                      FACTEXPDET ON PEDIMPRELTRANS.FED_INDICED = FACTEXPDET.FED_INDICED
						WHERE     PEDIMPDET.PID_REGIONFIN <> 'M' GROUP BY FACTEXPDET.FED_INDICED)))
					AND (VFillPedExpDet.MA_CODIGO IS NOT NULL)
					GROUP BY VPID_DESTNAFTA.PA_CODIGO, VFillPedExpDet.MA_CODIGO, VFillPedExpDet.FED_NOPARTE, 
					                      VFillPedExpDet.ME_CODIGO, VFillPedExpDet.MA_GENERICO, VFillPedExpDet.PA_CODIGO,
					                      VFillPedExpDet.FED_RATEIMPFO, FED_DEF_TIP/*, VFillPedExpDet.PID_PES_UNIKG*/,
					                      VFillPedExpDet.SPI_CODIGO, isnull(DIR_CLIENTE.PA_CODIGO,233),
					                      VFillPedExpDet.SE_CODIGO, VPID_DESTNAFTA.PID_DESTNAFTA, CASE WHEN @PICF_SAAIDETDIVPO='S' then isnull(FED_ORD_COMP,'') else '' end, VFillPedExpDet.Ar_fraccion, isnull(VFillPedExpDet.MA_SERVICIO,'N'), factexp.fe_codigo
					ORDER BY VFillPedExpDet.Ar_fraccion, FED_NOPARTE, MAX(FED_NOMBRE)
				end
			
			end
	
		end

	end


	update Temppedimpdet
	set ME_ARIMPMX=(select arancel.me_codigo from arancel where arancel.ar_codigo=Temppedimpdet.AR_IMPMX)


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
		where PID_CANT >0 AND ME_ARIMPMX IN (SELECT ME_KILOGRAMOS FROM CONFIGURACION)

	end

	update Temppedimpdet
	set EQ_GENERICO=1 
	where EQ_GENERICO is null or EQ_GENERICO=0


	if exists (select fe_codigo from factexp where (pi_codigo=@picodigo or pi_rectifica=@picodigo) and mo_codigo IN (SELECT MO_CODIGO FROM MONEDA WHERE MONEDA.PA_CODIGO = 154))
	begin

		/* el valor en aduana debe de estar en la unidad de medida del grupo generico por esto se divide entre el eq_generico*/
		update Temppedimpdet
		set PID_COS_UNI=round(((PID_CTOT_DLS)/@PI_TIP_CAM)/PID_CANT,6),
		PID_COS_UNIgen= round((((PID_CTOT_DLS)/@PI_TIP_CAM)/PID_CANT)/ EQ_GENERICO,6),
		PID_COS_UNIADU= round(PID_CTOT_MN * @pi_ft_adu/isnull(PID_CANT,0),6)/EQ_GENERICO,
		PID_VAL_ADU= round(PID_CTOT_MN * @pi_ft_adu,0)
		where PID_CANT >0 and PID_CTOT_DLS>0 and pi_codigo=@picodigo 

		update Temppedimpdet
		set PID_COS_UNI = round(PID_CTOT_DLS/@PI_TIP_CAM,6),
		PID_COS_UNIADU = dbo.trunc((PID_CTOT_MN * @pi_ft_adu)/ EQ_GENERICO,6),
		PID_COS_UNIgen = round((PID_CTOT_DLS/@PI_TIP_CAM)/EQ_GENERICO,6),
		PID_VAL_ADU = round(PID_CTOT_MN * @pi_ft_adu,0)
		where PID_CANT = 0 and PID_CTOT_DLS>0 and pi_codigo=@picodigo

		update Temppedimpdet
		set PID_CTOT_DLS=round((PID_CTOT_DLS)/@PI_TIP_CAM,6)
		where PID_CANT >0 and PID_CTOT_DLS>0 and pi_codigo=@picodigo 

	end
	else
	begin

	
		update Temppedimpdet
		set PID_COS_UNI = round(PID_CTOT_DLS/PID_CANT,6),
		PID_COS_UNIgen = round((PID_CTOT_DLS/PID_CANT)/ isnull(EQ_GENERICO,1),6),
		PID_COS_UNIADU = round((PID_CTOT_MN * @pi_ft_adu)/PID_CANT,6)/ EQ_GENERICO,
		PID_VAL_ADU= round(PID_CTOT_MN * @pi_ft_adu,0)
		where PID_CANT >0 and PID_CTOT_DLS>0 and pi_codigo=@picodigo
	
	
		update Temppedimpdet
		set PID_COS_UNI = round(PID_CTOT_DLS,6),
		PID_COS_UNIADU = dbo.trunc((PID_CTOT_MN * @pi_ft_adu)/ EQ_GENERICO,6),
		PID_COS_UNIgen = round((PID_CTOT_DLS)/EQ_GENERICO,6),
		PID_VAL_ADU = round(PID_CTOT_MN * @pi_ft_adu,0)
		where PID_CANT = 0 and PID_CTOT_DLS>0 and pi_codigo=@picodigo
	end

	update Temppedimpdet
	set PID_COS_UNI = 0,
	PID_COS_UNIgen = 0,
	PID_COS_UNIADU = 0,
	PID_VAL_ADU= 0
	where PID_CANT >0 and PID_CTOT_DLS=0 and pi_codigo=@picodigo

	update Temppedimpdet
	set PID_COS_UNI = 0,
	PID_COS_UNIADU = 0,
	PID_COS_UNIgen = 0,
	PID_VAL_ADU = 0
	where PID_CANT = 0 and PID_CTOT_DLS=0 and pi_codigo=@picodigo

	update Temppedimpdet  
	set pid_saldogen = 0
	where pi_codigo=@picodigo


	/* esto no se puede aplicar en salidas, ya que el campo PID_DEF_TIP se utiliza para saber si es un registro de desperdicio o reparacion

	update Temppedimpdet
	set SPI_CODIGO= 0
	where PID_DEF_TIP<>'P' and pi_codigo=@picodigo */


select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

	insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)	
	values (@user, 2, 'Llenando detalle Pedimento ', 'Filling Detail Pedimento ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)


	if (select min(pid_indiced) from TempPedImpDet)=0
	SELECT     @maximo= isnull(MAX(PID_INDICED),0)+1
	FROM         PEDIMPDET
	else
	SELECT     @maximo= isnull(MAX(PID_INDICED),1)
	FROM         PEDIMPDET
	


	exec sp_FillDetalle @picodigo, @maximo, @user



	if exists (select * from TempPedImpDet where PID_ORD_COMP is not null and PID_ORD_COMP<>'')
	EXEC SP_SECUENCIAPO @picodigo

	exec sp_CalculaTPago @picodigo, 'S'

/* se actualiza la liga con facturas */
select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

	insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
	values (@user, 2, 'Ligando detalle Pedimento - Detalle Factura ', 'Linking Pedimento Detail - Invoice Detail ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)


	EXEC LigaPedDetalle @picodigo
	



select @Pid_indiced= max(pid_indiced) from pedimpdet

	update consecutivo
	set cv_codigo =  isnull(@pid_indiced,0) + 1
	where cv_tipo = 'PID'

	ALTER TABLE PEDIMPDET ENABLE TRIGGER insert_pedimpdet



GO
