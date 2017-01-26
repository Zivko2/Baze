SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW dbo.VVISTAFALTANTE26 
	AS
	SELECT     TOP 100 PERCENT BOMDESC1.BST_HIJO, round(SUM(BOMDESC1.CANTDESC),6) AS CantaDescargar,
			'CantFaltante'=case when round((SELECT     SUM(pid_saldogen)
	                            FROM          pidescarga INNER JOIN
	                                                   pedimp ON pidescarga.pi_codigo = pedimp.pi_codigo 
					inner join claveped on pedimp.cp_codigo=claveped.cp_codigo
	                            WHERE      pedimp.pi_fec_ent <= FACTEXP.FE_FECHA AND pi_estatus<>'R' and claveped.cp_descargable='S'
				 and pedimp.pi_movimiento='E' 
				and PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IT', 'IV', 'OC', 'TR', 'VT', 'RG', 'IR', 'IE', 'IB', 'RE'))
				and ma_codigo = BOMDESC1.BST_HIJO) - SUM(BOMDESC1.CANTDESC),6)  < 0 then
	
			abs(round((SELECT     SUM(pid_saldogen)
	                            FROM          pidescarga INNER JOIN
	                                                   pedimp ON pidescarga.pi_codigo = pedimp.pi_codigo 
					inner join claveped on pedimp.cp_codigo=claveped.cp_codigo
	                            WHERE      pedimp.pi_fec_ent <= FACTEXP.FE_FECHA AND pi_estatus<>'R' and claveped.cp_descargable='S'
				 and pedimp.pi_movimiento='E' 
				and PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IT', 'IV', 'OC', 'TR', 'VT', 'RG', 'IR', 'IE', 'IB', 'RE'))
				and ma_codigo = BOMDESC1.BST_HIJO) - SUM(BOMDESC1.CANTDESC),6)) 
	
			when  round((SELECT     SUM(pid_saldogen)
	                            FROM          pidescarga INNER JOIN
	                                                   pedimp ON pidescarga.pi_codigo = pedimp.pi_codigo 
					inner join claveped on pedimp.cp_codigo=claveped.cp_codigo
	                            WHERE      pedimp.pi_fec_ent <= FACTEXP.FE_FECHA AND pi_estatus<>'R' and claveped.cp_descargable='S'
				 and pedimp.pi_movimiento='E' 
				and PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IT', 'IV', 'OC', 'TR', 'VT', 'RG', 'IR', 'IE', 'IB', 'RE'))
				and ma_codigo = BOMDESC1.BST_HIJO) - SUM(BOMDESC1.CANTDESC),6) is null then
			round(SUM(BOMDESC1.CANTDESC),6)
			else 0 end, BOMDESC1.FACTCONV, SUM(FED_CANT) AS FED_CANT
	FROM         (SELECT BOM_DESCTEMP.FE_CODIGO, BOM_DESCTEMP.BST_HIJO, SUM(BOM_DESCTEMP.FED_CANT) AS FED_CANT,
	                     SUM(BOM_DESCTEMP.FED_CANT * ISNULL(BOM_DESCTEMP.FACTCONV, 1)) AS CANTDESC,
			     BOM_DESCTEMP.FACTCONV
		      FROM BOM_DESCTEMP 
		      WHERE (BOM_DESCTEMP.BST_DISCH = 'S')
		      GROUP BY FE_CODIGO, BST_HIJO, FACTCONV) BOMDESC1 INNER JOIN
	                      FACTEXP ON BOMDESC1.FE_CODIGO = FACTEXP.FE_CODIGO LEFT OUTER JOIN
		        MAESTRO ON BOMDESC1.BST_HIJO=MAESTRO.MA_CODIGO	
	WHERE     (FACTEXP.FE_CODIGO =26)
	GROUP BY BOMDESC1.FE_CODIGO, BOMDESC1.BST_HIJO, FACTEXP.FE_FECHA, BOMDESC1.FACTCONV
GO
