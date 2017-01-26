SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.SP_descargaFam1 (@FED_INDICED int, @MetodoDescarga Varchar(4), @fe_fecha Varchar(10), @tipodescarga varchar(2))    as

SET NOCOUNT ON 
declare @existe int, @CF_DESCARGAVENCIDOS char(1), @CodigoFactura Int


	SELECT    @CF_DESCARGAVENCIDOS=CF_DESCARGAVENCIDOS
	FROM         CONFIGURACION

	select @CodigoFactura=fe_codigo from factexpdet where fed_indiced=@FED_INDICED


inicio:


	if @MetodoDescarga='PEPS'
	begin
		if @CF_DESCARGAVENCIDOS='S'
		begin


			INSERT INTO KARDESPEDtemp (KAP_FACTRANS, KAP_CantTotADescargar, KAP_CANTDESC, KAP_INDICED_PED, KAP_INDICED_FACT, 
				MA_HIJO, KAP_TIPO_DESC, KAP_FisComp, KAP_PADRESUST)
		
			SELECT @CodigoFactura, KAP_CantTotADescargar, 'KAP_CANTDESC'=case when vPIDescarga.PID_SALDOGEN<=KARDESPEDtemp.KAP_Saldo_FED 
			then round(vPIDescarga.PID_SALDOGEN,6)
			else round(KARDESPEDtemp.KAP_Saldo_FED,6) end, vPIDescarga.PID_INDICED, KARDESPEDtemp.KAP_INDICED_FACT, vPIDescarga.MA_CODIGO,
			KARDESPEDtemp.KAP_TIPO_DESC, 'N', KARDESPEDtemp.KAP_PADRESUST
			FROM         KARDESPEDtemp INNER JOIN
			                      vPIDescarga ON KARDESPEDtemp.KAP_PADRESUST = vPIDescarga.MA_FAMILIAMP
			WHERE  (KARDESPEDtemp.KAP_Saldo_FED > 0) and
				KARDESPEDtemp.KAP_INDICED_FACT=@fed_indiced
				AND vPIDescarga.PID_INDICED IN 
				(SELECT     TOP 100 PERCENT MIN(vPIDescarga1.PID_INDICED)
				FROM         vPIDescarga vPIDescarga1
				WHERE     vPIDescarga1.PID_SALDOGEN > 0 AND 
				                      vPIDescarga1.MA_FAMILIAMP = KARDESPEDtemp.KAP_PADRESUST AND vPIDescarga1.PI_FEC_ENT IN
					(SELECT     TOP 100 PERCENT MIN(vPIDescarga2.PI_FEC_ENT) AS PI_FEC_ENT
					FROM         vPIDescarga vPIDescarga2
					WHERE     vPIDescarga2.PID_SALDOGEN > 0 AND 
					                      vPIDescarga2.MA_FAMILIAMP = KARDESPEDtemp.KAP_PADRESUST and vPIDescarga2.PI_FEC_ENT<= @fe_fecha))
		
		       and kap_codigo in (SELECT MAX(KAP_CODIGO) FROM KARDESPEDtemp WHERE (KAP_FACTRANS = @CodigoFactura) AND (KAP_INDICED_FACT = @fed_indiced)
			        GROUP BY KAP_PADRESUST)
			group by KAP_CantTotADescargar, vPIDescarga.PID_INDICED, KARDESPEDtemp.KAP_INDICED_FACT, vPIDescarga.MA_CODIGO, KARDESPEDtemp.KAP_PADRESUST,
			 KARDESPEDtemp.KAP_TIPO_DESC, vPIDescarga.PID_SALDOGEN, KARDESPEDtemp.KAP_Saldo_FED 
		end
		else
		begin
			INSERT INTO KARDESPEDtemp (KAP_FACTRANS, KAP_CantTotADescargar, KAP_CANTDESC, KAP_INDICED_PED, KAP_INDICED_FACT, 
				MA_HIJO, KAP_TIPO_DESC, KAP_FisComp, KAP_PADRESUST)
		
			SELECT @CodigoFactura, KAP_CantTotADescargar, 'KAP_CANTDESC'=case when vPIDescarga.PID_SALDOGEN<=KARDESPEDtemp.KAP_Saldo_FED 
			then round(vPIDescarga.PID_SALDOGEN,6)
			else round(KARDESPEDtemp.KAP_Saldo_FED,6) end, vPIDescarga.PID_INDICED, KARDESPEDtemp.KAP_INDICED_FACT, vPIDescarga.MA_CODIGO,
			KARDESPEDtemp.KAP_TIPO_DESC, 'N', KARDESPEDtemp.KAP_PADRESUST
			FROM         KARDESPEDtemp INNER JOIN
			                      vPIDescarga ON KARDESPEDtemp.KAP_PADRESUST = vPIDescarga.MA_FAMILIAMP
			WHERE  (KARDESPEDtemp.KAP_Saldo_FED > 0) and
				KARDESPEDtemp.KAP_INDICED_FACT=@fed_indiced
				AND vPIDescarga.PID_INDICED IN 
				(SELECT     TOP 100 PERCENT MIN(vPIDescarga1.PID_INDICED)
				FROM         vPIDescarga vPIDescarga1
				WHERE     vPIDescarga1.PID_SALDOGEN > 0 AND 
				                      vPIDescarga1.MA_FAMILIAMP = KARDESPEDtemp.KAP_PADRESUST AND vPIDescarga1.PI_FEC_ENT IN
					(SELECT     TOP 100 PERCENT MIN(vPIDescarga2.PI_FEC_ENT) AS PI_FEC_ENT
					FROM         vPIDescarga vPIDescarga2
					WHERE     vPIDescarga2.pid_fechavence>=@fe_fecha and vPIDescarga2.PID_SALDOGEN > 0 AND 
					                      vPIDescarga2.MA_FAMILIAMP = KARDESPEDtemp.KAP_PADRESUST and vPIDescarga2.PI_FEC_ENT<= @fe_fecha))
		
		       and kap_codigo in (SELECT MAX(KAP_CODIGO) FROM KARDESPEDtemp WHERE (KAP_FACTRANS = @CodigoFactura) AND (KAP_INDICED_FACT = @fed_indiced)
			        GROUP BY KAP_PADRESUST)
			group by KAP_CantTotADescargar, vPIDescarga.PID_INDICED, KARDESPEDtemp.KAP_INDICED_FACT, vPIDescarga.MA_CODIGO, KARDESPEDtemp.KAP_PADRESUST,
			 KARDESPEDtemp.KAP_TIPO_DESC, vPIDescarga.PID_SALDOGEN, KARDESPEDtemp.KAP_Saldo_FED 

		end
	end
	else --ueps
	begin
		if @CF_DESCARGAVENCIDOS='S'
		begin

			INSERT INTO KARDESPEDtemp (KAP_FACTRANS, KAP_CantTotADescargar, KAP_CANTDESC, KAP_INDICED_PED, KAP_INDICED_FACT, 
				MA_HIJO, KAP_TIPO_DESC, KAP_FisComp, KAP_PADRESUST)
		
			SELECT @CodigoFactura, KAP_CantTotADescargar, 'KAP_CANTDESC'=case when vPIDescarga.PID_SALDOGEN<=KARDESPEDtemp.KAP_Saldo_FED 
			then round(vPIDescarga.PID_SALDOGEN,6)
			else round(KARDESPEDtemp.KAP_Saldo_FED,6) end, vPIDescarga.PID_INDICED, KARDESPEDtemp.KAP_INDICED_FACT, vPIDescarga.MA_CODIGO,
			KARDESPEDtemp.KAP_TIPO_DESC, 'N', KARDESPEDtemp.KAP_PADRESUST
			FROM         KARDESPEDtemp INNER JOIN
			                      vPIDescarga ON KARDESPEDtemp.KAP_PADRESUST = vPIDescarga.MA_FAMILIAMP
			WHERE  (KARDESPEDtemp.KAP_Saldo_FED > 0) and
				KARDESPEDtemp.KAP_INDICED_FACT=@fed_indiced
				AND vPIDescarga.PID_INDICED IN 
				(SELECT     TOP 100 PERCENT MAX(vPIDescarga1.PID_INDICED)
				FROM         vPIDescarga vPIDescarga1
				WHERE     vPIDescarga1.PID_SALDOGEN > 0 AND 
				                      vPIDescarga1.MA_FAMILIAMP = KARDESPEDtemp.KAP_PADRESUST AND vPIDescarga1.PI_FEC_ENT IN
					(SELECT     TOP 100 PERCENT MAX(vPIDescarga2.PI_FEC_ENT) AS PI_FEC_ENT
					FROM         vPIDescarga vPIDescarga2
					WHERE     vPIDescarga2.PID_SALDOGEN > 0 AND 
					                      vPIDescarga2.MA_FAMILIAMP = KARDESPEDtemp.KAP_PADRESUST and vPIDescarga2.PI_FEC_ENT<= @fe_fecha))
		
		       and kap_codigo in (SELECT MAX(KAP_CODIGO) FROM KARDESPEDtemp WHERE (KAP_FACTRANS = @CodigoFactura) AND (KAP_INDICED_FACT = @fed_indiced)
			        GROUP BY KAP_PADRESUST)
			group by KAP_CantTotADescargar, vPIDescarga.PID_INDICED, KARDESPEDtemp.KAP_INDICED_FACT, vPIDescarga.MA_CODIGO, KARDESPEDtemp.KAP_PADRESUST,
			 KARDESPEDtemp.KAP_TIPO_DESC, vPIDescarga.PID_SALDOGEN, KARDESPEDtemp.KAP_Saldo_FED 




		end
		else
		begin
			INSERT INTO KARDESPEDtemp (KAP_FACTRANS, KAP_CantTotADescargar, KAP_CANTDESC, KAP_INDICED_PED, KAP_INDICED_FACT, 
				MA_HIJO, KAP_TIPO_DESC, KAP_FisComp, KAP_PADRESUST)
		
			SELECT @CodigoFactura, KAP_CantTotADescargar, 'KAP_CANTDESC'=case when vPIDescarga.PID_SALDOGEN<=KARDESPEDtemp.KAP_Saldo_FED 
			then round(vPIDescarga.PID_SALDOGEN,6)
			else round(KARDESPEDtemp.KAP_Saldo_FED,6) end, vPIDescarga.PID_INDICED, KARDESPEDtemp.KAP_INDICED_FACT, vPIDescarga.MA_CODIGO,
			KARDESPEDtemp.KAP_TIPO_DESC, 'N', KARDESPEDtemp.KAP_PADRESUST
			FROM         KARDESPEDtemp INNER JOIN
			                      vPIDescarga ON KARDESPEDtemp.KAP_PADRESUST = vPIDescarga.MA_FAMILIAMP
			WHERE  (KARDESPEDtemp.KAP_Saldo_FED > 0) and
				KARDESPEDtemp.KAP_INDICED_FACT=@fed_indiced
				AND vPIDescarga.PID_INDICED IN 
				(SELECT     TOP 100 PERCENT MAX(vPIDescarga1.PID_INDICED)
				FROM         vPIDescarga vPIDescarga1
				WHERE     vPIDescarga1.PID_SALDOGEN > 0 AND 
				                      vPIDescarga1.MA_FAMILIAMP = KARDESPEDtemp.KAP_PADRESUST AND vPIDescarga1.PI_FEC_ENT IN
					(SELECT     TOP 100 PERCENT MAX(vPIDescarga2.PI_FEC_ENT) AS PI_FEC_ENT
					FROM         vPIDescarga vPIDescarga2
					WHERE     vPIDescarga2.pid_fechavence>=@fe_fecha and vPIDescarga2.PID_SALDOGEN > 0 AND 
					                      vPIDescarga2.MA_FAMILIAMP = KARDESPEDtemp.KAP_PADRESUST and vPIDescarga2.PI_FEC_ENT<= @fe_fecha))
		
		       and kap_codigo in (SELECT MAX(KAP_CODIGO) FROM KARDESPEDtemp WHERE (KAP_FACTRANS = @CodigoFactura) AND (KAP_INDICED_FACT = @fed_indiced)
			        GROUP BY KAP_PADRESUST)
			group by KAP_CantTotADescargar, vPIDescarga.PID_INDICED, KARDESPEDtemp.KAP_INDICED_FACT, vPIDescarga.MA_CODIGO, KARDESPEDtemp.KAP_PADRESUST,
			 KARDESPEDtemp.KAP_TIPO_DESC, vPIDescarga.PID_SALDOGEN, KARDESPEDtemp.KAP_Saldo_FED 



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
	WHERE KARDESPEDtemp.kap_codigo in (SELECT MAX(KAP_CODIGO) FROM KARDESPEDtemp 
						   WHERE  KAP_INDICED_FACT = @fed_indiced AND KAP_SALAFECTADO<>'S'
						  GROUP BY KAP_PADRESUST)


	UPDATE KARDESPEDTEMP
	SET KAP_SALAFECTADO='S'
	WHERE KAP_SALAFECTADO<>'S'


	delete from kardespedtemp where kap_indiced_fact=@fed_indiced 
	and kap_estatus='N' and kap_padresust in
	(select kap_padresust from kardespedtemp where kap_indiced_fact=@fed_indiced and kap_cantdesc>0)
	
	if @CF_DESCARGAVENCIDOS='S' 
	begin
		select @existe=count(pid_indiced) from vPIDescarga where pid_saldogen>0 and
		MA_FAMILIAMP in (select kap_padresust from kardespedtemp where kap_saldo_fed>0 and (kap_estatus<>'N' or kap_estatus is null) and kap_indiced_fact=@fed_indiced and kap_codigo in
		 (SELECT MAX(KAP_CODIGO) FROM KARDESPEDtemp WHERE (KAP_FACTRANS = @CodigoFactura) AND (KAP_INDICED_FACT = @fed_indiced)
			        GROUP BY KAP_PADRESUST)) and pi_fec_ent <=@fe_fecha

		while (@existe>0)
		begin
			goto inicio
		end
	end
	else
	begin

		select @existe=count(pid_indiced) from vPIDescarga where pid_saldogen>0 and
		MA_FAMILIAMP in (select kap_padresust from kardespedtemp where kap_saldo_fed>0 and (kap_estatus<>'N' or kap_estatus is null) and kap_indiced_fact=@fed_indiced and kap_codigo in
		 (SELECT MAX(KAP_CODIGO) FROM KARDESPEDtemp WHERE (KAP_FACTRANS = @CodigoFactura) AND (KAP_INDICED_FACT = @fed_indiced)
			        GROUP BY KAP_PADRESUST)) and pi_fec_ent <=@fe_fecha and vPIDescarga.pid_fechavence>=@fe_fecha
		while (@existe>0)
		begin
			goto inicio
		end

	end



























GO
