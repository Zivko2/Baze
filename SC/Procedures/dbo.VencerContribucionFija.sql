SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[VencerContribucionFija](@con_codigo int, @tipo int)   as

declare @maximos table(cof_codigo int not null,
                          cof_perini datetime not null,
                          cof_tipo varchar(5) not null,
                          primary key clustered (cof_codigo))

insert into @maximos
select max(cof_codigo) cof_codigo, max(cof_perini) cof_perini, cof_tipo
	from contribucionfija
	where cof_codigo in (select max(cof_codigo) from contribucionfija where con_codigo = @con_codigo group by cof_tipo)
	and con_codigo = @con_codigo
	group by cof_tipo
                          
declare @cof_codigo int, @cof_perini datetime, @cof_tipo varchar(5)
declare contribucion_fija cursor for
select * from @maximos
open contribucion_fija
FETCH NEXT FROM contribucion_fija INTO @cof_codigo, @cof_perini, @cof_tipo
WHILE (@@FETCH_STATUS = 0) 
	begin
	update contribucionFija set cof_perfin = @cof_perini - 1
	where cof_codigo in (select max(cof_codigo) from contribucionfija where cof_codigo < @cof_codigo and cof_tipo = @cof_tipo and con_codigo = @con_codigo)
	if @tipo = 2
		update contribucionFija set cof_perfin = '01/01/9999'
		where cof_codigo = @cof_codigo and cof_tipo = @cof_tipo and con_codigo = @con_codigo
		
	FETCH NEXT FROM contribucion_fija INTO @cof_codigo, @cof_perini, @cof_tipo
	end
close contribucion_fija
deallocate contribucion_fija
GO
