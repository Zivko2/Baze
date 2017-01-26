SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






















CREATE TRIGGER DEL_FACTCONS ON dbo.FACTCONS FOR DELETE 
AS

begin

  /* Se borra el detalle de la factura */
  IF EXISTS (SELECT * FROM FactConsTq, Deleted  WHERE  FactConsTq.Fc_Codigo = Deleted.Fc_codigo)
     DELETE FactConsTq FROM FactConsTq, Deleted  WHERE FactConsTq.Fc_Codigo = Deleted.Fc_codigo

  IF EXISTS (SELECT * FROM FactConsIdentifica, Deleted  WHERE  FactConsIdentifica.Fc_Codigo = Deleted.Fc_codigo)
     DELETE FactConsIdentifica FROM FactConsIdentifica, Deleted  WHERE FactConsIdentifica.Fc_Codigo = Deleted.Fc_codigo


  /* Se actualiza la factura de importacion */
  IF EXISTS (SELECT * FROM FactExp WHERE fc_codigo in (select fc_codigo from deleted where fc_tipo='S'))
	begin
	declare @codigo int
		declare curFcCodigoupdate cursor for
		select fc_codigo from factexp 
		where fc_codigo in (select fc_codigo from deleted)
	
		open curFcCodigoupdate
		fetch next from curFcCodigoupdate into @codigo
	
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN
				update factexp
				set fc_codigo = 0
				 where fe_codigo = @codigo
	
			fetch next from curFcCodigoupdate into @codigo
	
			END
		CLOSE curFcCodigoupdate
		DEALLOCATE curFcCodigoupdate

	end
end






















GO
