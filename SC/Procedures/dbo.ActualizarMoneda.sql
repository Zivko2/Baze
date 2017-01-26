SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE ActualizarMoneda as

if exists (SELECT name FROM dbo.sysobjects WHERE dbo.sysobjects.name = N'MonedaTemporal')
drop table MonedaTemporal

select * into monedaTemporal from moneda

delete from moneda 
where mo_codigo in(
select  max(mo_codigo)
from moneda
where mo_claveped <> ''
group by pa_codigo, mo_claveped 
having count(*)> 1)



update moneda set mo_nombre = b.mo_nombre
from moneda
  inner join original.dbo.moneda b on moneda.pa_codigo = b.pa_codigo and moneda.mo_claveped = b.mo_claveped
 where moneda.MO_CODIGO in
	(select max(moneda.mo_codigo)
	from moneda
		inner join original.dbo.moneda b on moneda.pa_codigo = b.pa_codigo and moneda.mo_claveped = b.mo_claveped
	group by moneda.pa_codigo) 
      and moneda.mo_claveped <> ''


insert into moneda(pa_codigo, mo_nombre, mo_name, mo_claveped, mo_simbolo)
select pa_codigo, mo_nombre, mo_name, mo_claveped, mo_simbolo
from original.dbo.moneda 
where convert(varchar(10),pa_codigo)+'-'+mo_claveped not in (select convert(varchar(10),pa_codigo)+'-'+mo_claveped from moneda)

GO
