SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO









/* cursor para todos los subensambles que estan en el nivel 1 */
CREATE PROCEDURE [SP_CALCULALABORCOSTO1]  (@bst_pt int, @ConsCal int) AS
SET NOCOUNT ON 

declare @bst_pertenece int,  @CostLabor float, @tco_manufactura int, @PorGastos float

declare cur_bstpertenece1 cursor for
	SELECT     BST_HIJO
	FROM         BOM_REP
	WHERE BST_HIJO IN (SELECT BST_HIJO FROM BOM_REP WHERE BST_PT=@bst_pt)
	AND BST_HIJO NOT IN (SELECT BST_PERTENECE FROM BOM_REP WHERE BST_PT=@bst_pt) AND
	BST_HIJO NOT IN (select MA_CODIGO from vmaestrocost where MA_CALMONO=@ConsCal)
	GROUP BY BST_PT, BST_HIJO, BST_NIVEL
	HAVING      (BST_PT = @bst_pt) 



open cur_bstpertenece1


	FETCH NEXT FROM cur_bstpertenece1 INTO @bst_pertenece

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

		select @tco_manufactura=tco_manufactura from configuracion


		SELECT  @CostLabor=   round(dbo.MAESTRO.MA_TIEMPOENSMIN * dbo.CENTROCOSTO.CC_MO,6)
		FROM         dbo.MAESTRO LEFT OUTER JOIN
		                      dbo.CENTROCOSTO ON dbo.MAESTRO.CC_CODIGO = dbo.CENTROCOSTO.CC_CODIGO
		WHERE     (dbo.MAESTRO.MA_CODIGO = @bst_pertenece)

		if ( SELECT  isnull(dbo.CENTROCOSTO.CC_GASIND,0) FROM dbo.MAESTRO LEFT OUTER JOIN dbo.CENTROCOSTO ON dbo.MAESTRO.CC_CODIGO = dbo.CENTROCOSTO.CC_CODIGO
		WHERE     (dbo.MAESTRO.MA_CODIGO = @bst_pertenece)) > 0

		SELECT  @PorGastos=   (dbo.CENTROCOSTO.CC_GASIND/100) * dbo.MAESTRO.MA_TIEMPOENSMIN * dbo.CENTROCOSTO.CC_MO
		FROM         dbo.MAESTRO LEFT OUTER JOIN
		                      dbo.CENTROCOSTO ON dbo.MAESTRO.CC_CODIGO = dbo.CENTROCOSTO.CC_CODIGO
		WHERE     (dbo.MAESTRO.MA_CODIGO = @bst_pertenece)
		else 
		set @PorGastos=0


		if exists(select * from vmaestrocost where ma_codigo =@bst_pertenece)
		begin
			update maestrocost
			set ma_grav_mo=isnull(@CostLabor,0)
			where ma_codigo=@bst_pertenece and tco_codigo =@tco_manufactura
			
			update maestrocost
			set ma_grav_gi_mx=@PorGastos
			where ma_codigo=@bst_pertenece and tco_codigo =@tco_manufactura
			and ( ma_grav_gi_mx is null or ma_grav_gi_mx=0)

		end
		else
		begin
			insert into maestrocost (ma_codigo, tco_codigo, ma_grav_mo, ma_grav_gi_mx)
			values (@bst_pertenece, @tco_manufactura, isnull(@CostLabor,0), @PorGastos)
		end


			
 		update maestrocost
		set ma_costo = round(isnull(ma_grav_mp,0) + isnull(ma_grav_add,0) + isnull(ma_grav_emp, 0) + isnull(ma_grav_gi,0) + 
		isnull(ma_grav_gi_mx,0) + isnull(ma_grav_mo,0) + isnull(ma_ng_mp,0) + isnull(ma_ng_add,0) + isnull(ma_ng_emp,0),6) 
		where ma_codigo=@bst_pertenece and tco_codigo=@tco_manufactura




	FETCH NEXT FROM cur_bstpertenece1 INTO @bst_pertenece

END

CLOSE cur_bstpertenece1
DEALLOCATE cur_bstpertenece1



GO
