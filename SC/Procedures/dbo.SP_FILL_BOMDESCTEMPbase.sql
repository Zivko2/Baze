SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



















/* inserta en la tabla TempBOM_CALCULABASE  los del nivel 1 el bom  para calculo de costos y calculo de aranceles*/
CREATE PROCEDURE [dbo].[SP_FILL_BOMDESCTEMPbase] (@BST_PT Int)   as

SET NOCOUNT ON 
declare @BST_HIJO int, @BST_INCORPOR decimal(38,6), @BST_PERINI datetime, @BST_ENTRAVIGOR DateTime,  @CF_USATIPOADQUISICION char(1), @CF_NIVELES  int,
 @bst_perini2 datetime, @cf_pais_mx int, @ar_codigo int

SET     @BST_ENTRAVIGOR = GETDATE()


SELECT     @CF_USATIPOADQUISICION = CF_USATIPOADQUISICION, @CF_NIVELES = CF_NIVELES
FROM         dbo.CONFIGURACION

if exists (select * from TempBOM_CALCULABASE where bst_pt=@BST_PT)
DELETE FROM TempBOM_CALCULABASE WHERE BST_PT = @BST_PT

select @cf_pais_mx=cf_pais_mx from configuracion



			insert into TempBOM_CALCULABASE(BST_CODIGO,BST_PT, BST_ENTRAVIGOR, BST_HIJO, BST_INCORPOR, 
			    BST_DISCH, TI_CODIGO, ME_CODIGO, FACTCONV, BST_PERINI, BST_PERFIN, ME_GEN, 
			    BST_TRANS, BST_TIPOCOSTO, MA_TIP_ENS, BST_NIVEL, BST_PERTENECE,
 			PA_CODIGO, AR_CODIGO)

			SELECT     BST_CODIGO, @BST_PT, @BST_ENTRAVIGOR, dbo.BOM_STRUCT.BST_HIJO, sum((BOM_STRUCT.BST_INCORPOR+(CASE WHEN isnull(MAESTRO.MA_POR_DESP,0)<0 and
				isnull(MAESTRO.MA_POR_DESP,0)<>0 then ((BOM_STRUCT.BST_INCORPOR*MAESTRO.MA_POR_DESP)/100) 
					         else 0 end))) AS BST_INCORPOR, dbo.BOM_STRUCT.BST_DISCH, 
			                      dbo.CONFIGURATIPO.CFT_TIPO, dbo.BOM_STRUCT.ME_CODIGO, dbo.BOM_STRUCT.FACTCONV, dbo.BOM_STRUCT.BST_PERINI, 
			                      dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.ME_GEN, dbo.BOM_STRUCT.BST_TRANS, dbo.MAESTRO.BST_TIPOCOSTO, 
			                      dbo.BOM_STRUCT.BST_TIP_ENS, 1, @BST_PT,
					dbo.MAESTRO.PA_ORIGEN, MAX(dbo.MAESTRO.AR_IMPFO)
			FROM         dbo.BOM_STRUCT LEFT OUTER JOIN
			                      dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
			                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
			WHERE ((dbo.CONFIGURATIPO.CFT_TIPO<>'P' and dbo.CONFIGURATIPO.CFT_TIPO<>'S') and (dbo.BOM_STRUCT.BST_TIP_ENS='C' or dbo.BOM_STRUCT.BST_TIP_ENS is null))
			or ((dbo.CONFIGURATIPO.CFT_TIPO='P' or dbo.CONFIGURATIPO.CFT_TIPO='S') and (dbo.BOM_STRUCT.BST_TIP_ENS='C' or dbo.BOM_STRUCT.BST_TIP_ENS='A' or dbo.BOM_STRUCT.BST_TIP_ENS='E' or dbo.BOM_STRUCT.BST_TIP_ENS='O'))
			GROUP BY BST_CODIGO, dbo.BOM_STRUCT.BST_HIJO, dbo.BOM_STRUCT.BST_DISCH, dbo.CONFIGURATIPO.CFT_TIPO, dbo.BOM_STRUCT.ME_CODIGO, 
			                      dbo.BOM_STRUCT.FACTCONV, dbo.BOM_STRUCT.BST_PERINI, dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.ME_GEN, 
			                      dbo.BOM_STRUCT.BST_TRANS, dbo.MAESTRO.BST_TIPOCOSTO, dbo.BOM_STRUCT.BST_TIP_ENS, dbo.BOM_STRUCT.BSU_SUBENSAMBLE, 
			                      dbo.BOM_STRUCT.BST_INCORPOR, dbo.MAESTRO.PA_ORIGEN
			HAVING     (dbo.BOM_STRUCT.BSU_SUBENSAMBLE = @BST_PT) 
			AND dbo.BOM_STRUCT.BST_HIJO IS NOT NULL AND (dbo.BOM_STRUCT.BST_PERINI <=  @BST_ENTRAVIGOR and dbo.BOM_STRUCT.BST_PERFIN>=  @BST_ENTRAVIGOR)
			AND dbo.BOM_STRUCT.BST_INCORPOR >0 
			ORDER BY dbo.BOM_STRUCT.BST_HIJO




declare CUR_TempBOM_CALCULABASE cursor for

SELECT     dbo.BOM_STRUCT.BST_HIJO, SUM(dbo.BOM_STRUCT.BST_INCORPOR) AS BST_INCORPOR, dbo.BOM_STRUCT.BST_PERINI
FROM         dbo.BOM_STRUCT LEFT OUTER JOIN dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
WHERE     (dbo.CONFIGURATIPO.CFT_TIPO = 'P' OR dbo.CONFIGURATIPO.CFT_TIPO = 'S') 
	AND (dbo.BOM_STRUCT.BST_TIP_ENS = 'F' OR dbo.BOM_STRUCT.BST_TIP_ENS IS NULL)
	AND (dbo.BOM_STRUCT.BSU_SUBENSAMBLE = @BST_PT) 
	AND dbo.BOM_STRUCT.BST_HIJO IS NOT NULL AND (dbo.BOM_STRUCT.BST_PERINI <=  @BST_ENTRAVIGOR and dbo.BOM_STRUCT.BST_PERFIN>=  @BST_ENTRAVIGOR)
	AND dbo.BOM_STRUCT.BST_INCORPOR >0 
GROUP BY dbo.BOM_STRUCT.BST_HIJO, dbo.BOM_STRUCT.BST_PERINI
ORDER BY dbo.BOM_STRUCT.BST_HIJO

 OPEN CUR_TempBOM_CALCULABASE

	FETCH NEXT FROM CUR_TempBOM_CALCULABASE INTO @BST_HIJO, @BST_INCORPOR, @BST_PERINI

  WHILE (@@fetch_status = 0) 

  BEGIN  


		exec  SP_FILL_BOMDESCTEMP1base @BST_PT, @BST_HIJO, @BST_ENTRAVIGOR,
		@BST_PERINI, @CF_USATIPOADQUISICION, @BST_INCORPOR, @CF_NIVELES, 1



	FETCH NEXT FROM CUR_TempBOM_CALCULABASE INTO @BST_HIJO, @BST_INCORPOR, @BST_PERINI
END

	CLOSE CUR_TempBOM_CALCULABASE
	DEALLOCATE CUR_TempBOM_CALCULABASE



	UPDATE TempBOM_CALCULABASE
	SET     TempBOM_CALCULABASE.BST_COSTO= VMAESTROCOST.MA_COSTO
	FROM         TempBOM_CALCULABASE INNER JOIN
	                      VMAESTROCOST ON TempBOM_CALCULABASE.BST_HIJO = VMAESTROCOST.MA_CODIGO
	WHERE    BST_PT= @BST_PT and (TempBOM_CALCULABASE.BST_COSTO IS NULL)


GO
