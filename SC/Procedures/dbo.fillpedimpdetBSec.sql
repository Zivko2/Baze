SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [fillpedimpdetBSec] (@picodigo int, @pi_movimiento char(1), @user int)   as

SET NOCOUNT ON 
declare @FechaActual varchar(10), @hora varchar(15), @em_codigo int, @CCP_TIPO varchar(5)


	TRUNCATE TABLE temppedimpdetb 

	dbcc checkident (TempPedimpdetb, reseed, 1) WITH NO_INFOMSGS
	
	SET @FechaActual = convert(varchar(10), getdate(),101)

	select @em_codigo=em_codigo from intradeglobal.dbo.empresa where em_corto in
	(select replace(convert(sysname,db_name()),'intrade',''))

	select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

	insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
	values (@user, 2, 'Llenando tabla temporal de agrupacion SAAI ', 'Filling SAAI Group temporary table ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)
	

	SELECT @CCP_TIPO=CCP_TIPO FROM CONFIGURACLAVEPED WHERE CP_CODIGO
	IN (SELECT CP_CODIGO FROM PEDIMP WHERE PI_CODIGO=@picodigo)

	if @pi_movimiento='E'
	begin
			insert into TempPedimpDetB ( PI_CODIGO, MA_GENERICO, AR_IMPMX, ME_ARIMPMX, ME_GENERICO, PIB_CAN_GEN, PIB_CAN_AR, 
				PA_ORIGEN, PA_PROCEDE, ES_ORIGEN, ES_DESTINO, ES_COMPRADOR, ES_VENDEDOR, PIB_VAL_ADU, PIB_VAL_US, 
				 PIB_VAL_FAC,  AR_EXPFO, PIB_RATEEXPFO, PIB_COS_UNIGRA, PIB_COS_UNIVA, EQ_EXPFO,
				PIB_CANT, PIB_POR_DEF, PIB_DESTNAFTA,PIB_NOMBRE, PIB_PAGACONTRIB, PIB_SEC_IMP, PIB_DEF_TIP, SPI_CODIGO, 
				PIB_SECUENCIAPID, PIB_CTOT_MN, PIB_VAL_RET, PIB_GENERA_EMPDET, PIB_SERVICIO)
	
	
			SELECT     @picodigo, max(MA_GENERICO), max(AR_IMPMX), MAX(ME_ARIMPMX), MAX(ME_GENERICO), round(SUM(PID_CAN_GEN),3), 
			                      round(SUM(PID_CAN_AR),3), max(PA_ORIGEN), max(PA_PROCEDE), max(ES_ORIGEN), max(ES_DESTINO), max(ES_COMPRADOR), max(ES_VENDEDOR), 0 
			                      , SUM(PID_CTOT_DLS), 0, max(AR_EXPFO), max(PID_RATEEXPFO), 
					'a'=case when SUM(PID_CANT)>0 then sum(PIB_COS_UNIGRA*PID_CANT)/SUM(PID_CANT) else 0 end, 
					case when SUM(PID_CANT)>0 then round(sum(PID_COS_UNIVA*PID_CANT)/sum(PID_CANT),6) else 0 end, 
					max(EQ_EXPFO), round(sum(PID_CANT),3), max(PID_POR_DEF), max(PIB_DESTNAFTA), 
			                     UPPER(MAX(PID_NOMBRE)), max(PID_PAGACONTRIB),  max(PID_SEC_IMP), max(PID_DEF_TIP), max(SPI_CODIGO), PID_SECUENCIA, 
					SUM(PID_CTOT_MN), SUM(PID_VAL_RET), max(PIB_GENERA_EMPDET), max(PID_SERVICIO)
			FROM         VFillPedImpDetB
			WHERE     (PI_CODIGO = @picodigo)
			GROUP BY PID_SECUENCIA
			ORDER BY max(AR_FRACCION), max(AR_IMPMX), max(MA_GENERICO)
	end
	else
	begin
			insert into TempPedimpDetB ( PI_CODIGO, MA_GENERICO, AR_IMPMX, ME_ARIMPMX, ME_GENERICO, PIB_CAN_GEN, PIB_CAN_AR, 
				PA_ORIGEN, PA_PROCEDE, ES_ORIGEN, ES_DESTINO, ES_COMPRADOR, ES_VENDEDOR, PIB_VAL_ADU, PIB_VAL_US, 
				 PIB_VAL_FAC,  AR_EXPFO, PIB_RATEEXPFO, PIB_COS_UNIGRA, PIB_COS_UNIVA, EQ_EXPFO,
				PIB_CANT, PIB_POR_DEF, PIB_DESTNAFTA,PIB_NOMBRE, PIB_PAGACONTRIB, PIB_SEC_IMP, PIB_DEF_TIP, SPI_CODIGO, 
				PIB_SECUENCIAPID, PIB_CTOT_MN, PIB_VAL_RET, PIB_GENERA_EMPDET, PIB_SERVICIO)
	
	
			SELECT     @picodigo, max(MA_GENERICO), max(AR_IMPMX), MAX(ME_ARIMPMX), MAX(ME_GENERICO), round(SUM(PID_CAN_GEN),3), 
			                      round(SUM(PID_CAN_AR),3), max(PA_ORIGEN), max(PA_PROCEDE), max(ES_ORIGEN), max(ES_DESTINO), max(ES_COMPRADOR), max(ES_VENDEDOR), 0
			                      , SUM(PID_CTOT_DLS), 0, max(AR_EXPFO), max(PID_RATEEXPFO), 
					'a'=case when SUM(PID_CANT)>0 then sum(PIB_COS_UNIGRA*PID_CANT)/SUM(PID_CANT) else 0 end, 
					case when SUM(PID_CANT)>0 then round(sum(PID_COS_UNIVA*PID_CANT)/sum(PID_CANT),6) else 0 end, max(EQ_EXPFO), round(sum(PID_CANT),3), max(PID_POR_DEF), max(PIB_DESTNAFTA), 
			                     UPPER(MAX(PID_NOMBRE)), max(PID_PAGACONTRIB),  max(PID_SEC_IMP), max(PID_DEF_TIP), max(SPI_CODIGO), PID_SECUENCIA, SUM(PID_CTOT_MN),
					SUM(PID_VAL_RET), max(PIB_GENERA_EMPDET), max(PID_SERVICIO)
			FROM         VFillPedImpDetB
			WHERE     (PI_CODIGO = @picodigo)
			GROUP BY PID_SECUENCIA
			ORDER BY max(AR_FRACCION), max(AR_IMPMX), max(MA_GENERICO)
	end

		update TempPedimpDetB
		set PIB_COS_UNIGEN= PIB_VAL_FAC/PIB_CAN_GEN
		where PIB_CAN_GEN>0 AND pi_codigo=@picodigo

		update TempPedimpDetB
		set PIB_COS_UNIGEN= 0
		where (PIB_CAN_GEN=0 or PIB_CAN_GEN is null) AND pi_codigo=@picodigo
		
		update TempPedimpDetB
		SET     TempPedimpDetB.PA_ORIGEN= PEDIMPPAISMAX.PA_ORIGEN
		FROM         TempPedimpDetB INNER JOIN
		                      (SELECT     PI_CODIGO, PID_SECUENCIA, MAX(COUNTPAIS) AS maxCOUNTPAIS, PA_ORIGEN
				FROM   (SELECT TOP 100 PERCENT PI_CODIGO, PID_SECUENCIA, PA_ORIGEN, COUNT(*) AS COUNTPAIS
					FROM         PEDIMPDET
					GROUP BY PI_CODIGO, PID_SECUENCIA, PA_ORIGEN) PEDIMPPAIS
				GROUP BY PI_CODIGO, PID_SECUENCIA, PA_ORIGEN) PEDIMPPAISMAX ON TempPedimpDetB.PI_CODIGO = PEDIMPPAISMAX.PI_CODIGO AND 
		                      TempPedimpDetB.PIB_SECUENCIAPID = PEDIMPPAISMAX.PID_SECUENCIA
		WHERE     (TempPedimpDetB.PI_CODIGO = @picodigo)

		/*	
		-- el 1 de septiembre cambia el calculo del valor comercial o valor pagado en la exportacion (valor factura)
		if (select PI_FEC_PAG from pedimp where pi_codigo=@picodigo) >= '05/01/2007' and @pi_movimiento='S'
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
			PIB_CANT, PIB_POR_DEF, PIB_DESTNAFTA, PA_ORIGEN, PIB_NOMBRE, PIB_SECUENCIAPID, case when PIB_CAN_GEN>0 THEN round(PIB_VAL_US/PIB_CAN_GEN,5) ELSE 0 END, 
			PIB_PAGACONTRIB, PIB_SEC_IMP, PIB_DEF_TIP, SPI_CODIGO, PIB_CODIGOFACT, PIB_VAL_RET, PIB_GENERA_EMPDET, PIB_SERVICIO
		from TempPedimpDetB

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
			PIB_CANT, PIB_POR_DEF, PIB_DESTNAFTA, PA_ORIGEN, PIB_NOMBRE, 0, case when PIB_CAN_GEN>0 THEN round(PIB_VAL_US/PIB_CAN_GEN,5) ELSE 0 END, 
			PIB_PAGACONTRIB, PIB_SEC_IMP, PIB_DEF_TIP, SPI_CODIGO, PIB_CODIGOFACT, PIB_VAL_RET, PIB_GENERA_EMPDET, PIB_SERVICIO
		from TempPedimpDetB

	end

/*=========================== Inicio actualizacion de la liga entre detalle y agrupacion ============================*/

	select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

	insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
	values (@user, 2, 'Ligando detalle Agrupacion SAAI - Detalle Pedimento ', 'Linking SAAI Group Detail - Pedimento Detail ', convert(varchar(10),@FechaActual,101),  @hora, @em_codigo)
	

	-- Actualizacion del PIB_INDICEB
	UPDATE dbo.PEDIMPDET
	SET     dbo.PEDIMPDET.PIB_INDICEB= dbo.PEDIMPDETB.PIB_INDICEB
	FROM         dbo.PEDIMPDET, dbo.PEDIMPDETB 
	WHERE     dbo.PEDIMPDETB.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO 
	AND(dbo.PEDIMPDETB.PI_CODIGO = @picodigo) and
	dbo.PEDIMPDET.PID_SECUENCIA = dbo.PEDIMPDETB.PIB_SECUENCIA
	AND dbo.PEDIMPDET.PID_IMPRIMIR='S'



	IF (SELECT PICF_SAAIDIVDESC from PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='N'
	exec SP_UNENOMBREPIB @picodigo


GO
