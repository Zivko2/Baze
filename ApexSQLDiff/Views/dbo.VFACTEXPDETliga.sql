SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





































CREATE VIEW dbo.VFACTEXPDETliga
with encryption as
SELECT     FED_INDICED, FE_CODIGO, MA_CODIGO, FED_NOMBRE, FED_NOPARTE, FED_NAME, ME_CODIGO, FED_OBSERVA, FED_CANT, 
                      FED_GRA_MP+(FED_GRA_MP*isnull((SELECT sum(FACTEXPDETCARGO.FEG_VALOR)/100 FROM FACTEXPDETCARGO WHERE FACTEXPDETCARGO.FED_INDICED = FACTEXPDET.FED_INDICED AND FEG_TIPO = 'T'),0)) AS FED_GRA_MP, 
                      FED_GRA_MO+(FED_GRA_MO*isnull((SELECT sum(FACTEXPDETCARGO.FEG_VALOR)/100 FROM FACTEXPDETCARGO WHERE FACTEXPDETCARGO.FED_INDICED = FACTEXPDET.FED_INDICED AND FEG_TIPO = 'T'),0)) AS FED_GRA_MO,
                      FED_GRA_EMP+(FED_GRA_EMP*isnull((SELECT sum(FACTEXPDETCARGO.FEG_VALOR)/100 FROM FACTEXPDETCARGO WHERE FACTEXPDETCARGO.FED_INDICED = FACTEXPDET.FED_INDICED AND FEG_TIPO = 'T'),0)) AS FED_GRA_EMP,
                      FED_GRA_ADD+(FED_GRA_ADD*isnull((SELECT sum(FACTEXPDETCARGO.FEG_VALOR)/100 FROM FACTEXPDETCARGO WHERE FACTEXPDETCARGO.FED_INDICED = FACTEXPDET.FED_INDICED AND FEG_TIPO = 'T'),0)) AS FED_GRA_ADD,
                      FED_GRA_GI+(FED_GRA_GI*isnull((SELECT sum(FACTEXPDETCARGO.FEG_VALOR)/100 FROM FACTEXPDETCARGO WHERE FACTEXPDETCARGO.FED_INDICED = FACTEXPDET.FED_INDICED AND FEG_TIPO = 'T'),0)) AS FED_GRA_GI,
                      FED_GRA_GI_MX+(FED_GRA_GI_MX*isnull((SELECT sum(FACTEXPDETCARGO.FEG_VALOR)/100 FROM FACTEXPDETCARGO WHERE FACTEXPDETCARGO.FED_INDICED = FACTEXPDET.FED_INDICED AND FEG_TIPO = 'T'),0)) AS FED_GRA_GI_MX,
                      FED_NG_MP+(FED_NG_MP*isnull((SELECT sum(FACTEXPDETCARGO.FEG_VALOR)/100 FROM FACTEXPDETCARGO WHERE FACTEXPDETCARGO.FED_INDICED = FACTEXPDET.FED_INDICED AND FEG_TIPO = 'T'),0)) AS FED_NG_MP,
                      FED_NG_EMP+(FED_NG_EMP*isnull((SELECT sum(FACTEXPDETCARGO.FEG_VALOR)/100 FROM FACTEXPDETCARGO WHERE FACTEXPDETCARGO.FED_INDICED = FACTEXPDET.FED_INDICED AND FEG_TIPO = 'T'),0)) AS FED_NG_EMP,
                      FED_NG_ADD+(FED_NG_ADD*isnull((SELECT sum(FACTEXPDETCARGO.FEG_VALOR)/100 FROM FACTEXPDETCARGO WHERE FACTEXPDETCARGO.FED_INDICED = FACTEXPDET.FED_INDICED AND FEG_TIPO = 'T'),0)) AS FED_NG_ADD,
                      FED_NG_USA+(FED_NG_USA*isnull((SELECT sum(FACTEXPDETCARGO.FEG_VALOR)/100 FROM FACTEXPDETCARGO WHERE FACTEXPDETCARGO.FED_INDICED = FACTEXPDET.FED_INDICED AND FEG_TIPO = 'T'),0)) AS FED_NG_USA,
                      FED_NG_MX+(FED_NG_MX*isnull((SELECT sum(FACTEXPDETCARGO.FEG_VALOR)/100 FROM FACTEXPDETCARGO WHERE FACTEXPDETCARGO.FED_INDICED = FACTEXPDET.FED_INDICED AND FEG_TIPO = 'T'),0)) AS FED_NG_MX,
                      FED_COS_UNI+(FED_COS_UNI*isnull((SELECT sum(FACTEXPDETCARGO.FEG_VALOR)/100 FROM FACTEXPDETCARGO WHERE FACTEXPDETCARGO.FED_INDICED = FACTEXPDET.FED_INDICED AND FEG_TIPO = 'T'),0)) AS FED_COS_UNI, 
                      FED_COS_TOT+(FED_COS_TOT*isnull((SELECT sum(FACTEXPDETCARGO.FEG_VALOR)/100 FROM FACTEXPDETCARGO WHERE FACTEXPDETCARGO.FED_INDICED = FACTEXPDET.FED_INDICED AND FEG_TIPO = 'T'),0)) AS FED_COS_TOT, 
                      FED_PES_UNI, FED_PES_NET, FED_PES_BRU, FED_PES_UNILB, FED_PES_NETLB, 
                      FED_PES_BRULB, FED_SEC_IMP, FED_DEF_TIP, FED_POR_DEF, FED_LOTE, AR_IMPMX, AR_EXPMX, AR_IMPFO, 
                      FED_CON_PED, MA_GENERICO, PA_CODIGO, LE_CODIGO, LED_INDICED, EX_CODIGO, FED_ORD_COMP, 
                      FED_NOORDEN, FED_USO_COMMINV, EQ_GEN, EQ_IMPFO, EQ_EXPMX, TI_CODIGO, FED_TENVIO, FED_INBOND, FED_TIPOINBOND, 
                      FED_RATEEXPMX, FED_RATEIMPFO, FED_RELEMP, FED_FECHA_STRUCT, FED_DISCHARGE, LE_FOLIO, SPI_CODIGO, FED_SALDO, 
                      FED_RETRABAJO, ADE_CODIGO, MA_EMPAQUE, FED_CANTEMP, FED_FAC_NUM, FED_FEC_ENV, FED_CON_CERTORIG, FED_COS_UNI_CO, 
                      FED_GRA_MAT_CO, FED_EMP_CO, FED_NG_MAT_CO, FED_VA_CO, FED_CANTGEN, MO_CODIGO, FED_DESCARGADO, FED_PARTTYPE, 
                      ME_GENERICO, FED_TIP_ENS, PID_INDICED, MA_NOPARTECL, ME_AREXPMX, FED_NAFTA, FED_DEFTXT1, FED_DEFTXT2, FED_DEFNO3, 
                      FED_DEFNO4, TCO_CODIGO, PI_ORIGENKITPADRE, CS_CODIGO, SE_CODIGO, FED_RELCAJAS, FED_DESTNAFTA, AR_ORIG, AR_NG_EMP,
                      END_INDICED, EN_CODIGO, 'PID_INDICEDLIGA'=CASE WHEN PID_INDICEDLIGAR1=-1 OR PID_INDICEDLIGAR1 IS NULL THEN PID_INDICEDLIGA ELSE PID_INDICEDLIGAR1 END, 
                      'CONIDENTIFICA'=CASE WHEN (SELECT COUNT(*) FROM FACTEXPDETIDENTIFICA WHERE FACTEXPDETIDENTIFICA.FED_INDICED=dbo.FACTEXPDET.FED_INDICED)>0 THEN 'S' ELSE 'N' END,
	         'CONCONTENIDO'=CASE WHEN (SELECT COUNT(*) FROM FACTEXPCONT WHERE FACTEXPCONT.FED_INDICED=dbo.FACTEXPDET.FED_INDICED)>0 THEN 'S' ELSE 'N' END,
			FED_PRECIO_UNI, FED_PRECIO_TOT
FROM         dbo.FACTEXPDET












































GO
