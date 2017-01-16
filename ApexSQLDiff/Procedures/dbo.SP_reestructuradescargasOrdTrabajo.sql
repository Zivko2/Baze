SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[SP_reestructuradescargasOrdTrabajo]    as

SET NOCOUNT ON 
declare @kap_indiced_ped int, @pid_saldogenr decimal(38,6), @pid_can_genr decimal(38,6), @Sumkap_CantDesc decimal(38,6), @PROD_INDICED int, @cantpendiente decimal(38,6)

	/* actualiza el saldo del ordtrabajo que se encuentran en PRODUCLIGA */

  	declare cur_actualizasaldo cursor for
		SELECT     dbo.ORDTRABAJODET.OTD_INDICED, isnull(dbo.ORDTRABAJODET.OTD_SALDO,0), isnull(round(dbo.ORDTRABAJODET.OTD_SIZELOTE,0),0), 
		                      isnull(round(SUM(dbo.PRODUCLIGA.LIP_CANTDESC),0),0)
		FROM         dbo.ORDTRABAJODET INNER JOIN
		                      dbo.PRODUCLIGA ON dbo.ORDTRABAJODET.OTD_INDICED = dbo.PRODUCLIGA.OTD_INDICED
		GROUP BY dbo.ORDTRABAJODET.OTD_INDICED, dbo.ORDTRABAJODET.OTD_SALDO, dbo.ORDTRABAJODET.OTD_SIZELOTE
	open cur_actualizasaldo

		fetch next from cur_actualizasaldo into @kap_indiced_ped, @pid_saldogenr, @pid_can_genr, @Sumkap_CantDesc 
			WHILE (@@FETCH_STATUS = 0) 
		BEGIN
	

			if @Sumkap_CantDesc<>0 and (@pid_saldogenr <> (@pid_can_genr-@Sumkap_CantDesc))
			update ordtrabajodet
			set otd_saldo = isnull((@pid_can_genr-@Sumkap_CantDesc),0)
			Where otd_indiced =  @kap_indiced_ped

			fetch next from cur_actualizasaldo into @kap_indiced_ped, @pid_saldogenr, @pid_can_genr, @Sumkap_CantDesc 
		END
		CLOSE cur_actualizasaldo
		DEALLOCATE cur_actualizasaldo



	/* actualiza el saldo de las ordenes de trabajo que no se encuentran en PRODUCLIGA y que el saldo es <> sizelote*/
		UPDATE dbo.ORDTRABAJODET
		SET     dbo.ORDTRABAJODET.OTD_SALDO= dbo.ORDTRABAJODET.OTD_SIZELOTE
		FROM         dbo.ORDTRABAJODET LEFT OUTER JOIN
		                      dbo.PRODUCLIGA ON dbo.ORDTRABAJODET.OTD_INDICED = dbo.PRODUCLIGA.OTD_INDICED
		WHERE     (dbo.PRODUCLIGA.OTD_INDICED IS NULL) 
			AND (dbo.ORDTRABAJODET.OTD_SALDO <> dbo.ORDTRABAJODET.OTD_SIZELOTE)




	/* actualiza la cantidad excedente de produccion que se encuentra en PRODUCLIGA */
	declare cur_actualizaPRODUC cursor for
		SELECT PROD_INDICED FROM PRODUCLIGA
		GROUP BY PROD_INDICED
	open cur_actualizaPRODUC

		fetch next from cur_actualizaPRODUC into @PROD_INDICED
			WHILE (@@FETCH_STATUS = 0) 
		BEGIN

			SELECT     @cantpendiente= SUM(dbo.PRODUCDET.PROD_CANT - dbo.PRODUCLIGA.LIP_CANTDESC) 
			FROM         dbo.PRODUCLIGA INNER JOIN
			                      dbo.PRODUCDET ON dbo.PRODUCLIGA.PROD_INDICED = dbo.PRODUCDET.PROD_INDICED
			WHERE     (dbo.PRODUCLIGA.PROD_INDICED = @PROD_INDICED)

				update producdet
				set prod_cantpend=@cantpendiente
				where prod_indiced=@PROD_INDICED
				and prod_cantpend<>@cantpendiente

			fetch next from cur_actualizaPRODUC into @PROD_INDICED
		END
		CLOSE cur_actualizaPRODUC
		DEALLOCATE cur_actualizaPRODUC


	/* actualiza la cantidad excedente de produccion que no se encuentra en PRODUCLIGA */
	declare cur_actualizaPRODUCSALDO cursor for
		SELECT PROD_INDICED FROM PRODUCDET WHERE PROD_INDICED NOT IN
		(SELECT PROD_INDICED FROM PRODUCLIGA GROUP BY PROD_INDICED)
	open cur_actualizaPRODUCSALDO

		fetch next from cur_actualizaPRODUCSALDO into @PROD_INDICED
			WHILE (@@FETCH_STATUS = 0) 
		BEGIN

				update producdet
				set prod_cantpend=prod_cant
				where prod_indiced=@PROD_INDICED
				and prod_cantpend<>prod_cant

			fetch next from cur_actualizaPRODUCSALDO into @PROD_INDICED
		END
		CLOSE cur_actualizaPRODUCSALDO
		DEALLOCATE cur_actualizaPRODUCSALDO


	/* actualiza estatus del produccion que no se encuentran en PRODUCLIGA */
	UPDATE PRODUC
	SET     PRODUC.PRO_ESTATUS='C'
	FROM  PRODUC 
	wHERE      PRO_CODIGO IN (SELECT PRO_CODIGO FROM PRODUCDET WHERE 
		dbo.PRODUCDET.PROD_INDICED IN (SELECT PROD_INDICED FROM PRODUCLIGA))



	/* actualiza el estatus de las ordenes de trabajo */
	EXEC SP_ACTUALIZAESTATUSORDTRABAJOALL



























GO
