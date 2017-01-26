SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






CREATE FUNCTION GetNafta (@fe_fecha varchar(30), @Ma_Codigo Integer, @ArExpMx Integer, @PaisOrigen integer, @TipoTasa char(1), @TipEns char(1))
RETURNS char(1) AS  
BEGIN
	DECLARE @nafta char(1)


        select @nafta= CASE WHEN MAESTRO.MA_CODIGO in 
                                (SELECT NAFTA.MA_CODIGO FROM NAFTA INNER JOIN SPI ON NAFTA.SPI_CODIGO = SPI.SPI_CODIGO WHERE SPI.SPI_CLAVE = 'NAFTA' 
                                 and NFT_CALIFICO='S' and NFT_PERINI<=@fe_fecha AND NFT_PERFIN>=@fe_fecha AND NAFTA.MA_CODIGO=MAESTRO.MA_CODIGO) 
                                 and TI_CODIGO IN (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S') AND (@TipEns='F' or @TipEns='E')
                                 then 'S' else (CASE WHEN MAESTRO.MA_CODIGO in (SELECT CERTORIGMPDET.MA_CODIGO 
                                 FROM  CERTORIGMPDET INNER JOIN CERTORIGMP ON CERTORIGMPDET.CMP_CODIGO = CERTORIGMP.CMP_CODIGO
                                 WHERE CERTORIGMP.CMP_TIPO<> 'P' and LEFT(REPLACE(CERTORIGMPDET.CMP_FRACCION,'.',''),6) IN (SELECT LEFT(REPLACE(A1.AR_FRACCION,'.',''),6) FROM ARANCEL A1 WHERE AR_CODIGO=@ArExpMx) 
                                  AND CERTORIGMP.CMP_ESTATUS='V' AND CERTORIGMPDET.PA_CLASE = @PaisOrigen 
                                  AND  CERTORIGMP.SPI_CODIGO IN (SELECT spi_codigo FROM spi  WHERE spi_clave = 'NAFTA') 
                                  AND CERTORIGMP.CMP_IFECHA<=@fe_fecha AND CERTORIGMP.CMP_FECHATRANS>=@fe_fecha AND CERTORIGMPDET.MA_CODIGO=MAESTRO.MA_CODIGO) 
                                   AND (@TipEns<>'F' and @TipEns<>'E') THEN 'S' ELSE (CASE WHEN (@PaisOrigen in (SELECT CF_PAIS_USA FROM CONFIGURACION)
				OR @PaisOrigen in (SELECT CF_PAIS_CA FROM CONFIGURACION)) AND (select CF_CONFERIRORIGEN FROM CONFIGURACION)='T' 
			AND @TipoTasa='P' THEN 'S' 
                                 ELSE 'N' END) END) end 
                                 from maestro where ma_codigo =@Ma_Codigo



	IF @nafta IS NULL
	SET @nafta='N'

	RETURN @nafta
END

GO
