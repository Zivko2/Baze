SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW dbo.VFillPedExpDetDesp
with encryption as
SELECT
   FACTEXPDET.FED_INDICED,
   FACTEXPDET.MA_CODIGO,
   FACTEXPDET.FED_NOPARTE,
   FACTEXPDET.FED_NOMBRE,
   FACTEXPDET.FED_NAME,
   convert(decimal(28,14),(CASE WHEN FACTEXP.TQ_CODIGO IN (SELECT TQ_CODIGO FROM CONFIGURATEMBARQUE WHERE CFQ_TIPO = 'D') 
              AND (SELECT CF_PEDDESPKG FROM CONFIGURACION) = 'S'
       THEN (CASE WHEN FACTEXPDET.FED_PES_BRU> FACTEXPDET.FED_PES_NET AND FACTEXPDET.FED_PES_BRU>0
                THEN FACTEXPDET.FED_PES_BRU
                ELSE (CASE WHEN FACTEXPDET.FED_PES_NET > 0
                         THEN FACTEXPDET.FED_PES_NET
                         ELSE 1
                      END)
             END)
       ELSE FACTEXPDET.FED_CANT
   END)) AS 'FED_CANT',
   (CASE WHEN FACTEXP.TQ_CODIGO IN (SELECT TQ_CODIGO FROM CONFIGURATEMBARQUE WHERE CFQ_TIPO = 'D')
               AND (SELECT CF_PEDDESPKG FROM CONFIGURACION) = 'S'
        THEN 36
        ELSE FACTEXPDET.ME_CODIGO
     END) AS ME_CODIGO, 
   (CASE WHEN FACTEXP.TQ_CODIGO IN (SELECT TQ_CODIGO FROM CONFIGURATEMBARQUE WHERE CFQ_TIPO = 'D') 
	       AND (SELECT CF_PEDDESPKG FROM CONFIGURACION)='S'
       THEN (CASE WHEN FACTEXPDET.ME_GENERICO=36
                THEN FACTEXPDET.MA_GENERICO
                ELSE 0
             END)
                ELSE FACTEXPDET.MA_GENERICO END) AS MA_GENERICO,
   (CASE WHEN FACTEXP.TQ_CODIGO IN (SELECT TQ_CODIGO FROM CONFIGURATEMBARQUE WHERE CFQ_TIPO = 'D') 
	       AND (SELECT CF_PEDDESPKG FROM CONFIGURACION)='S'
       THEN (CASE WHEN FACTEXPDET.ME_GENERICO = 36
                THEN FACTEXPDET.EQ_GEN
                ELSE 1
             END)
       ELSE FACTEXPDET.EQ_GEN
    END) AS EQ_GEN,
   FACTEXPDET.EQ_EXPMX,
   ISNULL(FACTEXPDET.AR_EXPMX, 0) AS AR_EXPMX,
   ISNULL(FACTEXPDET.AR_IMPFO, 0) AS AR_IMPFO,
   (case when (select cf_pagocontribucion from configuracion) = 'J'
       then 0
       else FACTEXPDET.FED_RATEIMPFO
    end) as FED_RATEIMPFO,
   'FED_DEF_TIP' = CASE WHEN FACTEXP.TQ_CODIGO IN (SELECT TQ_CODIGO FROM CONFIGURATEMBARQUE WHERE CFQ_TIPO = 'D')
                      THEN 'S'
                      ELSE 'N'
                   END,
   FACTEXPDET.TI_CODIGO,
   'SPI_CODIGO' = CASE WHEN FED_DEF_TIP <> 'P' OR FE_TIPO <> 'V'
                     THEN 0
                     ELSE FACTEXPDET.SPI_CODIGO
                  END,
   (CASE WHEN FACTEXP.TQ_CODIGO IN (SELECT TQ_CODIGO FROM CONFIGURATEMBARQUE WHERE CFQ_TIPO = 'D')
              AND (SELECT CF_PEDDESPKG FROM CONFIGURACION) = 'S'
       THEN (CASE WHEN FACTEXPDET.ME_GENERICO = 36
                THEN FACTEXPDET.ME_GENERICO
                ELSE 36
             END)
       ELSE FACTEXPDET.ME_GENERICO
    END) AS ME_GENERICO,
   FACTEXPDET.PA_CODIGO,
   --/*FACTEXPDET.EQ_SALDO*/FACTEXPDET.EQ_GEN,
   --/*FACTEXPDET.ME_SALDO*/FACTEXPDET.ME_GENERICO,
   'PID_PES_UNIKG' = case when isnull(FED_CANT, 0) > 0
                        then (case when FED_PES_NET = 0
                                 then ROUND(FED_PES_BRU / isnull(FED_CANT, 0), 6)
                                 else ROUND(FED_PES_NET/isnull(FED_CANT, 0), 10)
                              end)
                        else 0
                     end,
   round(FED_GRA_MO + FED_GRA_GI_MX + FED_NG_MX, 6) AS PID_COS_UNIVAUSD,
   round(FED_GRA_MO + FED_GRA_GI_MX + FED_GRA_GI + FED_NG_MX, 6) AS PID_COS_UNIVAUSDGI,
   round(FACTEXPDET.FED_COS_TOT + (FACTEXPDET.FED_COS_TOT * isnull((SELECT sum(FACTEXPDETCARGO.FEG_VALOR) / 100
                                                                    FROM FACTEXPDETCARGO
                                                                    WHERE
                                                                       FACTEXPDETCARGO.FED_INDICED = FACTEXPDET.FED_INDICED
                                                                       AND FEG_TIPO = 'T'),0)),6,6) as FED_COS_TOT,
   round(FACTEXPDET.FED_GRA_GI + (FACTEXPDET.FED_GRA_GI * isnull((SELECT sum(FACTEXPDETCARGO.FEG_VALOR) / 100
                                                                  FROM FACTEXPDETCARGO
                                                                  WHERE
                                                                     FACTEXPDETCARGO.FED_INDICED = FACTEXPDET.FED_INDICED
                                                                     AND FEG_TIPO = 'T'), 0)), 6, 6) as FED_GRA_GI,
   round(FACTEXPDET.FED_NG_EMP + (FACTEXPDET.FED_NG_EMP * isnull((SELECT sum(FACTEXPDETCARGO.FEG_VALOR) / 100
                                                                  FROM FACTEXPDETCARGO
                                                                  WHERE
                                                                     FACTEXPDETCARGO.FED_INDICED = FACTEXPDET.FED_INDICED
                                                                     AND FEG_TIPO = 'T'), 0)), 6, 6) as FED_NG_EMP,
   round(FACTEXPDET.FED_GRA_MO + (FACTEXPDET.FED_GRA_MO * isnull((SELECT sum(FACTEXPDETCARGO.FEG_VALOR) / 100
                                                                  FROM FACTEXPDETCARGO
                                                                  WHERE
                                                                     FACTEXPDETCARGO.FED_INDICED = FACTEXPDET.FED_INDICED
                                                                     AND FEG_TIPO = 'T'), 0)), 6, 6) as FED_GRA_MO,
   round(FACTEXPDET.FED_GRA_GI_MX + (FACTEXPDET.FED_GRA_GI_MX * isnull((SELECT sum(FACTEXPDETCARGO.FEG_VALOR) / 100
                                                                        FROM FACTEXPDETCARGO
                                                                        WHERE
                                                                           FACTEXPDETCARGO.FED_INDICED = FACTEXPDET.FED_INDICED
                                                                           AND FEG_TIPO = 'T'), 0)), 6, 6) as FED_GRA_GI_MX,
   round(FACTEXPDET.FED_GRA_EMP + (FACTEXPDET.FED_GRA_EMP * isnull((SELECT sum(FACTEXPDETCARGO.FEG_VALOR) / 100
                                                                    FROM FACTEXPDETCARGO
                                                                    WHERE
                                                                       FACTEXPDETCARGO.FED_INDICED = FACTEXPDET.FED_INDICED
                                                                       AND FEG_TIPO = 'T'), 0)), 6, 6) as FED_GRA_EMP,
   round(FACTEXPDET.FED_GRA_ADD + (FACTEXPDET.FED_GRA_ADD * isnull((SELECT sum(FACTEXPDETCARGO.FEG_VALOR) / 100
                                                                    FROM FACTEXPDETCARGO
                                                                    WHERE
                                                                       FACTEXPDETCARGO.FED_INDICED = FACTEXPDET.FED_INDICED
                                                                       AND FEG_TIPO = 'T'), 0)), 6, 6) as FED_GRA_ADD,
   round(FACTEXPDET.FED_GRA_MP + (FACTEXPDET.FED_GRA_MP * isnull((SELECT sum(FACTEXPDETCARGO.FEG_VALOR) / 100
                                                                  FROM FACTEXPDETCARGO
                                                                  WHERE
                                                                     FACTEXPDETCARGO.FED_INDICED = FACTEXPDET.FED_INDICED
                                                                     AND FEG_TIPO = 'T'), 0)), 6, 6) as FED_GRA_MP,
   round(FACTEXPDET.FED_NG_MP + (FACTEXPDET.FED_NG_MP * isnull((SELECT sum(FACTEXPDETCARGO.FEG_VALOR) / 100
                                                                FROM FACTEXPDETCARGO
                                                                WHERE
                                                                   FACTEXPDETCARGO.FED_INDICED = FACTEXPDET.FED_INDICED
                                                                   AND FEG_TIPO = 'T'), 0)), 6, 6) as FED_NG_MP,
   round(FACTEXPDET.FED_NG_ADD + (FACTEXPDET.FED_NG_ADD * isnull((SELECT sum(FACTEXPDETCARGO.FEG_VALOR) / 100
                                                                  FROM FACTEXPDETCARGO
                                                                  WHERE
                                                                     FACTEXPDETCARGO.FED_INDICED = FACTEXPDET.FED_INDICED
                                                                     AND FEG_TIPO = 'T'), 0)), 6, 6) as FED_NG_ADD,
   round(isnull(FACTEXPDET.FED_NG_USA, 0) + (FACTEXPDET.FED_NG_USA * isnull((SELECT sum(FACTEXPDETCARGO.FEG_VALOR) / 100
                                                                             FROM FACTEXPDETCARGO
                                                                             WHERE
                                                                                FACTEXPDETCARGO.FED_INDICED = FACTEXPDET.FED_INDICED
                                                                                AND FEG_TIPO = 'T'), 0)), 6, 6) as FED_NG_USA,
   round(isnull(FACTEXPDET.FED_NG_MX, 0) + (FACTEXPDET.FED_NG_MX * isnull((SELECT sum(FACTEXPDETCARGO.FEG_VALOR) / 100
                                                                           FROM FACTEXPDETCARGO
                                                                           WHERE
                                                                              FACTEXPDETCARGO.FED_INDICED = FACTEXPDET.FED_INDICED
                                                                              AND FEG_TIPO = 'T'), 0)), 6, 6) as FED_NG_MX,
   FACTEXPDET.SE_CODIGO,
   FACTEXPDET.FED_NOPARTEAUX,
   FACTEXPDET.FE_CODIGO,
   FACTEXPDET.FED_ORD_COMP,
   ARANCEL.AR_FRACCION,
   FED_GENERA_EMPDET,
   FACTEXPDET.FED_PES_BRU,
   convert(decimal(28,14),FACTEXPDET.FED_PES_NET) FED_PES_NET,
   ISNULL(ME_AREXPMX,0) AS ME_AREXPMX,
   ISNULL(FED_PIDSECUENCIA, 0) FED_PIDSECUENCIA,
   MA_SERVICIO
FROM
   FACTEXPDET RIGHT OUTER JOIN FACTEXP
      ON FACTEXPDET.FE_CODIGO = FACTEXP.FE_CODIGO
   LEFT OUTER JOIN ARANCEL
      ON FACTEXPDET.AR_EXPMX = ARANCEL.AR_CODIGO
   LEFT OUTER JOIN MAESTRO
      ON FACTEXPDET.MA_CODIGO = MAESTRO.MA_CODIGO

GO
