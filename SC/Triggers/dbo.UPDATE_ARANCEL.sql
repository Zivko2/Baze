SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



































CREATE TRIGGER [UPDATE_ARANCEL] ON dbo.ARANCEL 
FOR UPDATE
AS
SET NOCOUNT ON 
declare @ar_codigo int

	declare curArancelUpdate cursor for
		select ar_codigo from inserted
		where ar_tiporeg='F'
	open curArancelUpdate
		fetch next from curArancelUpdate into @ar_codigo
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN


			--if (select CF_SINGENERICO from configuracion)='S' and @ar_codigo <>0
			--exec SP_INSERTAGENERICOARANCEL @AR_CODIGO

		
			if update(me_codigo) 
			exec SP_ACTUALIZAEQARANCEL @ar_codigo,  -1

	

		fetch next from curArancelUpdate into @ar_codigo
		END

	CLOSE curArancelUpdate
	DEALLOCATE curArancelUpdate









































GO
