SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






-- Borra las fracciones arancelarias repetidas y las deja sin puntos
CREATE PROCEDURE [dbo].[OPTIMIZAARANCEL]   as

SET NOCOUNT ON 

declare @paisUSA int, @paisMX int
set @paisUSA = (select pa_codigo from pais where pa_corto = 'USA')
set @paisMX = (select pa_codigo from pais where pa_corto = 'MX')


--Ejemplo #A
--Borra las tablas que se usaran como temporales 
if exists(select * from sysobjects where name = 'ListaArancelesBorrados' and xtype = 'U')
begin
	--print 'algo'	
	drop table ListaArancelesBorrados;
end


if exists(SELECT name FROM  sysobjects WHERE name = 'arancel_Respaldo_ArTipo'  AND  type = 'U')
begin
	drop table arancel_Respaldo_ArTipo;
end


if exists(SELECT name FROM  sysobjects WHERE name = 'arancel_Cambios_ArTipo'  AND  type = 'U')
begin
	drop table arancel_Cambios_ArTipo;
end


--Crea un BK de la tabla de ARANCEL
select *
into arancel_Respaldo_ArTipo
from arancel


--Crea Tabla con la que se va a trabajar para modificar el campo ar_tipo	
select *
into arancel_Cambios_ArTipo
from arancel
where ar_tiporeg='F'



--Ejemplo #B
--Elimina los caracteres de  ('.', 'MX') del campo de ar_fraccion
update arancel_Cambios_ArTipo
set ar_fraccion = replace(replace(ar_fraccion,'.',''), 'MX','')
from arancel_Cambios_ArTipo
where ar_tiporeg='F'

--Ejemplo #C
--Borrar estos registros porque estan repetidos de acuerdo a la agrupación de ar_fraccion, ar_tipo, pa_codigo
select ar_codigo, ar_fraccion
into ListaArancelesBorrados
from arancel_Cambios_ArTipo
where ar_fraccion in ( select ar_fraccion from arancel_Cambios_ArTipo group by ar_fraccion, ar_tipo, pa_codigo having count (*) > 1)
and ar_codigo not in (select min(ar_codigo) from arancel_Cambios_ArTipo group by ar_fraccion, ar_tipo, pa_codigo having count (*) > 1)


delete from arancel_Cambios_ArTipo
where ar_fraccion in ( select ar_fraccion from arancel_Cambios_ArTipo group by ar_fraccion, ar_tipo, pa_codigo having count (*) > 1)
and ar_codigo not in (select min(ar_codigo) from arancel_Cambios_ArTipo group by ar_fraccion, ar_tipo, pa_codigo having count (*) > 1)






--Ejemplo #1
--Cuando se tienen una fraccion americana con un solo tipo y este es diferente de ('I','E') y su pais origen = USA (OK)
--Reemplaza el valor <> de I ó E  por el de I
if exists(select ar_fraccion from arancel_Cambios_ArTipo where ar_tiporeg = 'F' and ar_tipo not in ('I', 'E') and pa_codigo = @paisUSA
	 and ar_fraccion in (select ar_fraccion from arancel_Cambios_ArTipo where ar_tiporeg = 'F' and pa_codigo = @paisUSA group by ar_fraccion,pa_codigo having count(ar_tipo)=1) ) 
begin
	--print 'Cambia de A a I'
	--aqui debe reemplazar el ar_tipo<>'I'ó 'E' por el ar_tipo='I'
	------select ar_fraccion, ar_tipo, 'I' 
	update arancel_Cambios_ArTipo 
	set ar_tipo = 'I'
	from arancel_Cambios_ArTipo 
	where ar_tiporeg = 'F' and ar_tipo not in ('I', 'E') and pa_codigo = @paisUSA
	      and ar_fraccion in (select ar_fraccion from arancel_Cambios_ArTipo where ar_tiporeg = 'F' and pa_codigo = @paisUSA group by ar_fraccion,pa_codigo having count(ar_tipo)=1) 
end



--Ejemplo #2
--Cuando se tienen una fraccion mexicana con un solo tipo y este es <> ('A') y su pais origen = MEX (OK)
--Reemplaza el valor <>A por el de A
if exists(select ar_fraccion from arancel_Cambios_ArTipo where ar_tiporeg = 'F' and ar_tipo <> ('A') and pa_codigo = @paisMX
	 and ar_fraccion in (select ar_fraccion from arancel_Cambios_ArTipo where ar_tiporeg = 'F' and pa_codigo = @paisMX group by ar_fraccion,pa_codigo having count(ar_tipo)=1) ) 
begin
	--print 'Cambia de E ó I al valor de A'
	--aqui debe reemplazar el ar_tipo='E' ó 'I' por el ar_tipo='A'
	------select ar_fraccion, ar_tipo, 'A' 
	update arancel_Cambios_ArTipo
	set ar_tipo = 'A'
	from arancel_Cambios_ArTipo 
	where ar_tiporeg = 'F' and ar_tipo not in ('A') and pa_codigo = @paisMX
	      and ar_fraccion in (select ar_fraccion from arancel_Cambios_ArTipo where ar_tiporeg = 'F' and pa_codigo = @paisMX group by ar_fraccion,pa_codigo having count(ar_tipo)=1) 
end

--Ejemplo #3
--Cuando se tienen una misma fraccion americana con 2 tipos distintos (A, I) con pais origen = USA
--Lista los que tienen una misma fraccion americana con 2 tipos (I,A) con pais origen = USA, de esos saca los que son diferentes al valor de I 
--Cuando se tienen una misma fraccion americana con 2 tipos distintos (A, I) con pais origen = USA 
--Borra los registros que son distintos de I
	------select ar_fraccion +'_'+ case when ar_tipo = 'I' then ar_tipo else 'E' end +'_'+pais.pa_corto
	------	,ar_tipo, ar_codigo
	if exists(select * from sysobjects where name = 'ListaArancelesBorrados' and xtype = 'U')
	begin
		insert into ListaArancelesBorrados (ar_codigo, ar_fraccion)
		select ar_codigo, ar_fraccion
		from arancel_Cambios_ArTipo 
		left outer join pais on arancel_Cambios_ArTipo.pa_codigo = pais.pa_codigo
		where
		      ar_tiporeg = 'F'   and arancel_Cambios_ArTipo.pa_codigo = @paisUSA
		      and ar_fraccion in (select ar_fraccion from arancel_Cambios_ArTipo where ar_tiporeg = 'F' and pa_codigo = @paisUSA group by ar_fraccion,pa_codigo having count(ar_tipo)=2) 
		      and ar_fraccion in (select ar_fraccion from arancel_Cambios_ArTipo where ar_tipo ='I')
		      and ar_fraccion in (select ar_fraccion from arancel_Cambios_ArTipo where ar_tipo ='A')
		and ar_tipo <> (case when ar_tipo in ('I') then ar_tipo else 'E' end)
		and ar_fraccion +'_'+ (case when ar_tipo ='I' then ar_tipo else 'E' end) +'_'+pais.pa_corto not in 
		(select ar_fraccion +'_'+ ar_tipo+'_'+pais.pa_corto	from arancel_Cambios_ArTipo)
	end
	else
	begin
		select ar_codigo, ar_fraccion
		into ListaArancelesBorrados
		from arancel_Cambios_ArTipo 
		left outer join pais on arancel_Cambios_ArTipo.pa_codigo = pais.pa_codigo
		where
		      ar_tiporeg = 'F'   and arancel_Cambios_ArTipo.pa_codigo = @paisUSA
		      and ar_fraccion in (select ar_fraccion from arancel_Cambios_ArTipo where ar_tiporeg = 'F' and pa_codigo = @paisUSA group by ar_fraccion,pa_codigo having count(ar_tipo)=2) 
		      and ar_fraccion in (select ar_fraccion from arancel_Cambios_ArTipo where ar_tipo ='I')
		      and ar_fraccion in (select ar_fraccion from arancel_Cambios_ArTipo where ar_tipo ='A')
		and ar_tipo <> (case when ar_tipo in ('I') then ar_tipo else 'E' end)
		and ar_fraccion +'_'+ (case when ar_tipo ='I' then ar_tipo else 'E' end) +'_'+pais.pa_corto not in 
		(select ar_fraccion +'_'+ ar_tipo+'_'+pais.pa_corto	from arancel_Cambios_ArTipo)

	end


	delete arancel_Cambios_ArTipo 
	from arancel_Cambios_ArTipo 
	left outer join pais on arancel_Cambios_ArTipo.pa_codigo = pais.pa_codigo
	where
	      ar_tiporeg = 'F'   and arancel_Cambios_ArTipo.pa_codigo = @paisUSA
	      and ar_fraccion in (select ar_fraccion from arancel_Cambios_ArTipo where ar_tiporeg = 'F' and pa_codigo = @paisUSA group by ar_fraccion,pa_codigo having count(ar_tipo)=2) 
	      and ar_fraccion in (select ar_fraccion from arancel_Cambios_ArTipo where ar_tipo ='I')
	      and ar_fraccion in (select ar_fraccion from arancel_Cambios_ArTipo where ar_tipo ='A' )
	and ar_tipo <> case when ar_tipo in ('I') then ar_tipo else 'E' end
	and ar_fraccion +'_'+ case when ar_tipo ='I' then ar_tipo else 'E' end +'_'+pais.pa_corto not in 
	(select ar_fraccion +'_'+ ar_tipo+'_'+pais.pa_corto	from arancel_Cambios_ArTipo)



--Ejemplo #4
--Cuando se tienen una misma fraccion americana con 2 tipos distintos (E, A) con pais origen = USA
--Reemplaza el valor A por el de I
	------select ar_fraccion +'_'+ case when ar_tipo = 'E' then ar_tipo else 'I' end +'_'+pais.pa_corto
	------	,ar_tipo
	update arancel_Cambios_ArTipo 
	set ar_tipo = case when ar_tipo in ('E') then ar_tipo else 'I' end
	from arancel_Cambios_ArTipo 
	left outer join pais on arancel_Cambios_ArTipo.pa_codigo = pais.pa_codigo
	where
	      ar_tiporeg = 'F'   and arancel_Cambios_ArTipo.pa_codigo = @paisUSA
	      and ar_fraccion in (select ar_fraccion from arancel_Cambios_ArTipo where ar_tiporeg = 'F' and pa_codigo = @paisUSA group by ar_fraccion,pa_codigo having count(ar_tipo)=2) 
	      and ar_fraccion in (select ar_fraccion from arancel_Cambios_ArTipo where ar_tipo ='E')
	      and ar_fraccion in (select ar_fraccion from arancel_Cambios_ArTipo where ar_tipo ='A' )
	and ar_tipo <> case when ar_tipo in ('E') then ar_tipo else 'I' end
	and ar_fraccion +'_'+ case when ar_tipo ='E' then ar_tipo else 'I' end +'_'+pais.pa_corto not in 
	(select ar_fraccion +'_'+ ar_tipo+'_'+pais.pa_corto	from arancel_Cambios_ArTipo)



--Ejemplo #5
--Cuando se tienen una fraccion mexicana con varios tipo y todos estos son <> de ('A') y su pais origen = MEX (OK)
--Lista de los registros a los que se les debe cambiar su tipo de lo que sea al valor de ('A')
--toma el valor minimo y le asigna el valor de A
	update arancel_Cambios_ArTipo 
	set ar_tipo = 'A'
	from arancel_Cambios_ArTipo 
	where ar_codigo  in (	select min(ar_codigo)--, ar_fraccion
				from arancel_Cambios_ArTipo 
				left outer join pais on arancel_Cambios_ArTipo.pa_codigo = pais.pa_codigo
				where
				      ar_tiporeg = 'F'   and arancel_Cambios_ArTipo.pa_codigo = @paisMX
				      and ar_fraccion in (select ar_fraccion from arancel_Cambios_ArTipo where ar_tiporeg = 'F' and pa_codigo = @paisMX  group by ar_fraccion,pa_codigo having count(ar_tipo)>1) 
				and ar_fraccion not in (select ar_fraccion from arancel_Cambios_ArTipo where ar_tipo ='A' )
				group by ar_fraccion, arancel_Cambios_ArTipo.pa_codigo
			     )


--Ejemplo #6
--Cuando se tienen una fraccion mexicana con varios tipo y uno de ellos es ('A') y su pais origen = MEX (OK)
--Lista de los registros que se deben borrar ya que solo te tiene que dejar el que tiene 'A', el resto sale sobrando en la BD
	if exists(select * from sysobjects where name = 'ListaArancelesBorrados' and xtype = 'U')
	begin
		insert into ListaArancelesBorrados (ar_codigo, ar_fraccion)
		select ar_codigo, ar_fraccion
		from arancel_Cambios_ArTipo 
		left outer join pais on arancel_Cambios_ArTipo.pa_codigo = pais.pa_codigo
		where
		      ar_tiporeg = 'F'   and arancel_Cambios_ArTipo.pa_codigo = @paisMX
		      and ar_fraccion in (select ar_fraccion from arancel_Cambios_ArTipo where ar_tiporeg = 'F' and pa_codigo = @paisMX  group by ar_fraccion,pa_codigo having count(ar_tipo)>1) 
		--and ar_tipo = 'A'
		and ar_fraccion in (select ar_fraccion from arancel_Cambios_ArTipo where ar_tipo ='A' )
		and ar_codigo not in (	select min(ar_codigo)--, ar_fraccion
					from arancel_Cambios_ArTipo 
					left outer join pais on arancel_Cambios_ArTipo.pa_codigo = pais.pa_codigo
					where
					      ar_tiporeg = 'F'   and arancel_Cambios_ArTipo.pa_codigo = @paisMX
					      and ar_fraccion in (select ar_fraccion from arancel_Cambios_ArTipo where ar_tiporeg = 'F' and pa_codigo = @paisMX  group by ar_fraccion,pa_codigo having count(ar_tipo)>1) 
					and ar_tipo = 'A'
					--and ar_fraccion in (select ar_fraccion from arancel_Cambios_ArTipo where ar_tipo ='A' )
					group by ar_fraccion, arancel_Cambios_ArTipo.pa_codigo
				     )

	end
	else
	begin
		select ar_codigo, ar_fraccion
		into ListaArancelesBorrados
		from arancel_Cambios_ArTipo 
		left outer join pais on arancel_Cambios_ArTipo.pa_codigo = pais.pa_codigo
		where
		      ar_tiporeg = 'F'   and arancel_Cambios_ArTipo.pa_codigo = @paisMX
		      and ar_fraccion in (select ar_fraccion from arancel_Cambios_ArTipo where ar_tiporeg = 'F' and pa_codigo = @paisMX  group by ar_fraccion,pa_codigo having count(ar_tipo)>1) 
		      --and ar_tipo = 'A'
		      and ar_fraccion in (select ar_fraccion from arancel_Cambios_ArTipo where ar_tipo ='A' )
		      and ar_codigo not in (	select min(ar_codigo)--, ar_fraccion
						from arancel_Cambios_ArTipo 
						left outer join pais on arancel_Cambios_ArTipo.pa_codigo = pais.pa_codigo
						where
						      ar_tiporeg = 'F'   and arancel_Cambios_ArTipo.pa_codigo = @paisMX
						      and ar_fraccion in (select ar_fraccion from arancel_Cambios_ArTipo where ar_tiporeg = 'F' and pa_codigo = @paisMX  group by ar_fraccion,pa_codigo having count(ar_tipo)>1) 
						and ar_tipo = 'A'
						--and ar_fraccion in (select ar_fraccion from arancel_Cambios_ArTipo where ar_tipo ='A' )
						group by ar_fraccion, arancel_Cambios_ArTipo.pa_codigo
					     )
		
	end


	delete arancel_Cambios_ArTipo 
	from arancel_Cambios_ArTipo 
	left outer join pais on arancel_Cambios_ArTipo.pa_codigo = pais.pa_codigo
	where
	      ar_tiporeg = 'F'   and arancel_Cambios_ArTipo.pa_codigo = @paisMX
	      and ar_fraccion in (select ar_fraccion from arancel_Cambios_ArTipo where ar_tiporeg = 'F' and pa_codigo = @paisMX  group by ar_fraccion,pa_codigo having count(ar_tipo)>1) 
	--and ar_tipo = 'A'
	and ar_fraccion in (select ar_fraccion from arancel_Cambios_ArTipo where ar_tipo ='A' )
	and ar_codigo not in (	select min(ar_codigo)--, ar_fraccion
				from arancel_Cambios_ArTipo 
				left outer join pais on arancel_Cambios_ArTipo.pa_codigo = pais.pa_codigo
				where
				      ar_tiporeg = 'F'   and arancel_Cambios_ArTipo.pa_codigo = @paisMX
				      and ar_fraccion in (select ar_fraccion from arancel_Cambios_ArTipo where ar_tiporeg = 'F' and pa_codigo = @paisMX  group by ar_fraccion,pa_codigo having count(ar_tipo)>1) 
				and ar_tipo = 'A'
				--and ar_fraccion in (select ar_fraccion from arancel_Cambios_ArTipo where ar_tipo ='A' )
				group by ar_fraccion, arancel_Cambios_ArTipo.pa_codigo
			     )



--Ejemplo#7
--Borra la información de la tabla de ARANCEL y le inserta por la información que esta en la tabla de "arancel_Cambios_ArTipo" que ya esta corregida
	alter table [arancel] disable trigger [Del_Arancel]
		delete from arancel where ar_tiporeg='F'
	alter table [arancel] enable trigger [Del_Arancel]


	alter table [arancel] disable trigger [Insert_Arancel]
		insert into arancel (AR_CODIGO,AR_FRACCION,AR_DIGITO,AR_OFICIAL,AR_USO,CS_CODIGO,AR_TIPO,AR_TIPOREG,AR_LN_DESC,RA_CODIGO,PA_CODIGO,ME_CODIGO,ME_CODIGO2,VI_CODIGO,TV_CODIGO,AR_ESTADO,AR_FEC_REV,AR_PERINI,AR_PERFIN,AR_OBSERVA,PG_ADV,PG_BEN,PG_CUOTA,PG_IVA,PG_IEPS,PG_ISAN,AR_TIPOIMPUESTO,AR_CANTUMESP,AR_ESPEC,AR_PORCENT_8VA,AR_ADVDEF,AR_CUOTA,AR_IVA,AR_IVAFRANJA,AR_IEPS,AR_ISAN,ARR_CODIGO,AR_CAPITULO,AR_DESCCAPITULO,AR_PARTIDA,AR_DESCPARTIDA,AR_FECHAREVISION,AR_OBSOLETA,AR_PAGAISAN,AR_ULTMODIFTIGIE,AR_ADVFRONTERA)
		select 	AR_CODIGO,AR_FRACCION,AR_DIGITO,AR_OFICIAL,AR_USO,CS_CODIGO,AR_TIPO,AR_TIPOREG,AR_LN_DESC,RA_CODIGO,PA_CODIGO,ME_CODIGO,ME_CODIGO2,VI_CODIGO,TV_CODIGO,AR_ESTADO,AR_FEC_REV,AR_PERINI,AR_PERFIN,AR_OBSERVA,PG_ADV,PG_BEN,PG_CUOTA,PG_IVA,PG_IEPS,PG_ISAN,AR_TIPOIMPUESTO,AR_CANTUMESP,AR_ESPEC,AR_PORCENT_8VA,AR_ADVDEF,AR_CUOTA,AR_IVA,AR_IVAFRANJA,AR_IEPS,AR_ISAN,ARR_CODIGO,AR_CAPITULO,AR_DESCCAPITULO,AR_PARTIDA,AR_DESCPARTIDA,AR_FECHAREVISION,AR_OBSOLETA,AR_PAGAISAN,AR_ULTMODIFTIGIE,AR_ADVFRONTERA
		from arancel_Cambios_ArTipo
	alter table [arancel] enable trigger [Insert_Arancel]



--Ejemplo #8
if exists(select * from sysobjects where name = 'ListaArancelesBorrados' and xtype = 'U')
begin

	if exists(select * from sysobjects where name = 'ARANCELENTRY' and xtype ='U')
	begin	
	UPDATE ARANCELENTRY
	SET ARANCELENTRY.AR_CODIGO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN ARANCELENTRY ON ListaArancelesBorrados.ar_Codigo = ARANCELENTRY.AR_CODIGO
	end
	
	if exists(select * from sysobjects where name = 'BOM_ARANCEL' and xtype ='U')
	begin	
	UPDATE BOM_ARANCEL
	SET BOM_ARANCEL.AR_CODIGO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN BOM_ARANCEL ON ListaArancelesBorrados.ar_Codigo = BOM_ARANCEL.AR_CODIGO
	end
	
	if exists(select * from sysobjects where name = 'COMMINVDET' and xtype ='U')
	begin	
	UPDATE COMMINVDET
	SET COMMINVDET.AR_IMPFO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN COMMINVDET ON ListaArancelesBorrados.ar_Codigo = COMMINVDET.AR_IMPFO
	end
	
	if exists(select * from sysobjects where name = 'COSTSUBAJ' and xtype ='U')
	begin
	UPDATE COSTSUBAJ
	SET COSTSUBAJ.AR_CODIGO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN COSTSUBAJ ON ListaArancelesBorrados.ar_Codigo = COSTSUBAJ.AR_CODIGO
	end
	
	if exists(select * from sysobjects where name = 'COSTSUBAJ' and xtype ='U')
	begin
	UPDATE COSTSUBAJ
	SET COSTSUBAJ.AR_CODIGOREC= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN COSTSUBAJ ON ListaArancelesBorrados.ar_Codigo = COSTSUBAJ.AR_CODIGOREC
	end
	
	if exists(select * from sysobjects where name = 'COSTSUBAJ' and xtype ='U')
	begin
	UPDATE COSTSUBAJ
	SET COSTSUBAJ.AR_NG_EMP= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN COSTSUBAJ ON ListaArancelesBorrados.ar_Codigo = COSTSUBAJ.AR_NG_EMP
	end
	
	if exists(select * from sysobjects where name = 'COSTSUBAJ' and xtype ='U')
	begin
	UPDATE COSTSUBAJ
	SET COSTSUBAJ.AR_ORIG= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN COSTSUBAJ ON ListaArancelesBorrados.ar_Codigo = COSTSUBAJ.AR_ORIG
	end
	
	if exists(select * from sysobjects where name = 'COSTSUBBASC247DET' and xtype ='U')
	begin
	UPDATE COSTSUBBASC247DET
	SET COSTSUBBASC247DET.AR_CODIGO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN COSTSUBBASC247DET ON ListaArancelesBorrados.ar_Codigo = COSTSUBBASC247DET.AR_CODIGO
	end
	
	if exists(select * from sysobjects where name = 'COSTSUBBASC247ENTRY' and xtype ='U')
	begin	
	UPDATE COSTSUBBASC247ENTRY
	SET COSTSUBBASC247ENTRY.AR_CODIGO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN COSTSUBBASC247ENTRY ON ListaArancelesBorrados.ar_Codigo = COSTSUBBASC247ENTRY.AR_CODIGO
	end
	
	if exists(select * from sysobjects where name = 'DECANUALNVADET' and xtype ='U')
	begin
	UPDATE DECANUALNVADET
	SET DECANUALNVADET.AR_CODIGO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN DECANUALNVADET ON ListaArancelesBorrados.ar_Codigo = DECANUALNVADET.AR_CODIGO
	end
	
	if exists(select * from sysobjects where name = 'ENTRYSUMARA' and xtype ='U')
	begin
	UPDATE ENTRYSUMARA
	SET ENTRYSUMARA.AR_CODIGO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN ENTRYSUMARA ON ListaArancelesBorrados.ar_Codigo = ENTRYSUMARA.AR_CODIGO
	end
	
	if exists(select * from sysobjects where name = 'ENTRYSUMARA' and xtype ='U')
	begin	
	UPDATE ENTRYSUMARA
	SET ENTRYSUMARA.AR_ORIG= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN ENTRYSUMARA ON ListaArancelesBorrados.ar_Codigo = ENTRYSUMARA.AR_ORIG
	end
	
	if exists(select * from sysobjects where name = 'ENTRYSUMARA' and xtype ='U')
	begin	
	UPDATE ENTRYSUMARA
	SET ENTRYSUMARA.AR_NG_EMP= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN ENTRYSUMARA ON ListaArancelesBorrados.ar_Codigo = ENTRYSUMARA.AR_NG_EMP
	end
	
	if exists(select * from sysobjects where name = 'FACTIMPDET' and xtype ='U')
	begin
	UPDATE FACTIMPDET
	SET FACTIMPDET.AR_IMPMX= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN FACTIMPDET ON ListaArancelesBorrados.ar_Codigo = FACTIMPDET.AR_IMPMX
	end
	
	if exists(select * from sysobjects where name = 'FACTIMPDET' and xtype ='U')
	begin
	UPDATE FACTIMPDET
	SET FACTIMPDET.AR_EXPFO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN FACTIMPDET ON ListaArancelesBorrados.ar_Codigo = FACTIMPDET.AR_EXPFO
	end
	
	if exists(select * from sysobjects where name = 'PCKLISTDET' and xtype ='U')
	begin	
	UPDATE PCKLISTDET
	SET PCKLISTDET.AR_EXPFO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN PCKLISTDET ON ListaArancelesBorrados.ar_Codigo = PCKLISTDET.AR_EXPFO
	end
	
	if exists(select * from sysobjects where name = 'PCKLISTDET' and xtype ='U')
	begin	
	UPDATE PCKLISTDET
	SET PCKLISTDET.AR_IMPMX= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN PCKLISTDET ON ListaArancelesBorrados.ar_Codigo = PCKLISTDET.AR_IMPMX
	end
	
	if exists(select * from sysobjects where name = 'PEDIMPDET' and xtype ='U')
	begin	
	UPDATE PEDIMPDET
	SET PEDIMPDET.AR_IMPMX= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN PEDIMPDET ON ListaArancelesBorrados.ar_Codigo = PEDIMPDET.AR_IMPMX
	end
	
	if exists(select * from sysobjects where name = 'PEDIMPDET' and xtype ='U')
	begin
	UPDATE PEDIMPDET
	SET PEDIMPDET.AR_EXPFO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN PEDIMPDET ON ListaArancelesBorrados.ar_Codigo = PEDIMPDET.AR_EXPFO
	end
	
	if exists(select * from sysobjects where name = 'PEDIMPDETB' and xtype ='U')
	begin	
	UPDATE PEDIMPDETB
	SET PEDIMPDETB.AR_IMPMX= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN PEDIMPDETB ON ListaArancelesBorrados.ar_Codigo = PEDIMPDETB.AR_IMPMX
	end
	
	if exists(select * from sysobjects where name = 'PEDIMPDETB' and xtype ='U')
	begin
	UPDATE PEDIMPDETB
	SET PEDIMPDETB.AR_EXPFO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN PEDIMPDETB ON ListaArancelesBorrados.ar_Codigo = PEDIMPDETB.AR_EXPFO
	end
	
	if exists(select * from sysobjects where name = 'FACTEXPDET' and xtype ='U')
	begin	
	UPDATE FACTEXPDET
	SET FACTEXPDET.AR_EXPMX= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN FACTEXPDET ON ListaArancelesBorrados.ar_Codigo = FACTEXPDET.AR_EXPMX
	end
	
	if exists(select * from sysobjects where name = 'FACTEXPDET' and xtype ='U')
	begin		
	UPDATE FACTEXPDET
	SET FACTEXPDET.AR_IMPFO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN FACTEXPDET ON ListaArancelesBorrados.ar_Codigo = FACTEXPDET.AR_IMPFO
	end
	
	if exists(select * from sysobjects where name = 'FACTEXPDET' and xtype ='U')
	begin
	UPDATE FACTEXPDET
	SET FACTEXPDET.AR_IMPMX= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN FACTEXPDET ON ListaArancelesBorrados.ar_Codigo = FACTEXPDET.AR_IMPMX
	end
	
	if exists(select * from sysobjects where name = 'FACTEXPDET' and xtype ='U')
	begin
	UPDATE FACTEXPDET
	SET FACTEXPDET.AR_NG_EMP= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN FACTEXPDET ON ListaArancelesBorrados.ar_Codigo = FACTEXPDET.AR_NG_EMP
	end
	
	if exists(select * from sysobjects where name = 'FACTEXPDET' and xtype ='U')
	begin	
	UPDATE FACTEXPDET
	SET FACTEXPDET.AR_ORIG= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN FACTEXPDET ON ListaArancelesBorrados.ar_Codigo = FACTEXPDET.AR_ORIG
	end
	
	if exists(select * from sysobjects where name = 'LISTAEXPDET' and xtype ='U')
	begin	
	UPDATE LISTAEXPDET
	SET LISTAEXPDET.AR_DESP= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN LISTAEXPDET ON ListaArancelesBorrados.ar_Codigo = LISTAEXPDET.AR_DESP
	end
	
	if exists(select * from sysobjects where name = 'LISTAEXPDET' and xtype ='U')
	begin
	UPDATE LISTAEXPDET
	SET LISTAEXPDET.AR_EXPMX= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN LISTAEXPDET ON ListaArancelesBorrados.ar_Codigo = LISTAEXPDET.AR_EXPMX
	end
	
	if exists(select * from sysobjects where name = 'LISTAEXPDET' and xtype ='U')
	begin	
	UPDATE LISTAEXPDET
	SET LISTAEXPDET.AR_IMPFO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN LISTAEXPDET ON ListaArancelesBorrados.ar_Codigo = LISTAEXPDET.AR_IMPFO
	end
	
	if exists(select * from sysobjects where name = 'LISTAEXPDET' and xtype ='U')
	begin
	UPDATE LISTAEXPDET
	SET LISTAEXPDET.AR_IMPMX= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN LISTAEXPDET ON ListaArancelesBorrados.ar_Codigo = LISTAEXPDET.AR_IMPMX
	end
	
	if exists(select * from sysobjects where name = 'LISTAEXPDET' and xtype ='U')
	begin
	UPDATE LISTAEXPDET
	SET LISTAEXPDET.AR_NG_EMP= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN LISTAEXPDET ON ListaArancelesBorrados.ar_Codigo = LISTAEXPDET.AR_NG_EMP
	end
	
	if exists(select * from sysobjects where name = 'LISTAEXPDET' and xtype ='U')
	begin
	UPDATE LISTAEXPDET
	SET LISTAEXPDET.AR_ORIG= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN LISTAEXPDET ON ListaArancelesBorrados.ar_Codigo = LISTAEXPDET.AR_ORIG
	end
	
	if exists(select * from sysobjects where name = 'LISTAEXPDET' and xtype ='U')
	begin
	UPDATE LISTAEXPDET
	SET LISTAEXPDET.AR_RETRA= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN LISTAEXPDET ON ListaArancelesBorrados.ar_Codigo = LISTAEXPDET.AR_RETRA
	end
	
	if exists(select * from sysobjects where name = 'MAESTRO' and xtype ='U')
	begin	
	UPDATE MAESTRO
	SET MAESTRO.AR_DESP= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN MAESTRO ON ListaArancelesBorrados.ar_Codigo = MAESTRO.AR_DESP
	end
	
	if exists(select * from sysobjects where name = 'MAESTRO' and xtype ='U')
	begin
	UPDATE MAESTRO
	SET MAESTRO.AR_DESPMX= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN MAESTRO ON ListaArancelesBorrados.ar_Codigo = MAESTRO.AR_DESPMX
	end
	
	if exists(select * from sysobjects where name = 'MAESTRO' and xtype ='U')
	begin
	UPDATE MAESTRO
	SET MAESTRO.AR_EXPFO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN MAESTRO ON ListaArancelesBorrados.ar_Codigo = MAESTRO.AR_EXPFO
	end
	
	if exists(select * from sysobjects where name = 'MAESTRO' and xtype ='U')
	begin
	UPDATE MAESTRO
	SET MAESTRO.AR_EXPMX= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN MAESTRO ON ListaArancelesBorrados.ar_Codigo = MAESTRO.AR_EXPMX
	end
	
	if exists(select * from sysobjects where name = 'MAESTRO' and xtype ='U')
	begin
	UPDATE MAESTRO
	SET MAESTRO.AR_IMPEMPFOUSA= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN MAESTRO ON ListaArancelesBorrados.ar_Codigo = MAESTRO.AR_IMPEMPFOUSA
	end
	
	if exists(select * from sysobjects where name = 'MAESTRO' and xtype ='U')
	begin
	UPDATE MAESTRO
	SET MAESTRO.AR_IMPFO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN MAESTRO ON ListaArancelesBorrados.ar_Codigo = MAESTRO.AR_IMPFO
	end
	
	if exists(select * from sysobjects where name = 'MAESTRO' and xtype ='U')
	begin	
	UPDATE MAESTRO
	SET MAESTRO.AR_IMPFOUSA= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN MAESTRO ON ListaArancelesBorrados.ar_Codigo = MAESTRO.AR_IMPFOUSA
	end
	
	if exists(select * from sysobjects where name = 'MAESTRO' and xtype ='U')
	begin	
	UPDATE MAESTRO
	SET MAESTRO.AR_IMPMX= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN MAESTRO ON ListaArancelesBorrados.ar_Codigo = MAESTRO.AR_IMPMX	
	end
	
	if exists(select * from sysobjects where name = 'MAESTRO' and xtype ='U')
	begin	
	UPDATE MAESTRO
	SET MAESTRO.AR_IMPMXR8= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN MAESTRO ON ListaArancelesBorrados.ar_Codigo = MAESTRO.AR_IMPMXR8
	end
	
	if exists(select * from sysobjects where name = 'MAESTRO' and xtype ='U')
	begin	
	UPDATE MAESTRO
	SET MAESTRO.AR_RETRA= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN MAESTRO ON ListaArancelesBorrados.ar_Codigo = MAESTRO.AR_RETRA
	end
	
	if exists(select * from sysobjects where name = 'PERMISODET' and xtype ='U')
	begin		
	UPDATE PERMISODET
	SET PERMISODET.AR_EXPMX= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN PERMISODET ON ListaArancelesBorrados.ar_Codigo = PERMISODET.AR_EXPMX	
	end
	
	if exists(select * from sysobjects where name = 'PERMISODET' and xtype ='U')
	begin	
	UPDATE PERMISODET
	SET PERMISODET.AR_IMPMX= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN PERMISODET ON ListaArancelesBorrados.ar_Codigo = PERMISODET.AR_IMPMX
	end
	
	if exists(select * from sysobjects where name = 'ANEXO24' and xtype ='U')
	begin
        --Segunda parte
	UPDATE ANEXO24
	SET ANEXO24.AR_EXPMXFIS= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN ANEXO24 ON ListaArancelesBorrados.ar_Codigo = ANEXO24.AR_EXPMXFIS
	end
	
	if exists(select * from sysobjects where name = 'ANEXO24' and xtype ='U')
	begin
	UPDATE ANEXO24
	SET ANEXO24.AR_IMPFOFIS= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN ANEXO24 ON ListaArancelesBorrados.ar_Codigo = ANEXO24.AR_IMPFOFIS
	end
	
	if exists(select * from sysobjects where name = 'AVISOARANCEL' and xtype ='U')
	begin
	UPDATE AVISOARANCEL
	SET AVISOARANCEL.AR_CODIGO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN AVISOARANCEL ON ListaArancelesBorrados.ar_Codigo = AVISOARANCEL.AR_CODIGO
	end
	
	if exists(select * from sysobjects where name = 'BOM_CALCULABASE' and xtype ='U')
	begin
	UPDATE BOM_CALCULABASE
	SET BOM_CALCULABASE.AR_CODIGO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN BOM_CALCULABASE ON ListaArancelesBorrados.ar_Codigo = BOM_CALCULABASE.AR_CODIGO
	end
	
	if exists(select * from sysobjects where name = 'CARGORELARANCEL' and xtype ='U')
	begin
	UPDATE CARGORELARANCEL
	SET CARGORELARANCEL.AR_CODIGO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN CARGORELARANCEL ON ListaArancelesBorrados.ar_Codigo = CARGORELARANCEL.AR_CODIGO
	end
	
	if exists(select * from sysobjects where name = 'CATEGPERMISO' and xtype ='U')
	begin
	UPDATE CATEGPERMISO
	SET CATEGPERMISO.AR_CODIGO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN CATEGPERMISO ON ListaArancelesBorrados.ar_Codigo = CATEGPERMISO.AR_CODIGO
	end
	
	if exists(select * from sysobjects where name = 'CERTORIGMPDET' and xtype ='U')
	begin
	UPDATE CERTORIGMPDET
	SET CERTORIGMPDET.AR_CODIGO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN CERTORIGMPDET ON ListaArancelesBorrados.ar_Codigo = CERTORIGMPDET.AR_CODIGO
	end
	
	if exists(select * from sysobjects where name = 'CERTORIGMPDET' and xtype ='U')
	begin
	UPDATE CERTORIGMPDET
	SET CERTORIGMPDET.AR_ALTER= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN CERTORIGMPDET ON ListaArancelesBorrados.ar_Codigo = CERTORIGMPDET.AR_ALTER
	end
	
	if exists(select * from sysobjects where name = 'CLASIFICATLC' and xtype ='U')
	begin
	UPDATE CLASIFICATLC
	SET CLASIFICATLC.AR_CODIGO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN CLASIFICATLC ON ListaArancelesBorrados.ar_Codigo = CLASIFICATLC.AR_CODIGO
	end
	
	if exists(select * from sysobjects where name = 'CONFIGURACION' and xtype ='U')
	begin
	UPDATE CONFIGURACION
	SET CONFIGURACION.AR_EMPAQUEUSA= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN CONFIGURACION ON ListaArancelesBorrados.ar_Codigo = CONFIGURACION.AR_EMPAQUEUSA
	end
	
	if exists(select * from sysobjects where name = 'CONFIGURACION' and xtype ='U')
	begin
	UPDATE CONFIGURACION
	SET CONFIGURACION.AR_INSERTO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN CONFIGURACION ON ListaArancelesBorrados.ar_Codigo = CONFIGURACION.AR_INSERTO
	end
	
	if exists(select * from sysobjects where name = 'CONFIGURACION' and xtype ='U')
	begin
	UPDATE CONFIGURACION
	SET CONFIGURACION.AR_RETORNOUSA= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN CONFIGURACION ON ListaArancelesBorrados.ar_Codigo = CONFIGURACION.AR_RETORNOUSA
	end
	
	if exists(select * from sysobjects where name = 'CONFIGURACION' and xtype ='U')
	begin
	UPDATE CONFIGURACION
	SET CONFIGURACION.AR_RETRABAJO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN CONFIGURACION ON ListaArancelesBorrados.ar_Codigo = CONFIGURACION.AR_RETRABAJO
	end
	
	if exists(select * from sysobjects where name = 'COSTSUBAJ' and xtype ='U')
	begin
	UPDATE COSTSUBAJ
	SET COSTSUBAJ.AR_CODIGO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN COSTSUBAJ ON ListaArancelesBorrados.ar_Codigo = COSTSUBAJ.AR_CODIGO
	end
	
	if exists(select * from sysobjects where name = 'COSTSUBAJ' and xtype ='U')
	begin
	UPDATE COSTSUBAJ
	SET COSTSUBAJ.AR_CODIGOREC= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN COSTSUBAJ ON ListaArancelesBorrados.ar_Codigo = COSTSUBAJ.AR_CODIGOREC
	end
	
	if exists(select * from sysobjects where name = 'COSTSUBAJ' and xtype ='U')
	begin
	UPDATE COSTSUBAJ
	SET COSTSUBAJ.AR_NG_EMP= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN COSTSUBAJ ON ListaArancelesBorrados.ar_Codigo = COSTSUBAJ.AR_NG_EMP
	end
	
	if exists(select * from sysobjects where name = 'COSTSUBAJ' and xtype ='U')
	begin
	UPDATE COSTSUBAJ
	SET COSTSUBAJ.AR_ORIG= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN COSTSUBAJ ON ListaArancelesBorrados.ar_Codigo = COSTSUBAJ.AR_ORIG
	end
	
	if exists(select * from sysobjects where name = 'COSTSUBBASC247ENTRY' and xtype ='U')
	begin
	UPDATE COSTSUBBASC247ENTRY
	SET COSTSUBBASC247ENTRY.AR_CODIGO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN COSTSUBBASC247ENTRY ON ListaArancelesBorrados.ar_Codigo = COSTSUBBASC247ENTRY.AR_CODIGO
	end
	
	if exists(select * from sysobjects where name = 'CUESTIONPPSPT' and xtype ='U')
	begin
	UPDATE CUESTIONPPSPT
	SET CUESTIONPPSPT.AR_EXPMX= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN CUESTIONPPSPT ON ListaArancelesBorrados.ar_Codigo = CUESTIONPPSPT.AR_EXPMX
	end
	
	if exists(select * from sysobjects where name = 'CUESTIONPPSPT' and xtype ='U')
	begin
	UPDATE CUESTIONPPSPT
	SET CUESTIONPPSPT.AR_IMPFO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN CUESTIONPPSPT ON ListaArancelesBorrados.ar_Codigo = CUESTIONPPSPT.AR_IMPFO
	end
	
	if exists(select * from sysobjects where name = 'DECANUALPPSDET' and xtype ='U')
	begin
	UPDATE DECANUALPPSDET
	SET DECANUALPPSDET.AR_CODIGO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN DECANUALPPSDET ON ListaArancelesBorrados.ar_Codigo = DECANUALPPSDET.AR_CODIGO
	end
	
	if exists(select * from sysobjects where name = 'FACTEXPBOM_ARANCEL' and xtype ='U')
	begin
	UPDATE FACTEXPBOM_ARANCEL
	SET FACTEXPBOM_ARANCEL.AR_CODIGO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN FACTEXPBOM_ARANCEL ON ListaArancelesBorrados.ar_Codigo = FACTEXPBOM_ARANCEL.AR_CODIGO
	end
--> Aqui me quede

	
	if exists(select * from sysobjects where name = 'FACTIMPAGRUDET' and xtype ='U')
	begin
	UPDATE FACTIMPAGRUDET
	SET FACTIMPAGRUDET.AR_EXPFO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN FACTIMPAGRUDET ON ListaArancelesBorrados.ar_Codigo = FACTIMPAGRUDET.AR_EXPFO
	end
	
	if exists(select * from sysobjects where name = 'FACTIMPAGRUDET' and xtype ='U')
	begin
	UPDATE FACTIMPAGRUDET
	SET FACTIMPAGRUDET.AR_IMPMX= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN FACTIMPAGRUDET ON ListaArancelesBorrados.ar_Codigo = FACTIMPAGRUDET.AR_IMPMX
	end
	
	if exists(select * from sysobjects where name = 'FORMATOFCC' and xtype ='U')
	begin
	UPDATE FORMATOFCC
	SET FORMATOFCC.AR_IMPFO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN FORMATOFCC ON ListaArancelesBorrados.ar_Codigo = FORMATOFCC.AR_IMPFO
	end
	
	if exists(select * from sysobjects where name = 'IMPLEMENTAPEDIMPDET' and xtype ='U')
	begin
	UPDATE IMPLEMENTAPEDIMPDET
	SET IMPLEMENTAPEDIMPDET.AR_EXPFO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN IMPLEMENTAPEDIMPDET ON ListaArancelesBorrados.ar_Codigo = IMPLEMENTAPEDIMPDET.AR_EXPFO
	end
	
	if exists(select * from sysobjects where name = 'IMPLEMENTAPEDIMPDET' and xtype ='U')
	begin
	UPDATE IMPLEMENTAPEDIMPDET
	SET IMPLEMENTAPEDIMPDET.AR_IMPMX= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN IMPLEMENTAPEDIMPDET ON ListaArancelesBorrados.ar_Codigo = IMPLEMENTAPEDIMPDET.AR_IMPMX
	end
	
	if exists(select * from sysobjects where name = 'KARARANCEL' and xtype ='U')
	begin
	UPDATE KARARANCEL
	SET KARARANCEL.AR_CODIGO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN KARARANCEL ON ListaArancelesBorrados.ar_Codigo = KARARANCEL.AR_CODIGO
	end
	
	if exists(select * from sysobjects where name = 'KARDATOSPEDEXPDESC' and xtype ='U')
	begin
	UPDATE KARDATOSPEDEXPDESC
	SET KARDATOSPEDEXPDESC.AR_IMPMX= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN KARDATOSPEDEXPDESC ON ListaArancelesBorrados.ar_Codigo = KARDATOSPEDEXPDESC.AR_IMPMX
	end
	
	if exists(select * from sysobjects where name = 'KARDATOSPEDEXPPAGOUSA' and xtype ='U')
	begin
	UPDATE KARDATOSPEDEXPPAGOUSA
	SET KARDATOSPEDEXPPAGOUSA.AR_EXPFO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN KARDATOSPEDEXPPAGOUSA ON ListaArancelesBorrados.ar_Codigo = KARDATOSPEDEXPPAGOUSA.AR_EXPFO
	end
	
	if exists(select * from sysobjects where name = 'NAFTA' and xtype ='U')
	begin
	UPDATE NAFTA
	SET NAFTA.AR_CODIGO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN NAFTA ON ListaArancelesBorrados.ar_Codigo = NAFTA.AR_CODIGO
	end
	
	if exists(select * from sysobjects where name = 'OMISIONMAESTRO' and xtype ='U')
	begin
	UPDATE OMISIONMAESTRO
	SET OMISIONMAESTRO.AR_IMPMX= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN OMISIONMAESTRO ON ListaArancelesBorrados.ar_Codigo = OMISIONMAESTRO.AR_IMPMX
	end
	

	if exists(select * from sysobjects where name = 'PEDIMPVIRTUAL' and xtype ='U')
	begin
	UPDATE PEDIMPVIRTUAL
	SET PEDIMPVIRTUAL.AR_CODIGO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN PEDIMPVIRTUAL ON ListaArancelesBorrados.ar_Codigo = PEDIMPVIRTUAL.AR_CODIGO
	end

	if exists(select * from sysobjects where name = 'PERMISO' and xtype ='U')
	begin
	UPDATE PERMISO
	SET PERMISO.AR_CODIGO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN PERMISO ON ListaArancelesBorrados.ar_Codigo = PERMISO.AR_CODIGO
	end
	
	if exists(select * from sysobjects where name = 'PERMISOPT' and xtype ='U')
	begin
	UPDATE PERMISOPT
	SET PERMISOPT.AR_CODIGO= ARANCEL.AR_CODIGO
	FROM ListaArancelesBorrados 
	INNER JOIN ARANCEL ON ListaArancelesBorrados.ar_Fraccion = ARANCEL.AR_FRACCION 
	INNER JOIN PERMISOPT ON ListaArancelesBorrados.ar_Codigo = PERMISOPT.AR_CODIGO
	end
	

	
end






--Ejemplo #9
--Borra la tabla que contiene los registros borrados
if exists(select * from ListaArancelesBorrados)
begin
	drop table ListaArancelesBorrados
end






GO
