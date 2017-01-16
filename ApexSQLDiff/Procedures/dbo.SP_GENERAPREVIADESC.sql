SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_GENERAPREVIADESC]   as

SET NOCOUNT ON 
declare @tipo varchar(30), @tipo1 varchar(1), @tipo2 varchar(1), @FE_CODIGO int, @FE_FOLIO varchar(25), @FE_FECHA datetime

	if not exists (select * from dbo.sysobjects where name='previadesc')
	begin
		create table [dbo].[previadesc]
		(FE_CODIGO int, FE_FOLIO varchar(25), FE_FECHA datetime, TIPO1 varchar(1), TIPO2 varchar(1), TIPO varchar(30))
	end
	else
	begin
		TRUNCATE TABLE previadesc
	end


	DECLARE CUR_PREVIADESC CURSOR FOR
		SELECT FE_CODIGO, FE_FOLIO, FE_FECHA
		FROM FACTEXP
		
		ORDER BY FE_FECHA DESC, FE_CODIGO DESC
	open CUR_PREVIADESC
	fetch next from CUR_PREVIADESC into @FE_CODIGO, @FE_FOLIO, @FE_FECHA
	WHILE (@@FETCH_STATUS = 0) 
	BEGIN
	
		insert into previadesc(FE_CODIGO, FE_FOLIO, FE_FECHA)
		values (@FE_CODIGO, @FE_FOLIO, @FE_FECHA)
	

		if exists (select * from factexpdet where fe_codigo=@FE_CODIGO)
		begin
			if @FE_CODIGO in 
			(SELECT dbo.FACTEXP.FE_CODIGO
			FROM         dbo.FACTEXP LEFT OUTER JOIN
			                      dbo.FACTEXPDET ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO
			WHERE dbo.FACTEXPDET.TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN('P', 'S'))
			GROUP BY dbo.FACTEXP.FE_CODIGO)
		
			update previadesc	
			set tipo1 ='P' 
			where fe_codigo =@fe_codigo
			else
			update previadesc
			set tipo1 ='' 
			where fe_codigo =@fe_codigo
		
			if @FE_CODIGO in 
			(SELECT dbo.FACTEXP.FE_CODIGO
			FROM         dbo.FACTEXP LEFT OUTER JOIN
			                      dbo.FACTEXPDET ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO
			WHERE dbo.FACTEXPDET.TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO NOT IN('P', 'S'))
			GROUP BY dbo.FACTEXP.FE_CODIGO)
		
			update previadesc		
			set tipo2 ='C' 
			where fe_codigo =@fe_codigo
			else
			update previadesc
			set tipo2 ='' 
			where fe_codigo =@fe_codigo
		
			select @tipo1=tipo1, @tipo2=tipo2 from previadesc
			where fe_codigo =@fe_codigo
		
			if @tipo1='P' and @tipo2='C'
			update previadesc
			set tipo='Ambos'
			where fe_codigo =@fe_codigo
			
			else if @tipo1='P' and @tipo2=''
			update previadesc
			set tipo='Pt. y Sub.'
			where fe_codigo =@fe_codigo
		
			else if @tipo1='' and @tipo2='C'
			update previadesc
			set tipo='Diferente Pt. y Sub.'
			where fe_codigo =@fe_codigo
		end
		else
		begin
			update previadesc
			set tipo='Sin Detalles'
			where fe_codigo =@fe_codigo

		end	
	
	fetch next from CUR_PREVIADESC into @FE_CODIGO, @FE_FOLIO, @FE_FECHA
	END
	CLOSE CUR_PREVIADESC
	DEALLOCATE CUR_PREVIADESC



























GO
