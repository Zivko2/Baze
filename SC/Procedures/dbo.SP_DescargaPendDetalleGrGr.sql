SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.SP_DescargaPendDetalleGrGr (@fed_indiced int, @MetodoDescarga Varchar(4), @tipodescarga varchar(2))   as

SET NOCOUNT ON 

	-- Variables para Cursor con datos de SubEnsables a Descargar
DECLARE @nFECODIGO Int, @nFEDCANT decimal(38,6), @MA_GENERICO Int, @BST_TIPODESC VARCHAR(5), @CF_DESCARGAVENCIDOS char(1), @padresust int,
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


	exec sp_droptable 'PendienteKargr'

		select kap_indiced_fact, kap_saldo_fed, Ma_generico, KAP_CantTotADescargar, KAP_TIPO_DESC,
		isnull(kardespedtemp.kap_padresust, kardespedtemp.ma_hijo) as ma_hijo,
		(select max(maestrocost.ma_costo) from maestrocost 
		where maestrocost.tco_codigo=(SELECT CASE WHEN MAESTRO.MA_TIP_ENS IN ('A', 'C', 'P') THEN 3 ELSE 1 END AS TCO_CODIGO from maestro where maestro.ma_codigo=ma_hijo)
		and maestrocost.ma_perini <= @fefecha and maestrocost.ma_perfin >= @fefecha and maestrocost.ma_codigo=isnull(kardespedtemp.kap_padresust, kardespedtemp.ma_hijo)) as ma_costo
		into dbo.PendienteKargr
		from kardespedtemp  left outer join maestro on isnull(kardespedtemp.kap_padresust,kardespedtemp.ma_hijo)=maestro.ma_codigo
		where kap_saldo_fed>0 and kap_indiced_fact=@fed_indiced --and kap_fiscomppadre<>'S'
		and (KAP_TIPO_DESC=left(@tipodescarga,1) or KAP_TIPO_DESC=right(@tipodescarga,1))
		and kap_codigo in
		 (select vkardespedtempn.kap_codigo from vkardespedtempn where  kap_indiced_fact=@fed_indiced) and ma_generico in 
		(select ma_generico from vPIDescarga where pid_saldogen>0 and pi_fec_ent <=@fefecha and ma_generico<>0)
		ORDER BY ma_hijo


		update PendienteKargr
		set Ma_generico= isnull((select ma_generico from maestrorefer where ma_codigo=ma_hijo),0)
		where (Ma_generico=0 or Ma_generico is null)


  DECLARE curMPNU CURSOR FOR
		select kap_indiced_fact, kap_saldo_fed, Ma_generico, KAP_CantTotADescargar, KAP_TIPO_DESC,
		ma_hijo, ma_costo+(ma_costo*@CF_DESCPORGENERICO), ma_costo-(ma_costo*@CF_DESCPORGENERICO)
		from PendienteKargr
		ORDER BY ma_hijo

  OPEN curMPNU
  FETCH NEXT FROM curMPNU
	INTO @fed_indiced, @RestaDescargar, @MA_GENERICO, @fQtyTotDesc, @BST_TIPODESC, @ma_hijo, @ma_costomax, @ma_costomin


  WHILE (@@fetch_status <> -1) 
  BEGIN  --1
    IF(@@fetch_status <> -2)
    BEGIN --2

		if @MA_GENERICO<>0 
		begin

			if @CF_DESCPORGENERICO=0 
			begin				
				IF @MetodoDescarga = 'PEPS'
				BEGIN --3a

					        DECLARE curPedimentos CURSOR FOR 
						SELECT PID_INDICED, PID_SALDOGEN, MA_CODIGO
						FROM VPIDescarga 
						WHERE MA_GENERICO IN (SELECT MA_CODIGOSUST
									FROM MAESTROSUST
									WHERE isnull(MA_CODIGOSUST,0)<>0 and MA_CODIGO = @MA_GENERICO) 
						ORDER BY PI_FEC_ENT ASC, PI_CODIGO ASC
				      END--3a
				ELSE
				      BEGIN --4a

						DECLARE curPedimentos CURSOR FOR 
						SELECT PID_INDICED, PID_SALDOGEN, MA_CODIGO
						FROM VPIDescarga
						WHERE MA_GENERICO IN (SELECT MA_CODIGOSUST
									FROM MAESTROSUST
									WHERE isnull(MA_CODIGOSUST,0)<>0 and MA_CODIGO = @MA_GENERICO) 
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
						WHERE MA_GENERICO IN (SELECT MA_CODIGOSUST
									FROM MAESTROSUST
									WHERE isnull(MA_CODIGOSUST,0)<>0 and MA_CODIGO = @MA_GENERICO) 
						AND ((PID_COS_UNIDLS=@ma_costomax or PID_COS_UNIDLS<@ma_costomax)and 
						 (PID_COS_UNIDLS=@ma_costomin or PID_COS_UNIDLS>@ma_costomin))							
						ORDER BY PI_FEC_ENT ASC, PI_CODIGO ASC

				      END--3a
				ELSE
				      BEGIN --4a

						DECLARE curPedimentos CURSOR FOR 
						SELECT PID_INDICED, PID_SALDOGEN, MA_CODIGO
						FROM VPIDescarga
						WHERE MA_GENERICO IN (SELECT MA_CODIGOSUST
									FROM MAESTROSUST
									WHERE isnull(MA_CODIGOSUST,0)<>0 and MA_CODIGO = @MA_GENERICO) 
						AND ((PID_COS_UNIDLS=@ma_costomax or PID_COS_UNIDLS<@ma_costomax)and 
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
			INTO @fed_indiced, @RestaDescargar, @MA_GENERICO, @fQtyTotDesc, @BST_TIPODESC, @ma_hijo, @ma_costomax, @ma_costomin


		END --2
	END --1
	CLOSE curMPNU
	DEALLOCATE curMPNU


	if exists (select * from kardespedtemp where ma_hijo in (select kap_padresust from kardespedtemp where  KAP_INDICED_FACT = @fed_indiced and isnull(kap_padresust,0)>0) 
	and kap_estatus='N' and  KAP_FisComp='N' and KAP_INDICED_FACT = @fed_indiced) 

	delete from kardespedtemp 
	where ma_hijo in (select kap_padresust from kardespedtemp where  KAP_INDICED_FACT = @fed_indiced and isnull(kap_padresust,0)>0) 
	and kap_estatus='N' and  KAP_FisComp='N' and KAP_INDICED_FACT = @fed_indiced


	exec sp_droptable 'PendienteKargr'


GO
