SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_ACTUALIZASALDOFE] (@FE_CODIGO INT)   as

declare  @pid_saldogen decimal(38,6), @pid_can_gen decimal(38,6), @kap_indiced_ped int, @pid_saldogenr decimal(38,6), 
@pid_can_genr decimal(38,6), @Sumkap_CantDesc decimal(38,6), @KAP_TIPO_DESC char(1)


	 if (select CFQ_TIPO from configuratembarque where tq_codigo in (select tq_codigo from factexp where fe_codigo=@FE_CODIGO)) ='D'
	  set @KAP_TIPO_DESC = 'D'
	else
	 set @KAP_TIPO_DESC = 'N'

	update kardesped
	set kap_tipo_desc=@KAP_TIPO_DESC
	where kap_factrans=@FE_CODIGO
	and KAP_TIPO_DESC is null



	declare cur_actualizasaldo cursor for
		SELECT KARDESPED.KAP_INDICED_PED
		FROM         KARDESPED 
		WHERE KAP_FACTRANS=@FE_CODIGO
		GROUP BY KARDESPED.KAP_INDICED_PED
	open cur_actualizasaldo

		fetch next from cur_actualizasaldo into @kap_indiced_ped
			WHILE (@@FETCH_STATUS = 0) 
		BEGIN


		SELECT @pid_saldogenr=isnull(round(PIDESCARGA.PID_SALDOGEN,6),0), 
			@pid_can_genr=isnull(round(PEDIMPDET.PID_CAN_GEN,6),0), 
			@Sumkap_CantDesc =isnull(round(SUM(KARDESPED.KAP_CANTDESC),6),0)
		FROM         KARDESPED INNER JOIN
	                PEDIMPDET ON KARDESPED.KAP_INDICED_PED = PEDIMPDET.PID_INDICED
			LEFT OUTER JOIN PIDESCARGA ON PEDIMPDET.PID_INDICED=PIDESCARGA.PID_INDICED
		WHERE PEDIMPDET.PID_DESCARGABLE='S' AND  KARDESPED.KAP_INDICED_PED=@kap_indiced_ped
		GROUP BY PIDESCARGA.PID_SALDOGEN, PEDIMPDET.PID_CAN_GEN, KARDESPED.KAP_INDICED_PED
		HAVING isnull(round(PIDESCARGA.PID_SALDOGEN,6),0) <> (isnull(round(PEDIMPDET.PID_CAN_GEN,6),0)- isnull(round(SUM(KARDESPED.KAP_CANTDESC),6),0))


	
				update pidescarga
				set pid_saldogen = round(isnull((@pid_can_genr-@Sumkap_CantDesc),0),6)
				Where pid_indiced =  @kap_indiced_ped
				and  isnull((@pid_can_genr-@Sumkap_CantDesc),0) >0

				update pidescarga
				set pid_saldogen = 0
				Where pid_indiced =  @kap_indiced_ped
				and isnull((@pid_can_genr-@Sumkap_CantDesc),0) <=0


			fetch next from cur_actualizasaldo into @kap_indiced_ped
		END
		CLOSE cur_actualizasaldo
		DEALLOCATE cur_actualizasaldo


		EXEC SP_ACTUALIZAESTATUSPEDIMPALL

GO
