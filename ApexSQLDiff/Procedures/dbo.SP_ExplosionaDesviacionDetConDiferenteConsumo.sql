SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[SP_ExplosionaDesviacionDetConDiferenteConsumo]( @CodigoFactura int, @DEV_Codigo int, @DEV_Saldo decimal(38,20), @MA_NoParteOrig varchar(30), @MA_CodigoNvo int, @TipoSust char(1)='I', @ExplosionParaDescargar char(1))    as
    declare @TotalADesc decimal(38,20),    @CantDescTot decimal(38,20),            @CantDesc decimal(38,20),
           @Consecutivo int,              @DEV_Consumo decimal(38,20),            @DEV_NoPartePadre varchar(30),
           @NvoConsecutivo int,           @PorcDescargado decimal(38,20)
   declare @BOM_DescTemp table(CONSECUTIVO int NOT NULL, BST_INCORPORORIG decimal(38, 20) NULL)

/*
CB_FIELD	CB_KEYFIELD	CB_LOOKUP
DEV_TIPOSUST	A		PADRE E HIJO EMPIEZA CON
DEV_TIPOSUST	H		HIJO EMPIEZA CON
DEV_TIPOSUST	I		NO. PARTES IGUALES
DEV_TIPOSUST	P		PADRE EMPIEZA CON
*/
   
   
   set @DEV_Consumo = (select DEV_Consumo
                       from Desviacion
                       where DEV_Codigo = @DEV_Codigo)
   
   set @DEV_NoPartePadre = (select MA_NoPartePadre
                            from Desviacion
                            where DEV_Codigo = @DEV_Codigo)

/*SELECT     FE_CODIGO, DEV_CODIGO, KAD_CANTIDAD
FROM         KARDESDESV
*/

   -- obtener el total a descargar para el número de parte original (hijo)
   if @TipoSust = 'I' or @TipoSust = 'P'
      -- en procedimiento donde no se considera el consumo, se hace el cálculo de acuerdo a la incorporación, en este
      -- caso la cantidad total a descargar debe calcularse con el nuevo consumo, además debe filtrarse por el número
      -- de parte padre, para no tomar en cuenta otros registros indeseados
      SELECT
         @TotalADesc = round(sum(FACTEXPDET.FED_CANT * ISNULL(BOM_DESCTEMP.FACTCONV, 1) * @DEV_Consumo), 20)
      FROM
         BOM_DESCTEMP inner join FACTEXPDET
            on BOM_DESCTEMP.FED_INDICED = FACTEXPDET.FED_INDICED
      WHERE
         BOM_DESCTEMP.BST_HIJO in
            (select MA_CODIGO
             from MAESTRO
             where MA_NOPARTE = @MA_NoParteOrig) AND
         BOM_DESCTEMP.FE_CODIGO = @CodigoFactura AND
         BOM_DESCTEMP.BST_DISCH = 'S' and
         ((@TipoSust = 'I' and FACTEXPDET.FED_NOPARTE = @DEV_NoPartePadre) or
          (@TipoSust = 'P' and FACTEXPDET.FED_NOPARTE like @DEV_NoPartePadre + '%'))
   else
      -- @TipoSust = 'A' or @TipoSust = 'H' (Padre e hijo empiezan con o Hijo empieza con)
      -- en procedimiento donde no se considera el consumo, se hace el cálculo de acuerdo a la incorporación, en este
      -- caso la cantidad total a descargar debe calcularse con el nuevo consumo, además debe filtrarse por el número
      -- de parte padre, para no tomar en cuenta otros registros indeseados
      SELECT
         @TotalADesc = round(sum(FACTEXPDET.FED_CANT * ISNULL(BOM_DESCTEMP.FACTCONV, 1) * @DEV_Consumo), 20)
      FROM
         BOM_DESCTEMP inner join MAESTRO
            on BOM_DESCTEMP.BST_HIJO = MAESTRO.MA_CODIGO
            inner join FACTEXPDET
            on BOM_DESCTEMP.FED_INDICED = FACTEXPDET.FED_INDICED
      WHERE
         MAESTRO.MA_NOPARTE LIKE @MA_NoParteOrig + '%' AND
         BOM_DESCTEMP.FE_CODIGO = @CodigoFactura AND
         BOM_DESCTEMP.BST_DISCH = 'S' and
         ((@TipoSust = 'H' and FACTEXPDET.FED_NOPARTE = @DEV_NoPartePadre) or
          (@TipoSust = 'A' and FACTEXPDET.FED_NOPARTE like @DEV_NoPartePadre + '%'))



   if @TotalADesc is null
      set @TotalADesc = 0
   
   if @TotalADesc <= @DEV_Saldo
      begin
         if @TotalADesc > 0
            begin
               if @TipoSust = 'H' or @TipoSust = 'A'
                  UPDATE  BOM_DESCTEMP
                  SET
                     BOM_DESCTEMP.BST_HIJO = @MA_CodigoNvo,
                     BOM_DESCTEMP.BST_INCORPOR = @DEV_Consumo
                  FROM
                     BOM_DESCTEMP INNER JOIN MAESTRO ON
                        BOM_DESCTEMP.BST_HIJO = MAESTRO.MA_CODIGO
                  WHERE
                    MAESTRO.MA_NOPARTE like @MA_NoParteOrig + '%' AND
                    BOM_DESCTEMP.FE_CODIGO = @CodigoFactura AND
                    BOM_DESCTEMP.BST_PT <> BOM_DESCTEMP.BST_HIJO
               else
                  UPDATE  BOM_DESCTEMP
                  SET
                     BOM_DESCTEMP.BST_HIJO = @MA_CodigoNvo,
                     BOM_DESCTEMP.BST_INCORPOR = @DEV_Consumo
                  FROM
                     BOM_DESCTEMP INNER JOIN MAESTRO ON
                        BOM_DESCTEMP.BST_HIJO = MAESTRO.MA_CODIGO
                  WHERE
                     MAESTRO.MA_NOPARTE = @MA_NoParteOrig AND
                     BOM_DESCTEMP.FE_CODIGO = @CodigoFactura AND
                     BOM_DESCTEMP.BST_PT <> BOM_DESCTEMP.BST_HIJO



               UPDATE DESVIACION
               SET DEV_SALDO     = DEV_SALDO - @TotalADesc,
                   DEV_USO_SALDO = 'S'
               WHERE DEV_CODIGO = @DEV_Codigo

               INSERT INTO KARDESDESV(FE_CODIGO, DEV_CODIGO, KAD_CANTIDAD)
               VALUES(@CodigoFactura, @DEV_Codigo, @TotalADesc)
		
            end
      end
   else
      -- no hay saldo suficiente en la desviación para descargar el total necesario
      begin
         if @TipoSust = 'H' or @TipoSust = 'A'
            begin
               -- guardar la incorporacion original, para su posterior restauración
               INSERT INTO @BOM_DescTemp(CONSECUTIVO, BST_INCORPORORIG)
               SELECT
                  BOM_DESCTEMP.CONSECUTIVO, BOM_DESCTEMP.BST_INCORPOR
               FROM
                  BOM_DESCTEMP INNER JOIN MAESTRO ON
                     BOM_DESCTEMP.BST_HIJO = MAESTRO.MA_CODIGO
               WHERE
                  (FE_CODIGO = @CodigoFactura) AND
                  (MAESTRO.MA_NOPARTE like @MA_NoParteOrig + '%') AND
                  BOM_DESCTEMP.BST_PT <> BOM_DESCTEMP.BST_HIJO
               
               
               -- actualización de la nueva incorporación de acuerdo al nuevo consumo
               UPDATE BOM_DESCTEMP
               SET BOM_DESCTEMP.BST_INCORPOR = @DEV_Consumo
               FROM
                  BOM_DESCTEMP INNER JOIN MAESTRO ON
                     BOM_DESCTEMP.BST_HIJO = MAESTRO.MA_CODIGO
               WHERE
                  (FE_CODIGO = @CodigoFactura) AND
                  (MAESTRO.MA_NOPARTE like @MA_NoParteOrig + '%') AND
                  BOM_DESCTEMP.BST_PT <> BOM_DESCTEMP.BST_HIJO
               
               DECLARE cur_DesviacionFalta CURSOR FOR

                  SELECT
                     CONSECUTIVO, FED_CANT * BST_INCORPOR * ISNULL(FACTCONV, 1)
                  FROM
                     BOM_DESCTEMP INNER JOIN MAESTRO ON
                        BOM_DESCTEMP.BST_HIJO = MAESTRO.MA_CODIGO
                  WHERE
                     (FE_CODIGO = @CodigoFactura) AND
                     (MAESTRO.MA_NOPARTE like @MA_NoParteOrig + '%') AND
                     BOM_DESCTEMP.BST_PT <> BOM_DESCTEMP.BST_HIJO
            end
         else
            begin
               -- guardar la incorporacion original, para su posterior restauración parcial
               INSERT INTO @BOM_DescTemp(CONSECUTIVO, BST_INCORPORORIG)
               SELECT
                  BOM_DESCTEMP.CONSECUTIVO, BOM_DESCTEMP.BST_INCORPOR
               FROM
                  BOM_DESCTEMP INNER JOIN MAESTRO ON
                     BOM_DESCTEMP.BST_HIJO = MAESTRO.MA_CODIGO
               WHERE
                  (FE_CODIGO = @CodigoFactura) AND
                  (MAESTRO.MA_NOPARTE = @MA_NoParteOrig) AND
                  BOM_DESCTEMP.BST_PT <> BOM_DESCTEMP.BST_HIJO
               
               -- actualización de la nueva incorporación de acuerdo al nuevo consumo
               UPDATE BOM_DESCTEMP
               SET BOM_DESCTEMP.BST_INCORPOR = @DEV_Consumo
               FROM
                  BOM_DESCTEMP INNER JOIN MAESTRO ON
                     BOM_DESCTEMP.BST_HIJO = MAESTRO.MA_CODIGO
               WHERE
                  (FE_CODIGO = @CodigoFactura) AND
                  (MAESTRO.MA_NOPARTE = @MA_NoParteOrig) AND
                  BOM_DESCTEMP.BST_PT <> BOM_DESCTEMP.BST_HIJO
               
               DECLARE cur_DesviacionFalta CURSOR FOR

                  SELECT
                     CONSECUTIVO, FED_CANT * BST_INCORPOR * ISNULL(FACTCONV, 1)
                  FROM
                     BOM_DESCTEMP INNER JOIN MAESTRO ON
                        BOM_DESCTEMP.BST_HIJO = MAESTRO.MA_CODIGO
                  WHERE
                     (FE_CODIGO = @CodigoFactura) AND
                     (MAESTRO.MA_NOPARTE = @MA_NoParteOrig) AND
                     BOM_DESCTEMP.BST_PT <> BOM_DESCTEMP.BST_HIJO
            end
         
         open cur_DesviacionFalta
         FETCH NEXT FROM cur_DesviacionFalta INTO @Consecutivo, @CantDesc
         WHILE (@@FETCH_STATUS = 0)
            BEGIN
               if @CantDescTot is null
                  set @CantDescTot = 0

               if @CantDescTot < @CantDesc
                  begin
                     if @CantDesc >= @DEV_Saldo
                        begin

                           if @CantDesc > @DEV_Saldo
                              begin
                                 --se inserta el registro para que la cantidad descargada sea igual al dev_saldo
                                 INSERT INTO BOM_DESCTEMP(FE_CODIGO, FED_INDICED, BST_PT, BST_ENTRAVIGOR, BST_HIJO,
                                                          BST_INCORPOR, BST_DISCH, TI_CODIGO, ME_CODIGO, FACTCONV,
                                                          BST_PERINI, BST_PERFIN, ME_GEN, BST_TRANS, BST_TIPOCOSTO,
                                                          BST_COSTO, MA_TIP_ENS, FED_CANT, BST_NIVEL, BST_TIPODESC,
                                                          BST_PERTENECE, BST_CONTESTATUS, FACT_INV, BST_DESCARGADO,
                                                          BST_PESO_KG)
                                 SELECT
                                    FE_CODIGO, FED_INDICED, BST_PT, BST_ENTRAVIGOR, @MA_CodigoNvo,
                                    -- en cálculo de nueva incorporación por desviación se usaba la fórmula
                                    --    BST_Incorpor = @DEV_Saldo / (FactConv * FED_Cant)
                                    -- pero esto afectaba negativamente cuando la parte a sustituir tenía definido un
                                    -- factor de conversión diferente de 1
                                    @DEV_Saldo / FED_CANT, BST_DISCH, TI_CODIGO, ME_CODIGO, FACTCONV,
                                    BST_PERINI, BST_PERFIN, ME_GEN, BST_TRANS, BST_TIPOCOSTO,
                                    BST_COSTO, MA_TIP_ENS, FED_CANT, BST_NIVEL, BST_TIPODESC,
                                    BST_PERTENECE, BST_CONTESTATUS, FACT_INV, BST_DESCARGADO,
                                    BST_PESO_KG
                                 FROM
                                    BOM_DESCTEMP
                                 WHERE
                                    BOM_DESCTEMP.CONSECUTIVO = @Consecutivo
                                 
                                 SELECT @NvoConsecutivo = scope_identity()
                                 
                                 SET @PorcDescargado = (SELECT BST_Incorpor / @DEV_Consumo
                                                        FROM BOM_DESCTEMP
                                                        WHERE
                                                           BOM_DESCTEMP.CONSECUTIVO = @NvoConsecutivo)
                                 /*
                                 DECLARE @NuevaCantADescargar decimal(38,20)
                                 SET @NuevaCantADescargar = (SELECT BST_IncorporOrig * (1 - @PorcDescargado)
                                                             FROM BOM_DESCTEMP
                                                             WHERE
                                                                BOM_DESCTEMP.CONSECUTIVO = @Consecutivo)
                                 PRINT @NuevaCantADescargar
                                 */
                                 
                                 -- se actualizaba el registro para que la cantidad descargada fuera igual a la diferencia
                                 -- entre CANTDESC y dev_saldo
                                 -- ahora la nueva incorporación se basa en la incorporación original, descontando lo
                                 -- descargado en el INSERT de la parte superior, de otra manera se descargaba de la
                                 -- parte original tomando en cuenta el nuevo consumo para la parte original, lo cual
                                 -- no era lo correcto
                                 UPDATE  BOM_DESCTEMP
                                 SET
                                    -- BOM_DESCTEMP.BST_INCORPOR = (@CantDesc - @DEV_Saldo) / (FACTCONV * FED_CANT)
                                    BOM_DESCTEMP.BST_INCORPOR = ObjBOM_DescTemp.BST_IncorporOrig * (1 - @PorcDescargado)
                                 FROM    BOM_DESCTEMP INNER JOIN
                                            @BOM_DescTemp AS ObjBOM_DescTemp ON BOM_DESCTEMP.CONSECUTIVO = ObjBOM_DescTemp.CONSECUTIVO
                                 WHERE
                                    BOM_DESCTEMP.CONSECUTIVO = @Consecutivo
                                 
                              end
                           else
                              UPDATE  BOM_DESCTEMP
                              SET     BOM_DESCTEMP.BST_HIJO = @MA_CodigoNvo
                              FROM    BOM_DESCTEMP 
                              WHERE BOM_DESCTEMP.CONSECUTIVO = @Consecutivo
                           
                           
                           UPDATE DESVIACION
                           SET DEV_SALDO     = 0,
                               DEV_USO_SALDO = 'S'
                           WHERE DEV_CODIGO = @DEV_Codigo

                           set @CantDescTot = @CantDescTot + @CantDesc
                           

                           INSERT INTO KARDESDESV(FE_CODIGO, DEV_CODIGO, KAD_CANTIDAD)
                           VALUES(@CodigoFactura, @DEV_Codigo, @DEV_Saldo)

                        end
                     else
                        begin
                           UPDATE  BOM_DESCTEMP
                           SET     BOM_DESCTEMP.BST_HIJO = @MA_CodigoNvo
                           FROM    BOM_DESCTEMP 
                           WHERE BOM_DESCTEMP.CONSECUTIVO = @Consecutivo

                           UPDATE DESVIACION
                           SET DEV_SALDO     = DEV_SALDO - @CantDesc,
                               DEV_USO_SALDO = 'S'
                           WHERE DEV_CODIGO = @DEV_Codigo

                           set @CantDescTot = @CantDescTot + @CantDesc


                           INSERT INTO KARDESDESV(FE_CODIGO, DEV_CODIGO, KAD_CANTIDAD)
                           VALUES(@CodigoFactura, @DEV_Codigo, @CantDesc)


                        end
                  end

               FETCH NEXT FROM cur_DesviacionFalta INTO @Consecutivo, @CantDesc
            
            END -- WHILE (@@FETCH_STATUS = 0) 
            
         CLOSE cur_DesviacionFalta
         DEALLOCATE cur_DesviacionFalta
         
      end



   IF @ExplosionParaDescargar <> 'S'
      begin
         update Desviacion
         set DEV_Saldo = DEV_Saldo + KAD_Cantidad
         from
            Desviacion inner join
               KarDesDesv on Desviacion.DEV_Codigo= KarDesDesv.DEV_Codigo
         where
            Desviacion.DEV_Codigo = @DEV_Codigo
      end
GO
