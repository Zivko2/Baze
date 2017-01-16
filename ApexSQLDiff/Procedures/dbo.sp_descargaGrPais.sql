SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_descargaGrPais] (@fed_indiced int, @MetodoDescarga Varchar(4), @tipodescarga varchar(2)) with encryption as
SET NOCOUNT ON 
declare @KAP_FECHADESC varchar(10), @fe_fecha varchar(10), @CodigoFactura int, @CF_DESCARGAVENCIDOS char(1),
@destinofin char(1)
	
	set @KAP_FECHADESC= convert(varchar(10),getdate(),101)

	select @fe_fecha=convert(varchar(10),fe_fecha,101), @CodigoFactura=fe_codigo from factexp where fe_codigo in (select fe_codigo from factexpdet where fed_indiced=@fed_indiced)

	SELECT     @CF_DESCARGAVENCIDOS=CF_DESCARGAVENCIDOS
	FROM         CONFIGURACION


	-- inserta los que no se encontraron con la tasa deseada, esto para que sean buscados por medio del procedimiento sp_descargaGr1
	exec sp_descargaGrPaisNoEncon @fed_indiced, @tipodescarga 
	
		if @CF_DESCARGAVENCIDOS='S'
		begin
			print 'nafta-vencidos'
			INSERT INTO KARDESPEDtemp (KAP_FACTRANS, KAP_CantTotADescargar, KAP_CANTDESC, KAP_INDICED_PED, KAP_INDICED_FACT, 
				MA_HIJO, KAP_PADRESUST, KAP_TIPO_DESC, KAP_FisComp, PA_CODIGO)
		
			SELECT     TOP 100 PERCENT @CodigoFactura, round(VBOM_DESCTEMPGenPais.CANTDESC,6) AS KAP_CantTotADescargar, 
			'KAP_CANTDESC'=case when round(vPIDescarga.PID_SALDOGEN,6)<=round(VBOM_DESCTEMPGenPais.CANTDESC,6) then round(vPIDescarga.PID_SALDOGEN,6) else round(VBOM_DESCTEMPGenPais.CANTDESC,6) end, 
			vPIDescarga.PID_INDICED, VBOM_DESCTEMPGenPais.FED_INDICED, vPIDescarga.MA_CODIGO, VBOM_DESCTEMPGenPais.MA_GENERICO, VBOM_DESCTEMPGenPais.BST_TIPODESC,
			'N', VBOM_DESCTEMPGenPais.PA_CODIGO
			FROM         VBOM_DESCTEMPGenPais INNER JOIN
		                      vPIDescarga ON VBOM_DESCTEMPGenPais.MA_GENERICO = vPIDescarga.MA_GENERICO
			WHERE     vPIDescarga.PID_SALDOGEN > 0 AND vPIDescarga.PID_INDICED IN
				(SELECT     TOP 100 PERCENT MIN(vPIDescarga1.PID_INDICED)
				FROM         vPIDescarga vPIDescarga1
				WHERE     vPIDescarga1.PID_SALDOGEN > 0 AND 
				                vPIDescarga1.MA_GENERICO = VBOM_DESCTEMPGenPais.MA_GENERICO
						and vPIDescarga1.MA_GENERICO>0
						AND vPIDescarga1.pa_origen = VBOM_DESCTEMPGenPais.pa_codigo
					       AND vPIDescarga1.PI_FEC_ENT IN
					(SELECT     TOP 100 PERCENT MIN(vPIDescarga2.PI_FEC_ENT) AS PI_FEC_ENT
					FROM         vPIDescarga vPIDescarga2
					WHERE    vPIDescarga2.PI_FEC_ENT<= @fe_fecha 
						AND vPIDescarga2.PID_SALDOGEN > 0 
						AND vPIDescarga2.pa_origen = VBOM_DESCTEMPGenPais.pa_codigo AND
					                      vPIDescarga2.MA_GENERICO = VBOM_DESCTEMPGenPais.MA_GENERICO)) 
			and round(VBOM_DESCTEMPGenPais.CANTDESC,6)>0 
			and (VBOM_DESCTEMPGenPais.FED_INDICED= @fed_indiced)
			and (VBOM_DESCTEMPGenPais.BST_TIPODESC=left(@tipodescarga,1) or VBOM_DESCTEMPGenPais.BST_TIPODESC=right(@tipodescarga,1))
			group by VBOM_DESCTEMPGenPais.CANTDESC, vPIDescarga.MA_CODIGO, VBOM_DESCTEMPGenPais.BST_TIPODESC, vPIDescarga.PID_INDICED, vPIDescarga.PID_SALDOGEN, 
			VBOM_DESCTEMPGenPais.MA_TIP_ENS, VBOM_DESCTEMPGenPais.FED_INDICED, VBOM_DESCTEMPGenPais.MA_GENERICO, VBOM_DESCTEMPGenPais.PA_CODIGO
			order by vPIDescarga.PID_INDICED, VBOM_DESCTEMPGenPais.FED_INDICED
		end
		else
		begin
			print 'nafta-no vencidos'
			INSERT INTO KARDESPEDtemp (KAP_FACTRANS, KAP_CantTotADescargar, KAP_CANTDESC, KAP_INDICED_PED, KAP_INDICED_FACT, 
					MA_HIJO, KAP_PADRESUST, KAP_TIPO_DESC, KAP_FisComp, PA_CODIGO)
		
			SELECT     TOP 100 PERCENT @CodigoFactura, round(VBOM_DESCTEMPGenPais.CANTDESC,6) AS KAP_CantTotADescargar, 
			'KAP_CANTDESC'=case when round(vPIDescarga.PID_SALDOGEN,6)<=round(VBOM_DESCTEMPGenPais.CANTDESC,6) then round(vPIDescarga.PID_SALDOGEN,6) else round(VBOM_DESCTEMPGenPais.CANTDESC,6) end, 
			vPIDescarga.PID_INDICED, VBOM_DESCTEMPGenPais.FED_INDICED, vPIDescarga.MA_CODIGO, VBOM_DESCTEMPGenPais.MA_GENERICO, VBOM_DESCTEMPGenPais.BST_TIPODESC,
			'N', VBOM_DESCTEMPGenPais.PA_CODIGO
			FROM         VBOM_DESCTEMPGenPais INNER JOIN
		                      vPIDescarga ON VBOM_DESCTEMPGenPais.MA_GENERICO = vPIDescarga.MA_GENERICO
			WHERE     vPIDescarga.PID_SALDOGEN > 0 AND vPIDescarga.PID_INDICED IN
				(SELECT     TOP 100 PERCENT MIN(vPIDescarga1.PID_INDICED)
				FROM         vPIDescarga vPIDescarga1
				WHERE     vPIDescarga1.pid_fechavence>=@fe_fecha AND vPIDescarga1.PID_SALDOGEN > 0 AND 
				                      vPIDescarga1.MA_GENERICO = VBOM_DESCTEMPGenPais.MA_GENERICO 
					        and vPIDescarga1.MA_GENERICO>0
						AND vPIDescarga1.pa_origen = VBOM_DESCTEMPGenPais.pa_codigo 
					        AND vPIDescarga1.PI_FEC_ENT IN
					(SELECT     TOP 100 PERCENT MIN(vPIDescarga2.PI_FEC_ENT) AS PI_FEC_ENT
					FROM         vPIDescarga vPIDescarga2					WHERE    vPIDescarga2.PI_FEC_ENT<= @fe_fecha 
						and vPIDescarga2.pid_fechavence>=@fe_fecha and
						vPIDescarga2.PID_SALDOGEN > 0 AND 
						vPIDescarga2.pa_origen = VBOM_DESCTEMPGenPais.pa_codigo AND
					                      vPIDescarga2.MA_GENERICO = VBOM_DESCTEMPGenPais.MA_GENERICO)) 
			and round(VBOM_DESCTEMPGenPais.CANTDESC,6)>0 
			and (VBOM_DESCTEMPGenPais.FED_INDICED= @fed_indiced)
			and (VBOM_DESCTEMPGenPais.BST_TIPODESC=left(@tipodescarga,1) or VBOM_DESCTEMPGenPais.BST_TIPODESC=right(@tipodescarga,1))
			group by VBOM_DESCTEMPGenPais.CANTDESC, vPIDescarga.MA_CODIGO, VBOM_DESCTEMPGenPais.BST_TIPODESC, vPIDescarga.PID_INDICED, vPIDescarga.PID_SALDOGEN, 
			VBOM_DESCTEMPGenPais.MA_TIP_ENS, VBOM_DESCTEMPGenPais.FED_INDICED, VBOM_DESCTEMPGenPais.MA_GENERICO, VBOM_DESCTEMPGenPais.PA_CODIGO
			order by vPIDescarga.PID_INDICED, VBOM_DESCTEMPGenPais.FED_INDICED
		end

	/* ==== actualizando KAP_Saldo_FED ===*/

	UPDATE    KARDESPEDtemp
	SET             KAP_Saldo_FED = 0, KAP_ESTATUS='D'
	WHERE     (KAP_CANTDESC = KAP_CantTotADescargar)
	and  KAP_Saldo_FED  is null


	update kardespedtemp
	set kardespedtemp.KAP_Saldo_FED= round(kardespedtemp.KAP_CantTotADescargar-isnull((SELECT     SUM(kardespedtemp_1.kap_cantdesc)
						FROM         kardespedtemp kardespedtemp_1 
						WHERE     (kardespedtemp_1.kap_padresust = kardespedtemp.kap_padresust)  
						GROUP BY kardespedtemp_1.kap_indiced_fact HAVING  (kardespedtemp_1.kap_indiced_fact = @fed_indiced)),0),6)
	from kardespedtemp 
	where kardespedtemp.KAP_Saldo_FED is null and KAP_INDICED_FACT=@fed_indiced


	/* ==== actualizando SALDO Pedimento ===*/	             

	UPDATE PIDescarga
	SET     PIDescarga.PID_SALDOGEN= (case WHEN round(PIDescarga.PID_SALDOGEN,6)<=round(KARDESPEDtemp.KAP_CANTDESC,6)  then 0
	else round( round(PIDescarga.PID_SALDOGEN,6)-round(KARDESPEDtemp.KAP_CANTDESC,6),6) end)
	FROM         KARDESPEDtemp INNER JOIN
	                      PIDescarga ON KARDESPEDtemp.KAP_INDICED_PED = PIDescarga.PID_INDICED
	WHERE KARDESPEDtemp.kap_codigo in (SELECT MAX(KARDESPEDtemp.KAP_CODIGO) FROM KARDESPEDtemp INNER JOIN
               MAESTRO ON KARDESPEDtemp.MA_HIJO = MAESTRO.MA_CODIGO WHERE  KARDESPEDtemp.KAP_INDICED_FACT = @fed_indiced
	  GROUP BY MAESTRO.MA_GENERICO)

	UPDATE KARDESPEDTEMP
	SET KAP_SALAFECTADO='S'
	WHERE KAP_SALAFECTADO='N'



	/* restan por descargar */
	if @destinofin='N' -- nafta
	begin
		if exists (select ma_hijo from kardespedtemp where kap_saldo_fed>0 and kap_indiced_fact=@fed_indiced and kap_codigo in
		 (SELECT MAX(KARDESPEDtemp1.KAP_CODIGO) FROM KARDESPEDtemp KARDESPEDtemp1 INNER JOIN
		MAESTRO ON KARDESPEDtemp1.MA_HIJO = MAESTRO.MA_CODIGO 
		WHERE KARDESPEDtemp1.KAP_FACTRANS = @CodigoFactura AND KARDESPEDtemp1.KAP_INDICED_FACT = @fed_indiced
		and (KARDESPEDtemp1.KAP_TIPO_DESC=left(@tipodescarga,1) or KARDESPEDtemp1.KAP_TIPO_DESC=right(@tipodescarga,1))
		GROUP BY MAESTRO.MA_GENERICO) and (kap_estatus<>'N' or kap_estatus is null) 
		and KAP_PADRESUST in 
		(select ma_generico from vPIDescarga where pid_saldogen>0 and pid_por_def=0 and pi_fec_ent <=@fe_fecha and pa_origen =kardespedtemp.pa_codigo))
		begin
	
			exec sp_descargaGr1Pais @fed_indiced, @fe_fecha, @tipodescarga
	
		end
	end
	else
	begin
		if exists (select ma_hijo from kardespedtemp where kap_saldo_fed>0 and kap_indiced_fact=@fed_indiced and kap_codigo in
		 (SELECT MAX(KARDESPEDtemp1.KAP_CODIGO) FROM KARDESPEDtemp KARDESPEDtemp1 INNER JOIN
		MAESTRO ON KARDESPEDtemp1.MA_HIJO = MAESTRO.MA_CODIGO 
		WHERE KARDESPEDtemp1.KAP_FACTRANS = @CodigoFactura AND KARDESPEDtemp1.KAP_INDICED_FACT = @fed_indiced
		and (KARDESPEDtemp1.KAP_TIPO_DESC=left(@tipodescarga,1) or KARDESPEDtemp1.KAP_TIPO_DESC=right(@tipodescarga,1))
		GROUP BY MAESTRO.MA_GENERICO) and (kap_estatus<>'N' or kap_estatus is null) 
		and KAP_PADRESUST in 
		(select ma_generico from vPIDescarga where pid_saldogen>0 and pid_por_def>0 and pi_fec_ent <=@fe_fecha and pa_origen =kardespedtemp.pa_codigo))
		begin
	
			exec sp_descargaGr1Pais @fed_indiced, @fe_fecha, @tipodescarga
	
		end
	end


	-- restan por descargar sin tomar en cuenta la tasa
	if exists (select ma_hijo from kardespedtemp where kap_saldo_fed>0 and kap_indiced_fact=@fed_indiced and kap_codigo in
	 (SELECT MAX(KARDESPEDtemp1.KAP_CODIGO) FROM KARDESPEDtemp KARDESPEDtemp1 INNER JOIN
	MAESTRO ON KARDESPEDtemp1.MA_HIJO = MAESTRO.MA_CODIGO 
	WHERE KARDESPEDtemp1.KAP_FACTRANS = @CodigoFactura AND KARDESPEDtemp1.KAP_INDICED_FACT = @fed_indiced
	and (KARDESPEDtemp1.KAP_TIPO_DESC=left(@tipodescarga,1) or KARDESPEDtemp1.KAP_TIPO_DESC=right(@tipodescarga,1))
	GROUP BY MAESTRO.MA_GENERICO) /*and (kap_estatus='N' or kap_estatus is null) */
	and KAP_PADRESUST in 
	(select ma_generico from vPIDescarga where pid_saldogen>0 and pi_fec_ent <=@fe_fecha))
	begin

		exec sp_descargaGr1 @fed_indiced, @MetodoDescarga, @fe_fecha, @tipodescarga

	end
GO
