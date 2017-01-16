SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







































CREATE PROCEDURE [dbo].[SP_ACTUALIZA_PEDIMPRECT] (@PI_CODIGO INT, @PI_NO_RECT INT)   as

SET NOCOUNT ON 
declare @pi_codigo2 int
-- @pi_codigo pedimento rectificado
-- @pi_no_rect pedimento r1


	if not exists (select * from pedimprect where pi_no_rect=@PI_NO_RECT)
	begin
		insert into pedimprect (pi_codigo, pi_no_rect)
		values (@PI_CODIGO, @PI_NO_RECT)

	end
	else
	begin
		select @pi_codigo2=pi_codigo from pedimprect where pi_no_rect=@PI_NO_RECT

		if @pi_codigo2<>@PI_CODIGO
		begin
			delete from pedimprect where pi_no_rect=@PI_NO_RECT

			insert into pedimprect (pi_codigo, pi_no_rect)
			values (@PI_CODIGO, @PI_NO_RECT)

		end

	end






































GO
