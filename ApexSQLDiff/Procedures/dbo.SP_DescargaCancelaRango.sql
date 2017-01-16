SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_DescargaCancelaRango] (@fecodigo int, @fecodigofin int, @cancelamanual char(1), @CancelaH1 char(1))    as

SET NOCOUNT ON 
declare @nCodigoFactura int, @kapcodigoini int, @kapcodigofin int, @fe_fecha datetime
DECLARE @PICODIGO Integer, @PIDINDICED Integer, @Factconv decimal(28,14), @CantDesc decimal(38,6), @KAPCODIGO int,
	@PIDSALDOGEN decimal(38,6), @PIDCANGEN decimal(38,6), @ValorDescProc decimal(38,6), @SumSaldoGen decimal(38,6), @SumCanGen decimal(38,6), @cpcodigo int, @fedindiced int,
	@fe_con_pedcr char (1)


SELECT @kapcodigoini= MIN(KAP_CODIGO) 
FROM KARDESPED 
WHERE KAP_FACTRANS=@fecodigo

if @fecodigofin=0 
	SELECT @kapcodigofin = max(kap_codigo)
	FROM KARDESPED
else
	SELECT @kapcodigofin= max(KAP_CODIGO) 
	FROM KARDESPED 
	WHERE KAP_FACTRANS=@fecodigofin


exec sp_droptable 'CancelaRango'

CREATE TABLE [dbo].[CancelaRango] (
	[FE_CODIGO] [int] NULL) 



	if @CancelaH1='S' 
	begin
		if @cancelamanual='S'
		begin
			/* la descarga manual no la cancela en la descarga por periodo */
			insert into CancelaRango (Fe_codigo)
			SELECT   KAP_FACTRANS
				FROM        KARDESPED LEFT OUTER JOIN
				FACTEXP ON FACTEXP.FE_CODIGO=KARDESPED.KAP_FACTRANS
				WHERE (KAP_CODIGO >= @kapcodigoini) AND (KAP_CODIGO <= @kapcodigofin)
				and KAP_FACTRANS not in (select fe_codigo from factexp where fe_con_pedcr ='S')
				GROUP BY KAP_FACTRANS, FE_FECHADESCARGA
				ORDER BY FE_FECHADESCARGA DESC, MAX(KAP_CODIGO) DESC
		end
		else
		begin
			/* la descarga manual no la cancela en la descarga por periodo */
			insert into CancelaRango (Fe_codigo)
				SELECT   KAP_FACTRANS
				FROM        KARDESPED  LEFT OUTER JOIN
				FACTEXP ON FACTEXP.FE_CODIGO=KARDESPED.KAP_FACTRANS
				WHERE (KAP_CODIGO >= @kapcodigoini) AND (KAP_CODIGO <= @kapcodigofin)
				and FE_DESCMANUAL='N'
				and KAP_FACTRANS not in (select fe_codigo from factexp where fe_con_pedcr ='S')
				GROUP BY KAP_FACTRANS, FE_FECHADESCARGA
				ORDER BY FE_FECHADESCARGA DESC, MAX(KAP_CODIGO) DESC
	
		end
	end
	else
	begin
		if @cancelamanual='S'
		begin
			/* la descarga manual no la cancela en la descarga por periodo */
			insert into CancelaRango (Fe_codigo)
			SELECT   KAP_FACTRANS
				FROM        KARDESPED LEFT OUTER JOIN
				FACTEXP ON FACTEXP.FE_CODIGO=KARDESPED.KAP_FACTRANS
				WHERE (KAP_CODIGO >= @kapcodigoini) AND (KAP_CODIGO <= @kapcodigofin)
				and KAP_FACTRANS not in (select fe_codigo from factexp where fe_con_pedcr ='S')
				and FACTEXP.tq_codigo not in (select tq_codigo from configuratembarque where cfq_tipo ='T')
				GROUP BY KAP_FACTRANS, FE_FECHADESCARGA
				ORDER BY FE_FECHADESCARGA DESC, MAX(KAP_CODIGO) DESC
		end
		else
		begin
			/* la descarga manual no la cancela en la descarga por periodo */
			insert into CancelaRango (Fe_codigo)
				SELECT   KAP_FACTRANS
				FROM        KARDESPED  LEFT OUTER JOIN
				FACTEXP ON FACTEXP.FE_CODIGO=KARDESPED.KAP_FACTRANS
				WHERE (KAP_CODIGO >= @kapcodigoini) AND (KAP_CODIGO <= @kapcodigofin)
				and FE_DESCMANUAL='N'
				and KAP_FACTRANS not in (select fe_codigo from factexp where fe_con_pedcr ='S')
				and FACTEXP.tq_codigo not in (select tq_codigo from configuratembarque where cfq_tipo ='T')
				GROUP BY KAP_FACTRANS, FE_FECHADESCARGA
				ORDER BY FE_FECHADESCARGA DESC, MAX(KAP_CODIGO) DESC
	
		end
	end	

			/*================= kardespedcont =========================*/
	
			if exists(select * from kardespedcont where fed_indiced IN
					(SELECT KAP_INDICED_FACT
					FROM KARDESPED WHERE KAP_FACTRANS in (select  fe_codigo from CancelaRango) 
					GROUP BY KAP_INDICED_FACT))
			begin
				UPDATE PEDIMPCONT
				SET PEDIMPCONT.PIC_USO_DESCARGA='N'
				FROM         dbo.KARDESPEDCONT INNER JOIN
		             		         dbo.PEDIMPCONT ON dbo.KARDESPEDCONT.PIC_INDICEC = dbo.PEDIMPCONT.PIC_INDICEC
				WHERE     dbo.KARDESPEDCONT.FED_INDICED IN (SELECT KAP_INDICED_FACT
						FROM KARDESPED WHERE KAP_FACTRANS in (select  fe_codigo from CancelaRango) 
						GROUP BY KAP_INDICED_FACT)
	
				DELETE FROM KARDESPEDCONT WHERE FED_INDICED in (SELECT KAP_INDICED_FACT
						FROM KARDESPED WHERE KAP_FACTRANS in (select  fe_codigo from CancelaRango) 
						GROUP BY KAP_INDICED_FACT)
	

			end

		exec  sp_droptable 'indiced'

		SELECT KAP_INDICED_PED, SUM(KAP_CANTDESC) as KAP_CANTDESC
		INTO dbo.indiced
		FROM KARDESPED 
		WHERE KAP_FACTRANS in (select  fe_codigo from CancelaRango)  AND KAP_INDICED_PED IS NOT NULL  and KAP_INDICED_PED<>-1
		GROUP BY KAP_INDICED_PED



		DELETE FROM KARDESPED WHERE KAP_FACTRANS in (select  fe_codigo from CancelaRango) 
	

		TRUNCATE TABLE KARDESPEDTEMP	


		UPDATE PIDescarga
		SET    PIDescarga.PID_SALDOGEN= round(PIDescarga.PID_SALDOGEN+indiced.KAP_CANTDESC,6)
		FROM   PIDescarga inner join indiced on PIDescarga.PID_INDICED=indiced.KAP_INDICED_PED


		/* actualiza el campo pid_saldogen, pid_uso_saldo de los pedimentos de importacion que fueron afectados y se esta cancelando la descarga*/
			/*UPDATE dbo.PIDescarga
			SET     dbo.PIDescarga.PID_SALDOGEN= dbo.VPEDIMPSALDO.KAP_SALDOGEN
			FROM         dbo.PIDescarga INNER JOIN
			                      dbo.VPEDIMPSALDO ON dbo.PIDescarga.PID_INDICED = dbo.VPEDIMPSALDO.PID_INDICED AND 
			                      dbo.PIDescarga.PID_SALDOGEN <> dbo.VPEDIMPSALDO.KAP_SALDOGEN
			WHERE dbo.PIDescarga.PID_INDICED IN (SELECT KAP_INDICED_PED FROM indiced
							GROUP BY KAP_INDICED_PED)

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
				FROM         dbo.KARDESPED INNER JOIN
				                      dbo.PEDIMPDET ON dbo.KARDESPED.KAP_INDICED_PED = dbo.PEDIMPDET.PID_INDICED
				WHERE     dbo.KARDESPED.KAP_FACTRANS in (select  fe_codigo from CancelaRango) 
				GROUP BY dbo.PEDIMPDET.PI_CODIGO)



			if not exists(select pi_codigo from pedimpdet where pi_codigo in (select KAP_INDICED_PED from kardesped
			where KAP_FACTRANS not in (select  fe_codigo from CancelaRango)))
			update pedimp
			set pi_updaterect='S'
			where pi_codigo IN (SELECT     dbo.PEDIMPDET.PI_CODIGO
					FROM         indiced INNER JOIN
					                      dbo.PEDIMPDET ON indiced.KAP_INDICED_PED = dbo.PEDIMPDET.PID_INDICED
					GROUP BY dbo.PEDIMPDET.PI_CODIGO)
			and pi_updaterect<>'S'




	if exists (select * FROM ALMACENDESP WHERE  FETR_CODIGO in (select  fe_codigo from CancelaRango) )
	DELETE FROM ALMACENDESP WHERE  FETR_CODIGO in (select  fe_codigo from CancelaRango) 

		UPDATE FACTEXPCONT
		SET FEC_DESCARGADO='N'
		where fe_codigo in (select  fe_codigo from CancelaRango) 

		Update FactExpdet
		set fed_descargado = 'N' 
		where fe_codigo in (select  fe_codigo from CancelaRango) 



	UPDATE FACTEXP
	SET FE_FECHADESCARGA=NULL, FE_DESCMANUAL='N', FE_DESCARGADA='N'
	WHERE FE_CODIGO in (select  fe_codigo from CancelaRango) 
	
	/* se actualiza estatus de factura */
	exec SP_ACTUALIZAESTATUSFACTEXPALL



	-- actualiza el estatus del pedimento 
	EXEC SP_ACTUALIZAESTATUSPEDIMPALL	

	UPDATE CONFIGURACION
	SET CF_DESCARGANDO='N', US_DESCARGANDO=0

exec sp_droptable 'CancelaRango'

exec  sp_droptable 'indiced'

GO
