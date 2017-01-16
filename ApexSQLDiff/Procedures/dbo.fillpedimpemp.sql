SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO








CREATE PROCEDURE dbo.[fillpedimpemp] (@picodigo int, @user int)   as

SET NOCOUNT ON 
declare @maximo int, @Pid_indiced int, @pi_codigo varchar(20), @FechaActual varchar(10), @hora varchar(15), @em_codigo int, @CF_MAN_EMPAQUE char(1),
@ccp_tipo varchar(5), @PI_USA_TIP_CAMFACT char(1)


	SET @FechaActual = convert(varchar(10), getdate(),101)

	select @em_codigo=em_codigo from intradeglobal.dbo.empresa where em_corto in
	(select replace(convert(sysname,db_name()),'intrade',''))

	select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

	insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
	values (@user, 2, 'Calculando  Empaque como desperdicio  ', 'Calculating Scrap Packing ', convert(varchar(10), @FechaActual,101), @hora, @em_codigo)

	SELECT     @CF_MAN_EMPAQUE= CF_MAN_EMPAQUE
	FROM         CONFIGURACION

	select @ccp_tipo=ccp_tipo from configuraclaveped where cp_codigo in
	(select cp_codigo from pedimp where pi_codigo=@picodigo)

        set @pi_codigo = convert(varchar(20), @picodigo)


	declare @PI_TIP_CAM decimal(38,6), @pi_ft_adu decimal(38,9)


	select @PI_TIP_CAM=PI_TIP_CAM, @pi_ft_adu=pi_ft_adu, @PI_USA_TIP_CAMFACT=PI_USA_TIP_CAMFACT from pedimp where pi_codigo=@picodigo

	if (SELECT CF_EMPDESPIMP FROM CONFIGURACION)='S' /* si la empresa quiere llevar el control del empaque que importa como desperdicio */
	begin

		IF (SELECT PICF_SAAIDETDIVFACT FROM PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='S'
		begin
		--			PID_CODIGOFACT
                        -- la opción "Manejo empaque en documentos (pestaña o detalle)" ya no se muestra en Configuración del sistema
                        -- se asume que el empaque está incluido siempre en el detalle, y no se lleva por pestaña
                        -- tomado de versión 2.0.0.34 (glr)
                        --if @CF_MAN_EMPAQUE = 'I' /* si lleva el control del empaque en el detalle */
			begin
		
				INSERT INTO TempPedImpDet (PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CTOT_DLS, 
					PID_CANT, ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
					AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
					PA_PROCEDE, ME_GENERICO, ME_ARIMPMX, PID_IMPRIMIR, PID_GENERA_EMP, PID_CANT_DESP, PID_DESCARGABLE, PID_CODIGOFACT, PID_CTOT_MN,
					PID_CAN_GEN, PID_CAN_AR)
			
				SELECT     @picodigo, dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, isnull(isnull(max(VMAESTROCOST.MA_COSTO),0)*SUM(dbo.FACTIMPDET.FID_CANTEMP),0), 
				                      SUM(dbo.FACTIMPDET.FID_CANTEMP), dbo.MAESTRO.ME_COM, dbo.MAESTRO.MA_GENERICO, dbo.MAESTRO.EQ_GEN, 
				                      dbo.MAESTRO.EQ_IMPMX, isnull(dbo.MAESTRO.AR_IMPMX,0), isnull(dbo.MAESTRO.AR_EXPFO,0), dbo.GetAdvalorem(dbo.MAESTRO.AR_EXPFO, 0, 'G', 0, 0), dbo.MAESTRO.MA_SEC_IMP, 
				                      dbo.MAESTRO.MA_DEF_TIP, 0, dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.PA_ORIGEN, dbo.MAESTRO.SPI_CODIGO, 
				                      dbo.MAESTRO.PA_PROCEDE, MAESTRO_1.ME_COM AS ME_GEN, dbo.ARANCEL.ME_CODIGO AS ME_AR, 'N', dbo. FACTIMPDET.FID_GENERA_EMP,
					         sum(dbo. FACTIMPDET.FID_CANT_DESP), 'S', dbo. FACTIMPDET.FI_CODIGO, 'PID_CTOT_MN'=case when @PI_USA_TIP_CAMFACT<>'S' then  isnull(max(isnull(VMAESTROCOST.MA_COSTO,0)*@PI_TIP_CAM)*SUM(dbo.FACTIMPDET.FID_CANTEMP),0)  else isnull(max(isnull(VMAESTROCOST.MA_COSTO,0)*dbo.FACTIMP.FI_TIPOCAMBIO)*SUM(dbo.FACTIMPDET.FID_CANTEMP),0)  end,
						 round(SUM(isnull(dbo.FACTIMPDET.FID_CANTEMP,0)*isnull(dbo.MAESTRO.EQ_GEN,1)),6),
						 round(SUM(isnull(dbo.FACTIMPDET.FID_CANTEMP,0)*isnull(dbo.MAESTRO.EQ_IMPMX,1)),6)
				FROM         dbo.ARANCEL RIGHT OUTER JOIN
				                      dbo.MAESTRO ON dbo.ARANCEL.AR_CODIGO = dbo.MAESTRO.AR_IMPMX LEFT OUTER JOIN
				                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO RIGHT OUTER JOIN
				                      dbo.FACTIMPDET RIGHT OUTER JOIN
				                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO ON dbo.MAESTRO.MA_CODIGO = dbo.FACTIMPDET.MA_EMPAQUE LEFT OUTER JOIN
					         VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO=VMAESTROCOST.MA_CODIGO
				WHERE     (dbo.FACTIMP.PI_CODIGO = @picodigo)
				GROUP BY dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, 
				                      dbo.MAESTRO.ME_COM, dbo.MAESTRO.EQ_GEN, dbo.MAESTRO.EQ_IMPMX, dbo.MAESTRO.MA_GENERICO, 
				                      dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.AR_EXPFO, dbo.MAESTRO.MA_SEC_IMP, 
				                      dbo.MAESTRO.MA_DEF_TIP,dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.PA_ORIGEN, dbo.MAESTRO.SPI_CODIGO, 
				                      dbo.MAESTRO.PA_PROCEDE, MAESTRO_1.ME_COM, dbo.ARANCEL.ME_CODIGO, dbo. FACTIMPDET.FID_GENERA_EMP, dbo. FACTIMPDET.FI_CODIGO
				HAVING      (dbo.MAESTRO.MA_CODIGO IS NOT NULL) and SUM(dbo.FACTIMPDET.FID_CANTEMP)>0
			end
                        /*else
			begin
			
		
				-- empaque por pestaña
				INSERT INTO TempPedImpDet (PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CTOT_DLS, 
					PID_CANT, ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
					AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
					PA_PROCEDE, ME_GENERICO, ME_ARIMPMX, PID_IMPRIMIR, PID_GENERA_EMP, PID_CANT_DESP, PID_DESCARGABLE, PID_CODIGOFACT, PID_CTOT_MN,
					PID_CAN_GEN, PID_CAN_AR)
			
				SELECT     @picodigo, dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, isnull(max(VMAESTROCOST.MA_COSTO)*SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1),0), 
				                      SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1), dbo.MAESTRO.ME_COM, dbo.MAESTRO.MA_GENERICO, 
				                      dbo.MAESTRO.EQ_GEN, dbo.MAESTRO.EQ_IMPMX, dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.AR_EXPFO, dbo.GetAdvalorem(dbo.MAESTRO.AR_EXPFO, 0, 'G', 0, 0), 
				                      dbo.MAESTRO.MA_SEC_IMP, dbo.MAESTRO.MA_DEF_TIP, dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.PA_ORIGEN, isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.SPI_CODIGO,0)), 
							dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.PA_ORIGEN, 
				                      dbo.MAESTRO.SPI_CODIGO, dbo.MAESTRO.PA_PROCEDE, MAESTRO_1.ME_COM AS ME_GEN, dbo.ARANCEL.ME_CODIGO AS ME_AR, 'N',
				 	        dbo.FACTIMPEMPAQUE.FIE_GENERA_EMP1, sum(dbo.FACTIMPEMPAQUE.FIE_CANT_DESP1), 'S', dbo.FACTIMP.FI_CODIGO, 'PID_CTOT_MN'=case when @PI_USA_TIP_CAMFACT<>'S' then  isnull(max(isnull(VMAESTROCOST.MA_COSTO,0)*@PI_TIP_CAM)*SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1),0)  else isnull(max(isnull(VMAESTROCOST.MA_COSTO,0)*dbo.FACTIMP.FI_TIPOCAMBIO)*SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1),0)  end,
						 round(SUM(isnull(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1,0)*isnull(dbo.MAESTRO.EQ_GEN,1)),6),
						 round(SUM(isnull(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1,0)*isnull(dbo.MAESTRO.EQ_IMPMX,1)),6)
				FROM         dbo.MAESTRO MAESTRO_1 RIGHT OUTER JOIN
				                      dbo.ARANCEL RIGHT OUTER JOIN
				                      dbo.FACTIMPEMPAQUE INNER JOIN
				                      dbo.MAESTRO ON dbo.FACTIMPEMPAQUE.MA_EMP1 = dbo.MAESTRO.MA_CODIGO RIGHT OUTER JOIN
				                      dbo.FACTIMP ON dbo.FACTIMPEMPAQUE.FI_CODIGO = dbo.FACTIMP.FI_CODIGO ON dbo.ARANCEL.AR_CODIGO = dbo.MAESTRO.AR_IMPMX ON 
				                      MAESTRO_1.MA_CODIGO = dbo.MAESTRO.MA_GENERICO LEFT OUTER JOIN
					         VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO=VMAESTROCOST.MA_CODIGO
				WHERE     (dbo.FACTIMP.PI_CODIGO = @picodigo)
				GROUP BY dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, 
				                      dbo.MAESTRO.MA_NAME, dbo.MAESTRO.ME_COM, dbo.MAESTRO.EQ_GEN, dbo.MAESTRO.EQ_IMPMX, dbo.MAESTRO.MA_GENERICO, 
				                      dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.AR_EXPFO, dbo.MAESTRO.MA_SEC_IMP, dbo.MAESTRO.MA_DEF_TIP, dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.PA_ORIGEN, 
				                      dbo.MAESTRO.SPI_CODIGO, dbo.MAESTRO.PA_PROCEDE, MAESTRO_1.ME_COM, dbo.ARANCEL.ME_CODIGO, dbo.FACTIMPEMPAQUE.FIE_GENERA_EMP1, dbo.FACTIMP.FI_CODIGO
				HAVING      (dbo.MAESTRO.MA_CODIGO IS NOT NULL) and SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1)>0
				UNION
				SELECT     @picodigo, dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, isnull(max(VMAESTROCOST.MA_COSTO)*SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1),0), 
				                      SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP2), dbo.MAESTRO.ME_COM, dbo.MAESTRO.MA_GENERICO, 
				                      dbo.MAESTRO.EQ_GEN, dbo.MAESTRO.EQ_IMPMX, dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.AR_EXPFO, dbo.GetAdvalorem(dbo.MAESTRO.AR_EXPFO, 0, 'G', 0, 0),
				                      dbo.MAESTRO.MA_SEC_IMP, dbo.MAESTRO.MA_DEF_TIP, dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.PA_ORIGEN, isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.SPI_CODIGO,0)), dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.PA_ORIGEN, 
				                      dbo.MAESTRO.SPI_CODIGO, dbo.MAESTRO.PA_PROCEDE, MAESTRO_1.ME_COM AS ME_GEN, dbo.ARANCEL.ME_CODIGO AS ME_AR, 'N',
				 	        dbo.FACTIMPEMPAQUE.FIE_GENERA_EMP2, sum(dbo.FACTIMPEMPAQUE.FIE_CANT_DESP2), 'S', dbo.FACTIMP.FI_CODIGO, 'PID_CTOT_MN'=case when @PI_USA_TIP_CAMFACT<>'S' then  isnull(max(isnull(VMAESTROCOST.MA_COSTO,0)*@PI_TIP_CAM)*SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1),0)  else isnull(max(isnull(VMAESTROCOST.MA_COSTO,0)*dbo.FACTIMP.FI_TIPOCAMBIO)*SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1),0)  end,
						 round(SUM(isnull(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP2,0)*isnull(dbo.MAESTRO.EQ_GEN,1)),6),
						 round(SUM(isnull(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP2,0)*isnull(dbo.MAESTRO.EQ_IMPMX,1)),6)
				FROM         dbo.MAESTRO MAESTRO_1 RIGHT OUTER JOIN
				                      dbo.ARANCEL RIGHT OUTER JOIN
				                      dbo.FACTIMPEMPAQUE INNER JOIN
				                      dbo.MAESTRO ON dbo.FACTIMPEMPAQUE.MA_EMP2 = dbo.MAESTRO.MA_CODIGO RIGHT OUTER JOIN
				                      dbo.FACTIMP ON dbo.FACTIMPEMPAQUE.FI_CODIGO = dbo.FACTIMP.FI_CODIGO ON dbo.ARANCEL.AR_CODIGO = dbo.MAESTRO.AR_IMPMX ON 
				                      MAESTRO_1.MA_CODIGO = dbo.MAESTRO.MA_GENERICO LEFT OUTER JOIN
					         VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO=VMAESTROCOST.MA_CODIGO
				WHERE     (dbo.FACTIMP.PI_CODIGO =@picodigo)
				GROUP BY dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, 
				                      dbo.MAESTRO.MA_NAME, dbo.MAESTRO.ME_COM, dbo.MAESTRO.EQ_GEN, dbo.MAESTRO.EQ_IMPMX, dbo.MAESTRO.MA_GENERICO, 
				                      dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.AR_EXPFO, dbo.GetAdvalorem(dbo.MAESTRO.AR_EXPFO, 0, 'G', 0, 0), dbo.FACTIMP.FI_CODIGO,
				                      dbo.MAESTRO.MA_SEC_IMP, dbo.MAESTRO.MA_DEF_TIP, dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.PA_ORIGEN, 
				                      dbo.MAESTRO.SPI_CODIGO, dbo.MAESTRO.PA_PROCEDE, MAESTRO_1.ME_COM, dbo.ARANCEL.ME_CODIGO, dbo.FACTIMPEMPAQUE.FIE_GENERA_EMP2
				HAVING      (dbo.MAESTRO.MA_CODIGO IS NOT NULL) and SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP2)>0
			
                        end*/	
			-- empaque adicional
		
			if exists (SELECT     dbo.FACTIMPEMPAQUEADICIONAL.* FROM         dbo.FACTIMP LEFT OUTER JOIN
			                      dbo.FACTIMPEMPAQUEADICIONAL ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPEMPAQUEADICIONAL.FI_CODIGO
				WHERE     (dbo.FACTIMP.PI_CODIGO = @picodigo))
			begin
				INSERT INTO TempPedImpDet (PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CTOT_DLS, 
					PID_CANT, ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
					AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
					PA_PROCEDE, ME_GENERICO, ME_ARIMPMX, PID_IMPRIMIR, PID_GENERA_EMP, PID_CANT_DESP, PID_DESCARGABLE, PID_CODIGOFACT, PID_CTOT_MN,
					PID_CAN_GEN, PID_CAN_AR)
			
				SELECT     @picodigo, dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, isnull(max(VMAESTROCOST.MA_COSTO)*SUM(dbo.FACTIMPEMPAQUEADICIONAL.FIAD_CANTIDAD),0), 
				                      SUM(dbo.FACTIMPEMPAQUEADICIONAL.FIAD_CANTIDAD), dbo.MAESTRO.ME_COM, dbo.MAESTRO.MA_GENERICO, 
				                      dbo.MAESTRO.EQ_GEN, dbo.MAESTRO.EQ_IMPMX, isnull(dbo.MAESTRO.AR_IMPMX,0), isnull(dbo.MAESTRO.AR_EXPFO,0), dbo.GetAdvalorem(dbo.MAESTRO.AR_EXPFO, 0, 'G', 0, 0), 
				                      dbo.MAESTRO.MA_SEC_IMP, dbo.MAESTRO.MA_DEF_TIP, 0, dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.PA_ORIGEN, 
				                      dbo.MAESTRO.SPI_CODIGO, dbo.MAESTRO.PA_PROCEDE, MAESTRO_1.ME_COM AS ME_GEN, dbo.ARANCEL.ME_CODIGO AS ME_AR, 'N',
				                      dbo.MAESTRO.MA_GENERA_EMP, SUM(dbo.FACTIMPEMPAQUEADICIONAL.FIAD_CANTIDAD), 'S', dbo.FACTIMP.FI_CODIGO,
					        'PID_CTOT_MN'=case when @PI_USA_TIP_CAMFACT<>'S' then  isnull(max(isnull(VMAESTROCOST.MA_COSTO,0)*@PI_TIP_CAM)*SUM(dbo.FACTIMPEMPAQUEADICIONAL.FIAD_CANTIDAD),0)  else isnull(max(isnull(VMAESTROCOST.MA_COSTO,0)*dbo.FACTIMP.FI_TIPOCAMBIO)*SUM(dbo.FACTIMPEMPAQUEADICIONAL.FIAD_CANTIDAD),0)  end,
						 round(SUM(isnull(dbo.FACTIMPEMPAQUEADICIONAL.FIAD_CANTIDAD,0)*isnull(dbo.MAESTRO.EQ_GEN,1)),6),
						 round(SUM(isnull(dbo.FACTIMPEMPAQUEADICIONAL.FIAD_CANTIDAD,0)*isnull(dbo.MAESTRO.EQ_IMPMX,1)),6)

				FROM         dbo.FACTIMPEMPAQUEADICIONAL INNER JOIN
				                      dbo.FACTIMP ON dbo.FACTIMPEMPAQUEADICIONAL.FI_CODIGO = dbo.FACTIMP.FI_CODIGO LEFT OUTER JOIN
				                      dbo.MAESTRO ON dbo.FACTIMPEMPAQUEADICIONAL.MA_CODIGO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
				                      dbo.ARANCEL ON dbo.MAESTRO.AR_IMPMX = dbo.ARANCEL.AR_CODIGO LEFT OUTER JOIN
				                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO LEFT OUTER JOIN
					         VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO=VMAESTROCOST.MA_CODIGO
				WHERE     (dbo.FACTIMP.PI_CODIGO =@picodigo)
				GROUP BY dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, dbo.MAESTRO.ME_COM, 
				                      dbo.MAESTRO.EQ_GEN, dbo.MAESTRO.EQ_IMPMX, dbo.MAESTRO.MA_GENERICO, dbo.FACTIMP.FI_CODIGO,
				                      dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.AR_EXPFO, dbo.MAESTRO.MA_SEC_IMP, dbo.MAESTRO.MA_DEF_TIP, 
				                      dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.PA_ORIGEN, dbo.MAESTRO.SPI_CODIGO, dbo.MAESTRO.PA_PROCEDE, 
				                      MAESTRO_1.ME_COM, dbo.ARANCEL.ME_CODIGO, dbo.MAESTRO.MA_GENERA_EMP
				HAVING      (dbo.MAESTRO.MA_CODIGO IS NOT NULL) and SUM(dbo.FACTIMPEMPAQUEADICIONAL.FIAD_CANTIDAD)>0
		
			end
		end
		else
		begin
                        -- la opción "Manejo empaque en documentos (pestaña o detalle)" ya no se muestra en Configuración del sistema
                        -- se asume que el empaque está incluido siempre en el detalle, y no se lleva por pestaña
                        -- tomado de versión 2.0.0.34 (glr)
                        --if @CF_MAN_EMPAQUE = 'I' /* si lleva el control del empaque en el detalle */
			begin
		
				INSERT INTO TempPedImpDet (PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CTOT_DLS, 
					PID_CANT, ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
					AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
					PA_PROCEDE, ME_GENERICO, ME_ARIMPMX, PID_IMPRIMIR, PID_GENERA_EMP, PID_CANT_DESP, PID_DESCARGABLE, PID_CTOT_MN,
					PID_CAN_GEN, PID_CAN_AR)
			
				SELECT     @picodigo, dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, isnull(max(isnull(VMAESTROCOST.MA_COSTO,0))*SUM(dbo.FACTIMPDET.FID_CANTEMP),0), 
				                      SUM(dbo.FACTIMPDET.FID_CANTEMP), dbo.MAESTRO.ME_COM, dbo.MAESTRO.MA_GENERICO, dbo.MAESTRO.EQ_GEN, 
				                      dbo.MAESTRO.EQ_IMPMX, isnull(dbo.MAESTRO.AR_IMPMX,0), isnull(dbo.MAESTRO.AR_EXPFO,0), dbo.GetAdvalorem(dbo.MAESTRO.AR_EXPFO, 0, 'G', 0, 0), dbo.MAESTRO.MA_SEC_IMP, 
				                      dbo.MAESTRO.MA_DEF_TIP, 0, dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.PA_ORIGEN, dbo.MAESTRO.SPI_CODIGO, 
				                      dbo.MAESTRO.PA_PROCEDE, MAESTRO_1.ME_COM AS ME_GEN, dbo.ARANCEL.ME_CODIGO AS ME_AR, 'N', dbo. FACTIMPDET.FID_GENERA_EMP,
					         sum(dbo. FACTIMPDET.FID_CANT_DESP), 'S', 'PID_CTOT_MN'=case when @PI_USA_TIP_CAMFACT<>'S' then  isnull(max(isnull(VMAESTROCOST.MA_COSTO,0)*@PI_TIP_CAM)*SUM(dbo.FACTIMPDET.FID_CANTEMP),0)  else isnull(max(isnull(VMAESTROCOST.MA_COSTO,0)*dbo.FACTIMP.FI_TIPOCAMBIO)*SUM(dbo.FACTIMPDET.FID_CANTEMP),0)  end,
						 round(SUM(isnull(dbo.FACTIMPDET.FID_CANTEMP,0)*isnull(dbo.MAESTRO.EQ_GEN,1)),6),
						 round(SUM(isnull(dbo.FACTIMPDET.FID_CANTEMP,0)*isnull(dbo.MAESTRO.EQ_IMPMX,1)),6)
				FROM         dbo.ARANCEL RIGHT OUTER JOIN
				                      dbo.MAESTRO ON dbo.ARANCEL.AR_CODIGO = dbo.MAESTRO.AR_IMPMX LEFT OUTER JOIN
				                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO RIGHT OUTER JOIN
				                      dbo.FACTIMPDET RIGHT OUTER JOIN
				                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO ON dbo.MAESTRO.MA_CODIGO = dbo.FACTIMPDET.MA_EMPAQUE LEFT OUTER JOIN
					         VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO=VMAESTROCOST.MA_CODIGO
				WHERE     (dbo.FACTIMP.PI_CODIGO = @picodigo)
				GROUP BY dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, 
				                      dbo.MAESTRO.ME_COM, dbo.MAESTRO.EQ_GEN, dbo.MAESTRO.EQ_IMPMX, dbo.MAESTRO.MA_GENERICO, 
				                      dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.AR_EXPFO, dbo.MAESTRO.MA_SEC_IMP, 
				                      dbo.MAESTRO.MA_DEF_TIP,dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.PA_ORIGEN, dbo.MAESTRO.SPI_CODIGO, 
				                      dbo.MAESTRO.PA_PROCEDE, MAESTRO_1.ME_COM, dbo.ARANCEL.ME_CODIGO, dbo. FACTIMPDET.FID_GENERA_EMP
				HAVING      (dbo.MAESTRO.MA_CODIGO IS NOT NULL) and SUM(dbo.FACTIMPDET.FID_CANTEMP)>0
			end
                        /*else
			begin	
			
		
				-- empaque por pestaña
				INSERT INTO TempPedImpDet (PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CTOT_DLS, 
					PID_CANT, ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
					AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
					PA_PROCEDE, ME_GENERICO, ME_ARIMPMX, PID_IMPRIMIR, PID_GENERA_EMP, PID_CANT_DESP, PID_DESCARGABLE, PID_CTOT_MN,
					PID_CAN_GEN, PID_CAN_AR)
			
				SELECT     @picodigo, dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, isnull(max(VMAESTROCOST.MA_COSTO)*SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1),0), 
				                      SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1), dbo.MAESTRO.ME_COM, dbo.MAESTRO.MA_GENERICO, 
				                      dbo.MAESTRO.EQ_GEN, dbo.MAESTRO.EQ_IMPMX, dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.AR_EXPFO, dbo.GetAdvalorem(dbo.MAESTRO.AR_EXPFO, 0, 'G', 0, 0), 
				                      dbo.MAESTRO.MA_SEC_IMP, dbo.MAESTRO.MA_DEF_TIP, dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.PA_ORIGEN, isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.SPI_CODIGO,0)), dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.PA_ORIGEN, 
				                      dbo.MAESTRO.SPI_CODIGO, dbo.MAESTRO.PA_PROCEDE, MAESTRO_1.ME_COM AS ME_GEN, dbo.ARANCEL.ME_CODIGO AS ME_AR, 'N',
				 	        dbo.FACTIMPEMPAQUE.FIE_GENERA_EMP1, sum(dbo.FACTIMPEMPAQUE.FIE_CANT_DESP1), 'S',
					        'PID_CTOT_MN'=case when @PI_USA_TIP_CAMFACT<>'S' then  isnull(max(isnull(VMAESTROCOST.MA_COSTO,0)*@PI_TIP_CAM)*SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1),0)  else isnull(max(isnull(VMAESTROCOST.MA_COSTO,0)*dbo.FACTIMP.FI_TIPOCAMBIO)*SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1),0)  end,
						 round(SUM(isnull(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1,0)*isnull(dbo.MAESTRO.EQ_GEN,1)),6),
						 round(SUM(isnull(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1,0)*isnull(dbo.MAESTRO.EQ_IMPMX,1)),6)
				FROM         dbo.MAESTRO MAESTRO_1 RIGHT OUTER JOIN
				                      dbo.ARANCEL RIGHT OUTER JOIN
				                      dbo.FACTIMPEMPAQUE INNER JOIN
				                      dbo.MAESTRO ON dbo.FACTIMPEMPAQUE.MA_EMP1 = dbo.MAESTRO.MA_CODIGO RIGHT OUTER JOIN
				                      dbo.FACTIMP ON dbo.FACTIMPEMPAQUE.FI_CODIGO = dbo.FACTIMP.FI_CODIGO ON dbo.ARANCEL.AR_CODIGO = dbo.MAESTRO.AR_IMPMX ON 
				                      MAESTRO_1.MA_CODIGO = dbo.MAESTRO.MA_GENERICO LEFT OUTER JOIN
					         VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO=VMAESTROCOST.MA_CODIGO				        
				WHERE     (dbo.FACTIMP.PI_CODIGO = @picodigo)
				GROUP BY dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, 
				                      dbo.MAESTRO.MA_NAME, dbo.MAESTRO.ME_COM, dbo.MAESTRO.EQ_GEN, dbo.MAESTRO.EQ_IMPMX, dbo.MAESTRO.MA_GENERICO, 
				                      dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.AR_EXPFO, 
				                      dbo.MAESTRO.MA_SEC_IMP, dbo.MAESTRO.MA_DEF_TIP, dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.PA_ORIGEN, 
				                      dbo.MAESTRO.SPI_CODIGO, dbo.MAESTRO.PA_PROCEDE, MAESTRO_1.ME_COM, dbo.ARANCEL.ME_CODIGO, dbo.FACTIMPEMPAQUE.FIE_GENERA_EMP1
				HAVING      (dbo.MAESTRO.MA_CODIGO IS NOT NULL) and SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1)>0
				UNION
				SELECT     @picodigo, dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, isnull(max(VMAESTROCOST.MA_COSTO)*SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1),0), 
				                      SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP2), dbo.MAESTRO.ME_COM, dbo.MAESTRO.MA_GENERICO, 
				                      dbo.MAESTRO.EQ_GEN, dbo.MAESTRO.EQ_IMPMX, dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.AR_EXPFO, dbo.GetAdvalorem(dbo.MAESTRO.AR_EXPFO, 0, 'G', 0, 0), 
				                      dbo.MAESTRO.MA_SEC_IMP, dbo.MAESTRO.MA_DEF_TIP, dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.PA_ORIGEN, isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.SPI_CODIGO,0)), dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.PA_ORIGEN, 
				                      dbo.MAESTRO.SPI_CODIGO, dbo.MAESTRO.PA_PROCEDE, MAESTRO_1.ME_COM AS ME_GEN, dbo.ARANCEL.ME_CODIGO AS ME_AR, 'N',
				 	        dbo.FACTIMPEMPAQUE.FIE_GENERA_EMP2, sum(dbo.FACTIMPEMPAQUE.FIE_CANT_DESP2), 'S',
					        'PID_CTOT_MN'=case when @PI_USA_TIP_CAMFACT<>'S' then  isnull(max(isnull(VMAESTROCOST.MA_COSTO,0)*@PI_TIP_CAM)*SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1),0)  else isnull(max(isnull(VMAESTROCOST.MA_COSTO,0)*dbo.FACTIMP.FI_TIPOCAMBIO)*SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1),0)  end,
						 round(SUM(isnull(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP2,0)*isnull(dbo.MAESTRO.EQ_GEN,1)),6),
						 round(SUM(isnull(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP2,0)*isnull(dbo.MAESTRO.EQ_IMPMX,1)),6)
				FROM         dbo.MAESTRO MAESTRO_1 RIGHT OUTER JOIN
				                      dbo.ARANCEL RIGHT OUTER JOIN
				                      dbo.FACTIMPEMPAQUE INNER JOIN
				                      dbo.MAESTRO ON dbo.FACTIMPEMPAQUE.MA_EMP2 = dbo.MAESTRO.MA_CODIGO RIGHT OUTER JOIN
				                      dbo.FACTIMP ON dbo.FACTIMPEMPAQUE.FI_CODIGO = dbo.FACTIMP.FI_CODIGO ON dbo.ARANCEL.AR_CODIGO = dbo.MAESTRO.AR_IMPMX ON 
				                      MAESTRO_1.MA_CODIGO = dbo.MAESTRO.MA_GENERICO LEFT OUTER JOIN
					         VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO=VMAESTROCOST.MA_CODIGO
				WHERE     (dbo.FACTIMP.PI_CODIGO =@picodigo)
				GROUP BY dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, 
				                      dbo.MAESTRO.MA_NAME, dbo.MAESTRO.ME_COM, dbo.MAESTRO.EQ_GEN, dbo.MAESTRO.EQ_IMPMX, dbo.MAESTRO.MA_GENERICO, 
				                      dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.AR_EXPFO, 
				                      dbo.MAESTRO.MA_SEC_IMP, dbo.MAESTRO.MA_DEF_TIP, dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.PA_ORIGEN, 
				                      dbo.MAESTRO.SPI_CODIGO, dbo.MAESTRO.PA_PROCEDE, MAESTRO_1.ME_COM, dbo.ARANCEL.ME_CODIGO, dbo.FACTIMPEMPAQUE.FIE_GENERA_EMP2
				HAVING      (dbo.MAESTRO.MA_CODIGO IS NOT NULL) and SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP2)>0
			
                        end*/	
			-- empaque adicional
		
			if exists (SELECT     dbo.FACTIMPEMPAQUEADICIONAL.* FROM         dbo.FACTIMP LEFT OUTER JOIN
			                      dbo.FACTIMPEMPAQUEADICIONAL ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPEMPAQUEADICIONAL.FI_CODIGO
				WHERE     (dbo.FACTIMP.PI_CODIGO = @picodigo))
			begin
				INSERT INTO TempPedImpDet (PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CTOT_DLS, 
					PID_CANT, ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
					AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
					PA_PROCEDE, ME_GENERICO, ME_ARIMPMX, PID_IMPRIMIR, PID_GENERA_EMP, PID_CANT_DESP, PID_DESCARGABLE, PID_CTOT_MN,
					PID_CAN_GEN, PID_CAN_AR)
			
				SELECT     @picodigo, dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, isnull(max(VMAESTROCOST.MA_COSTO)*SUM(dbo.FACTIMPEMPAQUEADICIONAL.FIAD_CANTIDAD),0), 
				                      SUM(dbo.FACTIMPEMPAQUEADICIONAL.FIAD_CANTIDAD), dbo.MAESTRO.ME_COM, dbo.MAESTRO.MA_GENERICO, 
				                      dbo.MAESTRO.EQ_GEN, dbo.MAESTRO.EQ_IMPMX, isnull(dbo.MAESTRO.AR_IMPMX,0), isnull(dbo.MAESTRO.AR_EXPFO,0), dbo.GetAdvalorem(dbo.MAESTRO.AR_EXPFO, 0, 'G', 0, 0), 
				                      dbo.MAESTRO.MA_SEC_IMP, dbo.MAESTRO.MA_DEF_TIP, 0, dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.PA_ORIGEN, 
				                      dbo.MAESTRO.SPI_CODIGO, dbo.MAESTRO.PA_PROCEDE, MAESTRO_1.ME_COM AS ME_GEN, dbo.ARANCEL.ME_CODIGO AS ME_AR, 'N',
				                      dbo.MAESTRO.MA_GENERA_EMP, SUM(dbo.FACTIMPEMPAQUEADICIONAL.FIAD_CANTIDAD), 'S',
						'PID_CTOT_MN'=case when @PI_USA_TIP_CAMFACT<>'S' then  isnull(max(isnull(VMAESTROCOST.MA_COSTO,0)*@PI_TIP_CAM)*SUM(dbo.FACTIMPEMPAQUEADICIONAL.FIAD_CANTIDAD),0)  else isnull(max(isnull(VMAESTROCOST.MA_COSTO,0)*dbo.FACTIMP.FI_TIPOCAMBIO)*SUM(dbo.FACTIMPEMPAQUEADICIONAL.FIAD_CANTIDAD),0)  end,
						 round(SUM(isnull(dbo.FACTIMPEMPAQUEADICIONAL.FIAD_CANTIDAD,0)*isnull(dbo.MAESTRO.EQ_GEN,1)),6),
						 round(SUM(isnull(dbo.FACTIMPEMPAQUEADICIONAL.FIAD_CANTIDAD,0)*isnull(dbo.MAESTRO.EQ_IMPMX,1)),6)
				FROM         dbo.FACTIMPEMPAQUEADICIONAL INNER JOIN
				                      dbo.FACTIMP ON dbo.FACTIMPEMPAQUEADICIONAL.FI_CODIGO = dbo.FACTIMP.FI_CODIGO LEFT OUTER JOIN
				                      dbo.MAESTRO ON dbo.FACTIMPEMPAQUEADICIONAL.MA_CODIGO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
				                      dbo.ARANCEL ON dbo.MAESTRO.AR_IMPMX = dbo.ARANCEL.AR_CODIGO LEFT OUTER JOIN
				                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO LEFT OUTER JOIN
					         VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO=VMAESTROCOST.MA_CODIGO
				WHERE     (dbo.FACTIMP.PI_CODIGO =@picodigo)
				GROUP BY dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, dbo.MAESTRO.ME_COM, 
				                      dbo.MAESTRO.EQ_GEN, dbo.MAESTRO.EQ_IMPMX, dbo.MAESTRO.MA_GENERICO, 
				                      dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.AR_EXPFO, dbo.MAESTRO.MA_SEC_IMP, dbo.MAESTRO.MA_DEF_TIP, 
				                      dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.PA_ORIGEN, dbo.MAESTRO.SPI_CODIGO, dbo.MAESTRO.PA_PROCEDE, 
				                      MAESTRO_1.ME_COM, dbo.ARANCEL.ME_CODIGO, dbo.MAESTRO.MA_GENERA_EMP
				HAVING      (dbo.MAESTRO.MA_CODIGO IS NOT NULL) and SUM(dbo.FACTIMPEMPAQUEADICIONAL.FIAD_CANTIDAD)>0
		
			end
	
		end
	end
	else	-- aunque no controle el desperdicio en el detalle del pedimento, debe de controlar los empaque que se retornan, ej. carretes, bandejas, etc.
	begin
		IF (SELECT PICF_SAAIDETDIVFACT FROM PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='S'
		begin
                        -- la opción "Manejo empaque en documentos (pestaña o detalle)" ya no se muestra en Configuración del sistema
                        -- se asume que el empaque está incluido siempre en el detalle, y no se lleva por pestaña
                        -- tomado de versión 2.0.0.34 (glr)
                        --if @CF_MAN_EMPAQUE = 'I' /* si lleva el control del empaque en el detalle */
                        begin
		
				INSERT INTO TempPedImpDet (PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CTOT_DLS, 
					PID_CANT, ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
					AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
					PA_PROCEDE, ME_GENERICO, ME_ARIMPMX, PID_IMPRIMIR, PID_GENERA_EMP, PID_CANT_DESP, PID_DESCARGABLE, PID_CODIGOFACT, PID_CTOT_MN,
					PID_CAN_GEN, PID_CAN_AR)
			
				SELECT     @picodigo, dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, isnull(max(isnull(VMAESTROCOST.MA_COSTO,0))*SUM(dbo.FACTIMPDET.FID_CANTEMP),0), 
				                      SUM(dbo.FACTIMPDET.FID_CANTEMP), dbo.MAESTRO.ME_COM, dbo.MAESTRO.MA_GENERICO, dbo.MAESTRO.EQ_GEN, 
				                      dbo.MAESTRO.EQ_IMPMX, isnull(dbo.MAESTRO.AR_IMPMX,0), isnull(dbo.MAESTRO.AR_EXPFO,0), dbo.GetAdvalorem(dbo.MAESTRO.AR_EXPFO, 0, 'G', 0, 0), dbo.MAESTRO.MA_SEC_IMP, 
				                      dbo.MAESTRO.MA_DEF_TIP, 0, dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.PA_ORIGEN, dbo.MAESTRO.SPI_CODIGO, 
				                      dbo.MAESTRO.PA_PROCEDE, MAESTRO_1.ME_COM AS ME_GEN, dbo.ARANCEL.ME_CODIGO AS ME_AR, 'N', dbo. FACTIMPDET.FID_GENERA_EMP,
					         sum(dbo. FACTIMPDET.FID_CANT_DESP), 'S', dbo. FACTIMPDET.FI_CODIGO,
						'PID_CTOT_MN'=case when @PI_USA_TIP_CAMFACT<>'S' then  isnull(max(isnull(VMAESTROCOST.MA_COSTO,0)*@PI_TIP_CAM)*SUM(dbo.FACTIMPDET.FID_CANTEMP),0)  else isnull(max(isnull(VMAESTROCOST.MA_COSTO,0)*dbo.FACTIMP.FI_TIPOCAMBIO)*SUM(dbo.FACTIMPDET.FID_CANTEMP),0)  end,
						 round(SUM(isnull(dbo.FACTIMPDET.FID_CANTEMP,0)*isnull(dbo.MAESTRO.EQ_GEN,1)),6),
						 round(SUM(isnull(dbo.FACTIMPDET.FID_CANTEMP,0)*isnull(dbo.MAESTRO.EQ_IMPMX,1)),6)
				FROM         dbo.ARANCEL RIGHT OUTER JOIN
				                      dbo.MAESTRO ON dbo.ARANCEL.AR_CODIGO = dbo.MAESTRO.AR_IMPMX LEFT OUTER JOIN
				                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO RIGHT OUTER JOIN
				                      dbo.FACTIMPDET RIGHT OUTER JOIN
				                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO ON dbo.MAESTRO.MA_CODIGO = dbo.FACTIMPDET.MA_EMPAQUE LEFT OUTER JOIN
					         VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO=VMAESTROCOST.MA_CODIGO
				WHERE     (dbo.FACTIMP.PI_CODIGO = @picodigo) and dbo.MAESTRO.MA_GENERA_EMP in ('R','T')
				GROUP BY dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, 
				                      dbo.MAESTRO.ME_COM, dbo.MAESTRO.EQ_GEN, dbo.MAESTRO.EQ_IMPMX, dbo.MAESTRO.MA_GENERICO, 
				                      dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.AR_EXPFO, dbo.MAESTRO.MA_SEC_IMP, 
				                      dbo.MAESTRO.MA_DEF_TIP,dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.PA_ORIGEN, dbo.MAESTRO.SPI_CODIGO, 
				                      dbo.MAESTRO.PA_PROCEDE, MAESTRO_1.ME_COM, dbo.ARANCEL.ME_CODIGO, dbo. FACTIMPDET.FID_GENERA_EMP, dbo. FACTIMPDET.FI_CODIGO
				HAVING      (dbo.MAESTRO.MA_CODIGO IS NOT NULL) and SUM(dbo.FACTIMPDET.FID_CANTEMP)>0 
			end
                        /*else
			begin	
			
		
				-- empaque por pestaa
				INSERT INTO TempPedImpDet (PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CTOT_DLS, 
					PID_CANT, ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
					AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
					PA_PROCEDE, ME_GENERICO, ME_ARIMPMX, PID_IMPRIMIR, PID_GENERA_EMP, PID_CANT_DESP, PID_DESCARGABLE, PID_CODIGOFACT, PID_CTOT_MN,
					PID_CAN_GEN, PID_CAN_AR)
			
				SELECT     @picodigo, dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, isnull(max(VMAESTROCOST.MA_COSTO)*SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1),0), 
				                      SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1), dbo.MAESTRO.ME_COM, dbo.MAESTRO.MA_GENERICO, 
				                      dbo.MAESTRO.EQ_GEN, dbo.MAESTRO.EQ_IMPMX, dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.AR_EXPFO, dbo.GetAdvalorem(dbo.MAESTRO.AR_EXPFO, 0, 'G', 0, 0), 
				                      dbo.MAESTRO.MA_SEC_IMP, dbo.MAESTRO.MA_DEF_TIP, dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.PA_ORIGEN, isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.SPI_CODIGO,0)),
							 dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.PA_ORIGEN, 
				                      dbo.MAESTRO.SPI_CODIGO, dbo.MAESTRO.PA_PROCEDE, MAESTRO_1.ME_COM AS ME_GEN, dbo.ARANCEL.ME_CODIGO AS ME_AR, 'N',
				 	        dbo.FACTIMPEMPAQUE.FIE_GENERA_EMP1, sum(dbo.FACTIMPEMPAQUE.FIE_CANT_DESP1), 'S', dbo.FACTIMP.FI_CODIGO,
					        'PID_CTOT_MN'=case when @PI_USA_TIP_CAMFACT<>'S' then  isnull(max(isnull(VMAESTROCOST.MA_COSTO,0)*@PI_TIP_CAM)*SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1),0)  else isnull(max(isnull(VMAESTROCOST.MA_COSTO,0)*dbo.FACTIMP.FI_TIPOCAMBIO)*SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1),0)  end,
						 round(SUM(isnull(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1,0)*isnull(dbo.MAESTRO.EQ_GEN,1)),6),
						 round(SUM(isnull(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1,0)*isnull(dbo.MAESTRO.EQ_IMPMX,1)),6)
				FROM         dbo.MAESTRO MAESTRO_1 RIGHT OUTER JOIN
				                      dbo.ARANCEL RIGHT OUTER JOIN
				                      dbo.FACTIMPEMPAQUE INNER JOIN
				                      dbo.MAESTRO ON dbo.FACTIMPEMPAQUE.MA_EMP1 = dbo.MAESTRO.MA_CODIGO RIGHT OUTER JOIN
				                      dbo.FACTIMP ON dbo.FACTIMPEMPAQUE.FI_CODIGO = dbo.FACTIMP.FI_CODIGO ON dbo.ARANCEL.AR_CODIGO = dbo.MAESTRO.AR_IMPMX ON 
				                      MAESTRO_1.MA_CODIGO = dbo.MAESTRO.MA_GENERICO LEFT OUTER JOIN
					         VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO=VMAESTROCOST.MA_CODIGO
				WHERE     (dbo.FACTIMP.PI_CODIGO = @picodigo) and dbo.MAESTRO.MA_GENERA_EMP in ('R','T')
				GROUP BY dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, 
				                      dbo.MAESTRO.MA_NAME, dbo.MAESTRO.ME_COM, dbo.MAESTRO.EQ_GEN, dbo.MAESTRO.EQ_IMPMX, dbo.MAESTRO.MA_GENERICO, 
				                      dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.AR_EXPFO, 
				                      dbo.MAESTRO.MA_SEC_IMP, dbo.MAESTRO.MA_DEF_TIP, dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.PA_ORIGEN, 
				                      dbo.MAESTRO.SPI_CODIGO, dbo.MAESTRO.PA_PROCEDE, MAESTRO_1.ME_COM, dbo.ARANCEL.ME_CODIGO, dbo.FACTIMPEMPAQUE.FIE_GENERA_EMP1, dbo.FACTIMP.FI_CODIGO
				HAVING      (dbo.MAESTRO.MA_CODIGO IS NOT NULL) and SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1)>0
				UNION
				SELECT     @picodigo, dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, isnull(max(VMAESTROCOST.MA_COSTO)*SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1),0), 
				                      SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP2), dbo.MAESTRO.ME_COM, dbo.MAESTRO.MA_GENERICO, 
				                      dbo.MAESTRO.EQ_GEN, dbo.MAESTRO.EQ_IMPMX, dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.AR_EXPFO, dbo.GetAdvalorem(dbo.MAESTRO.AR_EXPFO, 0, 'G', 0, 0), 
				                      dbo.MAESTRO.MA_SEC_IMP, dbo.MAESTRO.MA_DEF_TIP, dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.PA_ORIGEN, isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.SPI_CODIGO,0)), dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.PA_ORIGEN, 
				                      dbo.MAESTRO.SPI_CODIGO, dbo.MAESTRO.PA_PROCEDE, MAESTRO_1.ME_COM AS ME_GEN, dbo.ARANCEL.ME_CODIGO AS ME_AR, 'N',
				 	        dbo.FACTIMPEMPAQUE.FIE_GENERA_EMP2, sum(dbo.FACTIMPEMPAQUE.FIE_CANT_DESP2), 'S', dbo.FACTIMP.FI_CODIGO,
					        'PID_CTOT_MN'=case when @PI_USA_TIP_CAMFACT<>'S' then  isnull(max(isnull(VMAESTROCOST.MA_COSTO,0)*@PI_TIP_CAM)*SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1),0)  else isnull(max(isnull(VMAESTROCOST.MA_COSTO,0)*dbo.FACTIMP.FI_TIPOCAMBIO)*SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1),0)  end,
						 round(SUM(isnull(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP2,0)*isnull(dbo.MAESTRO.EQ_GEN,1)),6),
						 round(SUM(isnull(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP2,0)*isnull(dbo.MAESTRO.EQ_IMPMX,1)),6)
				FROM         dbo.MAESTRO MAESTRO_1 RIGHT OUTER JOIN
				                      dbo.ARANCEL RIGHT OUTER JOIN
				                      dbo.FACTIMPEMPAQUE INNER JOIN
				                      dbo.MAESTRO ON dbo.FACTIMPEMPAQUE.MA_EMP2 = dbo.MAESTRO.MA_CODIGO RIGHT OUTER JOIN
				                      dbo.FACTIMP ON dbo.FACTIMPEMPAQUE.FI_CODIGO = dbo.FACTIMP.FI_CODIGO ON dbo.ARANCEL.AR_CODIGO = dbo.MAESTRO.AR_IMPMX ON 
				                      MAESTRO_1.MA_CODIGO = dbo.MAESTRO.MA_GENERICO LEFT OUTER JOIN
					         VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO=VMAESTROCOST.MA_CODIGO
				WHERE     (dbo.FACTIMP.PI_CODIGO =@picodigo) and dbo.MAESTRO.MA_GENERA_EMP in ('R','T')
				GROUP BY dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, 
				                      dbo.MAESTRO.MA_NAME, dbo.MAESTRO.ME_COM, dbo.MAESTRO.EQ_GEN, dbo.MAESTRO.EQ_IMPMX, dbo.MAESTRO.MA_GENERICO, 
				                      dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.AR_EXPFO, dbo.FACTIMP.FI_CODIGO,
				                      dbo.MAESTRO.MA_SEC_IMP, dbo.MAESTRO.MA_DEF_TIP, dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.PA_ORIGEN, 
				                      dbo.MAESTRO.SPI_CODIGO, dbo.MAESTRO.PA_PROCEDE, MAESTRO_1.ME_COM, dbo.ARANCEL.ME_CODIGO, dbo.FACTIMPEMPAQUE.FIE_GENERA_EMP2
				HAVING      (dbo.MAESTRO.MA_CODIGO IS NOT NULL) and SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP2)>0
			
                        end*/
			-- empaque adicional
		
			if exists (SELECT     dbo.FACTIMPEMPAQUEADICIONAL.* FROM         dbo.FACTIMP LEFT OUTER JOIN
			                      dbo.FACTIMPEMPAQUEADICIONAL ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPEMPAQUEADICIONAL.FI_CODIGO
				WHERE     (dbo.FACTIMP.PI_CODIGO = @picodigo))
			begin
				INSERT INTO TempPedImpDet (PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CTOT_DLS, 
					PID_CANT, ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
					AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
					PA_PROCEDE, ME_GENERICO, ME_ARIMPMX, PID_IMPRIMIR, PID_GENERA_EMP, PID_CANT_DESP, PID_DESCARGABLE, PID_CODIGOFACT, PID_CTOT_MN,
					PID_CAN_GEN, PID_CAN_AR)
			
				SELECT     @picodigo, dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, isnull(max(VMAESTROCOST.MA_COSTO)*SUM(dbo.FACTIMPEMPAQUEADICIONAL.FIAD_CANTIDAD),0), 
				                      SUM(dbo.FACTIMPEMPAQUEADICIONAL.FIAD_CANTIDAD), dbo.MAESTRO.ME_COM, dbo.MAESTRO.MA_GENERICO, 
				                      dbo.MAESTRO.EQ_GEN, dbo.MAESTRO.EQ_IMPMX, isnull(dbo.MAESTRO.AR_IMPMX,0), isnull(dbo.MAESTRO.AR_EXPFO,0), dbo.GetAdvalorem(dbo.MAESTRO.AR_EXPFO, 0, 'G', 0, 0), 
				                      dbo.MAESTRO.MA_SEC_IMP, dbo.MAESTRO.MA_DEF_TIP, 0, dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.PA_ORIGEN, 
				                      dbo.MAESTRO.SPI_CODIGO, dbo.MAESTRO.PA_PROCEDE, MAESTRO_1.ME_COM AS ME_GEN, dbo.ARANCEL.ME_CODIGO AS ME_AR, 'N',
				                      dbo.MAESTRO.MA_GENERA_EMP, SUM(dbo.FACTIMPEMPAQUEADICIONAL.FIAD_CANTIDAD), 'S', dbo.FACTIMP.FI_CODIGO, 					        'PID_CTOT_MN'=case when @PI_USA_TIP_CAMFACT<>'S' then  isnull(max(isnull(VMAESTROCOST.MA_COSTO,0)*@PI_TIP_CAM)*SUM(dbo.FACTIMPEMPAQUEADICIONAL.FIAD_CANTIDAD),0)  else isnull(max(isnull(VMAESTROCOST.MA_COSTO,0)*dbo.FACTIMP.FI_TIPOCAMBIO)*SUM(dbo.FACTIMPEMPAQUEADICIONAL.FIAD_CANTIDAD),0)  end,
						 round(SUM(isnull(dbo.FACTIMPEMPAQUEADICIONAL.FIAD_CANTIDAD,0)*isnull(dbo.MAESTRO.EQ_GEN,1)),6),
						 round(SUM(isnull(dbo.FACTIMPEMPAQUEADICIONAL.FIAD_CANTIDAD,0)*isnull(dbo.MAESTRO.EQ_IMPMX,1)),6)
				FROM         dbo.FACTIMPEMPAQUEADICIONAL INNER JOIN
				                      dbo.FACTIMP ON dbo.FACTIMPEMPAQUEADICIONAL.FI_CODIGO = dbo.FACTIMP.FI_CODIGO LEFT OUTER JOIN
				                      dbo.MAESTRO ON dbo.FACTIMPEMPAQUEADICIONAL.MA_CODIGO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
				                      dbo.ARANCEL ON dbo.MAESTRO.AR_IMPMX = dbo.ARANCEL.AR_CODIGO LEFT OUTER JOIN
				                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO LEFT OUTER JOIN
					         VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO=VMAESTROCOST.MA_CODIGO
				WHERE     (dbo.FACTIMP.PI_CODIGO =@picodigo) and dbo.MAESTRO.MA_GENERA_EMP in ('R','T')
				GROUP BY dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, dbo.MAESTRO.ME_COM, 
				                      dbo.MAESTRO.EQ_GEN, dbo.MAESTRO.EQ_IMPMX, dbo.MAESTRO.MA_GENERICO, dbo.FACTIMP.FI_CODIGO,
				                      dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.AR_EXPFO, dbo.MAESTRO.MA_SEC_IMP, dbo.MAESTRO.MA_DEF_TIP, 
				                      dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.PA_ORIGEN, dbo.MAESTRO.SPI_CODIGO, dbo.MAESTRO.PA_PROCEDE, 
				                      MAESTRO_1.ME_COM, dbo.ARANCEL.ME_CODIGO, dbo.MAESTRO.MA_GENERA_EMP
				HAVING      (dbo.MAESTRO.MA_CODIGO IS NOT NULL) and SUM(dbo.FACTIMPEMPAQUEADICIONAL.FIAD_CANTIDAD)>0
		
			end
		end
		else
		begin
	
                        -- la opción "Manejo empaque en documentos (pestaña o detalle)" ya no se muestra en Configuración del sistema
                        -- se asume que el empaque está incluido siempre en el detalle, y no se lleva por pestaña
                        -- tomado de versión 2.0.0.34 (glr)
                        --if @CF_MAN_EMPAQUE = 'I' /* si lleva el control del empaque en el detalle */
			begin
		
				INSERT INTO TempPedImpDet (PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CTOT_DLS, 
					PID_CANT, ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
					AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
					PA_PROCEDE, ME_GENERICO, ME_ARIMPMX, PID_IMPRIMIR, PID_GENERA_EMP, PID_CANT_DESP, PID_DESCARGABLE, PID_CTOT_MN,
					PID_CAN_GEN, PID_CAN_AR)
			
				SELECT     @picodigo, dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, isnull(max(isnull(VMAESTROCOST.MA_COSTO,0))*SUM(dbo.FACTIMPDET.FID_CANTEMP),0), 
				                      SUM(dbo.FACTIMPDET.FID_CANTEMP), dbo.MAESTRO.ME_COM, dbo.MAESTRO.MA_GENERICO, dbo.MAESTRO.EQ_GEN, 
				                      dbo.MAESTRO.EQ_IMPMX, isnull(dbo.MAESTRO.AR_IMPMX,0), isnull(dbo.MAESTRO.AR_EXPFO,0), dbo.GetAdvalorem(dbo.MAESTRO.AR_EXPFO, 0, 'G', 0, 0), dbo.MAESTRO.MA_SEC_IMP, 
				                      dbo.MAESTRO.MA_DEF_TIP, 0, dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.PA_ORIGEN, dbo.MAESTRO.SPI_CODIGO, 
				                      dbo.MAESTRO.PA_PROCEDE, MAESTRO_1.ME_COM AS ME_GEN, dbo.ARANCEL.ME_CODIGO AS ME_AR, 'N', dbo. FACTIMPDET.FID_GENERA_EMP,
					         sum(dbo. FACTIMPDET.FID_CANT_DESP), 'S',
					        'PID_CTOT_MN'=case when @PI_USA_TIP_CAMFACT<>'S' then  isnull(max(isnull(VMAESTROCOST.MA_COSTO,0)*@PI_TIP_CAM)*SUM(dbo.FACTIMPDET.FID_CANTEMP),0)  else isnull(max(isnull(VMAESTROCOST.MA_COSTO,0)*dbo.FACTIMP.FI_TIPOCAMBIO)*SUM(dbo.FACTIMPDET.FID_CANTEMP),0)  end,
						 round(SUM(isnull(dbo.FACTIMPDET.FID_CANTEMP,0)*isnull(dbo.MAESTRO.EQ_GEN,1)),6),
						 round(SUM(isnull(dbo.FACTIMPDET.FID_CANTEMP,0)*isnull(dbo.MAESTRO.EQ_IMPMX,1)),6)
				FROM         dbo.ARANCEL RIGHT OUTER JOIN
				                      dbo.MAESTRO ON dbo.ARANCEL.AR_CODIGO = dbo.MAESTRO.AR_IMPMX LEFT OUTER JOIN
				                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO RIGHT OUTER JOIN
				                      dbo.FACTIMPDET RIGHT OUTER JOIN
				                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO ON dbo.MAESTRO.MA_CODIGO = dbo.FACTIMPDET.MA_EMPAQUE LEFT OUTER JOIN
					         VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO=VMAESTROCOST.MA_CODIGO
				WHERE     (dbo.FACTIMP.PI_CODIGO = @picodigo) and dbo.MAESTRO.MA_GENERA_EMP in ('R','T')
				GROUP BY dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, 
				                      dbo.MAESTRO.ME_COM, dbo.MAESTRO.EQ_GEN, dbo.MAESTRO.EQ_IMPMX, dbo.MAESTRO.MA_GENERICO, 
				                      dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.AR_EXPFO, dbo.MAESTRO.MA_SEC_IMP, 
				                      dbo.MAESTRO.MA_DEF_TIP,dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.PA_ORIGEN, dbo.MAESTRO.SPI_CODIGO, 
				                      dbo.MAESTRO.PA_PROCEDE, MAESTRO_1.ME_COM, dbo.ARANCEL.ME_CODIGO, dbo. FACTIMPDET.FID_GENERA_EMP
				HAVING      (dbo.MAESTRO.MA_CODIGO IS NOT NULL) and SUM(dbo.FACTIMPDET.FID_CANTEMP)>0
			end
                        /*else
			begin	
			
		
				-- empaque por pestaña
				INSERT INTO TempPedImpDet (PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CTOT_DLS, 
					PID_CANT, ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
					AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
					PA_PROCEDE, ME_GENERICO, ME_ARIMPMX, PID_IMPRIMIR, PID_GENERA_EMP, PID_CANT_DESP, PID_DESCARGABLE, PID_CTOT_MN,
					PID_CAN_GEN, PID_CAN_AR)
			
				SELECT     @picodigo, dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, isnull(max(VMAESTROCOST.MA_COSTO)*SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1),0), 
				                      SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1), dbo.MAESTRO.ME_COM, dbo.MAESTRO.MA_GENERICO, 
				                      dbo.MAESTRO.EQ_GEN, dbo.MAESTRO.EQ_IMPMX, dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.AR_EXPFO, dbo.GetAdvalorem(dbo.MAESTRO.AR_EXPFO, 0, 'G', 0, 0), 
				                      dbo.MAESTRO.MA_SEC_IMP, dbo.MAESTRO.MA_DEF_TIP, dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.PA_ORIGEN, isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.SPI_CODIGO,0)),
							dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.PA_ORIGEN, 
				                      dbo.MAESTRO.SPI_CODIGO, dbo.MAESTRO.PA_PROCEDE, MAESTRO_1.ME_COM AS ME_GEN, dbo.ARANCEL.ME_CODIGO AS ME_AR, 'N',
				 	        dbo.FACTIMPEMPAQUE.FIE_GENERA_EMP1, sum(dbo.FACTIMPEMPAQUE.FIE_CANT_DESP1), 'S',
					        'PID_CTOT_MN'=case when @PI_USA_TIP_CAMFACT<>'S' then  isnull(max(isnull(VMAESTROCOST.MA_COSTO,0)*@PI_TIP_CAM)*SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1),0)  else isnull(max(isnull(VMAESTROCOST.MA_COSTO,0)*dbo.FACTIMP.FI_TIPOCAMBIO)*SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1),0)  end,
						 round(SUM(isnull(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1,0)*isnull(dbo.MAESTRO.EQ_GEN,1)),6),
						 round(SUM(isnull(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1,0)*isnull(dbo.MAESTRO.EQ_IMPMX,1)),6)
				FROM         dbo.MAESTRO MAESTRO_1 RIGHT OUTER JOIN
				                      dbo.ARANCEL RIGHT OUTER JOIN
				                      dbo.FACTIMPEMPAQUE INNER JOIN
				                      dbo.MAESTRO ON dbo.FACTIMPEMPAQUE.MA_EMP1 = dbo.MAESTRO.MA_CODIGO RIGHT OUTER JOIN
				                      dbo.FACTIMP ON dbo.FACTIMPEMPAQUE.FI_CODIGO = dbo.FACTIMP.FI_CODIGO ON dbo.ARANCEL.AR_CODIGO = dbo.MAESTRO.AR_IMPMX ON 
				                      MAESTRO_1.MA_CODIGO = dbo.MAESTRO.MA_GENERICO LEFT OUTER JOIN
					         VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO=VMAESTROCOST.MA_CODIGO
				WHERE     (dbo.FACTIMP.PI_CODIGO = @picodigo) and dbo.MAESTRO.MA_GENERA_EMP in ('R','T')
				GROUP BY dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, 
				                      dbo.MAESTRO.MA_NAME, dbo.MAESTRO.ME_COM, dbo.MAESTRO.EQ_GEN, dbo.MAESTRO.EQ_IMPMX, dbo.MAESTRO.MA_GENERICO, 
				                      dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.AR_EXPFO, 
				                      dbo.MAESTRO.MA_SEC_IMP, dbo.MAESTRO.MA_DEF_TIP, dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.PA_ORIGEN, 
				                      dbo.MAESTRO.SPI_CODIGO, dbo.MAESTRO.PA_PROCEDE, MAESTRO_1.ME_COM, dbo.ARANCEL.ME_CODIGO, dbo.FACTIMPEMPAQUE.FIE_GENERA_EMP1
				HAVING      (dbo.MAESTRO.MA_CODIGO IS NOT NULL) and SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1)>0
				UNION
				SELECT     @picodigo, dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, isnull(max(VMAESTROCOST.MA_COSTO)*SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1),0), 
				                      SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP2), dbo.MAESTRO.ME_COM, dbo.MAESTRO.MA_GENERICO, 
				                      dbo.MAESTRO.EQ_GEN, dbo.MAESTRO.EQ_IMPMX, dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.AR_EXPFO, dbo.GetAdvalorem(dbo.MAESTRO.AR_EXPFO, 0, 'G', 0, 0), 
				                      dbo.MAESTRO.MA_SEC_IMP, dbo.MAESTRO.MA_DEF_TIP, dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.PA_ORIGEN, isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.SPI_CODIGO,0)), dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.PA_ORIGEN, 
				                      dbo.MAESTRO.SPI_CODIGO, dbo.MAESTRO.PA_PROCEDE, MAESTRO_1.ME_COM AS ME_GEN, dbo.ARANCEL.ME_CODIGO AS ME_AR, 'N',
				 	        dbo.FACTIMPEMPAQUE.FIE_GENERA_EMP2, sum(dbo.FACTIMPEMPAQUE.FIE_CANT_DESP2), 'S',
					        'PID_CTOT_MN'=case when @PI_USA_TIP_CAMFACT<>'S' then  isnull(max(isnull(VMAESTROCOST.MA_COSTO,0)*@PI_TIP_CAM)*SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1),0)  else isnull(max(isnull(VMAESTROCOST.MA_COSTO,0)*dbo.FACTIMP.FI_TIPOCAMBIO)*SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP1),0)  end,
						 round(SUM(isnull(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP2,0)*isnull(dbo.MAESTRO.EQ_GEN,1)),6),
						 round(SUM(isnull(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP2,0)*isnull(dbo.MAESTRO.EQ_IMPMX,1)),6)
				FROM         dbo.MAESTRO MAESTRO_1 RIGHT OUTER JOIN
				                      dbo.ARANCEL RIGHT OUTER JOIN
				                      dbo.FACTIMPEMPAQUE INNER JOIN
				                      dbo.MAESTRO ON dbo.FACTIMPEMPAQUE.MA_EMP2 = dbo.MAESTRO.MA_CODIGO RIGHT OUTER JOIN
				                      dbo.FACTIMP ON dbo.FACTIMPEMPAQUE.FI_CODIGO = dbo.FACTIMP.FI_CODIGO ON dbo.ARANCEL.AR_CODIGO = dbo.MAESTRO.AR_IMPMX ON 
				                      MAESTRO_1.MA_CODIGO = dbo.MAESTRO.MA_GENERICO LEFT OUTER JOIN
					         VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO=VMAESTROCOST.MA_CODIGO
				WHERE     (dbo.FACTIMP.PI_CODIGO =@picodigo) and dbo.MAESTRO.MA_GENERA_EMP in ('R','T')
				GROUP BY dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, 
				                      dbo.MAESTRO.MA_NAME, dbo.MAESTRO.ME_COM, dbo.MAESTRO.EQ_GEN, dbo.MAESTRO.EQ_IMPMX, dbo.MAESTRO.MA_GENERICO, 
				                      dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.AR_EXPFO, 
				                      dbo.MAESTRO.MA_SEC_IMP, dbo.MAESTRO.MA_DEF_TIP, dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.PA_ORIGEN, 
				                      dbo.MAESTRO.SPI_CODIGO, dbo.MAESTRO.PA_PROCEDE, MAESTRO_1.ME_COM, dbo.ARANCEL.ME_CODIGO, dbo.FACTIMPEMPAQUE.FIE_GENERA_EMP2
				HAVING      (dbo.MAESTRO.MA_CODIGO IS NOT NULL) and SUM(dbo.FACTIMPEMPAQUE.FIE_TOT_EMP2)>0
			
                        end*/
			-- empaque adicional
		
			if exists (SELECT     dbo.FACTIMPEMPAQUEADICIONAL.* FROM         dbo.FACTIMP LEFT OUTER JOIN
			                      dbo.FACTIMPEMPAQUEADICIONAL ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPEMPAQUEADICIONAL.FI_CODIGO
				WHERE     (dbo.FACTIMP.PI_CODIGO = @picodigo))
			begin
				INSERT INTO TempPedImpDet (PI_CODIGO, MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_CTOT_DLS, 
					PID_CANT, ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
					AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
					PA_PROCEDE, ME_GENERICO, ME_ARIMPMX, PID_IMPRIMIR, PID_GENERA_EMP, PID_CANT_DESP, PID_DESCARGABLE, PID_CTOT_MN,
					PID_CAN_GEN, PID_CAN_AR)
			
				SELECT     @picodigo, dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, isnull(max(VMAESTROCOST.MA_COSTO)*SUM(dbo.FACTIMPEMPAQUEADICIONAL.FIAD_CANTIDAD),0), 
				                      SUM(dbo.FACTIMPEMPAQUEADICIONAL.FIAD_CANTIDAD), dbo.MAESTRO.ME_COM, dbo.MAESTRO.MA_GENERICO, 
				                      dbo.MAESTRO.EQ_GEN, dbo.MAESTRO.EQ_IMPMX, isnull(dbo.MAESTRO.AR_IMPMX,0), isnull(dbo.MAESTRO.AR_EXPFO,0), dbo.GetAdvalorem(dbo.MAESTRO.AR_EXPFO, 0, 'G', 0, 0), 
				                      dbo.MAESTRO.MA_SEC_IMP, dbo.MAESTRO.MA_DEF_TIP, 0, dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.PA_ORIGEN, 
				                      dbo.MAESTRO.SPI_CODIGO, dbo.MAESTRO.PA_PROCEDE, MAESTRO_1.ME_COM AS ME_GEN, dbo.ARANCEL.ME_CODIGO AS ME_AR, 'N',				                      dbo.MAESTRO.MA_GENERA_EMP, SUM(dbo.FACTIMPEMPAQUEADICIONAL.FIAD_CANTIDAD), 'S',
					       'PID_CTOT_MN'=case when @PI_USA_TIP_CAMFACT<>'S' then  isnull(max(isnull(VMAESTROCOST.MA_COSTO,0)*@PI_TIP_CAM)*SUM(dbo.FACTIMPEMPAQUEADICIONAL.FIAD_CANTIDAD),0)  else isnull(max(isnull(VMAESTROCOST.MA_COSTO,0)*dbo.FACTIMP.FI_TIPOCAMBIO)*SUM(dbo.FACTIMPEMPAQUEADICIONAL.FIAD_CANTIDAD),0)  end,
						 round(SUM(isnull(dbo.FACTIMPEMPAQUEADICIONAL.FIAD_CANTIDAD,0)*isnull(dbo.MAESTRO.EQ_GEN,1)),6),
						 round(SUM(isnull(dbo.FACTIMPEMPAQUEADICIONAL.FIAD_CANTIDAD,0)*isnull(dbo.MAESTRO.EQ_IMPMX,1)),6)
				FROM         dbo.FACTIMPEMPAQUEADICIONAL INNER JOIN
				                      dbo.FACTIMP ON dbo.FACTIMPEMPAQUEADICIONAL.FI_CODIGO = dbo.FACTIMP.FI_CODIGO LEFT OUTER JOIN
				                      dbo.MAESTRO ON dbo.FACTIMPEMPAQUEADICIONAL.MA_CODIGO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
				                      dbo.ARANCEL ON dbo.MAESTRO.AR_IMPMX = dbo.ARANCEL.AR_CODIGO LEFT OUTER JOIN
				                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO LEFT OUTER JOIN
					         VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO=VMAESTROCOST.MA_CODIGO
				WHERE     (dbo.FACTIMP.PI_CODIGO =@picodigo) and dbo.MAESTRO.MA_GENERA_EMP in ('R','T')
				GROUP BY dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, dbo.MAESTRO.ME_COM, 
				                      dbo.MAESTRO.EQ_GEN, dbo.MAESTRO.EQ_IMPMX, dbo.MAESTRO.MA_GENERICO, 
				                      dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.AR_EXPFO, dbo.MAESTRO.MA_SEC_IMP, dbo.MAESTRO.MA_DEF_TIP, 
				                      dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.PA_ORIGEN, dbo.MAESTRO.SPI_CODIGO, dbo.MAESTRO.PA_PROCEDE, 
				                      MAESTRO_1.ME_COM, dbo.ARANCEL.ME_CODIGO, dbo.MAESTRO.MA_GENERA_EMP
				HAVING      (dbo.MAESTRO.MA_CODIGO IS NOT NULL) and SUM(dbo.FACTIMPEMPAQUEADICIONAL.FIAD_CANTIDAD)>0
		
			end
	
		end
	end

GO
