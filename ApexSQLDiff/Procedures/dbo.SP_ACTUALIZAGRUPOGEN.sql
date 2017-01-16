SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

















































CREATE PROCEDURE [dbo].[SP_ACTUALIZAGRUPOGEN] (@ma_codigo int, @magennvo int)   as

SET NOCOUNT ON 
declare @ar_impmx  decimal(38,6), @ar_expmx  decimal(38,6), @ar_expfo  decimal(38,6), @ar_impfo  decimal(38,6), @ar_impfousa  decimal(38,6), @ar_desp  decimal(38,6), @ar_retra decimal(38,6)

	select @ar_impmx = ar_impmx, @ar_expmx = ar_expmx, @ar_expfo =ar_expfo, @ar_impfo = ar_impfo, @ar_impfousa = ar_impfousa, 
	@ar_desp = ar_desp, @ar_retra = ar_retra from maestro where ma_codigo = @magennvo


	update maestro
	set ma_generico = @magennvo
	where ma_codigo = @ma_codigo

	update maestro
	set ar_impmx = @ar_impmx
	where (ar_impmx is null or ar_impmx=0) and ma_codigo = @ma_codigo

	update maestro
	set ar_expmx = @ar_expmx
	where (ar_expmx is null or ar_expmx=0) and ma_codigo = @ma_codigo

	update maestro
	set ar_expfo = @ar_expfo
	where (ar_expfo is null or ar_expfo=0) and ma_codigo = @ma_codigo

	update maestro
	set ar_impfo = @ar_impfo
	where (ar_impfo is null or ar_impfo=0) and ma_codigo = @ma_codigo

	update maestro
	set ar_impfousa = @ar_impfousa
	where (ar_impfousa is null or ar_impfousa=0) and ma_codigo = @ma_codigo

	update maestro
	set ar_desp = @ar_desp
	where (ar_desp is null or ar_desp=0) and ma_codigo = @ma_codigo

	update maestro
	set ar_retra = @ar_retra
	where (ar_retra is null or ar_retra=0) and ma_codigo = @ma_codigo
















































GO
