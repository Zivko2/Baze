SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_ACTUALIZATIPOCOSTOCLASIFICATLCRango] (@spi_codigo int)   as

SET NOCOUNT ON 
DECLARE @spi_codigo2 int



	IF (SELECT SPI_CODIGO FROM SPI WHERE SPI_CLAVE='MX' )= @spi_codigo
	SELECT @spi_codigo2= SPI_CODIGO FROM SPI WHERE SPI_CLAVE='NAFTA'
	ELSE
	SET @spi_codigo2=@spi_codigo



	exec sp_droptable 'TempBomGravableTlc'

	exec sp_droptable 'TempPaisTLC'

	select pa_codigo 
	into TempPaisTLC
	from pais where (spi_codigo=@spi_codigo OR spi_codigo=@spi_codigo2) and pa_codigo<>233



	if (SELECT CF_CONFERIRORIGEN FROM CONFIGURACION)='C' 
	begin
		SELECT  CLASIFICATLC.CLT_CODIGO, 
		esGravable=case when (bst_trans = 'N') and bst_hijo in (SELECT CERTORIGMPDET.MA_CODIGO
					         FROM  CERTORIGMPDET INNER JOIN CERTORIGMP ON CERTORIGMPDET.CMP_CODIGO = CERTORIGMP.CMP_CODIGO 
					         WHERE (CERTORIGMP.SPI_CODIGO = @spi_codigo OR CERTORIGMP.SPI_CODIGO = @spi_codigo2)  and CERTORIGMPDET.PA_CLASE=CLASIFICATLC.pa_codigo 
						and LEFT(REPLACE(CERTORIGMPDET.CMP_FRACCION,'.',''),6)=LEFT(REPLACE((SELECT AR_FRACCION FROM ARANCEL WHERE AR_CODIGO=CLASIFICATLC.AR_CODIGO),'.',''),6)
						 AND CERTORIGMP.CMP_ESTATUS='V' AND CERTORIGMP.CMP_IFECHA <= CLASIFICATLC.bst_entravigor AND CERTORIGMP.CMP_VFECHA >= CLASIFICATLC.bst_entravigor) then
	  				         (case when CLASIFICATLC.pa_codigo  in (SELECT pa_codigo FROM TempPaisTLC) then
						(case when maestro.ma_consta='S' then 'Z' else 'X' end) else 'N' end) else (case when ma_servicio='S' then 'X' else 'S' end) end,
		esAnadido=case when MAESTRO.MA_REPARA <>'A' then 'N' else 'S' end,
			esMP=case when CLASIFICATLC.TI_CODIGO in ('R', 'L', 'M', 'O') or (CLASIFICATLC.TI_CODIGO ='S' and (CLASIFICATLC.MA_TIP_ENS='C' or CLASIFICATLC.MA_TIP_ENS='A')) then 'S' else 'N' end,
			esSUB=case when CLASIFICATLC.TI_CODIGO ='S' and CLASIFICATLC.MA_TIP_ENS<>'C' then 'S' else 'N' end,  'Z' as bst_tipocosto
			into TempBomGravableTlc
			FROM         CLASIFICATLC INNER JOIN
			                      MAESTRO ON CLASIFICATLC.BST_HIJO = MAESTRO.MA_CODIGO 
			WHERE NFT_CODIGO in (select nft_codigo from ##macodigo)
	end
	else
	begin
		SELECT  CLASIFICATLC.CLT_CODIGO, 
		esGravable=CASE WHEN bst_trans = 'N' and (MAESTRO.ma_def_tip='P' and (MAESTRO.spi_codigo=@spi_codigo OR MAESTRO.spi_codigo=@spi_codigo2)) then
		(case when CLASIFICATLC.pa_codigo in (SELECT pa_codigo FROM TempPaisTLC) then
		  (case when maestro.ma_consta='S' then 'Z' else 'X' end) else 'N' end) 
		else
		(case when MAESTRO.ma_servicio='S' then 'X' else 'S' end)
		end, esAnadido=case when MAESTRO.MA_REPARA <>'A' then 'N' else 'S' end,
		esMP=case when CLASIFICATLC.TI_CODIGO in ('R', 'L', 'M', 'O') or (CLASIFICATLC.TI_CODIGO ='S' and (CLASIFICATLC.MA_TIP_ENS='C' or CLASIFICATLC.MA_TIP_ENS='A')) then 'S' else 'N' end,
		esSUB=case when CLASIFICATLC.TI_CODIGO ='S' and CLASIFICATLC.MA_TIP_ENS<>'C' then 'S' else 'N' end, 'Z' as bst_tipocosto
		into TempBomGravableTlc
		FROM         CLASIFICATLC INNER JOIN
		                      MAESTRO ON CLASIFICATLC.BST_HIJO = MAESTRO.MA_CODIGO 
		WHERE NFT_CODIGO in (select nft_codigo from ##macodigo)

	end	


	

	

	
	/* Se asigna el tipo de costo */   


	update TempBomGravableTlc
	set bst_tipocosto='A'
	where esMP = 'S' and esGravable = 'S' and esAnadido = 'N' 
	
	
	update TempBomGravableTlc
	set bst_tipocosto='B'
	where esMP = 'S' and esGravable = 'S' and esAnadido = 'S' 
	
	
	update TempBomGravableTlc
	set bst_tipocosto='C'
	where esMP = 'S' and esGravable = 'N' and esAnadido = 'N' 
	
	
	update TempBomGravableTlc
	set bst_tipocosto='D'
	where esMP = 'S' and esGravable = 'N' and esAnadido = 'S' 
	
	
	update TempBomGravableTlc
	set bst_tipocosto='N'
	where esMP = 'S' and esGravable = 'X' and esAnadido = 'N' 
	
	
	update TempBomGravableTlc
	set bst_tipocosto='P'
	where esMP = 'S' and esGravable = 'X' and esAnadido = 'S' 

	update TempBomGravableTlc
	set bst_tipocosto='Z'
	where esMP = 'S' and esGravable = 'Z' and esAnadido = 'N' 
	
	
	update TempBomGravableTlc
	set bst_tipocosto='G'
	where esMP = 'S' and esGravable = 'Z' and esAnadido = 'S' 
	
	
	update TempBomGravableTlc
	set bst_tipocosto='S'
	where esSUB = 'S'  
	
	
	update TempBomGravableTlc
	set bst_tipocosto='E'
	where esMP = 'N' and esSUB = 'N' and
	(esGravable = 'S' or  esGravable = 'X') 
	

	update TempBomGravableTlc
	set bst_tipocosto='H'
	where esMP = 'N' and esSUB = 'N' and
	(esGravable = 'Z') 
	
	
	update TempBomGravableTlc
	set bst_tipocosto='F'
	where esMP = 'N' and esSUB = 'N' and
	(esGravable <> 'S' and  esGravable <> 'X') 



	update CLASIFICATLC
	set bst_tipocosto=TempBomGravableTlc.bst_tipocosto, bst_cos_uni=0, bst_empaque=0, bst_matorig=0, bst_matnoorig=0
	from TempBomGravableTlc inner join CLASIFICATLC on TempBomGravableTlc.clt_codigo=CLASIFICATLC.clt_codigo
	where CLASIFICATLC.bst_tipocosto is null or CLASIFICATLC.bst_tipocosto<>TempBomGravableTlc.bst_tipocosto






	exec sp_droptable 'TempBomGravableTlc'


	exec sp_droptable 'TempPaisTLC'

GO
