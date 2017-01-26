SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_CALCULAREMESAS]  (@pi_codigo int)   as

SET NOCOUNT ON 

declare @FE_CONSECUTIVOPED int, @FI_CONSECUTIVOPED int, @valor int, @siguiente int, @pi_movimiento varchar(1)

EXEC SP_DROPTABLE 'remesa'
CREATE TABLE [dbo].[remesa] (
	[pi_codigo] [int] NULL ,
	[remesaini] [int] NULL ,
	[remesafin] [int] NULL ) 

	select @pi_movimiento=pi_movimiento from pedimp where pi_codigo=@pi_codigo

	if @pi_movimiento='E' 
	begin
		SELECT  @valor=min(CONVERT(INT, FI_CONSECUTIVOPED))
		FROM         FACTIMP
		WHERE     (PI_CODIGO = @pi_codigo) and FI_CONSECUTIVOPED is not null and FI_CONSECUTIVOPED<>''
	
	
		  insert into remesa (pi_codigo, remesaini, remesafin)
		  values(@pi_codigo, @valor, 0)
	
	
		declare cur_remesas cursor for
			SELECT     CONVERT(INT, FI_CONSECUTIVOPED) 
			FROM         FACTIMP
			WHERE     (PI_CODIGO = @pi_codigo)
			and FI_CONSECUTIVOPED is not null and FI_CONSECUTIVOPED<>''
			ORDER BY CONVERT(INT, FI_CONSECUTIVOPED)
		open cur_remesas
		FETCH NEXT FROM cur_remesas INTO @FI_CONSECUTIVOPED
	
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN
			set @valor=@valor+1
	
			SELECT    @siguiente=MIN(CONVERT(INT, FI_CONSECUTIVOPED)) 
			FROM         dbo.FACTIMP
			WHERE     (PI_CODIGO = @pi_codigo) AND (CONVERT(INT, FI_CONSECUTIVOPED) > @FI_CONSECUTIVOPED)
			and FI_CONSECUTIVOPED is not null and FI_CONSECUTIVOPED<>''
	
			
			if @valor <> @siguiente
			begin
				if exists(select * from remesa where remesafin=0)
				update remesa
				set remesafin=@valor-1
				where remesafin=0
	
				set @valor=@siguiente
	
				insert into remesa (pi_codigo, remesaini, remesafin)
				values(@pi_codigo, @valor, 0)
	
			end
	
	
			FETCH NEXT FROM cur_remesas INTO @FI_CONSECUTIVOPED
	
		END
	
		CLOSE cur_remesas
		DEALLOCATE cur_remesas
	
	
		update remesa
		set remesafin=(SELECT max(CONVERT(INT, FI_CONSECUTIVOPED))
			       FROM FACTIMP
			       WHERE PI_CODIGO = @pi_codigo and FI_CONSECUTIVOPED is not null and FI_CONSECUTIVOPED<>'')
		where remesafin=0

	end
	else
	begin
		SELECT  @valor=min(CONVERT(INT, FE_CONSECUTIVOPED))
		FROM         FACTEXP
		WHERE     (PI_CODIGO = @pi_codigo) AND FE_CONSECUTIVOPED IS NOT NULL and FE_CONSECUTIVOPED <>''
	
	
		  insert into remesa (pi_codigo, remesaini, remesafin)
		  values(@pi_codigo, @valor, 0)
	
	
		declare cur_remesas cursor for
			SELECT     CONVERT(INT, FE_CONSECUTIVOPED) 
			FROM         FACTEXP
			WHERE     (PI_CODIGO = @pi_codigo)
			AND FE_CONSECUTIVOPED IS NOT NULL and FE_CONSECUTIVOPED <>''
			ORDER BY CONVERT(INT, FE_CONSECUTIVOPED)
		open cur_remesas
		FETCH NEXT FROM cur_remesas INTO @FE_CONSECUTIVOPED
	
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN
			set @valor=@valor+1
	
			SELECT    @siguiente=MIN(CONVERT(INT, FE_CONSECUTIVOPED)) 
			FROM         dbo.FACTEXP
			WHERE     (PI_CODIGO = @pi_codigo) AND (CONVERT(INT, FE_CONSECUTIVOPED) > @FE_CONSECUTIVOPED)
			AND FE_CONSECUTIVOPED IS NOT NULL and FE_CONSECUTIVOPED <>''
			
			if @valor <> @siguiente
			begin
				if exists(select * from remesa where remesafin=0)
				update remesa
				set remesafin=@valor-1
				where remesafin=0
	
				set @valor=@siguiente
	
				insert into remesa (pi_codigo, remesaini, remesafin)
				values(@pi_codigo, @valor, 0)
	
			end
	
	
			FETCH NEXT FROM cur_remesas INTO @FE_CONSECUTIVOPED
	
		END
	
		CLOSE cur_remesas
		DEALLOCATE cur_remesas
	
	
		update remesa
		set remesafin=(SELECT max(CONVERT(INT, FE_CONSECUTIVOPED))
			       FROM FACTEXP
			       WHERE PI_CODIGO = @pi_codigo AND FE_CONSECUTIVOPED IS NOT NULL and FE_CONSECUTIVOPED <>'')
		where remesafin=0

	end


GO
