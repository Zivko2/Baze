SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





/* calcula los costos del los subensambles en orden ascendente es decir del 12 al 1 */
CREATE PROCEDURE [dbo].[SP_CALCULABOMCOSTOTodos] (@fechaactual datetime, @GuardaHist char(1)='N', @spi_codigo int =22)   as

SET NOCOUNT ON 
declare @fecha varchar(10), @nivelmax int, @ConsCal int


	/*======== actualiza la tabla bom_costo =================================*/
	exec sp_droptable 'CalculandoCosto'
	create table [dbo].[CalculandoCosto] (BST_PERTENECE int, BST_PERINI datetime)

	/*=================================================================*/


	SELECT     @nivelmax = max (BST_NIVEL)+1
	FROM         dbo.TempBOM_NIVEL


	EXEC SP_CALCULABOMCOSTO2Todos  @nivelmax, @GuardaHist, @spi_codigo

	EXEC SP_CALCULABOMCOSTOSUB @GuardaHist, @spi_codigo

	 TRUNCATE TABLE CalculandoCosto

	insert into CalculandoCosto(bst_pertenece, bst_perini)
	select bst_hijo, bst_perini
	 from TempBOM_NIVEL where bst_nivel=1

	EXEC SP_CALCULABOMCOSTOSUB  @GuardaHist, @spi_codigo 

	 TRUNCATE TABLE CalculandoCosto

	insert into CalculandoCosto(bst_pertenece, bst_perini)
	select bst_hijo, bst_perini
	 from TempBOM_NIVEL where bst_nivel=1

	EXEC SP_CALCULABOMCOSTOSUB  @GuardaHist, @spi_codigo




	 IF (SELECT CF_USACOSTNODUTNAFTA FROM CONFIGURACION)='S' and @spi_codigo in (select spi_codigo from spi where spi_clave='nafta')
	   begin
		alter table MAESTROCOST disable trigger Insert_MaestroCost 

		begin tran
			 UPDATE MAESTROCOST
			SET MA_GRAV_MP= round(MA_GRAV_MP+ MA_GRAV_ADD+ MA_GRAV_EMP+ MA_NG_MP+ MA_NG_ADD+ MA_NG_EMP,6),
			MA_GRAV_ADD=0, MA_GRAV_EMP=0, MA_NG_MP=0, MA_NG_ADD=0, MA_NG_EMP=0, MA_NG_USA=0
			FROM   MAESTROCOST
			WHERE  TCO_CODIGO IN (SELECT TCO_MANUFACTURA
			                            FROM configuracion) and  SPI_CODIGO = @spi_codigo and ma_perini <=getdate() and ma_perfin >= getdate()
			    AND MA_CODIGO IN (SELECT MA_CODIGO FROM NAFTA INNER JOIN SPI ON NAFTA.SPI_CODIGO = SPI.SPI_CODIGO
			                            WHERE SPI.SPI_CLAVE = 'NAFTA' and NFT_CALIFICO='S' AND NAFTA.NFT_PERINI <= getdate() AND 
			                                                   NAFTA.NFT_PERFIN >= getdate())
			--  AND MA_CODIGO IN (SELECT BST_PERTENECE FROM CalculandoCosto)

		commit tran

		alter table MAESTROCOST enable trigger Insert_MaestroCost 
	  end

	exec sp_droptable 'CalculandoCosto'





















GO
