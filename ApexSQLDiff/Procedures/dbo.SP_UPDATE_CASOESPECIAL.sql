SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

















CREATE PROCEDURE [dbo].[SP_UPDATE_CASOESPECIAL] (@fe_codigo int)   as

declare @fe_fecha varchar(11)
--Procedimiento especial para Schneider Monterrey

	select @fe_fecha=convert(varchar(11),fe_fecha,101) from factexp where fe_codigo=@fe_codigo

update factexpdet set ar_expmx = (select ar_codigo from arancel where ar_fraccion = '85371001') , 
                      ar_impfo = (select ar_codigo from arancel where ar_fraccion = '8537109070'),
                      fed_name = 'STARTER MOTOR CONTROL<1000V',
                      fed_nombre = 'CAJA DE ARRANCADOR'
from factexpdet 
where (    fed_noparte like '8536%V%C%'
       or fed_noparte like '8537%V%C%'
       or fed_noparte like '8538%V%C%' 
       or fed_noparte like '8539%V%C%'
       or fed_noparte like '8736%V%C%'
       or fed_noparte like '8810%V%C%'
       or fed_noparte like '8738%V%C%'
       or fed_noparte like '8739%V%C%'

       or fed_noparte like '8536%V%F4T%'
       or fed_noparte like '8537%V%F4T%'
       or fed_noparte like '8538%V%F4T%' 
       or fed_noparte like '8539%V%F4T%'
       or fed_noparte like '8736%V%F4T%'
       or fed_noparte like '8810%V%F4T%'
       or fed_noparte like '8738%V%F4T%'
       or fed_noparte like '8739%V%F4T%'

       or fed_noparte like '8536%V%FF4T%'
       or fed_noparte like '8537%V%FF4T%'
       or fed_noparte like '8538%V%FF4T%' 
       or fed_noparte like '8539%V%FF4T%'
       or fed_noparte like '8736%V%FF4T%'
       or fed_noparte like '8810%V%FF4T%'
       or fed_noparte like '8738%V%FF4T%'
       or fed_noparte like '8739%V%FF4T%'

       or fed_noparte like '8536%V%F%'
       or fed_noparte like '8537%V%F%'
       or fed_noparte like '8538%V%F%' 
       or fed_noparte like '8539%V%F%'
       or fed_noparte like '8736%V%F%'
       or fed_noparte like '8810%V%F%'
       or fed_noparte like '8738%V%F%'
       or fed_noparte like '8739%V%F%')

    and fe_codigo=@fe_codigo


update factexpdet set ar_expmx = (select ar_codigo from arancel where ar_fraccion = '85365013') , 
                      ar_impfo = (select ar_codigo from arancel where ar_fraccion = '8536504000'),
                      fed_name = 'MOTOR STARTER<1000V',
                      fed_nombre = 'ARRANCADOR'
from factexpdet 
where      fed_noparte not like '8536%V%C%'
       and fed_noparte not like '8537%V%C%'
       and fed_noparte not like '8538%V%C%' 
       and fed_noparte not like '8539%V%C%'
       and fed_noparte not like '8736%V%C%'
       and fed_noparte not like '8810%V%C%'
       and fed_noparte not like '8738%V%C%'
       and fed_noparte not like '8739%V%C%'

       and fed_noparte not like '8536%V%F4T%'
       and fed_noparte not like '8537%V%F4T%'
       and fed_noparte not like '8538%V%F4T%' 
       and fed_noparte not like '8539%V%F4T%'
       and fed_noparte not like '8736%V%F4T%'
       and fed_noparte not like '8810%V%F4T%'
       and fed_noparte not like '8738%V%F4T%'
       and fed_noparte not like '8739%V%F4T%'

       and fed_noparte not like '8536%V%FF4T%'
       and fed_noparte not like '8537%V%FF4T%'
       and fed_noparte not like '8538%V%FF4T%' 
       and fed_noparte not like '8539%V%FF4T%'
       and fed_noparte not like '8736%V%FF4T%'
       and fed_noparte not like '8810%V%FF4T%'
       and fed_noparte not like '8738%V%FF4T%'
       and fed_noparte not like '8739%V%FF4T%'

       and fed_noparte not like '8536%V%F%'
       and fed_noparte not like '8537%V%F%'
       and fed_noparte not like '8538%V%F%' 
       and fed_noparte not like '8539%V%F%'
       and fed_noparte not like '8736%V%F%'
       and fed_noparte not like '8810%V%F%'
       and fed_noparte not like '8738%V%F%'
       and fed_noparte not like '8739%V%F%'

       and fed_noparte like '8536%V%'
       and fed_noparte like '8537%V%'
       and fed_noparte like '8538%V%' 
       and fed_noparte like '8539%V%'
       and fed_noparte like '8736%V%'
       and fed_noparte like '8810%V%'
       and fed_noparte like '8738%V%'
       and fed_noparte like '8739%V%'

       and fed_noparte like '8536%V%'
       and fed_noparte like '8537%V%'
       and fed_noparte like '8538%V%' 
       and fed_noparte like '8539%V%'
       and fed_noparte like '8736%V%'
       and fed_noparte like '8810%V%'
       and fed_noparte like '8738%V%'
       and fed_noparte like '8739%V%'

       and fed_noparte like '8536%V%'
       and fed_noparte like '8537%V%'
       and fed_noparte like '8538%V%' 
       and fed_noparte like '8539%V%'
       and fed_noparte like '8736%V%'
       and fed_noparte like '8810%V%'
       and fed_noparte like '8738%V%'
       and fed_noparte like '8739%V%'

       and fed_noparte like '8536%V%'
       and fed_noparte like '8537%V%'
       and fed_noparte like '8538%V%' 
       and fed_noparte like '8539%V%'
       and fed_noparte like '8736%V%'
       and fed_noparte like '8810%V%'
       and fed_noparte like '8738%V%'
       and fed_noparte like '8739%V%'

       and fe_codigo=@fe_codigo


update factexpdet set ar_expmx = (select ar_codigo from arancel where ar_fraccion = '85364902') , 
                      ar_impfo = (select ar_codigo from arancel where ar_fraccion = '8536490065'),
                      fed_name = 'CONTACTOR<1000V',
                      fed_nombre = 'CONTACTOR'
from factexpdet 
where(fed_noparte like '8505%'
   or fed_noparte like '8702%'
   or fed_noparte like '8903%')
  and fe_codigo=@fe_codigo


update factexpdet set ar_expmx = (select ar_codigo from arancel where ar_fraccion = '85371001') , 
                      ar_impfo = (select ar_codigo from arancel where ar_fraccion = '8537109070'),
                      fed_name = 'LA DEL PACKING',
                      fed_nombre = 'PANEL DEL CONTROL'
from factexpdet 
where (fed_noparte like '8940%'
   or fed_noparte like '8941%')
  and fe_codigo=@fe_codigo



update factexpdet set ma_generico=(select ma_codigo from maestro where ma_inv_gen='G' and ma_noparte='PIEZA'),
                      me_generico = 19,
                      eq_gen = 1
from factexpdet 
where me_codigo=19
  and fe_codigo=@fe_codigo


		update factexpdet
		set fed_nafta=(CASE WHEN factexpdet.MA_CODIGO=0 then
					(case when factexpdet.fed_noparte in 
	                                (SELECT NAFTA.MA_CODIGO FROM NAFTA INNER JOIN SPI ON NAFTA.SPI_CODIGO = SPI.SPI_CODIGO WHERE SPI.SPI_CLAVE = 'NAFTA' 
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
	                                  THEN 'S' ELSE (CASE WHEN factexpdet.pa_codigo in (SELECT CF_PAIS_USA FROM CONFIGURACION) AND fed_def_tip='P' THEN 'S' 
	                                 ELSE 'N' END) END) end)  end)
               from factexpdet where fe_codigo=@fe_codigo

GO
