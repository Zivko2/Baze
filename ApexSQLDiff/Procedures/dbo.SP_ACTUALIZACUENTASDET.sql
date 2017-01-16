SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_ACTUALIZACUENTASDET] (@tipo smallint=0)   as

		if @tipo=0
	begin
		update factimp
		set fi_cuentadet=(select isnull(count(factimpdet.fi_codigo),0) from factimpdet where factimpdet.fi_codigo =factimp.fi_codigo)
		where fi_cuentadet<>(select isnull(count(factimpdet.fi_codigo),0) from factimpdet where factimpdet.fi_codigo =factimp.fi_codigo)
	
		update factexp
		set fe_cuentadet=(select isnull(count(factexpdet.fe_codigo),0) from factexpdet where factexpdet.fe_codigo =factexp.fe_codigo)
		where fe_cuentadet<>(select isnull(count(factexpdet.fe_codigo),0) from factexpdet where factexpdet.fe_codigo =factexp.fe_codigo)
	
		update pedimp
		set pi_cuentadet=(select isnull(count(pedimpdet.pi_codigo),0) from pedimpdet where pedimpdet.pi_codigo =pedimp.pi_codigo)
		where pi_cuentadet<>(select isnull(count(pedimpdet.pi_codigo),0) from pedimpdet where pedimpdet.pi_codigo =pedimp.pi_codigo)
	
		update pedimp
		set pi_cuentadetb=(select isnull(count(pedimpdetb.pi_codigo),0) from pedimpdetb where pedimpdetb.pi_codigo =pedimp.pi_codigo)
		where pi_cuentadetb<>(select isnull(count(pedimpdetb.pi_codigo),0) from pedimpdetb where pedimpdetb.pi_codigo =pedimp.pi_codigo)
	end

	if @tipo=44 	
		update factimp
		set fi_cuentadet=(select isnull(count(factimpdet.fi_codigo),0) from factimpdet where factimpdet.fi_codigo =factimp.fi_codigo)
		where fi_cuentadet<>(select isnull(count(factimpdet.fi_codigo),0) from factimpdet where factimpdet.fi_codigo =factimp.fi_codigo)

	if @tipo=62 	
		update factexp
		set fe_cuentadet=(select isnull(count(factexpdet.fe_codigo),0) from factexpdet where factexpdet.fe_codigo =factexp.fe_codigo)
		where fe_cuentadet<>(select isnull(count(factexpdet.fe_codigo),0) from factexpdet where factexpdet.fe_codigo =factexp.fe_codigo)
	
	if @tipo=60 	
	begin
		update pedimp
		set pi_cuentadet=(select isnull(count(pedimpdet.pi_codigo),0) from pedimpdet where pedimpdet.pi_codigo =pedimp.pi_codigo)
		where pi_cuentadet<>(select isnull(count(pedimpdet.pi_codigo),0) from pedimpdet where pedimpdet.pi_codigo =pedimp.pi_codigo)
	
		update pedimp
		set pi_cuentadetb=(select isnull(count(pedimpdetb.pi_codigo),0) from pedimpdetb where pedimpdetb.pi_codigo =pedimp.pi_codigo)
		where pi_cuentadetb<>(select isnull(count(pedimpdetb.pi_codigo),0) from pedimpdetb where pedimpdetb.pi_codigo =pedimp.pi_codigo)
	end


GO
