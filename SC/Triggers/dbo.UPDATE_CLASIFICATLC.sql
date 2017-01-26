SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

































CREATE TRIGGER [UPDATE_CLASIFICATLC] ON dbo.CLASIFICATLC 
FOR UPDATE, INSERT
AS
declare @clt_codigo int, @pa_codigo int, @bst_trans char(1), @dummy char(1)

	if update(pa_codigo) or update(bst_trans) 
	begin
		declare crBOMUpdates cursor for
			select  clt_codigo, pa_codigo, bst_trans  from inserted
		open crBOMUpdates
		fetch next from crBOMUpdates into @clt_codigo, @pa_codigo, @bst_trans
		
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN
	

				--exec stpTipoCostoTLC @clt_codigo,  @bst_trans, @pa_codigo, @tipocosto=@dummy output

				--update clasificatlc set bst_tipocosto = @dummy 
				--where clt_codigo = @clt_codigo



	
				fetch next from crBOMUpdates into @clt_codigo, @pa_codigo, @bst_trans
			END
		CLOSE crBOMUpdates
		DEALLOCATE crBOMUpdates

	end



































GO
