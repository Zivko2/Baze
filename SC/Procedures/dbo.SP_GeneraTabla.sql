SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_GeneraTabla] (@tabla varchar(200), @enunciadofinal varchar(8000) output)   as

declare @totalcampos int, @enunciado varchar(1100), @contador int,  @enunciadofin varchar(8000), @CampoIdentity varchar(150)


--@tabla tabla en la que se va a basar para generarse, 
--@Tabla nombre de nueva tabla


	SELECT @totalcampos =count(*)
	FROM         vbasedatos
	WHERE     (tabla = @tabla)


	set @contador=0
	set @enunciadofin=''
	set @enunciadofinal=''
	declare A cursor for
		SELECT '['+columna+'] ['+ tipocampo+']'+
		(case when vbasedatos.[identity]=1 
		then ' IDENTITY (1, 1)' else '' end)+
		(case when tamano is null or tipocampo='text' or tipocampo='decimal' then 
			(case when tipocampo='decimal' then (case when (columna like 'eq_%' or columna like '%factcon%') then '(28,14)' else '(38,6)' end) else '' end) 
		     else 
                        '('+convert(varchar(50),tamano)+')' end)+
		(case when tipocampo='varchar' or tipocampo='char' or tipocampo='text' then
		' COLLATE SQL_Latin1_General_CP1_CI_AS' else '' end)+
		(case when permitenulos=0 then ' NOT NULL' else ' NULL' end)+
		(case when defaultcampo is null then '' else 
		' CONSTRAINT [DF_'+@tabla+'_'+columna+'] DEFAULT '+defaultcampo end)
		FROM         vbasedatos
		WHERE     (tabla = @tabla)



	open A
	
	
		FETCH NEXT FROM A INTO @enunciado
	
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN


			set @contador=@contador+1

			if @contador=@totalcampos
			set @enunciadofin = @enunciadofin+@enunciado
			else
			set @enunciadofin = @enunciadofin+@enunciado+','



		FETCH NEXT FROM A INTO @enunciado
	END
	CLOSE A
	DEALLOCATE A


		if exists(SELECT IMR_FIELDCONSEC FROM IMPORTTABLESDETCONT WHERE IMR_TABLA = @tabla)
		set @CampoIdentity =(SELECT IMR_FIELDCONSEC FROM IMPORTTABLESDETCONT WHERE IMR_TABLA = @tabla)
		else
		set @CampoIdentity =(SELECT IMT_PRIMARYKEY FROM IMPORTTABLES WHERE IMT_IDENTITY = 'N' AND IMT_TABLA = @tabla)




--print @enunciadofin
	set @enunciadofinal ='CREATE TABLE [dbo].['+@Tabla+'] ('+@enunciadofin+') ON [PRIMARY]'
GO
