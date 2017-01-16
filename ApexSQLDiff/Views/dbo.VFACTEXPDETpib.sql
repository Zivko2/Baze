SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




































CREATE VIEW dbo.VFACTEXPDETpib
with encryption as
SELECT     dbo.VFACTEXPDETliga.FED_INDICED, dbo.VFACTEXPDETliga.FE_CODIGO, dbo.VFACTEXPDETliga.MA_CODIGO, dbo.VFACTEXPDETliga.FED_NOMBRE, 
                      dbo.VFACTEXPDETliga.FED_NOPARTE, dbo.VFACTEXPDETliga.FED_NAME, dbo.VFACTEXPDETliga.ME_CODIGO, 
                      dbo.VFACTEXPDETliga.FED_OBSERVA, dbo.VFACTEXPDETliga.FED_CANT, dbo.VFACTEXPDETliga.FED_GRA_MP, 
                      dbo.VFACTEXPDETliga.FED_GRA_MO, dbo.VFACTEXPDETliga.FED_GRA_EMP, dbo.VFACTEXPDETliga.FED_GRA_ADD, 
                      dbo.VFACTEXPDETliga.FED_GRA_GI, dbo.VFACTEXPDETliga.FED_GRA_GI_MX, 
                      dbo.VFACTEXPDETliga.FED_NG_MP, dbo.VFACTEXPDETliga.FED_NG_EMP, dbo.VFACTEXPDETliga.FED_NG_ADD, 
                      dbo.VFACTEXPDETliga.FED_NG_USA, dbo.VFACTEXPDETliga.FED_NG_MX, dbo.VFACTEXPDETliga.FED_COS_UNI, dbo.VFACTEXPDETliga.FED_COS_TOT, 
                      dbo.VFACTEXPDETliga.FED_PES_UNI, dbo.VFACTEXPDETliga.FED_PES_NET, dbo.VFACTEXPDETliga.FED_PES_BRU, 
                      dbo.VFACTEXPDETliga.FED_PES_UNILB, dbo.VFACTEXPDETliga.FED_PES_NETLB, dbo.VFACTEXPDETliga.FED_PES_BRULB, 
                      dbo.VFACTEXPDETliga.FED_SEC_IMP, dbo.VFACTEXPDETliga.FED_DEF_TIP, dbo.VFACTEXPDETliga.FED_POR_DEF, 
                      dbo.VFACTEXPDETliga.FED_LOTE, dbo.VFACTEXPDETliga.AR_IMPMX, dbo.VFACTEXPDETliga.AR_EXPMX, dbo.VFACTEXPDETliga.AR_IMPFO, 
                      dbo.VFACTEXPDETliga.FED_CON_PED, dbo.VFACTEXPDETliga.MA_GENERICO, 
                      dbo.VFACTEXPDETliga.PA_CODIGO, dbo.VFACTEXPDETliga.LE_CODIGO, dbo.VFACTEXPDETliga.LED_INDICED, dbo.VFACTEXPDETliga.EX_CODIGO, 
                      dbo.VFACTEXPDETliga.FED_ORD_COMP, dbo.VFACTEXPDETliga.FED_NOORDEN, dbo.VFACTEXPDETliga.FED_USO_COMMINV, 
                      dbo.VFACTEXPDETliga.EQ_GEN, dbo.VFACTEXPDETliga.EQ_IMPFO, dbo.VFACTEXPDETliga.EQ_EXPMX, dbo.VFACTEXPDETliga.TI_CODIGO, 
                      dbo.VFACTEXPDETliga.FED_TENVIO, dbo.VFACTEXPDETliga.FED_INBOND, dbo.VFACTEXPDETliga.FED_TIPOINBOND, 
                      dbo.VFACTEXPDETliga.FED_RATEEXPMX, dbo.VFACTEXPDETliga.FED_RATEIMPFO, dbo.VFACTEXPDETliga.FED_RELEMP, 
                      dbo.VFACTEXPDETliga.FED_FECHA_STRUCT, dbo.VFACTEXPDETliga.FED_DISCHARGE, dbo.VFACTEXPDETliga.LE_FOLIO, 
                      dbo.VFACTEXPDETliga.SPI_CODIGO, dbo.VFACTEXPDETliga.FED_SALDO, dbo.VFACTEXPDETliga.FED_RETRABAJO, 
                      dbo.VFACTEXPDETliga.ADE_CODIGO, dbo.VFACTEXPDETliga.MA_EMPAQUE, dbo.VFACTEXPDETliga.FED_CANTEMP, 
                      dbo.VFACTEXPDETliga.FED_FAC_NUM, dbo.VFACTEXPDETliga.FED_FEC_ENV, dbo.VFACTEXPDETliga.FED_CON_CERTORIG, 
                      dbo.VFACTEXPDETliga.FED_COS_UNI_CO, dbo.VFACTEXPDETliga.FED_GRA_MAT_CO, dbo.VFACTEXPDETliga.FED_EMP_CO, 
                      dbo.VFACTEXPDETliga.FED_NG_MAT_CO, dbo.VFACTEXPDETliga.FED_VA_CO, dbo.VFACTEXPDETliga.FED_CANTGEN, 
                      dbo.VFACTEXPDETliga.MO_CODIGO, dbo.VFACTEXPDETliga.FED_DESCARGADO, dbo.VFACTEXPDETliga.FED_PARTTYPE, 
                      dbo.VFACTEXPDETliga.ME_GENERICO, dbo.VFACTEXPDETliga.FED_TIP_ENS, dbo.VFACTEXPDETliga.PID_INDICED, 
                      dbo.VFACTEXPDETliga.MA_NOPARTECL, dbo.VFACTEXPDETliga.ME_AREXPMX, dbo.VFACTEXPDETliga.FED_NAFTA, 
                      dbo.VFACTEXPDETliga.FED_DEFTXT1, dbo.VFACTEXPDETliga.FED_DEFTXT2, dbo.VFACTEXPDETliga.FED_DEFNO3, 
                      dbo.VFACTEXPDETliga.FED_DEFNO4, dbo.VFACTEXPDETliga.PID_INDICEDLIGA, dbo.VFACTEXPDETliga.TCO_CODIGO, 
                      dbo.VFACTEXPDETliga.PI_ORIGENKITPADRE, dbo.VFACTEXPDETliga.CS_CODIGO, dbo.VFACTEXPDETliga.SE_CODIGO, 
                      dbo.VFACTEXPDETliga.FED_RELCAJAS, dbo.VFACTEXPDETliga.END_INDICED, dbo.VFACTEXPDETliga.EN_CODIGO, 
                      dbo.VFACTEXPDETliga.FED_DESTNAFTA, dbo.PEDIMPDETB.PIB_INDICEB, dbo.VFACTEXPDETliga.AR_ORIG,
                      dbo.VFACTEXPDETliga.AR_NG_EMP, dbo.VFACTEXPDETliga.FED_PRECIO_UNI, dbo.VFACTEXPDETliga.FED_PRECIO_TOT
FROM         dbo.PEDIMPDETB RIGHT OUTER JOIN
                      dbo.PEDIMPDET ON dbo.PEDIMPDETB.PIB_INDICEB = dbo.PEDIMPDET.PIB_INDICEB RIGHT OUTER JOIN           
           dbo.VFACTEXPDETliga ON dbo.PEDIMPDET.PID_INDICED = dbo.VFACTEXPDETliga.PID_INDICEDLIGA




































































GO
