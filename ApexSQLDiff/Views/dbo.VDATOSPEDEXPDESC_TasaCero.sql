SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW dbo.VDATOSPEDEXPDESC_TasaCero
with encryption as
	select kardesped.kap_indiced_ped, isnull(kardesped.kap_cantdesc,0) as kap_cantdesc, pedimp.pi_tip_cam, pedimpdet.pid_cos_uni as kap_cos_uni, 
		isnull(pedimpdet.pid_por_def, -1) as pid_por_def , pedimpdet.pid_def_tip as kap_def_tip, pedimpdet.pid_nombre,  
		pedimpdet.ar_impmx,pedimpdet.pa_origen, pedimpdetb.pib_indiceb,
		  case when isnull(agenciapatente.agt_patente,'') ='' then pedimp.pi_folio  else agenciapatente.agt_patente collate database_default +'-'+pedimp.pi_folio collate database_default end as Patente_folio, claveped.cp_clave as clavePedImp,
	         pedimp.pi_fec_ent as FechaPedImp, pedexpdet.pid_noparte as NoParteExportado
	from factexp
	inner join factexpdet on factexp.fe_codigo = factexpdet.fe_codigo
	inner join pedimpdet pedexpdet on factexpdet.pid_indicedliga = pedexpdet.pid_indiced 
	inner join pedimpdetB on pedexpdet.pib_indiceb = pedimpdetB.pib_indiceb
	inner join pedimp pedexp on pedexpdet.pi_codigo = pedexp.pi_codigo
	inner join kardesped on factexpdet.fed_indiced = kardesped.kap_indiced_fact 
	inner join pedimpdet on kardesped.kap_indiced_ped = pedimpdet.pid_indiced 
	inner join pedimp on pedimpdet.pi_codigo = pedimp.pi_codigo
	left outer join agenciapatente on pedimp.agt_codigo = agenciapatente.agt_codigo
	inner join claveped on pedimp.cp_codigo = claveped.cp_codigo
	where  pedexp.pi_movimiento = 'S'
	and     ( 
		    (pedimpdet.PID_POR_DEF = 0 and pedimpdet.pid_def_tip in ('R','S')) 
	           OR ( pedimpdet.pid_def_tip in ('G') and (isnull(pedimpdet.pid_pagacontrib,'') <>'S'))
	         )
	and (kap_cantdesc > 0)
	and pedimpdet.pa_origen not in (35,154,233)
	--and (pedimpdetB.pib_nombre like '%DT 9a%' or pedimpdetB.pib_nombre like '%DT 10%')
	--and (pedimpdetB.pib_nombre like '%DT 22%' or pedimpdetB.pib_nombre like '%DT 10%')
	and ((pedimpdetB.pib_nombre like case when isnull(factexp.fe_fecha,'1999-01-01') <='2010-04-25'  then '%DT 9a%' else '%DT 22%' end  or pedimpdetB.pib_nombre like '%DT 10%')
            or (pedimpdet.PID_POR_DEF = 0 and pedimpdet.pid_def_tip in ('R')) )



GO
