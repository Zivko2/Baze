SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





























CREATE PROCEDURE [dbo].[SP_ACTUALIZAFACTEXPNAFTA] (@FE_CODIGO  INT)   as

DECLARE @fe_fecha VARCHAR(11)

	SELECT @fe_fecha = CONVERT(VARCHAR(11),FE_FECHA,101) FROM FACTEXP WHERE FE_CODIGO=@FE_CODIGO

		update factexpdet
		set fed_nafta=(CASE WHEN factexpdet.MA_CODIGO=0 then
					(case when factexpdet.fed_noparte in 
	                                (SELECT NAFTA.NFT_NOPARTE FROM NAFTA INNER JOIN SPI ON NAFTA.SPI_CODIGO = SPI.SPI_CODIGO WHERE SPI.SPI_CLAVE = 'NAFTA' 
	                                 and NFT_CALIFICO='S' and NFT_PERINI<=@fe_fecha AND NFT_PERFIN>=@fe_fecha AND NAFTA.NFT_NOPARTE=factexpdet.fed_noparte and nafta.nft_noparteaux=factexpdet.fed_noparteaux) 
	                                 and TI_CODIGO IN (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S') AND (fed_tip_ens='F' or fed_tip_ens='E')
	                                 then 'S' else 'N' end)
                                else
				(case when factexpdet.MA_CODIGO in 
	                                (SELECT NAFTA.MA_CODIGO FROM NAFTA INNER JOIN SPI ON NAFTA.SPI_CODIGO = SPI.SPI_CODIGO WHERE SPI.SPI_CLAVE = 'NAFTA' 
	                                 and NFT_CALIFICO='S' and NFT_PERINI<=@fe_fecha AND NFT_PERFIN>=@fe_fecha AND NAFTA.MA_CODIGO=factexpdet.MA_CODIGO) 
	                                 and TI_CODIGO IN (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S') AND (fed_tip_ens='F' or fed_tip_ens='E')
	                                 then 'S' else (CASE WHEN TI_CODIGO NOT IN (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S') AND
			       factexpdet.MA_CODIGO in (SELECT CERTORIGMPDET.MA_CODIGO 
	                                 FROM  CERTORIGMPDET INNER JOIN CERTORIGMP ON CERTORIGMPDET.CMP_CODIGO = CERTORIGMP.CMP_CODIGO
	                                 WHERE CERTORIGMP.CMP_TIPO<> 'P' and LEFT(REPLACE(CERTORIGMPDET.CMP_FRACCION,'.',''),6) IN (SELECT LEFT(REPLACE(A1.AR_FRACCION,'.',''),6) FROM ARANCEL A1 WHERE AR_CODIGO=factexpdet.Ar_ExpMx) 
	                                  AND CERTORIGMP.CMP_ESTATUS='V' AND CERTORIGMPDET.PA_CLASE = factexpdet.pa_codigo 
	                                  AND  CERTORIGMP.SPI_CODIGO IN (SELECT spi_codigo FROM spi  WHERE spi_clave = 'NAFTA') 
	                                  AND CERTORIGMP.CMP_IFECHA<=@fe_fecha AND CERTORIGMP.CMP_FECHATRANS>=@fe_fecha AND CERTORIGMPDET.MA_CODIGO=factexpdet.MA_CODIGO) 
	                                  THEN 'S' ELSE (CASE WHEN FACTEXPDET.PA_CODIGO in (SELECT CF_PAIS_USA FROM CONFIGURACION) AND (select CF_CONFERIRORIGEN FROM CONFIGURACION)='T' 
					AND FED_DEF_TIP='P' THEN 'S' 
		                                 ELSE 'N' END) END) end)  end)
               from factexpdet where fe_codigo=@fe_codigo

GO
