SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_DescargaCancelaFactExpSel] (@usuario int)   as

SET NOCOUNT ON
DECLARE @em_codigo INT, @FechaActual VARCHAR(10), @hora varchar(15)

	select @em_codigo=em_codigo from intradeglobal.dbo.empresa where em_corto in
	(select replace(convert(sysname,db_name()),'intrade',''))

SET @FechaActual = convert(varchar(10), getdate(),101)

exec sp_droptable 'CancelaRango'

CREATE TABLE [dbo].[CancelaRango] (
	[FE_CODIGO] [int] NULL) 

		/* la descarga manual no la cancela en la descarga por periodo */
		insert into CancelaRango (Fe_codigo)
			SELECT   KAP_FACTRANS
			FROM      KARDESPED LEFT OUTER JOIN
			FACTEXP ON FACTEXP.FE_CODIGO=KARDESPED.KAP_FACTRANS
			WHERE  (FE_SEL='S') and KAP_FACTRANS not in (select fe_codigo from factexp where fe_con_pedcr ='S')
			GROUP BY KAP_FACTRANS, FE_FECHADESCARGA


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

		SELECT KAP_INDICED_PED 
		INTO dbo.indiced
		FROM KARDESPED 
		WHERE KAP_FACTRANS in (select  fe_codigo from CancelaRango)  AND KAP_INDICED_PED IS NOT NULL 
		GROUP BY KAP_INDICED_PED


	select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

	insert into intradeglobal.dbo.avance (SYSUSLST_ID, AVA_MENSAJENO, AVA_INFO, AVA_INFOING, AVA_FECHA, AVA_HORA, em_codigo)
	values (@usuario,1, 'Borrando Info. de la tabla de descargas ', 'Delete Info. Discharge table ', @FechaActual, @hora, @em_codigo)


	DELETE FROM KARDESPED WHERE KAP_FACTRANS in (select  fe_codigo from CancelaRango) 


	TRUNCATE TABLE KARDESPEDTEMP	


	select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

	insert into intradeglobal.dbo.avance (SYSUSLST_ID, AVA_MENSAJENO, AVA_INFO, AVA_INFOING, AVA_FECHA, AVA_HORA, em_codigo)
	values (@usuario,1, 'Regresando saldos a Pedimentos ' , 'Return Pedimento Balances ', @FechaActual, @hora, @em_codigo)

		/* actualiza el campo pid_saldogen, pid_uso_saldo de los pedimentos de importacion que fueron afectados y se esta cancelando la descarga*/
			UPDATE dbo.PIDescarga
			SET     dbo.PIDescarga.PID_SALDOGEN= round(dbo.VPEDIMPSALDO.KAP_SALDOGEN,6)
			FROM         dbo.PIDescarga INNER JOIN
			                      dbo.VPEDIMPSALDO ON dbo.PIDescarga.PID_INDICED = dbo.VPEDIMPSALDO.PID_INDICED AND 
			                      dbo.PIDescarga.PID_SALDOGEN <> dbo.VPEDIMPSALDO.KAP_SALDOGEN
			WHERE dbo.PIDescarga.PID_INDICED IN (SELECT KAP_INDICED_PED FROM indiced)

			UPDATE PIDescarga
			SET     PIDescarga.PID_SALDOGEN=round(PIDescarga.PID_SALDOGEN-isnull((select sum(FACTEXPDET.FED_CANT * FACTEXPDET.EQ_GEN) from factexpdet
			where pid_indiced=PIDescarga.pid_indiced),0),6)
			WHERE dbo.PIDescarga.PID_INDICED IN (SELECT KAP_INDICED_PED FROM indiced)

		
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

	select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

	insert into intradeglobal.dbo.avance (SYSUSLST_ID, AVA_MENSAJENO, AVA_INFO, AVA_INFOING, AVA_FECHA, AVA_HORA, em_codigo)
	values (@usuario,1, 'Actualizando Estatus de facturas ' , 'Update Invoices Status', @FechaActual, @hora, @em_codigo)

	
	/* se actualiza estatus de factura */
	exec SP_ACTUALIZAESTATUSFACTEXPALL

	select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

	insert into intradeglobal.dbo.avance (SYSUSLST_ID, AVA_MENSAJENO, AVA_INFO, AVA_INFOING, AVA_FECHA, AVA_HORA, em_codigo)
	values (@usuario,1, 'Actualizando Estatus de Pedimentos ' , 'Update Pedimentos Status', @FechaActual, @hora, @em_codigo)


	-- actualiza el estatus del pedimento 
	EXEC SP_ACTUALIZAESTATUSPEDIMPALL

	UPDATE CONFIGURACION
	SET CF_DESCARGANDO='N', US_DESCARGANDO=0

exec sp_droptable 'CancelaRango'

exec  sp_droptable 'indiced'









GO
