SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE dbo.SP_TEST   as

SET NOCOUNT ON 
BEGIN
             /* Encabezado del Entry Summary Exhibit B */
	 INSERT INTO COSTSUBBASB (ET_CODIGO,CSBB_GRAVMAT, CSBB_NGMAT, CSBB_FECHA, CSBB_TOTAL) 
              	SELECT ET_CODIGO, EntryGravMat, EntryNoGravMat, ET_FECHA, (EntryGravMat+EntryNoGravMat) 
              	FROM VEXHIBIT_B_1 


             /* Encabezados de las Facturas de Exp contenidas en el Entry Summary MASTER (el de arriba) */
	INSERT INTO COSTSUBBASBFAC (ET_CODIGO, FE_CODIGO, CSBBF_GRAVMAT, CSBBF_NGMAT, CSBBF_TOTAL, CSBBF_FECHA, CSBBF_TOTVA )
	SELECT ET_CODIGO, FE_CODIGO,FactExpTotGravMat, FactExpTotNoGrav, (FactExpTotGravMat + FactExpTotNoGrav),  FE_FECHA, FactExpTotVA
	FROM VEXHIBIT_B_2A

             /* Encabezados de las Facturas de Exp contenidas en el Entry Summary MASTER (el de arriba) */
	INSERT INTO COSTSUBBASBFAC (ET_CODIGO, FE_CODIGO, CSBBF_GRAVMAT, CSBBF_NGMAT, CSBBF_TOTAL, CSBBF_FECHA, CSBBF_TOTVA )
	SELECT ET_CODIGO, FE_CODIGO,FactExpTotGravMat, FactExpTotNoGrav, (FactExpTotGravMat + FactExpTotNoGrav),  FE_FECHA, FactExpTotVA
	FROM VEXHIBIT_B_2I

             /* Detalle de c/u de las Factura de Exp. contenidas en el Entry Summary */
  	 INSERT INTO COSTSUBBASBDET (FE_CODIGO, FED_INDICED, MA_CODIGO, TI_CODIGO, AR_CODIGO, CSBD_NAFTA, CSBD_GRAV_MAT,
                  	             CSBD_GRAV_EMP, CSBD_GRAV_VA, CSBD_NG_MAT, CSBD_NG_EMP, CSBD_NG_VA, CSBD_TOT_GRAV, CSBD_TOT_NG, CSBD_COS_UNI, CSBD_CANT)
              	
	SELECT FE_CODIGO, FED_INDICED, MA_CODIGO, TI_CODIGO, AR_IMPFO, MA_NAFTA, FactExpGravMat, FED_GRA_EMP, FED_GRA_VA, 
		FactExpDetNGMat, FED_NG_EMP, FED_NG_VA,FactExpTotVA, FactExpTotNoGrav, FED_COS_UNI, FED_CANT
  	FROM VEXHIBIT_B_3A

	SELECT FE_CODIGO, FED_INDICED, MA_CODIGO, TI_CODIGO, AR_IMPFO, MA_NAFTA, FactExpGravMat, FED_GRA_EMP, FED_GRA_VA, 
		FactExpDetNGMat, FED_NG_EMP, FED_NG_VA,FactExpTotVA, FactExpTotNoGrav, FED_COS_UNI, FED_CANT
  	FROM VEXHIBIT_B_3I 

END


GO
