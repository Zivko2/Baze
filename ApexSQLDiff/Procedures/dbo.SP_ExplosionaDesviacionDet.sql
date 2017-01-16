SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



















CREATE PROCEDURE [dbo].[SP_ExplosionaDesviacionDet]
(
   @CodigoFactura int,             @dev_codigo int,            @dev_saldo decimal(38,20),
   @ma_noparteorig varchar(30),    @ma_codigoNvo int,          @TipoSust char(1)='I',
   @ExplosionParaDescargar char(1)
)
as
   declare @fe_fecha datetime,          @canttotal decimal(38,20),    @ma_codigoorig int,
           @TotalaDesc decimal(38,20),  @CANTDESCTOT decimal(38,20),  @CANTDESC decimal(38,20),
           @CONSECUTIVO INT,            @dev_NoPartePadre varchar(30)


/*
CB_FIELD	CB_KEYFIELD	CB_LOOKUP
DEV_TIPOSUST	A		PADRE E HIJO EMPIEZA CON
DEV_TIPOSUST	H		HIJO EMPIEZA CON
DEV_TIPOSUST	I		NO. PARTES IGUALES
DEV_TIPOSUST	P		PADRE EMPIEZA CON
*/

   set @dev_nopartepadre = isnull((select MA_NOPARTEPADRE
                            from Desviacion
                            where DEV_Codigo = @dev_codigo),'')

/*SELECT     FE_CODIGO, DEV_CODIGO, KAD_CANTIDAD
FROM         KARDESDESV
*/
   -- Se debe de obtener el total a descargar para el número de parte original (hijo). Tomar en cuenta que
   -- el no. de parte original también se puede indicar parcialmente con las opciones H "hijo empieza con" y A "padre
   -- e hijo empiezan con". También se incluye el tratamiento del no. de parte padre de acuerdo al tipo de sustitución
   -- definida en la desviación
	if @TipoSust = 'I' or @TipoSust = 'P'
	begin
		if @dev_nopartepadre=''
		      SELECT
		         @TotalaDesc = round(VBOM_DESCTEMP.CANTDESC, 20)
		      FROM VBOM_DESCTEMP inner join FACTEXPDET
		              on VBOM_DESCTEMP.FED_INDICED = FACTEXPDET.FED_INDICED
		      WHERE
		         VBOM_DESCTEMP.BST_HIJO in
		            (select MA_CODIGO
		             from MAESTRO
		             where MA_NOPARTE = @ma_noparteorig) AND
		         VBOM_DESCTEMP.FE_CODIGO = @CodigoFactura 
		else
		      SELECT
		         @TotalaDesc = round(VBOM_DESCTEMP.CANTDESC, 20)
		      FROM VBOM_DESCTEMP inner join FACTEXPDET
		              on VBOM_DESCTEMP.FED_INDICED = FACTEXPDET.FED_INDICED
		      WHERE
		         VBOM_DESCTEMP.BST_HIJO in
		            (select MA_CODIGO
		             from MAESTRO
		             where MA_NOPARTE = @ma_noparteorig) AND
		         VBOM_DESCTEMP.FE_CODIGO = @CodigoFactura and
		         ((@TipoSust = 'I' and FACTEXPDET.FED_NOPARTE = @dev_nopartepadre) or
		          (@TipoSust = 'P' and FACTEXPDET.FED_NOPARTE like @dev_nopartepadre + '%'))

	end
	else
	begin
		if @dev_nopartepadre=''
		      -- @TipoSust = 'H' or @TipoSust = 'A' (hijo empieza con, o padre e hijo empiezan con)
		      SELECT
		         @TotalaDesc = round(VBOM_DESCTEMP.CANTDESC, 20)
		      FROM
		         VBOM_DESCTEMP inner join
		            MAESTRO on VBOM_DESCTEMP.BST_HIJO = MAESTRO.MA_CODIGO inner join FACTEXPDET
		            on VBOM_DESCTEMP.FED_INDICED = FACTEXPDET.FED_INDICED
		      WHERE
		         MAESTRO.MA_NOPARTE LIKE @ma_noparteorig + '%' AND
		         VBOM_DESCTEMP.FE_CODIGO = @CodigoFactura 
		else
		      -- @TipoSust = 'H' or @TipoSust = 'A' (hijo empieza con, o padre e hijo empiezan con)
		      SELECT
		         @TotalaDesc = round(VBOM_DESCTEMP.CANTDESC, 20)
		      FROM
		         VBOM_DESCTEMP inner join
		            MAESTRO on VBOM_DESCTEMP.BST_HIJO = MAESTRO.MA_CODIGO inner join FACTEXPDET
		            on VBOM_DESCTEMP.FED_INDICED = FACTEXPDET.FED_INDICED
		      WHERE
		         MAESTRO.MA_NOPARTE LIKE @ma_noparteorig + '%' AND
		         VBOM_DESCTEMP.FE_CODIGO = @CodigoFactura and
		         ((@TipoSust = 'H' and FACTEXPDET.FED_NOPARTE = @dev_nopartepadre) or
		          (@TipoSust = 'A' and FACTEXPDET.FED_NOPARTE like @dev_nopartepadre + '%'))


	end


   if @TotalaDesc is null
      set @TotalaDesc = 0
   
   if @TotalaDesc <= @dev_saldo
      begin
         if @TotalaDesc > 0
            begin
               if @TipoSust = 'H' or @TipoSust = 'A'
	       begin
		  if @dev_nopartepadre = ''
		            UPDATE  BOM_DESCTEMP
		            SET     BOM_DESCTEMP.BST_HIJO = @ma_codigoNvo
		            FROM
		               BOM_DESCTEMP INNER JOIN MAESTRO ON
		                  BOM_DESCTEMP.BST_HIJO = MAESTRO.MA_CODIGO INNER JOIN MAESTRO MAESTRO_1  ON
		                  BOM_DESCTEMP.BST_PT = MAESTRO_1.MA_CODIGO
		            WHERE
		               MAESTRO.MA_NOPARTE like @ma_noparteorig + '%' AND
		               BOM_DESCTEMP.FE_CODIGO = @CodigoFactura AND
		               BOM_DESCTEMP.BST_PT <> BOM_DESCTEMP.BST_HIJO
		  else
		            UPDATE  BOM_DESCTEMP
		            SET     BOM_DESCTEMP.BST_HIJO = @ma_codigoNvo
		            FROM
		               BOM_DESCTEMP INNER JOIN MAESTRO ON
		                  BOM_DESCTEMP.BST_HIJO = MAESTRO.MA_CODIGO INNER JOIN MAESTRO MAESTRO_1  ON
		                  BOM_DESCTEMP.BST_PT = MAESTRO_1.MA_CODIGO
		            WHERE
		               MAESTRO.MA_NOPARTE like @ma_noparteorig + '%' AND
		               BOM_DESCTEMP.FE_CODIGO = @CodigoFactura AND
		               BOM_DESCTEMP.BST_PT <> BOM_DESCTEMP.BST_HIJO AND
			         ((@TipoSust = 'H' and MAESTRO_1.MA_NOPARTE = @dev_nopartepadre) or
			          (@TipoSust = 'A' and MAESTRO_1.MA_NOPARTE like @dev_nopartepadre + '%'))

	       end
               else
	       begin
		  if @dev_nopartepadre = ''
		            UPDATE  BOM_DESCTEMP
		            SET     BOM_DESCTEMP.BST_HIJO = @ma_codigoNvo
		            FROM
		               BOM_DESCTEMP INNER JOIN MAESTRO ON
		                  BOM_DESCTEMP.BST_HIJO = MAESTRO.MA_CODIGO INNER JOIN MAESTRO MAESTRO_1  ON
		                  BOM_DESCTEMP.BST_PT = MAESTRO_1.MA_CODIGO
		            WHERE
		               MAESTRO.MA_NOPARTE = @ma_noparteorig AND
		               BOM_DESCTEMP.FE_CODIGO = @CodigoFactura AND
		               BOM_DESCTEMP.BST_PT <> BOM_DESCTEMP.BST_HIJO
		  else
		            UPDATE  BOM_DESCTEMP
		            SET     BOM_DESCTEMP.BST_HIJO = @ma_codigoNvo
		            FROM
		               BOM_DESCTEMP INNER JOIN MAESTRO ON
		                  BOM_DESCTEMP.BST_HIJO = MAESTRO.MA_CODIGO INNER JOIN MAESTRO MAESTRO_1  ON
		                  BOM_DESCTEMP.BST_PT = MAESTRO_1.MA_CODIGO
		            WHERE
		               MAESTRO.MA_NOPARTE = @ma_noparteorig AND
		               BOM_DESCTEMP.FE_CODIGO = @CodigoFactura AND
		               BOM_DESCTEMP.BST_PT <> BOM_DESCTEMP.BST_HIJO AND
			 ((@TipoSust = 'I' and MAESTRO_1.MA_NOPARTE = @dev_nopartepadre) or
		                (@TipoSust = 'P' and MAESTRO_1.MA_NOPARTE like @dev_nopartepadre + '%'))

	      end

         UPDATE DESVIACION
         SET DEV_SALDO     = DEV_SALDO - @TotalaDesc,
             DEV_USO_SALDO = 'S'
         WHERE DEV_CODIGO = @dev_codigo

         INSERT INTO KARDESDESV(FE_CODIGO, DEV_CODIGO, KAD_CANTIDAD)
         VALUES(@CodigoFactura, @dev_codigo, @TotalaDesc)
	end	
      end
   else
      begin
         if @TipoSust = 'H' or @TipoSust = 'A'
            begin
		if @dev_nopartepadre=''
	                  DECLARE cur_DesviacionFalta CURSOR FOR
	
	                  SELECT
	                     CONSECUTIVO, FED_CANT * BST_INCORPOR * ISNULL(FACTCONV, 1)
	                 FROM
	                  BOM_DESCTEMP INNER JOIN MAESTRO ON
	                  BOM_DESCTEMP.BST_HIJO = MAESTRO.MA_CODIGO INNER JOIN MAESTRO MAESTRO_1  ON
	                  BOM_DESCTEMP.BST_PT = MAESTRO_1.MA_CODIGO
	                  WHERE
	                     (FE_CODIGO = @CodigoFactura) AND
	                     (MAESTRO.MA_NOPARTE like @ma_noparteorig + '%') AND
	                     BOM_DESCTEMP.BST_PT <> BOM_DESCTEMP.BST_HIJO 
		else
 	                  DECLARE cur_DesviacionFalta CURSOR FOR
	
	                  SELECT
	                     CONSECUTIVO, FED_CANT * BST_INCORPOR * ISNULL(FACTCONV, 1)
	                 FROM
	                  BOM_DESCTEMP INNER JOIN MAESTRO ON
	                  BOM_DESCTEMP.BST_HIJO = MAESTRO.MA_CODIGO INNER JOIN MAESTRO MAESTRO_1  ON
	                  BOM_DESCTEMP.BST_PT = MAESTRO_1.MA_CODIGO
	                  WHERE
	                     (FE_CODIGO = @CodigoFactura) AND
	                     (MAESTRO.MA_NOPARTE like @ma_noparteorig + '%') AND
	                     BOM_DESCTEMP.BST_PT <> BOM_DESCTEMP.BST_HIJO and 
		         (MAESTRO_1.MA_NOPARTE = @dev_nopartepadre or
		          MAESTRO_1.MA_NOPARTE like @dev_nopartepadre + '%')

            end
         else
            begin
		if @dev_nopartepadre=''
	               DECLARE cur_DesviacionFalta CURSOR FOR
	
	                  SELECT
	                     CONSECUTIVO, FED_CANT * BST_INCORPOR * ISNULL(FACTCONV, 1)
	                FROM
	                  BOM_DESCTEMP INNER JOIN MAESTRO ON
	                  BOM_DESCTEMP.BST_HIJO = MAESTRO.MA_CODIGO INNER JOIN MAESTRO MAESTRO_1  ON
	                  BOM_DESCTEMP.BST_PT = MAESTRO_1.MA_CODIGO
	                  WHERE
	                     (FE_CODIGO = @CodigoFactura) AND
	                     (MAESTRO.MA_NOPARTE = @ma_noparteorig) AND
	                     BOM_DESCTEMP.BST_PT <> BOM_DESCTEMP.BST_HIJO
		else
	               DECLARE cur_DesviacionFalta CURSOR FOR
	
	                  SELECT
	                     CONSECUTIVO, FED_CANT * BST_INCORPOR * ISNULL(FACTCONV, 1)
	                FROM
	                  BOM_DESCTEMP INNER JOIN MAESTRO ON
	                  BOM_DESCTEMP.BST_HIJO = MAESTRO.MA_CODIGO INNER JOIN MAESTRO MAESTRO_1  ON
	                  BOM_DESCTEMP.BST_PT = MAESTRO_1.MA_CODIGO
	                  WHERE
	                     (FE_CODIGO = @CodigoFactura) AND
	                     (MAESTRO.MA_NOPARTE = @ma_noparteorig) AND
	                     BOM_DESCTEMP.BST_PT <> BOM_DESCTEMP.BST_HIJO and
		         (MAESTRO_1.MA_NOPARTE = @dev_nopartepadre or
		          MAESTRO_1.MA_NOPARTE like @dev_nopartepadre + '%')

            end
         
         open cur_DesviacionFalta
         FETCH NEXT FROM cur_DesviacionFalta INTO @CONSECUTIVO, @CANTDESC
         WHILE (@@FETCH_STATUS = 0)
            BEGIN
               if @CANTDESCTOT is null
                  set @CANTDESCTOT = 0

               if @CANTDESCTOT < @CANTDESC
                  begin
                     if @CANTDESC >= @dev_saldo	
                        begin

                           if @CANTDESC > @dev_saldo	
                              begin
                                 --se inserta el registro para que la cantidad descargada sea igual al dev_saldo
                                 INSERT INTO BOM_DESCTEMP(FE_CODIGO, FED_INDICED, BST_PT, BST_ENTRAVIGOR, BST_HIJO,
                                                          BST_INCORPOR, BST_DISCH, TI_CODIGO, ME_CODIGO, FACTCONV,
                                                          BST_PERINI, BST_PERFIN, ME_GEN, BST_TRANS, BST_TIPOCOSTO,
                                                          BST_COSTO, MA_TIP_ENS, FED_CANT, BST_NIVEL, BST_TIPODESC,
                                                          BST_PERTENECE, BST_CONTESTATUS, FACT_INV, BST_DESCARGADO,
                                                          BST_PESO_KG)
                                 SELECT
                                    FE_CODIGO, FED_INDICED, BST_PT, BST_ENTRAVIGOR, @ma_codigoNvo, (@dev_saldo)/(FACTCONV*FED_CANT),
                                    BST_DISCH, TI_CODIGO, ME_CODIGO, FACTCONV,
                                    BST_PERINI, BST_PERFIN, ME_GEN, BST_TRANS, BST_TIPOCOSTO,
                                    BST_COSTO, MA_TIP_ENS, FED_CANT, BST_NIVEL, BST_TIPODESC,
                                    BST_PERTENECE, BST_CONTESTATUS, FACT_INV, BST_DESCARGADO,
                                    BST_PESO_KG
                                 FROM
                                    BOM_DESCTEMP
                                 WHERE
                                    BOM_DESCTEMP.CONSECUTIVO = @CONSECUTIVO

														
	
                                 --se actualiza el registro para que la cantidad descargada sea igual a la diferencia
                                 -- entre CANTDESC y dev_saldo
                                 UPDATE  BOM_DESCTEMP
                                 SET
                                    BOM_DESCTEMP.BST_INCORPOR = (@CANTDESC - @dev_saldo)/(FACTCONV * FED_CANT)
                                 FROM    BOM_DESCTEMP 
                                 WHERE
                                    BOM_DESCTEMP.CONSECUTIVO = @CONSECUTIVO
	
                              end
                           else	
                              UPDATE  BOM_DESCTEMP
                              SET     BOM_DESCTEMP.BST_HIJO = @ma_codigoNvo
                              FROM    BOM_DESCTEMP 
                              WHERE BOM_DESCTEMP.CONSECUTIVO = @CONSECUTIVO
		

                           UPDATE DESVIACION
                           SET DEV_SALDO     = 0,
                               DEV_USO_SALDO = 'S'
                           WHERE DEV_CODIGO=@dev_codigo

                           set @CANTDESCTOT = @CANTDESCTOT + @CANTDESC
	

                           INSERT INTO KARDESDESV(FE_CODIGO, DEV_CODIGO, KAD_CANTIDAD)
                           VALUES(@CodigoFactura, @dev_codigo, @dev_saldo)

                        end
                     else
                        begin
                           UPDATE  BOM_DESCTEMP
                           SET     BOM_DESCTEMP.BST_HIJO = @ma_codigoNvo
                           FROM    BOM_DESCTEMP 
                           WHERE BOM_DESCTEMP.CONSECUTIVO = @CONSECUTIVO								

                           UPDATE DESVIACION
                           SET DEV_SALDO     = DEV_SALDO - @CANTDESC,
                               DEV_USO_SALDO = 'S'
                           WHERE DEV_CODIGO = @dev_codigo

                           set @CANTDESCTOT = @CANTDESCTOT + @CANTDESC					


                           INSERT INTO KARDESDESV(FE_CODIGO, DEV_CODIGO, KAD_CANTIDAD)
                           VALUES(@CodigoFactura, @dev_codigo, @CANTDESC)


                        end
                  end

               FETCH NEXT FROM cur_DesviacionFalta INTO @CONSECUTIVO, @CANTDESC
	
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
