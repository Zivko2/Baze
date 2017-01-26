SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE dbo.SP_CambiaVarchar8000 @tabla varchar(100),@campo varchar(100)   as


declare @pos int, @objectname varchar(100)

select @pos = colid from sysobjects
left outer join syscolumns on sysobjects.id = syscolumns.id
where sysobjects.name = @tabla and syscolumns.name = @campo

exec ('alter table '+@tabla+' add  temporary_field varchar (8000)')

exec ('update '+@tabla+' set temporary_field = '+@campo)

if exists (select id from sysobjects where name = 'DF_'+@tabla+'_'+@campo)
	exec ('alter table '+@tabla+' drop constraint DF_'+@tabla+'_'+@campo)

exec ('alter table '+@tabla+' drop column '+@campo)

SET @objectname = @tabla+'.temporary_field'

EXEC sp_rename @objectname, @campo, 'COLUMN'

/*update syscolumns set colid = @pos
from sysobjects
left outer join syscolumns on sysobjects.id = syscolumns.id
where sysobjects.name = @tabla and syscolumns.name = @campo*/
















GO
