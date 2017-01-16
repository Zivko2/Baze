SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_PRORRATEASALDO] (@pid_indiced int, @ConDecimales char(1)='N')   as

declare @pid_saldogen decimal(36,6), @ValorProrrateado decimal(36,6), @restaDescargar decimal(36,6), @kap_codigo int, 
@cantRestar decimal(36,6), @MA_HIJO INT, @KAP_PADRESUST INT, @KAP_INDICED_FACT INT

select @pid_saldogen=pid_saldogen from pidescarga where pid_indiced= @pid_indiced

	if @pid_saldogen < 1 
		set @ValorProrrateado=@pid_saldogen
	else
	begin
		if @ConDecimales='S'
			select @ValorProrrateado=@pid_saldogen/(count(*)) from kardesped where kap_indiced_ped=@pid_indiced
		else
			select @ValorProrrateado=round(@pid_saldogen/(count(*)),0) from kardesped where kap_indiced_ped=@pid_indiced
	
	
		
		if @ValorProrrateado=0 or @ValorProrrateado is null
		set @ValorProrrateado=1
	end	
	
	
	set @restaDescargar=@pid_saldogen



	declare cur_prorrateo cursor for
		SELECT     KAP_CODIGO, MA_HIJO, ISNULL(KAP_PADRESUST,0), KAP_INDICED_FACT
		FROM         KARDESPED
		WHERE     (KAP_INDICED_PED = @pid_indiced)
		ORDER BY KAP_CODIGO
	open cur_prorrateo
	
	
		FETCH NEXT FROM cur_prorrateo INTO @kap_codigo, @MA_HIJO, @KAP_PADRESUST, @KAP_INDICED_FACT
	
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN

			if @restaDescargar<@ValorProrrateado
			begin
				UPDATE KARDESPED
				SET KAP_CANTDESC=KAP_CANTDESC+@restaDescargar,
				KAP_CantTotADescargar=KAP_CantTotADescargar+@restaDescargar
				WHERE KAP_CODIGO=@kap_codigo	

				if @KAP_PADRESUST>0
				begin
					update kardesped 
					set KAP_CantTotADescargar=KAP_CantTotADescargar+@restaDescargar,
					kap_saldo_fed=kap_saldo_fed+@restaDescargar
					where KAP_INDICED_FACT=@KAP_INDICED_FACT AND (KAP_PADRESUST=@KAP_PADRESUST or MA_HIJO=@KAP_PADRESUST) and
					kap_codigo<>@kap_codigo and kap_saldo_fed>0
	
				end
				else
				begin
					update kardesped 
					set KAP_CantTotADescargar=KAP_CantTotADescargar+@restaDescargar,
					kap_saldo_fed=kap_saldo_fed+@restaDescargar
					where KAP_INDICED_FACT=@KAP_INDICED_FACT AND (KAP_PADRESUST=@MA_HIJO or MA_HIJO=@MA_HIJO) and
					kap_codigo<>@kap_codigo and kap_saldo_fed>0
	
				end
				
				set @restaDescargar=0	

			end
			else
			begin
				UPDATE KARDESPED
				SET KAP_CANTDESC=KAP_CANTDESC+@ValorProrrateado, 
				KAP_CantTotADescargar=KAP_CantTotADescargar+@ValorProrrateado
				WHERE KAP_CODIGO=@kap_codigo



				if @KAP_PADRESUST>0
				begin
					update kardesped 
					set KAP_CantTotADescargar=KAP_CantTotADescargar+@ValorProrrateado,
					kap_saldo_fed=kap_saldo_fed+@ValorProrrateado
					where KAP_INDICED_FACT=@KAP_INDICED_FACT AND (KAP_PADRESUST=@KAP_PADRESUST or MA_HIJO=@KAP_PADRESUST) and
					kap_codigo<>@kap_codigo and kap_saldo_fed>0
	
				end
				else
				begin
					update kardesped 
					set KAP_CantTotADescargar=KAP_CantTotADescargar+@ValorProrrateado,
					kap_saldo_fed=kap_saldo_fed+@ValorProrrateado
					where KAP_INDICED_FACT=@KAP_INDICED_FACT AND (KAP_PADRESUST=@MA_HIJO or MA_HIJO=@MA_HIJO) and
					kap_codigo<>@kap_codigo and kap_saldo_fed>0
	
				end

				set @restaDescargar=@restaDescargar-@ValorProrrateado
				
			end
			

	

			if @restaDescargar=0
			Break
	
		FETCH NEXT FROM cur_prorrateo INTO @kap_codigo, @MA_HIJO, @KAP_PADRESUST, @KAP_INDICED_FACT
	
	END
	
	CLOSE cur_prorrateo
	DEALLOCATE cur_prorrateo
	



		UPDATE PIDescarga
		SET     PIDescarga.PID_SALDOGEN= round((PEDIMPDET.PID_CAN_GEN)- (ISNULL(KAP_CANTDESC, 0) + ISNULL(CANTLIGA, 0) + ISNULL(CANTLIGAB, 0))  ,6)
		FROM         PEDIMPDET INNER JOIN
		                      PEDIMP ON PEDIMPDET.PI_CODIGO = PEDIMP.PI_CODIGO LEFT OUTER JOIN
		                      PIDescarga ON PEDIMPDET.PID_INDICED = PIDescarga.PID_INDICED LEFT OUTER JOIN
		                        (SELECT     SUM(KAP_CANTDESC) AS KAP_CANTDESC, KAP_INDICED_PED
		                              FROM         KARDESPED
		                              WHERE     KAP_INDICED_PED IS NOT NULL
					GROUP BY KAP_INDICED_PED) CANTDESC ON PEDIMPDET.PID_INDICED=CANTDESC.KAP_INDICED_PED LEFT OUTER JOIN
					(SELECT     SUM(FACTEXPDET.FED_CANT * FACTEXPDET.EQ_GEN) CANTLIGA, FACTEXPDET.PID_INDICED
		                              FROM         FACTEXPDET INNER JOIN
		                                                    FACTEXP ON FACTEXPDET.FE_CODIGO = FACTEXP.FE_CODIGO
		                              WHERE     FACTEXP.FE_ESTATUS IN ('D', 'P') AND FACTEXPDET.PID_INDICED<>-1
					GROUP BY FACTEXPdet.PID_INDICED) CANTLIGADA ON PEDIMPDET.PID_INDICED=CANTLIGADA.pid_indiced LEFT OUTER JOIN
					(SELECT     SUM(RETRABAJO.RE_INCORPOR * RETRABAJO.FACTCONV) CANTLIGAB, RETRABAJO.PID_INDICED
		                              FROM         RETRABAJO INNER JOIN
		                                                    FACTEXP ON RETRABAJO.FETR_CODIGO = FACTEXP.FE_CODIGO
		                              WHERE     FACTEXP.FE_ESTATUS IN ('D', 'P') AND RETRABAJO.PID_INDICED<>-1
					GROUP BY RETRABAJO.PID_INDICED) CANTLIGADAB ON PEDIMPDET.PID_INDICED=CANTLIGADAB.PID_INDICED
		WHERE     PEDIMPDET.PID_INDICED=@pid_indiced


GO
