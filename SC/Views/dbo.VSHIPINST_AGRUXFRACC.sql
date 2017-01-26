SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




create view VSHIPINST_AGRUXFRACC 
as 
select shipinst.si_codigo,left(arancel.ar_fraccion,8)as Fraccion,
	'Domestico'=case when factimpdet.pa_codigo=233 then 'D' else 'F' end, 
	'DescOficial'=case when left(arancel.ar_fraccion,8)='' then 'Sin Fraccion Arancelaria' else 
	case when (arancel.ar_uso is null) or (arancel.ar_uso='') then 'Sin Descripción' else arancel.ar_uso  end end,
	'Digito'=case when len(arancel.ar_fraccion)=8 then arancel.ar_digito else right(arancel.ar_fraccion,2) end,
	'Cantidad'=case when arancel.me_codigo is null then left(sum(factimpdet.fid_cant_st),charindex('.',sum(factimpdet.fid_cant_st))+2)else
	case when medida.me_corto='X' then 'X' else 
	case when left(medida.me_corto,2)='KG' then  cast(left(sum(factimpdet.fid_pes_bru),charindex('.',sum(factimpdet.fid_pes_bru))+2) as varchar(255))+ 'kgs.' else
	cast(left(sum(factimpdet.fid_cant_st),charindex('.',sum(factimpdet.fid_cant_st))+2) as varchar(255)) + ' ' + medida.me_corto  collate database_default end  end end,
	sum(factimpdet.fid_pes_bru) as PesoTotal,
	sum(factimpdet.fid_cos_uni * factimpdet.fid_cant_st)as CostoTotalDllsRend
from shipinst
	left outer join factimp on shipinst.si_codigo=factimp.si_codigo 
	left outer join factimpdet on factimp.fi_codigo=factimpdet.fi_codigo
	left outer join arancel on arancel.ar_codigo=factimpdet.ar_expfo
	left outer join medida on arancel.me_codigo=medida.me_codigo
where arancel.ar_fraccion is not null 
group by arancel.ar_fraccion,shipinst.si_codigo,factimpdet.pa_codigo,arancel.ar_uso,arancel.ar_digito,arancel.me_codigo,
	medida.me_corto
having sum(factimpdet.fid_cos_uni * factimpdet.fid_cant_st)>2500
GO
