SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







































-- este procedimiento se debera de actualizar en caso de que se modifique el trigger de borrado de la tabla de pedimpdet, pedimpdetb, pedimpcont, etc
CREATE PROCEDURE [dbo].[BorradoPedImpDet] (@pi_codigo int)   as


alter table [pedimpdet] disable trigger [Del_PedImpDet]

declare @afectado char(1)
begin

	IF EXISTS (SELECT * FROM PedImpCont  WHERE pi_codigo=@pi_codigo)
		DELETE PedImpCont FROM PedImpCont WHERE pi_codigo=@pi_codigo

	IF EXISTS (SELECT * FROM AlmacenDesp WHERE fetr_indiced in (select pid_indiced from pedimpdet where pi_codigo=@pi_codigo))
		DELETE AlmacenDesp FROM AlmacenDesp  where fetr_indiced in (select pid_indiced from pedimpdet where pi_codigo=@pi_codigo)
		and ade_enuso = 'N' and tipo_ent_sal='E'

	-- borrado del pedimpdetb
	exec BorradoPedImpDetB @pi_codigo

	if exists (select * from PIDescarga where pi_codigo=@pi_codigo)
	delete from PIDescarga where pi_codigo=@pi_codigo

end

	if exists (select * from pedimpdet where pi_codigo=@pi_codigo)
	delete from pedimpdet where pi_codigo=@pi_codigo


alter table [pedimpdet] enable trigger [Del_PedImpDet]






































GO
