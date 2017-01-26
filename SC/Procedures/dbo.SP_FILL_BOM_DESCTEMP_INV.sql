SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







































CREATE PROCEDURE [dbo].[SP_FILL_BOM_DESCTEMP_INV] (@FED_INDICED INT, @BST_PT Int, @BST_ENTRAVIGOR DateTime, @FED_CANT decimal(38,6), @CODIGOFACTURA INT)   as


SET NOCOUNT ON 
declare @BST_HIJO int, @BST_INCORPOR decimal(38,6), @BST_DISCH char(1), @TI_CODIGO char(1), @ME_CODIGO int, @Factconv decimal(28,14), 
    @BST_PERINI datetime, @BST_PERFIN datetime, @ME_GEN int, @BST_TRANS char(1), @BST_TIPOCOSTO char(1), @BST_DESP decimal(38,6),
    @BST_MERMA decimal(38,6), @MA_TIP_ENS char(1), @CF_USATIPOADQUISICION char(1), @CF_NIVELES INT, @BST_PERINI2 datetime,
    @BST_TIPODESC varchar(5), @BST_PESO_KG decimal(38,6)


	exec sp_CreaBOM_DESCTEMP

SELECT     @CF_USATIPOADQUISICION = CF_USATIPOADQUISICION, @CF_NIVELES = CF_NIVELES
FROM         dbo.CONFIGURACION



			insert into bom_desctemp (BST_HIJO, BST_INCORPOR, BST_DISCH, TI_CODIGO,  ME_CODIGO, FACTCONV, BST_PERINI, BST_PERFIN, ME_GEN, 
			    BST_TRANS, BST_TIPOCOSTO, MA_TIP_ENS, FED_CANT, FE_CODIGO, BST_NIVEL, BST_TIPODESC,
			   BST_PERTENECE, FED_INDICED, BST_PT, BST_ENTRAVIGOR, BST_PESO_KG, BST_COSTO, FACT_INV)

			SELECT     dbo.BOM_STRUCT.BST_HIJO, SUM(dbo.BOM_STRUCT.BST_INCORPOR) AS BST_INCORPOR, dbo.BOM_STRUCT.BST_DISCH, 
			                      dbo.CONFIGURATIPO.CFT_TIPO, dbo.BOM_STRUCT.ME_CODIGO, dbo.BOM_STRUCT.FACTCONV, dbo.BOM_STRUCT.BST_PERINI, 
			                      dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.ME_GEN, dbo.BOM_STRUCT.BST_TRANS, dbo.MAESTRO.BST_TIPOCOSTO, 
			                      dbo.BOM_STRUCT.BST_TIP_ENS, @FED_CANT, @CODIGOFACTURA, 'B1', 'N' AS BST_TIPODESC,
					@BST_PT, @FED_INDICED, @BST_PT, @BST_ENTRAVIGOR, dbo.MAESTRO.MA_PESO_KG, isnull((SELECT MA_COSTO FROM VMAESTROCOST
				WHERE MA_CODIGO=dbo.BOM_STRUCT.BST_HIJO),0), 'I'
			FROM         dbo.BOM_STRUCT LEFT OUTER JOIN
			                      dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
			                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
			WHERE (dbo.CONFIGURATIPO.CFT_TIPO<>'P' and dbo.CONFIGURATIPO.CFT_TIPO<>'S') and dbo.BOM_STRUCT.BST_TIP_ENS='C'
			GROUP BY dbo.BOM_STRUCT.BST_HIJO, dbo.BOM_STRUCT.BST_DISCH, dbo.CONFIGURATIPO.CFT_TIPO, dbo.BOM_STRUCT.ME_CODIGO, 
			                      dbo.BOM_STRUCT.FACTCONV, dbo.BOM_STRUCT.BST_PERINI, dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.ME_GEN, 
			                      dbo.BOM_STRUCT.BST_TRANS, dbo.MAESTRO.BST_TIPOCOSTO, dbo.BOM_STRUCT.BST_TIP_ENS, dbo.BOM_STRUCT.BSU_SUBENSAMBLE, 
			                      dbo.BOM_STRUCT.BST_INCORPOR, dbo.MAESTRO.MA_PESO_KG
			HAVING     (dbo.BOM_STRUCT.BSU_SUBENSAMBLE = @BST_PT) 
			AND dbo.BOM_STRUCT.BST_HIJO IS NOT NULL AND (dbo.BOM_STRUCT.BST_PERINI <= @BST_ENTRAVIGOR and dbo.BOM_STRUCT.BST_PERFIN>= @BST_ENTRAVIGOR)
			AND SUM(dbo.BOM_STRUCT.BST_INCORPOR) >0
			/*UNION
			--desperdicio
			SELECT     dbo.BOM_STRUCT.BST_HIJO, SUM(dbo.BOM_STRUCT.BST_DESP) AS BST_INCORPOR, dbo.BOM_STRUCT.BST_DISCH, 
			                      dbo.CONFIGURATIPO.CFT_TIPO, dbo.BOM_STRUCT.ME_CODIGO, dbo.BOM_STRUCT.FACTCONV, dbo.BOM_STRUCT.BST_PERINI, 
			                      dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.ME_GEN, dbo.BOM_STRUCT.BST_TRANS, dbo.MAESTRO.BST_TIPOCOSTO, 
			                      dbo.BOM_STRUCT.BST_TIP_ENS, @FED_CANT, @CODIGOFACTURA, 'B1', 'D' AS BST_TIPODESC,
					@BST_PT, @FED_INDICED, @BST_PT, @BST_ENTRAVIGOR, dbo.BOM_STRUCT.BST_PESO_KG, isnull((SELECT MA_COSTO FROM VMAESTROCOST
				WHERE MA_CODIGO=dbo.BOM_STRUCT.BST_HIJO),0)
			FROM         dbo.BOM_STRUCT LEFT OUTER JOIN
			                      dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
			                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
			WHERE (dbo.CONFIGURATIPO.CFT_TIPO<>'P' and dbo.CONFIGURATIPO.CFT_TIPO<>'S') and dbo.BOM_STRUCT.BST_TIP_ENS='C'
			GROUP BY dbo.BOM_STRUCT.BST_HIJO, dbo.BOM_STRUCT.BST_DISCH, dbo.CONFIGURATIPO.CFT_TIPO, dbo.BOM_STRUCT.ME_CODIGO, 
			                      dbo.BOM_STRUCT.FACTCONV, dbo.BOM_STRUCT.BST_PERINI, dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.ME_GEN, 
			                      dbo.BOM_STRUCT.BST_TRANS, dbo.MAESTRO.BST_TIPOCOSTO, dbo.BOM_STRUCT.BST_TIP_ENS, dbo.BOM_STRUCT.BSU_SUBENSAMBLE, 
			                      dbo.BOM_STRUCT.BST_INCORPOR, dbo.BOM_STRUCT.BST_PESO_KG
			HAVING     (dbo.BOM_STRUCT.BSU_SUBENSAMBLE = @BST_PT) 
			AND dbo.BOM_STRUCT.BST_HIJO IS NOT NULL AND (dbo.BOM_STRUCT.BST_PERINI <= @BST_ENTRAVIGOR and dbo.BOM_STRUCT.BST_PERFIN>= @BST_ENTRAVIGOR)
			AND SUM(dbo.BOM_STRUCT.BST_DESP) >0
			UNION
			--merma
			SELECT     dbo.BOM_STRUCT.BST_HIJO, SUM(dbo.BOM_STRUCT.BST_MERMA) AS BST_INCORPOR, dbo.BOM_STRUCT.BST_DISCH, 
			                      dbo.CONFIGURATIPO.CFT_TIPO, dbo.BOM_STRUCT.ME_CODIGO, dbo.BOM_STRUCT.FACTCONV, dbo.BOM_STRUCT.BST_PERINI, 
			                      dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.ME_GEN, dbo.BOM_STRUCT.BST_TRANS, dbo.MAESTRO.BST_TIPOCOSTO, 
			                      dbo.BOM_STRUCT.BST_TIP_ENS, @FED_CANT, @CODIGOFACTURA, 'B1', 'M' AS BST_TIPODESC,
					@BST_PT, @FED_INDICED, @BST_PT, @BST_ENTRAVIGOR, dbo.BOM_STRUCT.BST_PESO_KG, isnull((SELECT MA_COSTO FROM VMAESTROCOST
				WHERE MA_CODIGO=dbo.BOM_STRUCT.BST_HIJO),0), 'I'
			FROM         dbo.BOM_STRUCT LEFT OUTER JOIN
			                      dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
			                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
			WHERE (dbo.CONFIGURATIPO.CFT_TIPO<>'P' and dbo.CONFIGURATIPO.CFT_TIPO<>'S') and dbo.BOM_STRUCT.BST_TIP_ENS='C'
			GROUP BY dbo.BOM_STRUCT.BST_HIJO, dbo.BOM_STRUCT.BST_DISCH, dbo.CONFIGURATIPO.CFT_TIPO, dbo.BOM_STRUCT.ME_CODIGO, 
			                      dbo.BOM_STRUCT.FACTCONV, dbo.BOM_STRUCT.BST_PERINI, dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.ME_GEN, 
			                      dbo.BOM_STRUCT.BST_TRANS, dbo.MAESTRO.BST_TIPOCOSTO, dbo.BOM_STRUCT.BST_TIP_ENS, dbo.BOM_STRUCT.BSU_SUBENSAMBLE, 
			                      dbo.BOM_STRUCT.BST_INCORPOR, dbo.BOM_STRUCT.BST_PESO_KG
			HAVING     (dbo.BOM_STRUCT.BSU_SUBENSAMBLE = @BST_PT) 
			AND dbo.BOM_STRUCT.BST_HIJO IS NOT NULL AND (dbo.BOM_STRUCT.BST_PERINI <= @BST_ENTRAVIGOR and dbo.BOM_STRUCT.BST_PERFIN>= @BST_ENTRAVIGOR)
			AND SUM(dbo.BOM_STRUCT.BST_MERMA) >0*/



declare CUR_BOMSTRUCT cursor for
/* incorporacion*/
SELECT     dbo.BOM_STRUCT.BST_HIJO, SUM(dbo.BOM_STRUCT.BST_INCORPOR) AS BST_INCORPOR, dbo.BOM_STRUCT.BST_DISCH, 
                      dbo.CONFIGURATIPO.CFT_TIPO, dbo.BOM_STRUCT.ME_CODIGO, dbo.BOM_STRUCT.FACTCONV, dbo.BOM_STRUCT.BST_PERINI, 
                      dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.ME_GEN, dbo.BOM_STRUCT.BST_TRANS, dbo.MAESTRO.BST_TIPOCOSTO, 
                      dbo.BOM_STRUCT.BST_TIP_ENS, 'N' AS BST_TIPODESC, dbo.MAESTRO.MA_PESO_KG
FROM         dbo.BOM_STRUCT LEFT OUTER JOIN
                      dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
WHERE dbo.CONFIGURATIPO.CFT_TIPO='P' OR dbo.CONFIGURATIPO.CFT_TIPO='S'
GROUP BY dbo.BOM_STRUCT.BST_HIJO, dbo.BOM_STRUCT.BST_DISCH, dbo.CONFIGURATIPO.CFT_TIPO, dbo.BOM_STRUCT.ME_CODIGO, 
                      dbo.BOM_STRUCT.FACTCONV, dbo.BOM_STRUCT.BST_PERINI, dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.ME_GEN, 
                      dbo.BOM_STRUCT.BST_TRANS, dbo.MAESTRO.BST_TIPOCOSTO, dbo.BOM_STRUCT.BST_TIP_ENS, dbo.BOM_STRUCT.BSU_SUBENSAMBLE, 
                      dbo.BOM_STRUCT.BST_INCORPOR, dbo.MAESTRO.MA_PESO_KG
HAVING     (dbo.BOM_STRUCT.BSU_SUBENSAMBLE = @BST_PT) 
AND dbo.BOM_STRUCT.BST_HIJO IS NOT NULL AND (dbo.BOM_STRUCT.BST_PERINI <= @BST_ENTRAVIGOR and dbo.BOM_STRUCT.BST_PERFIN>= @BST_ENTRAVIGOR)
AND SUM(dbo.BOM_STRUCT.BST_INCORPOR) >0
/*UNION
--desperdicio
SELECT     dbo.BOM_STRUCT.BST_HIJO, SUM(dbo.BOM_STRUCT.BST_DESP) AS BST_INCORPOR, dbo.BOM_STRUCT.BST_DISCH, 
                      dbo.CONFIGURATIPO.CFT_TIPO, dbo.BOM_STRUCT.ME_CODIGO, dbo.BOM_STRUCT.FACTCONV, dbo.BOM_STRUCT.BST_PERINI, 
                      dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.ME_GEN, dbo.BOM_STRUCT.BST_TRANS, dbo.MAESTRO.BST_TIPOCOSTO, 
                      dbo.BOM_STRUCT.BST_TIP_ENS, 'D' AS BST_TIPODESC, dbo.BOM_STRUCT.BST_PESO_KG
FROM         dbo.BOM_STRUCT LEFT OUTER JOIN
                      dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
WHERE dbo.CONFIGURATIPO.CFT_TIPO='P' OR dbo.CONFIGURATIPO.CFT_TIPO='S'
GROUP BY dbo.BOM_STRUCT.BST_HIJO, dbo.BOM_STRUCT.BST_DISCH, dbo.CONFIGURATIPO.CFT_TIPO, dbo.BOM_STRUCT.ME_CODIGO, 
                      dbo.BOM_STRUCT.FACTCONV, dbo.BOM_STRUCT.BST_PERINI, dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.ME_GEN, 
                      dbo.BOM_STRUCT.BST_TRANS, dbo.MAESTRO.BST_TIPOCOSTO, dbo.BOM_STRUCT.BST_TIP_ENS, dbo.BOM_STRUCT.BSU_SUBENSAMBLE, 
                      dbo.BOM_STRUCT.BST_INCORPOR, dbo.BOM_STRUCT.BST_PESO_KG
HAVING     (dbo.BOM_STRUCT.BSU_SUBENSAMBLE = @BST_PT) 
AND dbo.BOM_STRUCT.BST_HIJO IS NOT NULL AND (dbo.BOM_STRUCT.BST_PERINI <= @BST_ENTRAVIGOR and dbo.BOM_STRUCT.BST_PERFIN>= @BST_ENTRAVIGOR)
AND SUM(dbo.BOM_STRUCT.BST_DESP) >0
UNION
--merma
SELECT     dbo.BOM_STRUCT.BST_HIJO, SUM(dbo.BOM_STRUCT.BST_MERMA) AS BST_INCORPOR, dbo.BOM_STRUCT.BST_DISCH, 
                      dbo.CONFIGURATIPO.CFT_TIPO, dbo.BOM_STRUCT.ME_CODIGO, dbo.BOM_STRUCT.FACTCONV, dbo.BOM_STRUCT.BST_PERINI, 
                      dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.ME_GEN, dbo.BOM_STRUCT.BST_TRANS, dbo.MAESTRO.BST_TIPOCOSTO, 
                      dbo.BOM_STRUCT.BST_TIP_ENS, 'M' AS BST_TIPODESC, dbo.BOM_STRUCT.BST_PESO_KG
FROM         dbo.BOM_STRUCT LEFT OUTER JOIN
                      dbo.CONFIGURATIPO ON dbo.BOM_STRUCT.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO LEFT OUTER JOIN
                      dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO
WHERE dbo.CONFIGURATIPO.CFT_TIPO='P' OR dbo.CONFIGURATIPO.CFT_TIPO='S'
GROUP BY dbo.BOM_STRUCT.BST_HIJO, dbo.BOM_STRUCT.BST_DISCH, dbo.CONFIGURATIPO.CFT_TIPO, dbo.BOM_STRUCT.ME_CODIGO, 
                      dbo.BOM_STRUCT.FACTCONV, dbo.BOM_STRUCT.BST_PERINI, dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.ME_GEN, 
                      dbo.BOM_STRUCT.BST_TRANS, dbo.MAESTRO.BST_TIPOCOSTO, dbo.BOM_STRUCT.BST_TIP_ENS, dbo.BOM_STRUCT.BSU_SUBENSAMBLE, 
                      dbo.BOM_STRUCT.BST_INCORPOR, dbo.BOM_STRUCT.BST_PESO_KG
HAVING     (dbo.BOM_STRUCT.BSU_SUBENSAMBLE = @BST_PT) 
AND dbo.BOM_STRUCT.BST_HIJO IS NOT NULL AND (dbo.BOM_STRUCT.BST_PERINI <= @BST_ENTRAVIGOR and dbo.BOM_STRUCT.BST_PERFIN>= @BST_ENTRAVIGOR)
AND SUM(dbo.BOM_STRUCT.BST_MERMA) >0
*/

 OPEN CUR_BOMSTRUCT


	FETCH NEXT FROM CUR_BOMSTRUCT INTO @BST_HIJO, @BST_INCORPOR, @BST_DISCH, @TI_CODIGO, 			
	@ME_CODIGO, @FACTCONV, @BST_PERINI, @BST_PERFIN, @ME_GEN, @BST_TRANS, @BST_TIPOCOSTO,
	@MA_TIP_ENS, @BST_TIPODESC, @BST_PESO_KG

  WHILE (@@fetch_status = 0) 

  BEGIN  

	begin

	if @CF_USATIPOADQUISICION='S'
		begin
	
			if @MA_TIP_ENS='F' 
			begin

			
				exec  SP_FILL_BOM_DESCTEMP1_INV @FED_INDICED, @BST_PT, @BST_HIJO, @BST_ENTRAVIGOR, @BST_PERINI, 
				@FED_CANT, @CODIGOFACTURA, @CF_USATIPOADQUISICION, @BST_INCORPOR, @CF_NIVELES, 1
			end

			if @MA_TIP_ENS='C' or @MA_TIP_ENS='A' or @MA_TIP_ENS='E' or @MA_TIP_ENS='O' 

			begin
				insert into bom_desctemp(FED_INDICED, BST_PT, BST_ENTRAVIGOR, BST_HIJO, BST_INCORPOR, 
				    BST_DISCH, TI_CODIGO, ME_CODIGO, FACTCONV, BST_PERINI, BST_PERFIN, ME_GEN, 
				    BST_TRANS, BST_TIPOCOSTO, MA_TIP_ENS, FED_CANT, FE_CODIGO, BST_NIVEL, BST_TIPODESC, BST_PERTENECE,
				    BST_PESO_KG, bst_costo, FACT_INV)
				select
				@FED_INDICED, @BST_PT, @BST_ENTRAVIGOR, @BST_HIJO, @BST_INCORPOR, @BST_DISCH, @TI_CODIGO, @ME_CODIGO, 
				@FACTCONV, @BST_PERINI, @BST_PERFIN, @ME_GEN, @BST_TRANS, @BST_TIPOCOSTO,
				@MA_TIP_ENS, @FED_CANT, @CODIGOFACTURA, 'B1', @BST_TIPODESC, @BST_PT, @BST_PESO_KG, isnull((SELECT MA_COSTO FROM VMAESTROCOST
				WHERE MA_CODIGO=@BST_HIJO),0), 'I'

				--print @MA_TIP_ENS
			end

		end

		else
		begin

			exec  SP_FILL_BOM_DESCTEMP1_INV @FED_INDICED, @BST_PT, @BST_HIJO, @BST_ENTRAVIGOR, @BST_PERINI, 
			@FED_CANT, @CODIGOFACTURA, @CF_USATIPOADQUISICION, @BST_INCORPOR, @CF_NIVELES, 1

		end
	end



	FETCH NEXT FROM CUR_BOMSTRUCT INTO @BST_HIJO, @BST_INCORPOR, @BST_DISCH, @TI_CODIGO, 			
	@ME_CODIGO, @FACTCONV, @BST_PERINI, @BST_PERFIN, @ME_GEN, @BST_TRANS, @BST_TIPOCOSTO,
	@MA_TIP_ENS, @BST_TIPODESC, @BST_PESO_KG

END

	CLOSE CUR_BOMSTRUCT
	DEALLOCATE CUR_BOMSTRUCT






































GO
