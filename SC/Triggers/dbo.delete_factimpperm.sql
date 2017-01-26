SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

































CREATE TRIGGER [delete_factimpperm] ON dbo.FACTIMPPERM 
FOR DELETE 
AS
declare @ped_indiced int, @pe_codigo int, @ControlaSaldo char(1), @fid_indiced int, @Fir_codigo int

	select @ped_indiced=ped_indiced, @pe_codigo=pe_codigo, @fid_indiced=fid_indiced, @Fir_codigo=Fir_codigo from deleted


	exec sp_DescargaCancelaPermisoFid @Fir_codigo

	/*SELECT     @ControlaSaldo=dbo.CONFIGURAPERMISOREL.CFR_SALDO
	FROM         dbo.PERMISO INNER JOIN
	                      dbo.CONFIGURAPERMISOREL ON dbo.PERMISO.IDE_CODIGO = dbo.CONFIGURAPERMISOREL.IDE_CODIGO
	WHERE     (dbo.PERMISO.PE_CODIGO = @pe_codigo)

	if @ControlaSaldo='S' and @ped_indiced is not null
	begin

		 UPDATE PermisoDet 
	              SET ped_saldo = ped_cant-isnull((select sum(factimpdet.fid_cant_st*factimpdet.eq_gen) from factimpdet inner join factimpperm
					on factimpdet.fid_indiced=factimpperm.fid_indiced where factimpperm.ped_indiced=@ped_indiced),0)
	               FROM permisodet 
	               WHERE ped_indiced  = @ped_indiced  
	
	
		UPDATE PermisoDet
		SET ped_enuso = 'S'
		WHERE ped_indiced = @ped_indiced
		AND ped_saldo = ped_cant
	
		UPDATE PermisoDet
		SET ped_enuso = 'N'
		WHERE ped_indiced = @ped_indiced
		AND ped_saldo <> ped_cant   
	
	end*/

































GO
