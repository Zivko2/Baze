SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




































CREATE TRIGGER [INSERT_ARANCEL] ON dbo.ARANCEL 
FOR INSERT
AS
SET NOCOUNT ON 
declare @ar_codigo int, @ma_codigo int

	if (select CF_SINGENERICO from configuracion)='S' 
	begin
		declare crArancelInsert cursor for
			select ar_codigo from inserted
			where ar_tiporeg='F'
		open crArancelInsert
			fetch next from crArancelInsert into @ar_codigo
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN
				if @ar_codigo <>0
				exec SP_INSERTAGENERICOARANCEL @AR_CODIGO
	
			fetch next from crArancelInsert into @ar_codigo
			END
	
		CLOSE crArancelInsert
		DEALLOCATE crArancelInsert
	end

	if (select cf_singenerico from configuracion)='S'
	begin
		select @MA_CODIGO= max(isnull(MA_CODIGO,0))+1 from MAESTRO
		

		if exists(select * from maestrorefer) and (select max(isnull(ma_codigo,0)) from maestrorefer)>@MA_CODIGO
		select @MA_CODIGO= max(isnull(MA_CODIGO,0))+1 from MAESTROREFER
	
		update consecutivo
		set cv_codigo =  isnull(@ma_codigo,0)
		where cv_tipo = 'MA'
	end







































GO
