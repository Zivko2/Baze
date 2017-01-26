SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE dbo.SP_getfactconvara(@arimpmx integer, @arexpmx integer, @arimpfo integer, @arretra integer, @ardesp integer, @arexpfo integer, @mecom integer, @ansimpmx decimal(38,6) output, @ansexpmx decimal(38,6) output, @ansimpfo decimal(38,6) output, @ansretra decimal(38,6) output, @ansdesp decimal(38,6) output, @ansexpfo decimal(38,6) output)   as

begin
	declare @codigo integer
	declare @medida integer

	select @medida = me_codigo from arancel where ar_codigo = @arimpmx
	select @ansimpmx = eq_cant from equivale where me_codigo1 = @mecom and me_codigo2 = @medida
	if @ansimpmx is null
 		set @ansimpmx = 1

	select @medida = me_codigo from arancel where ar_codigo = @arexpmx
	select @ansexpmx = eq_cant from equivale where me_codigo1 = @mecom and me_codigo2 = @medida
	if @ansexpmx is null
 		set @ansexpmx = 1

	select @medida = me_codigo from arancel where ar_codigo = @arimpfo
	select @ansimpfo = eq_cant from equivale where me_codigo1 = @mecom and me_codigo2 = @medida
	if @ansimpfo is null
 		set @ansimpfo = 1

	select @medida = me_codigo from arancel where ar_codigo = @arretra
	select @ansretra = eq_cant from equivale where me_codigo1 = @mecom and me_codigo2 = @medida
	if @ansretra is null
 		set @ansretra = 1

	select @medida = me_codigo from arancel where ar_codigo = @ardesp
	select @ansdesp = eq_cant from equivale where me_codigo1 = @mecom and me_codigo2 = @medida
	if @ansdesp is null
 		set @ansdesp = 1

	select @medida = me_codigo from arancel where ar_codigo = @arexpfo
	select @ansexpfo = eq_cant from equivale where me_codigo1 = @mecom and me_codigo2 = @medida
	if @ansexpfo is null
 		set @ansexpfo = 1

end



























GO
