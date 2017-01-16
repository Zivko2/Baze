SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






























CREATE PROCEDURE [dbo].[SP_ExplosionaDesviacionDetFed] (@Fed_indiced int, @dev_codigo decimal(38,6), @dev_saldo decimal(38,6), @ma_noparteorig varchar(30), @ma_codigoNvo int, @TipoSust char(1)='I')   as

declare @fe_fecha datetime, @canttotal decimal(38,6), @ma_codigoorig int, @TotalaDesc decimal(38,6), @CANTDESCTOT decimal(38,6),
@CANTDESC decimal(38,6), @CONSECUTIVO INT

	SELECT @TotalaDesc=round(VBOM_DESCTEMP.CANTDESC,6) FROM VBOM_DESCTEMP WHERE VBOM_DESCTEMP.BST_HIJO =@ma_codigoorig
			AND VBOM_DESCTEMP.FED_INDICED=@Fed_indiced

	if @TotalaDesc is null
	set @TotalaDesc=0
	
	if @TotalaDesc <= @dev_saldo
	begin


		if @TipoSust='H'	 or @TipoSust='A'
			UPDATE  BOM_DESCTEMP
			SET     BOM_DESCTEMP.BST_HIJO = @ma_codigoNvo
			FROM    BOM_DESCTEMP INNER JOIN MAESTRO ON
	                                                         BOM_DESCTEMP.BST_HIJO = MAESTRO.MA_CODIGO
			WHERE MAESTRO.MA_NOPARTE like @ma_noparteorig+'%' AND
			 BOM_DESCTEMP.FED_INDICED = @Fed_indiced
		else
			UPDATE  BOM_DESCTEMP
			SET     BOM_DESCTEMP.BST_HIJO = @ma_codigoNvo
			FROM    BOM_DESCTEMP INNER JOIN MAESTRO ON
	                                                         BOM_DESCTEMP.BST_HIJO = MAESTRO.MA_CODIGO
			WHERE MAESTRO.MA_NOPARTE = @ma_noparteorig AND
			 BOM_DESCTEMP.FED_INDICED = @Fed_indiced



		UPDATE DESVIACION
		SET DEV_SALDO=DEV_SALDO-@TotalaDesc, DEV_USO_SALDO='S'
		WHERE DEV_CODIGO=@dev_codigo
	
	end
	else
	begin
		if @TipoSust='H'	 or @TipoSust='A'
		begin
		DECLARE cur_DesviacionFalta CURSOR FOR

			SELECT     CONSECUTIVO, FED_CANT * BST_INCORPOR * ISNULL(FACTCONV, 1)
			FROM         BOM_DESCTEMP INNER JOIN MAESTRO ON
                                                         BOM_DESCTEMP.BST_HIJO = MAESTRO.MA_CODIGO
			WHERE     (FED_INDICED = @Fed_indiced) AND (MAESTRO.MA_NOPARTE like @ma_noparteorig+'%')				
		end
		else
		begin
		DECLARE cur_DesviacionFalta CURSOR FOR

			SELECT     CONSECUTIVO, FED_CANT * BST_INCORPOR * ISNULL(FACTCONV, 1)
			FROM         BOM_DESCTEMP INNER JOIN MAESTRO ON
                                                         BOM_DESCTEMP.BST_HIJO = MAESTRO.MA_CODIGO
			WHERE     (FED_INDICED = @Fed_indiced) AND (MAESTRO.MA_NOPARTE = @ma_noparteorig)				

		end
		open cur_DesviacionFalta
			FETCH NEXT FROM cur_DesviacionFalta INTO @CONSECUTIVO, @CANTDESC
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN
				if @CANTDESCTOT is null
				set @CANTDESCTOT=0

				if @CANTDESCTOT <@CANTDESC
				begin
					if @CANTDESC>=@dev_saldo	
					begin	
	
						if @CANTDESC>@dev_saldo	
						begin
							--se inserta el registro para que la cantidad descargada sea igual al dev_saldo
							INSERT INTO BOM_DESCTEMP(FE_CODIGO, FED_INDICED, BST_PT, BST_ENTRAVIGOR, BST_HIJO, BST_INCORPOR, BST_DISCH, TI_CODIGO, ME_CODIGO, 
					                      FACTCONV, BST_PERINI, BST_PERFIN, ME_GEN, BST_TRANS, BST_TIPOCOSTO, BST_COSTO, MA_TIP_ENS, FED_CANT, 
					                      BST_NIVEL, BST_TIPODESC, BST_PERTENECE, BST_CONTESTATUS, FACT_INV, BST_DESCARGADO, 
					                      BST_PESO_KG)
					
							SELECT     FE_CODIGO, FED_INDICED, BST_PT, BST_ENTRAVIGOR, BST_HIJO, (@dev_saldo)/(FACTCONV*FED_CANT), BST_DISCH, TI_CODIGO, ME_CODIGO, 
					                      FACTCONV, BST_PERINI, BST_PERFIN, ME_GEN, BST_TRANS, BST_TIPOCOSTO, BST_COSTO, MA_TIP_ENS, FED_CANT, 					                      BST_NIVEL, BST_TIPODESC, BST_PERTENECE, BST_CONTESTATUS, FACT_INV, BST_DESCARGADO, 
					                      BST_PESO_KG
							FROM         BOM_DESCTEMP
							WHERE BOM_DESCTEMP.CONSECUTIVO = @CONSECUTIVO
	
							--se actualiza el registro para que la cantidad descargada sea igual a la diferencia entre CANTDESC y dev_saldo
							UPDATE  BOM_DESCTEMP
							SET     BOM_DESCTEMP.BST_INCORPOR = (@CANTDESC-@dev_saldo)/(FACTCONV*FED_CANT)
							FROM    BOM_DESCTEMP 
							WHERE BOM_DESCTEMP.CONSECUTIVO = @CONSECUTIVO
	
						end
						else	
							UPDATE  BOM_DESCTEMP
							SET     BOM_DESCTEMP.BST_HIJO = @ma_codigoNvo
							FROM    BOM_DESCTEMP 
							WHERE BOM_DESCTEMP.CONSECUTIVO = @CONSECUTIVO
		
						UPDATE DESVIACION
						SET DEV_SALDO=0, DEV_USO_SALDO='S'
						WHERE DEV_CODIGO=@dev_codigo

						set @CANTDESCTOT=@CANTDESCTOT+@CANTDESC
	
					end
					else
					begin
						UPDATE  BOM_DESCTEMP
						SET     BOM_DESCTEMP.BST_HIJO = @ma_codigoNvo
						FROM    BOM_DESCTEMP 
						WHERE BOM_DESCTEMP.CONSECUTIVO = @CONSECUTIVO								

						UPDATE DESVIACION
						SET DEV_SALDO=DEV_SALDO-@CANTDESC, DEV_USO_SALDO='S'
						WHERE DEV_CODIGO=@dev_codigo	

						set @CANTDESCTOT =@CANTDESCTOT+@CANTDESC					

					end
				end

			FETCH NEXT FROM cur_DesviacionFalta INTO @CONSECUTIVO, @CANTDESC
				
			END
				
			CLOSE cur_DesviacionFalta
			DEALLOCATE cur_DesviacionFalta
	end


GO
