SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE dbo.SP_getfactconvmaestro(@magenerico integer, @mecom integer, @ans decimal(38,6) output)   as

begin
	declare @codigo integer
	declare @medida integer

	select @medida = me_com from maestro where ma_codigo = @magenerico
	
	select @ans = eq_cant from equivale where me_codigo1 = @mecom and me_codigo2 = @medida

	if @ans is null
 		set @ans = 1
end



























GO
