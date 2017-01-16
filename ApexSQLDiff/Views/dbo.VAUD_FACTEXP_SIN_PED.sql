SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





































CREATE VIEW dbo.VAUD_FACTEXP_SIN_PED
with encryption as
SELECT     FE_CODIGO, FE_FOLIO, FE_FECHA, TF_CODIGO, TQ_CODIGO, FC_CODIGO, FE_NO_SEM, FE_DOCUMENTO, FE_DESTINO, AG_MX, AG_US, CL_PROD, 
                      DI_PROD, CL_COMP, DI_COMP, CL_EXP, DI_EXP, CL_DESTINI, DI_DESTINI, CL_DESTFIN, DI_DESTFIN, CL_VEND, DI_VEND, CL_IMP, DI_IMP, 
                      PU_SALIDA, PU_ENTRADA, PU_DESTINO, FE_FEC_ENV, FE_FEC_ARR, FE_NUM_ENV, FE_ENV_INST, FE_ORD_COMP, FE_NUM_CTL, 
                      FE_NUM_INBON, FE_TIPO_INBON, FE_FEC_INBON, FE_FIRMS, FE_COMENTA, FE_COMENTAUS, US_CODIGO, CT_COMPANY1, CA_COMPANY1, 
                      CJ_COMPANY1, CT_COMPANY2, CA_COMPANY2, CJ_COMPANY2, FE_TRAC_US1, FE_TRAC_MX1, FE_CONT1_REG, FE_CONT1_US, 
                      FE_CONT1_SELL, PG_COMPANY1, FE_TRAC_CHO1, FE_LIM1, RU_COMPANY1, 'N' AS FE_FAIRE_MART1, 'N' AS FE_F_TERRT1, 
                      IT_COMPANY1, 0 AS FE_TOTAL_TRANS1, MT_COMPANY1, 
                      FE_GUIA1, FE_TRAC_US2, FE_TRAC_MX2, FE_CONT2_REG, FE_CONT2_US, FE_CONT2_SELL, PG_COMPANY2, FE_TRAC_CHO2, 
                      FE_LIM2, RU_COMPANY2, 'N' AS FE_FAIRE_MART2, 'N' AS FE_F_TERRT2, IT_COMPANY2,  
                      0 AS FE_TOTAL_TRANS2, MT_COMPANY2, FE_GUIA2, FE_TOTALB, FE_TIPOCAMBIO, FE_MANIF, 
                      FE_AWB, FE_ESTATUS, FE_FACTAGRU, FE_INCOTLUGAR1, FE_INCOTLUGAR2, 
                      FE_LAGNO
FROM         dbo.FACTEXP
WHERE     (FE_TIPO <> 'T') AND (PI_CODIGO IS NULL OR
                      PI_CODIGO = -1)
























GO
