SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

/* este procedimiento genera una tabla temporal con identity, pero sola las incluidas en importtables o importtablesdetcont*/
CREATE PROCEDURE [dbo].[SP_GeneraTablaTemp] (@tabla varchar(200))   as

declare @totalcampos int, @enunciado varchar(1100), @enunciadofin varchar(8000), @contador int,  @tablaTemp varchar(200), @CampoIdentity varchar(150)


--@tabla tabla en la que se va a basar para generarse, 
--@tablaTemp nombre de nueva tabla
set @tablaTemp='TempImport'+@tabla

exec('exec sp_droptable '''+@tablaTemp+'''')



		SELECT @totalcampos =count(*)
		FROM         vbasedatos
		WHERE     (tabla = @tabla)


	set @contador=0
	set @enunciadofin=''
	declare A cursor for
		SELECT '['+columna+'] ['+ tipocampo+']'+
		(case when columna in (SELECT IMR_FIELDCONSEC FROM IMPORTTABLESDETCONT WHERE IMR_TABLA collate database_default = @tabla)
		or columna in (SELECT IMT_PRIMARYKEY FROM IMPORTTABLES WHERE IMT_IDENTITY = 'N' AND IMT_TABLA collate database_default = @tabla)
		then ' IDENTITY (1, 1)' else '' end)+
		(case when tamano is null or tipocampo='text' or tipocampo collate database_default ='decimal' then 
			(case when tipocampo collate database_default ='decimal' then (case when (columna like 'eq_%' or columna like '%factcon%') then '(28,14)' else '(38,6)' end) else '' end) 
		     else 
                        '('+convert(varchar(50),tamano) collate database_default +')' end)+
		(case when tipocampo='varchar' or tipocampo collate database_default ='char' or tipocampo collate database_default ='text' then
		' COLLATE SQL_Latin1_General_CP1_CI_AS' else '' end)+
		(case when permitenulos = 0 then ' NOT NULL' else ' NULL' end)+
		(case when defaultcampo is null then '' else 
		' CONSTRAINT [DF_'+@tablaTemp+columna collate database_default +'] DEFAULT '+defaultcampo collate database_default end)
		FROM         vbasedatos
		WHERE     (tabla = @tabla) and tipocampo <>'image'
	open A
	
	
		FETCH NEXT FROM A INTO @enunciado
	
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN


			set @contador=@contador+1

			if @contador=@totalcampos
			set @enunciadofin = @enunciadofin+@enunciado
			else
			set @enunciadofin = @enunciadofin+@enunciado+','+char(13)


		FETCH NEXT FROM A INTO @enunciado
	END
	CLOSE A
	DEALLOCATE A


		if exists(SELECT IMR_FIELDCONSEC FROM IMPORTTABLESDETCONT WHERE IMR_TABLA = @tabla)
		set @CampoIdentity =(SELECT IMR_FIELDCONSEC FROM IMPORTTABLESDETCONT WHERE IMR_TABLA = @tabla)
		else
		set @CampoIdentity =(SELECT IMT_PRIMARYKEY FROM IMPORTTABLES WHERE IMT_IDENTITY = 'N' AND IMT_TABLA = @tabla)





	exec ('CREATE TABLE [dbo].['+@tablaTemp+'] ('+@enunciadofin+') ON [PRIMARY]')


	exec ('declare @maximo int  

                        select @maximo=max('+@CampoIdentity+')+1 from '+@tabla+'  

		if @maximo is null set @maximo=1 
		else 
  	           set @maximo=@maximo+1 
		
		if '''+@tabla+'''=''MAESTRO'' and  (select isnull(max(ma_codigo),0)+1 from maestrorefer) >@maximo
		select @maximo=isnull(max(ma_codigo),0)+1 from maestrorefer

                        dbcc checkident('''+@tablaTemp+''', reseed, @maximo) WITH NO_INFOMSGS ')
GO
