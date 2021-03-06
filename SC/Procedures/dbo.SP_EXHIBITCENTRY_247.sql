SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE dbo.SP_EXHIBITCENTRY_247( @CS_CODIGO INT)    as

SET NOCOUNT ON 
 /* Eliminar los registros anteriores */
if exists (select * FROM COSTSUBBASC247ENTRY  WHERE CS_CODIGO = @CS_CODIGO)
  DELETE FROM COSTSUBBASC247ENTRY  WHERE CS_CODIGO = @CS_CODIGO

 /* Insertar los registros declarados a partir del exhibit B y el A a Detalle*/
 INSERT  INTO COSTSUBBASC247ENTRY( CS_CODIGO, AR_CODIGO, PA_CODIGO, CSBE_RATE,MA_NAFTA,
 CSBE_DUTVAL, CSBE_CANT,  SPI_CODIGO, PU_CODIGO, ET_CODIGO, CSBE_MPFDLLS, CSBE_DUTVALWMPF, CSBE_DUTVALREC)
SELECT VEXHIBIT_B_BASE247.CS_CODIGO,  VEXHIBIT_B_BASE247.AR_CODIGO,  VEXHIBIT_B_BASE247.PA_CODIGO,  VEXHIBIT_B_BASE247.ETA_RATE, 
   MAX(VEXHIBIT_B_BASE247.MA_NAFTA) AS MA_NAFTA,  COSTSUBA.CSA_DUTVALUE, SUM(VEXHIBIT_B_BASE247.ETA_CANT) AS CSB_CANT, MAX(VEXHIBIT_B_BASE247.SPI_CODIGO) AS SPI_CODIGO, 
     VEXHIBIT_B_BASE247.PU_ENTRADA AS PU_CODIGO, ET_CODIGO, SUM(ETA_DLLS_MPF), SUM(VEXHIBIT_B_BASE247.ETA_WMPF) AS ETA_WMPF, COSTSUBA.CSA_DUTVALUE
FROM VEXHIBIT_B_BASE247 LEFT OUTER JOIN
    COSTSUBA ON 
    VEXHIBIT_B_BASE247.CS_CODIGO = COSTSUBA.CS_CODIGO
WHERE VEXHIBIT_B_BASE247.CS_CODIGO=@CS_CODIGO AND ETA_RATE IS NOT NULL 
GROUP BY VEXHIBIT_B_BASE247.CS_CODIGO, 
    VEXHIBIT_B_BASE247.ETA_RATE, 
    VEXHIBIT_B_BASE247.AR_CODIGO, 
    VEXHIBIT_B_BASE247.PA_CODIGO, 
    VEXHIBIT_B_BASE247.PU_ENTRADA, 
    COSTSUBA.CSA_DUTVALUE, ET_CODIGO

/*========================================  CALCULOS  ==================================*/

-- Update a detalle, de los campos CSBE_3PORCENTO y CSBE_3PORCENTW (se genera calculo)

UPDATE COSTSUBBASC247ENTRY
SET  CSBE_PRORATIW=ISNULL(COSTSUBBASC247ENTRY.CSBE_DUTVALWMPF/TOT.DUTVALTOT,0)*CSBE_DUTVAL
FROM (SELECT SUM(ETA_COS_TOT) AS DUTVALTOT, CS_CODIGO, ET_CODIGO FROM VEXHIBIT_B_BASE247 GROUP BY  CS_CODIGO, ET_CODIGO) AS TOT
WHERE COSTSUBBASC247ENTRY.CS_CODIGO = TOT.CS_CODIGO  AND COSTSUBBASC247ENTRY.ET_CODIGO = TOT.ET_CODIGO AND DUTVALTOT>0
AND COSTSUBBASC247ENTRY.CS_CODIGO = @CS_CODIGO




GO
