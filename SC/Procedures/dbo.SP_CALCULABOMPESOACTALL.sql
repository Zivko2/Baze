SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

/* calcula los pesos del los subensambles en orden ascendente es decir del 12 al 1 */
CREATE PROCEDURE [dbo].[SP_CALCULABOMPESOACTALL]    as

SET NOCOUNT ON 
declare @fecha datetime, @nivel2 int, @ME_KILOGRAMOS INT

SET @Fecha =GETDATE()

	exec SP_FILL_TempBOMNivelTodos  @Fecha

	select @ME_KILOGRAMOS=ME_KILOGRAMOS from configuracion



	insert into sysusrlog41 (user_id, mov_id, referencia, frmtag, fechahora)
	values (0, 2, 'Recalculo de Pesos', 41, getdate())


	-- LOS QUE SOLO TIENEN UN NIVEL

		begin tran
		UPDATE MAESTRO
		SET MA_PESO_KG=
			ROUND(isnull((SELECT     SUM(isnull(M1.MA_PESO_KG,0) * isnull(dbo.BOM_STRUCT.BST_INCORPOR,0)) 
			FROM         dbo.BOM_STRUCT LEFT OUTER JOIN dbo.MAESTRO M1 on dbo.BOM_STRUCT.BST_HIJO = M1.MA_CODIGO 
			WHERE     (dbo.BOM_STRUCT.BST_PERFIN >= @Fecha) AND (dbo.BOM_STRUCT.BST_PERINI <= @Fecha)
			AND      (dbo.BOM_STRUCT.BSU_SUBENSAMBLE = MAESTRO.MA_CODIGO)),0),6)
		WHERE MA_CODIGO NOT IN 
			(SELECT A1.BSU_SUBENSAMBLE FROM BOM_STRUCT A1 LEFT OUTER JOIN MAESTRO M1 ON A1.BST_HIJO=M1.MA_CODIGO
						INNER JOIN CONFIGURATIPO ON
						M1.TI_CODIGO=CONFIGURATIPO.TI_CODIGO WHERE CFT_TIPO = 'S' and A1.BST_TIP_ENS<>'C'
						and A1.bst_perini <=@Fecha and A1.bst_perfin>= @Fecha
						GROUP BY A1.BSU_SUBENSAMBLE)
			AND  MA_CODIGO IN (SELECT A2.BSU_SUBENSAMBLE FROM BOM_STRUCT A2 
						WHERE A2.bst_perini <=@Fecha and A2.bst_perfin>= @Fecha
						GROUP BY A2.BSU_SUBENSAMBLE)
	
	
		commit tran
	
	

	-- EL RESTO
	DECLARE cur_bstpeso2 CURSOR FOR
		SELECT     BST_NIVEL
		FROM         TempBOM_NIVEL
		GROUP BY BST_NIVEL
		ORDER BY BST_NIVEL DESC
	open cur_bstpeso2
		FETCH NEXT FROM cur_bstpeso2 INTO @nivel2
	
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN
	
		if @nivel2 > 0
		begin

			begin tran
			UPDATE MAESTRO
			SET MA_PESO_KG=
				ROUND(isnull((SELECT     SUM(isnull(dbo.MAESTRO.MA_PESO_KG,0) * isnull(dbo.BOM_STRUCT.BST_INCORPOR,0)) 
				FROM         dbo.BOM_STRUCT LEFT OUTER JOIN dbo.MAESTRO ON 
					dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO
				WHERE     (dbo.BOM_STRUCT.BST_PERFIN >= @Fecha) AND (dbo.BOM_STRUCT.BST_PERINI <= @Fecha)
				AND      (dbo.BOM_STRUCT.BSU_SUBENSAMBLE = MAESTRO.MA_CODIGO)),0),6)
			WHERE MA_CODIGO IN (SELECT BST_PT FROM TempBOM_NIVEL WHERE BST_NIVEL=@nivel2 GROUP BY BST_PT)
			commit tran

	
	
		end
		FETCH NEXT FROM cur_bstpeso2 INTO @nivel2
	
	END
	
	CLOSE cur_bstpeso2
	DEALLOCATE cur_bstpeso2



	begin tran			
	UPDATE MAESTRO
	SET MA_PESO_LB=round(isnull(MA_PESO_KG,0)*2.20462442018378,6)
	WHERE MA_CODIGO IN (SELECT BST_PT FROM TempBOM_NIVEL WHERE BST_NIVEL=@nivel2  GROUP BY BST_PT)
	and MA_PESO_LB<>round(isnull(MA_PESO_KG,0)*2.20462442018378,6)
	commit tran

	begin tran
	UPDATE MAESTROCATEG
	SET     MAESTROCATEG.EQ_CANT=MAESTRO.MA_PESO_KG
	FROM         MAESTRO INNER JOIN
	                      MAESTROCATEG ON MAESTRO.MA_CODIGO = MAESTROCATEG.MA_CODIGO INNER JOIN
	                      CATEGPERMISO ON MAESTROCATEG.CPE_CODIGO = CATEGPERMISO.CPE_CODIGO
	WHERE     (CATEGPERMISO.ME_CODIGO = @ME_KILOGRAMOS) AND MA_PESO_KG>0
	and MAESTROCATEG.EQ_CANT<>MAESTRO.MA_PESO_KG
	commit tran

	begin tran
	UPDATE MAESTRO
	SET     MAESTRO.EQ_GEN=MAESTRO.MA_PESO_KG
	FROM         MAESTRO INNER JOIN
	                      MAESTRO MAESTRO_1 ON MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO
	WHERE     (MAESTRO_1.ME_COM = @ME_KILOGRAMOS)
	AND MAESTRO.MA_PESO_KG>0 and MAESTRO.EQ_GEN<>MAESTRO.MA_PESO_KG
	commit tran

	begin tran
	UPDATE MAESTRO
	SET     MAESTRO.EQ_IMPMX=MA_PESO_KG
	FROM         MAESTRO INNER JOIN
	                      ARANCEL ON MAESTRO.AR_IMPMX = ARANCEL.AR_CODIGO
	WHERE     (ARANCEL.ME_CODIGO = @ME_KILOGRAMOS)
	AND MA_PESO_KG>0 and MAESTRO.EQ_IMPMX<>MA_PESO_KG
	commit tran

	begin tran
	UPDATE MAESTRO
	SET     MAESTRO.EQ_EXPMX=MA_PESO_KG
	FROM         MAESTRO INNER JOIN
	                      ARANCEL ON MAESTRO.AR_EXPMX = ARANCEL.AR_CODIGO
	WHERE     (ARANCEL.ME_CODIGO = @ME_KILOGRAMOS)
	AND MA_PESO_KG>0 and MAESTRO.EQ_EXPMX<>MA_PESO_KG
	commit tran

	begin tran
	UPDATE MAESTRO
	SET     MAESTRO.EQ_IMPFO=MA_PESO_KG
	FROM         MAESTRO INNER JOIN
	                      ARANCEL ON MAESTRO.AR_IMPFO = ARANCEL.AR_CODIGO
	WHERE     (ARANCEL.ME_CODIGO = @ME_KILOGRAMOS)
	AND MA_PESO_KG>0 and MAESTRO.EQ_IMPFO<>MA_PESO_KG
	commit tran

	begin tran
	UPDATE MAESTRO
	SET     MAESTRO.EQ_EXPFO=MA_PESO_KG
	FROM         MAESTRO INNER JOIN
	                      ARANCEL ON MAESTRO.AR_EXPFO = ARANCEL.AR_CODIGO
	WHERE     (ARANCEL.ME_CODIGO = @ME_KILOGRAMOS)
	AND MA_PESO_KG>0 and MAESTRO.EQ_EXPFO<>MA_PESO_KG
	commit tran

	begin tran
	UPDATE MAESTRO
	SET     MAESTRO.EQ_EXPFO2=MA_PESO_KG
	FROM         MAESTRO INNER JOIN
	                      ARANCEL ON MAESTRO.AR_EXPFO = ARANCEL.AR_CODIGO
	WHERE     (ARANCEL.ME_CODIGO2 = @ME_KILOGRAMOS)
	AND MA_PESO_KG>0 and MAESTRO.EQ_EXPFO2<>MA_PESO_KG
	commit tran

	begin tran
	UPDATE MAESTRO
	SET     MAESTRO.EQ_RETRA=MA_PESO_KG
	FROM         MAESTRO INNER JOIN
	                      ARANCEL ON MAESTRO.AR_RETRA = ARANCEL.AR_CODIGO
	WHERE     (ARANCEL.ME_CODIGO = @ME_KILOGRAMOS)
	AND MA_PESO_KG>0 and MAESTRO.EQ_RETRA<>MA_PESO_KG
	commit tran

	begin tran
	UPDATE MAESTRO
	SET     MAESTRO.EQ_IMPFOUSA=MA_PESO_KG
	FROM         MAESTRO INNER JOIN
	                      ARANCEL ON MAESTRO.AR_IMPFOUSA = ARANCEL.AR_CODIGO
	WHERE     (ARANCEL.ME_CODIGO = @ME_KILOGRAMOS)
	AND MA_PESO_KG>0 and MAESTRO.EQ_IMPFOUSA<>MA_PESO_KG
	commit tran





GO