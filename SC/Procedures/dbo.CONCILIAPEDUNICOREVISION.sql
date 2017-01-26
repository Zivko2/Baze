SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[CONCILIAPEDUNICOREVISION]   as


				insert into IMPCONCILIALOG(iml_mensaje)
			SELECT 'Ped.: '+left(right(pedimpconcilia.Pedimento,11),4)+'-'+right(pedimpconcilia.Pedimento,7)+' Fecha de Entrada : '+
			 '  Valor Dls: Original =' +convert(varchar(150),PEDIMP.PI_FEC_ENTPED,101)+' Archivo='+ convert(varchar(150),pedimpconcilia.EntryDate,101)
			FROM         pedimpconcilia INNER JOIN
			                      PEDIMP ON pedimpconcilia.PI_CODIGO = PEDIMP.PI_CODIGO



	-- Fecha de pago
			insert into IMPCONCILIALOG(iml_mensaje)
			SELECT 'Ped.: '+left(right(pedimpconcilia.Pedimento,11),4)+'-'+right(pedimpconcilia.Pedimento,7)+' Fecha de Pago: '+
			 '  Valor Dls: Original =' +convert(varchar(150),PEDIMP.PI_FEC_PAG,101)+' Archivo='+ convert(varchar(150),pedimpconcilia.PaymentDate,101)
			FROM         pedimpconcilia INNER JOIN
			                      PEDIMP ON pedimpconcilia.PI_CODIGO = PEDIMP.PI_CODIGO


		

	
	-- Tipo de Cambio
			insert into IMPCONCILIALOG(iml_mensaje)
			SELECT 'Ped.: '+left(right(pedimpconcilia.Pedimento,11),4)+'-'+right(pedimpconcilia.Pedimento,7)+' Tipo de Cambio: '+
			 '  Valor Dls: Original =' +convert(varchar(150),PEDIMP.PI_TIP_CAM)+' Archivo='+ convert(varchar(150),pedimpconcilia.ConversionRate)
			FROM         pedimpconcilia INNER JOIN
			                      PEDIMP ON pedimpconcilia.PI_CODIGO = PEDIMP.PI_CODIGO



		-- fletes
			insert into IMPCONCILIALOG(iml_mensaje)
			SELECT 'Ped.: '+left(right(pedimpconcilia.Pedimento,11),4)+'-'+right(pedimpconcilia.Pedimento,7)+' Fletes: '+
			 '  Valor Dls: Original =' +convert(varchar(150),PEDIMPINCREMENTA.PII_VALOR)+' Archivo='+ convert(varchar(150),pedimpconcilia.FreightCost)
			FROM         pedimpconcilia INNER JOIN
			                      PEDIMP ON pedimpconcilia.PI_CODIGO = PEDIMP.PI_CODIGO LEFT OUTER JOIN PEDIMPINCREMENTA
				ON PEDIMPINCREMENTA.PI_CODIGO=PEDIMP.PI_CODIGO
			WHERE    IC_CODIGO=2 
		


		-- seguros
			insert into IMPCONCILIALOG(iml_mensaje)
			SELECT 'Ped.: '+left(right(pedimpconcilia.Pedimento,11),4)+'-'+right(pedimpconcilia.Pedimento,7)+' Seguros: '+
			 '  Valor Dls: Original =' +convert(varchar(150),PEDIMPINCREMENTA.PII_VALOR)+' Archivo='+ convert(varchar(150),pedimpconcilia.InsuranceCost)
			FROM         pedimpconcilia INNER JOIN
			                      PEDIMP ON pedimpconcilia.PI_CODIGO = PEDIMP.PI_CODIGO LEFT OUTER JOIN PEDIMPINCREMENTA
				ON PEDIMPINCREMENTA.PI_CODIGO=PEDIMP.PI_CODIGO
			WHERE    IC_CODIGO=1		


		-- embalajes
			insert into IMPCONCILIALOG(iml_mensaje)
			SELECT 'Ped.: '+left(right(pedimpconcilia.Pedimento,11),4)+'-'+right(pedimpconcilia.Pedimento,7)+' Embalajes: '+
			 '  Valor Dls: Original =' +convert(varchar(150),PEDIMPINCREMENTA.PII_VALOR)+' Archivo='+ convert(varchar(150),pedimpconcilia.InsuranceCost)
			FROM         pedimpconcilia INNER JOIN
			                      PEDIMP ON pedimpconcilia.PI_CODIGO = PEDIMP.PI_CODIGO LEFT OUTER JOIN PEDIMPINCREMENTA
				ON PEDIMPINCREMENTA.PI_CODIGO=PEDIMP.PI_CODIGO
			WHERE    IC_CODIGO=3



		-- contribuciones a nivel pedimento

			insert into IMPCONCILIALOG(iml_mensaje)
			select 'Ped.: '+left(right(pedimpconcilia.Pedimento,11),4)+'-'+right(pedimpconcilia.Pedimento,7)+', Contribucion (Nivel Ped.): '+(select con_abrevia from contribucion where contribucion.con_clave=pedimpconciliaContribucion.ContributionCode) +
			 '  Valor Dls: Original =' +convert(varchar(150),pit_contribtotmn)+' Archivo='+ convert(varchar(150),pedimpconciliaContribucion.TotalAmount)
			FROM         PEDIMPCONTRIBUCION INNER JOIN
			                      pedimpconciliaContribucion ON PEDIMPCONTRIBUCION.PI_CODIGO = pedimpconciliaContribucion.PI_CODIGO AND 
			                      PEDIMPCONTRIBUCION.PIT_CONTRIBTOTMN <> pedimpconciliaContribucion.TotalAmount INNER JOIN
			                      pedimpconcilia ON PEDIMPCONTRIBUCION.PI_CODIGO = pedimpconcilia.PI_CODIGO 
			WHERE PEDIMPCONTRIBUCION.con_codigo in (select con_codigo from contribucion where contribucion.con_clave=pedimpconciliaContribucion.ContributionCode)


		-- facturas

			insert into IMPCONCILIALOG(iml_mensaje)
			SELECT 'Ped.: '+left(right(pedimpconcilia.Pedimento,11),4)+'-'+right(pedimpconcilia.Pedimento,7)+' Factura: '+VPEDIMPFACT.FI_FOLIO+
					' Valor Dls: Original =' +Convert(varchar(150),VPEDIMPFACT.PIF_VALDLLS) +' Archivo='+Convert(varchar(150),pedimpconciliaInvoice.ValueUSD)+', '+
			                            'Valor Mon. Ext: Original =' + Convert(varchar(150),VPEDIMPFACT.PIF_VALMONEXT) + ' Archivo='+Convert(varchar(150),pedimpconciliaInvoice.ValueForeignCurr)+')'
			FROM         VPEDIMPFACT INNER JOIN
			                      pedimpconciliaInvoice ON VPEDIMPFACT.PI_CODIGO = pedimpconciliaInvoice.PI_CODIGO AND 
			                      VPEDIMPFACT.FI_FOLIO = pedimpconciliaInvoice.InvoiceNo INNER JOIN
			                      pedimpconcilia ON pedimpconciliaInvoice.PI_CODIGO = pedimpconcilia.PI_CODIGO
			ORDER BY VPEDIMPFACT.PI_CODIGO, VPEDIMPFACT.FI_CODIGO
		



		
		--valores detalles
			
			insert into IMPCONCILIALOG(iml_mensaje)
			select 'Ped.: '+left(right(pedimpconcilia.Pedimento,11),4)+'-'+right(pedimpconcilia.Pedimento,7)+', Costo Total (USD) (partida de: '+DescSpanish+', F. Arancelaria '+ARANCEL.AR_FRACCION+
				          '  Valor Dls: Original =' +Convert(varchar(150),PEDIMPDETB.PIB_VAL_US) +' Archivo='+Convert(varchar(150),round((pedimpconciliaDet.UnitValueUSD * Quantity),2))+')'
			FROM         pedimpconciliaDet INNER JOIN
		                      PEDIMPDETB ON pedimpconciliaDet.PIB_INDICEB = PEDIMPDETB.PIB_INDICEB INNER JOIN
		                      pedimpconcilia ON pedimpconciliaDet.PI_CODIGO = pedimpconcilia.PI_CODIGO INNER JOIN
		                      PEDIMP ON pedimpconciliaDet.PI_CODIGO = PEDIMP.PI_CODIGO LEFT OUTER JOIN
		                      MEDIDA ON pedimpconciliaDet.UMHTS = MEDIDA.ME_CLA_PED  LEFT OUTER JOIN
		                      ARANCEL ON pedimpconciliaDet.HTS = ARANCEL.AR_FRACCION
			
						
	-- tasas a nivel detalle 

		insert into IMPCONCILIALOG(iml_mensaje)
		SELECT     'Ped.: '+left(right(pedimpconcilia.Pedimento,11),4)+'-'+right(pedimpconcilia.Pedimento,7)+', Contribucion IGI/IGE (partida de: '+DescSpanish+', F. Arancelaria '+ARANCEL.AR_FRACCION+
			                               '  Tasa Original =' +Convert(varchar(150),dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBPOR) +' Archivo='+Convert(varchar(150),dbo.pedimpconciliaDetContribucion.ContributionRate)+')'
		FROM         dbo.PEDIMPDETB INNER JOIN
		                      dbo.pedimpconciliaDet ON dbo.PEDIMPDETB.PIB_INDICEB = dbo.pedimpconciliaDet.PIB_INDICEB INNER JOIN
		                      dbo.pedimpconcilia ON dbo.pedimpconciliaDet.PI_CODIGO = dbo.pedimpconcilia.PI_CODIGO INNER JOIN
		                      dbo.pedimpconciliaDetContribucion ON dbo.pedimpconciliaDet.PI_CODIGO = dbo.pedimpconciliaDetContribucion.PI_CODIGO AND 
		                      dbo.pedimpconciliaDet.RecordNum = dbo.pedimpconciliaDetContribucion.RecordNum INNER JOIN
		                      dbo.PEDIMPDETBCONTRIBUCION ON dbo.PEDIMPDETB.PIB_INDICEB = dbo.PEDIMPDETBCONTRIBUCION.PIB_INDICEB LEFT OUTER JOIN		                      dbo.ARANCEL ON dbo.PEDIMPDETB.AR_IMPMX = dbo.ARANCEL.AR_CODIGO
			WHERE dbo.pedimpconciliaDetContribucion.ContributionCode = '6' AND dbo.PEDIMPDETBCONTRIBUCION.CON_CODIGO IN
			      (SELECT     CON_CODIGO FROM CONTRIBUCION WHERE CON_ABREVIA = 'IGI/IGE')







GO
