SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [fillpedimpdetkit_rect] (@picodigo int, @user int)   as

SET NOCOUNT ON 
declare @Pid_indiced int, @maximo int, @FechaActual datetime, @hora varchar(15), @em_codigo int, @ccp_tipo varchar(5),
@PI_TIP_CAM decimal(38,6), @pi_ft_adu decimal(38,9), @incrementauni decimal(38,6), @PI_USA_TIP_CAMFACT char(1)


	SET @FechaActual = convert(varchar(10), getdate(),101)

	select @em_codigo=em_codigo from intradeglobal.dbo.empresa where em_corto in
	(select replace(convert(sysname,db_name()),'intrade',''))

	select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

	insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
	values (@user, 2, 'Llenando tabla temporal de detalle- Kit ', 'Filling Kit-Detail Temporary table ', convert(varchar(10), @FechaActual,101), @hora, @em_codigo)

	select @ccp_tipo=ccp_tipo from configuraclaveped where cp_codigo in
	(select cp_codigo from pedimp where pi_codigo=@picodigo)

	select @PI_TIP_CAM=PI_TIP_CAM, @pi_ft_adu=pi_ft_adu, @PI_USA_TIP_CAMFACT=PI_USA_TIP_CAMFACT from pedimp where pi_codigo=@picodigo


		INSERT INTO TempPedImpDet (PI_CODIGO,  MA_CODIGO, PID_NOPARTE, PID_NOMBRE, PID_NAME, PID_COS_UNI, PID_CTOT_DLS,
			PID_CANT, ME_CODIGO, MA_GENERICO, EQ_GENERICO, EQ_IMPMX, 
			AR_IMPMX, AR_EXPFO, PID_RATEEXPFO, PID_SEC_IMP, PID_DEF_TIP, PID_POR_DEF, TI_CODIGO, PA_ORIGEN, SPI_CODIGO, 
			PA_PROCEDE, ME_GENERICO, ME_ARIMPMX, PR_CODIGO, PID_DESCARGABLE,
			PID_IMPRIMIR, PID_MA_CODIGOPADREKIT, CS_CODIGO, PID_CODIGOFACT, PID_CTOT_MN,
			PID_CAN_GEN, PID_CAN_AR)
	
		SELECT     @picodigo, dbo.BOM_STRUCT.BST_HIJO, dbo.BOM_STRUCT.BST_NOPARTE, dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, isnull(VMAESTROCOST.MA_COSTO,0), 
			         isnull(dbo.FACTIMPDET.FID_CANT_ST * dbo.BOM_STRUCT.BST_INCORPOR*VMAESTROCOST.MA_COSTO,0),
		                      isnull(dbo.FACTIMPDET.FID_CANT_ST * dbo.BOM_STRUCT.BST_INCORPOR,0), dbo.BOM_STRUCT.ME_CODIGO, 
		                      dbo.MAESTRO.MA_GENERICO, dbo.MAESTRO.EQ_GEN, dbo.MAESTRO.EQ_IMPMX, isnull(dbo.MAESTRO.AR_IMPMX,0), isnull(dbo.MAESTRO.AR_EXPFO,0), 
		                      dbo.GetAdvalorem(dbo.MAESTRO.AR_EXPFO, 0, 'G', 0, 0), isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.MA_DEF_TIP, 'G'), dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.PA_ORIGEN, isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.SPI_CODIGO,0)),  
		                      dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.PA_ORIGEN, isnull(dbo.MAESTRO.SPI_CODIGO,0), dbo.MAESTRO.PA_PROCEDE, 
		                      dbo.BOM_STRUCT.ME_GEN, isnull(dbo.ARANCEL.ME_CODIGO,(select me_codigo from arancel where ar_codigo= dbo.MAESTRO.AR_IMPMX)), 
				dbo.FACTIMP.PR_CODIGO, 'S', 'N' , dbo.FACTIMPDET.MA_CODIGO, 8, dbo.FACTIMPDET.FI_CODIGO,
			         'PID_CTOT_MN'=case when @PI_USA_TIP_CAMFACT<>'S' then  isnull(dbo.FACTIMPDET.FID_CANT_ST * dbo.BOM_STRUCT.BST_INCORPOR*VMAESTROCOST.MA_COSTO*@PI_TIP_CAM,0)  else isnull(dbo.FACTIMPDET.FID_CANT_ST * dbo.BOM_STRUCT.BST_INCORPOR*VMAESTROCOST.MA_COSTO*dbo.FACTIMP.FI_TIPOCAMBIO,0)  end,
				 round(dbo.FACTIMPDET.FID_CANT_ST * dbo.BOM_STRUCT.BST_INCORPOR*isnull(dbo.MAESTRO.EQ_GEN,1),6),
				 round(dbo.FACTIMPDET.FID_CANT_ST * dbo.BOM_STRUCT.BST_INCORPOR*isnull(dbo.MAESTRO.EQ_IMPMX,1),6)
		FROM         dbo.BOM_STRUCT RIGHT OUTER JOIN
		                      dbo.FACTIMPDET RIGHT OUTER JOIN
		                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO ON 
		                      dbo.BOM_STRUCT.BSU_SUBENSAMBLE = dbo.FACTIMPDET.MA_CODIGO LEFT OUTER JOIN
		                      dbo.ARANCEL RIGHT OUTER JOIN
		                      dbo.MAESTRO ON dbo.ARANCEL.AR_CODIGO = dbo.MAESTRO.AR_IMPMX ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
	 		       VMAESTROCOST ON 	dbo.MAESTRO.MA_CODIGO=VMAESTROCOST.MA_CODIGO
		WHERE     (dbo.FACTIMPDET.CS_CODIGO = 2) AND (dbo.FACTIMP.PI_RECTIFICA = @picodigo) AND (dbo.FACTIMPDET.FID_PADREKITINSERT ='N')
		AND dbo.BOM_STRUCT.BST_PERINI<=dbo.FACTIMPDET.FID_FECHA_STRUCT AND dbo.BOM_STRUCT.BST_PERFIN>=dbo.FACTIMPDET.FID_FECHA_STRUCT


GO
