SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
/* calcula los pesos del los subensambles en orden ascendente es decir del 12 al 1 */
CREATE PROCEDURE [dbo].[SP_CALCULABOMPESO]  (@bst_pt int, @Entravigor datetime)   as

SET NOCOUNT ON 
declare @fecha varchar(11), @nivel2 int, @ME_KILOGRAMOS INT, @BA_PESO decimal(28,6)

SET @Fecha =convert(varchar(10), @Entravigor,101)

	exec SP_FILL_TempBOMNivel @BST_PT, @Fecha


	select @ME_KILOGRAMOS=ME_KILOGRAMOS from configuracion


	insert into sysusrlog41 (user_id, mov_id, referencia, frmtag, fechahora)
	select 0, 2, ma_noparte+', Recalculo de Pesos', 41, getdate()
	from maestro 
	where ma_codigo=@bst_pt



	DECLARE cur_bstpeso2 CURSOR FOR
		SELECT     BST_NIVEL
		FROM         TempBOM_NIVEL
		WHERE BST_PT=@bst_pt 
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
					FROM         dbo.BOM_STRUCT LEFT OUTER JOIN
					                      dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
					                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
					WHERE     (dbo.BOM_STRUCT.BST_PERFIN >= @Fecha) AND (dbo.BOM_STRUCT.BST_PERINI <= @Fecha)
					AND      (dbo.BOM_STRUCT.BSU_SUBENSAMBLE = MAESTRO.MA_CODIGO) --AND 
						-- (dbo.CONFIGURATIPO.CFT_TIPO <> 'P')
					GROUP BY dbo.BOM_STRUCT.BSU_SUBENSAMBLE),0),6)
				WHERE MA_CODIGO IN (SELECT BST_HIJO FROM TempBOM_NIVEL WHERE BST_PT=@bst_pt AND BST_NIVEL=@nivel2 GROUP BY BST_HIJO)
			commit tran		
			
			begin tran
				UPDATE MAESTRO
				SET MA_PESO_LB=round(isnull(MA_PESO_KG,0)*2.20462442018378,6)
				WHERE MA_CODIGO IN (SELECT BST_HIJO FROM TempBOM_NIVEL WHERE BST_PT=@bst_pt AND BST_NIVEL=@nivel2  GROUP BY BST_HIJO)
			commit tran

			begin tran
				UPDATE MAESTROCATEG
				SET     MAESTROCATEG.EQ_CANT=MAESTRO.MA_PESO_KG
				FROM         MAESTRO INNER JOIN
				                      MAESTROCATEG ON MAESTRO.MA_CODIGO = MAESTROCATEG.MA_CODIGO INNER JOIN
				                      CATEGPERMISO ON MAESTROCATEG.CPE_CODIGO = CATEGPERMISO.CPE_CODIGO
				WHERE     (CATEGPERMISO.ME_CODIGO = @ME_KILOGRAMOS) 
				AND (MAESTRO.MA_CODIGO IN (SELECT BST_HIJO FROM TempBOM_NIVEL WHERE BST_PT=@bst_pt AND BST_NIVEL=@nivel2 GROUP BY BST_HIJO))
				AND MA_PESO_KG>0
			commit tran

			begin tran			
				UPDATE MAESTRO
				SET     MAESTRO.EQ_GEN=MAESTRO.MA_PESO_KG
				FROM         MAESTRO INNER JOIN
				                      MAESTRO MAESTRO_1 ON MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO
				WHERE     (MAESTRO.MA_CODIGO IN (SELECT BST_HIJO FROM TempBOM_NIVEL WHERE BST_PT=@bst_pt AND BST_NIVEL=@nivel2 GROUP BY BST_HIJO)) 
				AND (MAESTRO_1.ME_COM = @ME_KILOGRAMOS)
				AND MAESTRO.MA_PESO_KG>0
			commit tran

			begin tran
				UPDATE MAESTRO
				SET     MAESTRO.EQ_IMPMX=MA_PESO_KG
				FROM         MAESTRO INNER JOIN
				                      ARANCEL ON MAESTRO.AR_IMPMX = ARANCEL.AR_CODIGO
				WHERE     (MAESTRO.MA_CODIGO IN (SELECT BST_HIJO FROM TempBOM_NIVEL WHERE BST_PT=@bst_pt AND BST_NIVEL=@nivel2 GROUP BY BST_HIJO)) 
				AND (ARANCEL.ME_CODIGO = @ME_KILOGRAMOS)
				AND MA_PESO_KG>0
			commit tran
			
			begin tran
				UPDATE MAESTRO
				SET     MAESTRO.EQ_EXPMX=MA_PESO_KG
				FROM         MAESTRO INNER JOIN
				                      ARANCEL ON MAESTRO.AR_EXPMX = ARANCEL.AR_CODIGO
				WHERE     (MAESTRO.MA_CODIGO IN (SELECT BST_HIJO FROM TempBOM_NIVEL WHERE BST_PT=@bst_pt AND BST_NIVEL=@nivel2 GROUP BY BST_HIJO)) 
				AND (ARANCEL.ME_CODIGO = @ME_KILOGRAMOS)
				AND MA_PESO_KG>0
			commit tran

			begin tran			
				UPDATE MAESTRO
				SET     MAESTRO.EQ_IMPFO=MA_PESO_KG
				FROM         MAESTRO INNER JOIN
				                      ARANCEL ON MAESTRO.AR_IMPFO = ARANCEL.AR_CODIGO
				WHERE     (MAESTRO.MA_CODIGO IN (SELECT BST_HIJO FROM TempBOM_NIVEL WHERE BST_PT=@bst_pt AND BST_NIVEL=@nivel2 GROUP BY BST_HIJO)) 
				AND (ARANCEL.ME_CODIGO = @ME_KILOGRAMOS)
				AND MA_PESO_KG>0
			commit tran
			
			begin tran
				UPDATE MAESTRO
				SET     MAESTRO.EQ_EXPFO=MA_PESO_KG
				FROM         MAESTRO INNER JOIN
				                      ARANCEL ON MAESTRO.AR_EXPFO = ARANCEL.AR_CODIGO
				WHERE     (MAESTRO.MA_CODIGO IN (SELECT BST_HIJO FROM TempBOM_NIVEL WHERE BST_PT=@bst_pt AND BST_NIVEL=@nivel2 GROUP BY BST_HIJO)) 
				AND (ARANCEL.ME_CODIGO = @ME_KILOGRAMOS)				AND MA_PESO_KG>0
			commit tran

			begin tran
				UPDATE MAESTRO
				SET     MAESTRO.EQ_EXPFO2=MA_PESO_KG
				FROM         MAESTRO INNER JOIN
				                      ARANCEL ON MAESTRO.AR_EXPFO = ARANCEL.AR_CODIGO
				WHERE     (MAESTRO.MA_CODIGO IN (SELECT BST_HIJO FROM TempBOM_NIVEL WHERE BST_PT=@bst_pt AND BST_NIVEL=@nivel2 GROUP BY BST_HIJO)) 
				AND (ARANCEL.ME_CODIGO2 = @ME_KILOGRAMOS)
				AND MA_PESO_KG>0
			commit tran

			begin tran			
				UPDATE MAESTRO
				SET     MAESTRO.EQ_RETRA=MA_PESO_KG
				FROM         MAESTRO INNER JOIN
				                      ARANCEL ON MAESTRO.AR_RETRA = ARANCEL.AR_CODIGO
				WHERE     (MAESTRO.MA_CODIGO IN (SELECT BST_HIJO FROM TempBOM_NIVEL WHERE BST_PT=@bst_pt AND BST_NIVEL=@nivel2 GROUP BY BST_HIJO)) 
				AND (ARANCEL.ME_CODIGO = @ME_KILOGRAMOS)
				AND MA_PESO_KG>0
			commit tran

			begin tran			
				UPDATE MAESTRO
				SET     MAESTRO.EQ_IMPFOUSA=MA_PESO_KG
				FROM         MAESTRO INNER JOIN
				                      ARANCEL ON MAESTRO.AR_IMPFOUSA = ARANCEL.AR_CODIGO
				WHERE     (MAESTRO.MA_CODIGO IN (SELECT BST_HIJO FROM TempBOM_NIVEL WHERE BST_PT=@bst_pt AND BST_NIVEL=@nivel2 GROUP BY BST_HIJO)) 
				AND (ARANCEL.ME_CODIGO = @ME_KILOGRAMOS)
				AND MA_PESO_KG>0
			commit tran
	
		end
		else
		begin

			SELECT     @BA_PESO=SUM(isnull(dbo.MAESTRO.MA_PESO_KG,0) * isnull(dbo.BOM_STRUCT.BST_INCORPOR,0)) 
			FROM         dbo.BOM_STRUCT LEFT OUTER JOIN
			                      dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
			                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
			WHERE     (dbo.BOM_STRUCT.BST_PERFIN >= @Entravigor) AND (dbo.BOM_STRUCT.BST_PERINI <= @Entravigor)
			AND      (dbo.BOM_STRUCT.BSU_SUBENSAMBLE = @bst_pt) --and
					--(dbo.CONFIGURATIPO.CFT_TIPO <> 'P')
			GROUP BY dbo.BOM_STRUCT.BSU_SUBENSAMBLE



			UPDATE MAESTRO
			SET MA_PESO_KG = round(@BA_PESO,6)
			WHERE MA_CODIGO = @bst_pt
		

			begin tran
				UPDATE MAESTRO
				SET MA_PESO_LB=round(isnull(MA_PESO_KG,0)*2.20462442018378,6)
				WHERE MA_CODIGO = @bst_pt
			commit tran
		

			begin tran
				UPDATE MAESTROCATEG
				SET     MAESTROCATEG.EQ_CANT=MAESTRO.MA_PESO_KG
				FROM         MAESTRO INNER JOIN
				                      MAESTROCATEG ON MAESTRO.MA_CODIGO = MAESTROCATEG.MA_CODIGO INNER JOIN
				                      CATEGPERMISO ON MAESTROCATEG.CPE_CODIGO = CATEGPERMISO.CPE_CODIGO
				WHERE     (CATEGPERMISO.ME_CODIGO = @ME_KILOGRAMOS) 
				AND (MAESTRO.MA_CODIGO =@bst_pt)
				AND MA_PESO_KG>0
			commit tran

			begin tran			
				UPDATE MAESTRO
				SET     MAESTRO.EQ_GEN=MAESTRO.MA_PESO_KG
				FROM         MAESTRO INNER JOIN
				                      MAESTRO MAESTRO_1 ON MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO
				WHERE     (MAESTRO.MA_CODIGO =@bst_pt) 
				AND (MAESTRO_1.ME_COM = @ME_KILOGRAMOS)
				AND MAESTRO.MA_PESO_KG>0
			commit tran

			begin tran
				UPDATE MAESTRO
				SET     MAESTRO.EQ_IMPMX=MA_PESO_KG
				FROM         MAESTRO INNER JOIN
				                      ARANCEL ON MAESTRO.AR_IMPMX = ARANCEL.AR_CODIGO
				WHERE     (MAESTRO.MA_CODIGO =@bst_pt) 
				AND (ARANCEL.ME_CODIGO = @ME_KILOGRAMOS)
				AND MA_PESO_KG>0
			commit tran
			
			begin tran
				UPDATE MAESTRO
				SET     MAESTRO.EQ_EXPMX=MA_PESO_KG
				FROM         MAESTRO INNER JOIN
				                      ARANCEL ON MAESTRO.AR_EXPMX = ARANCEL.AR_CODIGO
				WHERE     (MAESTRO.MA_CODIGO =@bst_pt) 
				AND (ARANCEL.ME_CODIGO = @ME_KILOGRAMOS)
				AND MA_PESO_KG>0
			commit tran

			begin tran			
				UPDATE MAESTRO
				SET     MAESTRO.EQ_IMPFO=MA_PESO_KG
				FROM         MAESTRO INNER JOIN
				                      ARANCEL ON MAESTRO.AR_IMPFO = ARANCEL.AR_CODIGO
				WHERE     (MAESTRO.MA_CODIGO =@bst_pt) 
				AND (ARANCEL.ME_CODIGO = @ME_KILOGRAMOS)
				AND MA_PESO_KG>0
			commit tran
			
			begin tran
				UPDATE MAESTRO
				SET     MAESTRO.EQ_EXPFO=MA_PESO_KG
				FROM         MAESTRO INNER JOIN
				                      ARANCEL ON MAESTRO.AR_EXPFO = ARANCEL.AR_CODIGO
				WHERE     (MAESTRO.MA_CODIGO =@bst_pt) 
				AND (ARANCEL.ME_CODIGO = @ME_KILOGRAMOS) AND MA_PESO_KG>0
			commit tran

			begin tran
				UPDATE MAESTRO
				SET     MAESTRO.EQ_EXPFO2=MA_PESO_KG
				FROM         MAESTRO INNER JOIN
				                      ARANCEL ON MAESTRO.AR_EXPFO = ARANCEL.AR_CODIGO
				WHERE     (MAESTRO.MA_CODIGO =@bst_pt) 
				AND (ARANCEL.ME_CODIGO2 = @ME_KILOGRAMOS)
				AND MA_PESO_KG>0
			commit tran

			begin tran			
				UPDATE MAESTRO
				SET     MAESTRO.EQ_RETRA=MA_PESO_KG
				FROM         MAESTRO INNER JOIN
				                      ARANCEL ON MAESTRO.AR_RETRA = ARANCEL.AR_CODIGO
				WHERE     (MAESTRO.MA_CODIGO =@bst_pt) 
				AND (ARANCEL.ME_CODIGO = @ME_KILOGRAMOS)
				AND MA_PESO_KG>0
			commit tran

			begin tran			
				UPDATE MAESTRO
				SET     MAESTRO.EQ_IMPFOUSA=MA_PESO_KG
				FROM         MAESTRO INNER JOIN
				                      ARANCEL ON MAESTRO.AR_IMPFOUSA = ARANCEL.AR_CODIGO
				WHERE     (MAESTRO.MA_CODIGO =@bst_pt) 
				AND (ARANCEL.ME_CODIGO = @ME_KILOGRAMOS)
				AND MA_PESO_KG>0
			commit tran

		end
		FETCH NEXT FROM cur_bstpeso2 INTO @nivel2
	
	END
	
	CLOSE cur_bstpeso2
	DEALLOCATE cur_bstpeso2

GO
