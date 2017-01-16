SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_VERIFICASALIDASPO] (@FechaIni VARCHAR(11), @FechaFin VARCHAR(11), @FechaIniMRP VARCHAR(11), @FechaFinMRP VARCHAR(11))   as



delete from TempSalidasPO where (ITNBR='ITNBR' or ITNBR is null)

   /*========================= STOCK=====================*/

	TRUNCATE TABLE TempTotSalidasPOStock

	insert into TempTotSalidasPOStock(NoParte, Cantidad, NoOrden, Factura, FechaEntrada, TipoFactura, Sistema ) 
	SELECT     ITNBR, round(SUM(convert(decimal(38,6),TQTY)),6), 
		--case when SUM(convert(decimal(38,6),TQTY))<0 then round(SUM(convert(decimal(38,6),TQTY)),6) else 0-round(SUM(convert(decimal(38,6),TQTY)),6) end, 
		'0' + Substring([REFNO],4,6) AS BLDN, '', MAX(convert(varchar(11),CONVERT(DATETIME,UPDDT),101)), '', 'RECO' 
	FROM TempSalidasPO
	WHERE (CODE IS NOT NULL AND CODE <> '') AND (((TempSalidasPO.REFNO) Like '03%') AND ((TempSalidasPO.ORDNO) Like 'fascua%') AND ((TempSalidasPO.CODE)='issm'))
		and convert(decimal(38,6),TQTY)<0
	AND CONVERT(DATETIME,UPDDT) >= CONVERT(DATETIME,@FechaIniMRP) AND CONVERT(DATETIME,UPDDT)<=CONVERT(DATETIME,@FechaFinMRP)
	GROUP BY TempSalidasPO.ITNBR, TempSalidasPO.TQTY, '0' + Substring([REFNO],4,6) 




	 insert into TempTotSalidasPOStock(NoParte, Cantidad, NoOrden, Factura, FechaEntrada, TipoFactura, Sistema ) 
	 SELECT RTRIM(LTRIM(FACTEXPDET.FED_NOPARTE)), round(SUM(FACTEXPDET.FED_CANT),6), left(isnull(FACTEXPDET.FED_ORD_COMP,''),20), FACTEXP.FE_FOLIO, CONVERT(VARCHAR(11),FACTEXP.FE_FECHA,101), 
	         TFACTURA.TF_NOMBRE, 'INTRADE' 
	 FROM   FACTEXPDET RIGHT OUTER JOIN 
	        FACTEXP INNER JOIN 
	        TFACTURA ON FACTEXP.TF_CODIGO = TFACTURA.TF_CODIGO ON FACTEXPDET.FE_CODIGO = FACTEXP.FE_CODIGO 
	 WHERE   LEN(isnull(FACTEXPDET.FED_ORD_COMP,''))>=10 AND
		 (FACTEXPDET.TI_CODIGO IN 
		
	          (SELECT TI_CODIGO FROM TIPO WHERE TI_CATEG <> '4' AND TI_CATEG <> '5' AND TI_CATEG <> '3B')) 
	        AND (FACTEXPDET.FED_NOPARTE IS NOT NULL) 
	        AND ((FACTEXP.FE_FECHA >= @FechaIni AND FACTEXP.FE_FECHA <= @FechaFin) OR 
		FACTEXP.FE_FOLIO IN (SELECT Factura FROM TempTotSalidasPOInclFact)) 
	        AND FACTEXP.FE_FOLIO NOT IN (SELECT Factura FROM TempTotSalidasPOExclFact) 
	 GROUP BY FACTEXP.FE_FECHA, RTRIM(LTRIM(FACTEXPDET.FED_NOPARTE)), FACTEXPDET.FED_ORD_COMP, FACTEXP.FE_FOLIO, TFACTURA.TF_NOMBRE


           UPDATE TempTotSalidasPOStock
          SET Sistema = 'NO EXISTE EN RECO'
          WHERE Sistema = 'INTRADE' 
                and rtrim(ltrim(NoParte))+'-'+rtrim(ltrim(NoOrden)) not in
                     (SELECT NoParte+'-'+NoOrden from TempTotSalidasPOStock where Sistema = 'RECO')




         UPDATE TempTotSalidasPOStock
         SET Sistema = 'EXISTE EN INTRADE FUERA DE PERIODO'
         WHERE Sistema = 'RECO' 
                and rtrim(ltrim(NoParte))+'-'+rtrim(ltrim(NoOrden)) not in
                     (SELECT NoParte+'-'+NoOrden from TempTotSalidasPOStock where Sistema = 'INTRADE' and NoParte+'-'+NoOrden is not null)

                and rtrim(ltrim(NoParte))+'-'+rtrim(ltrim(NoOrden)) in
                (SELECT RTRIM(LTRIM(FACTEXPDET.FED_NOPARTE))+'-'+isnull(FACTEXPDET.FED_ORD_COMP,'')
	         FROM   FACTEXPDET RIGHT OUTER JOIN 
	                FACTEXP ON FACTEXPDET.FE_CODIGO = FACTEXP.FE_CODIGO 
	         WHERE  (FACTEXPDET.TI_CODIGO IN 
	                  (SELECT TI_CODIGO FROM TIPO WHERE TI_CATEG <> '4' AND TI_CATEG <> '5' AND TI_CATEG <> '3B')
		   AND LEN(isnull(FACTEXPDET.FED_ORD_COMP,''))>=10) 
	                AND (LEFT(FACTEXP.FE_FOLIO, 2) <> 'RD') 
	                AND (FACTEXPDET.FED_NOPARTE IS NOT NULL) 
	                AND FACTEXP.FE_FOLIO NOT IN (SELECT Factura FROM TempTotSalidasPOExclFact) 
	         GROUP BY RTRIM(LTRIM(FACTEXPDET.FED_NOPARTE))+'-'+isnull(FACTEXPDET.FED_ORD_COMP,''))


	UPDATE TempTotSalidasPOStock
             SET Sistema = 'NO EXISTE EN INTRADE'
             WHERE Sistema = 'RECO' 
                and rtrim(ltrim(NoParte))+'-'+rtrim(ltrim(NoOrden)) not in
--                     (SELECT NoParte+'-'+NoOrden from TempTotSalidasPOStock where Sistema = 'INTRADE' and NoParte+'-'+NoOrden is not null)
                (SELECT RTRIM(LTRIM(FACTEXPDET.FED_NOPARTE))+'-'+isnull(FACTEXPDET.FED_ORD_COMP,'')
	         FROM   FACTEXPDET RIGHT OUTER JOIN 
	                FACTEXP ON FACTEXPDET.FE_CODIGO = FACTEXP.FE_CODIGO 
	         WHERE  (FACTEXPDET.TI_CODIGO IN 
	                  (SELECT TI_CODIGO FROM TIPO WHERE TI_CATEG <> '4' AND TI_CATEG <> '5' AND TI_CATEG <> '3B')
		   AND LEN(isnull(FACTEXPDET.FED_ORD_COMP,''))>=10) 
	                AND (LEFT(FACTEXP.FE_FOLIO, 2) <> 'RD') 
	                AND (FACTEXPDET.FED_NOPARTE IS NOT NULL) 
	                AND FACTEXP.FE_FOLIO NOT IN (SELECT Factura FROM TempTotSalidasPOExclFact) 
	         GROUP BY RTRIM(LTRIM(FACTEXPDET.FED_NOPARTE))+'-'+isnull(FACTEXPDET.FED_ORD_COMP,''))



         UPDATE TempTotSalidasPOStock
         SET Sistema = 'EL ARCHIVO ESTA FUERA DE PERIODO - RECO'
         WHERE Sistema = 'INTRADE' 
                and rtrim(ltrim(NoParte))+'-'+rtrim(ltrim(NoOrden)) not in
                     (SELECT NoParte+'-'+NoOrden from TempTotSalidasPOStock where Sistema = 'RECO' and NoParte+'-'+NoOrden is not null
	AND FechaEntrada between CONVERT(DATETIME,@FechaIniMRP) and CONVERT(DATETIME,@FechaFinMRP))


	 insert into TempTotSalidasPOStock(NoParte, NoOrden, Sistema, Cantidad) 
	 select NoParte, NoOrden, 'TOTAL', round(sum(Cantidad),6) as Cantidad
	 from TempTotSalidasPOStock 
	WHERE (Sistema ='RECO') OR (Sistema ='INTRADE') 
	 group by NoParte, NoOrden


   /*=========================NON STOCK=====================*/

	TRUNCATE TABLE TempTotSalidasPONonStock

	insert into TempTotSalidasPONonStock(NoParte, Cantidad, NoOrden, Factura, FechaEntrada, TipoFactura, Sistema ) 
	SELECT     ITNBR, round(SUM(convert(decimal(38,6),TQTY)),6), --case when SUM(convert(decimal(38,6),TQTY))<0 then round(SUM(convert(decimal(38,6),TQTY)),6) else 0-round(SUM(convert(decimal(38,6),TQTY)),6) end, 
		ORDNO, '', MAX(convert(varchar(11),CONVERT(DATETIME,UPDDT),101)), '', 'RECO' 
	FROM TempSalidasPO
	WHERE (CODE IS NOT NULL AND CODE <> '') AND (((TempSalidasPO.ORDNO) Not Like 'FASMFA%' And
	 (TempSalidasPO.ORDNO) Not Like 'FASCUA%' And (TempSalidasPO.ORDNO) Not Like 'MFGA%' And (TempSalidasPO.ORDNO) Not Like 'KB%' 
	And (TempSalidasPO.ORDNO) Not Like 'MFGKB%' And (TempSalidasPO.ORDNO) Not Like 'm%' And (TempSalidasPO.ORDNO)='ISSM'))
	and convert(decimal(38,6),TQTY)<0
	AND CONVERT(DATETIME,UPDDT) >= CONVERT(DATETIME,@FechaIniMRP) AND CONVERT(DATETIME,UPDDT)<=CONVERT(DATETIME,@FechaFinMRP)
	GROUP BY TempSalidasPO.ITNBR, TempSalidasPO.TQTY, TempSalidasPO.ORDNO


	 insert into TempTotSalidasPONonStock(NoParte, Cantidad, NoOrden, Factura, FechaEntrada, TipoFactura, Sistema ) 
	 SELECT RTRIM(LTRIM(FACTEXPDET.FED_NOPARTE)), round(SUM(FACTEXPDET.FED_CANT),6), left(isnull(FACTEXPDET.FED_ORD_COMP,''),20), FACTEXP.FE_FOLIO, CONVERT(VARCHAR(11),FACTEXP.FE_FECHA,101), 
	         TFACTURA.TF_NOMBRE, 'INTRADE' 
	 FROM   FACTEXPDET RIGHT OUTER JOIN 
	        FACTEXP INNER JOIN 
	        TFACTURA ON FACTEXP.TF_CODIGO = TFACTURA.TF_CODIGO ON FACTEXPDET.FE_CODIGO = FACTEXP.FE_CODIGO 
	 WHERE   LEN(isnull(FACTEXPDET.FED_ORD_COMP,''))<=8 AND
		(FACTEXPDET.TI_CODIGO IN 
		
	          (SELECT TI_CODIGO FROM TIPO WHERE TI_CATEG <> '4' AND TI_CATEG <> '5' AND TI_CATEG <> '3B')) 
	        AND (LEFT(FACTEXP.FE_FOLIO, 2) <> 'RD') 
	        AND (FACTEXPDET.FED_NOPARTE IS NOT NULL) 
	        AND ((FACTEXP.FE_FECHA >= @FechaIni AND FACTEXP.FE_FECHA <= @FechaFin) OR 
		FACTEXP.FE_FOLIO IN (SELECT Factura FROM TempTotSalidasPOInclFact)) 
	        AND FACTEXP.FE_FOLIO NOT IN (SELECT Factura FROM TempTotSalidasPOExclFact) 
	 GROUP BY FACTEXP.FE_FECHA, RTRIM(LTRIM(FACTEXPDET.FED_NOPARTE)), FACTEXPDET.FED_ORD_COMP, FACTEXP.FE_FOLIO, TFACTURA.TF_NOMBRE



           UPDATE TempTotSalidasPONonStock
          SET Sistema = 'NO EXISTE EN RECO'
          WHERE Sistema = 'INTRADE' 
                and rtrim(ltrim(NoParte))+'-'+rtrim(ltrim(NoOrden)) not in
                     (SELECT NoParte+'-'+NoOrden from TempTotSalidasPONonStock where Sistema = 'RECO')



         UPDATE TempTotSalidasPONonStock
         SET Sistema = 'EXISTE EN INTRADE FUERA DE PERIODO'
         WHERE Sistema = 'RECO' 
                and rtrim(ltrim(NoParte))+'-'+rtrim(ltrim(NoOrden)) not in
                     (SELECT NoParte+'-'+NoOrden from TempTotSalidasPONonStock where Sistema = 'INTRADE' and NoParte+'-'+NoOrden is not null)

                and rtrim(ltrim(NoParte))+'-'+rtrim(ltrim(NoOrden)) in
                (SELECT RTRIM(LTRIM(FACTEXPDET.FED_NOPARTE))+'-'+isnull(FACTEXPDET.FED_ORD_COMP,'')
	         FROM   FACTEXPDET RIGHT OUTER JOIN 
	                FACTEXP ON FACTEXPDET.FE_CODIGO = FACTEXP.FE_CODIGO 
	         WHERE  (FACTEXPDET.TI_CODIGO IN 
	                  (SELECT TI_CODIGO FROM TIPO WHERE TI_CATEG <> '4' AND TI_CATEG <> '5' AND TI_CATEG <> '3B')
		   AND  LEN(isnull(FACTEXPDET.FED_ORD_COMP,''))<=8) 
	                AND (RTRIM(LTRIM(FACTEXPDET.FED_NOPARTE)) IS NOT NULL) 
	                AND FACTEXP.FE_FOLIO NOT IN (SELECT Factura FROM TempTotSalidasPOExclFact) 
	         GROUP BY RTRIM(LTRIM(FACTEXPDET.FED_NOPARTE))+'-'+isnull(FACTEXPDET.FED_ORD_COMP,''))


	UPDATE TempTotSalidasPONonStock
             SET Sistema = 'NO EXISTE EN INTRADE'
             WHERE Sistema = 'RECO' 
                and rtrim(ltrim(NoParte))+'-'+rtrim(ltrim(NoOrden)) not in
--                     (SELECT NoParte+'-'+NoOrden from TempTotSalidasPONonStock where Sistema = 'INTRADE' and NoParte+'-'+NoOrden is not null)
                (SELECT RTRIM(LTRIM(FACTEXPDET.FED_NOPARTE))+'-'+isnull(FACTEXPDET.FED_ORD_COMP,'')
	         FROM   FACTEXPDET RIGHT OUTER JOIN 
	                FACTEXP ON FACTEXPDET.FE_CODIGO = FACTEXP.FE_CODIGO 
	         WHERE  (FACTEXPDET.TI_CODIGO IN 
	                  (SELECT TI_CODIGO FROM TIPO WHERE TI_CATEG <> '4' AND TI_CATEG <> '5' AND TI_CATEG <> '3B')
		   AND  LEN(isnull(FACTEXPDET.FED_ORD_COMP,''))<=8) 
	                AND (RTRIM(LTRIM(FACTEXPDET.FED_NOPARTE)) IS NOT NULL) 
	                AND FACTEXP.FE_FOLIO NOT IN (SELECT Factura FROM TempTotSalidasPOExclFact) 
	         GROUP BY RTRIM(LTRIM(FACTEXPDET.FED_NOPARTE))+'-'+isnull(FACTEXPDET.FED_ORD_COMP,''))


         UPDATE TempTotSalidasPONonStock
         SET Sistema = 'EL ARCHIVO ESTA FUERA DE PERIODO - RECO'
         WHERE Sistema = 'INTRADE' 
                and rtrim(ltrim(NoParte))+'-'+rtrim(ltrim(NoOrden)) not in
                     (SELECT NoParte+'-'+NoOrden from TempTotSalidasPONonStock where Sistema = 'RECO' and NoParte+'-'+NoOrden is not null
	AND FechaEntrada between CONVERT(DATETIME,@FechaIniMRP) and CONVERT(DATETIME,@FechaFinMRP))



	 insert into TempTotSalidasPONonStock(NoParte, NoOrden, Sistema, Cantidad) 
	 select NoParte, NoOrden, 'TOTAL', round(sum(Cantidad),6) as Cantidad
	 from TempTotSalidasPONonStock 
	WHERE (Sistema ='RECO') OR (Sistema ='INTRADE') 
	 group by NoParte, NoOrden


GO
