SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_CALCULAREMESASFACTAGRU]  (@fia_codigo int, @tipo char(1))   as

SET NOCOUNT ON 

declare @FE_CONSECUTIVOPED int, @FI_CONSECUTIVOPED int, @valor int, @siguiente int, @remesaini1 int, @remesaini INT, @remesafin INT


	IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
	   WHERE name = '##remesafactagru'  AND  type = 'U')
	begin
		drop table ##remesafactagru
	end


CREATE TABLE ##remesafactagru (
	[fia_codigo] [int] NULL ,
	[remesaini] [int] NULL ,
	[remesafin] [int] NULL 
) 

if @tipo='S'
begin
	UPDATE FACTEXPAGRU
	SET FEA_COMENTA=NULL
	WHERE     (FEA_CODIGO = @fia_codigo)			


	SELECT  @valor=min(CONVERT(INT, FE_CONSECUTIVOPED))
	FROM         FACTEXP
	WHERE     (FE_FACTAGRU = @fia_codigo)


	  insert into ##remesafactagru (fia_codigo, remesaini, remesafin)
	  values(@fia_codigo, @valor, 0)
	
	
	declare cur_remesas cursor for
		SELECT     CONVERT(INT, FE_CONSECUTIVOPED) 
		FROM         FACTEXP
		WHERE     (FE_FACTAGRU = @fia_codigo)
		AND FE_CONSECUTIVOPED IS NOT NULL
		ORDER BY CONVERT(INT, FE_CONSECUTIVOPED)
	open cur_remesas
		FETCH NEXT FROM cur_remesas INTO @FE_CONSECUTIVOPED
	
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN
			set @valor=@valor+1
	
			SELECT    @siguiente=MIN(CONVERT(INT, FE_CONSECUTIVOPED)) 
			FROM         dbo.FACTEXP
			WHERE     (FE_FACTAGRU = @fia_codigo) AND (CONVERT(INT, FE_CONSECUTIVOPED) > @FE_CONSECUTIVOPED)
	
			
			if @valor <> @siguiente
			begin
				if exists(select * from ##remesafactagru where remesafin=0)
				update ##remesafactagru
				set remesafin=@valor-1
				where remesafin=0
	
				set @valor=@siguiente
	
				insert into ##remesafactagru (fia_codigo, remesaini, remesafin)
				values(@fia_codigo, @valor, 0)
	
			end
	
	
		FETCH NEXT FROM cur_remesas INTO @FE_CONSECUTIVOPED
	
	END
	
	CLOSE cur_remesas
	DEALLOCATE cur_remesas
	
	
	update ##remesafactagru
	set remesafin=(SELECT max(CONVERT(INT, FE_CONSECUTIVOPED))
		       FROM FACTEXP
		       WHERE FE_FACTAGRU = @fia_codigo)
	where remesafin=0


	-- actualizacion de comentarios

		declare cur_remesasfin cursor for
			SELECT     remesaini, remesafin
			FROM         ##remesafactagru
			WHERE     (fia_codigo = @fia_codigo)
			AND remesaini <> remesafin
		open cur_remesasfin
			FETCH NEXT FROM cur_remesasfin INTO @remesaini, @remesafin
		
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN
	
			SELECT @remesaini1 = min(remesaini) FROM ##remesafactagru WHERE fia_codigo = @fia_codigo AND remesaini <> remesafin
	
			if @remesaini1=@remesaini
				UPDATE factexpagru
				SET fea_COMENTA=isnull(fea_COMENTA,'')+'Remesas:'+CONVERT(varchar(20), @remesaini) + '-' + CONVERT(varchar(20), @remesafin) 
				WHERE     (fea_codigo = @fia_codigo)			
			else		
				
				UPDATE factexpagru
				SET fea_comenta=fea_COMENTA+','+CONVERT(varchar(20), @remesaini) + '-' + CONVERT(varchar(20), @remesafin) 
				WHERE     (fea_codigo = @fia_codigo)			
			FETCH NEXT FROM cur_remesasfin INTO @remesaini, @remesafin
		
		END
		
		CLOSE cur_remesasfin
		DEALLOCATE cur_remesasfin
	
		declare cur_remesasworango cursor for
			SELECT     remesaini
			FROM         ##remesafactagru
			WHERE     (fia_CODIGO = @fia_codigo)
			AND remesaini = remesafin
	
		open cur_remesasworango
			FETCH NEXT FROM cur_remesasworango INTO @remesaini
		
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN
	
			if not exists(select fea_comenta from factexpagru where fea_codigo=@fia_codigo and (fea_comenta like 'remesas%' or fea_comenta like '%remesas%' ))
				UPDATE factexpagru
				SET fea_comenta=isnull(fea_comenta,'')+'Remesas:'+CONVERT(varchar(20), @remesaini)  
				WHERE     (fea_codigo = @fia_codigo)			
			else			
				UPDATE factexpagru
				SET fea_COMENTA=fea_COMENTA+','+CONVERT(varchar(20), @remesaini) 
				WHERE     (fea_codigo = @fia_codigo)			
			FETCH NEXT FROM cur_remesasworango INTO @remesaini
		
		END
		
		CLOSE cur_remesasworango
		DEALLOCATE cur_remesasworango
	
	


end
else
begin
	UPDATE FACTIMPAGRU
	SET FIA_COMENTA=NULL
	WHERE     (FIA_CODIGO = @fia_codigo)			

	SELECT  @valor=min(CONVERT(INT, FI_CONSECUTIVOPED))
	FROM         FACTIMP
	WHERE     (FI_FACTAGRU = @fia_codigo)


	  insert into ##remesafactagru (fia_codigo, remesaini, remesafin)
	  values(@fia_codigo, @valor, 0)
	
	
	declare cur_remesas cursor for
		SELECT     CONVERT(INT, FI_CONSECUTIVOPED) 
		FROM         FACTIMP
		WHERE     (FI_FACTAGRU = @fia_codigo)
		AND FI_CONSECUTIVOPED IS NOT NULL
		ORDER BY CONVERT(INT, FI_CONSECUTIVOPED)
	open cur_remesas
		FETCH NEXT FROM cur_remesas INTO @FI_CONSECUTIVOPED
	
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN
			set @valor=@valor+1
	
			SELECT    @siguiente=MIN(CONVERT(INT, FI_CONSECUTIVOPED)) 
			FROM         dbo.FACTIMP
			WHERE     (FI_FACTAGRU = @fia_codigo) AND (CONVERT(INT, FI_CONSECUTIVOPED) > @FI_CONSECUTIVOPED)
	
			
			if @valor <> @siguiente
			begin
				if exists(select * from ##remesafactagru where remesafin=0)
				update ##remesafactagru
				set remesafin=@valor-1
				where remesafin=0
	
				set @valor=@siguiente
	
				insert into ##remesafactagru (fia_codigo, remesaini, remesafin)
				values(@fia_codigo, @valor, 0)
	
			end
	
	
		FETCH NEXT FROM cur_remesas INTO @FI_CONSECUTIVOPED
	
	END
	
	CLOSE cur_remesas
	DEALLOCATE cur_remesas
	
	
	update ##remesafactagru
	set remesafin=(SELECT max(CONVERT(INT, FI_CONSECUTIVOPED))
		       FROM FACTIMP
		       WHERE FI_FACTAGRU = @fia_codigo)
	where remesafin=0


	-- actualizacion de comentarios
		declare cur_remesasfin cursor for
			SELECT     remesaini, remesafin
			FROM         ##remesafactagru
			WHERE     (FIA_CODIGO = @fia_codigo)
			AND remesaini <> remesafin
		open cur_remesasfin
			FETCH NEXT FROM cur_remesasfin INTO @remesaini, @remesafin
		
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN
	
			SELECT @remesaini1 = min(remesaini) FROM ##remesafactagru WHERE FIA_CODIGO = @fia_codigo AND remesaini <> remesafin
	
			if @remesaini1=@remesaini
				UPDATE FACTIMPAGRU
				SET FIA_COMENTA=isnull(FIA_COMENTA,'')+'Remesas:'+CONVERT(varchar(20), @remesaini) + '-' + CONVERT(varchar(20), @remesafin) 
				WHERE     (FIA_CODIGO = @fia_codigo)			
			else		
				
				UPDATE FACTIMPAGRU
				SET FIA_COMENTA=FIA_COMENTA+','+CONVERT(varchar(20), @remesaini) + '-' + CONVERT(varchar(20), @remesafin) 
				WHERE     (FIA_CODIGO = @fia_codigo)			
			FETCH NEXT FROM cur_remesasfin INTO @remesaini, @remesafin
		
		END
		
		CLOSE cur_remesasfin
		DEALLOCATE cur_remesasfin
	
		declare cur_remesasworango cursor for
			SELECT     remesaini
			FROM         ##remesafactagru
			WHERE     (FIA_CODIGO = @fia_codigo)
			AND remesaini = remesafin
	
		open cur_remesasworango
			FETCH NEXT FROM cur_remesasworango INTO @remesaini
		
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN
	
			if not exists(select fia_comenta from factimpagru where fia_codigo=@fia_codigo and (fia_comenta like 'remesas%' or fia_comenta like '%remesas%' ))
				UPDATE FACTIMPAGRU
				SET FIA_COMENTA=isnull(FIA_COMENTA,'')+'Remesas:'+CONVERT(varchar(20), @remesaini)  
				WHERE     (FIA_CODIGO = @fia_codigo)			
			else			
				UPDATE FACTIMPAGRU
				SET FIA_COMENTA=FIA_COMENTA+','+CONVERT(varchar(20), @remesaini) 
				WHERE     (FIA_CODIGO = @fia_codigo)			
			FETCH NEXT FROM cur_remesasworango INTO @remesaini
		
		END
		
		CLOSE cur_remesasworango
		DEALLOCATE cur_remesasworango
	
	


end	


	IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
	   WHERE name = '##remesafactagru'  AND  type = 'U')
	begin
		drop table ##remesafactagru
	end


GO
