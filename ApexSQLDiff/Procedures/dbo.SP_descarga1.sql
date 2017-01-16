SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE dbo.SP_descarga1 (@FED_INDICED int, @MetodoDescarga Varchar(4), @fe_fecha Varchar(10), @tipodescarga varchar(2), @padre int, @fiscomp char(1), @padremain int, @descini char(1)='N')  with encryption as
SET NOCOUNT ON 
declare @existe int, @CF_DESCARGAVENCIDOS char(1), @CodigoFactura Int


	if @padre is null
	set @padre=0

	SELECT    @CF_DESCARGAVENCIDOS=CF_DESCARGAVENCIDOS
	FROM         CONFIGURACION

	select @CodigoFactura=fe_codigo from factexpdet where fed_indiced=@FED_INDICED

		begin tran
			if @MetodoDescarga='PEPS'
			begin

					INSERT INTO KARDESPEDtemp (KAP_FACTRANS, KAP_CantTotADescargar, KAP_Saldo_FED, KAP_Saldo_FED, KAP_INDICED_PED, KAP_INDICED_FACT, 
						MA_HIJO,  KAP_TIPO_DESC, KAP_FisComp, KAP_PADREMAIN, KAP_PADRESUST, KAP_SaldoPedAntesDescargar)
	
					SELECT     TOP 100 PERCENT @CodigoFactura, KARDESPEDtemp.KAP_CantTotADescargar, 
						case when isnull((select  sum(SD.Pid_SaldoGen) from vPiDescarga SD
								WHERE  (SD.Ma_Codigo =  KARDESPEDtemp.MA_HIJO)  				
									AND (SD.Pid_SaldoGen > 0)
								  and SD.Pid_IdDescarga <= vPIDescarga.Pid_IdDescarga
								),0) >round(KARDESPEDtemp.KAP_Saldo_FED,6) then 0 else
			
								round(KARDESPEDtemp.KAP_Saldo_FED,6)-isnull((select  sum(SD.Pid_SaldoGen) from vPiDescarga SD
								WHERE  (SD.Ma_Codigo =  KARDESPEDtemp.MA_HIJO) AND 				
									  (SD.Pid_SaldoGen > 0)
								  and SD.Pid_IdDescarga <= vPIDescarga.Pid_IdDescarga
								),0) end Kap_Saldo_FED,
						(select  CASE 
									WHEN ((round(KARDESPEDtemp.KAP_Saldo_FED,6)-sum(SDS.Pid_SaldoGen)) IS NULL) and (round(KARDESPEDtemp.KAP_Saldo_FED,6) >= vPIDescarga.Pid_SaldoGen) 
									THEN 	vPIDescarga.Pid_SaldoGen
									WHEN (round(KARDESPEDtemp.KAP_Saldo_FED,6)-sum(SDS.Pid_SaldoGen) IS NULL) and (round(KARDESPEDtemp.KAP_Saldo_FED,6) < vPIDescarga.Pid_SaldoGen)  
									THEN 	round(KARDESPEDtemp.KAP_Saldo_FED,6) 
									WHEN (round(KARDESPEDtemp.KAP_Saldo_FED,6)-sum(SDS.Pid_SaldoGen)) > vPIDescarga.Pid_SaldoGen 
									THEN 	VPiDescarga.Pid_SaldoGen 
									WHEN ((round(KARDESPEDtemp.KAP_Saldo_FED,6)-sum(SDS.Pid_SaldoGen)) < 0) 
									THEN 	0
									ELSE (round(KARDESPEDtemp.KAP_Saldo_FED,6)-sum(SDS.Pid_SaldoGen)) 
									END CampoCase
									from  vPIDescarga SDS
									WHERE  (SDS.Ma_Codigo =  KARDESPEDtemp.MA_HIJO) 		
			                                                       AND (SDS.Pid_SaldoGen > 0)
									  and SDS.Pid_IdDescarga < vPIDescarga.Pid_IdDescarga
							)   KAP_Saldo_FED,
	
					vPIDescarga.PID_INDICED, KARDESPEDtemp.KAP_INDICED_FACT, KARDESPEDtemp.MA_HIJO, KARDESPEDtemp.KAP_TIPO_DESC,
					'KAP_FISCOMP'=case when (@descini='S' and KARDESPEDtemp.KAP_FISCOMP='N')  or (@descini='N' and (@padre=0 or @fiscomp='X')) then 'N' else 'S' end,
					@padremain, @padre, vPIDescarga.Pid_SaldoGen
					FROM         vPIDescarga INNER JOIN
					                      KARDESPEDtemp ON vPIDescarga.MA_CODIGO = KARDESPEDtemp.MA_HIJO
					WHERE     vPIDescarga.PID_SALDOGEN > 0 
					and round(KARDESPEDtemp.KAP_Saldo_FED,6)>0 
					and (KARDESPEDtemp.KAP_INDICED_FACT= @fed_indiced)
					AND ((select  CASE 
										WHEN ((round(KARDESPEDtemp.KAP_Saldo_FED,6)-sum(SDS.Pid_SaldoGen)) IS NULL) and (round(KARDESPEDtemp.KAP_Saldo_FED,6) >= vPIDescarga.Pid_SaldoGen) 
										THEN 	vPIDescarga.Pid_SaldoGen
										WHEN (round(KARDESPEDtemp.KAP_Saldo_FED,6)-sum(SDS.Pid_SaldoGen) IS NULL) and (round(KARDESPEDtemp.KAP_Saldo_FED,6) < vPIDescarga.Pid_SaldoGen)  
										THEN 	round(KARDESPEDtemp.KAP_Saldo_FED,6) 
										WHEN (round(KARDESPEDtemp.KAP_Saldo_FED,6)-sum(SDS.Pid_SaldoGen)) > vPIDescarga.Pid_SaldoGen 
										THEN 	vPIDescarga.Pid_SaldoGen 
										WHEN ((round(KARDESPEDtemp.KAP_Saldo_FED,6)-sum(SDS.Pid_SaldoGen)) < 0) 
										THEN 	0
										ELSE (round(KARDESPEDtemp.KAP_Saldo_FED,6)-sum(SDS.Pid_SaldoGen)) 
										END CampoCase
										from  vPIDescarga SDS
										WHERE  (SDS.Ma_Codigo =  KARDESPEDtemp.MA_HIJO)
						 				AND (SDS.Pid_SaldoGen > 0)
										  and SDS.Pid_IdDescarga < vPIDescarga.Pid_IdDescarga
										)  > 0) 
					and (KARDESPEDtemp.KAP_TIPO_DESC=left(@tipodescarga,1) or KARDESPEDtemp.KAP_TIPO_DESC=right(@tipodescarga,1))
				       and kap_codigo in (SELECT MAX(KAP_CODIGO) FROM KARDESPEDtemp WHERE (KAP_FACTRANS = @CodigoFactura) AND (KAP_INDICED_FACT = @fed_indiced)
					        GROUP BY MA_HIJO)
					order by KARDESPEDtemp.KAP_INDICED_FACT, KARDESPEDtemp.MA_HIJO, vPIDescarga.Pid_IdDescarga
				
			end
			else --UEPS
			begin


					INSERT INTO KARDESPEDtemp (KAP_FACTRANS, KAP_CantTotADescargar, KAP_Saldo_FED, KAP_Saldo_FED, KAP_INDICED_PED, KAP_INDICED_FACT, 
						MA_HIJO,  KAP_TIPO_DESC, KAP_FisComp, KAP_PADREMAIN, KAP_PADRESUST, KAP_SaldoPedAntesDescargar)
	
					SELECT     TOP 100 PERCENT @CodigoFactura, KARDESPEDtemp.KAP_CantTotADescargar, 
						case when isnull((select  sum(SD.Pid_SaldoGen) from vPiDescarga SD
								WHERE  (SD.Ma_Codigo =  KARDESPEDtemp.MA_HIJO)  				
									AND (SD.Pid_SaldoGen > 0)
								  and SD.Pid_IdDescarga <= vPIDescarga.Pid_IdDescarga
								),0) >round(KARDESPEDtemp.KAP_Saldo_FED,6) then 0 else
			
								round(KARDESPEDtemp.KAP_Saldo_FED,6)-isnull((select  sum(SD.Pid_SaldoGen) from vPiDescarga SD
								WHERE  (SD.Ma_Codigo =  KARDESPEDtemp.MA_HIJO) AND 				
									  (SD.Pid_SaldoGen > 0)
								  and SD.Pid_IdDescarga <= vPIDescarga.Pid_IdDescarga
								),0) end Kap_Saldo_FED,
						(select  CASE 
									WHEN ((round(KARDESPEDtemp.KAP_Saldo_FED,6)-sum(SDS.Pid_SaldoGen)) IS NULL) and (round(KARDESPEDtemp.KAP_Saldo_FED,6) >= vPIDescarga.Pid_SaldoGen) 
									THEN 	vPIDescarga.Pid_SaldoGen
									WHEN (round(KARDESPEDtemp.KAP_Saldo_FED,6)-sum(SDS.Pid_SaldoGen) IS NULL) and (round(KARDESPEDtemp.KAP_Saldo_FED,6) < vPIDescarga.Pid_SaldoGen)  
									THEN 	round(KARDESPEDtemp.KAP_Saldo_FED,6) 
									WHEN (round(KARDESPEDtemp.KAP_Saldo_FED,6)-sum(SDS.Pid_SaldoGen)) > vPIDescarga.Pid_SaldoGen 
									THEN 	VPiDescarga.Pid_SaldoGen 
									WHEN ((round(KARDESPEDtemp.KAP_Saldo_FED,6)-sum(SDS.Pid_SaldoGen)) < 0) 
									THEN 	0
									ELSE (round(KARDESPEDtemp.KAP_Saldo_FED,6)-sum(SDS.Pid_SaldoGen)) 
									END CampoCase
									from  vPIDescarga SDS
									WHERE  (SDS.Ma_Codigo =  KARDESPEDtemp.MA_HIJO) 		
			                                                       AND (SDS.Pid_SaldoGen > 0)
									  and SDS.Pid_IdDescarga < vPIDescarga.Pid_IdDescarga
							)   KAP_Saldo_FED,
	
					vPIDescarga.PID_INDICED, KARDESPEDtemp.KAP_INDICED_FACT, KARDESPEDtemp.MA_HIJO, KARDESPEDtemp.KAP_TIPO_DESC,
					'KAP_FISCOMP'=case when (@descini='S' and KARDESPEDtemp.KAP_FISCOMP='N')  or (@descini='N' and (@padre=0 or @fiscomp='X')) then 'N' else 'S' end,
					@padremain, @padre, vPIDescarga.Pid_SaldoGen
					FROM         vPIDescarga INNER JOIN
					                      KARDESPEDtemp ON vPIDescarga.MA_CODIGO = KARDESPEDtemp.MA_HIJO
					WHERE     vPIDescarga.PID_SALDOGEN > 0 
					and round(KARDESPEDtemp.KAP_Saldo_FED,6)>0 
					and (KARDESPEDtemp.KAP_INDICED_FACT= @fed_indiced)
					AND ((select  CASE 
										WHEN ((round(KARDESPEDtemp.KAP_Saldo_FED,6)-sum(SDS.Pid_SaldoGen)) IS NULL) and (round(KARDESPEDtemp.KAP_Saldo_FED,6) >= vPIDescarga.Pid_SaldoGen) 
										THEN 	vPIDescarga.Pid_SaldoGen
										WHEN (round(KARDESPEDtemp.KAP_Saldo_FED,6)-sum(SDS.Pid_SaldoGen) IS NULL) and (round(KARDESPEDtemp.KAP_Saldo_FED,6) < vPIDescarga.Pid_SaldoGen)  
										THEN 	round(KARDESPEDtemp.KAP_Saldo_FED,6) 
										WHEN (round(KARDESPEDtemp.KAP_Saldo_FED,6)-sum(SDS.Pid_SaldoGen)) > vPIDescarga.Pid_SaldoGen 
										THEN 	vPIDescarga.Pid_SaldoGen 
										WHEN ((round(KARDESPEDtemp.KAP_Saldo_FED,6)-sum(SDS.Pid_SaldoGen)) < 0) 
										THEN 	0
										ELSE (round(KARDESPEDtemp.KAP_Saldo_FED,6)-sum(SDS.Pid_SaldoGen)) 
										END CampoCase
										from  vPIDescarga SDS
										WHERE  (SDS.Ma_Codigo =  KARDESPEDtemp.MA_HIJO)
						 				AND (SDS.Pid_SaldoGen > 0)
										  and SDS.Pid_IdDescarga < vPIDescarga.Pid_IdDescarga
										)  > 0) 
					and (KARDESPEDtemp.KAP_TIPO_DESC=left(@tipodescarga,1) or KARDESPEDtemp.KAP_TIPO_DESC=right(@tipodescarga,1))
				       and kap_codigo in (SELECT MAX(KAP_CODIGO) FROM KARDESPEDtemp WHERE (KAP_FACTRANS = @CodigoFactura) AND (KAP_INDICED_FACT = @fed_indiced)
					        GROUP BY MA_HIJO)
					order by KARDESPEDtemp.KAP_INDICED_FACT, KARDESPEDtemp.MA_HIJO, vPIDescarga.Pid_IdDescarga desc
		
	
			end
	
		commit tran
	
	
		begin tran
			update pidescarga
			set PID_SALDOGEN=(select kap_saldopedantesdescargar-KAP_Saldo_FED from KARDESPEDtemp where kap_codigo in
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


		delete from kardespedtemp where kap_indiced_fact=@fed_indiced 
		and kap_estatus='N' and ma_hijo in
		(select ma_hijo from kardespedtemp where kap_indiced_fact=@fed_indiced and kap_cantdesc>0)

/*

inicio:


	begin tran

		if @MetodoDescarga='PEPS'
		begin
				INSERT INTO KARDESPEDtemp (KAP_FACTRANS, KAP_CantTotADescargar, KAP_CANTDESC, KAP_INDICED_PED, KAP_INDICED_FACT, 
					MA_HIJO, KAP_TIPO_DESC, KAP_FisComp, KAP_PADREMAIN, KAP_PADRESUST)
			
				SELECT @CodigoFactura, KAP_CantTotADescargar, 'KAP_CANTDESC'=case when vPIDescarga.PID_SALDOGEN<=KARDESPEDtemp.KAP_Saldo_FED 
				then round(vPIDescarga.PID_SALDOGEN,6)
				else round(KARDESPEDtemp.KAP_Saldo_FED,6) end, vPIDescarga.PID_INDICED, KARDESPEDtemp.KAP_INDICED_FACT, KARDESPEDtemp.MA_HIJO,
				KARDESPEDtemp.KAP_TIPO_DESC, 'KAP_FISCOMP'=case when (@descini='S' and KARDESPEDtemp.KAP_FISCOMP='N')  or (@descini='N' and (@padre=0 or @fiscomp='X')) then 'N' else 'S' end, @padremain, @padre
				FROM         KARDESPEDtemp INNER JOIN
				                      vPIDescarga ON KARDESPEDtemp.MA_HIJO = vPIDescarga.MA_CODIGO
				WHERE  (KARDESPEDtemp.KAP_Saldo_FED > 0) and
					KARDESPEDtemp.KAP_INDICED_FACT=@fed_indiced
					AND vPIDescarga.PID_INDICED IN 
					(SELECT     TOP 100 PERCENT MIN(vPIDescarga1.PID_INDICED)
					FROM         vPIDescarga vPIDescarga1
					WHERE     vPIDescarga1.PID_SALDOGEN > 0 AND 
					                      vPIDescarga1.MA_CODIGO = KARDESPEDtemp.MA_HIJO AND vPIDescarga1.PI_FEC_ENT IN
						(SELECT     TOP 100 PERCENT MIN(vPIDescarga2.PI_FEC_ENT) AS PI_FEC_ENT
						FROM         vPIDescarga vPIDescarga2
						WHERE     vPIDescarga2.PID_SALDOGEN > 0 AND 
						                      vPIDescarga2.MA_CODIGO = KARDESPEDtemp.MA_HIJO and vPIDescarga2.PI_FEC_ENT<= @fe_fecha))
			
			       and kap_codigo in (SELECT MAX(KAP_CODIGO) FROM KARDESPEDtemp WHERE (KAP_FACTRANS = @CodigoFactura) AND (KAP_INDICED_FACT = @fed_indiced)
				        GROUP BY MA_HIJO)
				group by KAP_CantTotADescargar, vPIDescarga.PID_INDICED, KARDESPEDtemp.KAP_INDICED_FACT, KARDESPEDtemp.MA_HIJO,
				 KARDESPEDtemp.KAP_TIPO_DESC,KARDESPEDtemp.KAP_FISCOMP,  vPIDescarga.PID_SALDOGEN, KARDESPEDtemp.KAP_Saldo_FED 

		end
		else -- UEPS
		begin

				INSERT INTO KARDESPEDtemp (KAP_FACTRANS, KAP_CantTotADescargar, KAP_CANTDESC, KAP_INDICED_PED, KAP_INDICED_FACT, 
					MA_HIJO,KAP_TIPO_DESC, KAP_FisComp, KAP_PADREMAIN, KAP_PADRESUST)
			
				SELECT @CodigoFactura, KAP_CantTotADescargar, 'KAP_CANTDESC'=case when vPIDescarga.PID_SALDOGEN<=KARDESPEDtemp.KAP_Saldo_FED 
				then round(vPIDescarga.PID_SALDOGEN,6)
				else round(KARDESPEDtemp.KAP_Saldo_FED,6) end, vPIDescarga.PID_INDICED, KARDESPEDtemp.KAP_INDICED_FACT, KARDESPEDtemp.MA_HIJO,
				KARDESPEDtemp.KAP_TIPO_DESC, 'KAP_FISCOMP'=case when (@descini='S' and KARDESPEDtemp.KAP_FISCOMP='N')  or (@descini='N' and (@padre=0 or @fiscomp='X')) then 'N' else 'S' end, @padremain, @padre
				FROM         KARDESPEDtemp INNER JOIN
				                      vPIDescarga ON KARDESPEDtemp.MA_HIJO = vPIDescarga.MA_CODIGO
				WHERE  (KARDESPEDtemp.KAP_Saldo_FED > 0) and
					KARDESPEDtemp.KAP_INDICED_FACT=@fed_indiced
					AND vPIDescarga.PID_INDICED IN 
					(SELECT     TOP 100 PERCENT MAX(vPIDescarga1.PID_INDICED)
					FROM         vPIDescarga vPIDescarga1
					WHERE     vPIDescarga1.PID_SALDOGEN > 0 AND 
					                      vPIDescarga1.MA_CODIGO = KARDESPEDtemp.MA_HIJO AND vPIDescarga1.PI_FEC_ENT IN
						(SELECT     TOP 100 PERCENT MAX(vPIDescarga2.PI_FEC_ENT) AS PI_FEC_ENT
						FROM         vPIDescarga vPIDescarga2
						WHERE     vPIDescarga2.PID_SALDOGEN > 0 AND 
						                      vPIDescarga2.MA_CODIGO = KARDESPEDtemp.MA_HIJO and vPIDescarga2.PI_FEC_ENT<= @fe_fecha))
			
			       and kap_codigo in (SELECT MAX(KAP_CODIGO) FROM KARDESPEDtemp WHERE (KAP_FACTRANS = @CodigoFactura) AND (KAP_INDICED_FACT = @fed_indiced)
				        GROUP BY MA_HIJO)
				group by KAP_CantTotADescargar, vPIDescarga.PID_INDICED, KARDESPEDtemp.KAP_INDICED_FACT, KARDESPEDtemp.MA_HIJO,
				 KARDESPEDtemp.KAP_TIPO_DESC,KARDESPEDtemp.KAP_FISCOMP,  vPIDescarga.PID_SALDOGEN, KARDESPEDtemp.KAP_Saldo_FED 
			
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

	delete from kardespedtemp where kap_indiced_fact=@fed_indiced 
	and kap_estatus='N' and ma_hijo in
	(select ma_hijo from kardespedtemp where kap_indiced_fact=@fed_indiced and kap_cantdesc>0)


		if @CF_DESCARGAVENCIDOS='S' 
		begin
				select @existe=count(pid_indiced) from vPIDescarga where pid_saldogen>0 and
				ma_codigo in (select ma_hijo from kardespedtemp where kap_saldo_fed>0 and (kap_estatus<>'N' or kap_estatus is null) and kap_indiced_fact=@fed_indiced and kap_codigo in
				 (SELECT MAX(KAP_CODIGO) FROM KARDESPEDtemp WHERE (KAP_FACTRANS = @CodigoFactura) AND (KAP_INDICED_FACT = @fed_indiced)
					        GROUP BY MA_HIJO)) and pi_fec_ent <=@fe_fecha

			while (@existe>0)
			begin
				goto inicio
			end
		end
		else
		begin
				select @existe=count(pid_indiced) from vPIDescarga where pid_saldogen>0 and
				ma_codigo in (select ma_hijo from kardespedtemp where kap_saldo_fed>0 and (kap_estatus<>'N' or kap_estatus is null) and kap_indiced_fact=@fed_indiced and kap_codigo in
				 (SELECT MAX(KAP_CODIGO) FROM KARDESPEDtemp WHERE (KAP_FACTRANS = @CodigoFactura) AND (KAP_INDICED_FACT = @fed_indiced)
					        GROUP BY MA_HIJO)) and pi_fec_ent <=@fe_fecha and vPIDescarga.pid_fechavence>=@fe_fecha

			while (@existe>0)
			begin
				goto inicio
			end
		end


		*/

GO
