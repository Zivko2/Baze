SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

/* cursor para todos los subensambles que estan en el nivel 1 */
CREATE PROCEDURE [dbo].[SP_CALCULALABORCOSTO2]  (@bst_pt int, @spi_codigo int)   as

SET NOCOUNT ON 
declare @bst_pertenece int,  @CostLabor decimal(38,6), @CostLaborsub decimal(38,6),  @tco_manufactura int,
@hola int, @PorGastos decimal(38,6), @fechaactual VARCHAR(11)


select @tco_manufactura=tco_manufactura from configuracion
set @fechaactual=convert(varchar(11),getdate(),101)

	insert into maestrocost (ma_codigo, ma_grav_mo, tco_codigo, ma_grav_gi_mx, SPI_CODIGO, MA_PERINI, MA_PERFIN)
	SELECT     BST_HIJO, 0, @tco_manufactura, 0, @spi_codigo, convert(varchar(11),getdate(),101), '01/01/9999'
	FROM         TempBOM_NIVEL
	WHERE  BST_HIJO NOT IN (SELECT MA_CODIGO FROM MAESTROCOST WHERE TCO_CODIGO=@tco_manufactura  and spi_codigo=@spi_codigo
						and MA_PERINI<=@fechaactual and MA_PERFIN>=@fechaactual)
	GROUP BY BST_HIJO


declare cur_bstpertenece2 cursor for
	SELECT     BST_HIJO
	FROM         TempBOM_NIVEL
	WHERE (BST_PT = @bst_pt) AND BST_HIJO<>@bst_pt
	GROUP BY BST_PT, BST_HIJO, BST_NIVEL
	ORDER BY BST_NIVEL DESC
open cur_bstpertenece2


	FETCH NEXT FROM cur_bstpertenece2 INTO @bst_pertenece

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

		begin tran
			update maestrocost
			set ma_grav_mo=
			-- sumatoria del costo de mano de obra de los subensambles que estan dentro del subensamble en cuestion
				isnull((SELECT SUM(VMAESTROCOST.MA_GRAV_MO * TempBOM_NIVEL.BST_INCORPOR) 
				FROM  TempBOM_NIVEL INNER JOIN VMAESTROCOST ON TempBOM_NIVEL.BST_HIJO = VMAESTROCOST.MA_CODIGO
				WHERE TempBOM_NIVEL.BST_PT=@bst_pt AND VMAESTROCOST.SPI_CODIGO=@spi_codigo 
					AND TempBOM_NIVEL.BST_PERTENECE = maestrocost.ma_codigo),0) +
			/* costo de ensamble del subensamble en cuestion */
				isnull((SELECT  round(dbo.MAESTRO.MA_TIEMPOENSMIN * dbo.CENTROCOSTO.CC_MO,6)
				FROM         dbo.MAESTRO LEFT OUTER JOIN
				                      dbo.CENTROCOSTO ON dbo.MAESTRO.CC_CODIGO = dbo.CENTROCOSTO.CC_CODIGO
				WHERE     dbo.MAESTRO.MA_CODIGO = maestrocost.ma_codigo),0)
	
			where ma_codigo=@bst_pertenece and tco_codigo = @tco_manufactura and spi_codigo=@spi_codigo
			and MA_PERINI<=@fechaactual and MA_PERFIN>=@fechaactual
		commit tran

		begin tran
			update maestrocost
			set ma_grav_gi_mx=
	
				isnull((SELECT  (dbo.CENTROCOSTO.CC_GASIND/100) * dbo.MAESTRO.MA_TIEMPOENSMIN * dbo.CENTROCOSTO.CC_MO
				FROM         dbo.MAESTRO LEFT OUTER JOIN
				                      dbo.CENTROCOSTO ON dbo.MAESTRO.CC_CODIGO = dbo.CENTROCOSTO.CC_CODIGO
				WHERE     dbo.MAESTRO.MA_CODIGO = maestrocost.ma_codigo),0)
	
			where ma_codigo=@bst_pertenece and tco_codigo =@tco_manufactura and spi_codigo=@spi_codigo
				and MA_PERINI<=@fechaactual and MA_PERFIN>=@fechaactual
				and isnull((SELECT  (dbo.CENTROCOSTO.CC_GASIND/100) * dbo.MAESTRO.MA_TIEMPOENSMIN * dbo.CENTROCOSTO.CC_MO
					FROM         dbo.MAESTRO LEFT OUTER JOIN
					                      dbo.CENTROCOSTO ON dbo.MAESTRO.CC_CODIGO = dbo.CENTROCOSTO.CC_CODIGO
					WHERE     dbo.MAESTRO.MA_CODIGO = maestrocost.ma_codigo),0)>0
		commit tran

		begin tran
	 		update maestrocost
			set ma_costo = round(isnull(ma_grav_mp,0) + isnull(ma_grav_add,0) + isnull(ma_grav_emp, 0) + isnull(ma_grav_gi,0) + 
			isnull(ma_grav_gi_mx,0) + isnull(ma_grav_mo,0) + isnull(ma_ng_mp,0) + isnull(ma_ng_add,0) + isnull(ma_ng_emp,0),6) 
			where ma_codigo=@bst_pertenece and tco_codigo=@tco_manufactura and spi_codigo=@spi_codigo
				and MA_PERINI<=@fechaactual and MA_PERFIN>=@fechaactual
		commit tran

	FETCH NEXT FROM cur_bstpertenece2 INTO @bst_pertenece

END

CLOSE cur_bstpertenece2
DEALLOCATE cur_bstpertenece2


		-- calculo de producto final
		begin tran
			update maestrocost
			set ma_grav_mo=
	
			-- sumatoria del costo de mano de obra de los subensambles que estan dentro del subensamble en cuestion
				isnull((SELECT SUM(VMAESTROCOST.MA_GRAV_MO * TempBOM_NIVEL.BST_INCORPOR) 
				FROM  TempBOM_NIVEL INNER JOIN VMAESTROCOST ON TempBOM_NIVEL.BST_HIJO = VMAESTROCOST.MA_CODIGO
				          AND TempBOM_NIVEL.BST_HIJO <>TempBOM_NIVEL.BST_PT
				WHERE  TempBOM_NIVEL.BST_PT=maestrocost.ma_codigo AND TempBOM_NIVEL.BST_PERTENECE = maestrocost.ma_codigo),0) 
			/* costo de ensamble del subensamble en cuestion */
				+isnull((SELECT  round(dbo.MAESTRO.MA_TIEMPOENSMIN * dbo.CENTROCOSTO.CC_MO,6)
				FROM         dbo.MAESTRO LEFT OUTER JOIN
				                      dbo.CENTROCOSTO ON dbo.MAESTRO.CC_CODIGO = dbo.CENTROCOSTO.CC_CODIGO
				WHERE     dbo.MAESTRO.MA_CODIGO = maestrocost.ma_codigo),0)
			where ma_codigo=@bst_pt and tco_codigo = @tco_manufactura and spi_codigo=@spi_codigo
			and MA_PERINI<=@fechaactual and MA_PERFIN>=@fechaactual

		commit tran

		begin tran
			update maestrocost
			set ma_grav_gi_mx=
	
				isnull((SELECT  (dbo.CENTROCOSTO.CC_GASIND/100) * dbo.MAESTRO.MA_TIEMPOENSMIN * dbo.CENTROCOSTO.CC_MO
				FROM         dbo.MAESTRO LEFT OUTER JOIN
				                      dbo.CENTROCOSTO ON dbo.MAESTRO.CC_CODIGO = dbo.CENTROCOSTO.CC_CODIGO
				WHERE     dbo.MAESTRO.MA_CODIGO = maestrocost.ma_codigo),0)
	
			where ma_codigo=@bst_pt and tco_codigo =@tco_manufactura and spi_codigo=@spi_codigo
				and MA_PERINI<=@fechaactual and MA_PERFIN>=@fechaactual
				and isnull((SELECT  (dbo.CENTROCOSTO.CC_GASIND/100) * dbo.MAESTRO.MA_TIEMPOENSMIN * dbo.CENTROCOSTO.CC_MO
					FROM         dbo.MAESTRO LEFT OUTER JOIN
					                      dbo.CENTROCOSTO ON dbo.MAESTRO.CC_CODIGO = dbo.CENTROCOSTO.CC_CODIGO
					WHERE     dbo.MAESTRO.MA_CODIGO = maestrocost.ma_codigo),0)>0

		commit tran

		begin tran
	 		update maestrocost
			set ma_costo = round(isnull(ma_grav_mp,0) + isnull(ma_grav_add,0) + isnull(ma_grav_emp, 0) + isnull(ma_grav_gi,0) + 
			isnull(ma_grav_gi_mx,0) + isnull(ma_grav_mo,0) + isnull(ma_ng_mp,0) + isnull(ma_ng_add,0) + isnull(ma_ng_emp,0),6) 
			where ma_codigo=@bst_pt and tco_codigo=@tco_manufactura and spi_codigo=@spi_codigo
				and MA_PERINI<=@fechaactual and MA_PERFIN>=@fechaactual
		commit tran


GO
