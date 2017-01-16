SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO














-- vista que muestra todos los numeros de parte que no tienen BOM, no se encontro cantidad suficiente o definitivamente no se encontraron en pedimentos al momento de descargar
CREATE VIEW dbo.VKARDESPEDN
with encryption as
SELECT    KAP_CODIGO, KAP_FACTRANS, KAP_INDICED_FACT, KAP_INDICED_PED, MA_HIJO, KAP_TIPO_DESC, KAP_ESTATUS, round(KAP_CantTotADescargar-KAP_Saldo_FED,6) as KAP_CANTDESC, 
                      KAP_CantTotADescargar, KAP_Saldo_FED, KAP_PADRESUST, KAP_CONTESTATUS, KAP_FISCOMP, KAP_PADREMAIN
FROM         KARDESPED
WHERE
   KAP_SALDO_FED > 0 AND
   ((KAP_ESTATUS = 'N' OR KAP_ESTATUS = 'B') OR
    (KAP_ESTATUS = 'P'
     and KAP_CODIGO in (SELECT MAX(KARDESPED1.KAP_CODIGO)
                        FROM KARDESPED KARDESPED1
                        WHERE
                           KARDESPED1.KAP_INDICED_FACT = KARDESPED.KAP_INDICED_FACT
                           and KARDESPED1.KAP_CantTotADescargar = KARDESPED.KAP_CantTotADescargar
                        GROUP BY
                           CASE WHEN ISNULL(KARDESPED1.KAP_PADRESUST,0)=0
                              THEN KARDESPED1.MA_HIJO
                              ELSE KARDESPED1.KAP_PADRESUST
                           END)))

-- en versión 2.0.0.33 se usaban estas condiciones más 2 uniones
/*
WHERE (SELECT CF_DESCARGASBUS FROM CONFIGURACION)='I'
AND KAP_INDICED_PED IS NULL AND kap_Saldo_fed > 0 AND (((KAP_ESTATUS = 'P' OR KAP_ESTATUS = 'N') AND KAP_INDICED_FACT NOT IN
                          (SELECT     KARDESPED1.kap_indiced_fact
                            FROM          KARDESPED KARDESPED1
                            WHERE      KARDESPED1.ma_hijo = KARDESPED.ma_hijo AND KARDESPED1.kap_estatus = 'D' AND KARDESPED1.kap_factrans = KARDESPED.kap_factrans)
		and (KARDESPED.kap_padresust is null or KARDESPED.kap_padresust=0) and KARDESPED.kap_fiscomp='N')
	or ((KAP_ESTATUS = 'P' OR
                      KAP_ESTATUS = 'N') AND 
			KAP_INDICED_FACT NOT IN
                          (SELECT     KARDESPED2.kap_indiced_fact
                            FROM          KARDESPED KARDESPED2
                            WHERE      KARDESPED2.ma_hijo = KARDESPED.ma_hijo AND KARDESPED2.kap_estatus = 'D' AND KARDESPED2.kap_factrans = KARDESPED.kap_factrans)
		and (KARDESPED.kap_padresust is not null and KARDESPED.kap_padresust>0) and KARDESPED.kap_fiscomp<>'N'))

UNION
SELECT    KAP_CODIGO, KAP_FACTRANS, KAP_INDICED_FACT, KAP_INDICED_PED, MA_HIJO, KAP_TIPO_DESC, KAP_ESTATUS, round(KAP_CantTotADescargar-KAP_Saldo_FED,6) as KAP_CANTDESC, 
                      KAP_CantTotADescargar, KAP_Saldo_FED, KAP_PADRESUST, KAP_CONTESTATUS, KAP_FISCOMP, KAP_PADREMAIN
FROM         dbo.KARDESPED
WHERE   (SELECT CF_DESCARGASBUS FROM CONFIGURACION)='I' AND kap_Saldo_fed > 0 AND ((KAP_ESTATUS = 'P' OR KAP_ESTATUS = 'N' OR KAP_ESTATUS = 'B') AND KAP_PADRESUST NOT IN
	(SELECT kardesped1.KAP_PADRESUST FROM KARDESPED kardesped1 
	 WHERE kardesped1.KAP_SALDO_FED=0  AND (kardesped1.KAP_PADRESUST <> 0 AND kardesped1.KAP_PADRESUST IS NOT NULL) AND kardesped1.KAP_INDICED_FACT=KARDESPED.KAP_INDICED_FACT)
	and kap_fiscomp='N')
AND dbo.KARDESPED.KAP_CODIGO IN
 (SELECT MAX(KARDESPED2.KAP_CODIGO) FROM KARDESPED KARDESPED2 WHERE (KARDESPED2.KAP_FACTRANS = KARDESPED.KAP_FACTRANS) AND (KARDESPED2.KAP_INDICED_FACT = KARDESPED.KAP_INDICED_FACT)
			        GROUP BY KARDESPED2.MA_HIJO)
UNION
SELECT    KAP_CODIGO, KAP_FACTRANS, KAP_INDICED_FACT, KAP_INDICED_PED, MA_HIJO, KAP_TIPO_DESC, KAP_ESTATUS, round(KAP_CantTotADescargar-KAP_Saldo_FED,6) as KAP_CANTDESC, 
                      KAP_CantTotADescargar, KAP_Saldo_FED, KAP_PADRESUST, KAP_CONTESTATUS, KAP_FISCOMP, KAP_PADREMAIN
FROM         KARDESPED
WHERE (SELECT CF_DESCARGASBUS FROM CONFIGURACION)='G'
AND KAP_INDICED_PED IS NULL AND kap_Saldo_fed > 0 AND ((KAP_ESTATUS = 'N' OR KAP_ESTATUS = 'B') OR
(KAP_ESTATUS = 'P'
and kap_codigo in (SELECT MAX(KARDESPED1.KAP_CODIGO) FROM KARDESPED KARDESPED1 WHERE (KARDESPED1.KAP_FACTRANS = KARDESPED.KAP_FACTRANS) AND (KARDESPED1.KAP_INDICED_FACT = KARDESPED.KAP_INDICED_FACT)
		   GROUP BY KARDESPED1.KAP_PADRESUST)))
*/

GO
