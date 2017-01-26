SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







































CREATE PROCEDURE dbo.SP_AJUSTARETRABAJO_INVFIS @ivf_codigo integer   as


declare @noparte varchar(50), @cantretr decimal(38,6), @cantnormal decimal(38,6),@consecutivo int, @me_generico int, @me_codigo int,@ma_codigo int,
	@ivfd_nombre varchar(150), @ivfd_name varchar(150)


-- Donde el Saldo en Ped de PT/SUB es mayor al Inventario actual, pone el Inventario actual como retrabajo


update INVENTARIOFISDET set IVFD_RETRABAJO = 'R' from INVENTARIOFISDET
INNER join TEMP_INVENTARIOS on inventariofisdet.ma_codigo = temp_inventarios.ma_codigo
where IVF_CODIGO = @ivf_codigo and IVFD_RETRABAJO = 'N' and IVFD_NOPARTE in
(
select noparte from INVENTARIOFISDET
INNER join TEMP_INVENTARIOS on inventariofisdet.ma_codigo = temp_inventarios.ma_codigo
where IVFD_NOPARTE in
(select noparte from temp_inventarios
left outer join maestro on maestro.ma_codigo = temp_inventarios.ma_codigo
where ti_codigo in (14,16) and ma_tip_ens='F') 
group by noparte
having sum(ivfd_can_gen) <= sum(pid_saldogen) and sum(pid_saldogen) > 0
)




declare curTEMP_INVENTARIOS cursor for
select noparte,sum(pid_saldogen) as SALDOPED,sum(ivfd_can_gen) - sum(pid_saldogen) as CANTxEXPL from temp_inventarios
left outer join inventariofisdet on inventariofisdet.ma_codigo = temp_inventarios.ma_codigo
where IVF_CODIGO = @ivf_codigo and IVFD_RETRABAJO = 'N'and IVFD_NOPARTE in
(select noparte from temp_inventarios
left outer join maestro on maestro.ma_codigo = temp_inventarios.ma_codigo
where ti_codigo in (14,16) and ma_tip_ens='F') 
group by noparte
having sum(ivfd_can_gen) > sum(pid_saldogen) and sum(pid_saldogen) > 0

open curTEMP_INVENTARIOS
fetch next from curTEMP_INVENTARIOS into @noparte,@cantretr,@cantnormal

while (@@fetch_status = 0)
begin
	exec sp_getconsecutivo @tipo='IVFD', @value=@consecutivo output

	select @me_generico = me_generico, @me_codigo = me_codigo, @ma_codigo = ma_codigo, @ivfd_nombre = ivfd_nombre, @ivfd_name = ivfd_name
	from inventariofisdet 
	where ivf_codigo = @ivf_codigo and ivfd_noparte = @noparte and ivfd_retrabajo = 'N'

	insert into inventariofisdet (ivf_codigo,ivfd_indiced,ivfd_noparte,ivfd_cant,ivfd_can_gen,ivfd_retrabajo,me_generico,me_codigo,ma_codigo,ivfd_nombre,ivfd_name)
			values   (@ivf_codigo,@consecutivo,@noparte,@cantretr,@cantretr,'R',@me_generico,@me_codigo,@ma_codigo,@ivfd_nombre,@ivfd_name)

	update inventariofisdet set ivfd_cant = @cantnormal, ivfd_can_gen = @cantnormal where
 			ivf_codigo = @ivf_codigo and ivfd_noparte = @noparte and ivfd_retrabajo = 'N'
	
	fetch next from curTEMP_INVENTARIOS into @noparte,@cantretr,@cantnormal
end
close curTEMP_INVENTARIOS
deallocate curTEMP_INVENTARIOS






































GO
