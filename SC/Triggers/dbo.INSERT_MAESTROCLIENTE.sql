SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

































































CREATE TRIGGER [INSERT_MAESTROCLIENTE] ON dbo.MAESTROCLIENTE
FOR INSERT
AS

declare  @mc_grav_mp decimal(38,6),  @mc_grav_add decimal(38,6), @mc_grav_emp decimal(38,6), @ma_codigo int, @tipo char(1),
	@mc_grav_gi decimal(38,6),  @mc_grav_gi_mx decimal(38,6),  @mc_grav_mo decimal(38,6), @mc_ng_mp decimal(38,6), @mc_ng_add decimal(38,6), @mc_ng_emp decimal(38,6)


	select @mc_grav_mp = mc_grav_mp,  @ma_codigo = ma_codigo,
	@mc_grav_emp = mc_grav_emp,  @mc_grav_gi =mc_grav_gi,  @mc_grav_gi_mx = mc_grav_gi_mx,  
	@mc_grav_mo = mc_grav_mo, @mc_ng_mp = mc_ng_mp, @mc_ng_emp = mc_ng_emp
	from maestrocliente where mc_codigo in (select mc_codigo from inserted)

	select @tipo = cft_tipo from configuratipo where ti_codigo in (select ti_codigo from maestro where ma_codigo = @ma_codigo)

	if (@tipo = 'P') or (@tipo = 'S')
		update maestrocliente
		set mc_precio = isnull(@mc_grav_mp,0) + isnull(@mc_grav_emp, 0) + isnull(@mc_grav_gi,0) + 
		isnull(@mc_grav_gi_mx,0) + isnull(@mc_grav_mo,0) + isnull(@mc_ng_mp,0) + isnull(@mc_ng_emp,0) 
		where mc_codigo in (select mc_codigo from inserted)


































































GO
