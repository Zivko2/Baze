SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




/* esta vista sirve para los reportes de intrade sobre descargas */
CREATE VIEW dbo.VKARDESPEDConsulta
with encryption as
SELECT     TOP 100 PERCENT KARDESPED.KAP_CODIGO, KARDESPED.KAP_ESTATUS, KARDESPED.KAP_CANTDESC,  
                      KARDESPED.KAP_CantTotADescargar, KARDESPED.KAP_Saldo_FED, 
                      KARDESPED.KAP_FACTRANS, KARDESPED.KAP_PADRESUST, KARDESPED.KAP_INDICED_PED, 
                      KARDESPED.KAP_INDICED_FACT, KARDESPED.MA_HIJO, 
	         'PID_INDICEDexp'=CASE WHEN FACTEXPDET1.PID_INDICEDLIGAR1=-1 OR FACTEXPDET1.PID_INDICEDLIGAR1 IS NULL THEN FACTEXPDET1.PID_INDICEDLIGA ELSE FACTEXPDET1.PID_INDICEDLIGAR1 END,
                      PEDIMPDET1.PI_CODIGO, PIDescarga1.PID_SALDOGEN, FACTEXP1.FE_FECHA, kardesped.kap_tipo_desc
FROM         (SELECT FE_CODIGO, FE_FECHA FROM FACTEXP) FACTEXP1 INNER JOIN
                      KARDESPED ON FACTEXP1.FE_CODIGO = KARDESPED.KAP_FACTRANS LEFT OUTER JOIN
                      (SELECT PI_CODIGO, PID_INDICED FROM PEDIMPDET) PEDIMPDET1 LEFT OUTER JOIN
                      (SELECT PID_INDICED, PID_SALDOGEN FROM PIDescarga) PIDescarga1 ON PEDIMPDET1.PID_INDICED = PIDescarga1.PID_INDICED ON 
                      KARDESPED.KAP_INDICED_PED = PEDIMPDET1.PID_INDICED LEFT OUTER JOIN
                      (SELECT FACTEXPDET.FED_INDICED, PID_INDICEDLIGAR1, PID_INDICEDLIGA FROM FACTEXPDET) FACTEXPDET1
                     ON KARDESPED.KAP_INDICED_FACT = FACTEXPDET1.FED_INDICED  
--ORDER BY KARDESPED.KAP_PADRESUST, KARDESPED.MA_HIJO, KARDESPED.KAP_CODIGO




GO
