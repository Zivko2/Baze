SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO































CREATE PROCEDURE [dbo].[SP_CALCULABOMCOSTORANGO] (@ma_codigoini int, @ma_codigofin int, @GuardaHist char(1), @spi_codigo int)   as

SET NOCOUNT ON 
declare @ma_subensamble int, @fechaactual datetime, @bm_entravigor datetime, @ma_noparteini varchar(30), @ma_nopartefin varchar(30)

select @fechaactual=convert(varchar(11),getdate(),101)

	/*================ Actualizacion de productos sin subensambles ===================*/
	exec sp_droptable 'CalculandoCosto'
	create table [dbo].[CalculandoCosto] (BST_PERTENECE int, BST_PERINI datetime)


	insert into CalculandoCosto (BST_PERTENECE, BST_PERINI)
	SELECT     BOM_STRUCT.BSU_SUBENSAMBLE, @fechaactual
	FROM         BOM_STRUCT
	where BOM_STRUCT.bst_perini<=@fechaactual and BOM_STRUCT.bst_perfin>=@fechaactual
		and bsu_noparte>=@ma_noparteini and bsu_noparte<= @ma_nopartefin
	AND BOM_STRUCT.BSU_SUBENSAMBLE NOT IN
		(SELECT A1.BSU_SUBENSAMBLE FROM BOM_STRUCT A1 LEFT OUTER JOIN MAESTRO M1 ON A1.BST_HIJO=M1.MA_CODIGO
				INNER JOIN CONFIGURATIPO ON
				M1.TI_CODIGO=CONFIGURATIPO.TI_CODIGO WHERE CFT_TIPO = 'S' 
		GROUP BY A1.BSU_SUBENSAMBLE)
	GROUP BY BOM_STRUCT.BSU_SUBENSAMBLE
	
	

	EXEC SP_CALCULABOMCOSTOSUB @GuardaHist, @spi_codigo

	/*========================================================================*/

	select @ma_noparteini = ma_noparte from maestro where ma_codigo=@ma_codigoini

	select @ma_nopartefin = ma_noparte from maestro where ma_codigo=@ma_codigofin



		SELECT MA_CODIGO
		into dbo.[#calculabom]
		FROM MAESTRO
		WHERE TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO where cft_tipo='P' OR cft_tipo='S')
		AND MA_CODIGO IN (SELECT bsu_subensamble FROM bom_struct where bst_perini<=getdate() and bst_perfin>=getdate() group by bsu_subensamble)
		and ma_noparte>=@ma_noparteini and ma_noparte<= @ma_nopartefin
		AND MA_CODIGO NOT IN (SELECT BST_PERTENECE FROM CalculandoCosto)
		AND MA_NOPARTE NOT LIKE '%SCRAP%' AND MA_EST_MAT='A' AND MA_INV_GEN='I'
		ORDER BY MA_NOPARTE



		TRUNCATE TABLE TempBOM_NIVEL
		exec SP_FILL_TempBOMNivelFiltro  @fechaactual -- llena la tabla TempBOM_NIVEL de todos los productos


		-- el campo bst_tipocosto es temporal, se va a modificar de acuerdo al spi_codigo que se usando en el calculo
		exec SP_ACTUALIZATIPOCOSTOTempBOM_NIVEL @spi_codigo


		exec SP_CALCULABOMCOSTOTodos @fechaactual, @GuardaHist, @spi_codigo

	exec sp_droptable '#calculabom'

GO
