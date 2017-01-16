SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


-- actualiza el pais de origen en el catalogo maestro con el que mas se ha usado en las facturas, ademas de asignarle el tipo de tasa mas conveniente
CREATE PROCEDURE [dbo].[OPTIMIZAPAISORIGENMA]   as

SET NOCOUNT ON 

declare @ma_codigo int, @pa_origen int

	-- se genera la tabla TempTasa
	if not exists (select * from sysobjects where name='TempTasaMa')
	begin
	CREATE TABLE [dbo].[TempTasaMa] (
		[TM_CODIGO] [int] IDENTITY (1, 1) NOT NULL ,
		[MA_CODIGO] [int] NULL ,
		[MA_POR_DEF] decimal(38,6) NULL ,
		[SPI_CODIGO] [int] NULL ,
		[MA_SEC_IMP] [int] NULL ,
		[MA_DEF_TIP] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
	) ON [PRIMARY]
	end
	else
	begin
		TRUNCATE TABLE TempTasama
	end




	declare cur_maestrooptimiza cursor for
		SELECT     MAESTRO.MA_CODIGO
		FROM         MAESTRO INNER JOIN
		                      dbo.VFACTIMPPAISMAX ON MAESTRO.MA_CODIGO = dbo.VFACTIMPPAISMAX.MA_CODIGO
		WHERE MAESTRO.PA_ORIGEN<> dbo.VFACTIMPPAISMAX.PA_CODIGO
	open cur_maestrooptimiza
	
	
		FETCH NEXT FROM cur_maestrooptimiza INTO @ma_codigo
	
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN
	

			UPDATE MAESTRO
			SET     MAESTRO.PA_ORIGEN= dbo.VFACTIMPPAISMAX.PA_CODIGO
			FROM         MAESTRO INNER JOIN
			                      dbo.VFACTIMPPAISMAX ON MAESTRO.MA_CODIGO = dbo.VFACTIMPPAISMAX.MA_CODIGO
			WHERE MAESTRO.PA_ORIGEN<> dbo.VFACTIMPPAISMAX.PA_CODIGO AND MAESTRO.MA_CODIGO=@ma_codigo
	
			EXEC ACTUALIZATASABAJAMA @ma_codigo		

			-- cambia el pais en el BOM
			if exists (select * from bom_struct where bst_hijo=@ma_codigo)
			begin
				select @pa_origen=pa_origen from maestro where ma_codigo=@ma_codigo
	
				exec SP_ACTUALIZABOMSTRUCTPAIS @ma_codigo, @pa_origen
			end
	
		FETCH NEXT FROM cur_maestrooptimiza INTO @ma_codigo
	
	END
	
	CLOSE cur_maestrooptimiza
	DEALLOCATE cur_maestrooptimiza


	exec sp_droptable 'TempTasaMa'





GO
