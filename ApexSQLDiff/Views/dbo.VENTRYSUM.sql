SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


















































CREATE VIEW dbo.VENTRYSUM
with encryption as
SELECT     ET_CODIGO, ET_ENTRY_NO, EA_ENTRADA, EB_ENTRADA, ET_FEC_ENTRY, ET_FEC_ENTRYS, ET_FEC_GEN, 
                      ET_FEC_IMP, ET_BOND, BT_BTIPO, AG_CODIGO, PA_CODIGO, ET_MISMAYOR2, MI_CODIGO, MI_CODIGO2, PU_FOREING, PU_ENTRADA, ET_LOCAT, 
                      US_DECLARANT, ET_IDECLARE, ET_FURTHER, ET_VOYAGE, ET_DES_GRAL, ET_MANIFEST, ET_BL_AWB, ET_NO_INB, ET_FEC_INB, ET_IMPORTER, 
                      ET_DLLS_MPF, ET_DLLS_RATE, ET_DLLS_IRC, ET_DLLS_VISA, ET_FLAGGED, ET_FIRMS, PU_ARRIBO, ET_MANIFIESTDATE, ET_ARRIBODATE, 
                      MT_CODIGO, ET_MANIFIESTDESC1, ET_MANIFIESTDESC2, CT_CODIGO, US_INCHARGE, ET_DLLS_TOTAL, TRM_CODIGO, 1 AS cl_codigo,
	        (select cl_matriz from cliente where cl_empresa='S') as cl_matriz
FROM         dbo.ENTRYSUM

GO
