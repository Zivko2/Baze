SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_descargaDetalleEquivale] (@fed_indiced Int, @MetodoDescarga Varchar(4), @tipodescarga varchar(2))    as
   -- Variables para Cursor con Datos de Pedimentos de Importacion
  DECLARE @nPIDINDICED Int, @fPIDSALDOGEN decimal(38,6), @SUMKAP_CANTDESC0 decimal(38,6), @CF_DESCARGAVENCIDOS char(1), @fe_codigo Int, @ma_hijo int,
@destinofin char(1), @BST_TIPODESC CHAR(1), @tempcantsum DECIMAL(38,6)

	-- Variables para Valores Calculados/Obtenidos con algun SP
  DECLARE @RestaDescargar decimal(38,6), @fQtyADescargar decimal(38,6), @fQtyTotDesc decimal(38,6), @fSaldoPedimento decimal(38,6), @fSaldoDescargar decimal(38,6),
		@cDescargaStatus Char(1), @vKapTipoEns Char(1), @nBSTHIJO int, @CF_SECTOR char(1), @SUMKAP_CANTDESC decimal(38,6), 
		@MA_CODIGO INT, @fe_fecha varchar(10), @KAP_TIPO_DESC varchar(1), @NoDescargadaQty DECIMAL(38,6)


	select @CF_DESCARGAVENCIDOS=CF_DESCARGAVENCIDOS from configuracion

	select @fe_codigo=fe_codigo from factexpdet where fed_indiced=@fed_indiced

	select @fe_fecha = convert(varchar(10),fe_fecha,101) from factexp where fe_codigo = @fe_codigo


	SELECT @destinofin= CASE 
	when dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT CF_PAIS_MX FROM CONFIGURACION) 
	 or dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT CF_PAIS_USA FROM CONFIGURACION) or dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT CF_PAIS_CA FROM CONFIGURACION)
	then 'N'  else 'F' end
	FROM  dbo.FACTEXP LEFT OUTER JOIN
	      dbo.DIR_CLIENTE ON dbo.FACTEXP.DI_DESTFIN = dbo.DIR_CLIENTE.DI_INDICE
	WHERE (dbo.FACTEXP.FE_CODIGO = @fe_codigo)


	-- Tabla temporal donde llevamos una cola para asignar el Estatus
  CREATE TABLE [dbo].[#KardespedStatusQueu]
  (	
		TKapCodigo Int NOT NULL
	)

	exec sp_droptable 'PendienteEquivale'

	SELECT  KARDESPEDtemp.KAP_CantTotADescargar, KARDESPEDtemp.KAP_Saldo_FED, 
                KARDESPEDtemp.MA_HIJO, KAP_TIPO_DESC
	into dbo.PendienteEquivale
	FROM    KARDESPEDtemp INNER JOIN
	                      MAESTROSUST ON KARDESPEDtemp.MA_HIJO = MAESTROSUST.MA_CODIGO 
	--Yolanda Avila (2009-11-17) --Proceso de regreso a la 33
	--WHERE  (KARDESPEDtemp.KAP_Saldo_FED > 0) and kap_fiscomppadre<>'S'
	WHERE  (KARDESPEDtemp.KAP_Saldo_FED > 0) --and kap_fiscomppadre<>'S'
       and (kap_codigo in (SELECT MAX(KAP_CODIGO) FROM KARDESPEDtemp WHERE (KAP_Indiced_Fact = @fed_indiced)
	        AND MA_HIJO=KARDESPEDtemp.MA_HIJO AND isnull(KAP_PADRESUST,0)=isnull(KARDESPEDtemp.KAP_PADRESUST,0)
	        GROUP BY MA_HIJO, isnull(KAP_PADRESUST,0))) 

	and (KAP_TIPO_DESC=left(@tipodescarga,1) or KAP_TIPO_DESC=right(@tipodescarga,1))
	group by KAP_CantTotADescargar, KARDESPEDtemp.MA_HIJO, KARDESPEDtemp.KAP_Saldo_FED, KAP_TIPO_DESC


-- ahorita la equivalencia del equivalente no se esta usando, hasta que se encuentre la forma de sacar la suma de la cant. total descargada de todos
--los registros con ese hijo incluyendo los equivalentes aun que se haga la conversion, es decir que unque unos tengan el grupo en pzas y otro en 
--kilogramos descargue en la um correspondiente y al final poder sacar la sumatoria en pzas de se lleva descargado (um original) 

  DECLARE curMPNUsust3 CURSOR FOR
	SELECT  KAP_CantTotADescargar, KAP_Saldo_FED, MA_HIJO, KAP_TIPO_DESC
	FROM    PendienteEquivale
	ORDER BY MA_HIJO
  OPEN curMPNUsust3
  FETCH NEXT FROM curMPNUsust3
	INTO @fQtyTotDesc, @RestaDescargar , @ma_hijo, @KAP_TIPO_DESC

  WHILE (@@fetch_status <> -1) 
  BEGIN  --1
    IF(@@fetch_status <> -2)
    BEGIN --2


				IF @MetodoDescarga = 'PEPS'
				BEGIN --3a

					        DECLARE curPedimentos CURSOR FOR 
						SELECT PID_INDICED, PID_SALDOGEN, MA_CODIGO
						FROM vPIDescarga 
						WHERE (PID_SALDOGEN > 0) 
						and ma_codigo in (SELECT MA_CODIGOSUST FROM MAESTROSUST 
								WHERE MAESTROSUST.MA_CODIGO=@ma_hijo)
								AND (PI_FEC_ENT <= @fe_fecha) 
						ORDER BY PI_FEC_ENT ASC, PI_CODIGO ASC
			        END--3a
				ELSE
				      BEGIN --4a

						DECLARE curPedimentos CURSOR FOR 
						SELECT PID_INDICED, PID_SALDOGEN, MA_CODIGO
						FROM vPIDescarga 
						WHERE (PID_SALDOGEN > 0) 
						and ma_codigo in (SELECT MA_CODIGOSUST FROM MAESTROSUST 
								WHERE MAESTROSUST.MA_CODIGO=@ma_hijo)
								AND (PI_FEC_ENT <= @fe_fecha) 
						ORDER BY PI_FEC_ENT DESC, PI_CODIGO DESC

				      END --4a
	

	      OPEN curPedimentos
	      FETCH NEXT FROM curPedimentos 
	
				INTO @nPIDINDICED, @fPIDSALDOGEN, @MA_CODIGO
	
	      WHILE (@@fetch_status <> -1)
	      BEGIN  --5

					if @RestaDescargar>0
					begin
						--Aqui manipulamos las cantidades
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

						
					--*******************************

	
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
							KAP_FisComp,
							Kap_PadreSust

						)
						VALUES (
							@fe_codigo, 
							@fed_indiced, 
							@nPIDINDICED, 
							@MA_CODIGO,
							@KAP_TIPO_DESC, 
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


		  FETCH NEXT FROM curMPNUsust3
				INTO @fQtyTotDesc, @RestaDescargar , @ma_hijo, @KAP_TIPO_DESC


		END --2
	END --1
	CLOSE curMPNUsust3

	DEALLOCATE curMPNUsust3


	if exists (select * from kardespedtemp where ma_hijo in (select kap_padresust from kardespedtemp where  KAP_INDICED_FACT = @fed_indiced and isnull(kap_padresust,0) >0)
	and kap_estatus='N' and  KAP_FisComp='N' and KAP_INDICED_FACT = @fed_indiced) 

	delete from kardespedtemp 
	where ma_hijo in (select kap_padresust from kardespedtemp where  KAP_INDICED_FACT = @fed_indiced and isnull(kap_padresust,0) >0) 
	and kap_estatus='N' and  KAP_FisComp='N' and KAP_INDICED_FACT = @fed_indiced

	exec sp_droptable 'PendienteEquivale'


/*
   DECLARE curMPNUSust CURSOR FOR
	SELECT  KAP_CantTotADescargar, KAP_Saldo_FED, MA_HIJO, KAP_TIPO_DESC, KAP_FISCOMP, Kap_PadreSust
	FROM    PendienteEquivale
	ORDER BY MA_HIJO


  OPEN curMPNUSust
  FETCH NEXT FROM curMPNUSust
	INTO @fQtyTotDesc, @RestaDescargar, @ma_hijo, @BST_TIPODESC, @kap_fiscomp, @kap_padresust

  WHILE (@@fetch_status = 0) 
  BEGIN  --1
  --  IF(@@fetch_status <> -2)
  --  BEGIN --2
	      DECLARE curSustitutos CURSOR FOR 
		
		SELECT MA_CODIGOSUST 
		FROM MAESTROSUST 							
		WHERE MAESTROSUST.MA_CODIGO=@Ma_hijo
		 and MA_CODIGOSUST in (select ma_codigo from vpidescarga group by ma_codigo)
		ORDER BY MAS_CODIGO
	      OPEN curSustitutos
	      FETCH NEXT FROM curSustitutos INTO @MA_CODIGO
	
	      WHILE (@@fetch_status <> -1)
	      BEGIN  --5
	

					if @kap_fiscomp='N'
					begin
						set @kap_padresust=@ma_hijo
						set @kap_padreMain=0
					end
					else
					begin
						set @kap_padreMain=@ma_hijo
					end



					IF @MetodoDescarga = 'PEPS'
					begin
						INSERT INTO KardesPedtemp ( 
							Ma_Hijo, 
							Kap_Factrans, 
							Kap_Indiced_Fact, 
							Kap_PadreSust, 
							kap_padreMain,
							Kap_Tipo_Desc, 
							Kap_Indiced_Ped, 
							kap_fiscomp,
							Kap_CantTotADescargar, 
							KAP_SaldoPedAntesDescargar,
							Kap_Saldo_FED, 			
							Kap_CantDesc,
							Kap_Estatus)


							SELECT   
								 @Ma_Codigo, 	
								 @fe_codigo, 
								 @Fed_Indiced, 
								 @kap_padresust, 
								 @kap_padreMain,
								 @Bst_TipoDesc,
								 vPiDescarga.Pid_Indiced, 
								 @kap_fiscomp,
								 @fQtyTotDesc, vPiDescarga.Pid_SaldoGen,
								
								case when isnull((select  sum(SD.Pid_SaldoGen) from vPiDescarga SD
									WHERE  (SD.Ma_Codigo =  @Ma_Codigo) 
									  and SD.Pid_IdDescarga <= vPIDescarga.Pid_IdDescarga),0) >@RestaDescargar then 0 else			
									@RestaDescargar-isnull((select  sum(SD.Pid_SaldoGen) from vPiDescarga SD
									WHERE  (SD.Ma_Codigo =  @Ma_Codigo) 
									  and SD.Pid_IdDescarga <= vPIDescarga.Pid_IdDescarga),0) end, 	
			
									 (select  CASE 
										WHEN ((@RestaDescargar-sum(SDS.Pid_SaldoGen)) IS NULL) and (@RestaDescargar >= vPiDescarga.Pid_SaldoGen) 
										THEN 	vPiDescarga.Pid_SaldoGen
										WHEN (@RestaDescargar-sum(SDS.Pid_SaldoGen) IS NULL) and (@RestaDescargar < vPiDescarga.Pid_SaldoGen)  
										THEN 	@RestaDescargar 
										WHEN (@RestaDescargar-sum(SDS.Pid_SaldoGen)) > vPiDescarga.Pid_SaldoGen 
										THEN 	vPiDescarga.Pid_SaldoGen 
										WHEN ((@RestaDescargar-sum(SDS.Pid_SaldoGen)) < 0) 
										THEN 	0
										ELSE (@RestaDescargar-sum(SDS.Pid_SaldoGen)) 
										END CampoCase
										from  vPiDescarga SDS
										WHERE  (SDS.Ma_Codigo =  @Ma_Codigo) 
										and SDS.Pid_IdDescarga < vPIDescarga.Pid_IdDescarga
								)   tempcantsum, 0
				
							FROM   vPiDescarga
							 WHERE  (Ma_Codigo =  @Ma_Codigo) 
							        AND (Pid_SaldoGen > 0) and (ISNULL((select  CASE 
											WHEN ((@RestaDescargar-sum(SDS.Pid_SaldoGen)) IS NULL) and (@RestaDescargar >= vPiDescarga.Pid_SaldoGen) 
											THEN 	vPiDescarga.Pid_SaldoGen
											WHEN (@RestaDescargar-sum(SDS.Pid_SaldoGen) IS NULL) and (@RestaDescargar < vPiDescarga.Pid_SaldoGen)  
											THEN 	@RestaDescargar 
											WHEN (@RestaDescargar-sum(SDS.Pid_SaldoGen)) > vPiDescarga.Pid_SaldoGen 
											THEN 	vPiDescarga.Pid_SaldoGen 
											WHEN ((@RestaDescargar-sum(SDS.Pid_SaldoGen)) < 0) 
											THEN 	0
											ELSE (@RestaDescargar-sum(SDS.Pid_SaldoGen)) 
											END CampoCase
											from  vPiDescarga SDS
											WHERE  (SDS.Ma_Codigo =  @Ma_Codigo) 
											and SDS.Pid_IdDescarga < vPIDescarga.Pid_IdDescarga
											),0)  > 0) 
							order by vPiDescarga.Pi_Fec_Ent, vPiDescarga.Pid_Indiced
	
		
							-- RESTA EL SALDO EN LA TABLA DE PEDIMENTO
					
							UPDATE PiDescarga
							SET   Pid_SaldoGen =  Pid_SaldoGen - tempcantsum
							FROM         PiDescarga inner join (
										SELECT   Pid_Indiced, 
											(select  CASE  when  ((@RestaDescargar-sum(Pid_SaldoGen)) IS NULL) and (@RestaDescargar >= vPiDescarga.Pid_SaldoGen) then vPiDescarga.Pid_SaldoGen
									       		when ((@RestaDescargar-sum(Pid_SaldoGen)) IS NULL) and  (@RestaDescargar < vPiDescarga.Pid_SaldoGen) then @RestaDescargar
									       		when (@RestaDescargar-sum(Pid_SaldoGen)) > (vPiDescarga.Pid_SaldoGen)
					  				                          then vPiDescarga.Pid_SaldoGen
									       	        when (@RestaDescargar-sum(Pid_SaldoGen)) < 0 then 0
											else (@RestaDescargar-sum(Pid_SaldoGen)) 
											END campo from vPiDescarga SDS
											WHERE  (  Ma_Codigo =  @Ma_Codigo) 
											--and  SDS.Pid_Indiced < vPiDescarga.Pid_Indiced
											and SDS.Pid_IdDescarga < vPIDescarga.Pid_IdDescarga) tempcantsum
											FROM   vPiDescarga WHERE  (Ma_Codigo =  @Ma_Codigo) 
											and (select  CASE when  ((@RestaDescargar-sum(Pid_SaldoGen)) IS NULL) and (@RestaDescargar >= vPiDescarga.Pid_SaldoGen) then vPiDescarga.Pid_SaldoGen
													when ((@RestaDescargar-sum(Pid_SaldoGen)) IS NULL) and  (@RestaDescargar < vPiDescarga.Pid_SaldoGen) then @RestaDescargar
													when  (@RestaDescargar-sum(Pid_SaldoGen)) > (vPiDescarga.Pid_SaldoGen) then vPiDescarga.Pid_SaldoGen
													when (@RestaDescargar-sum(Pid_SaldoGen)) < 0 then 0
													else (@RestaDescargar-sum(Pid_SaldoGen)) 
												END from vPiDescarga SDS
										WHERE  (Ma_Codigo =  @Ma_Codigo) 
										--and   SDS.Pid_Indiced < vPiDescarga.Pid_Indiced
										  and SDS.Pid_IdDescarga < vPIDescarga.Pid_IdDescarga) > 0
									) tabla 
								on tabla.Pid_Indiced = PiDescarga.Pid_Indiced
		
		
		
	
							select @tempcantsum= sum(tempcantsum) from 
									(
									SELECT   Pid_Indiced,  (select  CASE  when  ((@RestaDescargar-sum(Pid_SaldoGen)) IS NULL) and (@RestaDescargar >= vPiDescarga.Pid_SaldoGen)  then vPiDescarga.Pid_SaldoGen
											    when ((@RestaDescargar-sum(Pid_SaldoGen)) IS NULL) and  (@RestaDescargar < vPiDescarga.Pid_SaldoGen) then @RestaDescargar
											    when (@RestaDescargar-sum(Pid_SaldoGen)) > (vPiDescarga.Pid_SaldoGen) then vPiDescarga.Pid_SaldoGen
											    when (@RestaDescargar-sum(Pid_SaldoGen)) < 0 then 0
											    else (@RestaDescargar-sum(Pid_SaldoGen)) 
											    END campo from vPiDescarga SDS
											    WHERE  (Ma_Codigo =  @Ma_Codigo) 
												--and SDS.Pid_Indiced < vPiDescarga.Pid_Indiced 
												and SDS.Pid_IdDescarga < vPIDescarga.Pid_IdDescarga) tempcantsum
												FROM   vPiDescarga WHERE  (Ma_Codigo =  @Ma_Codigo) 
												and (select  CASE when  ((@RestaDescargar-sum(Pid_SaldoGen)) IS NULL) and (@RestaDescargar >= vPiDescarga.Pid_SaldoGen) then vPiDescarga.Pid_SaldoGen
															when ((@RestaDescargar-sum(Pid_SaldoGen)) IS NULL) and  (@RestaDescargar < vPiDescarga.Pid_SaldoGen) then @RestaDescargar
															when  (@RestaDescargar-sum(Pid_SaldoGen)) > (vPiDescarga.Pid_SaldoGen) then vPiDescarga.Pid_SaldoGen
															when (@RestaDescargar-sum(Pid_SaldoGen)) < 0 then 0
															else (@RestaDescargar-sum(Pid_SaldoGen)) 
														END from vPiDescarga SDS
												WHERE  (Ma_Codigo =  @Ma_Codigo) 
												--and SDS.Pid_Indiced < vPiDescarga.Pid_Indiced
												and SDS.Pid_IdDescarga < vPIDescarga.Pid_IdDescarga) > 0
									) tabla
					end
					else
					begin
						INSERT INTO KardesPedtemp ( 
							Ma_Hijo, 
							Kap_Factrans, 
							Kap_Indiced_Fact, 
							Kap_PadreSust, 
							kap_padreMain,
							Kap_Tipo_Desc, 
							Kap_Indiced_Ped, 
							kap_fiscomp,
							Kap_CantTotADescargar, 
							KAP_SaldoPedAntesDescargar,
							Kap_Saldo_FED, 			
							Kap_CantDesc,
							Kap_Estatus)
							SELECT   
								 @Ma_Codigo, 	
								 @fe_codigo, 
								 @Fed_Indiced, 
								 @kap_padresust, 
								 @kap_padreMain,
								 @Bst_TipoDesc,
								 vPiDescarga.Pid_Indiced, 
								 @kap_fiscomp,
								 @fQtyTotDesc, vPiDescarga.Pid_SaldoGen,
								
								case when isnull((select  sum(SD.Pid_SaldoGen) from vPiDescarga SD
									WHERE  (SD.Ma_Codigo =  @Ma_Codigo) 
									--and SD.Pid_Indiced >= vPiDescarga.Pid_Indiced
									  and SD.Pid_IdDescarga >= vPIDescarga.Pid_IdDescarga),0) >@RestaDescargar then 0 else
				
									@RestaDescargar-isnull((select  sum(SD.Pid_SaldoGen) from vPiDescarga SD
									WHERE  (SD.Ma_Codigo =  @Ma_Codigo) 
									--and SD.Pid_Indiced >= vPiDescarga.Pid_Indiced
									  and SD.Pid_IdDescarga >= vPIDescarga.Pid_IdDescarga),0) end, 
				
				
									 (select  CASE 
										WHEN ((@RestaDescargar-sum(SDS.Pid_SaldoGen)) IS NULL) and (@RestaDescargar >= vPiDescarga.Pid_SaldoGen) 
										THEN 	vPiDescarga.Pid_SaldoGen
										WHEN (@RestaDescargar-sum(SDS.Pid_SaldoGen) IS NULL) and (@RestaDescargar < vPiDescarga.Pid_SaldoGen)  
										THEN 	@RestaDescargar 
										WHEN (@RestaDescargar-sum(SDS.Pid_SaldoGen)) > vPiDescarga.Pid_SaldoGen 
										THEN 	vPiDescarga.Pid_SaldoGen 
										WHEN ((@RestaDescargar-sum(SDS.Pid_SaldoGen)) < 0) 
										THEN 	0
										ELSE (@RestaDescargar-sum(SDS.Pid_SaldoGen)) 
										END CampoCase
										from  vPiDescarga SDS
										WHERE  (SDS.Ma_Codigo =  @Ma_Codigo) 
										--and SDS.Pid_Indiced > vPiDescarga.Pid_Indiced
										and SDS.Pid_IdDescarga > vPIDescarga.Pid_IdDescarga
								)   tempcantsum, 0
				
							FROM   vPiDescarga
							 WHERE  (Ma_Codigo =  @Ma_Codigo) 
							        AND (Pid_SaldoGen > 0) and (ISNULL((select  CASE 
											WHEN ((@RestaDescargar-sum(SDS.Pid_SaldoGen)) IS NULL) and (@RestaDescargar >= vPiDescarga.Pid_SaldoGen) 
											THEN 	vPiDescarga.Pid_SaldoGen
											WHEN (@RestaDescargar-sum(SDS.Pid_SaldoGen) IS NULL) and (@RestaDescargar < vPiDescarga.Pid_SaldoGen)  
											THEN 	@RestaDescargar 
											WHEN (@RestaDescargar-sum(SDS.Pid_SaldoGen)) > vPiDescarga.Pid_SaldoGen 
											THEN 	vPiDescarga.Pid_SaldoGen 
											WHEN ((@RestaDescargar-sum(SDS.Pid_SaldoGen)) < 0) 
											THEN 	0
											ELSE (@RestaDescargar-sum(SDS.Pid_SaldoGen)) 
											END CampoCase
											from  vPiDescarga SDS
											WHERE  (SDS.Ma_Codigo =  @Ma_Codigo) 
											--and SDS.Pid_Indiced > vPiDescarga.Pid_Indiced
											and SDS.Pid_IdDescarga > vPIDescarga.Pid_IdDescarga
											),0)  > 0) 
							order by vPiDescarga.Pi_Fec_Ent desc, vPiDescarga.Pid_Indiced
	
	
	
	
							-- RESTA EL SALDO EN LA TABLA DE PEDIMENTO
					
							UPDATE PiDescarga
							SET   Pid_SaldoGen =  Pid_SaldoGen - tempcantsum
							FROM         PiDescarga inner join (
										SELECT   Pid_Indiced, 
											(select  CASE  when  ((@RestaDescargar-sum(Pid_SaldoGen)) IS NULL) and (@RestaDescargar >= vPiDescarga.Pid_SaldoGen) then vPiDescarga.Pid_SaldoGen
									       		when ((@RestaDescargar-sum(Pid_SaldoGen)) IS NULL) and  (@RestaDescargar < vPiDescarga.Pid_SaldoGen) then @RestaDescargar
									       		when (@RestaDescargar-sum(Pid_SaldoGen)) > (vPiDescarga.Pid_SaldoGen)
					  				                          then vPiDescarga.Pid_SaldoGen
									       	        when (@RestaDescargar-sum(Pid_SaldoGen)) < 0 then 0
											else (@RestaDescargar-sum(Pid_SaldoGen)) 
											END campo from vPiDescarga SDS
											WHERE  (  Ma_Codigo =  @Ma_Codigo) 
											--and  SDS.Pid_Indiced > vPiDescarga.Pid_Indiced
											and SDS.Pid_IdDescarga > vPIDescarga.Pid_IdDescarga) tempcantsum
											FROM   vPiDescarga WHERE  (Ma_Codigo =  @Ma_Codigo) 
											and (select  CASE when  ((@RestaDescargar-sum(Pid_SaldoGen)) IS NULL) and (@RestaDescargar >= vPiDescarga.Pid_SaldoGen) then vPiDescarga.Pid_SaldoGen
													when ((@RestaDescargar-sum(Pid_SaldoGen)) IS NULL) and  (@RestaDescargar < vPiDescarga.Pid_SaldoGen) then @RestaDescargar
													when  (@RestaDescargar-sum(Pid_SaldoGen)) > (vPiDescarga.Pid_SaldoGen) then vPiDescarga.Pid_SaldoGen
													when (@RestaDescargar-sum(Pid_SaldoGen)) < 0 then 0
													else (@RestaDescargar-sum(Pid_SaldoGen)) 
												END from vPiDescarga SDS
										WHERE  (Ma_Codigo =  @Ma_Codigo) 
										--and   SDS.Pid_Indiced > vPiDescarga.Pid_Indiced
										  and SDS.Pid_IdDescarga > vPIDescarga.Pid_IdDescarga) > 0
									) tabla 
								on tabla.Pid_Indiced = PiDescarga.Pid_Indiced
		
		
		
							select @tempcantsum = sum(tempcantsum) from 
									(
									SELECT   Pid_Indiced,  (select  CASE  when  ((@RestaDescargar-sum(Pid_SaldoGen)) IS NULL) and (@RestaDescargar >= vPiDescarga.Pid_SaldoGen)  then vPiDescarga.Pid_SaldoGen
											    when ((@RestaDescargar-sum(Pid_SaldoGen)) IS NULL) and  (@RestaDescargar < vPiDescarga.Pid_SaldoGen) then @RestaDescargar
											    when (@RestaDescargar-sum(Pid_SaldoGen)) > (vPiDescarga.Pid_SaldoGen) then vPiDescarga.Pid_SaldoGen
											    when (@RestaDescargar-sum(Pid_SaldoGen)) < 0 then 0
											    else (@RestaDescargar-sum(Pid_SaldoGen)) 
											    END campo from vPiDescarga SDS
											    WHERE  (Ma_Codigo =  @Ma_Codigo) 
												--and SDS.Pid_Indiced > vPiDescarga.Pid_Indiced 
												and SDS.Pid_IdDescarga > vPIDescarga.Pid_IdDescarga) tempcantsum
												FROM   vPiDescarga WHERE  (Ma_Codigo =  @Ma_Codigo) 
												and (select  CASE when  ((@RestaDescargar-sum(Pid_SaldoGen)) IS NULL) and (@RestaDescargar >= vPiDescarga.Pid_SaldoGen) then vPiDescarga.Pid_SaldoGen
															when ((@RestaDescargar-sum(Pid_SaldoGen)) IS NULL) and  (@RestaDescargar < vPiDescarga.Pid_SaldoGen) then @RestaDescargar
															when  (@RestaDescargar-sum(Pid_SaldoGen)) > (vPiDescarga.Pid_SaldoGen) then vPiDescarga.Pid_SaldoGen
															when (@RestaDescargar-sum(Pid_SaldoGen)) < 0 then 0
															else (@RestaDescargar-sum(Pid_SaldoGen)) 
														END from vPiDescarga SDS
												WHERE  (Ma_Codigo =  @Ma_Codigo) 
												--and SDS.Pid_Indiced > vPiDescarga.Pid_Indiced
												and SDS.Pid_IdDescarga > vPIDescarga.Pid_IdDescarga) > 0
									) tabla
					end

					--SELECT @tempcantsum=sum(Kap_CantDesc) from kardespedtemp where kap_padresust=@ma_hijo
					--and kap_indiced_fact=@fed_indiced

		
					IF @tempcantsum IS NULL 
					set @tempcantsum = 0
					

					SET @NoDescargadaQty = @RestaDescargar - @tempcantsum

									
					set @RestaDescargar=@RestaDescargar - @tempcantsum


					print @RestaDescargar


					IF (@NoDescargadaQty = 0) 
					BREAK --Jump out of Pedimentou Cycle

				FETCH NEXT FROM curSustitutos 
				INTO @MA_CODIGO
	
				END  --5
				CLOSE curSustitutos
	
			DEALLOCATE curSustitutos


		  FETCH NEXT FROM curMPNUSust
			INTO @fQtyTotDesc, @RestaDescargar, @ma_hijo, @BST_TIPODESC, @kap_fiscomp, @kap_padresust

		--END --2
	END --1

	CLOSE curMPNUSust
	DEALLOCATE curMPNUSust

*/


GO
