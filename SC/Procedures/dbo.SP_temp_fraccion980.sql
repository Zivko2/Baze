SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE [dbo].[SP_temp_fraccion980]   as

SET NOCOUNT ON 



	UPDATE dbo.FACTIMP
	SET     dbo.FACTIMP.PI_RECTIFICA= dbo.PEDIMPRECT.PI_NO_RECT
	FROM         dbo.FACTIMP INNER JOIN
	                      dbo.PEDIMP ON dbo.FACTIMP.PI_CODIGO = dbo.PEDIMP.PI_CODIGO INNER JOIN
	                      dbo.PEDIMPRECT ON dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPRECT.PI_CODIGO
	WHERE     (dbo.FACTIMP.PI_CODIGO = dbo.FACTIMP.PI_RECTIFICA) AND (dbo.PEDIMP.PI_ESTATUS = 'R')



	print 'actualizando fed_destnafta'
	UPDATE dbo.FACTEXPDET
	SET     dbo.FACTEXPDET.FED_DESTNAFTA= CASE 
	when dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT CF_PAIS_MX FROM CONFIGURACION) THEN 'M'
	 when dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT CF_PAIS_USA FROM CONFIGURACION) or dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT CF_PAIS_CA FROM CONFIGURACION)
	then 'N'  WHEN 	  dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT PA_CODIGO FROM PAIS WHERE SPI_CODIGO IN ( SELECT SPI_CODIGO FROM SPI WHERE SPI_CLAVE='MX-UE')) 
	then 'U' when 	  dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT PA_CODIGO FROM PAIS WHERE SPI_CODIGO IN ( SELECT SPI_CODIGO FROM SPI WHERE SPI_CLAVE='AELC')) 
	then 'A'  else 'F' end
	FROM         dbo.FACTEXPDET INNER JOIN
	                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO LEFT OUTER JOIN
	                      dbo.DIR_CLIENTE ON dbo.FACTEXP.DI_DESTFIN = dbo.DIR_CLIENTE.DI_INDICE
	WHERE     (dbo.FACTEXPDET.FED_DESTNAFTA is null)


	print 'actualizando pid_pagacontrib'

	update PEDIMPDET
	set  pid_pagacontrib='N'
	where (pa_origen in (SELECT CF_PAIS_MX FROM CONFIGURACION) and PID_DEF_TIP = 'P') or
	(pa_origen in (SELECT CF_PAIS_CA FROM CONFIGURACION) and PID_DEF_TIP = 'P') or
	(pa_origen in (SELECT CF_PAIS_USA FROM CONFIGURACION) and PID_DEF_TIP = 'P') or
	ti_codigo in (SELECT TI_CODIGO FROM TIPO WHERE TI_PAGACONTRIB='N')


	print 'actualizando ar_orig'
	update factexpdet
	set ar_orig= isnull((select max(ar_codigo) from bom_arancel where ma_codigo=factexpdet.ma_codigo and ba_tipocosto='2'),0)
	where (ar_orig is null or ar_orig =0) and fed_retrabajo<>'R' and ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')
	

	update factexpdet
	set ar_orig= isnull((select ar_impfo from maestro where ma_codigo=factexpdet.ma_codigo),0)
	where (ar_orig is null or ar_orig =0) and fed_retrabajo='R' 

	print 'actualizando ar_ng_emp'	
	update factexpdet
	set ar_ng_emp= isnull((select max(ar_codigo) from bom_arancel where ma_codigo=factexpdet.ma_codigo and ba_tipocosto='3'),0)
	where (ar_ng_emp is null or ar_ng_emp =0) and fed_retrabajo<>'R' and ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')



























GO
