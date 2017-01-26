SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

























CREATE TRIGGER [DELETE_TRANSMISIONDET] ON dbo.TRANSMISIONDET 
FOR DELETE 
AS
declare @TRM_CODIGO INT

	select @TRM_CODIGO=trm_codigo from deleted

	IF EXISTS(SELECT * FROM TRANSMISION WHERE TRM_CODIGO=@TRM_CODIGO)
	exec SP_ACTUALIZAESTATUSTRANSMISION @TRM_CODIGO

























GO
