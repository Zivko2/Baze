SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_droptable] (@table varchar(150), @tipo char(1)='T')   as

SET NOCOUNT ON 

declare @owner varchar(150), @cuenta int



	if @tipo='T' AND left(@table,1)='#'
	exec ('DELETE  '+@table)

if exists (select * from sysobjects where name=@table)
begin

		SELECT     @cuenta=count(sysusers.name)
		FROM         sysobjects INNER JOIN
		                      sysusers ON sysobjects.uid = sysusers.uid
		WHERE     (sysobjects.name = @table)


	if @cuenta>1
	begin


		DECLARE cur_owner CURSOR FOR
				SELECT     sysusers.name 
				FROM         sysobjects INNER JOIN
				                      sysusers ON sysobjects.uid = sysusers.uid
				WHERE     (sysobjects.name = @table)
		
		open cur_owner
			FETCH NEXT FROM cur_owner INTO @owner
		
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN

			if @tipo='T'
			exec ('DROP TABLE ['+@owner+'].['+@table+']')


			if @tipo='P'
			exec ('DROP PROCEDURE ['+@owner+'].['+@table+']')

			if @tipo='V'
			exec ('DROP VIEW ['+@owner+'].['+@table+']')

			FETCH NEXT FROM cur_owner INTO @owner
			
			END
		
		CLOSE cur_owner
		DEALLOCATE cur_owner
		
	
	end
	else
	begin
		SELECT     @owner=sysusers.name 
		FROM         sysobjects INNER JOIN
		                      sysusers ON sysobjects.uid = sysusers.uid
		WHERE     (sysobjects.name =@table)


		if @tipo='T'
		exec ('DROP TABLE ['+@owner+'].['+@table+']')


		if @tipo='P'
		exec ('DROP PROCEDURE ['+@owner+'].['+@table+']')

		if @tipo='V'
		exec ('DROP VIEW ['+@owner+'].['+@table+']')

	end	


end



GO
