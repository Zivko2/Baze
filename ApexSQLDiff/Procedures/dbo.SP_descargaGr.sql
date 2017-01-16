SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_descargaGr] (@fed_indiced int, @MetodoDescarga Varchar(4), @tipodescarga varchar(2))    as

SET NOCOUNT ON 
declare @KAP_FECHADESC varchar(10), @fe_fecha varchar(10), @CodigoFactura int, @CF_DESCARGAVENCIDOS char(1)
	
	set @KAP_FECHADESC= convert(varchar(10),getdate(),101)

	select @fe_fecha=convert(varchar(10),fe_fecha,101), @CodigoFactura=fe_codigo from factexp where fe_codigo in (select fe_codigo from factexpdet where fed_indiced=@fed_indiced)

	SELECT     @CF_DESCARGAVENCIDOS=CF_DESCARGAVENCIDOS
	FROM         CONFIGURACION

	if @CF_DESCARGAVENCIDOS='S'
	begin
		INSERT INTO KARDESPEDtemp(KAP_FACTRANS,  KAP_CantTotADescargar, KAP_CANTDESC, KAP_INDICED_FACT, 
					MA_HIJO, KAP_TIPO_DESC, KAP_Saldo_FED, KAP_FisComp, KAP_ESTATUS, KAP_PADRESUST)
	
		SELECT     TOP 100 PERCENT @CodigoFactura, round(VBOM_DESCTEMP.CANTDESC,6), 0, VBOM_DESCTEMP.FED_INDICED, 
				VBOM_DESCTEMP.BST_HIJO, VBOM_DESCTEMP.BST_TIPODESC,
				round(VBOM_DESCTEMP.CANTDESC,6) , 'MA_TIP_ENS' = case when VBOM_DESCTEMP.MA_TIP_ENS='A'  THEN 'S' ELSE 'N' END, 'N',
				VBOM_DESCTEMP.MA_GENERICO
		FROM         VBOM_DESCTEMP
		WHERE     VBOM_DESCTEMP.MA_GENERICO not in (SELECT MA_GENERICO FROM vPIDescarga 
				WHERE vPIDescarga.PID_SALDOGEN > 0 and vPIDescarga.PI_FEC_ENT<= @fe_fecha)
		and (VBOM_DESCTEMP.BST_TIPODESC=left(@tipodescarga,1) or VBOM_DESCTEMP.BST_TIPODESC=right(@tipodescarga,1))
		AND VBOM_DESCTEMP.FED_INDICED=@fed_indiced AND VBOM_DESCTEMP.BST_HIJO IS NOT NULL
		and round(VBOM_DESCTEMP.CANTDESC,6)>0
	end
	else
	begin
		INSERT INTO KARDESPEDtemp(KAP_FACTRANS,  KAP_CantTotADescargar, KAP_CANTDESC, KAP_INDICED_FACT, 
					MA_HIJO, KAP_TIPO_DESC, KAP_Saldo_FED, KAP_FisComp, KAP_ESTATUS, KAP_PADRESUST)
	
		SELECT     TOP 100 PERCENT @CodigoFactura, round(VBOM_DESCTEMP.CANTDESC,6), 0, VBOM_DESCTEMP.FED_INDICED, 
				VBOM_DESCTEMP.BST_HIJO, VBOM_DESCTEMP.BST_TIPODESC,
				round(VBOM_DESCTEMP.CANTDESC,6) , 'MA_TIP_ENS' = case when VBOM_DESCTEMP.MA_TIP_ENS='A'  THEN 'S' ELSE 'N' END, 'N',
			     VBOM_DESCTEMP.MA_GENERICO
		FROM         VBOM_DESCTEMP
		WHERE     VBOM_DESCTEMP.MA_GENERICO not in (SELECT MA_GENERICO FROM vPIDescarga
				WHERE vPIDescarga.PID_SALDOGEN > 0 and
				vPIDescarga.PI_FEC_ENT<= @fe_fecha and vPIDescarga.pid_fechavence>=@fe_fecha )
		and (VBOM_DESCTEMP.BST_TIPODESC=left(@tipodescarga,1) or VBOM_DESCTEMP.BST_TIPODESC=right(@tipodescarga,1))
		AND VBOM_DESCTEMP.FED_INDICED=@fed_indiced AND VBOM_DESCTEMP.BST_HIJO IS NOT NULL
		and round(VBOM_DESCTEMP.CANTDESC,6)>0
	end

	if @MetodoDescarga='PEPS'
	begin
		if @CF_DESCARGAVENCIDOS='S'
		begin
			INSERT INTO KARDESPEDtemp (KAP_FACTRANS, KAP_CantTotADescargar, KAP_CANTDESC, KAP_INDICED_PED, KAP_INDICED_FACT, 
				MA_HIJO, KAP_PADRESUST, KAP_TIPO_DESC, KAP_FisComp)
		
			SELECT     TOP 100 PERCENT @CodigoFactura, round(VBOM_DESCTEMPGen.CANTDESC,6) AS KAP_CantTotADescargar, 
			'KAP_CANTDESC'=case when round(vPIDescarga.PID_SALDOGEN,6)<=round(VBOM_DESCTEMPGen.CANTDESC,6) then round(vPIDescarga.PID_SALDOGEN,6) else round(VBOM_DESCTEMPGen.CANTDESC,6) end, 
			vPIDescarga.PID_INDICED, VBOM_DESCTEMPGen.FED_INDICED, vPIDescarga.MA_CODIGO, VBOM_DESCTEMPGen.MA_GENERICO, VBOM_DESCTEMPGen.BST_TIPODESC,
			'N'
			FROM         VBOM_DESCTEMPGen INNER JOIN
		                      vPIDescarga ON VBOM_DESCTEMPGen.MA_GENERICO = vPIDescarga.MA_GENERICO
			WHERE     vPIDescarga.PID_SALDOGEN > 0 AND vPIDescarga.PID_INDICED IN
				(SELECT     TOP 100 PERCENT MIN(vPIDescarga1.PID_INDICED)
				FROM         vPIDescarga vPIDescarga1
				WHERE     vPIDescarga1.PID_SALDOGEN > 0 AND 
				                      vPIDescarga1.MA_GENERICO = VBOM_DESCTEMPGen.MA_GENERICO
        					        and vPIDescarga1.MA_GENERICO>0
					       AND vPIDescarga1.PI_FEC_ENT IN
					(SELECT     TOP 100 PERCENT MIN(vPIDescarga2.PI_FEC_ENT) AS PI_FEC_ENT
					FROM         vPIDescarga vPIDescarga2
					WHERE    vPIDescarga2.PI_FEC_ENT<= @fe_fecha 
						AND vPIDescarga2.PID_SALDOGEN > 0 AND 
					                      vPIDescarga2.MA_GENERICO = VBOM_DESCTEMPGen.MA_GENERICO)) 
			and round(VBOM_DESCTEMPGen.CANTDESC,6)>0 
			and (VBOM_DESCTEMPGen.FED_INDICED= @fed_indiced)
			and (VBOM_DESCTEMPGen.BST_TIPODESC=left(@tipodescarga,1) or VBOM_DESCTEMPGen.BST_TIPODESC=right(@tipodescarga,1))
			group by VBOM_DESCTEMPGen.CANTDESC, vPIDescarga.MA_CODIGO, VBOM_DESCTEMPGen.BST_TIPODESC, vPIDescarga.PID_INDICED, vPIDescarga.PID_SALDOGEN, 
			VBOM_DESCTEMPGen.MA_TIP_ENS, VBOM_DESCTEMPGen.FED_INDICED, VBOM_DESCTEMPGen.MA_GENERICO
			order by vPIDescarga.PID_INDICED, VBOM_DESCTEMPGen.FED_INDICED
		end
		else
		begin
			INSERT INTO KARDESPEDtemp (KAP_FACTRANS, KAP_CantTotADescargar, KAP_CANTDESC, KAP_INDICED_PED, KAP_INDICED_FACT, 
					MA_HIJO, KAP_PADRESUST, KAP_TIPO_DESC, KAP_FisComp)
		
			SELECT     TOP 100 PERCENT @CodigoFactura, round(VBOM_DESCTEMPGen.CANTDESC,6) AS KAP_CantTotADescargar, 
			'KAP_CANTDESC'=case when round(vPIDescarga.PID_SALDOGEN,6)<=round(VBOM_DESCTEMPGen.CANTDESC,6) then round(vPIDescarga.PID_SALDOGEN,6) else round(VBOM_DESCTEMPGen.CANTDESC,6) end, 
			vPIDescarga.PID_INDICED, VBOM_DESCTEMPGen.FED_INDICED, vPIDescarga.MA_CODIGO, VBOM_DESCTEMPGen.MA_GENERICO, VBOM_DESCTEMPGen.BST_TIPODESC,
			'N'
			FROM         VBOM_DESCTEMPGen INNER JOIN
		                      vPIDescarga ON VBOM_DESCTEMPGen.MA_GENERICO = vPIDescarga.MA_GENERICO
			WHERE     vPIDescarga.PID_SALDOGEN > 0 AND vPIDescarga.PID_INDICED IN
				(SELECT     TOP 100 PERCENT MIN(vPIDescarga1.PID_INDICED)
				FROM         vPIDescarga vPIDescarga1
				WHERE     vPIDescarga1.pid_fechavence>=@fe_fecha AND vPIDescarga1.PID_SALDOGEN > 0 AND 
				                      vPIDescarga1.MA_GENERICO = VBOM_DESCTEMPGen.MA_GENERICO 
					        and vPIDescarga1.MA_GENERICO>0
					        AND vPIDescarga1.PI_FEC_ENT IN
					(SELECT     TOP 100 PERCENT MIN(vPIDescarga2.PI_FEC_ENT) AS PI_FEC_ENT
					FROM         vPIDescarga vPIDescarga2
					WHERE    vPIDescarga2.PI_FEC_ENT<= @fe_fecha 
						and vPIDescarga2.pid_fechavence>=@fe_fecha and
						vPIDescarga2.PID_SALDOGEN > 0 AND 
					                      vPIDescarga2.MA_GENERICO = VBOM_DESCTEMPGen.MA_GENERICO)) 
			and round(VBOM_DESCTEMPGen.CANTDESC,6)>0 
			and (VBOM_DESCTEMPGen.FED_INDICED= @fed_indiced)
			and (VBOM_DESCTEMPGen.BST_TIPODESC=left(@tipodescarga,1) or VBOM_DESCTEMPGen.BST_TIPODESC=right(@tipodescarga,1))
			group by VBOM_DESCTEMPGen.CANTDESC, vPIDescarga.MA_CODIGO, VBOM_DESCTEMPGen.BST_TIPODESC, vPIDescarga.PID_INDICED, vPIDescarga.PID_SALDOGEN, 
			VBOM_DESCTEMPGen.MA_TIP_ENS, VBOM_DESCTEMPGen.FED_INDICED, VBOM_DESCTEMPGen.MA_GENERICO
			order by vPIDescarga.PID_INDICED, VBOM_DESCTEMPGen.FED_INDICED
		end
	end
	else --ueps
	begin
		if @CF_DESCARGAVENCIDOS='S'
		begin
			INSERT INTO KARDESPEDtemp (KAP_FACTRANS, KAP_CantTotADescargar, KAP_CANTDESC, KAP_INDICED_PED, KAP_INDICED_FACT, 
				MA_HIJO, KAP_PADRESUST, KAP_TIPO_DESC, KAP_FisComp)
		
			SELECT     TOP 100 PERCENT @CodigoFactura, round(VBOM_DESCTEMPGen.CANTDESC,6) AS KAP_CantTotADescargar, 
			'KAP_CANTDESC'=case when round(vPIDescarga.PID_SALDOGEN,6)<=round(VBOM_DESCTEMPGen.CANTDESC,6) then round(vPIDescarga.PID_SALDOGEN,6) else round(VBOM_DESCTEMPGen.CANTDESC,6) end, 
			vPIDescarga.PID_INDICED, VBOM_DESCTEMPGen.FED_INDICED, vPIDescarga.MA_CODIGO, VBOM_DESCTEMPGen.MA_GENERICO, VBOM_DESCTEMPGen.BST_TIPODESC,
			 'N'
			FROM         VBOM_DESCTEMPGen INNER JOIN
		                      vPIDescarga ON VBOM_DESCTEMPGen.MA_GENERICO = vPIDescarga.MA_GENERICO
			WHERE     vPIDescarga.PID_SALDOGEN > 0 AND vPIDescarga.PID_INDICED IN
				(SELECT     TOP 100 PERCENT MAX(vPIDescarga1.PID_INDICED)
				FROM         vPIDescarga vPIDescarga1
				WHERE     vPIDescarga1.PID_SALDOGEN > 0 AND 
				                      vPIDescarga1.MA_GENERICO = VBOM_DESCTEMPGen.MA_GENERICO
        					        and vPIDescarga1.MA_GENERICO>0
					       AND vPIDescarga1.PI_FEC_ENT IN
					(SELECT     TOP 100 PERCENT MAX(vPIDescarga2.PI_FEC_ENT) AS PI_FEC_ENT
					FROM         vPIDescarga vPIDescarga2
					WHERE    vPIDescarga2.PI_FEC_ENT<= @fe_fecha 
						AND vPIDescarga2.PID_SALDOGEN > 0 AND 
					                      vPIDescarga2.MA_GENERICO = VBOM_DESCTEMPGen.MA_GENERICO)) 
			and round(VBOM_DESCTEMPGen.CANTDESC,6)>0 
			and (VBOM_DESCTEMPGen.FED_INDICED= @fed_indiced)
			and (VBOM_DESCTEMPGen.BST_TIPODESC=left(@tipodescarga,1) or VBOM_DESCTEMPGen.BST_TIPODESC=right(@tipodescarga,1))
			group by VBOM_DESCTEMPGen.CANTDESC, vPIDescarga.MA_CODIGO, VBOM_DESCTEMPGen.BST_TIPODESC, vPIDescarga.PID_INDICED, vPIDescarga.PID_SALDOGEN, 
			VBOM_DESCTEMPGen.MA_TIP_ENS, VBOM_DESCTEMPGen.FED_INDICED, VBOM_DESCTEMPGen.MA_GENERICO
			order by vPIDescarga.PID_INDICED, VBOM_DESCTEMPGen.FED_INDICED
		end
		else
		begin
			INSERT INTO KARDESPEDtemp (KAP_FACTRANS, KAP_CantTotADescargar, KAP_CANTDESC, KAP_INDICED_PED, KAP_INDICED_FACT, 
				MA_HIJO, KAP_PADRESUST, KAP_TIPO_DESC, KAP_FisComp)
		
			SELECT     TOP 100 PERCENT @CodigoFactura, round(VBOM_DESCTEMPGen.CANTDESC,6) AS KAP_CantTotADescargar, 
			'KAP_CANTDESC'=case when round(vPIDescarga.PID_SALDOGEN,6)<=round(VBOM_DESCTEMPGen.CANTDESC,6) then round(vPIDescarga.PID_SALDOGEN,6) else round(VBOM_DESCTEMPGen.CANTDESC,6) end, 
			vPIDescarga.PID_INDICED, VBOM_DESCTEMPGen.FED_INDICED, vPIDescarga.MA_CODIGO, VBOM_DESCTEMPGen.MA_GENERICO, VBOM_DESCTEMPGen.BST_TIPODESC,
			'N'
			FROM         VBOM_DESCTEMPGen INNER JOIN
		                      vPIDescarga ON VBOM_DESCTEMPGen.MA_GENERICO = vPIDescarga.MA_GENERICO
			WHERE     vPIDescarga.PID_SALDOGEN > 0 AND vPIDescarga.PID_INDICED IN
				(SELECT     TOP 100 PERCENT MAX(vPIDescarga1.PID_INDICED)
				FROM         vPIDescarga vPIDescarga1
				WHERE     vPIDescarga1.pid_fechavence>=@fe_fecha AND vPIDescarga1.PID_SALDOGEN > 0 AND 
				                      vPIDescarga1.MA_GENERICO = VBOM_DESCTEMPGen.MA_GENERICO 
        					        and vPIDescarga1.MA_GENERICO>0
					        AND vPIDescarga1.PI_FEC_ENT IN
					(SELECT     TOP 100 PERCENT MAX(vPIDescarga2.PI_FEC_ENT) AS PI_FEC_ENT
					FROM         vPIDescarga vPIDescarga2
					WHERE    vPIDescarga2.PI_FEC_ENT<= @fe_fecha 
						and vPIDescarga2.pid_fechavence>=@fe_fecha and
						vPIDescarga2.PID_SALDOGEN > 0 AND 
					                      vPIDescarga2.MA_GENERICO = VBOM_DESCTEMPGen.MA_GENERICO)) 
			and round(VBOM_DESCTEMPGen.CANTDESC,6)>0 
			and (VBOM_DESCTEMPGen.FED_INDICED= @fed_indiced)
			and (VBOM_DESCTEMPGen.BST_TIPODESC=left(@tipodescarga,1) or VBOM_DESCTEMPGen.BST_TIPODESC=right(@tipodescarga,1))
			group by VBOM_DESCTEMPGen.CANTDESC, vPIDescarga.MA_CODIGO, VBOM_DESCTEMPGen.BST_TIPODESC, vPIDescarga.PID_INDICED, vPIDescarga.PID_SALDOGEN, 
			VBOM_DESCTEMPGen.MA_TIP_ENS, VBOM_DESCTEMPGen.FED_INDICED, VBOM_DESCTEMPGen.MA_GENERICO
			order by vPIDescarga.PID_INDICED, VBOM_DESCTEMPGen.FED_INDICED
		end	
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
	if exists (select ma_hijo from kardespedtemp where kap_saldo_fed>0 and kap_indiced_fact=@fed_indiced and kap_codigo in
	 (SELECT MAX(KARDESPEDtemp1.KAP_CODIGO) FROM KARDESPEDtemp KARDESPEDtemp1 INNER JOIN
	MAESTRO ON KARDESPEDtemp1.MA_HIJO = MAESTRO.MA_CODIGO 
	WHERE KARDESPEDtemp1.KAP_FACTRANS = @CodigoFactura AND KARDESPEDtemp1.KAP_INDICED_FACT = @fed_indiced
	and (KARDESPEDtemp1.KAP_TIPO_DESC=left(@tipodescarga,1) or KARDESPEDtemp1.KAP_TIPO_DESC=right(@tipodescarga,1))
	GROUP BY MAESTRO.MA_GENERICO) and (kap_estatus<>'N' or kap_estatus is null) 
	and KAP_PADRESUST in 
	(select ma_generico from vPIDescarga where pid_saldogen>0 and pi_fec_ent <=@fe_fecha))
	begin

		exec sp_descargaGr1 @fed_indiced, @MetodoDescarga, @fe_fecha, @tipodescarga

	end



GO
