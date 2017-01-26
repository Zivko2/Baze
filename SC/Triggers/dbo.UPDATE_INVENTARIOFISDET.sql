SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






















































CREATE TRIGGER [UPDATE_INVENTARIOFISDET] ON dbo.INVENTARIOFISDET 
FOR UPDATE,INSERT
AS
declare @IVF_CODIGO int, @countconcilia int,@cuenta int

	
	select @cuenta = count(*) from inserted
	select @IVF_CODIGO=IVF_CODIGO FROM inserted
	select @countconcilia=count(*) from inventariofisdet where IVF_CODIGO=@IVF_CODIGO and IVFD_CONCILIADO='N'

	if update(IVFD_CONCILIADO) and (@cuenta > 0) and (@countconcilia=0) --and exists (select * from inventariofis where IVF_CODIGO=@IVF_CODIGO)
		update inventariofis
		set ivf_estatus='C'
		where IVF_CODIGO=@IVF_CODIGO and ivf_estatus<>'C'
	/*
	if update(IVFD_CANT) and (@cuenta > 0)
	begin
		print 'actualizando cantidades'
		
		if not update(IVFD_CANT_SINTRANS)
	 		update inventariofisdet set ivfd_cant_sintrans = ivfd_cant-isnull(ivfd_cant_trans,0)  where ivfd_indiced in (select ivfd_indiced from inserted)
                           if not update(IVFD_CAN_GEN)
			update inventariofisdet set ivfd_can_gen = ivfd_cant*eq_generico  where ivfd_indiced in (select ivfd_indiced from inserted)
		
		
	end
	*/
	

	
		



























































GO
