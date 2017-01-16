SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
































CREATE PROCEDURE [dbo].[SP_CALCULABOMCOSTOFACTEXP] (@FE_CODIGO INT, @GuardaHist char(1)='N')   as

SET NOCOUNT ON 
declare @ma_subensamble int, @fechaactual datetime, @bm_entravigor datetime, @SPI_CODIGO INT

select @fechaactual=convert(varchar(11),fe_fecha,101) from factexp where fe_codigo=@FE_CODIGO

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
			M1.TI_CODIGO=CONFIGURATIPO.TI_CODIGO WHERE CFT_TIPO = 'S' AND A1.BST_TIP_ENS<>'C'
		and A1.bst_perini <=@fechaactual and A1.bst_perfin>= @fechaactual
		GROUP BY A1.BSU_SUBENSAMBLE)
	AND BOM_STRUCT.BSU_SUBENSAMBLE IN (SELECT MA_CODIGO FROM FACTEXPDET WHERE FE_CODIGO=@FE_CODIGO)
	GROUP BY BOM_STRUCT.BSU_SUBENSAMBLE
	

		SELECT    @SPI_CODIGO=  PAIS.SPI_CODIGO
		FROM         PAIS INNER JOIN
		                      DIR_CLIENTE ON PAIS.PA_CODIGO = DIR_CLIENTE.PA_CODIGO INNER JOIN
		                      FACTEXP ON DIR_CLIENTE.DI_INDICE = FACTEXP.DI_DESTFIN
		WHERE     (FACTEXP.FE_CODIGO = @FE_CODIGO)

	TRUNCATE TABLE TempBOM_NIVEL

		INSERT INTO TempBOM_NIVEL(BST_PT, BST_PERTENECE, BST_HIJO, BST_NIVEL, BST_PERINI, BST_INCORPOR, BST_INCORPORUSO)
		SELECT     BOM_STRUCT.BSU_SUBENSAMBLE, BOM_STRUCT.BSU_SUBENSAMBLE, BOM_STRUCT.BSU_SUBENSAMBLE, 1, @fechaactual, 1, 1
		FROM         BOM_STRUCT
		where BOM_STRUCT.bst_perini<=@fechaactual and BOM_STRUCT.bst_perfin>=@fechaactual
		AND BOM_STRUCT.BSU_SUBENSAMBLE NOT IN
			(SELECT A1.BSU_SUBENSAMBLE FROM BOM_STRUCT A1 LEFT OUTER JOIN MAESTRO M1 ON A1.BST_HIJO=M1.MA_CODIGO
				INNER JOIN CONFIGURATIPO ON
				M1.TI_CODIGO=CONFIGURATIPO.TI_CODIGO WHERE CFT_TIPO = 'S' AND A1.BST_TIP_ENS<>'C'
			and A1.bst_perini <=@fechaactual and A1.bst_perfin>= @fechaactual
			GROUP BY A1.BSU_SUBENSAMBLE) AND BOM_STRUCT.BSU_SUBENSAMBLE IN
			(SELECT MA_CODIGO FROM FACTEXPDET WHERE FE_CODIGO=@FE_CODIGO GROUP BY MA_CODIGO)
		GROUP BY BOM_STRUCT.BSU_SUBENSAMBLE

	exec SP_ACTUALIZATIPOCOSTOTempBOM_NIVEL @spi_codigo

	EXEC SP_CALCULABOMCOSTOSUB  @GuardaHist, @spi_codigo

	/*========================================================================*/

		EXEC SP_ASIGNATIPOCOSTOTLC @SPI_CODIGO


		SELECT MA_CODIGO
		into dbo.[#calculabom]
		FROM FACTEXPDET
		WHERE TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO where cft_tipo='P' OR cft_tipo='S')
		AND MA_CODIGO IN (SELECT bsu_subensamble FROM bom_struct group by bsu_subensamble)
		AND MA_CODIGO NOT IN (SELECT BST_PERTENECE FROM CalculandoCosto)
		AND FED_NOPARTE NOT LIKE '%SCRAP%' AND FE_CODIGO=@FE_CODIGO
		ORDER BY FED_NOPARTE

		TRUNCATE TABLE TempBOM_NIVEL
		exec SP_FILL_TempBOMNivelFiltro  @fechaactual -- llena la tabla TempBOM_NIVEL de todos los productos


		-- el campo bst_tipocosto es temporal, se va a modificar de acuerdo al spi_codigo que se usando en el calculo
		exec SP_ACTUALIZATIPOCOSTOTempBOM_NIVEL @spi_codigo

		exec SP_CALCULABOMCOSTOTodos @fechaactual, @GuardaHist, @spi_codigo



	exec sp_droptable '#calculabom'


	UPDATE MAESTROCOST
	SET     MA_COSTO= ROUND(MA_GRAV_MP + MA_GRAV_ADD + MA_GRAV_EMP + MA_GRAV_GI + MA_GRAV_GI_MX + MA_GRAV_MO + MA_NG_MP +
	                      MA_NG_ADD + MA_NG_EMP,6)
	FROM         MAESTROCOST
	WHERE TCO_CODIGO=1 AND MA_PERINI <=GETDATE() and MA_PERFIN>= GETDATE() AND
	MA_COSTO<> ROUND(MA_GRAV_MP + MA_GRAV_ADD + MA_GRAV_EMP + MA_GRAV_GI + MA_GRAV_GI_MX + MA_GRAV_MO + MA_NG_MP +
	                      MA_NG_ADD + MA_NG_EMP,6)



	UPDATE dbo.FACTEXPDET
	SET     dbo.FACTEXPDET.FED_GRA_MP= dbo.VMAESTROCOST.MA_GRAV_MP, dbo.FACTEXPDET.FED_GRA_MO= dbo.VMAESTROCOST.MA_GRAV_MO, 
	      dbo.FACTEXPDET.FED_GRA_EMP= dbo.VMAESTROCOST.MA_GRAV_EMP, dbo.FACTEXPDET.FED_GRA_ADD= dbo.VMAESTROCOST.MA_GRAV_ADD, 
	      dbo.FACTEXPDET.FED_GRA_GI= dbo.VMAESTROCOST.MA_GRAV_GI, dbo.FACTEXPDET.FED_GRA_GI_MX= dbo.VMAESTROCOST.MA_GRAV_GI_MX, 
	      dbo.FACTEXPDET.FED_NG_MP= dbo.VMAESTROCOST.MA_NG_MP, dbo.FACTEXPDET.FED_NG_EMP= dbo.VMAESTROCOST.MA_NG_EMP, 
	      dbo.FACTEXPDET.FED_NG_ADD= dbo.VMAESTROCOST.MA_NG_ADD, dbo.FACTEXPDET.FED_NG_USA= dbo.VMAESTROCOST.MA_NG_USA, 
	      dbo.FACTEXPDET.FED_COS_UNI= dbo.VMAESTROCOST.MA_COSTO, dbo.FACTEXPDET.FED_COS_TOT= dbo.FACTEXPDET.FED_CANT*dbo.VMAESTROCOST.MA_COSTO
	FROM         dbo.VMAESTROCOST INNER JOIN
	                      dbo.FACTEXPDET ON dbo.VMAESTROCOST.MA_CODIGO = dbo.FACTEXPDET.MA_CODIGO
	WHERE     dbo.FACTEXPDET.TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO='P' OR CFT_TIPO='S') 
	AND (dbo.FACTEXPDET.FE_CODIGO = @FE_CODIGO)


























GO
