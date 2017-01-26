SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
































CREATE TRIGGER [DELETE_PERMISODET] ON dbo.PERMISODET 
FOR DELETE, INSERT 
AS

	declare @consecutivo int, @PED_ID_SUBORD INT, @PE_CODIGO INT, @PED_REGISTROTIPO INT, @PED_INDICED INT

	SELECT @PE_CODIGO=PE_CODIGO, @PED_INDICED=PED_INDICED, @PED_ID_SUBORD=isnull(PED_ID_SUBORD,0), 
		@PED_REGISTROTIPO=isnull(PED_REGISTROTIPO,0) FROM deleted

	SELECT @PE_CODIGO=PE_CODIGO, @PED_ID_SUBORD=isnull(PED_ID_SUBORD,0), @PED_REGISTROTIPO=isnull(PED_REGISTROTIPO,0) FROM INSERTED

	SELECT @consecutivo = isnull(MAX(PED_INDICED),0)+1 FROM PERMISODET

	update consecutivo
	set cv_codigo = @consecutivo
	where cv_tipo ='PED'


	if @PED_REGISTROTIPO=1 and (@PED_ID_SUBORD=0 or @PED_ID_SUBORD is null) and exists(select * from permisodet where ped_id_subord=@PED_INDICED)
	delete from permisodet where PED_REGISTROTIPO=1 and PED_ID_SUBORD = @PED_INDICED


	EXEC SP_ACTUALIZASECUENCIA @PE_CODIGO, @PED_ID_SUBORD, @PED_REGISTROTIPO































GO
