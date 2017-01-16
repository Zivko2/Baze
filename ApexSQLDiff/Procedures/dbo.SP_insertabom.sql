SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE [dbo].[SP_insertabom] (@bsu_subensamble int, @EntraVigor datetime)   as

SET NOCOUNT ON 
declare @bsu_hijo int

	exec SP_filltablaimplosionsub @bsu_subensamble, @EntraVigor

	exec ('if exists (select * from dbo.sysobjects where id = object_id(N''[dbo].[DELETE_BOM]'') and OBJECTPROPERTY(id, N''IsTrigger'') = 1)
	drop trigger [dbo].[DELETE_BOM]')

		if exists (select * from bom where ma_subensamble =@bsu_subensamble)
		delete from bom where ma_subensamble =@bsu_subensamble

		--print 'cara' +convert(varchar(30),@bsu_subensamble)
		exec  SP_FILLTABLABOM @bsu_subensamble



		if exists (select * from tempImplosionSub where bst_hijo=@bsu_subensamble)
		--todos los padres posibles de este subensamble 
		begin
			declare cur_insertabom cursor for
				SELECT     bsu_subensamble				from tempImplosionSub 
				where bst_hijo=@bsu_subensamble
				group by bsu_subensamble
			open cur_insertabom
				FETCH NEXT FROM cur_insertabom INTO @bsu_hijo
			
				WHILE (@@FETCH_STATUS = 0) 
				BEGIN

				--print 'cara' +convert(varchar(30),@bsu_hijo)
				exec  SP_FILLTABLABOM @bsu_hijo
					
			
				FETCH NEXT FROM cur_insertabom INTO @bsu_hijo
			
			END
			
			CLOSE cur_insertabom
			DEALLOCATE cur_insertabom
		end


		--print 'termino'
		exec sp_creartriggerdelete_bom



























GO
