SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE ActualizarTReporte   as

/*Yolanda 18-julio-2005  */
declare  @ConfiguraClavePed Int,
@ConfiguraTEmbarque Int, 
@ConfiguraTFaCt Int, @ConfiguraTipo Int, 
@ConfiguraTMovimiento Int



Insert into clavepedIdentifica (CP_CODIGO,IDE_CODIGO,IDE_NIVEL,CP_MOVIMIENTO,CP_COMPLEMENTO)
SELECT     dbo.CLAVEPED.CP_CODIGO, dbo.IDENTIFICA.IDE_CODIGO, Original.dbo.CLAVEPEDIDENTIFICA.IDE_NIVEL, 
                      Original.dbo.CLAVEPEDIDENTIFICA.CP_MOVIMIENTO, Original.dbo.CLAVEPEDIDENTIFICA.CP_COMPLEMENTO
FROM  Original.dbo.CLAVEPEDIDENTIFICA 
INNER JOIN Original.dbo.CLAVEPED ON Original.dbo.CLAVEPEDIDENTIFICA.CP_CODIGO = Original.dbo.CLAVEPED.CP_CODIGO 
INNER JOIN Original.dbo.identifica ON Original.dbo.CLAVEPEDIDENTIFICA.ide_CODIGO = Original.dbo.identifica.ide_CODIGO 
INNER JOIN dbo.CLAVEPED ON Original.dbo.CLAVEPED.CP_Clave = dbo.CLAVEPED.CP_Clave 
INNER JOIN dbo.identifica ON (Original.dbo.IDENTIFICA.ide_Clave = dbo.identifica.ide_Clave 
	   and  Original.dbo.IDENTIFICA.ide_nivel = dbo.identifica.ide_nivel
	   and  Original.dbo.IDENTIFICA.ide_identPerm = dbo.identifica.ide_identPerm)
where not Original.dbo.CLAVEPED.cp_clave 
      +'-'+ convert(varchar(10),Original.dbo.identifica.ide_clave)  
      +'-'+ convert(varchar(10),Original.dbo.CLAVEPEDIDENTIFICA.ide_nivel)  
      +'-'+ convert(varchar(10),Original.dbo.CLAVEPEDIDENTIFICA.cp_movimiento) 
in (
	select dbo.CLAVEPED.cp_clave 
	      +'-'+ convert(varchar(10), dbo.identifica.ide_clave)  
	      +'-'+ convert(varchar(10),dbo.clavepedidentifica.ide_nivel)  
	      +'-'+ convert(varchar(10),dbo.clavepedidentifica.cp_movimiento) 
	from dbo.clavepedidentifica
	inner join dbo.claveped on dbo.clavepedidentifica.cp_codigo = dbo.claveped.cp_codigo
	inner join dbo.identifica on dbo.clavepedidentifica.ide_codigo = dbo.identifica.ide_codigo
    )





/*Nota: (10/feb/05)
Las tablas que NO TIENEN IDENTITY deben de ponerse en este script y no en el codigo del Actualizador
La condicion IF se tiene que repetir para que inicie el contador de la tabla en 1 y no repita la info el reporte de Etiquetas
*/

if not exists(select fst_codigo from imprimeetiquetas)
begin
    DELETE FROM IMPRIMEETIQUETAS
    dbcc checkident (imprimeetiquetas, reseed, 0)
    declare @CONTADOR int
    set @CONTADOR=1		
    WHILE (@CONTADOR<101)
    BEGIN
     	INSERT INTO IMPRIMEETIQUETAS(FST_CODIGO)
     	VALUES(1)
        SET @CONTADOR=@CONTADOR+1
    END	
end
/*GO*/

delete from imprimeetiquetas
/*GO*/

if not exists(select fst_codigo from imprimeetiquetas)
begin
    DELETE FROM IMPRIMEETIQUETAS
    dbcc checkident (imprimeetiquetas, reseed, 0)
    declare @CONTADOR_eti int
    set @CONTADOR_eti=1		
    WHILE (@CONTADOR_eti<101)
    BEGIN
     	INSERT INTO IMPRIMEETIQUETAS(FST_CODIGO)
     	VALUES(1)
        SET @CONTADOR_eti=@CONTADOR_eti+1
    END	
end
/*GO*/



/* Nota : 
Yolanda 17-feb-05
 El sig codigo es para actualizar algunas tablas que inician con 'REL' o con 'CONFIG'
===================================================================================================
===================================================================================================
===================UPDATES DE LAS TABLAS QUE INICIAN CON "CONFIGURA" ==============================
===================================================================================================
===================================================================================================
*/

/*Yolanda 18-julio-2005  */
UPDATE CONFIGURACLAVEPED
SET     CONFIGURACLAVEPED.CCP_TIPO=CONFIGURACLAVEPED_1.CCP_TIPO
FROM         CONFIGURACLAVEPED INNER JOIN
                      CLAVEPED INNER JOIN
                      Original.dbo.CONFIGURACLAVEPED CONFIGURACLAVEPED_1 INNER JOIN
                      Original.dbo.CLAVEPED CLAVEPED_1 ON CONFIGURACLAVEPED_1.CP_CODIGO = CLAVEPED_1.CP_CODIGO ON 
                      CLAVEPED.CP_CLAVE = CLAVEPED_1.CP_CLAVE ON CONFIGURACLAVEPED.CP_CODIGO = CLAVEPED.CP_CODIGO


Insert INTO CONFIGURACLAVEPED (CP_CODIGO, CCP_TIPO)
SELECT     dbo.CLAVEPED.CP_CODIGO, Original.dbo.CONFIGURACLAVEPED.CCP_TIPO
FROM         dbo.CLAVEPED INNER JOIN
                      Original.dbo.CONFIGURACLAVEPED INNER JOIN
                      Original.dbo.CLAVEPED ON Original.dbo.CONFIGURACLAVEPED.CP_CODIGO = Original.dbo.CLAVEPED.CP_CODIGO ON 
                      dbo.CLAVEPED.CP_CLAVE = Original.dbo.CLAVEPED.CP_CLAVE
WHERE     (NOT (dbo.CLAVEPED.CP_CODIGO IN
                          (SELECT     CP_CODIGO
                            FROM          CONFIGURACLAVEPED)))




/*==============*/

/*Yolanda 18-julio-2005  */
UPDATE CONFIGURATEMBARQUE
SET     CONFIGURATEMBARQUE.CFQ_TIPO=CONFIGURATEMBARQUE_1.CFQ_TIPO
FROM         TEMBARQUE INNER JOIN
                      CONFIGURATEMBARQUE ON TEMBARQUE.TQ_CODIGO = CONFIGURATEMBARQUE.TQ_CODIGO INNER JOIN
                      Original.dbo.TEMBARQUE TEMBARQUE_1 ON TEMBARQUE.TQ_NOMBRE = TEMBARQUE_1.TQ_NOMBRE INNER JOIN
                      Original.dbo.CONFIGURATEMBARQUE CONFIGURATEMBARQUE_1 ON TEMBARQUE_1.TQ_CODIGO = CONFIGURATEMBARQUE_1.TQ_CODIGO                      

Insert INTO CONFIGURATEMBARQUE (TQ_CODIGO, CFQ_TIPO)
SELECT     dbo.TEMBARQUE.TQ_CODIGO, Original.dbo.CONFIGURATEMBARQUE.CFQ_TIPO
FROM         Original.dbo.CONFIGURATEMBARQUE INNER JOIN
                      Original.dbo.TEMBARQUE ON Original.dbo.CONFIGURATEMBARQUE.TQ_CODIGO = Original.dbo.TEMBARQUE.TQ_CODIGO INNER JOIN
                      dbo.TEMBARQUE ON Original.dbo.TEMBARQUE.TQ_NOMBRE = dbo.TEMBARQUE.TQ_NOMBRE
WHERE     (NOT (dbo.TEMBARQUE.TQ_CODIGO IN
                          (SELECT     TQ_CODIGO
                            FROM          CONFIGURATEMBARQUE)))                   


/*==============*/
/*Yolanda 18-julio-2005  */

UPDATE CONFIGURATFACT
SET      CONFIGURATFACT.CFF_TIPO= CONFIGURATFACT_1.CFF_TIPO, CONFIGURATFACT.CFF_TRAT=CONFIGURATFACT_1.CFF_TRAT, CONFIGURATFACT.CFF_TIPODESCARGA=CONFIGURATFACT_1.CFF_TIPODESCARGA
FROM         CONFIGURATFACT INNER JOIN
                      TFACTURA INNER JOIN
                      Original.dbo.CONFIGURATFACT CONFIGURATFACT_1 INNER JOIN
                      Original.dbo.TFACTURA TFACTURA_1 ON CONFIGURATFACT_1.TF_CODIGO = TFACTURA_1.TF_CODIGO ON 
                      TFACTURA.TF_NOMBRE = TFACTURA_1.TF_NOMBRE AND TFACTURA.TF_NOMBRE = TFACTURA_1.TF_NOMBRE ON 
                      CONFIGURATFACT.TF_CODIGO = TFACTURA.TF_CODIGO
                      

insert INTO CONFIGURATFACT  (CFF_TIPO, TF_CODIGO, CFF_TRAT, CFF_TIPODESCARGA)
SELECT     Original.dbo.CONFIGURATFACT.CFF_TIPO, dbo.TFACTURA.TF_CODIGO, Original.dbo.CONFIGURATFACT.CFF_TRAT, 
                      Original.dbo.CONFIGURATFACT.CFF_TIPODESCARGA
FROM         Original.dbo.CONFIGURATFACT INNER JOIN
                      Original.dbo.TFACTURA ON Original.dbo.CONFIGURATFACT.TF_CODIGO = Original.dbo.TFACTURA.TF_CODIGO INNER JOIN
                      dbo.TFACTURA ON Original.dbo.TFACTURA.TF_NOMBRE = dbo.TFACTURA.TF_NOMBRE
WHERE     (NOT (dbo.TFACTURA.TF_CODIGO IN
                          (SELECT     TF_CODIGO
                            FROM          CONFIGURATFACT)))
                      


/*==============*/


/*Yolanda 18-julio-2005  */
UPDATE CONFIGURATIPO
SET     CONFIGURATIPO.CFT_TIPO=CONFIGURATIPO_1.CFT_TIPO, CONFIGURATIPO.CFT_COSTSUB=CONFIGURATIPO_1.CFT_COSTSUB
FROM         CONFIGURATIPO INNER JOIN
                      TIPO INNER JOIN
                      Original.dbo.CONFIGURATIPO CONFIGURATIPO_1 INNER JOIN
                      Original.dbo.TIPO TIPO_1 ON CONFIGURATIPO_1.TI_CODIGO = TIPO_1.TI_CODIGO ON TIPO.TI_NOMBRE = TIPO_1.TI_NOMBRE ON 
                      CONFIGURATIPO.TI_CODIGO = TIPO.TI_CODIGO



Insert INTO CONFIGURATIPO  (TI_CODIGO, CFT_TIPO, cft_costsub)
SELECT     dbo.TIPO.TI_CODIGO, Original.dbo.CONFIGURATIPO.CFT_TIPO, Original.dbo.CONFIGURATIPO.CFT_COSTSUB
FROM         Original.dbo.CONFIGURATIPO INNER JOIN
                      Original.dbo.TIPO ON Original.dbo.CONFIGURATIPO.TI_CODIGO = Original.dbo.TIPO.TI_CODIGO INNER JOIN
                      dbo.TIPO ON Original.dbo.TIPO.TI_NOMBRE = dbo.TIPO.TI_NOMBRE
WHERE     (NOT (dbo.TIPO.TI_CODIGO IN
                          (SELECT     TI_CODIGO
                            FROM          CONFIGURATIPO)))



/*YOLANDA 16-JULIO-05*/
/*==============*/


/*Yolanda 18-julio-2005  */

UPDATE CONFIGURATMOVIMIENTO
SET     CONFIGURATMOVIMIENTO.CFM_TIPO=CONFIGURATMOVIMIENTO_1.CFM_TIPO
FROM         TMOVIMIENTO INNER JOIN
                      Original.dbo.TMOVIMIENTO TMOVIMIENTO_1 ON TMOVIMIENTO.TM_NOMBRE = TMOVIMIENTO_1.TM_NOMBRE INNER JOIN
                      Original.dbo.CONFIGURATMOVIMIENTO CONFIGURATMOVIMIENTO_1 ON 
                      TMOVIMIENTO_1.TM_CODIGO = CONFIGURATMOVIMIENTO_1.TM_CODIGO INNER JOIN
                      CONFIGURATMOVIMIENTO ON TMOVIMIENTO.TM_CODIGO = CONFIGURATMOVIMIENTO.TM_CODIGO

Insert INTO CONFIGURATMOVIMIENTO  (TM_CODIGO, CFM_TIPO)
SELECT     dbo.TMOVIMIENTO.TM_CODIGO, Original.dbo.CONFIGURATMOVIMIENTO.CFM_TIPO
FROM         Original.dbo.CONFIGURATMOVIMIENTO INNER JOIN
                      Original.dbo.TMOVIMIENTO ON Original.dbo.CONFIGURATMOVIMIENTO.TM_CODIGO = Original.dbo.TMOVIMIENTO.TM_CODIGO INNER JOIN
                      dbo.TMOVIMIENTO ON Original.dbo.TMOVIMIENTO.TM_NOMBRE = dbo.TMOVIMIENTO.TM_NOMBRE
WHERE     (NOT (dbo.TMOVIMIENTO.TM_CODIGO IN
                          (SELECT     TM_CODIGO
                            FROM          CONFIGURATMOVIMIENTO)))



/*===================================================================================================
===================================================================================================
===================BORRAR Y UPDATES DE LAS TABLAS QUE INICIAN CON "REL" ===========================
===================================================================================================
===================================================================================================
 Las tablas afectadas fueron: CONFIGURATIEMPO,RELTFACTCLAPED,RELTFACTTEMBAR,RELTEMBTIPO,RELTCOMPRATIPO,RELTCOMPRATEMBAR,RELTRECIBETIPO,RELCLAVEPEDREG
*/

/*
--Yolanda Avila (16-Dic-2008)
--Esta parte se comento ya que no debe borrar la información, solo debe agregar la que le hace falta
DELETE FROM RELTFACTCLAPED WHERE CP_CODIGO IN
(SELECT CP_CODIGO FROM CLAVEPED WHERE CP_CLAVE IN
(SELECT     ORIGINAL.dbo.CLAVEPED.CP_CLAVE
FROM         ORIGINAL.dbo.RELTFACTCLAPED INNER JOIN
                      ORIGINAL.dbo.CLAVEPED ON ORIGINAL.dbo.RELTFACTCLAPED.CP_CODIGO = ORIGINAL.dbo.CLAVEPED.CP_CODIGO))
*/


INSERT INTO RELTFACTCLAPED(CP_CODIGO, TF_CODIGO)
SELECT     dbo.CLAVEPED.CP_CODIGO, dbo.TFACTURA.TF_CODIGO
FROM         dbo.TFACTURA 
		      INNER JOIN dbo.CLAVEPED 
                      INNER JOIN Original.dbo.RELTFACTCLAPED RELTFACTCLAPED_1 
                      INNER JOIN Original.dbo.TFACTURA TFACTURA_1 ON RELTFACTCLAPED_1.TF_CODIGO = TFACTURA_1.TF_CODIGO 
                      INNER JOIN Original.dbo.CLAVEPED CLAVEPED_1 ON RELTFACTCLAPED_1.CP_CODIGO = CLAVEPED_1.CP_CODIGO 
                      		ON dbo.CLAVEPED.CP_CLAVE = CLAVEPED_1.CP_CLAVE 
                      		ON dbo.TFACTURA.TF_NOMBRE = TFACTURA_1.TF_NOMBRE
WHERE CONVERT(VARCHAR(20),dbo.CLAVEPED.CP_CODIGO)+'-'+ CONVERT(VARCHAR(20),dbo.TFACTURA.TF_CODIGO) NOT IN
(SELECT CONVERT(VARCHAR(20),RELTFACTCLAPEDNVO.CP_CODIGO)+'-'+ CONVERT(VARCHAR(20),RELTFACTCLAPEDNVO.TF_CODIGO)
FROM RELTFACTCLAPED AS RELTFACTCLAPEDNVO)



/*                      
--Yolanda Avila (16-Dic-2008)
--Esta parte se comento ya que no debe borrar la información, solo debe agregar la que le hace falta
DELETE FROM RELTFACTTEMBAR WHERE TF_CODIGO IN
(SELECT TF_CODIGO FROM TFACTURA WHERE TF_NOMBRE IN
 (SELECT     original.dbo.TFACTURA.TF_NOMBRE
FROM         original.dbo.RELTFACTTEMBAR INNER JOIN
                      original.dbo.TFACTURA ON original.dbo.RELTFACTTEMBAR.TF_CODIGO = original.dbo.TFACTURA.TF_CODIGO))



INSERT INTO RELTFACTTEMBAR (TF_CODIGO,TQ_CODIGO,CP_CODIGO)
SELECT     TFACTURA.TF_CODIGO, TEMBARQUE.TQ_CODIGO, (SELECT     CLAVEPED.CP_CODIGO  FROM  CLAVEPED INNER JOIN  Original.dbo.CLAVEPED CLAVEPED_1 ON CLAVEPED.CP_CLAVE = CLAVEPED_1.CP_CLAVE   WHERE      claveped_1.cp_codigo = RELTFACTTEMBAR_1.CP_CODIGO)
FROM  TEMBARQUE 
      INNER JOIN Original.dbo.RELTFACTTEMBAR RELTFACTTEMBAR_1 
      INNER JOIN Original.dbo.TEMBARQUE TEMBARQUE_1 ON RELTFACTTEMBAR_1.TQ_CODIGO = TEMBARQUE_1.TQ_CODIGO 
      INNER JOIN Original.dbo.TFACTURA TFACTURA_1 ON RELTFACTTEMBAR_1.TF_CODIGO = TFACTURA_1.TF_CODIGO 
      INNER JOIN TFACTURA ON TFACTURA_1.TF_NOMBRE = TFACTURA.TF_NOMBRE ON TEMBARQUE.TQ_NOMBRE = TEMBARQUE_1.TQ_NOMBRE

WHERE CONVERT(VARCHAR(20),TFACTURA.TF_CODIGO)+ CONVERT(VARCHAR(20),TEMBARQUE.TQ_CODIGO) NOT IN
(SELECT CONVERT(VARCHAR(20),RELTFACTTEMBARNVO.TF_CODIGO)+ CONVERT(VARCHAR(20),RELTFACTTEMBARNVO.TQ_CODIGO)
FROM RELTFACTTEMBAR AS RELTFACTTEMBARNVO)
*/

--Yolanda Avila (16-Dic-2008)
--La parte de arriba se comento ya que no debe borrar la información, solo debe agregar la que le hace falta
INSERT INTO RELTFACTTEMBAR (TF_CODIGO,TQ_CODIGO,CP_CODIGO)
select tfactura.tf_codigo, tembarque.tq_codigo, 
	(select claveped.cp_codigo from claveped  inner join original.dbo.claveped on claveped.cp_clave = original.dbo.claveped.cp_clave where original.dbo.claveped.cp_codigo = reltfacttembar_1.cp_codigo)
from original.dbo.reltfacttembar reltfacttembar_1
inner join original.dbo.tfactura  tfactura_1 on  reltfacttembar_1.tf_codigo = tfactura_1.tf_codigo
inner join original.dbo.tembarque tembarque_1 on  reltfacttembar_1.tq_codigo = tembarque_1.tq_codigo
inner join tfactura on tfactura_1.tf_nombre = tfactura.tf_nombre 
inner join tembarque on tembarque_1.tq_nombre = tembarque.tq_nombre 
where convert(varchar(20),tfactura.tf_codigo) +'-'+ convert(varchar(20),tembarque.tq_codigo) not in 
(select convert(varchar(20),relTFTE.tf_codigo) +'-'+ convert(varchar(20),relTFTE.tq_codigo) from reltfacttembar relTFTE)



--Yolanda Avila (16-Dic-2008)
--Esta parte se comento ya que no debe borrar la información, solo debe agregar la que le hace falta
/*DELETE FROM RELTEMBTIPO WHERE TQ_CODIGO IN
(SELECT TQ_CODIGO FROM TEMBARQUE WHERE TQ_NOMBRE IN 
(SELECT      Original.dbo.TEMBARQUE.TQ_NOMBRE
FROM         Original.dbo.RELTEMBTIPO INNER JOIN
                      Original.dbo.TEMBARQUE ON Original.dbo.RELTEMBTIPO.TQ_CODIGO = Original.dbo.TEMBARQUE.TQ_CODIGO))                      
*/
INSERT INTO RELTEMBTIPO (TQ_CODIGO,TI_CODIGO)
SELECT     TEMBARQUE.TQ_CODIGO, TIPO.TI_CODIGO
FROM     TIPO  
		INNER JOIN  TEMBARQUE
		INNER JOIN  Original.dbo.RELTEMBTIPO  RELTEMBTIPO_1
		INNER JOIN  original.dbo.TIPO TIPO_1 ON RELTEMBTIPO_1.TI_CODIGO = TIPO_1.TI_CODIGO
		INNER JOIN  Original.dbo.TEMBARQUE TEMBARQUE_1 ON RELTEMBTIPO_1.TQ_CODIGO  = TEMBARQUE_1.TQ_CODIGO
		    ON TEMBARQUE.TQ_NOMBRE = TEMBARQUE_1.TQ_NOMBRE
		    ON TIPO.TI_NOMBRE  = TIPO_1.TI_NOMBRE
WHERE CONVERT(VARCHAR(20),TEMBARQUE.TQ_CODIGO)+'-'+ CONVERT(VARCHAR(20),TIPO.TI_CODIGO) NOT IN
(SELECT CONVERT(VARCHAR(20),RELTEMBTIPONVO.TQ_CODIGO)+'-'+ CONVERT(VARCHAR(20),RELTEMBTIPONVO.TI_CODIGO)
FROM RELTEMBTIPO AS RELTEMBTIPONVO)






DELETE FROM RELTCOMPRATIPO WHERE TR_CODIGO IN
(SELECT TR_CODIGO FROM TCOMPRA WHERE TR_NOMBRE IN                      
(SELECT     Original.dbo.TCOMPRA.TR_NOMBRE
FROM         Original.dbo.RELTCOMPRATIPO INNER JOIN
                      Original.dbo.TCOMPRA ON Original.dbo.RELTCOMPRATIPO.TR_CODIGO = Original.dbo.TCOMPRA.TR_CODIGO))
                    
INSERT INTO RELTCOMPRATIPO (TR_CODIGO,TI_CODIGO)
SELECT     TCOMPRA.TR_CODIGO, TIPO.TI_CODIGO
FROM     TIPO  
		INNER JOIN  TCOMPRA 
		INNER JOIN  Original.dbo.RELTCOMPRATIPO  RELTCOMPRATIPO_1
		INNER JOIN original.dbo.TIPO TIPO_1 ON RELTCOMPRATIPO_1.TI_CODIGO = TIPO_1.TI_CODIGO
		INNER JOIN  Original.dbo.TCOMPRA TCOMPRA_1 ON RELTCOMPRATIPO_1.TR_CODIGO  = TCOMPRA_1.TR_CODIGO
		    ON TCOMPRA.TR_NOMBRE = TCOMPRA_1.TR_NOMBRE
		    ON TIPO.TI_NOMBRE  = TIPO_1.TI_NOMBRE
WHERE CONVERT(VARCHAR(20),TCOMPRA.TR_CODIGO)+ CONVERT(VARCHAR(20),TIPO.TI_CODIGO) NOT IN
(SELECT CONVERT(VARCHAR(20),RELTCOMPRATIPONVO.TR_CODIGO)+ CONVERT(VARCHAR(20),RELTCOMPRATIPONVO.TI_CODIGO)
FROM RELTCOMPRATIPO AS RELTCOMPRATIPONVO)




/* objecto RELTCOMPRATEMBAR ya no existe
DELETE FROM RELTCOMPRATEMBAR WHERE TR_CODIGO IN
(SELECT TR_CODIGO FROM TCOMPRA WHERE TR_NOMBRE IN                      
(SELECT     Original.dbo.TCOMPRA.TR_NOMBRE
FROM         Original.dbo.RELTCOMPRATEMBAR INNER JOIN
                      Original.dbo.TCOMPRA ON Original.dbo.RELTCOMPRATEMBAR.TR_CODIGO = Original.dbo.TCOMPRA.TR_CODIGO))                      


INSERT INTO RELTCOMPRATEMBAR (TR_CODIGO,TQ_CODIGO)
SELECT     TCOMPRA.TR_CODIGO, TEMBARQUE.TQ_CODIGO
FROM     TEMBARQUE  
		INNER JOIN  TCOMPRA 
		INNER JOIN  Original.dbo.RELTCOMPRATEMBAR  RELTCOMPRATEMBAR_1
		INNER JOIN  Original.dbo.TEMBARQUE TEMBARQUE_1 ON RELTCOMPRATEMBAR_1.TQ_CODIGO  = TEMBARQUE_1.TQ_CODIGO
		INNER JOIN  Original.dbo.TCOMPRA TCOMPRA_1 ON RELTCOMPRATEMBAR_1.TR_CODIGO  = TCOMPRA_1.TR_CODIGO
		    ON TCOMPRA.TR_NOMBRE = TCOMPRA_1.TR_NOMBRE
		    ON TEMBARQUE.TQ_NOMBRE  = TEMBARQUE_1.TQ_NOMBRE
WHERE CONVERT(VARCHAR(20),TCOMPRA.TR_CODIGO)+ CONVERT(VARCHAR(20),TEMBARQUE.TQ_CODIGO) NOT IN
(SELECT CONVERT(VARCHAR(20),RELTCOMPRATEMBARNVO.TR_CODIGO)+ CONVERT(VARCHAR(20),RELTCOMPRATEMBARNVO.TQ_CODIGO)
FROM RELTCOMPRATEMBAR AS RELTCOMPRATEMBARNVO)
*/  
                      



/*Objecto RELTRECIBETIPO no existe
DELETE FROM RELTRECIBETIPO WHERE TRC_CODIGO IN
(SELECT     TRC_CODIGO FROM TRECIBE WHERE TRC_NOMBRE IN 
(SELECT     Original.dbo.TRECIBE.TRC_NOMBRE 
FROM         Original.dbo.RELTRECIBETIPO INNER JOIN
                      Original.dbo.TRECIBE ON Original.dbo.RELTRECIBETIPO.TRC_CODIGO = Original.dbo.TRECIBE.TRC_CODIGO))                      
                        

INSERT INTO RELTRECIBETIPO (TRC_CODIGO,TI_CODIGO)
SELECT     TRECIBE.TRC_CODIGO, TIPO.TI_CODIGO
FROM     TIPO  
		INNER JOIN  TRECIBE 
		INNER JOIN  Original.dbo.RELTRECIBETIPO  RELTRECIBETIPO_1
		INNER JOIN  Original.dbo.TIPO TIPO_1 ON RELTRECIBETIPO_1.TI_CODIGO  = TIPO_1.TI_CODIGO
		INNER JOIN  Original.dbo.TRECIBE TRECIBE_1 ON RELTRECIBETIPO_1.TRC_CODIGO  = TRECIBE_1.TRC_CODIGO
		    ON TRECIBE.TRC_NOMBRE = TRECIBE_1.TRC_NOMBRE
		    ON TIPO.TI_NOMBRE  = TIPO_1.TI_NOMBRE
WHERE CONVERT(VARCHAR(20),TRECIBE.TRC_CODIGO)+ CONVERT(VARCHAR(20),TIPO.TI_CODIGO) NOT IN
(SELECT CONVERT(VARCHAR(20),RELTRECIBETIPONVO.TRC_CODIGO)+ CONVERT(VARCHAR(20),RELTRECIBETIPONVO.TI_CODIGO)
FROM RELTRECIBETIPO AS RELTRECIBETIPONVO)
  
*/




/*para borrar los datos de CONFIGURATIEMPO*/
/* Este query fue comentado ya que eliminaba las que deberian ser, se cambio por el que le sigue Manuel G. 16-Oct-09
DELETE FROM CONFIGURATIEMPO WHERE CP_CODIGO IN
(SELECT CP_CODIGO FROM CLAVEPED WHERE CP_CLAVE IN
(SELECT     ORIGINAL.dbo.CLAVEPED.CP_CLAVE
FROM         ORIGINAL.dbo.CONFIGURATIEMPO INNER JOIN
                      ORIGINAL.dbo.CLAVEPED ON ORIGINAL.dbo.CONFIGURATIEMPO.CP_CODIGO = ORIGINAL.dbo.CLAVEPED.CP_CODIGO))
*/
delete configuratiempo from configuratiempo 
INNER JOIN  CLAVEPED ON CONFIGURATIEMPO.CP_CODIGO = CLAVEPED.CP_CODIGO
INNER JOIN  tipo ON CONFIGURATIEMPO.ti_CODIGO = tipo.ti_CODIGO
where CLAVEPED.CP_CLAVE +'-'+ tipo.ti_nombre  in 
  (SELECT original.dbo.CLAVEPED.CP_CLAVE+'-'+  original.dbo.tipo.ti_nombre
   FROM  original.dbo.CONFIGURATIEMPO 
   INNER JOIN  original.dbo.CLAVEPED ON original.dbo.CONFIGURATIEMPO.CP_CODIGO = original.dbo.CLAVEPED.CP_CODIGO
   INNER JOIN  original.dbo.tipo ON original.dbo.CONFIGURATIEMPO.ti_CODIGO = original.dbo.tipo.ti_CODIGO
  )

  

/* Este query fue modificado por eso fue comentado, se reemplazo por el query que le sigue
INSERT INTO CONFIGURATIEMPO (CP_CODIGO,TI_CODIGO,cot_tiempo)
SELECT     dbo.CLAVEPED.CP_CODIGO, dbo.TIPO.TI_CODIGO,configuratiempo_1.cot_tiempo 
FROM         dbo.TIPO 
		      INNER JOIN dbo.CLAVEPED 
                      INNER JOIN Original.dbo.CONFIGURATIEMPO CONFIGURATIEMPO_1 
                      INNER JOIN Original.dbo.TIPO TIPO_1 ON CONFIGURATIEMPO_1.TI_CODIGO = TIPO_1.TI_CODIGO 
                      INNER JOIN Original.dbo.CLAVEPED CLAVEPED_1 ON CONFIGURATIEMPO_1.CP_CODIGO = CLAVEPED_1.CP_CODIGO 
                      		ON dbo.CLAVEPED.CP_CLAVE = CLAVEPED_1.CP_CLAVE 
                      		ON dbo.TIPO.TI_NOMBRE = TIPO_1.TI_NOMBRE
WHERE CONVERT(VARCHAR(20),dbo.CLAVEPED.CP_CODIGO)+ CONVERT(VARCHAR(20),dbo.TIPO.TI_CODIGO) NOT IN
(SELECT CONVERT(VARCHAR(20),CONFIGURATIEMPONVO.CP_CODIGO)+ CONVERT(VARCHAR(20),CONFIGURATIEMPONVO.TI_CODIGO)
FROM CONFIGURATIEMPO AS CONFIGURATIEMPONVO)*/
  
INSERT INTO CONFIGURATIEMPO (CP_CODIGO,TI_CODIGO,cot_tiempo)
SELECT     dbo.CLAVEPED.CP_CODIGO, dbo.TIPO.TI_CODIGO,configuratiempo_1.cot_tiempo 
FROM         dbo.TIPO 
		      INNER JOIN dbo.CLAVEPED 
                      INNER JOIN Original.dbo.CONFIGURATIEMPO CONFIGURATIEMPO_1 
                      INNER JOIN Original.dbo.TIPO TIPO_1 ON CONFIGURATIEMPO_1.TI_CODIGO = TIPO_1.TI_CODIGO 
                      INNER JOIN Original.dbo.CLAVEPED CLAVEPED_1 ON CONFIGURATIEMPO_1.CP_CODIGO = CLAVEPED_1.CP_CODIGO 
                      		ON dbo.CLAVEPED.CP_CLAVE = CLAVEPED_1.CP_CLAVE 
                      		ON dbo.TIPO.TI_NOMBRE = TIPO_1.TI_NOMBRE
WHERE CONVERT(VARCHAR(20),dbo.CLAVEPED.CP_CODIGO)+'_'+ CONVERT(VARCHAR(20),dbo.TIPO.TI_CODIGO) NOT IN
(SELECT CONVERT(VARCHAR(20),CONFIGURATIEMPONVO.CP_CODIGO)+'_'+ CONVERT(VARCHAR(20),CONFIGURATIEMPONVO.TI_CODIGO)
FROM CONFIGURATIEMPO AS CONFIGURATIEMPONVO)




--Yolanda Avila (16-Dic-2008)
--Esta parte se comento ya que no debe borrar la información, solo debe agregar la que le hace falta
/*DELETE FROM RELCLAVEPEDREG WHERE CP_CODIGO IN
(SELECT CP_CODIGO FROM CLAVEPED WHERE CP_CLAVE IN
(SELECT     ORIGINAL.dbo.CLAVEPED.CP_CLAVE
FROM         ORIGINAL.dbo.RELCLAVEPEDREG INNER JOIN
                      ORIGINAL.dbo.CLAVEPED ON ORIGINAL.dbo.RELCLAVEPEDREG.CP_CODIGO = ORIGINAL.dbo.CLAVEPED.CP_CODIGO))
*/
INSERT INTO RELCLAVEPEDREG(CP_CODIGO, REG_CODIGO, REL_DEFAULT, REL_MOVIMIENTO)
SELECT     dbo.CLAVEPED.CP_CODIGO, dbo.REGIMEN.REG_CODIGO, RELCLAVEPEDREG_1.REL_DEFAULT,  RELCLAVEPEDREG_1.REL_MOVIMIENTO
FROM         dbo.REGIMEN 
		      INNER JOIN dbo.CLAVEPED 
                      INNER JOIN Original.dbo.RELCLAVEPEDREG RELCLAVEPEDREG_1 
                      INNER JOIN Original.dbo.REGIMEN REGIMEN_1 ON RELCLAVEPEDREG_1.REG_CODIGO = REGIMEN_1.REG_CODIGO 
                      INNER JOIN Original.dbo.CLAVEPED CLAVEPED_1 ON RELCLAVEPEDREG_1.CP_CODIGO = CLAVEPED_1.CP_CODIGO 
                      		ON dbo.CLAVEPED.CP_CLAVE = CLAVEPED_1.CP_CLAVE 
                      		ON dbo.REGIMEN.REG_CLAVE = REGIMEN_1.REG_CLAVE
WHERE CONVERT(VARCHAR(20),dbo.CLAVEPED.CP_CODIGO)+'-'+ CONVERT(VARCHAR(20),dbo.REGIMEN.REG_CODIGO) NOT IN
(SELECT CONVERT(VARCHAR(20),RELCLAVEPEDREGNVO.CP_CODIGO)+'-'+ CONVERT(VARCHAR(20),RELCLAVEPEDREGNVO.REG_CODIGO)
FROM RELCLAVEPEDREG AS RELCLAVEPEDREGNVO)



IF (SELECT COUNT(*) FROM CONFIGURAPEDIMENTO)=0
BEGIN
	INSERT INTO CONFIGURAPEDIMENTO(EM_CODIGO, PI_LLENAINCREMENTA, PI_LLENAPESO, PI_LLENAPERIODOBSERVA, PI_LLENASECUENCIA, PI_LLENAIDENTIFICA, 
	                      PI_LLENAPEDIMPDETB, PI_LLENACHECKPAGACONTRIB, PI_LLENAADVDETB, PI_LLENAIVADTACC, PI_LLENAIDENTIFICADET, 
	                      PI_LLENASECUENCIADETB)
	VALUES(1, 'S', 'S', 'S', 'S', 'S', 'S', 'S', 'S', 'S', 'S', 'S')
END


IF (SELECT COUNT(*) FROM CLIENTEENTIDADES)=0
BEGIN
	DECLARE @CL_MATRIZ INT
	

	INSERT INTO CLIENTEENTIDADES(TF_CODIGO, OM_TIPO)
	SELECT     TF_CODIGO, 'E'
	FROM         VTFACTURAENT
	WHERE CONVERT(VARCHAR(15),TF_CODIGO)+'E' NOT IN (SELECT CONVERT(VARCHAR(15),TF_CODIGO)+'E' FROM CLIENTEENTIDADES)
	
	
	
	INSERT INTO CLIENTEENTIDADES(TF_CODIGO, OM_TIPO)
	SELECT     TF_CODIGO, 'S'
	FROM         VTFACTURASAL
	WHERE CONVERT(VARCHAR(15),TF_CODIGO)+'S' NOT IN (SELECT CONVERT(VARCHAR(15),TF_CODIGO)+'S' FROM CLIENTEENTIDADES)
	

	
	SELECT @CL_MATRIZ=CL_MATRIZ FROM CLIENTE WHERE CL_EMPRESA='S'
	
	
	UPDATE CLIENTEENTIDADES
	SET     PR_CODIGO=@CL_MATRIZ, CL_PROD=@CL_MATRIZ, CL_VEND=@CL_MATRIZ, CL_EXP=@CL_MATRIZ, CL_EXPFIN=@CL_MATRIZ,
	CL_DESTINI=1, CL_DESTFIN=1, CL_COMP=1, CL_COMPFIN=1, CL_IMP=1
	WHERE     (OM_TIPO = 'E')
	
	
	UPDATE CLIENTEENTIDADES
	SET     PR_CODIGO=1, CL_PROD=1, CL_VEND=1, CL_EXP=1, CL_EXPFIN=1,
	CL_DESTINI=@CL_MATRIZ, CL_DESTFIN=@CL_MATRIZ, CL_COMP=@CL_MATRIZ, CL_COMPFIN=@CL_MATRIZ, CL_IMP=@CL_MATRIZ
	WHERE     (OM_TIPO = 'S')
END
GO
