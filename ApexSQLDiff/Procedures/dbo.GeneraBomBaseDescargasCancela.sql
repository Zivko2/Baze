SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GeneraBomBaseDescargasCancela] (@fechaini varchar(10), @fechafin varchar(10), @fe_codigo int=0)   as

		if @fe_codigo is null
	set @fe_codigo=0

	alter table factexpdet disable trigger Update_FactExpDet

	if @fe_codigo>0
	begin

		update factexpdet
		set fed_retrabajo='N' where fed_indiced in 
		(select fed_indiced from RetrabajoModHist where fed_indiced in
		(select fed_indiced from factexpdet left outer join factexp
		on factexp.fe_codigo=factexpdet.fe_codigo where fed_retrabajo='E' 
		and factexp.fe_codigo= @fe_codigo))

	end
	else
	begin
		update factexpdet
		set fed_retrabajo='N' where fed_indiced in 
		(select fed_indiced from RetrabajoModHist where fed_indiced in
		(select fed_indiced from factexpdet left outer join factexp
		on factexp.fe_codigo=factexpdet.fe_codigo where fed_retrabajo='E' 
		and fe_fecha>=@fechaini and fe_fecha<=@fechafin))

	end

	
		delete from retrabajo 
		where tipo_factrans='F' and fetr_indiced in (select fed_indiced from factexpdet where fed_retrabajo='N')

	alter table factexpdet enable trigger Update_FactExpDet


GO
