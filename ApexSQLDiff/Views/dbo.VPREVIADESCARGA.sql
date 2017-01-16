SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO









































CREATE VIEW dbo.VPREVIADESCARGA
with encryption as
SELECT     TOP 100 PERCENT dbo.VBOM_DESCTEMP.FE_CODIGO, dbo.FACTEXP.FE_FECHA, dbo.VBOM_DESCTEMP.BST_HIJO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOPARTEAUX,
	round(SUM(dbo.VBOM_DESCTEMP.CANTDESC),6) AS CantaDescargar,
                          'CantDisponible'=case when (SELECT     SUM(pid_saldogen)
	                            FROM          pidescarga INNER JOIN
             	                                      pedimp ON pidescarga.pi_codigo = pedimp.pi_codigo 
				inner join claveped on pedimp.cp_codigo=claveped.cp_codigo
              	               WHERE      pedimp.pi_fec_ent <= dbo.FACTEXP.FE_FECHA AND pi_estatus<>'R' and claveped.cp_descargable='S'
	 		 and pedimp.pi_movimiento='E'  
			and PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IT', 'IV', 'OC', 'TR', 'VT', 'RG', 'IR', 'IE', 'IB', 'RE'))
			and ma_codigo = dbo.VBOM_DESCTEMP.BST_HIJO) is null then
			0 else
				(SELECT     SUM(pid_saldogen)
	                            FROM          pidescarga INNER JOIN
	                                                   pedimp ON pidescarga.pi_codigo = pedimp.pi_codigo 
					inner join claveped on pedimp.cp_codigo=claveped.cp_codigo
	                            WHERE      pedimp.pi_fec_ent <= dbo.FACTEXP.FE_FECHA AND pi_estatus<>'R' and claveped.cp_descargable='S'
				 and pedimp.pi_movimiento='E' 
				and PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IT', 'IV', 'OC', 'TR', 'VT', 'RG', 'IR', 'IE', 'IB', 'RE'))
				and ma_codigo = dbo.VBOM_DESCTEMP.BST_HIJO) end,
                          'saldoPosterior'=case when (SELECT     SUM(pid_saldogen)
                            FROM          pidescarga INNER JOIN
                                                   pedimp ON pidescarga.pi_codigo = pedimp.pi_codigo 
				inner join claveped on pedimp.cp_codigo=claveped.cp_codigo
                            WHERE      pedimp.pi_fec_ent <= dbo.FACTEXP.FE_FECHA AND pi_estatus<>'R' and claveped.cp_descargable='S'
			 and pedimp.pi_movimiento='E' 
			and PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IT', 'IV', 'OC', 'TR', 'VT', 'RG', 'IR', 'IE', 'IB', 'RE'))
			and ma_codigo = dbo.VBOM_DESCTEMP.BST_HIJO) - SUM(dbo.VBOM_DESCTEMP.CANTDESC)<0 or
			(SELECT     SUM(pid_saldogen)
                            FROM          pidescarga INNER JOIN
                                                   pedimp ON pidescarga.pi_codigo = pedimp.pi_codigo 
				inner join claveped on pedimp.cp_codigo=claveped.cp_codigo
                            WHERE      pedimp.pi_fec_ent <= dbo.FACTEXP.FE_FECHA AND pi_estatus<>'R' and claveped.cp_descargable='S'
			 and pedimp.pi_movimiento='E' 
			and PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IT', 'IV', 'OC', 'TR', 'VT', 'RG', 'IR', 'IE', 'IB', 'RE'))
			and ma_codigo = dbo.VBOM_DESCTEMP.BST_HIJO) - SUM(dbo.VBOM_DESCTEMP.CANTDESC) is null then 0
			else
			round((SELECT     SUM(pid_saldogen)
                            FROM          pidescarga INNER JOIN
                                                   pedimp ON pidescarga.pi_codigo = pedimp.pi_codigo 
				inner join claveped on pedimp.cp_codigo=claveped.cp_codigo
                            WHERE      pedimp.pi_fec_ent <= dbo.FACTEXP.FE_FECHA AND pi_estatus<>'R' and claveped.cp_descargable='S'
			 and pedimp.pi_movimiento='E' 
			and PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IT', 'IV', 'OC', 'TR', 'VT', 'RG', 'IR', 'IE', 'IB', 'RE'))
			and ma_codigo = dbo.VBOM_DESCTEMP.BST_HIJO) - SUM(dbo.VBOM_DESCTEMP.CANTDESC),6)
			end,
		'CantFaltante'=case when (SELECT     SUM(pid_saldogen)
                            FROM          pidescarga INNER JOIN
                                                   pedimp ON pidescarga.pi_codigo = pedimp.pi_codigo 
				inner join claveped on pedimp.cp_codigo=claveped.cp_codigo
                            WHERE      pedimp.pi_fec_ent <= dbo.FACTEXP.FE_FECHA AND pi_estatus<>'R' and claveped.cp_descargable='S'
			 and pedimp.pi_movimiento='E' 
			and PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IT', 'IV', 'OC', 'TR', 'VT', 'RG', 'IR', 'IE', 'IB', 'RE'))
			and ma_codigo = dbo.VBOM_DESCTEMP.BST_HIJO) - SUM(dbo.VBOM_DESCTEMP.CANTDESC)  < 0 then

		abs(round((SELECT     SUM(pid_saldogen)
                            FROM          pidescarga INNER JOIN
                                                   pedimp ON pidescarga.pi_codigo = pedimp.pi_codigo 
				inner join claveped on pedimp.cp_codigo=claveped.cp_codigo
                            WHERE      pedimp.pi_fec_ent <= dbo.FACTEXP.FE_FECHA AND pi_estatus<>'R' and claveped.cp_descargable='S'
			 and pedimp.pi_movimiento='E' 
			and PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IT', 'IV', 'OC', 'TR', 'VT', 'RG', 'IR', 'IE', 'IB', 'RE'))
			and ma_codigo = dbo.VBOM_DESCTEMP.BST_HIJO) - SUM(dbo.VBOM_DESCTEMP.CANTDESC),6)) 


		when  (SELECT     SUM(pid_saldogen)
                            FROM          pidescarga INNER JOIN
                                                   pedimp ON pidescarga.pi_codigo = pedimp.pi_codigo 
				inner join claveped on pedimp.cp_codigo=claveped.cp_codigo
                            WHERE      pedimp.pi_fec_ent <= dbo.FACTEXP.FE_FECHA AND pi_estatus<>'R' and claveped.cp_descargable='S'
			 and pedimp.pi_movimiento='E' 
			and PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IT', 'IV', 'OC', 'TR', 'VT', 'RG', 'IR', 'IE', 'IB', 'RE'))
			and ma_codigo = dbo.VBOM_DESCTEMP.BST_HIJO) - SUM(dbo.VBOM_DESCTEMP.CANTDESC) is null then
		SUM(dbo.VBOM_DESCTEMP.CANTDESC)
		else 0 end
FROM         dbo.VBOM_DESCTEMP INNER JOIN
                      dbo.FACTEXP ON dbo.VBOM_DESCTEMP.FE_CODIGO = dbo.FACTEXP.FE_CODIGO LEFT OUTER JOIN
	        dbo.MAESTRO ON dbo.VBOM_DESCTEMP.BST_HIJO=dbo.MAESTRO.MA_CODIGO	
GROUP BY dbo.VBOM_DESCTEMP.FE_CODIGO, dbo.VBOM_DESCTEMP.BST_HIJO, dbo.FACTEXP.FE_FECHA, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOPARTEAUX
ORDER BY dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOPARTEAUX











































GO
