SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_VERIFICAENTRADASPO] (@FechaIni VARCHAR(11), @FechaFin VARCHAR(11))    as

declare @FechaIniMRP varchar(11), @FechaFinMRP varchar(11)

delete from TempEntradasPO where (RCPT_DATE='RCPT DATE')

	--set @FechaIniMRP=convert(varchar(11),DATEADD(day, 2, convert(datetime,@FechaIni)) ,101) 
	--set @FechaFinMRP=convert(varchar(11),DATEADD(day, 3, convert(datetime,@FechaFin)) ,101)

	set @FechaIniMRP=@FechaIni
	set @FechaFinMRP=@FechaFin


	TRUNCATE TABLE TempTotEntradasPO

	 insert into TempTotEntradasPO(NoParte, Cantidad, NoOrdenCompra, Factura, FechaEntrada, TipoFactura, Sistema ) 
	 SELECT RTRIM(LTRIM(ITEM_NUMBER)), 0-SUM(RECEIPT_QUANTITY), RTRIM(LTRIM(PO_NBR)), '', MAX(RCPT_DATE), '', 'RECO' 
	 FROM TempEntradasPO 
	 WHERE PO_NBR NOT LIKE 'MFG%'
	 GROUP BY RTRIM(LTRIM(ITEM_NUMBER)), RTRIM(LTRIM(PO_NBR))
	 ORDER BY RTRIM(LTRIM(ITEM_NUMBER))




	insert into TempTotEntradasPO(NoParte, Cantidad, NoOrdenCompra, Factura, FechaEntrada, TipoFactura, Sistema ) 
	SELECT RTRIM(LTRIM(FACTIMPDET.FID_NOPARTE)), 
	round(SUM(FACTIMPDET.FID_CANT_ST),6), 
	convert(varchar(20),RTRIM(LTRIM(isnull(FACTIMPDET.FID_ORD_COMP,'') ))), 
	FACTIMP.FI_FOLIO, 
	CONVERT(VARCHAR(10),FACTIMP.FI_FECHA,101), 
	         TFACTURA.TF_NOMBRE, 
	'INTRADE' 
	 FROM   FACTIMPDET RIGHT OUTER JOIN 
	        FACTIMP INNER JOIN 
	        TFACTURA ON FACTIMP.TF_CODIGO = TFACTURA.TF_CODIGO ON FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO 
	 WHERE  (FACTIMPDET.TI_CODIGO IN 
		
	          (SELECT TI_CODIGO FROM TIPO WHERE TI_CATEG <> '4' AND TI_CATEG <> '5' AND TI_CATEG <> '3B')) 
	        AND (LEFT(FACTIMP.FI_FOLIO, 2) <> 'RD') 
	        AND (FACTIMPDET.FID_NOPARTE IS NOT NULL) 
	        AND ((FACTIMP.FI_FECHA >= @FechaIni AND FACTIMP.FI_FECHA <= @FechaFin) 
	        OR FACTIMP.FI_FOLIO IN (SELECT Factura FROM TempTotEntradasPOInclFact)) 
	        AND FACTIMP.FI_FOLIO NOT IN (SELECT Factura FROM TempTotEntradasPOExclFact) 
	 GROUP BY FACTIMP.FI_FECHA, RTRIM(LTRIM(FACTIMPDET.FID_NOPARTE)), convert(varchar(20),RTRIM(LTRIM(isnull(FACTIMPDET.FID_ORD_COMP,'')))), FACTIMP.FI_FOLIO, TFACTURA.TF_NOMBRE




           UPDATE TempTotEntradasPO
          SET Sistema = 'NO EXISTE EN RECO'
          WHERE Sistema = 'INTRADE' 
                and rtrim(ltrim(NoParte))+'-'+rtrim(ltrim(NoOrdenCompra)) not in
                     (SELECT NoParte+'-'+NoOrdenCompra from TempTotEntradasPO where Sistema = 'RECO')



	 insert into TempTotEntradasPO(NoParte, Cantidad, NoOrdenCompra, Factura, FechaEntrada, TipoFactura, Sistema ) 
	 SELECT RTRIM(LTRIM(FACTIMPDET.FID_NOPARTE)), round(SUM(FACTIMPDET.FID_CANT_ST),6), RTRIM(LTRIM(isnull(convert(varchar(20),FACTIMPDET.FID_ORD_COMP),''))), 		
		FACTIMP.FI_FOLIO, CONVERT(VARCHAR(10),FACTIMP.FI_FECHA,101), 
	         TFACTURA.TF_NOMBRE, 'EXISTE EN INTRADE FUERA DE PERIODO'
	 FROM   FACTIMPDET RIGHT OUTER JOIN 
	        FACTIMP INNER JOIN 
	        TFACTURA ON FACTIMP.TF_CODIGO = TFACTURA.TF_CODIGO ON FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO 
	 WHERE  (FACTIMPDET.TI_CODIGO IN 
	        (SELECT TI_CODIGO FROM TIPO WHERE TI_CATEG <> '4' AND TI_CATEG <> '5' AND TI_CATEG <> '3B')) 
	        AND (LEFT(FACTIMP.FI_FOLIO, 2) <> 'RD') 
	        AND (FACTIMPDET.FID_NOPARTE IS NOT NULL)         
	        AND FACTIMP.FI_FOLIO NOT IN (SELECT Factura FROM TempTotEntradasPOExclFact) 
                     and (rtrim(ltrim(FACTIMPDET.FID_NOPARTE ))+'-'+RTRIM(LTRIM(isnull(FACTIMPDET.FID_ORD_COMP,''))) not in
                            (SELECT NoParte+'-'+NoOrdenCompra from TempTotEntradasPO where Sistema = 'INTRADE' and NoParte+'-'+NoOrdenCompra is not null)
                     and rtrim(ltrim(FACTIMPDET.FID_NOPARTE ))+'-'+RTRIM(LTRIM(isnull(FACTIMPDET.FID_ORD_COMP,''))) in
                            (SELECT NoParte+'-'+NoOrdenCompra from TempTotEntradasPO where Sistema = 'RECO' and NoParte+'-'+NoOrdenCompra is not null)
			OR (FACTIMP.FI_FOLIO IN (SELECT Factura FROM TempTotEntradasPOInclFact)))
	 GROUP BY FACTIMP.FI_FECHA, RTRIM(LTRIM(FACTIMPDET.FID_NOPARTE)), RTRIM(LTRIM(isnull(convert(varchar(20),FACTIMPDET.FID_ORD_COMP),''))), FACTIMP.FI_FOLIO, TFACTURA.TF_NOMBRE



	UPDATE TempTotEntradasPO
             SET Sistema = 'NO EXISTE EN INTRADE'
             WHERE Sistema = 'RECO' 
                and rtrim(ltrim(NoParte))+'-'+rtrim(ltrim(NoOrdenCompra)) not in
                 --    (SELECT NoParte+'-'+NoOrdenCompra from TempTotEntradasPO where Sistema = 'INTRADE' and NoParte+'-'+NoOrdenCompra is not null)
                (SELECT RTRIM(LTRIM(FACTIMPDET.FID_NOPARTE))+'-'+RTRIM(LTRIM(isnull(FACTIMPDET.FID_ORD_COMP,'')))
	         FROM   FACTIMPDET RIGHT OUTER JOIN 
	                FACTIMP ON FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO 
	         WHERE  (FACTIMPDET.TI_CODIGO IN 
	                  (SELECT TI_CODIGO FROM TIPO WHERE TI_CATEG <> '4' AND TI_CATEG <> '5' AND TI_CATEG <> '3B')) 
	                AND (LEFT(FACTIMP.FI_FOLIO, 2) <> 'RD') 
	                AND (FACTIMPDET.FID_NOPARTE IS NOT NULL) 
	                AND FACTIMP.FI_FOLIO NOT IN (SELECT Factura FROM TempTotEntradasPOExclFact) 
	         GROUP BY RTRIM(LTRIM(FACTIMPDET.FID_NOPARTE))+'-'+RTRIM(LTRIM(isnull(FACTIMPDET.FID_ORD_COMP,''))))



           UPDATE TempTotEntradasPO
          SET Sistema = 'EL ARCHIVO ESTA FUERA DE PERIODO - RECO'
          WHERE Sistema = 'INTRADE' 
                and rtrim(ltrim(NoParte))+'-'+rtrim(ltrim(NoOrdenCompra)) not in
                     (SELECT NoParte+'-'+NoOrdenCompra from TempTotEntradasPO where Sistema = 'RECO' and
		 CONVERT(DATETIME,FechaEntrada) between CONVERT(DATETIME,@FechaIniMRP) and CONVERT(DATETIME,@FechaFinMRP))


	 insert into TempTotEntradasPO(NoParte, NoOrdenCompra, Sistema, Cantidad) 
	 select NoParte, NoOrdenCompra, 'TOTAL', round(sum(Cantidad),6) as Cantidad
	 from TempTotEntradasPO 
	WHERE (Sistema ='RECO') OR (Sistema ='INTRADE') OR (Sistema ='EL ARCHIVO ESTA FUERA DE PERIODO - RECO')
		OR (Sistema ='EXISTE EN INTRADE FUERA DE PERIODO')
	 group by NoParte, NoOrdenCompra



GO
