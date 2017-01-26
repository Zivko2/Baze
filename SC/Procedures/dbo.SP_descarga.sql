SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_descarga] (@fed_indiced int, @MetodoDescarga Varchar(4), @tipodescarga varchar(2), @tipo char(1))    as

SET NOCOUNT ON 
declare @KAP_FECHADESC varchar(10), @fe_fecha varchar(10), @CodigoFactura int, @CF_USAEQUIVALENTE char(1), @CF_DESCARGAVENCIDOS char(1)
	

	set @KAP_FECHADESC= convert(varchar(10),getdate(),101)

	select @fe_fecha=convert(varchar(10),fe_fecha,101), @CodigoFactura=fe_codigo from factexp where fe_codigo in (select fe_codigo from factexpdet where fed_indiced=@fed_indiced)

	--exec SP_CreaVPIDescargaHijo @tipo, @fe_fecha, @fed_indiced

	SELECT     @CF_USAEQUIVALENTE = CF_USAEQUIVALENTE,  @CF_DESCARGAVENCIDOS=CF_DESCARGAVENCIDOS
	FROM         CONFIGURACION




	/*========== los que no se encuentran en pedimentos =============*/
	begin tran

		INSERT INTO KARDESPEDtemp(KAP_FACTRANS,  KAP_CantTotADescargar, KAP_CANTDESC, KAP_INDICED_FACT, 
					MA_HIJO, KAP_TIPO_DESC, KAP_Saldo_FED, KAP_FisComp, KAP_ESTATUS)
	
		SELECT     TOP 100 PERCENT @CodigoFactura, round(VBOM_DESCTEMP.CANTDESC,6), 0, VBOM_DESCTEMP.FED_INDICED, 
				VBOM_DESCTEMP.BST_HIJO, VBOM_DESCTEMP.BST_TIPODESC,
				round(VBOM_DESCTEMP.CANTDESC,6) , 'MA_TIP_ENS' = case when VBOM_DESCTEMP.MA_TIP_ENS='A'  THEN 'S' ELSE 'N' END, 'N'
		FROM         VBOM_DESCTEMP
		WHERE     VBOM_DESCTEMP.BST_HIJO not in (SELECT MA_CODIGO FROM vPIDescarga 
				WHERE vPIDescarga.PID_SALDOGEN > 0 and PI_FEC_ENT<= @fe_fecha)
		and (VBOM_DESCTEMP.BST_TIPODESC=left(@tipodescarga,1) or VBOM_DESCTEMP.BST_TIPODESC=right(@tipodescarga,1))
		AND VBOM_DESCTEMP.FED_INDICED=@fed_indiced AND VBOM_DESCTEMP.BST_HIJO IS NOT NULL
		and round(VBOM_DESCTEMP.CANTDESC,6)>0

	commit tran





		begin tran
			if @MetodoDescarga='PEPS'
			begin
					INSERT INTO KARDESPEDtemp (KAP_FACTRANS, KAP_CantTotADescargar, KAP_Saldo_FED, KAP_CANTDESC, KAP_INDICED_PED, KAP_INDICED_FACT, 
						MA_HIJO,  KAP_TIPO_DESC, KAP_FisComp, KAP_SaldoPedAntesDescargar)
	
					SELECT     TOP 100 PERCENT @CodigoFactura, round(VBOM_DESCTEMP.CANTDESC,6) AS KAP_CantTotADescargar, 
						case when isnull((select  sum(SD.Pid_SaldoGen) from vPiDescarga SD
								WHERE  (SD.Ma_Codigo =  VBOM_DESCTEMP.BST_HIJO)  				
									AND (SD.Pid_SaldoGen > 0)
								  and SD.Pid_IdDescarga <= vPIDescarga.Pid_IdDescarga
								),0) >round(VBOM_DESCTEMP.CANTDESC,6) then 0 else
			
								round(VBOM_DESCTEMP.CANTDESC,6)-isnull((select  sum(SD.Pid_SaldoGen) from vPiDescarga SD
								WHERE  (SD.Ma_Codigo =  VBOM_DESCTEMP.BST_HIJO) AND 				
									  (SD.Pid_SaldoGen > 0)
								  and SD.Pid_IdDescarga <= vPIDescarga.Pid_IdDescarga
								),0) end Kap_Saldo_FED,
						(select  CASE 
									WHEN ((round(VBOM_DESCTEMP.CANTDESC,6)-sum(SDS.Pid_SaldoGen)) IS NULL) and (round(VBOM_DESCTEMP.CANTDESC,6) >= vPIDescarga.Pid_SaldoGen) 
									THEN 	vPIDescarga.Pid_SaldoGen
									WHEN (round(VBOM_DESCTEMP.CANTDESC,6)-sum(SDS.Pid_SaldoGen) IS NULL) and (round(VBOM_DESCTEMP.CANTDESC,6) < vPIDescarga.Pid_SaldoGen)  
									THEN 	round(VBOM_DESCTEMP.CANTDESC,6) 
									WHEN (round(VBOM_DESCTEMP.CANTDESC,6)-sum(SDS.Pid_SaldoGen)) > vPIDescarga.Pid_SaldoGen 
									THEN 	VPiDescarga.Pid_SaldoGen 
									WHEN ((round(VBOM_DESCTEMP.CANTDESC,6)-sum(SDS.Pid_SaldoGen)) < 0) 
									THEN 	0
									ELSE (round(VBOM_DESCTEMP.CANTDESC,6)-sum(SDS.Pid_SaldoGen)) 
									END CampoCase
									from  vPIDescarga SDS
									WHERE  (SDS.Ma_Codigo =  VBOM_DESCTEMP.BST_HIJO) 		
			                                                       AND (SDS.Pid_SaldoGen > 0)
									  and SDS.Pid_IdDescarga < vPIDescarga.Pid_IdDescarga
							)   KAP_CANTDESC,
	
					vPIDescarga.PID_INDICED, VBOM_DESCTEMP.FED_INDICED, VBOM_DESCTEMP.BST_HIJO, VBOM_DESCTEMP.BST_TIPODESC,
					/*'MA_TIP_ENS' = case when VBOM_DESCTEMP.MA_TIP_ENS='A'  THEN 'S' ELSE 'N' END, */ 'N', vPIDescarga.Pid_SaldoGen
					FROM         vPIDescarga INNER JOIN
					                      VBOM_DESCTEMP ON vPIDescarga.MA_CODIGO = VBOM_DESCTEMP.BST_HIJO
					WHERE     vPIDescarga.PID_SALDOGEN > 0 
					and round(VBOM_DESCTEMP.CANTDESC,6)>0 
					and (VBOM_DESCTEMP.FED_INDICED= @fed_indiced)
					AND ((select  CASE 
										WHEN ((round(VBOM_DESCTEMP.CANTDESC,6)-sum(SDS.Pid_SaldoGen)) IS NULL) and (round(VBOM_DESCTEMP.CANTDESC,6) >= vPIDescarga.Pid_SaldoGen) 
										THEN 	vPIDescarga.Pid_SaldoGen
										WHEN (round(VBOM_DESCTEMP.CANTDESC,6)-sum(SDS.Pid_SaldoGen) IS NULL) and (round(VBOM_DESCTEMP.CANTDESC,6) < vPIDescarga.Pid_SaldoGen)  
										THEN 	round(VBOM_DESCTEMP.CANTDESC,6) 
										WHEN (round(VBOM_DESCTEMP.CANTDESC,6)-sum(SDS.Pid_SaldoGen)) > vPIDescarga.Pid_SaldoGen 
										THEN 	vPIDescarga.Pid_SaldoGen 
										WHEN ((round(VBOM_DESCTEMP.CANTDESC,6)-sum(SDS.Pid_SaldoGen)) < 0) 
										THEN 	0
										ELSE (round(VBOM_DESCTEMP.CANTDESC,6)-sum(SDS.Pid_SaldoGen)) 
										END CampoCase
										from  vPIDescarga SDS
										WHERE  (SDS.Ma_Codigo =  VBOM_DESCTEMP.BST_HIJO)
						 				AND (SDS.Pid_SaldoGen > 0)
										  and SDS.Pid_IdDescarga < vPIDescarga.Pid_IdDescarga
										)  > 0) 
					and (VBOM_DESCTEMP.BST_TIPODESC=left(@tipodescarga,1) or VBOM_DESCTEMP.BST_TIPODESC=right(@tipodescarga,1))
					order by VBOM_DESCTEMP.FED_INDICED, VBOM_DESCTEMP.BST_HIJO,  vPIDescarga.Pid_IdDescarga
				
			end
			else --UEPS
			begin
					INSERT INTO KARDESPEDtemp (KAP_FACTRANS, KAP_CantTotADescargar, KAP_Saldo_FED, KAP_CANTDESC, KAP_INDICED_PED, KAP_INDICED_FACT, 
						MA_HIJO,  KAP_TIPO_DESC, KAP_FisComp, KAP_SaldoPedAntesDescargar)
	
					SELECT     TOP 100 PERCENT @CodigoFactura, round(VBOM_DESCTEMP.CANTDESC,6) AS KAP_CantTotADescargar, 
						case when isnull((select  sum(SD.Pid_SaldoGen) from vPiDescarga SD
								WHERE  (SD.Ma_Codigo =  VBOM_DESCTEMP.BST_HIJO)  				
									AND (SD.Pid_SaldoGen > 0)
								  and SD.Pid_IdDescarga >= vPIDescarga.Pid_IdDescarga
								),0) >round(VBOM_DESCTEMP.CANTDESC,6) then 0 else
			
								round(VBOM_DESCTEMP.CANTDESC,6)-isnull((select  sum(SD.Pid_SaldoGen) from vPiDescarga SD
								WHERE  (SD.Ma_Codigo =  VBOM_DESCTEMP.BST_HIJO) AND 				
									  (SD.Pid_SaldoGen > 0)
								  and SD.Pid_IdDescarga >= vPIDescarga.Pid_IdDescarga
								),0) end Kap_Saldo_FED,
						(select  CASE 
									WHEN ((round(VBOM_DESCTEMP.CANTDESC,6)-sum(SDS.Pid_SaldoGen)) IS NULL) and (round(VBOM_DESCTEMP.CANTDESC,6) >= vPIDescarga.Pid_SaldoGen) 
									THEN 	vPIDescarga.Pid_SaldoGen
									WHEN (round(VBOM_DESCTEMP.CANTDESC,6)-sum(SDS.Pid_SaldoGen) IS NULL) and (round(VBOM_DESCTEMP.CANTDESC,6) < vPIDescarga.Pid_SaldoGen)  
									THEN 	round(VBOM_DESCTEMP.CANTDESC,6) 
									WHEN (round(VBOM_DESCTEMP.CANTDESC,6)-sum(SDS.Pid_SaldoGen)) > vPIDescarga.Pid_SaldoGen 
									THEN 	VPiDescarga.Pid_SaldoGen 
									WHEN ((round(VBOM_DESCTEMP.CANTDESC,6)-sum(SDS.Pid_SaldoGen)) < 0) 
									THEN 	0
									ELSE (round(VBOM_DESCTEMP.CANTDESC,6)-sum(SDS.Pid_SaldoGen)) 
									END CampoCase
									from  vPIDescarga SDS
									WHERE  (SDS.Ma_Codigo =  VBOM_DESCTEMP.BST_HIJO) 		
			                                                       AND (SDS.Pid_SaldoGen > 0)
									  and SDS.Pid_IdDescarga > vPIDescarga.Pid_IdDescarga
							)   KAP_CANTDESC,
	
					vPIDescarga.PID_INDICED, VBOM_DESCTEMP.FED_INDICED, VBOM_DESCTEMP.BST_HIJO, VBOM_DESCTEMP.BST_TIPODESC,
					/*'MA_TIP_ENS' = case when VBOM_DESCTEMP.MA_TIP_ENS='A'  THEN 'S' ELSE 'N' END, */'N', vPIDescarga.Pid_SaldoGen
					FROM         vPIDescarga INNER JOIN
					                      VBOM_DESCTEMP ON vPIDescarga.MA_CODIGO = VBOM_DESCTEMP.BST_HIJO
					WHERE     vPIDescarga.PID_SALDOGEN > 0 
					and round(VBOM_DESCTEMP.CANTDESC,6)>0 
					and (VBOM_DESCTEMP.FED_INDICED= @fed_indiced)
					AND ((select  CASE 
										WHEN ((round(VBOM_DESCTEMP.CANTDESC,6)-sum(SDS.Pid_SaldoGen)) IS NULL) and (round(VBOM_DESCTEMP.CANTDESC,6) >= vPIDescarga.Pid_SaldoGen) 
										THEN 	vPIDescarga.Pid_SaldoGen
										WHEN (round(VBOM_DESCTEMP.CANTDESC,6)-sum(SDS.Pid_SaldoGen) IS NULL) and (round(VBOM_DESCTEMP.CANTDESC,6) < vPIDescarga.Pid_SaldoGen)  
										THEN 	round(VBOM_DESCTEMP.CANTDESC,6) 
										WHEN (round(VBOM_DESCTEMP.CANTDESC,6)-sum(SDS.Pid_SaldoGen)) > vPIDescarga.Pid_SaldoGen 
										THEN 	vPIDescarga.Pid_SaldoGen 
										WHEN ((round(VBOM_DESCTEMP.CANTDESC,6)-sum(SDS.Pid_SaldoGen)) < 0) 
										THEN 	0
										ELSE (round(VBOM_DESCTEMP.CANTDESC,6)-sum(SDS.Pid_SaldoGen)) 
										END CampoCase
										from  vPIDescarga SDS
										WHERE  (SDS.Ma_Codigo =  VBOM_DESCTEMP.BST_HIJO)
						 				AND (SDS.Pid_SaldoGen > 0)
										  and SDS.Pid_IdDescarga > vPIDescarga.Pid_IdDescarga
										)  > 0) 
					and (VBOM_DESCTEMP.BST_TIPODESC=left(@tipodescarga,1) or VBOM_DESCTEMP.BST_TIPODESC=right(@tipodescarga,1))
					order by VBOM_DESCTEMP.FED_INDICED, VBOM_DESCTEMP.BST_HIJO, vPIDescarga.Pid_IdDescarga desc
		
	
			end
	
		commit tran
	
	
		begin tran
			update pidescarga
			set PID_SALDOGEN=(select kap_saldopedantesdescargar-kap_cantdesc from KARDESPEDtemp where kap_codigo in
				(select max(k2.kap_codigo) 
				 from KARDESPEDtemp k2 
				 where k2.kap_indiced_ped is not null and k2.kap_indiced_ped=pidescarga.pid_indiced
				 group by k2.kap_indiced_ped))
			from pidescarga
			where  pid_indiced in (select max(k3.kap_indiced_ped) from KARDESPEDtemp k3 where KAP_INDICED_FACT = @fed_indiced and KAP_SALAFECTADO<>'S' and k3.kap_indiced_ped is not null group by k3.kap_indiced_ped)
			
	
		commit tran
	
	
		UPDATE KARDESPEDTEMP
		SET KAP_SALAFECTADO='S'
		WHERE KAP_SALAFECTADO<>'S'	




	/*======================================= los que si se encuentran en pedimentos =================================*/
	/*begin tran
		if @MetodoDescarga='PEPS'
		begin
			if @CF_DESCARGAVENCIDOS='S'
			begin
				INSERT INTO KARDESPEDtemp (KAP_FACTRANS, KAP_CantTotADescargar, KAP_CANTDESC, KAP_INDICED_PED, KAP_INDICED_FACT, 
					MA_HIJO,  KAP_TIPO_DESC, KAP_FisComp, KAP_PADREMAIN)
			
				SELECT     TOP 100 PERCENT @CodigoFactura, round(VBOM_DESCTEMP.CANTDESC,6) AS KAP_CantTotADescargar, 
				'KAP_CANTDESC'=case when round(vPIDescarga.PID_SALDOGEN,6)<=round(VBOM_DESCTEMP.CANTDESC,6) then round(vPIDescarga.PID_SALDOGEN,6) else round(VBOM_DESCTEMP.CANTDESC,6) end, 
				vPIDescarga.PID_INDICED, VBOM_DESCTEMP.FED_INDICED, VBOM_DESCTEMP.BST_HIJO, VBOM_DESCTEMP.BST_TIPODESC,
				'MA_TIP_ENS' = case when VBOM_DESCTEMP.MA_TIP_ENS='A'  THEN 'S' ELSE 'N' END, 0
				FROM         vPIDescarga INNER JOIN
				                      VBOM_DESCTEMP ON vPIDescarga.MA_CODIGO = VBOM_DESCTEMP.BST_HIJO
				WHERE     vPIDescarga.PID_SALDOGEN > 0 AND vPIDescarga.PID_INDICED IN
					(SELECT     TOP 100 PERCENT MIN(vPIDescarga1.PID_INDICED)
					FROM         vPIDescarga vPIDescarga1
					WHERE     vPIDescarga1.PID_SALDOGEN > 0 AND 
					          vPIDescarga1.MA_CODIGO = VBOM_DESCTEMP.BST_HIJO AND vPIDescarga1.PI_FEC_ENT IN
						(SELECT     TOP 100 PERCENT MIN(vPIDescarga2.PI_FEC_ENT) AS PI_FEC_ENT
						FROM         vPIDescarga vPIDescarga2
						WHERE    vPIDescarga2.PI_FEC_ENT<= @fe_fecha and
							vPIDescarga2.PID_SALDOGEN > 0 AND 
						        vPIDescarga2.MA_CODIGO = VBOM_DESCTEMP.BST_HIJO)) 
				and round(VBOM_DESCTEMP.CANTDESC,6)>0 
				and (VBOM_DESCTEMP.FED_INDICED= @fed_indiced)
				and (VBOM_DESCTEMP.BST_TIPODESC=left(@tipodescarga,1) or VBOM_DESCTEMP.BST_TIPODESC=right(@tipodescarga,1))
				group by VBOM_DESCTEMP.CANTDESC, VBOM_DESCTEMP.BST_HIJO, VBOM_DESCTEMP.BST_TIPODESC, vPIDescarga.PID_INDICED, vPIDescarga.PID_SALDOGEN, 
				VBOM_DESCTEMP.MA_TIP_ENS, VBOM_DESCTEMP.FED_INDICED
				order by vPIDescarga.PID_INDICED, VBOM_DESCTEMP.FED_INDICED
			end
			else
			begin
				INSERT INTO KARDESPEDtemp (KAP_FACTRANS, KAP_CantTotADescargar, KAP_CANTDESC, KAP_INDICED_PED, KAP_INDICED_FACT, 
					MA_HIJO, KAP_TIPO_DESC, KAP_FisComp, KAP_PADREMAIN)
			
				SELECT     TOP 100 PERCENT @CodigoFactura, round(VBOM_DESCTEMP.CANTDESC,6) AS KAP_CantTotADescargar, 
				'KAP_CANTDESC'=case when round(vPIDescarga.PID_SALDOGEN,6)<=round(VBOM_DESCTEMP.CANTDESC,6) then round(vPIDescarga.PID_SALDOGEN,6) else round(VBOM_DESCTEMP.CANTDESC,6) end, 
				vPIDescarga.PID_INDICED, VBOM_DESCTEMP.FED_INDICED, VBOM_DESCTEMP.BST_HIJO, VBOM_DESCTEMP.BST_TIPODESC,
				'MA_TIP_ENS' = case when VBOM_DESCTEMP.MA_TIP_ENS='A'  THEN 'S' ELSE 'N' END, 0
				FROM         vPIDescarga INNER JOIN
				                      VBOM_DESCTEMP ON vPIDescarga.MA_CODIGO = VBOM_DESCTEMP.BST_HIJO
				WHERE     vPIDescarga.PID_SALDOGEN > 0 AND vPIDescarga.PID_INDICED IN
					(SELECT     TOP 100 PERCENT MIN(vPIDescarga1.PID_INDICED)
					FROM         vPIDescarga vPIDescarga1 
					WHERE     vPIDescarga1.PID_SALDOGEN > 0 AND 
					        vPIDescarga1.MA_CODIGO = VBOM_DESCTEMP.BST_HIJO and vPIDescarga1.pid_fechavence>=@fe_fecha 
						and vPIDescarga1.PI_FEC_ENT IN
						(SELECT     TOP 100 PERCENT MIN(vPIDescarga2.PI_FEC_ENT) AS PI_FEC_ENT
						FROM         vPIDescarga vPIDescarga2 
						WHERE    vPIDescarga2.PI_FEC_ENT<= @fe_fecha and vPIDescarga2.pid_fechavence>=@fe_fecha and
							vPIDescarga2.PID_SALDOGEN > 0 AND 
						        vPIDescarga2.MA_CODIGO = VBOM_DESCTEMP.BST_HIJO)) 
				and round(VBOM_DESCTEMP.CANTDESC,6)>0 
				and (VBOM_DESCTEMP.FED_INDICED= @fed_indiced)
				and (VBOM_DESCTEMP.BST_TIPODESC=left(@tipodescarga,1) or VBOM_DESCTEMP.BST_TIPODESC=right(@tipodescarga,1))
				group by VBOM_DESCTEMP.CANTDESC, VBOM_DESCTEMP.BST_HIJO, VBOM_DESCTEMP.BST_TIPODESC, vPIDescarga.PID_INDICED, vPIDescarga.PID_SALDOGEN, 
				VBOM_DESCTEMP.MA_TIP_ENS, VBOM_DESCTEMP.FED_INDICED
				order by vPIDescarga.PID_INDICED, VBOM_DESCTEMP.FED_INDICED
	
			end
		end
		else --UEPS
		begin
			if @CF_DESCARGAVENCIDOS='S'
			begin
	
				INSERT INTO KARDESPEDtemp (KAP_FACTRANS, KAP_CantTotADescargar, KAP_CANTDESC, KAP_INDICED_PED, KAP_INDICED_FACT, 
					MA_HIJO, KAP_TIPO_DESC, KAP_FisComp, KAP_PADREMAIN)
			
				SELECT     TOP 100 PERCENT @CodigoFactura, round(VBOM_DESCTEMP.CANTDESC,6) AS KAP_CantTotADescargar, 
				'KAP_CANTDESC'=case when round(vPIDescarga.PID_SALDOGEN,6)<=round(VBOM_DESCTEMP.CANTDESC,6) then round(vPIDescarga.PID_SALDOGEN,6) else round(VBOM_DESCTEMP.CANTDESC,6) end, 
				vPIDescarga.PID_INDICED, VBOM_DESCTEMP.FED_INDICED, VBOM_DESCTEMP.BST_HIJO,VBOM_DESCTEMP.BST_TIPODESC,
				'MA_TIP_ENS' = case when VBOM_DESCTEMP.MA_TIP_ENS='A' THEN 'S' ELSE 'N' END, 0
				FROM         vPIDescarga INNER JOIN
				                      VBOM_DESCTEMP ON vPIDescarga.MA_CODIGO = VBOM_DESCTEMP.BST_HIJO
				WHERE     vPIDescarga.PID_SALDOGEN > 0 AND vPIDescarga.PID_INDICED IN
					(SELECT     TOP 100 PERCENT MAX(vPIDescarga1.PID_INDICED)
					FROM         vPIDescarga vPIDescarga1
					WHERE     vPIDescarga1.PID_SALDOGEN > 0 AND 
					          vPIDescarga1.MA_CODIGO = VBOM_DESCTEMP.BST_HIJO AND vPIDescarga1.PI_FEC_ENT IN
						(SELECT     TOP 100 PERCENT MAX(vPIDescarga2.PI_FEC_ENT) AS PI_FEC_ENT
						FROM         vPIDescarga vPIDescarga2
						WHERE    vPIDescarga2.PI_FEC_ENT<= @fe_fecha and
							vPIDescarga2.PID_SALDOGEN > 0 AND 
						        vPIDescarga2.MA_CODIGO = VBOM_DESCTEMP.BST_HIJO)) 
				and round(VBOM_DESCTEMP.CANTDESC,6)>0 
				and (VBOM_DESCTEMP.FED_INDICED= @fed_indiced)
				and (VBOM_DESCTEMP.BST_TIPODESC=left(@tipodescarga,1) or VBOM_DESCTEMP.BST_TIPODESC=right(@tipodescarga,1))
				group by VBOM_DESCTEMP.CANTDESC, VBOM_DESCTEMP.BST_HIJO, VBOM_DESCTEMP.BST_TIPODESC, vPIDescarga.PID_INDICED, vPIDescarga.PID_SALDOGEN, 
				VBOM_DESCTEMP.MA_TIP_ENS, VBOM_DESCTEMP.FED_INDICED
				order by vPIDescarga.PID_INDICED, VBOM_DESCTEMP.FED_INDICED
			end
			else
			begin
				INSERT INTO KARDESPEDtemp (KAP_FACTRANS, KAP_CantTotADescargar, KAP_CANTDESC, KAP_INDICED_PED, KAP_INDICED_FACT, 
					MA_HIJO, KAP_TIPO_DESC, KAP_FisComp, KAP_PADREMAIN)
			
				SELECT     TOP 100 PERCENT @CodigoFactura, round(VBOM_DESCTEMP.CANTDESC,6) AS KAP_CantTotADescargar, 
				'KAP_CANTDESC'=case when round(vPIDescarga.PID_SALDOGEN,6)<=round(VBOM_DESCTEMP.CANTDESC,6) then round(vPIDescarga.PID_SALDOGEN,6) else round(VBOM_DESCTEMP.CANTDESC,6) end, 
				vPIDescarga.PID_INDICED, VBOM_DESCTEMP.FED_INDICED, VBOM_DESCTEMP.BST_HIJO, VBOM_DESCTEMP.BST_TIPODESC,
				'MA_TIP_ENS' = case when VBOM_DESCTEMP.MA_TIP_ENS='A'  THEN 'S' ELSE 'N' END, 0
				FROM         vPIDescarga INNER JOIN
				                      VBOM_DESCTEMP ON vPIDescarga.MA_CODIGO = VBOM_DESCTEMP.BST_HIJO
				WHERE     vPIDescarga.PID_SALDOGEN > 0 AND vPIDescarga.PID_INDICED IN
					(SELECT     TOP 100 PERCENT MAX(vPIDescarga1.PID_INDICED)
					FROM         vPIDescarga vPIDescarga1 
					WHERE     vPIDescarga1.PID_SALDOGEN > 0 AND 
					        vPIDescarga1.MA_CODIGO = VBOM_DESCTEMP.BST_HIJO and vPIDescarga1.pid_fechavence>=@fe_fecha 
						and vPIDescarga1.PI_FEC_ENT IN
						(SELECT     TOP 100 PERCENT MAX(vPIDescarga2.PI_FEC_ENT) AS PI_FEC_ENT
						FROM         vPIDescarga vPIDescarga2 
						WHERE    vPIDescarga2.PI_FEC_ENT<= @fe_fecha and vPIDescarga2.pid_fechavence>=@fe_fecha and
							vPIDescarga2.PID_SALDOGEN > 0 AND 
						        vPIDescarga2.MA_CODIGO = VBOM_DESCTEMP.BST_HIJO)) 
				and round(VBOM_DESCTEMP.CANTDESC,6)>0 
				and (VBOM_DESCTEMP.FED_INDICED= @fed_indiced)
				and (VBOM_DESCTEMP.BST_TIPODESC=left(@tipodescarga,1) or VBOM_DESCTEMP.BST_TIPODESC=right(@tipodescarga,1))
				group by VBOM_DESCTEMP.CANTDESC, VBOM_DESCTEMP.BST_HIJO, VBOM_DESCTEMP.BST_TIPODESC, vPIDescarga.PID_INDICED, vPIDescarga.PID_SALDOGEN, 
				VBOM_DESCTEMP.MA_TIP_ENS, VBOM_DESCTEMP.FED_INDICED
				order by vPIDescarga.PID_INDICED, VBOM_DESCTEMP.FED_INDICED
	
			end
		end

	commit tran

	--==== actualizando KAP_Saldo_FED ===
	begin tran
		UPDATE    KARDESPEDtemp
		SET             KAP_Saldo_FED = 0
		WHERE     (KAP_CANTDESC = KAP_CantTotADescargar)
	
		update kardespedtemp
		set kardespedtemp.KAP_Saldo_FED= round(kardespedtemp.KAP_CantTotADescargar-isnull((SELECT     SUM(kardespedtemp1.KAP_CANTDESC) FROM kardespedtemp as kardespedtemp1
						WHERE     (kardespedtemp1.MA_HIJO = kardespedtemp.MA_HIJO) AND (kardespedtemp1.KAP_INDICED_FACT = kardespedtemp.KAP_INDICED_FACT)),0),6)
		where kardespedtemp.KAP_Saldo_FED is null

	commit tran

	--==== actualizando SALDO Pedimento ===
	begin tran
		UPDATE PIDescarga
		SET     PIDescarga.PID_SALDOGEN= (case WHEN round(PIDescarga.PID_SALDOGEN,6)<=round(KARDESPEDtemp.KAP_CANTDESC,6)  then 0
		else round(PIDescarga.PID_SALDOGEN-round(KARDESPEDtemp.KAP_CANTDESC,6),6) end)
		FROM         KARDESPEDtemp INNER JOIN
		                  PIDescarga ON KARDESPEDtemp.KAP_INDICED_PED = PIDescarga.PID_INDICED
		WHERE KARDESPEDtemp.kap_codigo in (SELECT MAX(KAP_CODIGO) FROM KARDESPEDtemp 
				WHERE (KAP_FACTRANS = @CodigoFactura) AND (KAP_INDICED_FACT = @fed_indiced)
			        GROUP BY MA_HIJO)
	commit tran


	UPDATE KARDESPEDTEMP
	SET KAP_SALAFECTADO='S'
	WHERE KAP_SALAFECTADO<>'S'	



	--print 'restan por descargar '
	if @CF_DESCARGAVENCIDOS='S'
	begin

		if exists (select * from vPIDescarga where pid_saldogen>0 and
		ma_codigo in (select ma_hijo from kardespedtemp where kap_saldo_fed>0 and (kap_estatus<>'N' or kap_estatus is null) 
		and (kap_tipo_desc=left(@tipodescarga,1) or kap_tipo_desc=right(@tipodescarga,1)) 
		and kap_indiced_fact=@fed_indiced and kap_codigo in
		 (SELECT MAX(KAP_CODIGO) FROM KARDESPEDtemp WHERE (KAP_FACTRANS = @CodigoFactura) AND (KAP_INDICED_FACT = @fed_indiced)
			        GROUP BY MA_HIJO)) and pi_fec_ent <=@fe_fecha)
		begin
--				exec sp_DescargaDetalle @CodigoFactura, @fed_indiced, @MetodoDescarga, @KAP_FECHADESC, @tipodescarga, 0, 'N', 0

			exec sp_descarga1 @fed_indiced, @MetodoDescarga, @fe_fecha, @tipodescarga, 0, 'N', 0, 'S'

			delete from bom_desctemp where fed_indiced=@fed_indiced and (bst_tipodesc=left(@tipodescarga,1) or bst_tipodesc=right(@tipodescarga,1))
		end
	end
	else
	begin
		if exists (select * from vPIDescarga where pid_saldogen>0 and
		ma_codigo in (select ma_hijo from kardespedtemp where kap_saldo_fed>0 and (kap_estatus<>'N' or kap_estatus is null) 
		and (kap_tipo_desc=left(@tipodescarga,1) or kap_tipo_desc=right(@tipodescarga,1)) 
		and kap_indiced_fact=@fed_indiced and kap_codigo in
		 (SELECT MAX(KAP_CODIGO) FROM KARDESPEDtemp WHERE (KAP_FACTRANS = @CodigoFactura) AND (KAP_INDICED_FACT = @fed_indiced)
			        GROUP BY MA_HIJO)) and pi_fec_ent <=@fe_fecha and pid_fechavence>=@fe_fecha)
		
		begin
			exec sp_descarga1 @fed_indiced, @MetodoDescarga, @fe_fecha, @tipodescarga, 0, 'N', 0, 'S'

			delete from bom_desctemp where fed_indiced=@fed_indiced and (bst_tipodesc=left(@tipodescarga,1) or bst_tipodesc=right(@tipodescarga,1))
		end
	end

*/

	

	--if (SELECT CF_PENDGR FROM  CONFIGURACION)<>'S'
	--begin

	
		--========== equivalentes =============
	
		if @CF_USAEQUIVALENTE='S' and exists (select ma_codigo from maestrosust)
		begin

			exec SP_ESTATUSKARDESPEDFED @fed_indiced, @tipo

			if exists (select * from vPIDescarga where pid_saldogen>0 and
			ma_codigo in (select ma_codigosust from maestrosust where ma_codigo 
			in (select ma_hijo from kardespedtemp where  kap_saldo_fed>0 and kap_indiced_fact=@fed_indiced and kap_codigo in
			 (SELECT MAX(KAP_CODIGO) FROM KARDESPEDtemp WHERE (KAP_FACTRANS = @CodigoFactura) AND (KAP_INDICED_FACT = @fed_indiced)
				        GROUP BY MA_HIJO))) and pi_fec_ent <=@fe_fecha)
			begin
				exec sp_descargaDetalleEquivale @fed_indiced, @MetodoDescarga, @tipodescarga
			end

		end
	
	--end


GO
