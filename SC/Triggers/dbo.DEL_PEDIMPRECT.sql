SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







































CREATE TRIGGER [DEL_PEDIMPRECT] ON [dbo].[PEDIMPRECT] 
FOR DELETE 
AS

declare @pi_codigo int, @rectificado int, @countrect int, @codigo int, @codigo2 int, @pi_movimiento char(1), @CCP_TIPO varchar(2),
@cp_codigo int


	
	select @pi_codigo=pi_codigo  from deleted
	select @cp_codigo=cp_codigo from pedimp where pi_codigo=@pi_codigo

	SELECT     @CCP_TIPO = CCP_TIPO FROM CONFIGURACLAVEPED WHERE CP_CODIGO 
		in (SELECT CP_CODIGO FROM inserted)



/*	select @countrect = count(*) from pedimprect where pi_codigo=@pi_codigo

  -- Se actualiza el rectificado

	if @countrect >= 1 
		update pedimp
		set pi_rectestatus='M'
		where pi_codigo=@pi_codigo
		and pi_rectestatus<>'M'

	if @countrect = 0 
	begin
		update pedimp
		set pi_rectestatus='S'
		where pi_codigo = @pi_codigo
		and pi_rectestatus<>'S'*/

		exec SP_ACTUALIZAESTATUSPEDIMP @pi_codigo, @cp_codigo
--	end








































































GO
