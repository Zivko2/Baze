SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE dbo.SP_ACTUALIZAR_REGLAORIGIEN (@ar_fraccion int )   as


--Yolanda Avila
--2010-09-21
--si ya existe la relacion, entonces solo debe actualizar la fecha
--si no existe entonces debe agregarlo con el segundo query
--Nunca debe borrar la relacion
	/*
	delete from ARANCELREGLAORIGEN where ARR_CODIGO in
	(select ARR_CODIGO from REGLAORIGEN where spi_codigo in (select spi_codigo from spi where spi_clave='nafta'))
	and ar_codigo in (select ar_codigo from tempRangosReglaOrigen)
	and ar_codigo <> @ar_fraccion
	*/
if exists (	select * 
		from ARANCELREGLAORIGEN 
		where convert(varchar(10),ar_codigo) +'#'+convert(varchar(10),arr_codigo) in (select convert(varchar(10),tempRangosReglaOrigen.ar_codigo)+'#'+convert(varchar(10),tempRangosReglaOrigen.arr_codigo) from tempRangosReglaOrigen)
	   )
begin
	update ARANCELREGLAORIGEN
	set ARANCELREGLAORIGEN.arr_perini = tempRangosReglaOrigen.arr_perini,
	    ARANCELREGLAORIGEN.arr_perfin = tempRangosReglaOrigen.arr_perfin
	from ARANCELREGLAORIGEN
	inner join tempRangosReglaOrigen on tempRangosReglaOrigen.ar_codigo = ARANCELREGLAORIGEN.ar_codigo and tempRangosReglaOrigen.arr_codigo = ARANCELREGLAORIGEN.arr_codigo
	where ARANCELREGLAORIGEN.ar_codigo <> @ar_fraccion
end	


if  exists (	select *
		from tempRangosReglaOrigen 
		where convert(varchar(10),tempRangosReglaOrigen.ar_codigo)+'#'+convert(varchar(10),tempRangosReglaOrigen.arr_codigo) not in
							    ( select convert(varchar(10),ar_codigo) +'#'+convert(varchar(10),ARANCELREGLAORIGEN.arr_codigo)
							      from ARANCELREGLAORIGEN 
							      inner join REGLAORIGEN on ARANCELREGLAORIGEN.ARR_CODIGO = REGLAORIGEN.ARR_CODIGO
							      where REGLAORIGEN.spi_codigo in (select spi_codigo from spi where spi_clave='nafta')
							     )
	   )	
begin
	--Yolanda Avila
	--2010-09-21
	/*
	insert into ARANCELREGLAORIGEN
	select  tempRangosReglaOrigen.ar_codigo, tempRangosReglaOrigen.arr_codigo
	from tempRangosReglaOrigen 
	where tempRangosReglaOrigen.ar_codigo not in( select ar_codigo
						      from ARANCELREGLAORIGEN 
						      inner join REGLAORIGEN on ARANCELREGLAORIGEN.ARR_CODIGO = REGLAORIGEN.ARR_CODIGO
						      where REGLAORIGEN.spi_codigo in (select spi_codigo from spi where spi_clave='nafta')
						     )
	*/
	insert into ARANCELREGLAORIGEN
	select  tempRangosReglaOrigen.ar_codigo, tempRangosReglaOrigen.arr_codigo, tempRangosReglaOrigen.arr_perini, tempRangosReglaOrigen.arr_perfin
	from tempRangosReglaOrigen 
	where convert(varchar(10),tempRangosReglaOrigen.ar_codigo)+'#'+convert(varchar(10),tempRangosReglaOrigen.arr_codigo) not in
						    ( select convert(varchar(10),ar_codigo) +'#'+convert(varchar(10),ARANCELREGLAORIGEN.arr_codigo)
						      from ARANCELREGLAORIGEN 
						      inner join REGLAORIGEN on ARANCELREGLAORIGEN.ARR_CODIGO = REGLAORIGEN.ARR_CODIGO
						      where REGLAORIGEN.spi_codigo in (select spi_codigo from spi where spi_clave='nafta')
						     )
end

/*
update ARANCELREGLAORIGEN set arr_codigo = tempRangosReglaOrigen.arr_codigo
from ARANCELREGLAORIGEN left join tempRangosReglaOrigen on ARANCELREGLAORIGEN.ar_codigo = tempRangosReglaOrigen.ar_codigo
*/

--Yolanda Avila
--2010-08-24
--Borra la tabla para que al entrar de nuevo al procedimiento sp_Rangos_reglaOrigen_fraccion se cree la tabla nuevamente
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tempRangosReglaOrigen]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tempRangosReglaOrigen]


GO
