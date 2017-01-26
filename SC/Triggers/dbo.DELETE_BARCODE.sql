SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO























CREATE TRIGGER [DELETE_BARCODE] ON [dbo].[BARCODE] 
FOR DELETE 
AS
declare @BC_TIPOMOV char(1), @BC_TIPO char(1), @BC_CODIGO int


	select @BC_TIPOMOV=BC_TIPOMOV, @BC_TIPO=BC_TIPO, @BC_CODIGO=BC_CODIGO from deleted

	if @BC_TIPO='F'
	begin

		if @BC_TIPOMOV='E' 
		begin
		    IF EXISTS (SELECT * FROM FactImp  WHERE  FactImp.bc_Codigo = @BC_CODIGO)
		    update factimp
		    set bc_codigo=0
		    where bc_codigo=@BC_CODIGO
	
	
		end
		else
		    IF EXISTS (SELECT * FROM FactExp  WHERE  FactExp.bc_Codigo = @BC_CODIGO)
		    update factexp
		    set bc_codigo=0
		    where bc_codigo=@BC_CODIGO	
	end
	else
	    IF EXISTS (SELECT * FROM PedImp  WHERE  PedImp.bc_Codigo = @BC_CODIGO)
	    update PedImp
	    set bc_codigo=0
	    where bc_codigo=@BC_CODIGO	























GO
