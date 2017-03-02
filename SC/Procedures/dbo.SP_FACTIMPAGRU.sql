SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO































CREATE PROCEDURE [dbo].[SP_FACTIMPAGRU] (@FIA_CODIGO INT)   as


EXEC SP_DROPTABLE 'FACTIMPAGRUDET'

SELECT     FACTIMP.FI_FACTAGRU, FACTIMPDET.FID_COS_UNI, FACTIMPDET.FID_NOPARTE, MAX(FACTIMPDET.FID_NOMBRE) AS FID_NOMBRE, 
                      MAX(FACTIMPDET.FID_NAME) AS FID_NAME, SUM(FACTIMPDET.FID_CANT_ST) AS FID_CANT_ST, SUM(FACTIMPDET.FID_COS_TOT) AS FID_COS_TOT, 
		FACTIMPDET.FID_PES_UNI, 
                      SUM(FACTIMPDET.FID_PES_NET) AS FID_PES_NET, SUM(FACTIMPDET.FID_PES_BRU) AS FID_PES_BRU, 
                      FACTIMPDET.FID_OBSERVA, FACTIMPDET.FID_FEC_ENT, FACTIMPDET.FID_NUM_ENT, FACTIMPDET.FID_SEC_IMP, FACTIMPDET.FID_POR_DEF, 
                      FACTIMPDET.FID_DEF_TIP, FACTIMPDET.FID_ENVIO, FACTIMPDET.AR_IMPMX, FACTIMPDET.AR_EXPFO, FACTIMPDET.MA_CODIGO, 
                      FACTIMPDET.ME_CODIGO, FACTIMPDET.MA_GENERICO, FACTIMPDET.ME_ARIMPMX, FACTIMPDET.PA_CODIGO, 
                      FACTIMPDET.PR_CODIGO, FACTIMPDET.PL_FOLIO, FACTIMPDET.PL_CODIGO, FACTIMPDET.PLD_INDICED, 
                      FACTIMPDET.EQ_GEN, FACTIMPDET.EQ_IMPMX, FACTIMPDET.EQ_EXPFO, FACTIMPDET.TI_CODIGO, 
                      FACTIMPDET.FID_RATEEXPFO, FACTIMPDET.FID_RELEMP, FACTIMPDET.SPI_CODIGO, FACTIMPDET.MA_EMPAQUE, SUM(FACTIMPDET.FID_CANTEMP) AS FID_CANTEMP, 
                      FACTIMPDET.ME_GEN, FACTIMPDET.TCO_CODIGO, 
                      FACTIMPDET.FID_NOPARTEAUX, FACTIMPDET.FID_REFTASA, FACTIMPDET.EQ_EXPFO2, (SELECT SUM(FACTIMP1.FI_TOTALB) FROM FACTIMP AS FACTIMP1 WHERE FACTIMP1.FI_FACTAGRU=FACTIMP.FI_FACTAGRU) AS FIA_TOTALB
INTO dbo.FACTIMPAGRUDET
FROM         FACTIMPDET INNER JOIN
                      FACTIMP ON FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
WHERE FACTIMP.FI_FACTAGRU=@FIA_CODIGO
GROUP BY FACTIMP.FI_FACTAGRU, FACTIMPDET.FID_COS_UNI, FACTIMPDET.FID_NOPARTE, 
                      FACTIMPDET.FID_OBSERVA, FACTIMPDET.FID_FEC_ENT, FACTIMPDET.FID_NUM_ENT, FACTIMPDET.FID_SEC_IMP, FACTIMPDET.FID_POR_DEF, 
                      FACTIMPDET.FID_DEF_TIP, FACTIMPDET.FID_ENVIO, FACTIMPDET.AR_IMPMX, FACTIMPDET.AR_EXPFO, FACTIMPDET.MA_CODIGO, 
                      FACTIMPDET.ME_CODIGO, FACTIMPDET.MA_GENERICO, FACTIMPDET.ME_ARIMPMX, FACTIMPDET.PA_CODIGO, 
                      FACTIMPDET.PR_CODIGO, FACTIMPDET.PL_FOLIO, FACTIMPDET.PL_CODIGO, FACTIMPDET.PLD_INDICED, 
                      FACTIMPDET.EQ_GEN, FACTIMPDET.EQ_IMPMX, FACTIMPDET.EQ_EXPFO, FACTIMPDET.TI_CODIGO, 
                      FACTIMPDET.FID_RATEEXPFO, FACTIMPDET.FID_RELEMP, FACTIMPDET.SPI_CODIGO, FACTIMPDET.MA_EMPAQUE,
                      FACTIMPDET.ME_GEN, FACTIMPDET.TCO_CODIGO,  FACTIMPDET.FID_PES_UNI,
                      FACTIMPDET.FID_NOPARTEAUX, FACTIMPDET.FID_REFTASA, FACTIMPDET.EQ_EXPFO2






























GO