SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_EstructuraOriginalVSEstructuraEspecial]     as

SET NOCOUNT ON 
declare @fed_indiced int, @cantidadEspecial decimal(38,6), @CantidadFactura decimal(38,6), @fed_indicedProd int
if 		exists(select controlRetrabajoSaldoPrevio.fed_indiced, sum(CRP_CantidadDescargada) CantidadEspecial, fed_cant - sum(CRP_CantidadDescargada)  CantidadFactura
		from controlRetrabajoSaldoPrevio
			left outer join factexpdet on ControlRetrabajoSaldoPrevio.fed_indiced = factexpdet.fed_indiced
		group by controlRetrabajoSaldoPrevio.fed_indiced, fed_cant)
	begin
		declare cur_descarga cursor for
		select controlRetrabajoSaldoPrevio.fed_indiced, sum(CRP_CantidadDescargada) CantidadEspecial, fed_cant - sum(CRP_CantidadDescargada)  CantidadFactura
		from controlRetrabajoSaldoPrevio
			left outer join factexpdet on ControlRetrabajoSaldoPrevio.fed_indiced = factexpdet.fed_indiced
		group by controlRetrabajoSaldoPrevio.fed_indiced, fed_cant
		open cur_descarga
		FETCH NEXT FROM cur_descarga INTO @Fed_indiced, @CantidadEspecial, @CantidadFactura
		WHILE (@@fetch_status = 0) 
		BEGIN  
			--Validar si el ti_codigo = 'S' (descargo directo)
			if exists (select fed_indiced from bomespecialdesctemp where fed_indiced = @Fed_indiced and ti_codigo = 'S')
				begin
					if exists (select fed_indiced from bomespecialdesctemp where fed_indiced = @Fed_indiced and ti_codigo = 'S' and fed_cant >= @CantidadFactura)
						begin
						print @cantidadFactura
							--Solo pasar el producto con la cantidad restante
							insert into bom_desctemp (FE_CODIGO, FED_INDICED, BST_PT, BST_ENTRAVIGOR, BST_HIJO, BST_INCORPOR, BST_DISCH, TI_CODIGO, ME_CODIGO, 
								  FACTCONV, BST_PERINI, BST_PERFIN, ME_GEN, BST_TRANS, BST_TIPOCOSTO, BST_COSTO, MA_TIP_ENS, FED_CANT, BST_NIVEL, 
								  BST_TIPODESC, BST_PERTENECE, BST_CONTESTATUS, FACT_INV, BST_DESCARGADO, BST_PESO_KG)
							select bomEspecialDescTemp.FE_CODIGO, bomEspecialDescTemp.FED_INDICED, bomEspecialDescTemp.BST_PT, bomEspecialDescTemp.BST_ENTRAVIGOR, bomEspecialDescTemp.BST_HIJO, 
									bomEspecialDescTemp.BST_INCORPOR, bomEspecialDescTemp.BST_DISCH, bomEspecialDescTemp.TI_CODIGO, bomEspecialDescTemp.ME_CODIGO, bomEspecialDescTemp.FACTCONV, 
									bomEspecialDescTemp.BST_PERINI, bomEspecialDescTemp.BST_PERFIN, bomEspecialDescTemp.ME_GEN, bomEspecialDescTemp.BST_TRANS, bomEspecialDescTemp.BST_TIPOCOSTO, 
									bomEspecialDescTemp.BST_COSTO, bomEspecialDescTemp.MA_TIP_ENS, @CantidadFactura, BST_NIVEL, bomEspecialDescTemp.BST_TIPODESC, 
									bomEspecialDescTemp.BST_PERTENECE, bomEspecialDescTemp.BST_CONTESTATUS, bomEspecialDescTemp.FACT_INV, bomEspecialDescTemp.BST_DESCARGADO, bomEspecialDescTemp.BST_PESO_KG
								from bomespecialdesctemp where fed_indiced = @Fed_indiced and ti_codigo = 'S'
						end
					else
						begin
						print 'aqui 2'
							--Pasar el producto
							insert into bom_desctemp (FE_CODIGO, FED_INDICED, BST_PT, BST_ENTRAVIGOR, BST_HIJO, BST_INCORPOR, BST_DISCH, TI_CODIGO, ME_CODIGO, 
							  FACTCONV, BST_PERINI, BST_PERFIN, ME_GEN, BST_TRANS, BST_TIPOCOSTO, BST_COSTO, MA_TIP_ENS, FED_CANT, BST_NIVEL, 
							  BST_TIPODESC, BST_PERTENECE, BST_CONTESTATUS, FACT_INV, BST_DESCARGADO, BST_PESO_KG)
							select bomEspecialDescTemp.FE_CODIGO, bomEspecialDescTemp.FED_INDICED, bomEspecialDescTemp.BST_PT, bomEspecialDescTemp.BST_ENTRAVIGOR, bomEspecialDescTemp.BST_HIJO, 
								bomEspecialDescTemp.BST_INCORPOR, bomEspecialDescTemp.BST_DISCH, bomEspecialDescTemp.TI_CODIGO, bomEspecialDescTemp.ME_CODIGO, bomEspecialDescTemp.FACTCONV, 
								bomEspecialDescTemp.BST_PERINI, bomEspecialDescTemp.BST_PERFIN, bomEspecialDescTemp.ME_GEN, bomEspecialDescTemp.BST_TRANS, bomEspecialDescTemp.BST_TIPOCOSTO, 
								bomEspecialDescTemp.BST_COSTO, bomEspecialDescTemp.MA_TIP_ENS, fed_cant, BST_NIVEL, bomEspecialDescTemp.BST_TIPODESC, 
								bomEspecialDescTemp.BST_PERTENECE, bomEspecialDescTemp.BST_CONTESTATUS, bomEspecialDescTemp.FACT_INV, bomEspecialDescTemp.BST_DESCARGADO, bomEspecialDescTemp.BST_PESO_KG
							from bomespecialdesctemp where fed_indiced = @Fed_indiced and ti_codigo = 'S'					

							insert into bom_desctemp (FE_CODIGO, FED_INDICED, BST_PT, BST_ENTRAVIGOR, BST_HIJO, BST_INCORPOR, BST_DISCH, TI_CODIGO, ME_CODIGO, 
							  FACTCONV, BST_PERINI, BST_PERFIN, ME_GEN, BST_TRANS, BST_TIPOCOSTO, BST_COSTO, MA_TIP_ENS, FED_CANT, BST_NIVEL, 
							  BST_TIPODESC, BST_PERTENECE, BST_CONTESTATUS, FACT_INV, BST_DESCARGADO, BST_PESO_KG)
							select bomEspecialDescTemp.FE_CODIGO, bomEspecialDescTemp.FED_INDICED, bomEspecialDescTemp.BST_PT, bomEspecialDescTemp.BST_ENTRAVIGOR, bomEspecialDescTemp.BST_HIJO, 
								bomEspecialDescTemp.BST_INCORPOR, bomEspecialDescTemp.BST_DISCH, bomEspecialDescTemp.TI_CODIGO, bomEspecialDescTemp.ME_CODIGO, bomEspecialDescTemp.FACTCONV, 
								bomEspecialDescTemp.BST_PERINI, bomEspecialDescTemp.BST_PERFIN, bomEspecialDescTemp.ME_GEN, bomEspecialDescTemp.BST_TRANS, bomEspecialDescTemp.BST_TIPOCOSTO, 
								bomEspecialDescTemp.BST_COSTO, bomEspecialDescTemp.MA_TIP_ENS, @CantidadFactura, BST_NIVEL, bomEspecialDescTemp.BST_TIPODESC, 
								bomEspecialDescTemp.BST_PERTENECE, bomEspecialDescTemp.BST_CONTESTATUS, bomEspecialDescTemp.FACT_INV, bomEspecialDescTemp.BST_DESCARGADO, bomEspecialDescTemp.BST_PESO_KG
							from bomespecialdesctemp where fed_indiced = @Fed_indiced and ti_codigo <> 'S'					
							
						end
				end
			else
				begin
					print 'aqui 3'
							insert into bom_desctemp (FE_CODIGO, FED_INDICED, BST_PT, BST_ENTRAVIGOR, BST_HIJO, BST_INCORPOR, BST_DISCH, TI_CODIGO, ME_CODIGO, 
								  FACTCONV, BST_PERINI, BST_PERFIN, ME_GEN, BST_TRANS, BST_TIPOCOSTO, BST_COSTO, MA_TIP_ENS, FED_CANT, BST_NIVEL, 
								  BST_TIPODESC, BST_PERTENECE, BST_CONTESTATUS, FACT_INV, BST_DESCARGADO, BST_PESO_KG)
							select bomEspecialDescTemp.FE_CODIGO, bomEspecialDescTemp.FED_INDICED, bomEspecialDescTemp.BST_PT, bomEspecialDescTemp.BST_ENTRAVIGOR, bomEspecialDescTemp.BST_HIJO, 
									bomEspecialDescTemp.BST_INCORPOR, bomEspecialDescTemp.BST_DISCH, bomEspecialDescTemp.TI_CODIGO, bomEspecialDescTemp.ME_CODIGO, bomEspecialDescTemp.FACTCONV, 
									bomEspecialDescTemp.BST_PERINI, bomEspecialDescTemp.BST_PERFIN, bomEspecialDescTemp.ME_GEN, bomEspecialDescTemp.BST_TRANS, bomEspecialDescTemp.BST_TIPOCOSTO, 
									bomEspecialDescTemp.BST_COSTO, bomEspecialDescTemp.MA_TIP_ENS, @CantidadFactura, BST_NIVEL, bomEspecialDescTemp.BST_TIPODESC, 
									bomEspecialDescTemp.BST_PERTENECE, bomEspecialDescTemp.BST_CONTESTATUS, bomEspecialDescTemp.FACT_INV, bomEspecialDescTemp.BST_DESCARGADO, bomEspecialDescTemp.BST_PESO_KG
								from bomespecialdesctemp where fed_indiced = @Fed_indiced
				end
			FETCH NEXT FROM cur_descarga INTO @Fed_indiced, @CantidadEspecial, @CantidadFactura
		END
		close cur_descarga
		deallocate cur_descarga
		
		--Inserta los de la estructura original que no tenian retrabajo
		insert into Bom_DescTemp (FE_CODIGO, FED_INDICED, BST_PT, BST_ENTRAVIGOR, BST_HIJO, BST_INCORPOR, BST_DISCH, TI_CODIGO, ME_CODIGO, 
										FACTCONV, BST_PERINI, BST_PERFIN, ME_GEN, BST_TRANS, BST_TIPOCOSTO, BST_COSTO, MA_TIP_ENS, FED_CANT, BST_NIVEL, 
										BST_TIPODESC, BST_PERTENECE, BST_CONTESTATUS, FACT_INV, BST_DESCARGADO, BST_PESO_KG)
		select  E.FE_CODIGO, E.FED_INDICED, E.BST_PT, E.BST_ENTRAVIGOR, E.BST_HIJO, E.BST_INCORPOR, E.BST_DISCH, E.TI_CODIGO, E.ME_CODIGO, 
				E.FACTCONV, E.BST_PERINI, E.BST_PERFIN, E.ME_GEN, E.BST_TRANS, E.BST_TIPOCOSTO, E.BST_COSTO, E.MA_TIP_ENS, E.FED_CANT, E.BST_NIVEL, 
				E.BST_TIPODESC, E.BST_PERTENECE, E.BST_CONTESTATUS, E.FACT_INV, E.BST_DESCARGADO, E.BST_PESO_KG
		from BomEspecialDescTemp E
			left outer join bom_desctemp O on E.fed_indiced = O.fed_indiced
		where O.consecutivo is null
		

		
	end
else
	begin
		--No habia retrabajo, por lo que devuelve la explosión original
		insert into Bom_DescTemp (FE_CODIGO, FED_INDICED, BST_PT, BST_ENTRAVIGOR, BST_HIJO, BST_INCORPOR, BST_DISCH, TI_CODIGO, ME_CODIGO, 
										FACTCONV, BST_PERINI, BST_PERFIN, ME_GEN, BST_TRANS, BST_TIPOCOSTO, BST_COSTO, MA_TIP_ENS, FED_CANT, BST_NIVEL, 
										BST_TIPODESC, BST_PERTENECE, BST_CONTESTATUS, FACT_INV, BST_DESCARGADO, BST_PESO_KG)
		select  FE_CODIGO, FED_INDICED, BST_PT, BST_ENTRAVIGOR, BST_HIJO, BST_INCORPOR, BST_DISCH, TI_CODIGO, ME_CODIGO, 
				FACTCONV, BST_PERINI, BST_PERFIN, ME_GEN, BST_TRANS, BST_TIPOCOSTO, BST_COSTO, MA_TIP_ENS, FED_CANT, BST_NIVEL, 
				BST_TIPODESC, BST_PERTENECE, BST_CONTESTATUS, FACT_INV, BST_DESCARGADO, BST_PESO_KG
		from BomEspecialDescTemp
	end

		
GO
