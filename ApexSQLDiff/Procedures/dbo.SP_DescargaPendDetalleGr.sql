SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE dbo.SP_DescargaPendDetalleGr (@fed_indiced int, @MetodoDescarga Varchar(4), @tipodescarga varchar(2))   as

SET NOCOUNT ON 

	-- Variables para Cursor con datos de SubEnsables a Descargar
DECLARE @nFECODIGO Int, @nFEDCANT decimal(38,6), @ma_generico Int, @BST_TIPODESC VARCHAR(5), @CF_DESCARGAVENCIDOS char(1), @padresust int,
@CodigoFactura Int, @ma_hijo int, @CF_DESCPORGENERICO decimal(38,6), @ma_costomax decimal(38,6), @ma_costomin decimal(38,6)



  -- Variables para Cursor con Datos de Pedimentos de Importacion
  DECLARE @nPIDINDICED Int, @fPIDSALDOGEN decimal(38,6), @MA_CODIGO int, @FechaActual VARCHAR(10)

	-- Variables para Valores Calculados/Obtenidos con algun SP
  DECLARE @fQtyADescargar decimal(38,6), @fQtyTotDesc decimal(38,6), @fSaldoPedimento decimal(38,6), @RestaDescargar decimal(38,6),
		@CF_USAEQUIVALENTE CHAR(1), @fefecha datetime
		


	SELECT    @CF_DESCARGAVENCIDOS=CF_DESCARGAVENCIDOS, @CF_DESCPORGENERICO=ISNULL(CF_DESCPORGENERICO,0)/100
	FROM         dbo.CONFIGURACION


	select @CodigoFactura=fe_codigo from factexpdet where fed_indiced=@fed_indiced
	select @fefecha = fe_fecha from factexp where fe_codigo = @CodigoFactura
	set @FechaActual= convert(varchar(10),getdate(),101)


		update kardespedtemp
		set kap_padresust= null
		where kap_padresust = 0


	exec sp_droptable 'PendienteKar'

		select kap_indiced_fact, kap_saldo_fed, Ma_generico, KAP_CantTotADescargar, KAP_TIPO_DESC,
		isnull(kardespedtemp.kap_padresust,kardespedtemp.ma_hijo) as ma_hijo,
		(select max(maestrocost.ma_costo) from maestrocost 
		where maestrocost.tco_codigo=(SELECT CASE WHEN MAESTRO.MA_TIP_ENS IN ('A', 'C', 'P') THEN 3 ELSE 1 END AS TCO_CODIGO from maestro where maestro.ma_codigo=ma_hijo)
		and maestrocost.ma_perini <= @fefecha and maestrocost.ma_perfin >= @fefecha and maestrocost.ma_codigo=isnull(kardespedtemp.kap_padresust, kardespedtemp.ma_hijo)) as ma_costo
		into dbo.PendienteKar
		from kardespedtemp  left outer join maestro on isnull(kardespedtemp.kap_padresust,kardespedtemp.ma_hijo)=maestro.ma_codigo
		where kap_saldo_fed>0 and kap_indiced_fact=@fed_indiced --and kap_fiscomppadre<>'S'
		and (KAP_TIPO_DESC=left(@tipodescarga,1) or KAP_TIPO_DESC=right(@tipodescarga,1))
		and kap_codigo in
		 (select vkardespedtempn.kap_codigo from vkardespedtempn where  kap_indiced_fact=@fed_indiced) and ma_generico in 
		(select ma_generico from vPIDescarga where pid_saldogen>0 and pi_fec_ent <=@fefecha and ma_generico<>0)
		ORDER BY ma_hijo


		update PendienteKar
		set Ma_generico= isnull((select ma_generico from maestrorefer where ma_codigo=ma_hijo),0)
		where (Ma_generico=0 or Ma_generico is null)


  DECLARE curMPNU CURSOR FOR
		select kap_indiced_fact, kap_saldo_fed, Ma_generico, KAP_CantTotADescargar, KAP_TIPO_DESC,
		ma_hijo, ma_costo+(ma_costo*@CF_DESCPORGENERICO), ma_costo-(ma_costo*@CF_DESCPORGENERICO)
		from PendienteKar
		ORDER BY ma_hijo

  OPEN curMPNU
  FETCH NEXT FROM curMPNU
	INTO @fed_indiced, @RestaDescargar, @ma_generico, @fQtyTotDesc, @BST_TIPODESC, @ma_hijo, @ma_costomax, @ma_costomin


  WHILE (@@fetch_status <> -1) 
  BEGIN  --1
    IF(@@fetch_status <> -2)
    BEGIN --2

		if @ma_generico<>0
		begin

			if @CF_DESCPORGENERICO=0 
			begin				
				IF @MetodoDescarga = 'PEPS'
				BEGIN --3a

					        DECLARE curPedimentos CURSOR FOR 
						SELECT PID_INDICED, PID_SALDOGEN, MA_CODIGO
						FROM VPIDescarga 
						WHERE (MA_GENERICO = @ma_generico) 
						ORDER BY PI_FEC_ENT ASC, PI_CODIGO ASC
				      END--3a
				ELSE
				      BEGIN --4a

						DECLARE curPedimentos CURSOR FOR 
						SELECT PID_INDICED, PID_SALDOGEN, MA_CODIGO
						FROM VPIDescarga
						WHERE (MA_GENERICO = @ma_generico) 
					        ORDER BY PI_FEC_ENT DESC, PI_CODIGO DESC

				      END --4a
			end
			else -- revision adicional de costo
			begin



				IF @MetodoDescarga = 'PEPS'
				BEGIN --3a

					        DECLARE curPedimentos CURSOR FOR 
						SELECT PID_INDICED, PID_SALDOGEN, MA_CODIGO
						FROM VPIDescarga 
						WHERE(MA_GENERICO = @ma_generico) AND 
						 ((PID_COS_UNIDLS=@ma_costomax or PID_COS_UNIDLS<@ma_costomax)and 
						 (PID_COS_UNIDLS=@ma_costomin or PID_COS_UNIDLS>@ma_costomin))							
						ORDER BY PI_FEC_ENT ASC, PI_CODIGO ASC

				      END--3a
				ELSE
				      BEGIN --4a

						DECLARE curPedimentos CURSOR FOR 
						SELECT PID_INDICED, PID_SALDOGEN, MA_CODIGO
						FROM VPIDescarga
						WHERE (MA_GENERICO = @ma_generico) AND 
						 ((PID_COS_UNIDLS=@ma_costomax or PID_COS_UNIDLS<@ma_costomax)and 
						 (PID_COS_UNIDLS=@ma_costomin or PID_COS_UNIDLS>@ma_costomin))
					        ORDER BY PI_FEC_ENT DESC, PI_CODIGO DESC

				      END --4a


			end	
	
		      OPEN curPedimentos
		      FETCH NEXT FROM curPedimentos 
		
					INTO @nPIDINDICED, @fPIDSALDOGEN, @MA_CODIGO
		
		      WHILE (@@fetch_status <> -1)
		      BEGIN  --5
	


					if @RestaDescargar>0
					begin

						SET @fQtyADescargar = ROUND(@RestaDescargar,6)   --Cantidad a descargar (o descargada)  = salod por descargar
						SET @fSaldoPedimento = ROUND(ROUND(@fPIDSALDOGEN,6) - round(@fQtyADescargar,6),6) -- saldo posterior del ped = saldo actual menos cantidad a descargar
		
						
						IF(@fSaldoPedimento < 0)  -- si saldo posterior es negativo
						BEGIN --7
							SET @RestaDescargar = ABS(@fSaldoPedimento) -- cantidad que queda a descargar = al saldo negativo (absoluto)
							SET @fQtyADescargar =  ROUND(@fPIDSALDOGEN,6) -- cantidad descargada = saldo anterior (porque es lo que le quedaba)
							SET @fSaldoPedimento = 0 --saldo del pedimento =0
						END --7
						ELSE
						BEGIN --8
							SET @RestaDescargar = 0 -- si saldo posterior no es < a cero entonces cant. que queda por descargar igual a cero
						END --8				


	
						INSERT INTO KARDESPEDtemp
						(
							KAP_FACTRANS, 
							KAP_INDICED_FACT, 
							KAP_INDICED_PED, 
							MA_HIJO, 
							KAP_TIPO_DESC, 
							KAP_CANTDESC, 
							KAP_CantTotADescargar,
							KAP_Saldo_FED,
							kap_fiscomp,
							Kap_PadreSust
						)
						VALUES (
							@CodigoFactura, 
							@fed_indiced, 
							@nPIDINDICED, 
							@MA_CODIGO,
							@BST_TIPODESC, 
							@fQtyADescargar, 
	 						@fQtyTotDesc,
							@RestaDescargar,
							'N',
							@ma_hijo
	
						)			


						UPDATE PEDIMP 
						SET PI_AFECTADO = 'S' 
						WHERE PI_CODIGO IN (SELECT PI_CODIGO FROM PIDESCARGA WHERE pid_indiced=@nPidIndiced)
						and PI_AFECTADO <> 'S'

						UPDATE PIDESCARGA
						SET PID_SALDOGEN=@fSaldoPedimento
						WHERE PID_INDICED=@nPidIndiced

					end

									
					IF (@RestaDescargar = 0) 
					BREAK --Jump out of Pedimentou Cycle

				FETCH NEXT FROM curPedimentos 
				INTO @nPIDINDICED, @fPIDSALDOGEN, @MA_CODIGO
	
				END  --5
				CLOSE curPedimentos
	
			DEALLOCATE curPedimentos

		end


		  FETCH NEXT FROM curMPNU
			INTO @fed_indiced, @RestaDescargar, @ma_generico, @fQtyTotDesc, @BST_TIPODESC, @ma_hijo, @ma_costomax, @ma_costomin


		END --2
	END --1
	CLOSE curMPNU
	DEALLOCATE curMPNU


	if exists (select * from kardespedtemp where ma_hijo in (select kap_padresust from kardespedtemp where  KAP_INDICED_FACT = @fed_indiced and isnull(kap_padresust,0)>0) 
	and kap_estatus='N' and  KAP_FisComp='N' and KAP_INDICED_FACT = @fed_indiced) 

	delete from kardespedtemp 
	where ma_hijo in (select kap_padresust from kardespedtemp where  KAP_INDICED_FACT = @fed_indiced and isnull(kap_padresust,0)>0) 
	and kap_estatus='N' and  KAP_FisComp='N' and KAP_INDICED_FACT = @fed_indiced


/*	if exists (select * from kardespedtemp 	
	where ma_hijo in (select kap_padremain from kardespedtemp where  KAP_INDICED_FACT = @fed_indiced) 
	and (kap_padresust<>0 and kap_padresust is not null)
	and kap_estatus='N' and  KAP_FisComp='S' and KAP_INDICED_FACT = @fed_indiced)

	delete from kardespedtemp 
	where ma_hijo in (select kap_padremain from kardespedtemp where  KAP_INDICED_FACT = @fed_indiced) 
	and (kap_padresust<>0 and kap_padresust is not null)
	and kap_estatus='N' and  KAP_FisComp='S' and KAP_INDICED_FACT = @fed_indiced
*/

	exec sp_droptable 'PendienteKar'



/*declare @existe int, @CF_DESCARGAVENCIDOS char(1), @CodigoFactura Int, @fe_fecha Varchar(11)


--	if @padre is null
--	set @padre=0

	SELECT    @CF_DESCARGAVENCIDOS=CF_DESCARGAVENCIDOS
	FROM         CONFIGURACION

	select @CodigoFactura=fe_codigo from factexpdet where fed_indiced=@fed_indiced
	select @fe_fecha =convert(varchar(11), fe_fecha,101) from factexp where fe_codigo = @CodigoFactura

	print 'entro a sp_DescargaPendDetalleGr'


inicio:

	begin tran

		if @MetodoDescarga='PEPS'
		begin
			if @CF_DESCARGAVENCIDOS='S'
			begin
				INSERT INTO KARDESPEDtemp (KAP_FACTRANS, KAP_CantTotADescargar, KAP_CANTDESC, KAP_INDICED_PED, KAP_INDICED_FACT, 
					MA_HIJO, KAP_TIPO_DESC, KAP_FisComp, KAP_PADREMAIN, KAP_PADRESUST)
			
				SELECT @CodigoFactura, KAP_CantTotADescargar, 'KAP_CANTDESC'=case when vPIDescarga.PID_SALDOGEN<=KARDESPEDtemp.KAP_Saldo_FED 
				then round(vPIDescarga.PID_SALDOGEN,6)
				else round(KARDESPEDtemp.KAP_Saldo_FED,6) end, vPIDescarga.PID_INDICED, KARDESPEDtemp.KAP_INDICED_FACT, KARDESPEDtemp.MA_HIJO,
				KARDESPEDtemp.KAP_TIPO_DESC, KARDESPEDtemp.KAP_FISCOMP, 
				'kap_padreMain'=case when KARDESPEDtemp.KAP_FISCOMP='N' then 0 else KARDESPEDtemp.MA_HIJO end,
				 'kap_padresust'=case when KARDESPEDtemp.KAP_FISCOMP='N' then  KARDESPEDtemp.MA_HIJO else KARDESPEDtemp.kap_padresust end
				FROM         KARDESPEDtemp INNER JOIN MAESTRO ON KARDESPEDtemp.MA_HIJO = MAESTRO.MA_CODIGO
					INNER JOIN vPIDescarga ON MAESTRO.MA_GENERICO = vPIDescarga.MA_GENERICO
					
				WHERE  (KARDESPEDtemp.KAP_Saldo_FED > 0) and
					KARDESPEDtemp.KAP_INDICED_FACT=@fed_indiced 
					AND vPIDescarga.PID_INDICED IN 
					(SELECT     TOP 100 PERCENT MIN(vPIDescarga1.PID_INDICED)
					FROM         vPIDescarga vPIDescarga1
					WHERE     vPIDescarga1.PID_SALDOGEN > 0 AND 
					                      vPIDescarga1.MA_GENERICO = MAESTRO.MA_GENERICO AND vPIDescarga1.PI_FEC_ENT IN
						(SELECT     TOP 100 PERCENT MIN(vPIDescarga2.PI_FEC_ENT) AS PI_FEC_ENT
						FROM         vPIDescarga vPIDescarga2
						WHERE     vPIDescarga2.PID_SALDOGEN > 0 AND 
						                      vPIDescarga2.MA_GENERICO = MAESTRO.MA_GENERICO and vPIDescarga2.PI_FEC_ENT<= @fe_fecha))
				       and kap_fiscomppadre<>'S' and (KAP_TIPO_DESC=left(@tipodescarga,1) or KAP_TIPO_DESC=right(@tipodescarga,1))	
				       and kap_codigo in (select VKARDESPEDTempNGen.kap_codigo from VKARDESPEDTempNGen where  kap_indiced_fact=@fed_indiced) and MAESTRO.ma_generico in 
				                 (select ma_generico from PIDescarga where pid_saldogen>0 and pi_fec_ent <=@fe_fecha and pi_activofijo='N' and ma_generico<>0)
				group by KAP_CantTotADescargar, vPIDescarga.PID_INDICED, KARDESPEDtemp.KAP_INDICED_FACT, KARDESPEDtemp.MA_HIJO,
				 KARDESPEDtemp.KAP_TIPO_DESC,KARDESPEDtemp.KAP_FISCOMP,  vPIDescarga.PID_SALDOGEN, KARDESPEDtemp.KAP_Saldo_FED, KARDESPEDtemp.kap_padresust 
			end
			else
			begin
				INSERT INTO KARDESPEDtemp (KAP_FACTRANS, KAP_CantTotADescargar, KAP_CANTDESC, KAP_INDICED_PED, KAP_INDICED_FACT, 
					MA_HIJO, KAP_TIPO_DESC, KAP_FisComp, KAP_PADREMAIN, KAP_PADRESUST)
			
				SELECT @CodigoFactura, KAP_CantTotADescargar, 'KAP_CANTDESC'=case when vPIDescarga.PID_SALDOGEN<=KARDESPEDtemp.KAP_Saldo_FED 
				then round(vPIDescarga.PID_SALDOGEN,6)
				else round(KARDESPEDtemp.KAP_Saldo_FED,6) end, vPIDescarga.PID_INDICED, KARDESPEDtemp.KAP_INDICED_FACT, KARDESPEDtemp.MA_HIJO,
				 KARDESPEDtemp.KAP_TIPO_DESC,KARDESPEDtemp.KAP_FISCOMP, 
				'kap_padreMain'=case when KARDESPEDtemp.KAP_FISCOMP='N' then 0 else KARDESPEDtemp.MA_HIJO end,
				 'kap_padresust'=case when KARDESPEDtemp.KAP_FISCOMP='N' then  KARDESPEDtemp.MA_HIJO else KARDESPEDtemp.kap_padresust end
				FROM         KARDESPEDtemp INNER JOIN MAESTRO ON KARDESPEDtemp.MA_HIJO = MAESTRO.MA_CODIGO
					INNER JOIN vPIDescarga ON MAESTRO.MA_GENERICO = vPIDescarga.MA_GENERICO
				WHERE  (KARDESPEDtemp.KAP_Saldo_FED > 0) and
					KARDESPEDtemp.KAP_INDICED_FACT=@fed_indiced
					AND vPIDescarga.PID_INDICED IN 
					(SELECT     TOP 100 PERCENT MIN(vPIDescarga1.PID_INDICED)
					FROM         vPIDescarga vPIDescarga1
					WHERE     vPIDescarga1.pid_fechavence>=@fe_fecha AND vPIDescarga1.PID_SALDOGEN > 0 AND 
					          vPIDescarga1.MA_GENERICO = MAESTRO.MA_GENERICO AND vPIDescarga1.PI_FEC_ENT IN
						(SELECT     TOP 100 PERCENT MIN(vPIDescarga2.PI_FEC_ENT) AS PI_FEC_ENT
						FROM         vPIDescarga vPIDescarga2
						WHERE     vPIDescarga2.pid_fechavence>=@fe_fecha AND vPIDescarga2.PID_SALDOGEN > 0 AND 	
						                      vPIDescarga2.MA_GENERICO = MAESTRO.MA_GENERICO and vPIDescarga2.PI_FEC_ENT<= @fe_fecha))
				
				       and kap_fiscomppadre<>'S' and (KAP_TIPO_DESC=left(@tipodescarga,1) or KAP_TIPO_DESC=right(@tipodescarga,1))	
				       and kap_codigo in (select VKARDESPEDTempNGen.kap_codigo from VKARDESPEDTempNGen where  kap_indiced_fact=@fed_indiced) and MAESTRO.ma_generico in 
				                 (select ma_generico from PIDescarga where pid_saldogen>0 and pi_fec_ent <=@fe_fecha and pi_activofijo='N' and ma_generico<>0)

				group by KAP_CantTotADescargar, vPIDescarga.PID_INDICED, KARDESPEDtemp.KAP_INDICED_FACT, KARDESPEDtemp.MA_HIJO,
				 KARDESPEDtemp.KAP_TIPO_DESC, KARDESPEDtemp.KAP_FISCOMP,  vPIDescarga.PID_SALDOGEN, KARDESPEDtemp.KAP_Saldo_FED, KARDESPEDtemp.kap_padresust 
	
			end
		end
		else -- UEPS
		begin
			if @CF_DESCARGAVENCIDOS='S'
			begin
				INSERT INTO KARDESPEDtemp (KAP_FACTRANS, KAP_CantTotADescargar, KAP_CANTDESC, KAP_INDICED_PED, KAP_INDICED_FACT, 
					MA_HIJO,KAP_TIPO_DESC, KAP_FisComp, KAP_PADREMAIN, KAP_PADRESUST)
			
				SELECT @CodigoFactura, KAP_CantTotADescargar, 'KAP_CANTDESC'=case when vPIDescarga.PID_SALDOGEN<=KARDESPEDtemp.KAP_Saldo_FED 
				then round(vPIDescarga.PID_SALDOGEN,6)
				else round(KARDESPEDtemp.KAP_Saldo_FED,6) end, vPIDescarga.PID_INDICED, KARDESPEDtemp.KAP_INDICED_FACT, KARDESPEDtemp.MA_HIJO,
				KARDESPEDtemp.KAP_TIPO_DESC, KARDESPEDtemp.KAP_FISCOMP, 
				'kap_padreMain'=case when KARDESPEDtemp.KAP_FISCOMP='N' then 0 else KARDESPEDtemp.MA_HIJO end,
				 'kap_padresust'=case when KARDESPEDtemp.KAP_FISCOMP='N' then  KARDESPEDtemp.MA_HIJO else KARDESPEDtemp.kap_padresust end
				FROM         KARDESPEDtemp INNER JOIN MAESTRO ON KARDESPEDtemp.MA_HIJO = MAESTRO.MA_CODIGO
					INNER JOIN vPIDescarga ON MAESTRO.MA_GENERICO = vPIDescarga.MA_GENERICO
				WHERE  (KARDESPEDtemp.KAP_Saldo_FED > 0) and
					KARDESPEDtemp.KAP_INDICED_FACT=@fed_indiced
					AND vPIDescarga.PID_INDICED IN 
					(SELECT     TOP 100 PERCENT MAX(vPIDescarga1.PID_INDICED)
					FROM         vPIDescarga vPIDescarga1
					WHERE     vPIDescarga1.PID_SALDOGEN > 0 AND 
					                      vPIDescarga1.MA_GENERICO = MAESTRO.MA_GENERICO AND vPIDescarga1.PI_FEC_ENT IN
						(SELECT     TOP 100 PERCENT MAX(vPIDescarga2.PI_FEC_ENT) AS PI_FEC_ENT
						FROM         vPIDescarga vPIDescarga2
						WHERE     vPIDescarga2.PID_SALDOGEN > 0 AND 
						                      vPIDescarga2.MA_GENERICO = MAESTRO.MA_GENERICO and vPIDescarga2.PI_FEC_ENT<= @fe_fecha))
			
				       and kap_fiscomppadre<>'S' and (KAP_TIPO_DESC=left(@tipodescarga,1) or KAP_TIPO_DESC=right(@tipodescarga,1))	
				       and kap_codigo in (select VKARDESPEDTempNGen.kap_codigo from VKARDESPEDTempNGen where  kap_indiced_fact=@fed_indiced) and MAESTRO.ma_generico in 
				                 (select ma_generico from PIDescarga where pid_saldogen>0 and pi_fec_ent <=@fe_fecha and pi_activofijo='N' and ma_generico<>0)

				group by KAP_CantTotADescargar, vPIDescarga.PID_INDICED, KARDESPEDtemp.KAP_INDICED_FACT, KARDESPEDtemp.MA_HIJO,
				 KARDESPEDtemp.KAP_TIPO_DESC,KARDESPEDtemp.KAP_FISCOMP,  vPIDescarga.PID_SALDOGEN, KARDESPEDtemp.KAP_Saldo_FED, KARDESPEDtemp.kap_padresust
			end
			else
			begin
				INSERT INTO KARDESPEDtemp (KAP_FACTRANS, KAP_CantTotADescargar, KAP_CANTDESC, KAP_INDICED_PED, KAP_INDICED_FACT, 
					MA_HIJO,  KAP_TIPO_DESC,KAP_FisComp, KAP_PADREMAIN, KAP_PADRESUST)
			
				SELECT @CodigoFactura, KAP_CantTotADescargar, 'KAP_CANTDESC'=case when vPIDescarga.PID_SALDOGEN<=KARDESPEDtemp.KAP_Saldo_FED 
				then round(vPIDescarga.PID_SALDOGEN,6)
				else round(KARDESPEDtemp.KAP_Saldo_FED,6) end, vPIDescarga.PID_INDICED, KARDESPEDtemp.KAP_INDICED_FACT, KARDESPEDtemp.MA_HIJO,
				 KARDESPEDtemp.KAP_TIPO_DESC, KARDESPEDtemp.KAP_FISCOMP, 
				'kap_padreMain'=case when KARDESPEDtemp.KAP_FISCOMP='N' then 0 else KARDESPEDtemp.MA_HIJO end,
				 'kap_padresust'=case when KARDESPEDtemp.KAP_FISCOMP='N' then  KARDESPEDtemp.MA_HIJO else KARDESPEDtemp.kap_padresust end
				FROM         KARDESPEDtemp INNER JOIN MAESTRO ON KARDESPEDtemp.MA_HIJO = MAESTRO.MA_CODIGO
					INNER JOIN vPIDescarga ON MAESTRO.MA_GENERICO = vPIDescarga.MA_GENERICO
				WHERE  (KARDESPEDtemp.KAP_Saldo_FED > 0) and
					KARDESPEDtemp.KAP_INDICED_FACT=@fed_indiced
					AND vPIDescarga.PID_INDICED IN 
					(SELECT     TOP 100 PERCENT MAX(vPIDescarga1.PID_INDICED)
					FROM         vPIDescarga vPIDescarga1
					WHERE     vPIDescarga1.pid_fechavence>=@fe_fecha AND vPIDescarga1.PID_SALDOGEN > 0 AND 
					          vPIDescarga1.MA_GENERICO = MAESTRO.MA_GENERICO AND vPIDescarga1.PI_FEC_ENT IN
						(SELECT     TOP 100 PERCENT MAX(vPIDescarga2.PI_FEC_ENT) AS PI_FEC_ENT
						FROM         vPIDescarga vPIDescarga2
						WHERE     vPIDescarga2.pid_fechavence>=@fe_fecha AND vPIDescarga2.PID_SALDOGEN > 0 AND 
						                     vPIDescarga2.MA_GENERICO = MAESTRO.MA_GENERICO and vPIDescarga2.PI_FEC_ENT<= @fe_fecha))
				
				       and kap_fiscomppadre<>'S' and (KAP_TIPO_DESC=left(@tipodescarga,1) or KAP_TIPO_DESC=right(@tipodescarga,1))	
				       and kap_codigo in (select VKARDESPEDTempNGen.kap_codigo from VKARDESPEDTempNGen where  kap_indiced_fact=@fed_indiced) and MAESTRO.ma_generico in 
				                 (select ma_generico from PIDescarga where pid_saldogen>0 and pi_fec_ent <=@fe_fecha and pi_activofijo='N' and ma_generico<>0)

				group by KAP_CantTotADescargar, vPIDescarga.PID_INDICED, KARDESPEDtemp.KAP_INDICED_FACT, KARDESPEDtemp.MA_HIJO,
				 KARDESPEDtemp.KAP_TIPO_DESC, KARDESPEDtemp.KAP_FISCOMP,  vPIDescarga.PID_SALDOGEN, KARDESPEDtemp.KAP_Saldo_FED, KARDESPEDtemp.kap_padresust 
	
	
			end
		end

	commit tran


	-- ==== actualizando KAP_Saldo_FED ===
	begin tran
		UPDATE    KARDESPEDtemp
		SET             KAP_Saldo_FED = 0
		WHERE     (KAP_CANTDESC = KAP_CantTotADescargar)
		and  KAP_Saldo_FED  is null
	
		update kardespedtemp
		set kardespedtemp.KAP_Saldo_FED= round(kardespedtemp.KAP_CantTotADescargar-isnull((SELECT     SUM(kardespedtemp1.KAP_CANTDESC) FROM kardespedtemp as kardespedtemp1
							WHERE     (kardespedtemp1.MA_HIJO = kardespedtemp.MA_HIJO) AND (kardespedtemp1.KAP_INDICED_FACT = kardespedtemp.KAP_INDICED_FACT)),0),6)
		where kardespedtemp.KAP_Saldo_FED is null

	commit tran


	-- ==== actualizando SALDO Pedimento ===
	begin tran   

		UPDATE PIDescarga
		SET     PIDescarga.PID_SALDOGEN= (case WHEN PIDescarga.PID_SALDOGEN<=round(KARDESPEDtemp.KAP_CANTDESC,6)  then 0
		else round(PIDescarga.PID_SALDOGEN-round(KARDESPEDtemp.KAP_CANTDESC,6),6) end)
		FROM         KARDESPEDtemp INNER JOIN
		                  PIDescarga ON KARDESPEDtemp.KAP_INDICED_PED = PIDescarga.PID_INDICED
		WHERE KARDESPEDtemp.kap_codigo in (SELECT MAX(KAP_CODIGO) FROM KARDESPEDtemp 
				WHERE (KAP_FACTRANS = @CodigoFactura) AND (KAP_INDICED_FACT = @fed_indiced) AND KAP_SALAFECTADO<>'S'
			        GROUP BY MA_HIJO)
	commit tran
	

	begin tran
		UPDATE KARDESPEDTEMP
		SET KAP_SALAFECTADO='S'
		WHERE KAP_SALAFECTADO<>'S'	
	commit tran

	exec SP_ESTATUSKARDESPEDFED @fed_indiced


	delete from kardespedtemp where kap_indiced_fact=@fed_indiced and kap_cantdesc=0 and kap_fiscomp='S'
	and ma_hijo in (select k1.kap_padremain from kardespedtemp k1 where k1.kap_indiced_fact=@fed_indiced and k1.kap_cantdesc>0 and  k1.kap_fiscomp='S' and k1.kap_padresust = kardespedtemp.kap_padresust)


	delete from kardespedtemp where kap_indiced_fact=@fed_indiced and kap_cantdesc=0 and kap_fiscomp<>'S'
	and ma_hijo in (select k1.kap_padresust from kardespedtemp k1 where k1.kap_indiced_fact=@fed_indiced and k1.kap_cantdesc>0 and k1.kap_fiscomp<>'S')




		if @CF_DESCARGAVENCIDOS='S' 
		begin
				select @existe=COUNT(kap_indiced_fact)
				from kardespedtemp  left outer join maestro on kardespedtemp.ma_hijo=maestro.ma_codigo
				where kap_saldo_fed>0 and kap_indiced_fact=@fed_indiced and kap_fiscomppadre<>'S'
				and (KAP_TIPO_DESC=left(@tipodescarga,1) or KAP_TIPO_DESC=right(@tipodescarga,1))
				and kap_codigo in
				 (select VKARDESPEDTempNGen.kap_codigo from VKARDESPEDTempNGen where  kap_indiced_fact=@fed_indiced) and ma_generico in 
				(select ma_generico from vPIDescarga where pid_saldogen>0 and pi_fec_ent <=@fe_fecha and ma_generico<>0)


			while (@existe>0)
			begin
				goto inicio
			end
		end
		else
		begin
				select @existe=COUNT(kap_indiced_fact)
				from kardespedtemp  left outer join maestro on kardespedtemp.ma_hijo=maestro.ma_codigo
				where kap_saldo_fed>0 and kap_indiced_fact=@fed_indiced and kap_fiscomppadre<>'S'
				and (KAP_TIPO_DESC=left(@tipodescarga,1) or KAP_TIPO_DESC=right(@tipodescarga,1))
				and kap_codigo in
				 (select VKARDESPEDTempNGen.kap_codigo from VKARDESPEDTempNGen where  kap_indiced_fact=@fed_indiced) and ma_generico in 
				(select ma_generico from vPIDescarga where pid_saldogen>0 and pi_fec_ent <=@fe_fecha  and ma_generico<>0
				and vPIDescarga.pid_fechavence>=@fe_fecha)

			while (@existe>0)
			begin
				goto inicio
			end
		end*/

GO
