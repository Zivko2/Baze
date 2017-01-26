SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[FillPIDescarga] (@picodigo int, @user int)   as

declare  @maximo int, @FechaActual varchar(10), @hora varchar(15),
@kap_indiced_ped int, @pid_saldogenr decimal(38,6),  @pid_can_genr decimal(38,6),@Sumkap_CantDesc decimal(38,6), @em_codigo int, @PI_USA_TIP_CAMFACT char(1),
 @ccp_tipo varchar(5), @pi_rectifica int, @ccp_tipo2 varchar(5)

	if (select min(pid_indiced) from TempPedImpDet)=0
		SELECT     @maximo= isnull(MAX(PID_INDICED),0)+1
		FROM         PEDIMPDET
	else
		SELECT     @maximo= isnull(MAX(PID_INDICED),1)
		FROM         PEDIMPDET


	select @ccp_tipo=ccp_tipo from configuraclaveped where cp_codigo in (select cp_codigo from pedimp where pi_codigo=@picodigo)
	select @pi_rectifica=pi_rectifica from pedimp where pi_codigo=@picodigo
	select @ccp_tipo2=ccp_tipo from configuraclaveped where cp_codigo in (select cp_codigo from pedimp where pi_codigo=@pi_rectifica)


	delete from pidescarga where pi_codigo not in (select pi_codigo from vpedimp)
	delete from pidescarga where pid_indiced not in (select pid_indiced from vpedimp inner join pedimpdet on vpedimp.pi_codigo=pedimpdet.pi_codigo)

	delete from pidescarga where pi_codigo=@picodigo


	insert into PIDescarga(PI_CODIGO, PID_INDICED, PID_SALDOGEN, MA_CODIGO, MA_GENERICO, PI_FEC_ENT, PI_ACTIVOFIJO, DI_DEST_ORIGEN)
	SELECT TempPedImpDet.PI_CODIGO, TempPedImpDet.PID_INDICED+@maximo, TempPedImpDet.PID_CAN_GEN, TempPedImpDet.MA_CODIGO, TempPedImpDet.MA_GENERICO, 
	CASE WHEN PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('TS')) then PEDIMP.PI_FEC_ENTPED else PEDIMP.PI_FEC_ENT end, 
	'PI_ACTIVOFIJO'=(CASE WHEN PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IA', 'IB', 'IM')) OR
				PEDIMP.CP_RECTIFICA in (select cp_codigo from configuraclaveped where ccp_tipo in ('IA', 'IB', 'IM')) 
				OR (PEDIMP.PI_DESP_EQUIPO='S' AND (PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ( 'VT', 'IV')) OR
				PEDIMP.CP_RECTIFICA in (select cp_codigo from configuraclaveped where ccp_tipo in ('VT', 'IV')))) OR
				TempPedImpDet.TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN('H', 'Q', 'X', 'C')) THEN 'S' ELSE 'N' END),
	PEDIMP.DI_DEST_ORIGEN
	FROM PEDIMP LEFT OUTER JOIN
	                      CLAVEPED ON PEDIMP.CP_CODIGO = CLAVEPED.CP_CODIGO INNER JOIN
	                      TempPedImpDet ON PEDIMP.PI_CODIGO = TempPedImpDet.PI_CODIGO
	WHERE (PEDIMP.PI_ACTIVO_DESCARGA = 'S') AND (PEDIMP.PI_MOVIMIENTO='E') 
			and ((CLAVEPED.CP_DESCARGABLE = 'S' and @ccp_tipo<>'RE') or (@ccp_tipo='RE'  and PI_GENERASALDOF4 ='S'))
			and (TempPedImpDet.pid_descargable='S') 
	and  TempPedImpDet.PI_CODIGO=@picodigo
	ORDER BY PEDIMP.PI_FEC_ENT ASC, PEDIMP.PI_CODIGO ASC





--	if (select CF_USASALDOPEDIMPDEFINITO from configuracion)='S' or (select cp_descargable from claveped where cp_codigo in (select cp_codigo from pedimp where pi_codigo=@picodigo))='S'
	begin
		insert into PIDescarga(PI_CODIGO, PID_INDICED, PID_SALDOGEN, MA_CODIGO, MA_GENERICO, PI_FEC_ENT, PI_ACTIVOFIJO, PI_DEFINITIVO, DI_DEST_ORIGEN)
		SELECT TempPedImpDet.PI_CODIGO, TempPedImpDet.PID_INDICED+@maximo, TempPedImpDet.PID_CAN_GEN, TempPedImpDet.MA_CODIGO, TempPedImpDet.MA_GENERICO, 
		CASE WHEN PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('TS')) then PEDIMP.PI_FEC_ENTPED else PEDIMP.PI_FEC_ENT end, 
		'PI_ACTIVOFIJO'=CASE WHEN TempPedImpDet.TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN('H', 'Q', 'X', 'C')) THEN 'S' ELSE 'N' END,
		'S', PEDIMP.DI_DEST_ORIGEN
		FROM PEDIMP LEFT OUTER JOIN
		                      CLAVEPED ON PEDIMP.CP_CODIGO = CLAVEPED.CP_CODIGO LEFT OUTER JOIN
		                      TempPedImpDet ON PEDIMP.PI_CODIGO = TempPedImpDet.PI_CODIGO 
		WHERE (PEDIMP.PI_MOVIMIENTO='E') 
		and (PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IE', 'RG', 'SI'))
		and PI_GENERASALDOF4 ='S')
		AND (PEDIMP.PI_ACTIVO_DESCARGA = 'S')
		and TempPedImpDet.PID_INDICED+@maximo not in (select PID_INDICED from PIDescarga)		
		and  TempPedImpDet.PI_CODIGO=@picodigo
		ORDER BY PEDIMP.PI_FEC_ENT ASC, PEDIMP.PI_CODIGO ASC


		SELECT     @maximo= MAX(PID_INDICED)+1
		FROM         dbo.PEDIMPDET

		-- el pedimento RG con PI_DESP_EQUIPO='S' viene de factura de exportacion ya que es regularizacion de material vencido
		if (@ccp_tipo='CN' or (@ccp_tipo='RG' and (select PI_DESP_EQUIPO from pedimp where pi_codigo=@picodigo)='S')) 
                   and (select PI_GENERASALDOF4 from pedimp where pi_codigo=@picodigo)='S'
		begin	
			insert into PIDescarga(PI_CODIGO, PID_INDICED, PID_SALDOGEN, MA_CODIGO, MA_GENERICO, PI_FEC_ENT, PI_ACTIVOFIJO, PI_DEFINITIVO, DI_DEST_ORIGEN)
			SELECT TempPedImpDetF4.PI_CODIGO, TempPedImpDetF4.PID_INDICED+@maximo, TempPedImpDetF4.PID_CAN_GEN, TempPedImpDetF4.MA_CODIGO, 
			TempPedImpDetF4.MA_GENERICO, PEDIMP.PI_FEC_ENT, 
			'PI_ACTIVOFIJO'=CASE WHEN TempPedImpDetF4.TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN('H', 'Q', 'X', 'C')) THEN 'S' ELSE 'N' END,
			'S', PEDIMP.DI_DEST_ORIGEN
			FROM PEDIMP LEFT OUTER JOIN
			                      CLAVEPED ON PEDIMP.CP_CODIGO = CLAVEPED.CP_CODIGO LEFT OUTER JOIN
			                      TempPedImpDetF4 ON PEDIMP.PI_CODIGO = TempPedImpDetF4.PI_CODIGO 
			WHERE (PEDIMP.PI_MOVIMIENTO='E')  and (PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('CN')) and PI_GENERASALDOF4 ='S')
			AND (PEDIMP.PI_ACTIVO_DESCARGA = 'S') and  TempPedImpDetF4.PI_CODIGO=@picodigo
			
			ORDER BY PEDIMP.PI_FEC_ENT ASC, PEDIMP.PI_CODIGO ASC

		end


		if ((@ccp_tipo2='CN' or @ccp_tipo2='RG') and (select PI_GENERASALDOF4 from pedimp where pi_codigo=@pi_rectifica)='S')
		begin
			insert into PIDescarga(PI_CODIGO, PID_INDICED, PID_SALDOGEN, MA_CODIGO, MA_GENERICO, PI_FEC_ENT, PI_ACTIVOFIJO, PI_DEFINITIVO, DI_DEST_ORIGEN)
			SELECT TempPedImpDetF4.PI_CODIGO, TempPedImpDetF4.PID_INDICED+@maximo, TempPedImpDetF4.PID_CAN_GEN, TempPedImpDetF4.MA_CODIGO, TempPedImpDetF4.MA_GENERICO, PEDIMP.PI_FEC_ENT, 
			'PI_ACTIVOFIJO'=CASE WHEN TempPedImpDetF4.TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN('H', 'Q', 'X', 'C')) THEN 'S' ELSE 'N' END,
			'S', PEDIMP.DI_DEST_ORIGEN
			FROM PEDIMP LEFT OUTER JOIN
			                      CLAVEPED ON PEDIMP.CP_CODIGO = CLAVEPED.CP_CODIGO LEFT OUTER JOIN
			                      TempPedImpDetF4 ON PEDIMP.PI_CODIGO = TempPedImpDetF4.PI_CODIGO 
			WHERE (PEDIMP.PI_MOVIMIENTO='E')  AND (PEDIMP.PI_ACTIVO_DESCARGA = 'S') and PI_GENERASALDOF4 ='S'
			and  TempPedImpDetF4.PI_CODIGO=@picodigo
			ORDER BY PEDIMP.PI_FEC_ENT ASC, PEDIMP.PI_CODIGO ASC

		end


	end



/*	if @ccp_tipo='RE'
	begin

		delete from pidescarga where pi_codigo in (select pi_rectifica from pedimp where pi_codigo=@picodigo)

		if exists(select * from kardesped where kap_indiced_ped in 
		(select pid_indiced from pedimpdet where pi_codigo in (select pi_rectifica from pedimp where pi_codigo=@picodigo)))
		BEGIN
	
			select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)
			
			insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
			values (@user, 2, 'Actualizando Descargas con los nuevos Detalles R1 ', 'Updating Discharges with the new R1 Details  ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)
			
	
			-- actualiza el campo kap_indiced_pedorig (original) como respaldo de la tabla kardesped para cuando esta afectado 
			INSERT INTO KARDESPEDR1 (KAP_CODIGO, KAP_INDICED_PEDORIG, KAP_INDICED_PEDR1, PI_CODIGOORIG, PI_CODIGOR1)
			SELECT     dbo.KARDESPED.KAP_CODIGO, dbo.KARDESPED.KAP_INDICED_PED, dbo.FACTIMPDET.PID_INDICEDLIGAR1, dbo.FACTIMP.PI_CODIGO, dbo.FACTIMP.PI_RECTIFICA
			FROM         dbo.FACTIMPDET INNER JOIN
			                      dbo.KARDESPED ON dbo.FACTIMPDET.PID_INDICEDLIGA = dbo.KARDESPED.KAP_INDICED_PED INNER JOIN
			                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO			
			WHERE     (dbo.FACTIMP.PI_RECTIFICA = @picodigo) and dbo.KARDESPED.KAP_CODIGO not in
			(SELECT KAP_CODIGO FROM KARDESPEDR1) AND dbo.FACTIMPDET.PID_INDICEDLIGAR1<>-1
			GROUP BY dbo.KARDESPED.KAP_CODIGO, dbo.KARDESPED.KAP_INDICED_PED, dbo.FACTIMPDET.PID_INDICEDLIGAR1, dbo.FACTIMP.PI_CODIGO, dbo.FACTIMP.PI_RECTIFICA
			
	
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
					isnull(round(dbo.TempPedImpDet.PID_CAN_GEN,0),0), isnull(round(SUM(dbo.KARDESPED.KAP_CANTDESC),0),0)
				FROM         dbo.KARDESPED INNER JOIN
			                      dbo.TempPedImpDet ON dbo.KARDESPED.KAP_INDICED_PED = dbo.TempPedImpDet.PID_INDICED+@maximo
					LEFT OUTER JOIN PIDESCARGA ON dbo.TempPedImpDet.PID_INDICED+@maximo=PIDESCARGA.PID_INDICED
				WHERE dbo.TempPedImpDet.PI_CODIGO=@picodigo
				GROUP BY PIDESCARGA.PID_SALDOGEN, dbo.TempPedImpDet.PID_CAN_GEN, dbo.KARDESPED.KAP_INDICED_PED
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

	end*/


GO
