SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


/* en este procedimiento no se consideran desviaciones con diferente consumo, estas se tratan en otro procedimiento */
/* los numero de parte deben de pertenecer al mismo grupo generico */
CREATE PROCEDURE [dbo].[SP_ExplosionaDesviacion]
(
   @CodigoFactura int, @ExplosionParaDescargar char(1) = 'S'
)
as
   declare @fe_fecha datetime,          @canttotal decimal(38,20),    @dev_codigo int,              @dev_saldo decimal(38,20),
           @TotalaDesc decimal(38,20),  @ma_codigoNvo int,            @CANTDESCTOT decimal(38,20),  @CANTDESC decimal(38,20),
           @CONSECUTIVO INT,            @ma_noparteorig varchar(30),  @DEV_TIPOSUST char(1)
   declare @Desviaciones table(DEV_Codigo int not null, primary key(Dev_Codigo))

   select
      @fe_fecha = fe_fecha
   from FactExp
   where FE_Codigo = @CodigoFactura

/*
CB_FIELD	CB_KEYFIELD	CB_LOOKUP
DEV_TIPOSUST	A		PADRE E HIJO EMPIEZA CON
DEV_TIPOSUST	H		HIJO EMPIEZA CON
DEV_TIPOSUST	I		NO. PARTES IGUALES
DEV_TIPOSUST	P		PADRE EMPIEZA CON
*/

   -- por periodo partes iguales
   UPDATE BOM_DESCTEMP
   SET
      BOM_DESCTEMP.BST_HIJO = DESVIACION.MA_CODIGONVO
   FROM
      DESVIACION INNER JOIN
         MAESTRO MAESTRO_1 ON MAESTRO_1.MA_NOPARTE = DESVIACION.MA_NOPARTEORIG INNER JOIN
         BOM_DESCTEMP ON MAESTRO_1.MA_CODIGO = BOM_DESCTEMP.BST_HIJO INNER JOIN
         FACTEXPDET ON BOM_DESCTEMP.FED_INDICED = FACTEXPDET.FED_INDICED AND 
                       FACTEXPDET.FED_NOPARTE = DESVIACION.MA_NOPARTEPADRE
   WHERE
      (BOM_DESCTEMP.FE_CODIGO = @CodigoFactura) AND
      (DESVIACION.DEV_FECHAINI <= @fe_fecha) AND
      (DESVIACION.DEV_FECHAFIN >= @fe_fecha) and
      DESVIACION.DEV_CANTIDAD = 0 and
      DESVIACION.DEV_HABILITADO ='S' AND
      FACTEXPDET.FED_TIP_ENS <> 'C' AND
      FACTEXPDET.TI_CODIGO IN (SELECT TI_CODIGO
                               FROM CONFIGURATIPO
                               WHERE (CFT_TIPO = 'P' OR CFT_TIPO = 'S')) and
      isnull(DESVIACION.MA_NOPARTEPADRE, '') <> '' and
      DESVIACION.DEV_TIPOSUST = 'I' and
      DESVIACION.MA_CODIGONVO <> 0 and
      FACTEXPDET.FED_RETRABAJO = 'N' and
      DESVIACION.MA_CODIGONVO <> 0 and
      DESVIACION.DEV_CONSUMO <= 0
   

   -- por periodo padre empieza con
   UPDATE
      BOM_DESCTEMP
   SET 
      BOM_DESCTEMP.BST_HIJO = DESVIACION.MA_CODIGONVO
   FROM
      DESVIACION INNER JOIN
         MAESTRO MAESTRO_1 ON MAESTRO_1.MA_NOPARTE = DESVIACION.MA_NOPARTEORIG INNER JOIN
         BOM_DESCTEMP ON MAESTRO_1.MA_CODIGO = BOM_DESCTEMP.BST_HIJO INNER JOIN
         FACTEXPDET ON BOM_DESCTEMP.FED_INDICED = FACTEXPDET.FED_INDICED AND 
                       FACTEXPDET.FED_NOPARTE LIKE DESVIACION.MA_NOPARTEPADRE + '%'
   WHERE
      (BOM_DESCTEMP.FE_CODIGO = @CodigoFactura) AND
      (DESVIACION.DEV_FECHAINI <= @fe_fecha) AND
      (DESVIACION.DEV_FECHAFIN >= @fe_fecha) and
      DESVIACION.DEV_CANTIDAD = 0 and
      DESVIACION.DEV_HABILITADO = 'S' AND
      FACTEXPDET.FED_TIP_ENS <> 'C' AND
      FACTEXPDET.TI_CODIGO IN (SELECT TI_CODIGO
                               FROM CONFIGURATIPO
                               WHERE (CFT_TIPO = 'P' OR CFT_TIPO = 'S')) and
      isnull(DESVIACION.MA_NOPARTEPADRE, '') <> '' and
      DESVIACION.DEV_TIPOSUST = 'P' and
      DESVIACION.MA_CODIGONVO <> 0 and
      FACTEXPDET.FED_RETRABAJO = 'N' and
      DESVIACION.DEV_CONSUMO <= 0


   -- por periodo hijo empieza con
   UPDATE
      BOM_DESCTEMP
   SET
      BOM_DESCTEMP.BST_HIJO = DESVIACION.MA_CODIGONVO
   FROM
      DESVIACION INNER JOIN
         MAESTRO MAESTRO_1 ON MAESTRO_1.MA_NOPARTE LIKE DESVIACION.MA_NOPARTEORIG + '%' INNER JOIN
         BOM_DESCTEMP ON MAESTRO_1.MA_CODIGO = BOM_DESCTEMP.BST_HIJO INNER JOIN
         FACTEXPDET ON BOM_DESCTEMP.FED_INDICED = FACTEXPDET.FED_INDICED AND 
                       FACTEXPDET.FED_NOPARTE = DESVIACION.MA_NOPARTEPADRE
   WHERE
      (BOM_DESCTEMP.FE_CODIGO = @CodigoFactura) AND
      (DESVIACION.DEV_FECHAINI <= @fe_fecha) AND
      (DESVIACION.DEV_FECHAFIN >= @fe_fecha) and
      DESVIACION.DEV_CANTIDAD = 0 and
      DESVIACION.DEV_HABILITADO = 'S' AND
      FACTEXPDET.FED_TIP_ENS <> 'C' AND
      FACTEXPDET.TI_CODIGO IN (SELECT TI_CODIGO
                               FROM CONFIGURATIPO
                               WHERE (CFT_TIPO = 'P' OR CFT_TIPO = 'S')) and
      isnull(DESVIACION.MA_NOPARTEPADRE, '') <> '' and
      DESVIACION.DEV_TIPOSUST = 'H' and
      DESVIACION.MA_CODIGONVO <> 0 and
      FACTEXPDET.FED_RETRABAJO = 'N' and
      DESVIACION.DEV_CONSUMO <= 0


   -- por periodo ambos empiezan con
   UPDATE
      BOM_DESCTEMP
   SET
      BOM_DESCTEMP.BST_HIJO = DESVIACION.MA_CODIGONVO
   FROM
      DESVIACION INNER JOIN
         MAESTRO MAESTRO_1 ON MAESTRO_1.MA_NOPARTE LIKE DESVIACION.MA_NOPARTEORIG + '%' INNER JOIN
         BOM_DESCTEMP ON MAESTRO_1.MA_CODIGO = BOM_DESCTEMP.BST_HIJO INNER JOIN
         FACTEXPDET ON BOM_DESCTEMP.FED_INDICED = FACTEXPDET.FED_INDICED AND 
                       FACTEXPDET.FED_NOPARTE LIKE DESVIACION.MA_NOPARTEPADRE + '%'
   WHERE
      (BOM_DESCTEMP.FE_CODIGO = @CodigoFactura) AND
      (DESVIACION.DEV_FECHAINI <= @fe_fecha) AND
      (DESVIACION.DEV_FECHAFIN >= @fe_fecha) and
      DESVIACION.DEV_CANTIDAD = 0 and
      DESVIACION.DEV_HABILITADO = 'S' AND
      FACTEXPDET.FED_TIP_ENS <> 'C' AND
      FACTEXPDET.TI_CODIGO IN (SELECT TI_CODIGO
                               FROM CONFIGURATIPO
                               WHERE (CFT_TIPO = 'P' OR CFT_TIPO = 'S')) and
      isnull(DESVIACION.MA_NOPARTEPADRE, '') <> '' and
      DESVIACION.DEV_TIPOSUST = 'A' and
      DESVIACION.MA_CODIGONVO <> 0 and
      FACTEXPDET.FED_RETRABAJO = 'N' and
      DESVIACION.DEV_CONSUMO <= 0


   -- por cantidad y periodo
   if @ExplosionParaDescargar = 'S'
      begin
         -- nos. de partes iguales / hijo empieza con
         insert into @Desviaciones
         select DEV_Codigo
         FROM    DESVIACION
         WHERE
            (DEV_FECHAINI <= @fe_fecha) AND
            (DEV_FECHAFIN >= @fe_fecha) and
            MA_NOPARTEORIG IN
               (SELECT MA_NOPARTE
                FROM MAESTRO
                WHERE
                   MA_CODIGO IN 
                      (SELECT BST_HIJO
                       FROM
                          BOM_DESCTEMP inner join
                             FactExpDet on FactExpDet.fed_indiced = BOM_DESCTEMP.fed_indiced
                       WHERE
                          BOM_DESCTEMP.FE_CODIGO = @CodigoFactura AND
                          FACTEXPDET.FED_TIP_ENS <> 'C' AND
                          FACTEXPDET.TI_CODIGO IN (SELECT TI_CODIGO
                                                   FROM CONFIGURATIPO
                                                   WHERE
                                                      (CFT_TIPO = 'P' OR CFT_TIPO = 'S')) and
                          FACTEXPDET.FED_RETRABAJO = 'N' and
                          FactExpDet.FED_NOPARTE = DESVIACION.MA_NOPARTEPADRE
                       GROUP BY BST_HIJO)) and
            MA_NOPARTEORIG <> MA_NOPARTENVO AND
            DEV_SALDO > 0 and
            DEV_HABILITADO = 'S' and
            (DESVIACION.DEV_TIPOSUST = 'I' or DESVIACION.DEV_TIPOSUST = 'H')	and
            isnull(DESVIACION.MA_NOPARTEPADRE, '') <> '' and
            MA_CODIGONVO <> 0 and
            DESVIACION.DEV_CONSUMO <= 0

         while exists(select * from @Desviaciones)
            BEGIN
               select top 1
                  @dev_codigo     = Desviacion.DEV_Codigo,
                  @dev_saldo      = Desviacion.DEV_Saldo,
                  @ma_noparteorig = Desviacion.MA_NoParteOrig,
                  @ma_codigoNvo   = Desviacion.MA_CodigoNvo,
                  @DEV_TipoSust   = Desviacion.DEV_TipoSust
               from
                  Desviacion
               where
                  Desviacion.DEV_Codigo = (select top 1 DEV_Codigo from @Desviaciones)
	       
               exec SP_ExplosionaDesviacionDet @CodigoFactura, @dev_codigo, @dev_saldo, @ma_noparteorig,
                                               @ma_codigoNvo, @DEV_TIPOSUST, @ExplosionParaDescargar
		
		
               delete
               from @Desviaciones
               where DEV_Codigo = @dev_codigo
			
            END
		
	
	
         -- por cantidad y periodo, padre empieza con
         insert into @Desviaciones
         select DEV_Codigo
         FROM    DESVIACION 
         WHERE
            (DEV_FECHAINI <= @fe_fecha) AND (DEV_FECHAFIN >= @fe_fecha) and
            MA_NOPARTEORIG IN (SELECT MA_NOPARTE
                               FROM MAESTRO
                               WHERE
                                  MA_CODIGO IN 
                                     (SELECT BST_HIJO
                                      FROM
                                         BOM_DESCTEMP inner join
                                            FactExpDet on FactExpDet.fed_indiced = BOM_DESCTEMP.fed_indiced
                                      WHERE
                                         BOM_DESCTEMP.FE_CODIGO = @CodigoFactura AND
                                         FACTEXPDET.FED_TIP_ENS <> 'C' AND
                                         FACTEXPDET.TI_CODIGO IN (SELECT TI_CODIGO
                                                                  FROM CONFIGURATIPO
                                                                  WHERE (CFT_TIPO = 'P' OR CFT_TIPO = 'S')) and
                                         FACTEXPDET.FED_RETRABAJO = 'N' and
                                         FactExpDet.FED_NOPARTE like MA_NOPARTEPADRE + '%'
                                      GROUP BY BST_HIJO)) and
            MA_NOPARTEORIG <> MA_NOPARTENVO AND
            DEV_SALDO > 0 and
            DEV_HABILITADO = 'S' and
            (DESVIACION.DEV_TIPOSUST = 'P' or DESVIACION.DEV_TIPOSUST = 'A') and
            isnull(DESVIACION.MA_NOPARTEPADRE, '') <> '' and
            MA_CODIGONVO <> 0 and
            DESVIACION.DEV_CONSUMO <= 0

         while exists(select * from @Desviaciones)
            BEGIN
               select top 1
                  @dev_codigo     = Desviacion.DEV_Codigo,
                  @dev_saldo      = Desviacion.DEV_Saldo,
                  @ma_noparteorig = Desviacion.MA_NoParteOrig,
                  @ma_codigoNvo   = Desviacion.MA_CodigoNvo,
                  @DEV_TipoSust   = Desviacion.DEV_TipoSust
               from
                  Desviacion
               where
                  Desviacion.DEV_Codigo = (select top 1 DEV_Codigo from @Desviaciones)

	
               exec SP_ExplosionaDesviacionDet @CodigoFactura, @dev_codigo, @dev_saldo, @ma_noparteorig, @ma_codigoNvo,
                                               @DEV_TIPOSUST, @ExplosionParaDescargar
	
               delete
               from @Desviaciones
               where DEV_Codigo = @dev_codigo
	
            END
	
      end -- if @ExplosionParaDescargar = 'S'




   /*===============================================================*/
   -- por periodo sin padre
   UPDATE  BOM_DESCTEMP
   SET
      BOM_DESCTEMP.BST_HIJO = DESVIACION.MA_CODIGONVO
   FROM
      BOM_DESCTEMP INNER JOIN
         MAESTRO MAESTRO_1 INNER JOIN
         DESVIACION ON MAESTRO_1.MA_NOPARTE = DESVIACION.MA_NOPARTEORIG ON 
         BOM_DESCTEMP.BST_HIJO = MAESTRO_1.MA_CODIGO 
   WHERE
      (BOM_DESCTEMP.FE_CODIGO = @CodigoFactura) AND
      (DESVIACION.DEV_FECHAINI <= @fe_fecha) AND
      (DESVIACION.DEV_FECHAFIN >= @fe_fecha) and
      DESVIACION.DEV_CANTIDAD = 0 and
      DESVIACION.DEV_HABILITADO = 'S' and
      isnull(DESVIACION.MA_NOPARTEPADRE, '') = '' and
      DESVIACION.DEV_TIPOSUST = 'I' and
      DESVIACION.MA_CODIGONVO <> 0 AND
      BOM_DESCTEMP.FED_INDICED IN
         (SELECT FACTEXPDET.FED_INDICED
          FROM FACTEXPDET
          WHERE
             FE_CODIGO = @CodigoFactura and
             FACTEXPDET.FED_RETRABAJO = 'N' AND
             FACTEXPDET.FED_TIP_ENS <> 'C' AND
             FACTEXPDET.TI_CODIGO IN (SELECT TI_CODIGO
                                      FROM CONFIGURATIPO
                                      WHERE (CFT_TIPO = 'P' OR CFT_TIPO = 'S'))) and
      DESVIACION.DEV_CONSUMO <= 0


   -- por periodo sin padre,  hijo empieza con
   UPDATE  BOM_DESCTEMP
   SET
      BOM_DESCTEMP.BST_HIJO = DESVIACION.MA_CODIGONVO
   FROM
      BOM_DESCTEMP INNER JOIN
         MAESTRO MAESTRO_1 INNER JOIN
         DESVIACION ON MAESTRO_1.MA_NOPARTE LIKE DESVIACION.MA_NOPARTEORIG + '%' ON 
         BOM_DESCTEMP.BST_HIJO = MAESTRO_1.MA_CODIGO 
   WHERE
      (BOM_DESCTEMP.FE_CODIGO = @CodigoFactura) AND
      (DESVIACION.DEV_FECHAINI <= @fe_fecha) AND
      (DESVIACION.DEV_FECHAFIN >= @fe_fecha) and
      DESVIACION.DEV_CANTIDAD = 0 and
      DESVIACION.DEV_HABILITADO = 'S' and
      isnull(DESVIACION.MA_NOPARTEPADRE, '') = '' and
      DESVIACION.DEV_TIPOSUST = 'H' AND
      BOM_DESCTEMP.FED_INDICED IN
         (SELECT FACTEXPDET.FED_INDICED
          FROM FACTEXPDET
          WHERE
             FE_CODIGO = @CodigoFactura and
             FACTEXPDET.FED_RETRABAJO = 'N' AND
             FACTEXPDET.FED_TIP_ENS <> 'C' AND
             FACTEXPDET.TI_CODIGO IN (SELECT TI_CODIGO
                                      FROM CONFIGURATIPO
                                      WHERE (CFT_TIPO = 'P' OR CFT_TIPO = 'S'))) and
      DESVIACION.MA_CODIGONVO <> 0 and
      DESVIACION.DEV_CONSUMO <= 0


-- por cantidad y periodo sin padre
   if @ExplosionParaDescargar = 'S'
      begin

         insert into @Desviaciones
         select DEV_Codigo
            FROM     DESVIACION
            WHERE
               (DEV_FECHAINI <= @fe_fecha) AND
               (DEV_FECHAFIN >= @fe_fecha) and
               MA_NOPARTEORIG IN (SELECT MA_NOPARTE
                                  FROM MAESTRO
                                  WHERE
                                     MA_CODIGO IN 
                                        (SELECT BST_HIJO
                                         FROM BOM_DESCTEMP
                                         WHERE
                                            FE_CODIGO = @CodigoFactura AND
                                            BOM_DESCTEMP.FED_INDICED IN
                                               (SELECT FACTEXPDET.FED_INDICED
                                                FROM FACTEXPDET
                                                WHERE
                                                   FE_CODIGO = @CodigoFactura and
                                                   FACTEXPDET.FED_RETRABAJO = 'N' AND
                                                   FACTEXPDET.FED_TIP_ENS <> 'C' AND
                                                   FACTEXPDET.TI_CODIGO IN
                                                      (SELECT TI_CODIGO
                                                       FROM CONFIGURATIPO
                                                       WHERE (CFT_TIPO = 'P' OR CFT_TIPO = 'S')))
                                         GROUP BY BST_HIJO)) and
               MA_NOPARTEORIG <> MA_NOPARTENVO AND
               DEV_SALDO > 0 and
               DEV_HABILITADO = 'S' and
               (DESVIACION.DEV_TIPOSUST = 'I' or DESVIACION.DEV_TIPOSUST = 'H')	and
               isnull(DESVIACION.MA_NOPARTEPADRE, '') = '' and
               MA_CODIGONVO <> 0 and
               DESVIACION.DEV_CONSUMO <= 0
         
         while exists(select * from @Desviaciones)
            BEGIN
               select top 1
                  @dev_codigo     = Desviacion.DEV_Codigo,
                  @dev_saldo      = Desviacion.DEV_Saldo,
                  @ma_noparteorig = Desviacion.MA_NoParteOrig,
                  @ma_codigoNvo   = Desviacion.MA_CodigoNvo,
                  @DEV_TipoSust   = Desviacion.DEV_TipoSust
               from
                  Desviacion
               where
                  Desviacion.DEV_Codigo = (select top 1 DEV_Codigo from @Desviaciones)
               

               exec SP_ExplosionaDesviacionDet @CodigoFactura, @dev_codigo, @dev_saldo, @ma_noparteorig,
                                               @ma_codigoNvo, @DEV_TIPOSUST, @ExplosionParaDescargar
	
	
               delete
               from @Desviaciones
               where DEV_Codigo = @dev_codigo
            END
	 
      end -- if @ExplosionParaDescargar = 'S'



   IF @ExplosionParaDescargar <> 'S'
      delete
      from KarDesDesv
      where FE_Codigo = @CodigoFactura

GO
