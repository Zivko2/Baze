SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW dbo.VKARDESPED
with encryption as
SELECT     
                    (dbo.agenciapatente.agt_patente collate database_default +'-'+ dbo.pedimp.pi_folio collate database_default) as PATENTE_FOLIO ,
                    dbo.KARDESPED.KAP_CODIGO, dbo.KARDESPED.KAP_FACTRANS, dbo.FACTEXP.FE_TIPO AS KAP_TIPO_FACTRANS, 
                      dbo.PEDIMPDET.PI_CODIGO AS KAP_PED_CONST, dbo.KARDESPED.KAP_INDICED_FACT, dbo.KARDESPED.KAP_INDICED_PED, 
                      dbo.PEDIMP.PI_TIPO AS KAP_TIPO_PED, dbo.FACTEXP.FE_FECHADESCARGA AS KAP_FECHADESC, dbo.PEDIMP.PI_FEC_ENT AS KAP_FECHAPED, 
                      dbo.FACTEXPDET.MA_CODIGO AS MA_FACT_TRANS, dbo.KARDESPED.MA_HIJO, dbo.PEDIMPDET.TI_CODIGO AS TI_HIJO, 
                      dbo.PEDIMPDET.ME_GENERICO AS ME_HIJO, 
                      MAESTRO_1.MA_DISCHARGE AS KAP_SEDESCARGA, MAESTRO_1.MA_CONSTA, 
                      dbo.KARDESPED.KAP_ESTATUS, dbo.PEDIMPDET.EQ_GENERICO AS EQ_GENHIJO, dbo.KARDESPED.KAP_CANTDESC, VKAP_SALDO_PED.KAP_SALDO_PED, 
                      dbo.KARDESPED.KAP_CantTotADescargar, dbo.KARDESPED.KAP_Saldo_FED, dbo.KARDESPED.KAP_PADRESUST, 
                      dbo.PEDIMPDET.PA_ORIGEN, dbo.PEDIMPDET.PA_PROCEDE, MAESTRO_1.SE_CODIGO, 
                      dbo.PEDIMPDET.PID_POR_DEF AS KAP_POR_DEF, dbo.PEDIMPDET.PID_DEF_TIP AS KAP_DEF_TIP, 
                      dbo.PEDIMPDET.PID_SEC_IMP AS KAP_SEC_IMP, dbo.FACTEXPDET.FED_FECHA_STRUCT AS KAP_FED_FECHA, 
                      dbo.FACTEXPDET.FED_RATEIMPFO AS KAP_RATEIMPFO, dbo.FACTEXPDET.AR_IMPFO, dbo.PEDIMPDET.SPI_CODIGO, 
                      dbo.PEDIMPDET.AR_IMPMX, dbo.FACTEXPDET.AR_EXPMX,
	         'KAP_COS_UNI' =case when dbo.PEDIMPDET.PID_COS_UNIADU is null then 0 else 
	         (case when dbo.PEDIMP.PI_TIP_CAM is null or dbo.PEDIMP.PI_TIP_CAM=0 then 0 else isnull((dbo.PEDIMPDET.PID_COS_UNIADU/dbo.PEDIMP.PI_TIP_CAM),0) end) end
FROM         dbo.MAESTRO MAESTRO_1 RIGHT OUTER JOIN
                      dbo.FACTEXPDET ON MAESTRO_1.MA_CODIGO = dbo.FACTEXPDET.MA_CODIGO RIGHT OUTER JOIN
                      dbo.FACTEXP RIGHT OUTER JOIN
                      dbo.KARDESPED LEFT OUTER JOIN
                      dbo.MAESTRO MAESTRO_2 ON dbo.KARDESPED.MA_HIJO = MAESTRO_2.MA_CODIGO ON 
                      dbo.FACTEXP.FE_CODIGO = dbo.KARDESPED.KAP_FACTRANS ON 
                      dbo.FACTEXPDET.FED_INDICED = dbo.KARDESPED.KAP_INDICED_FACT LEFT OUTER JOIN
                      dbo.PEDIMP RIGHT OUTER JOIN
                      dbo.PEDIMPDET ON dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO ON dbo.KARDESPED.KAP_INDICED_PED = dbo.PEDIMPDET.PID_INDICED
	LEFT OUTER JOIN VKAP_SALDO_PED ON dbo.KARDESPED.KAP_CODIGO=VKAP_SALDO_PED.KAP_CODIGO
              left outer join dbo.agenciapatente on dbo.pedimp.agt_codigo = dbo.agenciapatente.agt_codigo

































































GO
