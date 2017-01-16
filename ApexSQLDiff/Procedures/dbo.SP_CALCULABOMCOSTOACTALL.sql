SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






























CREATE PROCEDURE [dbo].[SP_CALCULABOMCOSTOACTALL] (@GuardaHist char(1)='N', @spi_codigo int =22)   as

SET NOCOUNT ON 
declare @ma_subensamble int, @fechaactual datetime, @bm_entravigor datetime

select @fechaactual=convert(varchar(11),getdate(),101)


UPDATE MAESTROCOST
SET SPI_CODIGO=22
WHERE SPI_CODIGO=0 OR SPI_CODIGO IS NULL


	/*================ Actualizacion de productos sin subensambles ===================*/
	exec sp_droptable 'CalculandoCosto'
	create table [dbo].[CalculandoCosto] (BST_PERTENECE int, BST_PERINI datetime)


	exec SP_CREATABLALOG 41
	insert into sysusrlog41 (user_id, mov_id, referencia, frmtag, fechahora)
	values (0, 2, 'Recalculo de Costos', 41, getdate())

	alter table MAESTROCOST disable  trigger Insert_MaestroCost

	begin tran
		insert into CalculandoCosto (BST_PERTENECE, BST_PERINI)
		SELECT     BOM_STRUCT.BSU_SUBENSAMBLE, @fechaactual
		FROM         BOM_STRUCT
		where BOM_STRUCT.bst_perini<=@fechaactual and BOM_STRUCT.bst_perfin>=@fechaactual
		AND BOM_STRUCT.BSU_SUBENSAMBLE NOT IN
			(SELECT A1.BSU_SUBENSAMBLE FROM BOM_STRUCT A1 LEFT OUTER JOIN MAESTRO M1 ON A1.BST_HIJO=M1.MA_CODIGO
				INNER JOIN CONFIGURATIPO ON
				M1.TI_CODIGO=CONFIGURATIPO.TI_CODIGO WHERE CFT_TIPO = 'S' and A1.BST_TIP_ENS<>'C'
			and A1.bst_perini <=@fechaactual and A1.bst_perfin>= @fechaactual
			GROUP BY A1.BSU_SUBENSAMBLE)
		GROUP BY BOM_STRUCT.BSU_SUBENSAMBLE
	commit tran	


	TRUNCATE TABLE TempBOM_NIVEL

	begin tran

		INSERT INTO TempBOM_NIVEL(BST_PT, BST_PERTENECE, BST_HIJO, BST_NIVEL, BST_PERINI, BST_INCORPOR, BST_INCORPORUSO)
		SELECT     BOM_STRUCT.BSU_SUBENSAMBLE, BOM_STRUCT.BSU_SUBENSAMBLE, BOM_STRUCT.BSU_SUBENSAMBLE, 1, @fechaactual, 1, 1
		FROM         BOM_STRUCT
		where BOM_STRUCT.bst_perini<=@fechaactual and BOM_STRUCT.bst_perfin>=@fechaactual
		AND BOM_STRUCT.BSU_SUBENSAMBLE NOT IN
			(SELECT A1.BSU_SUBENSAMBLE FROM BOM_STRUCT A1 LEFT OUTER JOIN MAESTRO M1 ON A1.BST_HIJO=M1.MA_CODIGO
				INNER JOIN CONFIGURATIPO ON
				M1.TI_CODIGO=CONFIGURATIPO.TI_CODIGO WHERE CFT_TIPO = 'S' and A1.BST_TIP_ENS<>'C'
			and A1.bst_perini <=@fechaactual and A1.bst_perfin>= @fechaactual
			GROUP BY A1.BSU_SUBENSAMBLE)
		GROUP BY BOM_STRUCT.BSU_SUBENSAMBLE
	commit tran

		exec SP_ACTUALIZATIPOCOSTOTempBOM_NIVEL @spi_codigo


		EXEC SP_CALCULABOMCOSTOSUB  @GuardaHist, @spi_codigo
	/*========================================================================*/
		TRUNCATE TABLE TempBOM_NIVEL



		exec SP_FILL_TempBOMNivelTodos  @fechaactual -- llena la tabla TempBOM_NIVEL de todos los productos

		-- borra los que ya se calculadon
		begin tran
			DELETE FROM TempBOM_NIVEL
			WHERE  BST_HIJO IN
				(SELECT     BOM_STRUCT.BSU_SUBENSAMBLE
				FROM         BOM_STRUCT
				where BOM_STRUCT.bst_perini<=@fechaactual and BOM_STRUCT.bst_perfin>=@fechaactual
				AND BOM_STRUCT.BSU_SUBENSAMBLE NOT IN
					(SELECT A1.BSU_SUBENSAMBLE FROM BOM_STRUCT A1 LEFT OUTER JOIN MAESTRO M1 ON A1.BST_HIJO=M1.MA_CODIGO
					INNER JOIN CONFIGURATIPO ON
					M1.TI_CODIGO=CONFIGURATIPO.TI_CODIGO WHERE CFT_TIPO = 'S'  and A1.BST_TIP_ENS<>'C'
					and A1.bst_perini <=@fechaactual and A1.bst_perfin>= @fechaactual
					GROUP BY A1.BSU_SUBENSAMBLE)
				GROUP BY BOM_STRUCT.BSU_SUBENSAMBLE)
		commit tran

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

	alter table MAESTROCOST enable  trigger Insert_MaestroCost


























GO
