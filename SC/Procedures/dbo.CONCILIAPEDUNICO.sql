SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[CONCILIAPEDUNICO] (@verifica char(1)='N', @actualiza char(1)='N', @lenguaje int = 1)   as

declare @picodigo int, @maximo int, @fraccion varchar(20), @pi_codigo int, @PIB_INDICEB INT

	DECLARE @mensaje varchar(5000)

EXEC SP_DROPTABLE 'IMPCONCILIALOG'
CREATE TABLE [dbo].[IMPCONCILIALOG] (
	[IML_CODIGO] [int] IDENTITY (1, 1) NOT NULL ,
	[IML_MENSAJE] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	CONSTRAINT [IX_IMPCONCILIALOG] UNIQUE  NONCLUSTERED 
	(
		[IML_CODIGO]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
) ON [PRIMARY]

	-- elimina los espacios
--	UPDATE pedimpconcilia
--	SET     Pedimento=REPLACE(Pedimento, ' ', '')

	UPDATE pedimpconcilia
	SET pedimpconcilia.PI_CODIGO=PEDIMP.PI_CODIGO
	FROM  PEDIMP INNER JOIN AGENCIAPATENTE ON PEDIMP.AGT_CODIGO=AGENCIAPATENTE.AGT_CODIGO
        left outer join aduana on pedimp.ad_des = aduana.ad_codigo
	INNER JOIN pedimpconcilia ON right(RTRIM(pedimpconcilia.Pedimento collate database_default),11) = AGENCIAPATENTE.AGT_PATENTE collate database_default +PEDIMP.PI_FOLIO collate database_default
	AND replace(replace(pedimpconcilia.OperationType collate database_default,1, 'E'),2, 'S') = PEDIMP.PI_MOVIMIENTO collate database_default
	AND pedimpconcilia.CustomSection = aduana.ad_clave + aduana.ad_seccion

	select @picodigo= pi_codigo from pedimpconcilia

	UPDATE pedimpconciliaIdentifica
	SET pedimpconciliaIdentifica.pi_codigo = pedimpconcilia.PI_CODIGO
	FROM pedimpconciliaIdentifica inner join pedimpconcilia 
	     on pedimpconciliaIdentifica.pedimento=pedimpconcilia.pedimento

	UPDATE pedimpconciliaDet
	SET pedimpconciliaDet.pi_codigo = pedimpconcilia.PI_CODIGO
	FROM pedimpconciliaDet inner join pedimpconcilia 
	     on pedimpconciliaDet.pedimento=pedimpconcilia.pedimento

	UPDATE pedimpconciliaDetIdentifica
	SET pedimpconciliaDetIdentifica.pi_codigo = pedimpconcilia.PI_CODIGO
	FROM pedimpconciliaDetIdentifica inner join pedimpconcilia 
	     on pedimpconciliaDetIdentifica.pedimento=pedimpconcilia.pedimento

	UPDATE pedimpconciliaInvoice
	SET pedimpconciliaInvoice.pi_codigo = pedimpconcilia.PI_CODIGO
	FROM pedimpconciliaInvoice inner join pedimpconcilia 
	     on pedimpconciliaInvoice.pedimento=pedimpconcilia.pedimento

	UPDATE pedimpconciliaContribucion
	SET pedimpconciliaContribucion.pi_codigo = pedimpconcilia.PI_CODIGO
	FROM pedimpconciliaContribucion inner join pedimpconcilia 
	     on pedimpconciliaContribucion.pedimento=pedimpconcilia.pedimento

	UPDATE pedimpconciliaDetContribucion
	SET pedimpconciliaDetContribucion.pi_codigo = pedimpconcilia.PI_CODIGO
	FROM pedimpconciliaDetContribucion inner join pedimpconcilia 
	     on pedimpconciliaDetContribucion.pedimento=pedimpconcilia.pedimento


	UPDATE PedImpConciliaContainer
	SET PedImpConciliaContainer.pi_codigo = pedimpconcilia.PI_CODIGO
	FROM PedImpConciliaContainer inner join pedimpconcilia 
	     on PedImpConciliaContainer.pedimento=pedimpconcilia.pedimento



	exec Sp_ligaDetalles
-- ===================================== Tabla PedImp ==============================================
		if exists (select PI_CODIGO from pedimpconcilia where PI_CODIGO is null) 
		begin
			if @lenguaje <> 2 
 				set @mensaje = 'No existe en el sistema'
			else
				set @mensaje = 'Does not exists'

			insert into IMPCONCILIALOG(iml_mensaje)
			SELECT 'Ped.: '+left(right(pedimpconcilia.Pedimento collate database_default,11),4)+'-'+right(pedimpconcilia.Pedimento collate database_default ,7)+@mensaje
			FROM         pedimpconcilia 
			WHERE     PI_CODIGO is null
			

		end
	
			if @lenguaje <> 2 
 				set @mensaje = ', Fecha de Entrada diferente'
			else
				set @mensaje = ', Entry Date is different'

			insert into IMPCONCILIALOG(iml_mensaje)
			SELECT 'Ped.: '+left(right(pedimpconcilia.Pedimento collate database_default,11),4)+'-'+right(pedimpconcilia.Pedimento collate database_default,7)+@mensaje+' (Sistema ='+convert(varchar(11),PEDIMP.PI_FEC_ENTPED,101)+' Archivo ='+convert(varchar(11),pedimpconcilia.EntryDate,101)+')'
			FROM         pedimpconcilia INNER JOIN
			                      PEDIMP ON pedimpconcilia.PI_CODIGO = PEDIMP.PI_CODIGO
			WHERE     PEDIMP.PI_FEC_ENTPED<> pedimpconcilia.EntryDate
		

	
	
	-- Fecha de pago
			if @lenguaje <> 2 
 				set @mensaje = ', Fecha de Pago diferente'
			else
				set @mensaje = ', Payment Date is different'
			insert into IMPCONCILIALOG(iml_mensaje)
			SELECT 'Ped.: '+left(right(pedimpconcilia.Pedimento collate database_default,11),4)+'-'+right(pedimpconcilia.Pedimento collate database_default,7)+@mensaje+' (Sistema ='+convert(varchar(11),PEDIMP.PI_FEC_PAG,101)+' Archivo ='+convert(varchar(11),pedimpconcilia.PaymentDate,101)+')'
			FROM         pedimpconcilia INNER JOIN
			                      PEDIMP ON pedimpconcilia.PI_CODIGO = PEDIMP.PI_CODIGO
			WHERE PEDIMP.PI_FEC_PAG<> pedimpconcilia.PaymentDate
		


	-- Clave Pedimento
			if @lenguaje <> 2 
 				set @mensaje = ', Clave Pedimento diferente'
			else
				set @mensaje = ', Pedimento Code is different'
			insert into IMPCONCILIALOG(iml_mensaje)
			SELECT 'Ped.: '+left(right(pedimpconcilia.Pedimento collate database_default,11),4)+'-'+right(pedimpconcilia.Pedimento collate database_default,7)+@mensaje+' (Sistema ='+dbo.CLAVEPED.CP_CLAVE collate database_default+' Archivo ='+dbo.pedimpconcilia.PedimentoCode collate database_default+')'
			FROM         dbo.pedimpconcilia INNER JOIN
			                      dbo.PEDIMP ON dbo.pedimpconcilia.PI_CODIGO = dbo.PEDIMP.PI_CODIGO INNER JOIN
			                      dbo.CLAVEPED ON dbo.PEDIMP.CP_CODIGO = dbo.CLAVEPED.CP_CODIGO
			WHERE dbo.pedimpconcilia.PedimentoCode <> dbo.CLAVEPED.CP_CLAVE

	-- medio transporte
			if @lenguaje <> 2 
 				set @mensaje = ', Medio Trans. Pedimento diferente'
			else
				set @mensaje = ', Transport Mode is different'
			insert into IMPCONCILIALOG(iml_mensaje)
			SELECT 'Ped.: '+left(right(pedimpconcilia.Pedimento collate database_default,11),4)+'-'+right(pedimpconcilia.Pedimento collate database_default,7)+@mensaje+' (Sistema ='+dbo.MEDIOTRAN.MT_CLA_PED collate database_default+' Archivo ='+dbo.pedimpconcilia.TransMode collate database_default+')'
			FROM         dbo.pedimpconcilia INNER JOIN
			                      dbo.PEDIMP ON dbo.pedimpconcilia.PI_CODIGO = dbo.PEDIMP.PI_CODIGO INNER JOIN
			                      dbo.MEDIOTRAN ON dbo.PEDIMP.MT_CODIGO = dbo.MEDIOTRAN.MT_CODIGO
			WHERE dbo.pedimpconcilia.TransMode <> dbo.MEDIOTRAN.MT_CLA_PED


	
	-- Tipo de Cambio
			if @lenguaje <> 2 
 				set @mensaje = ', Tipo de Cambio diferente'
			else
				set @mensaje = ', Exchange Rate is different'
			insert into IMPCONCILIALOG(iml_mensaje)
			SELECT 'Ped.: '+left(right(pedimpconcilia.Pedimento collate database_default,11),4)+'-'+right(pedimpconcilia.Pedimento collate database_default,7)+@mensaje+' (Sistema ='+convert(varchar(50),PEDIMP.PI_TIP_CAM)+' Archivo ='+convert(varchar(50),pedimpconcilia.ConversionRate)+')'
			FROM         pedimpconcilia INNER JOIN
			                      PEDIMP ON pedimpconcilia.PI_CODIGO = PEDIMP.PI_CODIGO
			WHERE PEDIMP.PI_TIP_CAM<> pedimpconcilia.ConversionRate
		


	-- Peso Bruto
			if @lenguaje <> 2 
 				set @mensaje = ', Peso Bruto diferente'
			else
				set @mensaje = ', Gross Weight is different'
			insert into IMPCONCILIALOG(iml_mensaje)
			SELECT 'Ped.: '+left(right(pedimpconcilia.Pedimento collate database_default,11),4)+'-'+right(pedimpconcilia.Pedimento collate database_default,7)+@mensaje+' (Sistema ='+convert(varchar(50),PEDIMP.PI_PESO)+' Archivo ='+convert(varchar(50),pedimpconcilia.GrossWeight)+')'
			FROM         pedimpconcilia INNER JOIN
			                      PEDIMP ON pedimpconcilia.PI_CODIGO = PEDIMP.PI_CODIGO
			WHERE PEDIMP.PI_PESO<> pedimpconcilia.GrossWeight
	

	-- Importador/Exportador
			if @lenguaje <> 2 
 				set @mensaje = ', Importador/Exportador diferente'
			else
				set @mensaje = ', Importer/Exporter is different'
			insert into IMPCONCILIALOG(iml_mensaje)
			SELECT 'Ped.: '+left(right(pedimpconcilia.Pedimento collate database_default,11),4)+'-'+right(pedimpconcilia.Pedimento collate database_default,7)+@mensaje+' (Sistema ='+replace(ISNULL(dbo.CLIENTE.CL_RFC collate database_default, dbo.CLIENTE.CL_IRS collate database_default),' ','')+' Archivo ='+dbo.pedimpconcilia.RFCImporter collate database_default+')'
			FROM         dbo.pedimpconcilia INNER JOIN
			                      dbo.PEDIMP ON dbo.pedimpconcilia.PI_CODIGO = dbo.PEDIMP.PI_CODIGO INNER JOIN
			                      dbo.CLIENTE ON dbo.PEDIMP.CL_CODIGO = dbo.CLIENTE.CL_CODIGO
			where replace(ISNULL(dbo.CLIENTE.CL_RFC, dbo.CLIENTE.CL_IRS),' ','')<> dbo.pedimpconcilia.RFCImporter


		-- fletes
			-- los que no existen
			if @lenguaje <> 2 
 				set @mensaje = ', Fletes Diferentes'
			else
				set @mensaje = ', Freight differs'
			insert into IMPCONCILIALOG(iml_mensaje)
			SELECT 'Ped.: '+left(right(pedimpconcilia.Pedimento collate database_default,11),4)+'-'+right(pedimpconcilia.Pedimento collate database_default,7)+@mensaje+' (Sistema = 0  Archivo ='+convert(varchar(50),pedimpconcilia.FreightCost)+')'
			FROM         pedimpconcilia 
			WHERE    pedimpconcilia.FreightCost > 0 AND pedimpconcilia.PI_CODIGO NOT IN 
				(SELECT     dbo.PEDIMP.PI_CODIGO
				FROM         dbo.PEDIMP INNER JOIN
				                      dbo.PEDIMPINCREMENTA ON dbo.PEDIMPINCREMENTA.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
				WHERE     PEDIMP.PI_CODIGO = pedimpconcilia.PI_CODIGO AND (dbo.PEDIMPINCREMENTA.IC_CODIGO in (2, 8, 7)))

			-- con diferente valor
			if @lenguaje <> 2 
 				set @mensaje = ', Fletes Diferentes'
			else
				set @mensaje = ', Freight differs'
			insert into IMPCONCILIALOG(iml_mensaje)
			SELECT 'Ped.: '+left(right(pedimpconcilia.Pedimento collate database_default,11),4)+'-'+right(pedimpconcilia.Pedimento collate database_default,7)+@mensaje+' (Sistema = '+convert(varchar(50),round(PEDIMPINCREMENTA.PII_VALOR*PEDIMP.PI_TIP_CAM,0))+' Archivo ='+convert(varchar(50),pedimpconcilia.FreightCost)+')'
			FROM         pedimpconcilia INNER JOIN
			                      PEDIMP ON pedimpconcilia.PI_CODIGO = PEDIMP.PI_CODIGO LEFT OUTER JOIN PEDIMPINCREMENTA
				ON PEDIMPINCREMENTA.PI_CODIGO=PEDIMP.PI_CODIGO
			WHERE    IC_CODIGO in (2, 8, 7) AND (round(PEDIMPINCREMENTA.PII_VALOR*PEDIMP.PI_TIP_CAM,0)<>pedimpconcilia.FreightCost or PEDIMPINCREMENTA.PII_VALOR is null
				or pedimpconcilia.FreightCost is null)
		


		-- seguros
			if @lenguaje <> 2 
 				set @mensaje = ', Seguros Diferentes'
			else
				set @mensaje = ', Insurance differs'
			insert into IMPCONCILIALOG(iml_mensaje)
			SELECT 'Ped.: '+left(right(pedimpconcilia.Pedimento collate database_default,11),4)+'-'+right(pedimpconcilia.Pedimento collate database_default,7)+@mensaje
				+' (Sistema = 0  Archivo ='+convert(varchar(50),pedimpconcilia.InsuranceCost)+')'
			FROM         pedimpconcilia 
			WHERE    pedimpconcilia.InsuranceCost > 0 AND pedimpconcilia.PI_CODIGO NOT IN 
				(SELECT     dbo.PEDIMP.PI_CODIGO
				FROM         dbo.PEDIMP INNER JOIN
				                      dbo.PEDIMPINCREMENTA ON dbo.PEDIMPINCREMENTA.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
				WHERE     PEDIMP.PI_CODIGO = pedimpconcilia.PI_CODIGO AND (dbo.PEDIMPINCREMENTA.IC_CODIGO = 1))

			if @lenguaje <> 2 
 				set @mensaje = ', Seguros Diferentes'
			else
				set @mensaje = ', Insurance differs'
			insert into IMPCONCILIALOG(iml_mensaje)
			SELECT 'Ped.: '+left(right(pedimpconcilia.Pedimento collate database_default,11),4)+'-'+right(pedimpconcilia.Pedimento collate database_default,7)+@mensaje
			+' (Sistema = '+convert(varchar(50),round(PEDIMPINCREMENTA.PII_VALOR*PEDIMP.PI_TIP_CAM,0))+' Archivo ='+convert(varchar(50),pedimpconcilia.InsuranceCost)+')'
			FROM         pedimpconcilia INNER JOIN
			                      PEDIMP ON pedimpconcilia.PI_CODIGO = PEDIMP.PI_CODIGO LEFT OUTER JOIN PEDIMPINCREMENTA
				ON PEDIMPINCREMENTA.PI_CODIGO=PEDIMP.PI_CODIGO
			WHERE    IC_CODIGO=1 AND (round(PEDIMPINCREMENTA.PII_VALOR*PEDIMP.PI_TIP_CAM,0)<>pedimpconcilia.InsuranceCost or PEDIMPINCREMENTA.PII_VALOR is null
				or pedimpconcilia.InsuranceCost is null)
		


		-- embalajes
			if @lenguaje <> 2 
 				set @mensaje = ', Embalajes Diferentes'
			else
				set @mensaje = ', Packages differs'
			insert into IMPCONCILIALOG(iml_mensaje)
			SELECT 'Ped.: '+left(right(pedimpconcilia.Pedimento collate database_default,11),4)+'-'+right(pedimpconcilia.Pedimento collate database_default,7)+@mensaje
				+' (Sistema = 0  Archivo ='+convert(varchar(50),pedimpconcilia.PackagesCost)+')'
			FROM         pedimpconcilia 
			WHERE    pedimpconcilia.PackagesCost > 0 AND pedimpconcilia.PI_CODIGO NOT IN 
				(SELECT     dbo.PEDIMP.PI_CODIGO
				FROM         dbo.PEDIMP INNER JOIN
				                      dbo.PEDIMPINCREMENTA ON dbo.PEDIMPINCREMENTA.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
				WHERE     PEDIMP.PI_CODIGO = pedimpconcilia.PI_CODIGO AND (dbo.PEDIMPINCREMENTA.IC_CODIGO = 3))


			if @lenguaje <> 2 
 				set @mensaje = ', Embalajes Diferentes'
			else
				set @mensaje = ', Packages differs'
			insert into IMPCONCILIALOG(iml_mensaje)
			SELECT 'Ped.: '+left(right(pedimpconcilia.Pedimento collate database_default,11),4)+'-'+right(pedimpconcilia.Pedimento collate database_default,7)+@mensaje
			+' (Sistema = '+convert(varchar(50),round(PEDIMPINCREMENTA.PII_VALOR*PEDIMP.PI_TIP_CAM,0))+' Archivo ='+convert(varchar(50),pedimpconcilia.PackagesCost)+')'
			FROM         pedimpconcilia INNER JOIN
			                      PEDIMP ON pedimpconcilia.PI_CODIGO = PEDIMP.PI_CODIGO LEFT OUTER JOIN PEDIMPINCREMENTA
				ON PEDIMPINCREMENTA.PI_CODIGO=PEDIMP.PI_CODIGO
			WHERE    IC_CODIGO=3 AND (round(PEDIMPINCREMENTA.PII_VALOR*PEDIMP.PI_TIP_CAM,0)<>pedimpconcilia.PackagesCost or PEDIMPINCREMENTA.PII_VALOR is null
				or pedimpconcilia.PackagesCost is null)
		


		-- Otros Costos
			if @lenguaje <> 2 
 				set @mensaje = ', Otros Incrementables Diferentes'
			else
				set @mensaje = ', Other Cost differs'
			insert into IMPCONCILIALOG(iml_mensaje)
			SELECT 'Ped.: '+left(right(pedimpconcilia.Pedimento collate database_default,11),4)+'-'+right(pedimpconcilia.Pedimento collate database_default,7)+@mensaje+' (Sistema = 0  Archivo ='+convert(varchar(50),pedimpconcilia.OtherCost)+')'
			FROM         pedimpconcilia 
			WHERE    pedimpconcilia.OtherCost > 0 AND pedimpconcilia.PI_CODIGO NOT IN 
				(SELECT     dbo.PEDIMP.PI_CODIGO
				FROM         dbo.PEDIMP INNER JOIN
				                      dbo.PEDIMPINCREMENTA ON dbo.PEDIMPINCREMENTA.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
				WHERE     PEDIMP.PI_CODIGO = pedimpconcilia.PI_CODIGO AND (dbo.PEDIMPINCREMENTA.IC_CODIGO = 11))

			if @lenguaje <> 2 
 				set @mensaje = ', Otros Incrementables Diferentes'
			else
				set @mensaje = ', Other Cost differs'
			insert into IMPCONCILIALOG(iml_mensaje)
			SELECT 'Ped.: '+left(right(pedimpconcilia.Pedimento collate database_default,11),4)+'-'+right(pedimpconcilia.Pedimento collate database_default,7)+@mensaje+' (Sistema = '+convert(varchar(50),round(PEDIMPINCREMENTA.PII_VALOR*PEDIMP.PI_TIP_CAM,0))+' Archivo ='+convert(varchar(50),pedimpconcilia.OtherCost)+')'
			FROM         pedimpconcilia INNER JOIN
			                      PEDIMP ON pedimpconcilia.PI_CODIGO = PEDIMP.PI_CODIGO LEFT OUTER JOIN PEDIMPINCREMENTA
				ON PEDIMPINCREMENTA.PI_CODIGO=PEDIMP.PI_CODIGO
			WHERE    IC_CODIGO=11 AND (round(PEDIMPINCREMENTA.PII_VALOR*PEDIMP.PI_TIP_CAM,0)<>pedimpconcilia.OtherCost or PEDIMPINCREMENTA.PII_VALOR is null
				or pedimpconcilia.OtherCost is null)





		-- contribuciones a nivel pedimento

			if @lenguaje <> 2 
				insert into IMPCONCILIALOG(iml_mensaje)
				select 'Ped.: '+left(right(pedimpconcilia.Pedimento,11),4)+'-'+right(pedimpconcilia.Pedimento,7)+', Contribucion (Nivel Ped.): '+dbo.CONTRIBUCION.con_abrevia+' diferente'
				FROM         dbo.PEDIMP INNER JOIN
				                      dbo.PEDIMPCONTRIBUCION ON dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPCONTRIBUCION.PI_CODIGO INNER JOIN
				                      dbo.pedimpconcilia INNER JOIN
				                      dbo.pedimpconciliaContribucion ON dbo.pedimpconcilia.PI_CODIGO = dbo.pedimpconciliaContribucion.PI_CODIGO INNER JOIN
				                      dbo.CONTRIBUCION ON dbo.pedimpconciliaContribucion.ContributionCode = dbo.CONTRIBUCION.CON_CLAVE ON 
				                      dbo.PEDIMP.PI_CODIGO = dbo.pedimpconcilia.PI_CODIGO AND dbo.PEDIMPCONTRIBUCION.CON_CODIGO = dbo.CONTRIBUCION.CON_CODIGO AND 
				                      dbo.PEDIMPCONTRIBUCION.PIT_CONTRIBTOTMN <> dbo.pedimpconciliaContribucion.TotalAmount

			else
				insert into IMPCONCILIALOG(iml_mensaje)
				select 'Ped.: '+left(right(pedimpconcilia.Pedimento,11),4)+'-'+right(pedimpconcilia.Pedimento,7)+', Contribution (Ped. Level): '+dbo.CONTRIBUCION.con_abrevia +' differs'
				FROM         dbo.PEDIMP INNER JOIN
				                      dbo.PEDIMPCONTRIBUCION ON dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPCONTRIBUCION.PI_CODIGO INNER JOIN
				                      dbo.pedimpconcilia INNER JOIN
				                      dbo.pedimpconciliaContribucion ON dbo.pedimpconcilia.PI_CODIGO = dbo.pedimpconciliaContribucion.PI_CODIGO INNER JOIN
				                      dbo.CONTRIBUCION ON dbo.pedimpconciliaContribucion.ContributionCode = dbo.CONTRIBUCION.CON_CLAVE ON 
				                      dbo.PEDIMP.PI_CODIGO = dbo.pedimpconcilia.PI_CODIGO AND dbo.PEDIMPCONTRIBUCION.CON_CODIGO = dbo.CONTRIBUCION.CON_CODIGO AND 
				                      dbo.PEDIMPCONTRIBUCION.PIT_CONTRIBTOTMN <> dbo.pedimpconciliaContribucion.TotalAmount



			-- forma de pago
			if @lenguaje <> 2 
				insert into IMPCONCILIALOG(iml_mensaje)
				SELECT 'Ped.: '+left(right(pedimpconcilia.Pedimento,11),4)+'-'+right(pedimpconcilia.Pedimento,7)+ ' Forma de pago incorrecta (' + dbo.CONTRIBUCION.CON_ABREVIA + ')'+
					' Sistema =' +dbo.TPAGO.PG_CLAVE +' Archivo='+dbo.pedimpconciliaContribucion.PaymentForm
				FROM         dbo.PEDIMP INNER JOIN
				                      dbo.PEDIMPCONTRIBUCION ON dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPCONTRIBUCION.PI_CODIGO INNER JOIN
				                      dbo.pedimpconcilia INNER JOIN
				                      dbo.pedimpconciliaContribucion ON dbo.pedimpconcilia.PI_CODIGO = dbo.pedimpconciliaContribucion.PI_CODIGO INNER JOIN
				                      dbo.CONTRIBUCION ON dbo.pedimpconciliaContribucion.ContributionCode = dbo.CONTRIBUCION.CON_CLAVE ON 
				                      dbo.PEDIMP.PI_CODIGO = dbo.pedimpconcilia.PI_CODIGO AND 
				                      dbo.PEDIMPCONTRIBUCION.CON_CODIGO = dbo.CONTRIBUCION.CON_CODIGO INNER JOIN
				                      dbo.TPAGO ON dbo.PEDIMPCONTRIBUCION.PG_CODIGO = dbo.TPAGO.PG_CODIGO AND 
				                      dbo.pedimpconciliaContribucion.PaymentForm <> dbo.TPAGO.PG_CLAVE

			else
				insert into IMPCONCILIALOG(iml_mensaje)
				SELECT 'Ped.: '+left(right(pedimpconcilia.Pedimento,11),4)+'-'+right(pedimpconcilia.Pedimento,7)+' incorrect Payment type (' + dbo.CONTRIBUCION.CON_ABREVIA + ')'+
					' Sistema =' +dbo.TPAGO.PG_CLAVE +' Archivo='+dbo.pedimpconciliaContribucion.PaymentForm
				FROM         dbo.PEDIMP INNER JOIN
				                      dbo.PEDIMPCONTRIBUCION ON dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPCONTRIBUCION.PI_CODIGO INNER JOIN
				                      dbo.pedimpconcilia INNER JOIN
				                      dbo.pedimpconciliaContribucion ON dbo.pedimpconcilia.PI_CODIGO = dbo.pedimpconciliaContribucion.PI_CODIGO INNER JOIN
				                      dbo.CONTRIBUCION ON dbo.pedimpconciliaContribucion.ContributionCode = dbo.CONTRIBUCION.CON_CLAVE ON 
				                      dbo.PEDIMP.PI_CODIGO = dbo.pedimpconcilia.PI_CODIGO AND 
				                      dbo.PEDIMPCONTRIBUCION.CON_CODIGO = dbo.CONTRIBUCION.CON_CODIGO INNER JOIN
				                      dbo.TPAGO ON dbo.PEDIMPCONTRIBUCION.PG_CODIGO = dbo.TPAGO.PG_CODIGO AND 
				                      dbo.pedimpconciliaContribucion.PaymentForm <> dbo.TPAGO.PG_CLAVE



		-- contribuciones a nivel pedimento,no existente en intrade

			if @lenguaje <> 2 
				insert into IMPCONCILIALOG(iml_mensaje)
				SELECT     'Ped.: ' + LEFT(RIGHT(dbo.pedimpconcilia.Pedimento, 11), 4) + '-' + RIGHT(dbo.pedimpconcilia.Pedimento, 7) +', Contribucion no existente en intrade (Nivel Ped.):'+ 
				                      dbo.pedimpconciliaContribucion.ContributionCode + ' (' + dbo.CONTRIBUCION.CON_ABREVIA + ')'
				FROM         dbo.pedimpconcilia INNER JOIN
				                      dbo.pedimpconciliaContribucion ON dbo.pedimpconcilia.PI_CODIGO = dbo.pedimpconciliaContribucion.PI_CODIGO INNER JOIN
				                      dbo.CONTRIBUCION ON dbo.pedimpconciliaContribucion.ContributionCode = dbo.CONTRIBUCION.CON_CLAVE
				WHERE     (NOT (dbo.pedimpconciliaContribucion.ContributionCode IN
				                          (SELECT     dbo.CONTRIBUCION.CON_CLAVE
				                            FROM          dbo.PEDIMPCONTRIBUCION INNER JOIN
				                                                   dbo.CONTRIBUCION ON dbo.CONTRIBUCION.CON_CODIGO = dbo.PEDIMPCONTRIBUCION.CON_CODIGO
				                            WHERE      dbo.PEDIMPCONTRIBUCION.PI_CODIGO = dbo.pedimpconcilia.PI_CODIGO)))
				
			else
				insert into IMPCONCILIALOG(iml_mensaje)
				SELECT     'Ped.: ' + LEFT(RIGHT(dbo.pedimpconcilia.Pedimento, 11), 4) + '-' + RIGHT(dbo.pedimpconcilia.Pedimento, 7) +', On the system does not contain the Contribution(Ped. Level):'+ 
				                      dbo.pedimpconciliaContribucion.ContributionCode + ' (' + dbo.CONTRIBUCION.CON_ABREVIA + ')'
				FROM         dbo.pedimpconcilia INNER JOIN
				                      dbo.pedimpconciliaContribucion ON dbo.pedimpconcilia.PI_CODIGO = dbo.pedimpconciliaContribucion.PI_CODIGO INNER JOIN
				                      dbo.CONTRIBUCION ON dbo.pedimpconciliaContribucion.ContributionCode = dbo.CONTRIBUCION.CON_CLAVE
				WHERE     (NOT (dbo.pedimpconciliaContribucion.ContributionCode IN
				                          (SELECT     dbo.CONTRIBUCION.CON_CLAVE
				                            FROM          dbo.PEDIMPCONTRIBUCION INNER JOIN
				                                                   dbo.CONTRIBUCION ON dbo.CONTRIBUCION.CON_CODIGO = dbo.PEDIMPCONTRIBUCION.CON_CODIGO
				                            WHERE      dbo.PEDIMPCONTRIBUCION.PI_CODIGO = dbo.pedimpconcilia.PI_CODIGO)))




			if @lenguaje <> 2 
				insert into IMPCONCILIALOG(iml_mensaje)
				SELECT     'Ped.: ' + LEFT(RIGHT(dbo.pedimpconcilia.Pedimento, 11), 4) + '-' + RIGHT(dbo.pedimpconcilia.Pedimento, 7) +', Contribucion no existente en SAAI (Nivel Ped.):'+ 
				                      dbo.CONTRIBUCION.CON_CLAVE + ' (' + dbo.CONTRIBUCION.CON_ABREVIA + ')'
				FROM         dbo.pedimpconcilia INNER JOIN
				                      dbo.PEDIMPCONTRIBUCION ON dbo.pedimpconcilia.PI_CODIGO = dbo.PEDIMPCONTRIBUCION.PI_CODIGO INNER JOIN
				                      dbo.CONTRIBUCION ON dbo.PEDIMPCONTRIBUCION.CON_CODIGO = dbo.CONTRIBUCION.CON_CODIGO
				WHERE     (NOT (dbo.CONTRIBUCION.CON_CLAVE IN
				                          (SELECT     ContributionCode
				                            FROM          dbo.pedimpconciliaContribucion 
				                            WHERE      dbo.pedimpconciliaContribucion.PI_CODIGO = dbo.pedimpconcilia.PI_CODIGO)))
				
			else
				SELECT     'Ped.: ' + LEFT(RIGHT(dbo.pedimpconcilia.Pedimento, 11), 4) + '-' + RIGHT(dbo.pedimpconcilia.Pedimento, 7) +', On the SAAI does not contain the Contribution (Ped. Level):'+ 
				                      dbo.CONTRIBUCION.CON_CLAVE + ' (' + dbo.CONTRIBUCION.CON_ABREVIA + ')'
				FROM         dbo.pedimpconcilia INNER JOIN
				                      dbo.PEDIMPCONTRIBUCION ON dbo.pedimpconcilia.PI_CODIGO = dbo.PEDIMPCONTRIBUCION.PI_CODIGO INNER JOIN
				                      dbo.CONTRIBUCION ON dbo.PEDIMPCONTRIBUCION.CON_CODIGO = dbo.CONTRIBUCION.CON_CODIGO
				WHERE     (NOT (dbo.CONTRIBUCION.CON_CLAVE IN
				                          (SELECT     ContributionCode
				                            FROM          dbo.pedimpconciliaContribucion 
				                            WHERE      dbo.pedimpconciliaContribucion.PI_CODIGO = dbo.pedimpconcilia.PI_CODIGO)))


		if @lenguaje <> 2 
 				set @mensaje = ', En el sistema no contiene el Identificador (Nivel Ped.):'
			else
				set @mensaje = ', On the system does not contain the Identifier (Ped. Level):'
		insert into IMPCONCILIALOG(iml_mensaje)
		select 'Ped.: '+left(right(pedimpconcilia.Pedimento,11),4)+'-'+right(pedimpconcilia.Pedimento,7)+@mensaje+pedimpconciliaIdentifica.Identificator
		FROM         dbo.pedimpconciliaIdentifica INNER JOIN
		                      dbo.IDENTIFICA ON dbo.pedimpconciliaIdentifica.Identificator = dbo.IDENTIFICA.IDE_CLAVE and IDENTIFICA.IDE_IDENTPERM = 'I' INNER JOIN
		                      dbo.pedimpconcilia ON dbo.pedimpconciliaIdentifica.PI_CODIGO = dbo.pedimpconcilia.PI_CODIGO 
		WHERE     (dbo.IDENTIFICA.IDE_CODIGO NOT IN
		                          (SELECT     IDE_CODIGO
		                            FROM          PEDIMPIDENTIFICA
		                            WHERE      PI_CODIGO = pedimpconciliaIdentifica.PI_CODIGO))



		-- verificacion de catalogos
		if @lenguaje <>2
		insert into IMPCONCILIALOG(iml_mensaje)
		SELECT     'No existe el Pais: '+dbo.pedimpconciliaDet.CountryOrig+' en el cat. de InTrade'
		FROM         dbo.pedimpconciliaDet LEFT OUTER JOIN
		                      dbo.PAIS ON dbo.pedimpconciliaDet.CountryOrig = dbo.PAIS.PA_SAAIM3
		WHERE sistema='SAAI'
		GROUP BY dbo.pedimpconciliaDet.CountryOrig, dbo.PAIS.PA_SAAIM3
		HAVING      (dbo.PAIS.PA_SAAIM3 IS NULL)
		else
		insert into IMPCONCILIALOG(iml_mensaje)
		SELECT     'The Country: '+dbo.pedimpconciliaDet.CountryOrig+' does not exists in InTrade Catalog'
		FROM         dbo.pedimpconciliaDet LEFT OUTER JOIN
		                      dbo.PAIS ON dbo.pedimpconciliaDet.CountryOrig = dbo.PAIS.PA_SAAIM3
		WHERE sistema='SAAI'
		GROUP BY dbo.pedimpconciliaDet.CountryOrig, dbo.PAIS.PA_SAAIM3
		HAVING      (dbo.PAIS.PA_SAAIM3 IS NULL)


		if @lenguaje <>2
		insert into IMPCONCILIALOG(iml_mensaje)
		SELECT     'No existe la F. Arancelaria: '+dbo.pedimpconciliaDet.HTS+' en el cat. de InTrade'
		FROM         dbo.pedimpconciliaDet LEFT OUTER JOIN
		                      dbo.ARANCEL ON dbo.pedimpconciliaDet.HTS = REPLACE(dbo.ARANCEL.AR_FRACCION, '.', '')
		WHERE     (dbo.ARANCEL.AR_FRACCION IS NULL) AND sistema='SAAI'
		GROUP BY dbo.pedimpconciliaDet.HTS
		else
		insert into IMPCONCILIALOG(iml_mensaje)
		SELECT     'The Tariff: '+dbo.pedimpconciliaDet.HTS+' does not exists in InTrade Catalog'
		FROM         dbo.pedimpconciliaDet LEFT OUTER JOIN
		                      dbo.ARANCEL ON dbo.pedimpconciliaDet.HTS = REPLACE(dbo.ARANCEL.AR_FRACCION, '.', '')
		WHERE     (dbo.ARANCEL.AR_FRACCION IS NULL) AND sistema='SAAI'
		GROUP BY dbo.pedimpconciliaDet.HTS

		if @lenguaje <>2
		insert into IMPCONCILIALOG(iml_mensaje)
		SELECT     'No existe la Unidad de Medida: '+dbo.pedimpconciliaDet.UM+' en el cat. de InTrade'
		FROM         dbo.pedimpconciliaDet LEFT OUTER JOIN
		                      dbo.MEDIDA ON dbo.pedimpconciliaDet.UM = dbo.MEDIDA.ME_CLA_PED
		WHERE     (dbo.MEDIDA.ME_CLA_PED IS NULL) AND sistema='SAAI'
		GROUP BY dbo.pedimpconciliaDet.UM
		else
		insert into IMPCONCILIALOG(iml_mensaje)
		SELECT     'The Unit of Measure: '+dbo.pedimpconciliaDet.UM+' does not exists in InTrade Catalog'
		FROM         dbo.pedimpconciliaDet LEFT OUTER JOIN
		                      dbo.MEDIDA ON dbo.pedimpconciliaDet.UM = dbo.MEDIDA.ME_CLA_PED
		WHERE     (dbo.MEDIDA.ME_CLA_PED IS NULL) AND sistema='SAAI'
		GROUP BY dbo.pedimpconciliaDet.UM
		
		


		if (select count(*) from pedimpconciliaInvoice)>0
		begin
		--Relacion de facturas

			if @lenguaje <> 2
				set @mensaje = ',  Factura Erronea en seleccion (no existe en SAAI): '
			else
				set @mensaje = ',  Wrong Invoice Selection (not exist in SAAI):'
			insert into IMPCONCILIALOG(iml_mensaje)
			SELECT 'Ped.: '+left(right(pedimpconcilia.Pedimento,11),4)+'-'+right(pedimpconcilia.Pedimento,7)+@mensaje+VPEDIMPFACT.FI_FOLIO
			FROM         VPEDIMPFACT INNER JOIN
			                      pedimpconcilia ON VPEDIMPFACT.PI_CODIGO = pedimpconcilia.PI_CODIGO
			WHERE     VPEDIMPFACT.FI_FOLIO not in (select InvoiceNo from pedimpconciliaInvoice where pedimpconciliaInvoice.PI_CODIGO=VPEDIMPFACT.PI_CODIGO)
			ORDER BY VPEDIMPFACT.PI_CODIGO, VPEDIMPFACT.FI_CODIGO



		--Relacion de facturas
			if @lenguaje <> 2
				set @mensaje = ',  Factura Erronea en seleccion (no existe en InTrade): '
			else
				set @mensaje = ',  Wrong Invoice Selection (not exist in InTrade):'
			insert into IMPCONCILIALOG(iml_mensaje)
			SELECT 'Ped.: '+left(right(pedimpconcilia.Pedimento,11),4)+'-'+right(pedimpconcilia.Pedimento,7)+@mensaje+InvoiceNo
			FROM         pedimpconciliaInvoice INNER JOIN
			                      pedimpconcilia ON pedimpconciliaInvoice.PI_CODIGO = pedimpconcilia.PI_CODIGO
			WHERE     InvoiceNo not in (select FI_FOLIO from VPEDIMPFACT where VPEDIMPFACT.PI_CODIGO=pedimpconciliaInvoice.PI_CODIGO)


		--Valores en facturas
			if @lenguaje <> 2
				set @mensaje = ',  Valores diferentes (Factura '
			else
				set @mensaje = ',  Different values (Invoice '
			insert into IMPCONCILIALOG(iml_mensaje)
			SELECT 'Ped.: '+left(right(pedimpconcilia.Pedimento,11),4)+'-'+right(pedimpconcilia.Pedimento,7)+@mensaje+VPEDIMPFACT.FI_FOLIO+
					' Sistema =' +Convert(varchar(150),VPEDIMPFACT.PIF_VALDLLS) +' Archivo='+Convert(varchar(150),pedimpconciliaInvoice.ValueUSD)+', '+
			                            ' System =' + Convert(varchar(150),VPEDIMPFACT.PIF_VALMONEXT) + ' Archivo='+Convert(varchar(150),pedimpconciliaInvoice.ValueForeignCurr)+')'
			FROM         VPEDIMPFACT INNER JOIN
			                      pedimpconciliaInvoice ON VPEDIMPFACT.PI_CODIGO = pedimpconciliaInvoice.PI_CODIGO AND 
			                      VPEDIMPFACT.FI_FOLIO = pedimpconciliaInvoice.InvoiceNo INNER JOIN
			                      pedimpconcilia ON pedimpconciliaInvoice.PI_CODIGO = pedimpconcilia.PI_CODIGO
			WHERE     (VPEDIMPFACT.PIF_VALDLLS <> pedimpconciliaInvoice.ValueUSD) OR
			                      (VPEDIMPFACT.PIF_VALMONEXT <> pedimpconciliaInvoice.ValueForeignCurr)
			ORDER BY VPEDIMPFACT.PI_CODIGO, VPEDIMPFACT.FI_CODIGO


		--fechas en facturas
			if @lenguaje <> 2
				set @mensaje = ',  Valores diferentes (Factura '
			else
				set @mensaje = ',  Different values (Invoice '
			insert into IMPCONCILIALOG(iml_mensaje)
			SELECT 'Ped.: '+left(right(pedimpconcilia.Pedimento,11),4)+'-'+right(pedimpconcilia.Pedimento,7)+@mensaje+VPEDIMPFACT.FI_FOLIO+
					' Sistema =' +Convert(varchar(150),FI_FECHA,120) +' Archivo='+Convert(varchar(150),pedimpconciliaInvoice.InvoiceDate)
			FROM         VPEDIMPFACT INNER JOIN
			                      pedimpconciliaInvoice ON VPEDIMPFACT.PI_CODIGO = pedimpconciliaInvoice.PI_CODIGO AND 
			                      VPEDIMPFACT.FI_FOLIO = pedimpconciliaInvoice.InvoiceNo INNER JOIN
			                      pedimpconcilia ON pedimpconciliaInvoice.PI_CODIGO = pedimpconcilia.PI_CODIGO
			WHERE     (Convert(varchar(150),FI_FECHA,120) <> pedimpconciliaInvoice.InvoiceDate) 
			ORDER BY VPEDIMPFACT.PI_CODIGO, VPEDIMPFACT.FI_CODIGO



		--Proveedor/Destino en facturas
			if @lenguaje <> 2
				set @mensaje = ',  Proveedor/Destino diferente (Factura '
			else
				set @mensaje = ',  Different supplier/destination (Invoice '
			insert into IMPCONCILIALOG(iml_mensaje)
			SELECT 'Ped.: '+left(right(pedimpconcilia.Pedimento,11),4)+'-'+right(pedimpconcilia.Pedimento,7)+@mensaje+VPEDIMPFACT.FI_FOLIO+
					' Sistema =' +replace(ISNULL(dbo.CLIENTE.CL_RFC, dbo.CLIENTE.CL_IRS),'-','') +' Archivo='+pedimpconciliaInvoice.Supplier_ClientIRS
			FROM         dbo.VPEDIMPFACT INNER JOIN
			                      dbo.pedimpconciliaInvoice ON dbo.VPEDIMPFACT.PI_CODIGO = dbo.pedimpconciliaInvoice.PI_CODIGO AND 
			                      dbo.VPEDIMPFACT.FI_FOLIO = dbo.pedimpconciliaInvoice.InvoiceNo INNER JOIN
			                      dbo.pedimpconcilia ON dbo.pedimpconciliaInvoice.PI_CODIGO = dbo.pedimpconcilia.PI_CODIGO INNER JOIN
			                      dbo.CLIENTE ON dbo.VPEDIMPFACT.PR_CODIGO = dbo.CLIENTE.CL_CODIGO
			WHERE     dbo.pedimpconciliaInvoice.Supplier_ClientIRS<> replace(ISNULL(dbo.CLIENTE.CL_RFC, dbo.CLIENTE.CL_IRS),'-','')
			ORDER BY VPEDIMPFACT.PI_CODIGO, VPEDIMPFACT.FI_CODIGO

		end


		if (select count(*) from pedimpconciliaContainer)>0
		begin

		--Relacion de Contenedores
			if @lenguaje <> 2
				set @mensaje = ',  Contenedor Erroneo(no existe en SAAI): '
			else
				set @mensaje = ',  Wrong Container(not exist in SAAI):'
			insert into IMPCONCILIALOG(iml_mensaje)
			SELECT 'Ped.: '+left(right(pedimpconcilia.Pedimento,11),4)+'-'+right(pedimpconcilia.Pedimento,7)+@mensaje+PedImpContenedor.PI_CONTENEDOR_NO
			FROM         (SELECT    PedImpCaja.PI_CONTENEDOR_NO, PedImpCaja.PI_CODIGO
					FROM         PedImpCaja INNER JOIN
		                      TCAJA ON PedImpCaja.TCA_CODIGO = TCAJA.TCA_CODIGO) PedImpContenedor INNER JOIN
			                      pedimpconcilia ON PedImpContenedor.PI_CODIGO = pedimpconcilia.PI_CODIGO
			WHERE     PedImpContenedor.PI_CONTENEDOR_NO not in (select NoContenedor from pedimpconciliaContainer where pedimpconciliaContainer.PI_CODIGO=PedImpContenedor.PI_CODIGO)



		--Relacion de Contenedores
			if @lenguaje <> 2
				set @mensaje = ',  Contenedor Erroneo(no existe en InTrade): '
			else
				set @mensaje = ',  Wrong Container(not exist in InTrade):'
			insert into IMPCONCILIALOG(iml_mensaje)
			SELECT 'Ped.: '+left(right(pedimpconcilia.Pedimento,11),4)+'-'+right(pedimpconcilia.Pedimento,7)+@mensaje+NoContenedor
			FROM         pedimpconciliaContainer INNER JOIN
			                      pedimpconcilia ON pedimpconciliaContainer.PI_CODIGO = pedimpconcilia.PI_CODIGO
			WHERE     NoContenedor not in  (SELECT    PedImpCaja.PI_CONTENEDOR_NO FROM PedImpCaja INNER JOIN TCAJA ON PedImpCaja.TCA_CODIGO = TCAJA.TCA_CODIGO
							WHERE PedImpCaja.PI_CODIGO=pedimpconciliaContainer.PI_CODIGO)



		--Tipo Caja en Contendores
			if @lenguaje <> 2
				set @mensaje = ',  Valores diferentes (Factura '
			else
				set @mensaje = ',  Different values (Invoice '
			insert into IMPCONCILIALOG(iml_mensaje)
			SELECT 'Ped.: '+left(right(pedimpconcilia.Pedimento,11),4)+'-'+right(pedimpconcilia.Pedimento,7)+@mensaje+PedImpContenedor.PI_CONTENEDOR_NO+
					' Sistema =' +TCA_CLA_PED +' Archivo='+pedimpconciliaContainer.TipoContenedor
			FROM  (SELECT    PedImpCaja.PI_CONTENEDOR_NO, PedImpCaja.PI_CODIGO, TCAJA.TCA_CLA_PED
			  	    FROM         PedImpCaja INNER JOIN
	                 		     TCAJA ON PedImpCaja.TCA_CODIGO = TCAJA.TCA_CODIGO) PedImpContenedor INNER JOIN
			                      pedimpconciliaContainer ON PedImpContenedor.PI_CODIGO = pedimpconciliaContainer.PI_CODIGO AND 
			                      PedImpContenedor.PI_CONTENEDOR_NO = pedimpconciliaContainer.NoContenedor INNER JOIN
			                      pedimpconcilia ON pedimpconciliaContainer.PI_CODIGO = pedimpconcilia.PI_CODIGO
			WHERE     (TCA_CLA_PED <> pedimpconciliaContainer.TipoContenedor) 

		end

		/*=============== detalles  ======================*/			

			DELETE FROM pedimpconciliaDet WHERE (Sistema='TOTAL' or Sistema='INTRADE')





		if (select cf_conciliasaaisec from configuracion)='S'
		begin

			insert into pedimpconciliaDet(PI_CODIGO, Pedimento, DescSpanish, Quantity, UM, QtyUMHTS, UMHTS, HTS, TotalValueMN, TotalValueAdu, AddValue, CountryOrig, CountrySel, UnitValueUSD, 
			                      Sistema, RecordNum, pib_indiceb)
			
			SELECT     dbo.PEDIMP.PI_CODIGO, dbo.pedimpconcilia.Pedimento, LEFT(dbo.PEDIMPDETB.PIB_NOMBRE,50), dbo.PEDIMPDETB.PIB_CAN_GEN AS CantidadUMC, 
			                      MEDIDA_1.ME_CLA_PED AS UMComercializacion, ROUND(dbo.PEDIMPDETB.PIB_CAN_AR,3) AS CantidadUMT, MEDIDA_2.ME_CLA_PED AS UMTarifa, 
					left(dbo.ARANCEL.AR_FRACCION,8), dbo.PEDIMPDETB.PIB_VAL_FAC, 
			                      case when PEDIMP.PI_MOVIMIENTO='S' then 0 else dbo.PEDIMPDETB.PIB_VAL_ADU end, 
						case when PEDIMP.PI_MOVIMIENTO='S' and PEDIMPDETB.PIB_COS_UNIVA>0 then
						PEDIMPDETB.PIB_COS_UNIVA*PEDIMPDETB.PIB_CANT else 0 end, 
						dbo.PAIS.PA_SAAIM3 AS PaisOrigenDestino, PAIS_1.PA_SAAIM3 AS PaisCompradorVendedor, 
			                      case when dbo.PEDIMPDETB.PIB_CAN_GEN > 0 then ROUND(dbo.PEDIMPDETB.PIB_VAL_FAC / dbo.PEDIMPDETB.PIB_CAN_GEN, 5) else ROUND(dbo.PEDIMPDETB.PIB_VAL_FAC, 5) end AS PrecioUnitario, 'INTRADE', dbo.PEDIMPDETB.PIB_SECUENCIA,
					dbo.PEDIMPDETB.PIB_INDICEB
			FROM         dbo.PAIS RIGHT OUTER JOIN
			                      dbo.PEDIMP INNER JOIN
			                      dbo.pedimpconcilia ON dbo.PEDIMP.PI_CODIGO = dbo.pedimpconcilia.PI_CODIGO INNER JOIN
			                      dbo.PEDIMPDETB ON dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPDETB.PI_CODIGO LEFT OUTER JOIN
			                      dbo.PAIS PAIS_1 ON dbo.PEDIMPDETB.PA_PROCEDE = PAIS_1.PA_CODIGO ON 
			                      dbo.PAIS.PA_CODIGO = dbo.PEDIMPDETB.PA_ORIGEN LEFT OUTER JOIN
			                      dbo.MEDIDA MEDIDA_1 ON dbo.PEDIMPDETB.ME_GENERICO = MEDIDA_1.ME_CODIGO LEFT OUTER JOIN
			                      dbo.MEDIDA MEDIDA_2 RIGHT OUTER JOIN
			                      dbo.ARANCEL ON MEDIDA_2.ME_CODIGO = dbo.ARANCEL.ME_CODIGO ON dbo.PEDIMPDETB.AR_IMPMX = dbo.ARANCEL.AR_CODIGO


				INSERT INTO pedimpconciliaDet(PI_CODIGO, Pedimento, Quantity, QtyUMHTS, TotalValueMN, TotalValueAdu, AddValue, Sistema, PIB_INDICEB, RecordNum)
				SELECT     PI_CODIGO, Pedimento, round(SUM(isnull(Quantity,0)),3), round(SUM(isnull(QtyUMHTS,0)),3), round(SUM(isnull(TotalValueMN,0)),5), 
					   round(SUM(isnull(TotalValueAdu,0)),5), round(SUM(isnull(AddValue,0)),5), 'TOTAL', PIB_INDICEB, RecordNum
				FROM         pedimpconciliaDet
				GROUP BY Pedimento, PIB_INDICEB, PI_CODIGO, RecordNum



				-- se anexan las contribuciones a nivel partida
	
				DELETE FROM pedimpconciliaDetContribucion WHERE (Sistema='TOTAL' or Sistema='INTRADE')
	
				INSERT INTO pedimpconciliaDetContribucion(PI_CODIGO, Pedimento, RecordNum, ContributionCode, ContributionRate, PaymentForm, RateType, TotalAmount, Sistema, PIB_INDICEB)
				SELECT     dbo.pedimpconcilia.PI_CODIGO, dbo.pedimpconcilia.Pedimento, dbo.PEDIMPDETB.PIB_SECUENCIA, dbo.CONTRIBUCION.CON_CLAVE, 
				                      dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBPOR, dbo.TPAGO.PG_CLAVEM3, dbo.TTASA.TTA_CLA_PED, 
				                      dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN, 'INTRADE', dbo.PEDIMPDETBCONTRIBUCION.PIB_INDICEB
				FROM         dbo.PEDIMPDETB INNER JOIN
				                      dbo.PEDIMPDETBCONTRIBUCION ON dbo.PEDIMPDETB.PIB_INDICEB = dbo.PEDIMPDETBCONTRIBUCION.PIB_INDICEB INNER JOIN
				                      dbo.CONTRIBUCION ON dbo.PEDIMPDETBCONTRIBUCION.CON_CODIGO = dbo.CONTRIBUCION.CON_CODIGO INNER JOIN
				                      dbo.pedimpconcilia ON dbo.PEDIMPDETB.PI_CODIGO = dbo.pedimpconcilia.PI_CODIGO LEFT OUTER JOIN
				                      dbo.TTASA ON dbo.PEDIMPDETBCONTRIBUCION.TTA_CODIGO = dbo.TTASA.TTA_CODIGO LEFT OUTER JOIN
				                      dbo.TPAGO ON dbo.PEDIMPDETBCONTRIBUCION.PG_CODIGO = dbo.TPAGO.PG_CODIGO 
				WHERE  dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN>0
	
	
	
				INSERT INTO pedimpconciliaDetContribucion(PI_CODIGO, Pedimento, ContributionCode, TotalAmount, Sistema, RecordNum, PIB_INDICEB)
				SELECT     PI_CODIGO, Pedimento, ContributionCode, SUM(TotalAmount), 'TOTAL', RecordNum, PIB_INDICEB
				FROM         pedimpconciliaDetContribucion
				GROUP BY PI_CODIGO, Pedimento, ContributionCode, RecordNum, PIB_INDICEB
	

		end
		else
		begin
			insert into pedimpconciliaDet(PI_CODIGO, Pedimento, DescSpanish, Quantity, UM, QtyUMHTS, UMHTS, HTS, TotalValueMN, TotalValueAdu, AddValue, CountryOrig, CountrySel, UnitValueUSD, 
			                      Sistema, RecordNum)
			
			SELECT     dbo.PEDIMP.PI_CODIGO, dbo.pedimpconcilia.Pedimento, LEFT(dbo.PEDIMPDETB.PIB_NOMBRE,50), dbo.PEDIMPDETB.PIB_CAN_GEN AS CantidadUMC, 
			                      MEDIDA_1.ME_CLA_PED AS UMComercializacion, ROUND(dbo.PEDIMPDETB.PIB_CAN_AR,3) AS CantidadUMT, MEDIDA_2.ME_CLA_PED AS UMTarifa, 
					left(dbo.ARANCEL.AR_FRACCION,8),dbo.PEDIMPDETB.PIB_VAL_FAC, 
			                        case when PEDIMP.PI_MOVIMIENTO='S' then 0 else dbo.PEDIMPDETB.PIB_VAL_ADU end, 
						case when PEDIMP.PI_MOVIMIENTO='S' and PEDIMPDETB.PIB_COS_UNIVA>0 then
						PEDIMPDETB.PIB_COS_UNIVA*PEDIMPDETB.PIB_CANT else 0 end, 
						dbo.PAIS.PA_SAAIM3 AS PaisOrigenDestino, PAIS_1.PA_SAAIM3 AS PaisCompradorVendedor, 
					 	case when dbo.PEDIMPDETB.PIB_CAN_GEN > 0 then ROUND(dbo.PEDIMPDETB.PIB_VAL_FAC / dbo.PEDIMPDETB.PIB_CAN_GEN, 5) 
						else ROUND(dbo.PEDIMPDETB.PIB_VAL_FAC, 5) end AS PrecioUnitario, 'INTRADE', dbo.PEDIMPDETB.PIB_SECUENCIA
			FROM         dbo.PAIS RIGHT OUTER JOIN
			                      dbo.PEDIMP INNER JOIN
			                      dbo.pedimpconcilia ON dbo.PEDIMP.PI_CODIGO = dbo.pedimpconcilia.PI_CODIGO INNER JOIN
			                      dbo.PEDIMPDETB ON dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPDETB.PI_CODIGO LEFT OUTER JOIN
			                      dbo.PAIS PAIS_1 ON dbo.PEDIMPDETB.PA_PROCEDE = PAIS_1.PA_CODIGO ON 
			                      dbo.PAIS.PA_CODIGO = dbo.PEDIMPDETB.PA_ORIGEN LEFT OUTER JOIN
			                      dbo.MEDIDA MEDIDA_1 ON dbo.PEDIMPDETB.ME_GENERICO = MEDIDA_1.ME_CODIGO LEFT OUTER JOIN
			                      dbo.MEDIDA MEDIDA_2 RIGHT OUTER JOIN
			                      dbo.ARANCEL ON MEDIDA_2.ME_CODIGO = dbo.ARANCEL.ME_CODIGO ON dbo.PEDIMPDETB.AR_IMPMX = dbo.ARANCEL.AR_CODIGO


			
				IF (SELECT CF_SAAIDIVDESC FROM CONFIGURACION)='S' 
				begin
					--  se reemplaza el enter REPLACE(DescSpanish, CHAR(13) + CHAR(10), '')
					INSERT INTO pedimpconciliaDet(PI_CODIGO, Pedimento, Quantity, QtyUMHTS, HTS, TotalValueMN, TotalValueAdu, AddValue, CountrySel, CountryOrig, DescSpanish, Sistema)
					SELECT     PI_CODIGO, Pedimento, round(SUM(isnull(Quantity,0)),3), round(SUM(isnull(QtyUMHTS,0)),3), HTS, round(SUM(isnull(TotalValueMN,0)),5), 
					round(SUM(isnull(TotalValueAdu,0)),5), round(SUM(isnull(AddValue,0)),5), CountrySel, CountryOrig,  REPLACE(DescSpanish, CHAR(13) + CHAR(10), ''), 'TOTAL'
					FROM         pedimpconciliaDet
					GROUP BY Pedimento, HTS,  REPLACE(DescSpanish, CHAR(13) + CHAR(10), ''), CountrySel, CountryOrig, PI_CODIGO
	
				end
				else
				begin
					INSERT INTO pedimpconciliaDet(PI_CODIGO, Pedimento, Quantity, QtyUMHTS, HTS, TotalValueMN, TotalValueAdu, AddValue, CountrySel, CountryOrig, Sistema)
					SELECT     PI_CODIGO, Pedimento, round(SUM(isnull(Quantity,0)),3), round(SUM(isnull(QtyUMHTS,0)),3), HTS, round(SUM(isnull(TotalValueMN,0)),5), 
						round(SUM(isnull(TotalValueAdu,0)),5), round(SUM(isnull(AddValue,0)),5), CountrySel, CountryOrig, 'TOTAL'
					FROM         pedimpconciliaDet
					GROUP BY Pedimento, HTS, CountrySel, CountryOrig, PI_CODIGO
	
				end


				-- se anexan las contribuciones a nivel partida
	
				DELETE FROM pedimpconciliaDetContribucion WHERE (Sistema='TOTAL' or Sistema='INTRADE')
	
				INSERT INTO pedimpconciliaDetContribucion(PI_CODIGO, Pedimento, RecordNum, ContributionCode, ContributionRate, PaymentForm, RateType, TotalAmount, Sistema)
				SELECT     dbo.pedimpconcilia.PI_CODIGO, dbo.pedimpconcilia.Pedimento, dbo.PEDIMPDETB.PIB_SECUENCIA, dbo.CONTRIBUCION.CON_CLAVE, 
				                      dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBPOR, dbo.TPAGO.PG_CLAVEM3, dbo.TTASA.TTA_CLA_PED, 
				                      dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN, 'INTRADE'
				FROM         dbo.PEDIMPDETB INNER JOIN
				                      dbo.PEDIMPDETBCONTRIBUCION ON dbo.PEDIMPDETB.PIB_INDICEB = dbo.PEDIMPDETBCONTRIBUCION.PIB_INDICEB INNER JOIN
				                      dbo.CONTRIBUCION ON dbo.PEDIMPDETBCONTRIBUCION.CON_CODIGO = dbo.CONTRIBUCION.CON_CODIGO INNER JOIN
				                      dbo.pedimpconcilia ON dbo.PEDIMPDETB.PI_CODIGO = dbo.pedimpconcilia.PI_CODIGO LEFT OUTER JOIN
				                      dbo.TTASA ON dbo.PEDIMPDETBCONTRIBUCION.TTA_CODIGO = dbo.TTASA.TTA_CODIGO LEFT OUTER JOIN
				                      dbo.TPAGO ON dbo.PEDIMPDETBCONTRIBUCION.PG_CODIGO = dbo.TPAGO.PG_CODIGO 
				WHERE  dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN>0
	
	
	
				INSERT INTO pedimpconciliaDetContribucion(PI_CODIGO, Pedimento, ContributionCode, TotalAmount, Sistema)
				SELECT     PI_CODIGO, Pedimento, ContributionCode, SUM(TotalAmount), 'TOTAL'
				FROM         pedimpconciliaDetContribucion
				GROUP BY PI_CODIGO, Pedimento, ContributionCode


		end





		-- compara el total en contribuciones 
			insert into IMPCONCILIALOG(iml_mensaje)
				
			SELECT     'Ped.: '+left(right(pedimpconciliaDetContribucion.Pedimento,11),4)+'-'+right(pedimpconciliaDetContribucion.Pedimento,7)+', Total de Pago Contribuciones, Sistema= ' +Convert(varchar(150),(SELECT     SUM(PCD.TotalAmount)
				FROM         pedimpconciliaDetContribucion PCD
				WHERE     (PCD.Sistema = 'INTRADE') AND PCD.Pedimento=pedimpconciliaDetContribucion.Pedimento)) +' Archivo= ' +Convert(varchar(150),SUM(ABS(TotalAmount)))
			FROM         pedimpconciliaDetContribucion
			WHERE     (Sistema = 'SAAI')
			GROUP BY Pedimento
			HAVING SUM(ABS(TotalAmount)) <> (SELECT     SUM(PCD.TotalAmount)
				FROM         pedimpconciliaDetContribucion PCD
				WHERE     (PCD.Sistema = 'INTRADE') AND PCD.Pedimento=pedimpconciliaDetContribucion.Pedimento)

			

		-- compara el total en cantidad comercial x pedimento
				if @lenguaje <> 2
					insert into IMPCONCILIALOG(iml_mensaje)
					select 'Ped.: '+left(right(pedimpconciliadet.Pedimento,11),4)+'-'+right(pedimpconciliadet.Pedimento,7)+', Cantidad Comercial Total diferente, '+
					       					          '  Sistema =' +Convert(varchar(150),(SELECT SUM(PCon1.Quantity)
									                  FROM          pedimpconciliaDet PCon1
									                  WHERE      (PCon1.Sistema = 'INTRADE') AND PCon1.Pedimento = pedimpconciliaDet.Pedimento))+' Archivo='+Convert(varchar(150),ABS(SUM(Quantity)))+')'
					FROM         pedimpconciliaDet
					WHERE     (Sistema = 'SAAI')
					GROUP BY Pedimento
					HAVING ABS(SUM(Quantity)) <> (SELECT     SUM(PCon1.Quantity)
					                            FROM          pedimpconciliaDet PCon1
					                            WHERE      (PCon1.Sistema = 'INTRADE') AND PCon1.Pedimento = pedimpconciliaDet.Pedimento) 
				else
					insert into IMPCONCILIALOG(iml_mensaje)
					select 'Ped.: '+left(right(pedimpconciliadet.Pedimento,11),4)+'-'+right(pedimpconciliadet.Pedimento,7)+', Total Commercial Quantity is different, '+
					       					          '  System =' +Convert(varchar(150),(SELECT SUM(PCon1.Quantity)
									                  FROM          pedimpconciliaDet PCon1
									                  WHERE      (PCon1.Sistema = 'INTRADE') AND PCon1.Pedimento = pedimpconciliaDet.Pedimento))+' File='+Convert(varchar(150),ABS(SUM(Quantity)))+')'
					FROM         pedimpconciliaDet
					WHERE     (Sistema = 'SAAI')
					GROUP BY Pedimento
					HAVING ABS(SUM(Quantity)) <> (SELECT     SUM(PCon1.Quantity)
					                            FROM          pedimpconciliaDet PCon1
					                            WHERE      (PCon1.Sistema = 'INTRADE') AND PCon1.Pedimento = pedimpconciliaDet.Pedimento) 




		-- compara el total en valor mn x pedimento

				if @lenguaje <> 2
					insert into IMPCONCILIALOG(iml_mensaje)
					select 'Ped.: '+left(right(pedimpconciliadet.Pedimento,11),4)+'-'+right(pedimpconciliadet.Pedimento,7)+', Valor Comercial Total diferente, '+
					       					          '  Sistema =' +Convert(varchar(150),(SELECT SUM(PCon1.TotalValueMN)
									                  FROM          pedimpconciliaDet PCon1
									                  WHERE      (PCon1.Sistema = 'INTRADE') AND PCon1.Pedimento = pedimpconciliaDet.Pedimento))+' Archivo='+Convert(varchar(150),ABS(SUM(TotalValueMN)))+')'
					FROM         pedimpconciliaDet
					WHERE     (Sistema = 'SAAI')
					GROUP BY Pedimento
					HAVING ABS(SUM(TotalValueMN)) <> (SELECT     SUM(PCon1.TotalValueMN)
					                            FROM          pedimpconciliaDet PCon1
					                            WHERE      (PCon1.Sistema = 'INTRADE') AND PCon1.Pedimento = pedimpconciliaDet.Pedimento) 
				else
					insert into IMPCONCILIALOG(iml_mensaje)
					select 'Ped.: '+left(right(pedimpconciliadet.Pedimento,11),4)+'-'+right(pedimpconciliadet.Pedimento,7)+', Total Commercial Value is different, '+
					       					          '  System =' +Convert(varchar(150),(SELECT SUM(PCon1.TotalValueMN)
									                  FROM          pedimpconciliaDet PCon1
									                  WHERE      (PCon1.Sistema = 'INTRADE') AND PCon1.Pedimento = pedimpconciliaDet.Pedimento))+' File='+Convert(varchar(150),ABS(SUM(TotalValueMN)))+')'
					FROM         pedimpconciliaDet
					WHERE     (Sistema = 'SAAI')
					GROUP BY Pedimento
					HAVING ABS(SUM(TotalValueMN)) <> (SELECT     SUM(PCon1.TotalValueMN)
					                            FROM          pedimpconciliaDet PCon1
					                            WHERE      (PCon1.Sistema = 'INTRADE') AND PCon1.Pedimento = pedimpconciliaDet.Pedimento) 



		-- compara el total en valor aduana x pedimento

				if @lenguaje <> 2
					insert into IMPCONCILIALOG(iml_mensaje)
					select 'Ped.: '+left(right(pedimpconciliadet.Pedimento,11),4)+'-'+right(pedimpconciliadet.Pedimento,7)+', Valor Aduana Total diferente, '+
					       					          '  Sistema =' +Convert(varchar(150),(SELECT SUM(PCon1.TotalValueAdu)
									                  FROM          pedimpconciliaDet PCon1
									                  WHERE      (PCon1.Sistema = 'INTRADE') AND PCon1.Pedimento = pedimpconciliaDet.Pedimento))+' Archivo='+Convert(varchar(150),ABS(SUM(TotalValueAdu)))+')'
					FROM         pedimpconciliaDet
					WHERE     (Sistema = 'SAAI')
					GROUP BY Pedimento
					HAVING ABS(SUM(TotalValueAdu)) <> (SELECT     SUM(PCon1.TotalValueAdu)
					                            FROM          pedimpconciliaDet PCon1
					                            WHERE      (PCon1.Sistema = 'INTRADE') AND PCon1.Pedimento = pedimpconciliaDet.Pedimento) 
				else
					insert into IMPCONCILIALOG(iml_mensaje)
					select 'Ped.: '+left(right(pedimpconciliadet.Pedimento,11),4)+'-'+right(pedimpconciliadet.Pedimento,7)+', Total Customs Value is different, '+
					       					          '  System =' +Convert(varchar(150),(SELECT SUM(PCon1.TotalValueAdu)
									                  FROM          pedimpconciliaDet PCon1
									                  WHERE      (PCon1.Sistema = 'INTRADE') AND PCon1.Pedimento = pedimpconciliaDet.Pedimento))+' File='+Convert(varchar(150),ABS(SUM(TotalValueAdu)))+')'
					FROM         pedimpconciliaDet
					WHERE     (Sistema = 'SAAI')
					GROUP BY Pedimento
					HAVING ABS(SUM(TotalValueAdu)) <> (SELECT     SUM(PCon1.TotalValueAdu)
					                            FROM          pedimpconciliaDet PCon1
					                            WHERE      (PCon1.Sistema = 'INTRADE') AND PCon1.Pedimento = pedimpconciliaDet.Pedimento) 




		-- compara el total en valor agregado pedimento

				if @lenguaje <> 2
					insert into IMPCONCILIALOG(iml_mensaje)
					select 'Ped.: '+left(right(pedimpconciliadet.Pedimento,11),4)+'-'+right(pedimpconciliadet.Pedimento,7)+', Valor Agregado Total diferente, '+
					       					          '  Sistema =' +Convert(varchar(150),(SELECT SUM(PCon1.AddValue)
									                  FROM          pedimpconciliaDet PCon1
									                  WHERE      (PCon1.Sistema = 'INTRADE') AND PCon1.Pedimento = pedimpconciliaDet.Pedimento))+' Archivo='+Convert(varchar(150),ABS(SUM(AddValue)))+')'
					FROM         pedimpconciliaDet
					WHERE     (Sistema = 'SAAI')
					GROUP BY Pedimento
					HAVING ABS(SUM(AddValue)) <> (SELECT     SUM(PCon1.AddValue)
					                            FROM          pedimpconciliaDet PCon1
					                            WHERE      (PCon1.Sistema = 'INTRADE') AND PCon1.Pedimento = pedimpconciliaDet.Pedimento) 
				else
					insert into IMPCONCILIALOG(iml_mensaje)
					select 'Ped.: '+left(right(pedimpconciliadet.Pedimento,11),4)+'-'+right(pedimpconciliadet.Pedimento,7)+', Total Add Value is different, '+
					       					          '  System =' +Convert(varchar(150),(SELECT SUM(PCon1.AddValue)
									                  FROM          pedimpconciliaDet PCon1
									                  WHERE      (PCon1.Sistema = 'INTRADE') AND PCon1.Pedimento = pedimpconciliaDet.Pedimento))+' File='+Convert(varchar(150),ABS(SUM(AddValue)))+')'
					FROM         pedimpconciliaDet
					WHERE     (Sistema = 'SAAI')
					GROUP BY Pedimento
					HAVING ABS(SUM(AddValue)) <> (SELECT     SUM(PCon1.AddValue)
					                            FROM          pedimpconciliaDet PCon1
					                            WHERE      (PCon1.Sistema = 'INTRADE') AND PCon1.Pedimento = pedimpconciliaDet.Pedimento) 



		if (select cf_conciliasaaisec from configuracion)='S'
		begin


			declare CUR_VERIFICADETALLE cursor for
				SELECT     PIB_INDICEB
				FROM pedimpconciliaDet
				WHERE SISTEMA='INTRADE'
				GROUP BY PIB_INDICEB
			 OPEN CUR_VERIFICADETALLE
			
			  FETCH NEXT FROM CUR_VERIFICADETALLE
				INTO @PIB_INDICEB
			
			  WHILE (@@fetch_status = 0) 
			  BEGIN  


				IF (SELECT HTS FROM pedimpconciliaDet WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='SAAI')=
				   (SELECT HTS FROM pedimpconciliaDet WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='INTRADE')
					UPDATE pedimpconciliaDet
					SET HTS='='
					WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='TOTAL'
				ELSE
					UPDATE pedimpconciliaDet
					SET HTS='<>'
					WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='TOTAL'	



				IF (SELECT CountryOrig FROM pedimpconciliaDet WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='SAAI')=
				   (SELECT CountryOrig FROM pedimpconciliaDet WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='INTRADE')
					UPDATE pedimpconciliaDet
					SET CountryOrig='='
					WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='TOTAL'
				ELSE
					UPDATE pedimpconciliaDet
					SET CountryOrig='<>'
					WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='TOTAL'	



				IF (SELECT CountrySel FROM pedimpconciliaDet WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='SAAI')=
				   (SELECT CountrySel FROM pedimpconciliaDet WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='INTRADE')
					UPDATE pedimpconciliaDet
					SET CountrySel='='
					WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='TOTAL'
				ELSE
					UPDATE pedimpconciliaDet
					SET CountrySel='<>'
					WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='TOTAL'	




				IF (SELECT DescSpanish FROM pedimpconciliaDet WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='SAAI')=
				   (SELECT DescSpanish FROM pedimpconciliaDet WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='INTRADE')
					UPDATE pedimpconciliaDet
					SET DescSpanish='='
					WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='TOTAL'
				ELSE
					UPDATE pedimpconciliaDet
					SET DescSpanish='<>'
					WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='TOTAL'	



				IF (SELECT UM FROM pedimpconciliaDet WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='SAAI')=
				   (SELECT UM FROM pedimpconciliaDet WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='INTRADE')
					UPDATE pedimpconciliaDet
					SET UM='='
					WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='TOTAL'
				ELSE
					UPDATE pedimpconciliaDet
					SET UM='<>'
					WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='TOTAL'
	


				IF (SELECT UMHTS FROM pedimpconciliaDet WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='SAAI')=
				   (SELECT UMHTS FROM pedimpconciliaDet WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='INTRADE')
					UPDATE pedimpconciliaDet
					SET UMHTS='='
					WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='TOTAL'
				ELSE
					UPDATE pedimpconciliaDet
					SET UMHTS='<>'
					WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='TOTAL'
	

				

				IF (SELECT PaymentForm FROM pedimpconciliaDetContribucion WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='SAAI')=
				   (SELECT PaymentForm FROM pedimpconciliaDetContribucion WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='INTRADE')
					UPDATE pedimpconciliaDetContribucion
					SET PaymentForm='='
					WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='TOTAL'
				ELSE
					UPDATE pedimpconciliaDetContribucion
					SET PaymentForm='<>'
					WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='TOTAL'
	

				IF (SELECT RateType FROM pedimpconciliaDetContribucion WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='SAAI')=
				   (SELECT RateType FROM pedimpconciliaDetContribucion WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='INTRADE')
					UPDATE pedimpconciliaDetContribucion
					SET RateType='='
					WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='TOTAL'
				ELSE
					UPDATE pedimpconciliaDetContribucion
					SET RateType='<>'
					WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='TOTAL'
	


				IF (SELECT ContributionRate FROM pedimpconciliaDetContribucion WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='SAAI')=
				   (SELECT ContributionRate FROM pedimpconciliaDetContribucion WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='INTRADE')
					UPDATE pedimpconciliaDetContribucion
					SET ContributionRate='0'
					WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='TOTAL'
				ELSE
					UPDATE pedimpconciliaDetContribucion
					SET ContributionRate= (SELECT ContributionRate FROM pedimpconciliaDetContribucion WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='SAAI')-
				   (SELECT ContributionRate FROM pedimpconciliaDetContribucion WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='INTRADE')
					WHERE PIB_INDICEB=@PIB_INDICEB AND SISTEMA='TOTAL'
	


	
	
				FETCH NEXT FROM CUR_VERIFICADETALLE INTO @PIB_INDICEB
			
			END
			
			CLOSE CUR_VERIFICADETALLE
			DEALLOCATE CUR_VERIFICADETALLE


		end

GO
