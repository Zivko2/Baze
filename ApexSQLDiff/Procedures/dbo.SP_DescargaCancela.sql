SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE dbo.SP_DescargaCancela (@nCodigoFactura Int, @bFromRange bit = 0, @bFromRange1 bit = 0)   as

SET NOCOUNT ON 

	DECLARE --@nFeCodigo Integer, 
	@PICODIGO Integer, @PIDINDICED Integer, @Factconv decimal(28,14), @CantDesc decimal(38,6), @KAPCODIGO int
	DECLARE @PIDSALDOGEN decimal(38,6), @PIDCANGEN decimal(38,6), @ValorDescProc decimal(38,6), @SumSaldoGen decimal(38,6), @SumCanGen decimal(38,6), @cpcodigo int, @fedindiced int,
	@fe_con_pedcr char (1)

	select @fe_con_pedcr = fe_con_pedcr from factexp where fe_codigo = @nCodigoFactura


	if @fe_con_pedcr <>'S'   /* si no se ha generado pedimento de cambio de regimen se podra cancelar */
	begin

		/* actualiza el campo pid_saldogen, pid_uso_saldo de los pedimentos de importacion que fueron afectados y se esta cancelando la descarga*/

			/*================= kardespedcont =========================*/

			if exists(select * from kardespedcont where fed_indiced IN
					(SELECT KAP_INDICED_FACT
					FROM KARDESPED WHERE KAP_FACTRANS = @nCodigoFactura 
					GROUP BY KAP_INDICED_FACT))
			begin
				UPDATE PEDIMPCONT
				SET PEDIMPCONT.PIC_USO_DESCARGA='N'
				FROM         dbo.KARDESPEDCONT INNER JOIN
		             		         dbo.PEDIMPCONT ON dbo.KARDESPEDCONT.PIC_INDICEC = dbo.PEDIMPCONT.PIC_INDICEC
				WHERE     dbo.KARDESPEDCONT.FED_INDICED IN (SELECT KAP_INDICED_FACT
						FROM KARDESPED WHERE KAP_FACTRANS = @nCodigoFactura 
						GROUP BY KAP_INDICED_FACT)
	
				DELETE FROM KARDESPEDCONT WHERE FED_INDICED in (SELECT KAP_INDICED_FACT
						FROM KARDESPED WHERE KAP_FACTRANS = @nCodigoFactura 
						GROUP BY KAP_INDICED_FACT)
			end


		exec  sp_droptable 'indiced'

		SELECT KAP_INDICED_PED,  SUM(KAP_CANTDESC) as KAP_CANTDESC
		INTO dbo.indiced
		FROM KARDESPED 
		WHERE KAP_FACTRANS=@nCodigoFactura AND KAP_INDICED_PED IS NOT NULL 
		AND KAP_INDICED_FACT NOT IN (SELECT FED_INDICED FROM FACTEXPDET WHERE FE_CODIGO=@nCodigoFactura AND PID_INDICED<>-1)
		GROUP BY KAP_INDICED_PED


		--Regresa el saldo para el control de retrabajo
		UPDATE ControlRetrabajo
		SET	   CR_Saldo = CR_Saldo + CRS_CantidadDescargada
		from ControlRetrabajo 
			inner join ControlRetrabajoSaldo on ControlRetrabajo.CR_Codigo = ControlRetrabajoSaldo.CR_Codigo
			inner join (SELECT KAP_INDICED_FACT
						FROM KARDESPED 
						WHERE KAP_FACTRANS=@nCodigoFactura AND KAP_INDICED_PED IS NOT NULL 
							AND KAP_INDICED_FACT NOT IN (SELECT FED_INDICED FROM FACTEXPDET WHERE FE_CODIGO=@nCodigoFactura AND PID_INDICED<>-1)
						GROUP BY KAP_INDICED_PED, KAP_INDICED_FACT) k on ControlRetrabajoSaldo.FED_Indiced = k.KAP_INDICED_FACT
		
		delete from ControlRetrabajoSaldo
		from ControlRetrabajoSaldo 
			inner join ControlRetrabajo on ControlRetrabajoSaldo.CR_Codigo = ControlRetrabajo.CR_Codigo 
			inner join (SELECT KAP_INDICED_FACT
						FROM KARDESPED 
						WHERE KAP_FACTRANS=@nCodigoFactura AND KAP_INDICED_PED IS NOT NULL 
							AND KAP_INDICED_FACT NOT IN (SELECT FED_INDICED FROM FACTEXPDET WHERE FE_CODIGO=@nCodigoFactura AND PID_INDICED<>-1)
						GROUP BY KAP_INDICED_PED, KAP_INDICED_FACT) k on ControlRetrabajoSaldo.FED_Indiced = k.KAP_INDICED_FACT


		DELETE FROM KARDESPED WHERE KAP_FACTRANS = @nCodigoFactura 	


		TRUNCATE TABLE KARDESPEDTEMP	


		UPDATE PIDescarga
		SET    PIDescarga.PID_SALDOGEN = round(PIDescarga.PID_SALDOGEN+indiced.KAP_CANTDESC,6)
		FROM   PIDescarga inner join indiced on PIDescarga.PID_INDICED=indiced.KAP_INDICED_PED
		
			
		
		
		


		/*UPDATE dbo.PIDescarga
		SET     dbo.PIDescarga.PID_SALDOGEN= round(dbo.VPEDIMPSALDO.KAP_SALDOGEN,6)
		FROM         dbo.PIDescarga INNER JOIN
		                      dbo.VPEDIMPSALDO ON dbo.PIDescarga.PID_INDICED = dbo.VPEDIMPSALDO.PID_INDICED AND 
		                      round(dbo.PIDescarga.PID_SALDOGEN,6) <> round(dbo.VPEDIMPSALDO.KAP_SALDOGEN,6)
		WHERE dbo.PIDescarga.PID_INDICED IN (SELECT KAP_INDICED_PED FROM indiced)

		UPDATE PIDescarga
		SET     PIDescarga.PID_SALDOGEN=round(PIDescarga.PID_SALDOGEN-isnull((select sum(FACTEXPDET.FED_CANT * FACTEXPDET.EQ_GEN) from factexpdet
		where pid_indiced=PIDescarga.pid_indiced),0),6)
		WHERE dbo.PIDescarga.PID_INDICED IN (SELECT KAP_INDICED_PED FROM indiced)*/

		-- se actualiza el campo PI_AFECTADO 				


		UPDATE PEDIMP 
		SET PI_AFECTADO = 'N'  --el estatus se modifica la cambiarlo en la tabla por el trigger 
		WHERE PI_CODIGO IN			
			(SELECT     dbo.PEDIMPDET.PI_CODIGO
			FROM         dbo.PEDIMPDET INNER JOIN
			                      dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
				     INNER JOIN PIDescarga ON dbo.PEDIMPDET.PID_INDICED=PIDescarga.PID_INDICED
			WHERE     (PEDIMP.PI_AFECTADO = 'S')
			GROUP BY PEDIMPDET.PI_CODIGO
			HAVING      (SUM(PIDescarga.PID_SALDOGEN) = SUM(dbo.PEDIMPDET.PID_CAN_GEN)))
		AND PI_CODIGO IN 
			(SELECT     dbo.PEDIMPDET.PI_CODIGO
			FROM         indiced INNER JOIN
			                      dbo.PEDIMPDET ON indiced.KAP_INDICED_PED = dbo.PEDIMPDET.PID_INDICED
			GROUP BY dbo.PEDIMPDET.PI_CODIGO)



		if not exists(select pi_codigo from pedimpdet where pi_codigo in (select KAP_INDICED_PED from kardesped
		where KAP_FACTRANS <> @nCodigoFactura))
		update pedimp
		set pi_updaterect='S'
		where pi_codigo IN (SELECT     dbo.PEDIMPDET.PI_CODIGO
				FROM         indiced INNER JOIN
				                      dbo.PEDIMPDET ON indiced.KAP_INDICED_PED = dbo.PEDIMPDET.PID_INDICED
				GROUP BY dbo.PEDIMPDET.PI_CODIGO)
		and pi_updaterect<>'S'



		if exists (select * FROM ALMACENDESP WHERE  FETR_CODIGO= @nCodigoFactura)
		DELETE FROM ALMACENDESP WHERE  FETR_CODIGO= @nCodigoFactura 

		UPDATE FACTEXPCONT
		SET FEC_DESCARGADO='N'
		where fe_codigo = @nCodigoFactura	

		Update FactExpdet
		set fed_descargado = 'N' 
		where fe_codigo = @nCodigoFactura	


		
		/* se actualiza estatus de factura */
	
		exec SP_ACTUALIZAESTATUSFACTEXP @nCodigoFactura 

	
	end


	
	UPDATE FACTEXP
	SET FE_FECHADESCARGA=NULL, FE_DESCMANUAL='N', FE_DESCARGADA='N'
	WHERE FE_CODIGO=@nCodigoFactura


	UPDATE CONFIGURACION
	SET CF_DESCARGANDO='N', US_DESCARGANDO=0


	exec  sp_droptable 'indiced'

RETURN 0


GO
