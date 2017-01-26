SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_ASIGNAFACTURA] (@picodigo int, @ficodigo int, @user int)    as

SET NOCOUNT ON 
DECLARE @ccp_tipo varchar(5)


	select @ccp_tipo=ccp_tipo from configuraclaveped where cp_codigo in (select cp_codigo from pedimp where pi_codigo=@picodigo)


	IF (SELECT FC_CODIGO FROM PEDIMP WHERE PI_CODIGO=@picodigo) IS NOT NULL
	UPDATE FACTIMP
	SET FC_CODIGO=(SELECT FC_CODIGO FROM PEDIMP WHERE PI_CODIGO=@picodigo)
	WHERE FI_CODIGO=@ficodigo AND ISNULL(FC_CODIGO,0)<=0


	if @ccp_tipo='RE'
		update factimp
		set pi_rectifica=@picodigo, fi_estatus='C'
		where fi_codigo=@ficodigo
	else
		update factimp
		set pi_codigo=@picodigo, fi_estatus='C'
		where fi_codigo=@ficodigo


GO
