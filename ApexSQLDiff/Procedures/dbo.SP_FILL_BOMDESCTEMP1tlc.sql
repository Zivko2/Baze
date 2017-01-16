SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

/* inserta en la tabla CLASIFICATLC  los de nivel diferentes del 1 el bom  para calculo de costos y calculo de aranceles*/
CREATE PROCEDURE [dbo].[SP_FILL_BOMDESCTEMP1tlc] (@BST_PT INT, @BST_HIJO INT, @BST_ENTRAVIGOR DATETIME, @BST_PERINI DATETIME, @CF_USATIPOADQUISICION char(1), @BST_INCORPOR1 decimal(38,6), @CF_NIVELES int, @nivel int, @NFT_CODIGO INT, @IML_CBFORMA int)   as

SET NOCOUNT ON 
declare @BST_HIJO1 int, @BST_INCORPOR decimal(38,6), @spi_codigo int,
    @BST_PERINI1 datetime, @nivelr int, @bst_perini2 datetime, @incorporacionfinal decimal(38,6), @cf_pais_mx int, @cf_pais_ca int

select @cf_pais_mx=cf_pais_mx, @cf_pais_ca=cf_pais_ca from configuracion


select @spi_codigo=spi_codigo from nafta where nft_codigo=@NFT_CODIGO


	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA, IML_REFERENCIA)
	SELECT 'NO. PARTE : ' +MA_NOPARTE+' NO TIENE ASIGNADA ESTRUCTURA (BOM)', @IML_CBFORMA,  @BST_PT
	FROM MAESTRO WHERE MA_CODIGO=@BST_HIJO AND
	MA_CODIGO NOT IN (SELECT BSU_SUBENSAMBLE FROM BOM_STRUCT WHERE 
	BST_PERINI <=  @BST_ENTRAVIGOR and BST_PERFIN>=  @BST_ENTRAVIGOR)



	SET @nivelr=@nivel+1

			insert into CLASIFICATLC(BST_PT, BST_ENTRAVIGOR, BST_HIJO, BST_INCORPOR, 
			    BST_DISCH, TI_CODIGO, ME_CODIGO, FACTCONV, BST_PERINI, BST_PERFIN, ME_GEN, 
			    BST_TRANS, BST_TIPOCOSTO, MA_TIP_ENS, BST_NIVEL, BST_PERTENECE, PA_CODIGO, AR_CODIGO, NFT_CODIGO)

			SELECT @BST_PT, @BST_ENTRAVIGOR, dbo.BOM_STRUCT.BST_HIJO, sum((BOM_STRUCT.BST_INCORPOR+(CASE WHEN isnull(MAESTRO.MA_POR_DESP,0)<0 and
				isnull(MAESTRO.MA_POR_DESP,0)<>0 then ((BOM_STRUCT.BST_INCORPOR*MAESTRO.MA_POR_DESP)/100) 
					         else 0 end)))*@BST_INCORPOR1 AS BST_INCORPOR, 
					'BST_DISCH'=CASE WHEN (dbo.BOM_STRUCT.BST_TIP_ENS='A') OR 
					((ISNULL(dbo.CONFIGURATIPO.CFT_TIPO,CONFIGURATIPOA.CFT_TIPO) ='P' or ISNULL(dbo.CONFIGURATIPO.CFT_TIPO,CONFIGURATIPOA.CFT_TIPO) ='S') AND dbo.BOM_STRUCT.BST_TRANS='S') THEN 'S' ELSE dbo.BOM_STRUCT.BST_DISCH END,
			                      ISNULL(dbo.CONFIGURATIPO.CFT_TIPO,CONFIGURATIPOA.CFT_TIPO) , dbo.BOM_STRUCT.ME_CODIGO, dbo.BOM_STRUCT.FACTCONV, dbo.BOM_STRUCT.BST_PERINI, 
			                      dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.ME_GEN, dbo.BOM_STRUCT.BST_TRANS, dbo.MAESTRO.BST_TIPOCOSTO, 
			                      CASE WHEN dbo.BOM_STRUCT.BST_TIP_ENS='A' THEN 'C' ELSE dbo.BOM_STRUCT.BST_TIP_ENS END, @nivelr, @BST_HIJO,
				dbo.MAESTRO.PA_ORIGEN, 'AR_CODIGO'=CASE WHEN @spi_codigo in (select spi_codigo from spi where SPI_ANALISISHTSMEX='S') then MAX(dbo.MAESTRO.AR_IMPMX) else MAX(dbo.MAESTRO.AR_IMPFO) end, @NFT_CODIGO
			FROM         dbo.BOM_STRUCT LEFT OUTER JOIN
			                      dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
			                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO LEFT OUTER JOIN dbo.MAESTROREFER ON
					 dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTROREFER.MA_CODIGO LEFT OUTER JOIN
                  				    dbo.CONFIGURATIPO CONFIGURATIPOA ON dbo.MAESTROREFER.TI_CODIGO = CONFIGURATIPOA.TI_CODIGO
			WHERE (((ISNULL(dbo.CONFIGURATIPO.CFT_TIPO,CONFIGURATIPOA.CFT_TIPO) <>'P' and ISNULL(dbo.CONFIGURATIPO.CFT_TIPO,CONFIGURATIPOA.CFT_TIPO) <>'S') and (dbo.BOM_STRUCT.BST_TIP_ENS='C' or dbo.BOM_STRUCT.BST_TIP_ENS is null))
			or ((ISNULL(dbo.CONFIGURATIPO.CFT_TIPO,CONFIGURATIPOA.CFT_TIPO) ='P' or ISNULL(dbo.CONFIGURATIPO.CFT_TIPO,CONFIGURATIPOA.CFT_TIPO) ='S') and (dbo.BOM_STRUCT.BST_TIP_ENS='C' or dbo.BOM_STRUCT.BST_TIP_ENS='A' or dbo.BOM_STRUCT.BST_TIP_ENS='E' 
			or dbo.BOM_STRUCT.BST_TIP_ENS='O' or dbo.BOM_STRUCT.BST_TRANS='S'))) and
				dbo.MAESTRO.MA_USO_ENANALISIS='S'
			GROUP BY dbo.BOM_STRUCT.BST_HIJO, dbo.BOM_STRUCT.BST_DISCH, ISNULL(dbo.CONFIGURATIPO.CFT_TIPO,CONFIGURATIPOA.CFT_TIPO) , dbo.BOM_STRUCT.ME_CODIGO, 
			                      dbo.BOM_STRUCT.FACTCONV, dbo.BOM_STRUCT.BST_PERINI, dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.ME_GEN, 
			                      dbo.BOM_STRUCT.BST_TRANS, dbo.MAESTRO.BST_TIPOCOSTO, dbo.BOM_STRUCT.BST_TIP_ENS, dbo.BOM_STRUCT.BSU_SUBENSAMBLE, 
			                      dbo.BOM_STRUCT.BST_INCORPOR, dbo.MAESTRO.PA_ORIGEN
			HAVING     (dbo.BOM_STRUCT.BSU_SUBENSAMBLE = @BST_hijo) 
			AND dbo.BOM_STRUCT.BST_HIJO IS NOT NULL AND (dbo.BOM_STRUCT.BST_PERINI <=  @BST_ENTRAVIGOR and dbo.BOM_STRUCT.BST_PERFIN>=  @BST_ENTRAVIGOR)
			AND dbo.BOM_STRUCT.BST_INCORPOR >0 AND (dbo.BOM_STRUCT.BST_TIP_ENS<>'P')
			ORDER BY dbo.BOM_STRUCT.BST_HIJO



DECLARE @CursorVar CURSOR

SET @CursorVar = CURSOR SCROLL DYNAMIC FOR
SELECT     dbo.BOM_STRUCT.BST_HIJO, SUM(dbo.BOM_STRUCT.BST_INCORPOR) AS BST_INCORPOR, dbo.BOM_STRUCT.BST_PERINI
FROM         dbo.BOM_STRUCT LEFT OUTER JOIN dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN 
                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO LEFT OUTER JOIN dbo.MAESTROREFER ON
		 dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTROREFER.MA_CODIGO LEFT OUTER JOIN
                      dbo.CONFIGURATIPO CONFIGURATIPOA ON dbo.MAESTROREFER.TI_CODIGO = CONFIGURATIPOA.TI_CODIGO
WHERE     (ISNULL(dbo.CONFIGURATIPO.CFT_TIPO,CONFIGURATIPOA.CFT_TIPO) = 'P' OR ISNULL(dbo.CONFIGURATIPO.CFT_TIPO,CONFIGURATIPOA.CFT_TIPO) = 'S') AND (dbo.BOM_STRUCT.BST_TIP_ENS = 'F' OR
                      dbo.BOM_STRUCT.BST_TIP_ENS IS NULL)
AND (dbo.BOM_STRUCT.BSU_SUBENSAMBLE = @BST_hijo) 
AND dbo.BOM_STRUCT.BST_HIJO IS NOT NULL AND (dbo.BOM_STRUCT.BST_PERINI <=  @BST_ENTRAVIGOR and dbo.BOM_STRUCT.BST_PERFIN>=  @BST_ENTRAVIGOR)
AND dbo.BOM_STRUCT.BST_INCORPOR >0 AND (dbo.BOM_STRUCT.BST_TIP_ENS<>'P') AND (dbo.BOM_STRUCT.BST_TRANS<>'S' OR dbo.BOM_STRUCT.BST_TRANS IS NULL)
GROUP BY dbo.BOM_STRUCT.BST_HIJO, dbo.BOM_STRUCT.BST_PERINI
ORDER BY dbo.BOM_STRUCT.BST_HIJO



 OPEN @CursorVar

	FETCH NEXT FROM @CursorVar INTO @BST_HIJO1, @BST_INCORPOR, @BST_PERINI1

  WHILE (@@fetch_status = 0) 

  BEGIN  

	set @incorporacionfinal=@BST_INCORPOR* @BST_INCORPOR1






		if @@NESTLEVEL <31
			exec  SP_FILL_BOMDESCTEMP1tlc @BST_PT, @BST_HIJO1, @BST_ENTRAVIGOR,
			@BST_PERINI1, @CF_USATIPOADQUISICION, @incorporacionfinal, @CF_NIVELES, @nivelr, @NFT_CODIGO, @IML_CBFORMA
		else
		begin
			INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA, IML_REFERENCIA)
			SELECT 'NO. PARTE : ' +MA_NOPARTE+' CON ESTRUCTURA(BOM) CICLADA', @IML_CBFORMA,  @BST_PT
			FROM MAESTRO WHERE MA_CODIGO=@BST_PT

			break
		end


	FETCH NEXT FROM @CursorVar INTO @BST_HIJO1, @BST_INCORPOR, @BST_PERINI1

END

	CLOSE @CursorVar
	DEALLOCATE @CursorVar

return 0

GO
