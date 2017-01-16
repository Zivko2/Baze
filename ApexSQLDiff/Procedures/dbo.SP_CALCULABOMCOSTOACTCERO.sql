SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO































CREATE PROCEDURE [dbo].[SP_CALCULABOMCOSTOACTCERO] (@GuardaHist char(1)='N', @spi_codigo int =22)   as

SET NOCOUNT ON 
declare @ma_subensamble int, @fechaactual datetime, @bm_entravigor datetime

select @fechaactual=convert(varchar(11),getdate(),101)


	/*================ Actualizacion de productos sin subensambles ===================*/
	exec sp_droptable 'CalculandoCosto'
	create table [dbo].[CalculandoCosto] (BST_PERTENECE int, BST_PERINI datetime)

	insert into CalculandoCosto (BST_PERTENECE, BST_PERINI)
	SELECT     BOM_STRUCT.BSU_SUBENSAMBLE, @fechaactual
	FROM         BOM_STRUCT
	where BOM_STRUCT.bst_perini<=@fechaactual and BOM_STRUCT.bst_perfin>=@fechaactual
	AND BOM_STRUCT.BSU_SUBENSAMBLE NOT IN
		(SELECT A1.BSU_SUBENSAMBLE FROM BOM_STRUCT A1 LEFT OUTER JOIN MAESTRO M1 ON A1.BST_HIJO=M1.MA_CODIGO
			INNER JOIN CONFIGURATIPO ON
			M1.TI_CODIGO=CONFIGURATIPO.TI_CODIGO WHERE CFT_TIPO = 'S'  and A1.BST_TIP_ENS<>'C'
		and A1.bst_perini <=@fechaactual and A1.bst_perfin>= @fechaactual
		GROUP BY A1.BSU_SUBENSAMBLE)
	GROUP BY BOM_STRUCT.BSU_SUBENSAMBLE

	TRUNCATE TABLE TempBOM_NIVEL

		INSERT INTO TempBOM_NIVEL(BST_PT, BST_PERTENECE, BST_HIJO, BST_NIVEL, BST_PERINI, BST_INCORPOR, BST_INCORPORUSO)
		SELECT     BOM_STRUCT.BSU_SUBENSAMBLE, BOM_STRUCT.BSU_SUBENSAMBLE, BOM_STRUCT.BSU_SUBENSAMBLE, 1, @fechaactual, 1, 1
		FROM         BOM_STRUCT
		where BOM_STRUCT.bst_perini<=@fechaactual and BOM_STRUCT.bst_perfin>=@fechaactual
		AND BOM_STRUCT.BSU_SUBENSAMBLE NOT IN
			(SELECT A1.BSU_SUBENSAMBLE FROM BOM_STRUCT A1 LEFT OUTER JOIN MAESTRO M1 ON A1.BST_HIJO=M1.MA_CODIGO
				INNER JOIN CONFIGURATIPO ON
				M1.TI_CODIGO=CONFIGURATIPO.TI_CODIGO WHERE CFT_TIPO = 'S'  and A1.BST_TIP_ENS<>'C'
			and A1.bst_perini <=@fechaactual and A1.bst_perfin>= @fechaactual
			GROUP BY A1.BSU_SUBENSAMBLE)
		AND (BOM_STRUCT.BSU_SUBENSAMBLE NOT IN
		(SELECT MA_CODIGO FROM VMAESTROCOST) OR BOM_STRUCT.BSU_SUBENSAMBLE IN (SELECT MA_CODIGO FROM VMAESTROCOST WHERE MA_COSTO=0 OR MA_COSTO IS NULL))
		GROUP BY BOM_STRUCT.BSU_SUBENSAMBLE


	exec SP_ACTUALIZATIPOCOSTOTempBOM_NIVEL @spi_codigo

	EXEC SP_CALCULABOMCOSTOSUB @GuardaHist, @spi_codigo

	/*========================================================================*/

		SELECT MA_CODIGO
		into dbo.[#calculabom]
		FROM MAESTRO
		WHERE TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO where cft_tipo='P' OR cft_tipo='S')
		AND MA_CODIGO IN (SELECT bsu_subensamble FROM bom_struct where bst_perini<=@fechaactual and bst_perfin>=@fechaactual group by bsu_subensamble )
		AND MA_CODIGO NOT IN (SELECT BST_PERTENECE FROM CalculandoCosto)
		AND MA_INV_GEN='I'
		AND MA_NOPARTE NOT LIKE '%SCRAP%'  AND (MA_CODIGO NOT IN
		(SELECT MA_CODIGO FROM VMAESTROCOST) OR MA_CODIGO IN (SELECT MA_CODIGO FROM VMAESTROCOST WHERE MA_COSTO=0 OR MA_COSTO IS NULL))
		ORDER BY MA_NOPARTE


		TRUNCATE TABLE TempBOM_NIVEL
		exec SP_FILL_TempBOMNivelFiltro  @fechaactual -- llena la tabla TempBOM_NIVEL de todos los productos


		-- el campo bst_tipocosto es temporal, se va a modificar de acuerdo al spi_codigo que se usando en el calculo
		exec SP_ACTUALIZATIPOCOSTOTempBOM_NIVEL @spi_codigo

		exec SP_CALCULABOMCOSTOTodos @fechaactual, @GuardaHist, @spi_codigo



		UPDATE MAESTROCOST
		SET     MA_COSTO= ROUND(MA_GRAV_MP + MA_GRAV_ADD + MA_GRAV_EMP + MA_GRAV_GI + MA_GRAV_GI_MX + MA_GRAV_MO + MA_NG_MP +
		                      MA_NG_ADD + MA_NG_EMP,6)
		FROM         MAESTROCOST
		WHERE TCO_CODIGO=1 AND MA_PERINI <=GETDATE() and MA_PERFIN>= GETDATE() AND
		MA_COSTO<> ROUND(MA_GRAV_MP + MA_GRAV_ADD + MA_GRAV_EMP + MA_GRAV_GI + MA_GRAV_GI_MX + MA_GRAV_MO + MA_NG_MP +
		                      MA_NG_ADD + MA_NG_EMP,6)
	

	exec sp_droptable '#calculabom'


























GO
