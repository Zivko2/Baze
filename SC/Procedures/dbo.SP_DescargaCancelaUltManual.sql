SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

























/* cancela el ultimo fed_indiced descargado*/
CREATE PROCEDURE dbo.SP_DescargaCancelaUltManual (@fecodigo int)   as

SET NOCOUNT ON 

	DECLARE @FEDINDICED Integer, @PIDINDICED Integer, @CantDesc decimal(38,6), @PICODIGO Int, @countdescargado int,  @fccodigo int,
	@cpcodigo int, @SumSaldoGen decimal(38,6), @SumCanGen decimal(38,6)

	SELECT     @PICODIGO =dbo.PEDIMPDET.PI_CODIGO, @FEDINDICED = dbo.KARDESPED.KAP_INDICED_FACT
	FROM         dbo.KARDESPED LEFT OUTER JOIN
	                      dbo.PEDIMPDET ON dbo.KARDESPED.KAP_INDICED_PED = dbo.PEDIMPDET.PID_INDICED
	WHERE     (dbo.KARDESPED.KAP_CODIGO IN
	                          (SELECT     MAX(KAP_CODIGO)
	                            FROM          KARDESPED
	                            WHERE      KARDESPED.KAP_FACTRANS = @fecodigo))

	
	select @cpcodigo = cp_codigo from pedimp where pi_codigo = @PICODIGO

	SELECT     @countdescargado = COUNT(FED_DESCARGADO) 
	FROM         dbo.FACTEXPDET
	GROUP BY FE_CODIGO, FED_DESCARGADO
	HAVING      (FE_CODIGO = @FECODIGO) AND (FED_DESCARGADO = 'S')


	select @fccodigo = fc_codigo from factexp where fe_codigo = @fecodigo

		Update FactExpdet
		set fed_descargado = 'N' 
		where fed_indiced = @FEDINDICED


	if @countdescargado = 0

	UPDATE FACTEXP SET FE_DESCARGADA = 'N' WHERE FE_CODIGO = @fecodigo

	if @fccodigo = 0 
		update factexp set fe_estatus = 'D' where fe_codigo = @feCodigo

	if @fccodigo <> 0 and @fccodigo  is not null
		update factexp set fe_estatus = 'P' where fe_codigo = @feCodigo


	/*actualiza los pedimentos de importacion afectados */
			declare curPidIndiced cursor for
				SELECT KARDESPED.KAP_INDICED_PED, KARDESPED.KAP_CANTDESC
				FROM KARDESPED, FACTEXPDET
				WHERE KARDESPED.KAP_INDICED_FACT = @FEDINDICED
				AND KARDESPED.KAP_INDICED_FACT = FACTEXPDET.FED_INDICED
				AND FACTEXPDET.PID_INDICED=-1

			open curPidIndiced
			fetch next from curPidIndiced into @pidindiced, @CantDesc
				WHILE (@@FETCH_STATUS = 0) 
				BEGIN
					if (@pidindiced is not null and @pidindiced>0) and @CantDesc>0
					begin
						update pidescarga
						set pid_saldogen = isnull(pid_saldogen,0) + @CantDesc
						where pid_indiced =@PIDINDICED

						/*update pedimpdet 
						set pid_saldogen = isnull(pid_saldogen,0) + @CantDesc
						where pid_indiced =@PIDINDICED	*/
	
						/*contenido del pedimento que no se encuentra en kardespedcont y pertenece al detalle del pedimento afectado */
						update dbo.pedimpcont
						SET     dbo.PEDIMPCONT.PIC_USO_DESCARGA='N'
						FROM         dbo.PEDIMPCONT INNER JOIN
						                      dbo.KARDESPEDCONT ON dbo.PEDIMPCONT.PIC_INDICEC = dbo.KARDESPEDCONT.PIC_INDICEC
						WHERE     (dbo.KARDESPEDCONT.PIC_INDICEC IS NULL) AND (dbo.PEDIMPCONT.PID_INDICED = @PIDINDICED)
					end


					if not exists(select pi_codigo from pedimpdet where pi_codigo in (select KAP_INDICED_PED from kardesped
					where KAP_FACTRANS <> @fecodigo))
					update pedimp
					set pi_updaterect='S'
					where pi_codigo in (select pi_codigo from pedimpdet where pid_indiced=@pidindiced)
					and pi_updaterect<>'S'

				fetch next from curPidIndiced into @pidindiced, @CantDesc
				END
			CLOSE curPidIndiced
			DEALLOCATE curPidIndiced
	
	

	/* se actualiza el campo PI_AFECTADO */	
	if @PICODIGO is not null and @PICODIGO>0
	begin
		SELECT @SumSaldoGen = SUM(pidescarga.PID_SALDOGEN), @SumCanGen = SUM(pedimpdet.PID_CAN_GEN)
		FROM PEDIMPDET left outer join pidescarga 
		on pedimpdet.pid_indiced=pidescarga.pid_indiced
		WHERE (PEDIMPDET.PI_CODIGO = @PICODIGO)

		IF (@SumSaldoGen = @SumCanGen)
		UPDATE PEDIMP SET PI_AFECTADO = 'N'  /*el estatus se modifica la cambiarlo en la tabla por el trigger */
		WHERE (PI_CODIGO = @PICODIGO)


	end


		if exists(select * from kardespedcont where fed_indiced = @FEDINDICED)
		BEGIN

			UPDATE PEDIMPCONT
			SET PEDIMPCONT.PIC_USO_DESCARGA='N'
			FROM         dbo.KARDESPEDCONT INNER JOIN
		                      dbo.PEDIMPCONT ON dbo.KARDESPEDCONT.PIC_INDICEC = dbo.PEDIMPCONT.PIC_INDICEC
			WHERE     (dbo.KARDESPEDCONT.FED_INDICED = @FEDINDICED)
	
	
			DELETE FROM KARDESPEDCONT WHERE FED_INDICED = @FEDINDICED
		END



		UPDATE FACTEXPCONT
		SET FEC_DESCARGADO='N'
		WHERE FED_INDICED = @FEDINDICED


		DELETE FROM KARDESPED WHERE KAP_INDICED_FACT = @FEDINDICED

		if not exists(select * from kardesped where kap_factrans=@FECODIGO)
		update factexp
		set fe_descargada='N'
		where fe_codigo=@FECODIGO

		/* se actualiza estatus de factura */
		exec SP_ACTUALIZAESTATUSFACTEXP @FECODIGO

		update configuracion
		set cf_descargando='N', US_DESCARGANDO=0

RETURN 0



























GO
