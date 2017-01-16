SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_ACTUALIZASECUENCIA] (@PE_CODIGO INT, @PED_ID_SUBORD INT, @PED_REGISTROTIPO INT)   as

SET NOCOUNT ON 
declare @ped_indiced int, @SECUENCIA INT, @PED_CONSECUTIVO int
	
/*	producto terminado (PED_REGISTROTIPO=1, PED_ID_SUBORD=0)
	materia prima (PED_REGISTROTIPO=1, PED_ID_SUBORD<>0)
	contenedores (PED_REGISTROTIPO=2)
	herramienta (PED_REGISTROTIPO=3)
	maquinaria (PED_REGISTROTIPO=4)
*/


	UPDATE PERMISODET
	SET PED_CONSECUTIVO=0
	WHERE PE_CODIGO=@PE_CODIGO
	and ped_id_subord=@PED_ID_SUBORD
	and ped_registrotipo=@PED_REGISTROTIPO

declare cur_detallepermiso cursor for
	select ped_indiced from permisodet where 
	pe_codigo=@PE_CODIGO
	and ped_id_subord=@PED_ID_SUBORD
	and ped_registrotipo=@PED_REGISTROTIPO
	order by ped_indiced
open cur_detallepermiso


	FETCH NEXT FROM cur_detallepermiso INTO @ped_indiced

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

	SELECT @PED_CONSECUTIVO=ISNULL(MAX(PED_CONSECUTIVO),0) FROM PERMISODET  WHERE PE_CODIGO=@PE_CODIGO
	AND PED_REGISTROTIPO=@PED_REGISTROTIPO AND PED_ID_SUBORD=@PED_ID_SUBORD

	set @secuencia= @PED_CONSECUTIVO+1
	UPDATE PERMISODET
	SET PED_CONSECUTIVO=@SECUENCIA
	WHERE PED_INDICED = @ped_indiced


	FETCH NEXT FROM cur_detallepermiso INTO @ped_indiced

END

CLOSE cur_detallepermiso
DEALLOCATE cur_detallepermiso

GO
