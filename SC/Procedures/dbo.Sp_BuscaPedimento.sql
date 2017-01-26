SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sp_BuscaPedimento] (@CodigoFactura int, @MetodoDescarga Varchar(4), @fed_indiced int, @kap_padresust int, @ma_hijo int, 
@tipodescarga varchar(2), @KAP_CantTotADescargar decimal(38,6), @KAP_CantADescargar decimal(38,6), @Kap_Saldo_fed decimal(38,6) Output, @kap_codigoSaldo int Output, @Kap_CantDesc decimal(38,6) Output) AS
BEGIN


		INSERT INTO KARDESPEDtemp ( 
			Kap_Factrans,  
			MA_HIJO, 
			KAP_INDICED_FACT, 
			KAP_PADRESUST,  
			KAP_INDICED_PED, 
			KAP_SALDOPEDANTESDESCARGAR, 
			KAP_CantTotADescargar, 
			KAP_Saldo_FED, 			
			KAP_CANTDESC,
			KAP_TIPO_DESC)
			SELECT   @CodigoFactura, 
				 @ma_hijo, 	
				 @FED_INDICED, 
				 @kap_padresust, 	
				vPiDescarga.Pid_Indiced, 
				vPiDescarga.Pid_Saldogen,
				@KAP_CantADescargar,
				case when isnull((select  sum(SD.Pid_SaldoGen) from vPiDescarga SD
					WHERE  (SD.Ma_Codigo =  @ma_hijo)  				
					  and SD.Pid_IdDescarga <= vPIDescarga.Pid_IdDescarga
					),0) >@KAP_CantADescargar then 0 else			
					@KAP_CantADescargar-isnull((select  sum(SD.Pid_SaldoGen) from vPiDescarga SD
					WHERE  (SD.Ma_Codigo =  @ma_hijo) 	
					  and SD.Pid_IdDescarga <= vPIDescarga.Pid_IdDescarga
					),0) end Kap_Saldo_FED,

				 (select  CASE 
					WHEN ((@KAP_CantADescargar-sum(SDS.Pid_SaldoGen)) IS NULL) and (@KAP_CantADescargar >= vPIDescarga.Pid_SaldoGen) 
					THEN 	vPIDescarga.Pid_SaldoGen
					WHEN (@KAP_CantADescargar-sum(SDS.Pid_SaldoGen) IS NULL) and (@KAP_CantADescargar < vPIDescarga.Pid_SaldoGen)  
					THEN 	@KAP_CantADescargar 
					WHEN (@KAP_CantADescargar-sum(SDS.Pid_SaldoGen)) > vPIDescarga.Pid_SaldoGen 
					THEN 	VPiDescarga.Pid_SaldoGen 
					WHEN ((@KAP_CantADescargar-sum(SDS.Pid_SaldoGen)) < 0) 
					THEN 	0
					ELSE (@KAP_CantADescargar-sum(SDS.Pid_SaldoGen)) 
					END CampoCase
					from  vPIDescarga SDS
					WHERE  (SDS.Ma_Codigo =  @ma_hijo) 		
					  and SDS.Pid_IdDescarga < vPIDescarga.Pid_IdDescarga
				)   KAP_CANTDESC, @tipodescarga	

			FROM   vPiDescarga WHERE  (Ma_codigo=@ma_hijo) 
			and ((select  CASE 
						WHEN ((@KAP_CantADescargar-sum(Pid_Saldogen)) IS NULL) and (@KAP_CantADescargar >= vPiDescarga.Pid_Saldogen) 
						THEN 	vPiDescarga.Pid_Saldogen
						WHEN (@KAP_CantADescargar-sum(Pid_Saldogen) IS NULL) and (@KAP_CantADescargar < vPiDescarga.Pid_Saldogen)  
						THEN 	@KAP_CantADescargar 
						WHEN (@KAP_CantADescargar-sum(Pid_Saldogen)) > vPiDescarga.Pid_Saldogen 
						THEN 	vPiDescarga.Pid_Saldogen 
						WHEN ((@KAP_CantADescargar-sum(Pid_Saldogen)) < 0) 
						THEN 	0
						ELSE (@KAP_CantADescargar-sum(Pid_Saldogen)) 
						END CampoCase
						from  vPiDescarga SDS
						WHERE  (Ma_codigo=@ma_hijo) AND
						SDS.Pid_IdDescarga < vPiDescarga.Pid_IdDescarga
				)  > 0) order by vPiDescarga.Pid_Indiced



		-- RESTA EL SALDO EN LA TABLA DE PEDIMENTO

		UPDATE PiDescarga
		SET   Pid_Saldogen =  Pid_Saldogen - tempcantsum
		FROM         PiDescarga inner join (
					SELECT   Pid_Indiced, 
						(select  CASE  when  ((@KAP_CantADescargar-sum(Pid_Saldogen)) IS NULL) and (@KAP_CantADescargar >= vPiDescarga.Pid_Saldogen)  then vPiDescarga.Pid_Saldogen
				       		when ((@KAP_CantADescargar-sum(Pid_Saldogen)) IS NULL) and  (@KAP_CantADescargar < vPiDescarga.Pid_Saldogen)   then @KAP_CantADescargar
				       		when (@KAP_CantADescargar-sum(Pid_Saldogen)) > (vPiDescarga.Pid_Saldogen)
  				                          then vPiDescarga.Pid_Saldogen
				       	        when (@KAP_CantADescargar-sum(Pid_Saldogen)) < 0 then 0
						else (@KAP_CantADescargar-sum(Pid_Saldogen)) 
						END campo from vPiDescarga SDS
						WHERE  (Ma_codigo=@ma_hijo) 
						and SDS.Pid_IdDescarga < vPiDescarga.Pid_IdDescarga) tempcantsum
						FROM   vPiDescarga WHERE  (Ma_codigo=@ma_hijo) 
						and (select  CASE when  ((@KAP_CantADescargar-sum(Pid_Saldogen)) IS NULL) and (@KAP_CantADescargar >= vPiDescarga.Pid_Saldogen) then vPiDescarga.Pid_Saldogen
								when ((@KAP_CantADescargar-sum(Pid_Saldogen)) IS NULL) and  (@KAP_CantADescargar < vPiDescarga.Pid_Saldogen) 	then @KAP_CantADescargar
								when  (@KAP_CantADescargar-sum(Pid_Saldogen)) > (vPiDescarga.Pid_Saldogen) then vPiDescarga.Pid_Saldogen
								when (@KAP_CantADescargar-sum(Pid_Saldogen)) < 0  then 0
								else (@KAP_CantADescargar-sum(Pid_Saldogen)) 
							END from vPiDescarga SDS
					WHERE  (Ma_codigo=@ma_hijo) 
					and SDS.Pid_IdDescarga < vPiDescarga.Pid_IdDescarga) > 0
				) tabla 
			on tabla.Pid_Indiced = PiDescarga.Pid_Indiced



			declare @temp float
			select @temp = sum(tempcantsum) from 
					(
					SELECT   Pid_Indiced,  (select  CASE  when  ((@KAP_CantADescargar-sum(Pid_Saldogen)) IS NULL) and (@KAP_CantADescargar >= vPiDescarga.Pid_Saldogen)  then vPiDescarga.Pid_Saldogen
							    when ((@KAP_CantADescargar-sum(Pid_Saldogen)) IS NULL) and  (@KAP_CantADescargar < vPiDescarga.Pid_Saldogen)   then @KAP_CantADescargar
							    when (@KAP_CantADescargar-sum(Pid_Saldogen)) > (vPiDescarga.Pid_Saldogen) then vPiDescarga.Pid_Saldogen
							    when (@KAP_CantADescargar-sum(Pid_Saldogen)) < 0 then 0
							    else (@KAP_CantADescargar-sum(Pid_Saldogen)) 
							    END campo from vPiDescarga SDS
							    WHERE  (  Ma_codigo =  @ma_hijo) 
								and SDS.Pid_IdDescarga < vPiDescarga.Pid_IdDescarga) tempcantsum
								FROM   vPiDescarga WHERE  (  Ma_codigo =  @ma_hijo  ) AND ( Pid_Saldogen > 0 )
								and (select  CASE when  ((@KAP_CantADescargar-sum(Pid_Saldogen)) IS NULL) and (@KAP_CantADescargar >= vPiDescarga.Pid_Saldogen) then vPiDescarga.Pid_Saldogen
											when ((@KAP_CantADescargar-sum(Pid_Saldogen)) IS NULL) and  (@KAP_CantADescargar < vPiDescarga.Pid_Saldogen) 	then @KAP_CantADescargar
											when  (@KAP_CantADescargar-sum(Pid_Saldogen)) > (vPiDescarga.Pid_Saldogen)	then vPiDescarga.Pid_Saldogen
											when (@KAP_CantADescargar-sum(Pid_Saldogen)) < 0 then 0
											else (@KAP_CantADescargar-sum(Pid_Saldogen)) 
										END from vPiDescarga SDS
								WHERE  (Ma_codigo =  @ma_hijo)
								and SDS.Pid_IdDescarga < vPiDescarga.Pid_IdDescarga) > 0
					) tabla



	
		IF @temp IS NULL 
		set @temp = 0

		set @kap_codigoSaldo=0

		set @KAP_Saldo_fed = @KAP_CantADescargar - @temp

		set @Kap_CantDesc =@temp
	

		IF  (@KAP_CantADescargar > @temp)
		BEGIN
			INSERT INTO KARDESPEDtemp (Kap_factrans, KAP_INDICED_PED, MA_HIJO, KAP_INDICED_FACT, KAP_TIPO_DESC,
								KAP_PADRESUST, KAP_SALDOPEDANTESDESCARGAR, KAP_Saldo_FED, KAP_CANTDESC,  KAP_CantTotADescargar,
								KAP_ESTATUS)
			VALUES (@CodigoFactura, 0, @ma_hijo, @FED_INDICED, @tipodescarga, @kap_padresust, 0, @KAP_Saldo_fed, 0, @KAP_CantTotADescargar, 'N' )

			select @kap_codigoSaldo=max(kap_codigo) from KARDESPEDtemp
			set @Kap_CantDesc=0
		END
	


END
GO
