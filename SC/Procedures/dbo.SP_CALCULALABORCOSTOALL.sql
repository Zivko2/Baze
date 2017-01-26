SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_CALCULALABORCOSTOALL] (@spi_codigo int=22)   as

SET NOCOUNT ON 
declare @fechaactual varchar(11), @tco_manufactura int, @nivel int

set @fechaactual=convert(varchar(11),getdate(),101)

	select @tco_manufactura=tco_manufactura from configuracion

	exec SP_FILL_TempBOMNivelTodos  @fechaactual -- llena la tabla TempBOM_NIVEL de todos los productos

	begin tran
		insert into maestrocost (ma_codigo, ma_grav_mo, tco_codigo, ma_grav_gi_mx, SPI_CODIGO, MA_PERINI, MA_PERFIN)
		select bst_hijo, 0, @tco_manufactura, 0, @spi_codigo, @fechaactual, '01/01/9999'
		from TempBOM_NIVEL
		where bst_hijo not in (select ma_codigo from maestrocost where tco_codigo=@tco_manufactura and spi_codigo=@spi_codigo and MA_PERINI<=@fechaactual and MA_PERFIN>=@fechaactual)
		group by bst_hijo			
	commit tran

	begin tran
		insert into maestrocost (ma_codigo, ma_grav_mo, tco_codigo, ma_grav_gi_mx, SPI_CODIGO, MA_PERINI, MA_PERFIN)
		select bst_pt, 0, @tco_manufactura, 0, @spi_codigo, @fechaactual, '01/01/9999'
		from TempBOM_NIVEL
		where bst_pt not in (select ma_codigo from maestrocost where tco_codigo=@tco_manufactura and spi_codigo=@spi_codigo and MA_PERINI<=@fechaactual and MA_PERFIN>=@fechaactual)
		group by bst_pt		
	commit tran

	declare cur_bstperteneceAll cursor for
		SELECT    BST_NIVEL
		FROM         TempBOM_NIVEL
		WHERE BST_PT<>BST_HIJO
		GROUP BY BST_NIVEL
		ORDER BY BST_NIVEL DESC
	open cur_bstperteneceAll
	
	
		FETCH NEXT FROM cur_bstperteneceAll INTO @nivel
	
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN
			

				begin tran
					update maestrocost
					set ma_grav_mo=	
					-- sumatoria del costo de mano de obra de los subensambles que estan dentro del subensamble en cuestion
						isnull((SELECT SUM(VMAESTROCOST.MA_GRAV_MO * TempBOM_NIVEL.BST_INCORPOR) 
						FROM  TempBOM_NIVEL INNER JOIN VMAESTROCOST ON TempBOM_NIVEL.BST_HIJO = VMAESTROCOST.MA_CODIGO
						          AND TempBOM_NIVEL.BST_HIJO <>TempBOM_NIVEL.BST_PT
						WHERE  TempBOM_NIVEL.BST_PT=maestrocost.ma_codigo AND TempBOM_NIVEL.BST_PERTENECE = maestrocost.ma_codigo),0) 
					-- costo de ensamble del subensamble en cuestion 
						+isnull((SELECT  round(dbo.MAESTRO.MA_TIEMPOENSMIN * dbo.CENTROCOSTO.CC_MO,6)
						FROM         dbo.MAESTRO LEFT OUTER JOIN
						                      dbo.CENTROCOSTO ON dbo.MAESTRO.CC_CODIGO = dbo.CENTROCOSTO.CC_CODIGO
						WHERE     dbo.MAESTRO.MA_CODIGO = maestrocost.ma_codigo),0)
					from maestrocost
					where ma_codigo in (select bst_pertenece from TempBOM_NIVEL where bst_nivel=@nivel and  BST_PERTENECE =BST_PT)
						and tco_codigo = @tco_manufactura and spi_codigo=@spi_codigo
					and MA_PERINI<=@fechaactual and MA_PERFIN>=@fechaactual
				commit tran

				begin tran
					update maestrocost
					set ma_grav_gi_mx=
						isnull((SELECT  (CENTROCOSTO.CC_GASIND/100) * gimx.MA_TIEMPOENSMIN * CENTROCOSTO.CC_MO
						FROM MAESTRO gimx LEFT OUTER JOIN CENTROCOSTO ON gimx.CC_CODIGO = CENTROCOSTO.CC_CODIGO
						WHERE     gimx.MA_CODIGO = maestrocost.ma_codigo),0)
					from maestrocost
					where ma_codigo in (select bst_pertenece from TempBOM_NIVEL where bst_nivel=@nivel and bst_pt<>bst_hijo)
						and tco_codigo =@tco_manufactura and spi_codigo=@spi_codigo
						and MA_PERINI<=@fechaactual and MA_PERFIN>=@fechaactual
						and isnull((SELECT  (CENTROCOSTO.CC_GASIND/100) * gimx.MA_TIEMPOENSMIN * CENTROCOSTO.CC_MO
							FROM MAESTRO gimx LEFT OUTER JOIN CENTROCOSTO ON gimx.CC_CODIGO = CENTROCOSTO.CC_CODIGO
							WHERE     gimx.MA_CODIGO = maestrocost.ma_codigo),0)>0
				commit tran

				begin tran
					update maestrocost
					set ma_costo = round(isnull(ma_grav_mp,0) + isnull(ma_grav_add,0) + isnull(ma_grav_emp, 0) + isnull(ma_grav_gi,0) + 
					isnull(ma_grav_gi_mx,0) + isnull(ma_grav_mo,0) + isnull(ma_ng_mp,0) + isnull(ma_ng_add,0) + isnull(ma_ng_emp,0),6) 
					from maestrocost
					where ma_codigo in (select bst_pertenece from TempBOM_NIVEL where bst_nivel=@nivel and bst_pt<>bst_hijo) and tco_codigo=@tco_manufactura
					and spi_codigo=@spi_codigo and MA_PERINI<=@fechaactual and MA_PERFIN>=@fechaactual
				commit tran
	
		FETCH NEXT FROM cur_bstperteneceAll INTO @nivel
	
	END
	
	CLOSE cur_bstperteneceAll
	DEALLOCATE cur_bstperteneceAll


			begin tran			
				update maestrocost
				set ma_grav_mo=
		
				-- sumatoria del costo de mano de obra de los subensambles que estan dentro del subensamble en cuestion
					isnull((SELECT SUM(VMAESTROCOST.MA_GRAV_MO * TempBOM_NIVEL.BST_INCORPOR) 
					FROM  TempBOM_NIVEL INNER JOIN VMAESTROCOST ON TempBOM_NIVEL.BST_HIJO = VMAESTROCOST.MA_CODIGO
					          AND TempBOM_NIVEL.BST_HIJO <>TempBOM_NIVEL.BST_PT
					WHERE  TempBOM_NIVEL.BST_PT=maestrocost.ma_codigo AND TempBOM_NIVEL.BST_PERTENECE = maestrocost.ma_codigo),0) 
				-- costo de ensamble del subensamble en cuestion 
					+isnull((SELECT  round(dbo.MAESTRO.MA_TIEMPOENSMIN * dbo.CENTROCOSTO.CC_MO,6)
					FROM         dbo.MAESTRO LEFT OUTER JOIN
					                      dbo.CENTROCOSTO ON dbo.MAESTRO.CC_CODIGO = dbo.CENTROCOSTO.CC_CODIGO
					WHERE     dbo.MAESTRO.MA_CODIGO = maestrocost.ma_codigo),0)
				from maestrocost
				where ma_codigo in (select bst_pertenece from TempBOM_NIVEL where bst_nivel=1 and  BST_PERTENECE =BST_PT)
					and tco_codigo = @tco_manufactura and spi_codigo=@spi_codigo
				and MA_PERINI<=@fechaactual and MA_PERFIN>=@fechaactual

			commit tran

			begin tran
				-- los que no tinenes subensambles dentro
				update maestrocost
				set ma_grav_mo= isnull((SELECT  round(dbo.MAESTRO.MA_TIEMPOENSMIN * dbo.CENTROCOSTO.CC_MO,6)
					FROM         dbo.MAESTRO LEFT OUTER JOIN
					                      dbo.CENTROCOSTO ON dbo.MAESTRO.CC_CODIGO = dbo.CENTROCOSTO.CC_CODIGO
					WHERE     dbo.MAESTRO.MA_CODIGO = maestrocost.ma_codigo),0)
				from maestrocost
				where tco_codigo = @tco_manufactura and spi_codigo=@spi_codigo
				and MA_PERINI<=@fechaactual and MA_PERFIN>=@fechaactual
				and ma_codigo in
					(SELECT     BSU_SUBENSAMBLE
					FROM         BOM_STRUCT
					WHERE BSU_SUBENSAMBLE NOT IN (SELECT BSU_SUBENSAMBLE FROM BOM_STRUCT LEFT OUTER JOIN MAESTRO
									ON BOM_STRUCT.BST_HIJO=MAESTRO.MA_CODIGO
									WHERE (MAESTRO.TI_CODIGO = 16 or MAESTRO.TI_CODIGO = 14) and bst_perini <=@fechaactual and bst_perfin>= @fechaactual GROUP BY BSU_SUBENSAMBLE)
					and bst_perini <=@fechaactual and bst_perfin>= @fechaactual 					
					GROUP BY BSU_SUBENSAMBLE)
			commit tran


			begin tran
				update maestrocost
				set ma_grav_gi_mx=
					isnull((SELECT  (CENTROCOSTO.CC_GASIND/100) * gimx.MA_TIEMPOENSMIN * CENTROCOSTO.CC_MO
					FROM MAESTRO gimx LEFT OUTER JOIN CENTROCOSTO ON gimx.CC_CODIGO = CENTROCOSTO.CC_CODIGO
					WHERE     gimx.MA_CODIGO = maestrocost.ma_codigo),0)
				from maestrocost
				where (ma_codigo in (select bst_pertenece from TempBOM_NIVEL where bst_nivel=1 and BST_PERTENECE =BST_PT) OR
				       ma_codigo in
						(SELECT     BSU_SUBENSAMBLE
						FROM         BOM_STRUCT
						WHERE BSU_SUBENSAMBLE NOT IN (SELECT BSU_SUBENSAMBLE FROM BOM_STRUCT LEFT OUTER JOIN MAESTRO
									ON BOM_STRUCT.BST_HIJO=MAESTRO.MA_CODIGO WHERE (MAESTRO.TI_CODIGO = 16 or MAESTRO.TI_CODIGO = 14) and bst_perini <=@fechaactual and bst_perfin>= @fechaactual GROUP BY BSU_SUBENSAMBLE)
						and bst_perini <=@fechaactual and bst_perfin>= @fechaactual 					
						GROUP BY BSU_SUBENSAMBLE))
					and tco_codigo =@tco_manufactura and spi_codigo=@spi_codigo
					and MA_PERINI<=@fechaactual and MA_PERFIN>=@fechaactual
					and isnull((SELECT  (CENTROCOSTO.CC_GASIND/100) * gimx.MA_TIEMPOENSMIN * CENTROCOSTO.CC_MO
						FROM MAESTRO gimx LEFT OUTER JOIN CENTROCOSTO ON gimx.CC_CODIGO = CENTROCOSTO.CC_CODIGO
						WHERE     gimx.MA_CODIGO = maestrocost.ma_codigo),0)>0
			commit tran

			begin tran
	
				UPDATE MAESTROCOST
				SET     MA_COSTO= ROUND(MA_GRAV_MP + MA_GRAV_ADD + MA_GRAV_EMP + MA_GRAV_GI + MA_GRAV_GI_MX + MA_GRAV_MO + MA_NG_MP +
				                      MA_NG_ADD + MA_NG_EMP,6)
				FROM         MAESTROCOST
				WHERE TCO_CODIGO=1 AND MA_PERINI <=@fechaactual and MA_PERFIN>= @fechaactual AND
				MA_COSTO<> ROUND(MA_GRAV_MP + MA_GRAV_ADD + MA_GRAV_EMP + MA_GRAV_GI + MA_GRAV_GI_MX + MA_GRAV_MO + MA_NG_MP +
				                      MA_NG_ADD + MA_NG_EMP,6)
			commit tran

GO
