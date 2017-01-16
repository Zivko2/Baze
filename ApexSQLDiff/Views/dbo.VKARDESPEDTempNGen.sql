SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW dbo.VKARDESPEDTempNGen
with encryption as
SELECT     dbo.KARDESPEDTemp.*
FROM         KARDESPEDTemp inner join MAESTRO on KARDESPEDTemp.ma_hijo=MAESTRO.MA_CODIGO
WHERE     KAP_INDICED_PED IS NULL AND kap_Saldo_fed > 0 AND (((KAP_ESTATUS = 'P' OR
                      KAP_ESTATUS = 'N') AND (NOT (KAP_INDICED_FACT IN
                          (SELECT     KARDESPEDTemp1.kap_indiced_fact
                            FROM          KARDESPEDTemp KARDESPEDTemp1 inner join MAESTRO MAESTRO1 on KARDESPEDTemp1.ma_hijo=MAESTRO1.MA_CODIGO
                            WHERE      MAESTRO1.MA_GENERICO = MAESTRO.MA_GENERICO AND KARDESPEDTemp1.kap_estatus = 'D' AND KARDESPEDTemp1.kap_factrans = KARDESPEDTemp.kap_factrans)))
		and (KARDESPEDTemp.kap_padresust is null or KARDESPEDTemp.kap_padresust=0) and kap_fiscomp='N')
	or ((KAP_ESTATUS = 'P' OR
                      KAP_ESTATUS = 'N') AND (NOT (KAP_INDICED_FACT IN
                          (SELECT     KARDESPEDTemp2.kap_indiced_fact
                            FROM          KARDESPEDTemp KARDESPEDTemp2 inner join MAESTRO MAESTRO2 on KARDESPEDTemp2.ma_hijo=MAESTRO2.MA_CODIGO
                            WHERE      MAESTRO2.MA_GENERICO = MAESTRO.MA_GENERICO AND KARDESPEDTemp2.kap_estatus = 'D' AND KARDESPEDTemp2.kap_factrans = KARDESPEDTemp.kap_factrans)))
		and (KARDESPEDTemp.kap_padresust is not null and KARDESPEDTemp.kap_padresust>0) and kap_fiscomp<>'N'))
AND dbo.KARDESPEDTemp.KAP_CODIGO IN
 (SELECT MAX(KARDESPEDtemp2.KAP_CODIGO) FROM KARDESPEDtemp KARDESPEDtemp2 WHERE (KARDESPEDtemp2.KAP_FACTRANS = KARDESPEDtemp.KAP_FACTRANS) AND (KARDESPEDtemp2.KAP_INDICED_FACT = KARDESPEDtemp.KAP_INDICED_FACT)
			        GROUP BY KARDESPEDtemp2.MA_HIJO)
UNION
SELECT   dbo.KARDESPEDTemp.*
FROM         dbo.KARDESPEDTemp
WHERE   kap_Saldo_fed > 0 AND ((KAP_ESTATUS = 'P' OR KAP_ESTATUS = 'N' OR KAP_ESTATUS = 'B') AND KAP_PADRESUST NOT IN
	(SELECT kardesped1.KAP_PADRESUST FROM KARDESPEDTemp kardesped1 
	 WHERE kardesped1.KAP_SALDO_FED=0  AND (kardesped1.KAP_PADRESUST <> 0 AND kardesped1.KAP_PADRESUST IS NOT NULL) AND kardesped1.KAP_INDICED_FACT=KARDESPEDTemp.KAP_INDICED_FACT)
	and kap_fiscomp='N')
AND dbo.KARDESPEDTemp.KAP_CODIGO IN
 (SELECT MAX(KARDESPEDtemp2.KAP_CODIGO) FROM KARDESPEDtemp KARDESPEDtemp2 WHERE (KARDESPEDtemp2.KAP_FACTRANS = KARDESPEDtemp.KAP_FACTRANS) AND (KARDESPEDtemp2.KAP_INDICED_FACT = KARDESPEDtemp.KAP_INDICED_FACT)
			        GROUP BY KARDESPEDtemp2.MA_HIJO)






GO
