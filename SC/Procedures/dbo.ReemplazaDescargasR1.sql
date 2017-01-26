SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ReemplazaDescargasR1] (@picodigo int, @user int, @ccp_tipo varchar(5))   as

declare  @maximo int, @FechaActual varchar(10), @hora varchar(15),  @em_codigo int, @kap_indiced_ped int,
 @pid_saldogenr decimal(38,6),  @pid_can_genr decimal(38,6),@Sumkap_CantDesc decimal(38,6)


	if @ccp_tipo='RE'
	begin

		delete from pidescarga where pi_codigo in (select pi_rectifica from pedimp where pi_codigo=@picodigo)

		if exists(select * from kardesped where kap_indiced_ped in 
		(select pid_indiced from pedimpdet where pi_codigo in (select pi_rectifica from pedimp where pi_codigo=@picodigo)))
		BEGIN
	
			select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)
			
			insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
			values (@user, 2, 'Actualizando Descargas con los nuevos Detalles R1 ', 'Updating Discharges with the new R1 Details  ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)
			
	

			-- actualiza el campo kap_indiced_ped de la tabla kardesped para cuando esta afectado 
			UPDATE dbo.KARDESPED
			SET     dbo.KARDESPED.KAP_INDICED_PED= dbo.FACTIMPDET.PID_INDICEDLIGAR1
			FROM         dbo.FACTIMPDET INNER JOIN
			                      dbo.KARDESPED ON dbo.FACTIMPDET.PID_INDICEDLIGA = dbo.KARDESPED.KAP_INDICED_PED INNER JOIN
			                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
			WHERE     (dbo.FACTIMP.PI_RECTIFICA = @picodigo) AND dbo.FACTIMPDET.PID_INDICEDLIGAR1<>-1
	
	
			update pedimp
			set pi_updaterect='N'
			where pi_codigo=@picodigo
	
		END	
	
		if exists(select * from pedimp where pi_updaterect='N' and pi_codigo=@picodigo)
		begin
	
			select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)
			
			insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
			values (@user, 2, 'Actualizando saldos de Detalles R1 ', 'Updating R1 Detail Balances ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)
			
	
			-- cursor para actualizar saldos del redimento R1
			declare cur_actualizasaldorect cursor for
				SELECT dbo.KARDESPED.KAP_INDICED_PED, isnull(PIDESCARGA.PID_SALDOGEN,0), 
					--Yolanda Avila
					--2010-08-11
					--isnull(round(dbo.PedImpDet.PID_CAN_GEN,0),0), isnull(round(SUM(dbo.KARDESPED.KAP_CANTDESC),0),0)
					isnull(round(dbo.PedImpDet.PID_CAN_GEN,6),0), isnull(round(SUM(dbo.KARDESPED.KAP_CANTDESC),6),0)
				FROM         dbo.KARDESPED INNER JOIN
			                      dbo.PedImpDet ON dbo.KARDESPED.KAP_INDICED_PED = dbo.PedImpDet.PID_INDICED
					LEFT OUTER JOIN PIDESCARGA ON dbo.PedImpDet.PID_INDICED=PIDESCARGA.PID_INDICED
				WHERE dbo.PedImpDet.PI_CODIGO=@picodigo
				GROUP BY PIDESCARGA.PID_SALDOGEN, dbo.PedImpDet.PID_CAN_GEN, dbo.KARDESPED.KAP_INDICED_PED
			open cur_actualizasaldorect
		
				fetch next from cur_actualizasaldorect into @kap_indiced_ped, @pid_saldogenr, @pid_can_genr, @Sumkap_CantDesc 
					WHILE (@@FETCH_STATUS = 0) 
				BEGIN
			
		
					if @Sumkap_CantDesc<>0 and (@pid_saldogenr <> (@pid_can_genr-@Sumkap_CantDesc))
					update pidescarga
					set pid_saldogen = isnull((@pid_can_genr-@Sumkap_CantDesc),0)
					Where pid_indiced =  @kap_indiced_ped
		
					
					fetch next from cur_actualizasaldorect into @kap_indiced_ped, @pid_saldogenr, @pid_can_genr, @Sumkap_CantDesc 
				END
				CLOSE cur_actualizasaldorect
				DEALLOCATE cur_actualizasaldorect
	
		end


		EXEC SP_ACTUALIZAESTATUSPEDIMP @picodigo

	end

GO
