SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO












CREATE trigger Del_PedImpDet on dbo.PEDIMPDET for DELETE as
SET NOCOUNT ON

declare @afectado char(1)
begin

	IF EXISTS (SELECT * FROM PedImpCont ,deleted WHERE PedImpCont.pid_indiced = deleted.pid_indiced)
		DELETE PedImpCont FROM PedImpCont ,deleted WHERE PedImpCont.pid_indiced = deleted.pid_indiced

	IF EXISTS (SELECT * FROM AlmacenDesp,deleted WHERE AlmacenDesp.fetr_indiced = deleted.pid_indiced)
		DELETE AlmacenDesp FROM AlmacenDesp ,deleted WHERE AlmacenDesp.fetr_indiced = deleted.pid_indiced
		and ade_enuso = 'N' and AlmacenDesp.tipo_ent_sal='E'

	if exists (select * from pedimpdetb where pib_indiceb in (select pib_indiceb from deleted))
	delete from pedimpdetb where pib_indiceb in (select pib_indiceb from deleted)


	if exists (select * from pedimp where pi_codigo in (select pi_codigo from deleted))
	begin

		select @afectado = pi_afectado from pedimp where pi_codigo in (select pi_codigo from deleted)

		-- esta es la parte en la que marca el error... por si lo buscan   Febrero28
		if not exists (select * from pedimpdet where pi_codigo in (select pi_codigo from deleted)) 
		and (@afectado <>'N')
		update pedimp
		set pi_afectado='N'
		where pi_codigo in (select pi_codigo from deleted)
	
	end

	IF EXISTS (SELECT * FROM pidescarga,deleted WHERE pidescarga.pid_indiced = deleted.pid_indiced)
		DELETE pidescarga FROM pidescarga ,deleted WHERE pidescarga.pid_indiced = deleted.pid_indiced


end














GO
