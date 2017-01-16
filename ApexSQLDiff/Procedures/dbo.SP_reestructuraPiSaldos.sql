SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_reestructuraPiSaldos] (@user int)   as

--SET NOCOUNT ON 
declare  @pid_saldogen decimal(38,6), @pid_can_gen decimal(38,6), @kap_indiced_ped int, @pid_saldogenr decimal(38,6), 
@pid_can_genr decimal(38,6), @Sumkap_CantDesc decimal(38,6)


	--Yolanda Avila (2009-06-16)
	--Se comento este query, ya que aqui borraba los detalles de algunos pedimentos de acuerdo al estatus, sin antes actualizarles el saldo para que les cambiara el status
	--Se movio este query a otro lugar dentro del stored procedure 
	-- borra los definitivos
	--if (select CF_USASALDOPEDIMPDEFINITO from configuracion)<>'S'
	/*DELETE FROM PIDescarga
	WHERE PI_CODIGO IN
	(SELECT     PIDescarga.PI_CODIGO
	FROM         CLAVEPED INNER JOIN
	                      PEDIMP ON CLAVEPED.CP_CODIGO = PEDIMP.CP_CODIGO INNER JOIN
	                      PIDescarga ON PEDIMP.PI_CODIGO = PIDescarga.PI_CODIGO
	WHERE     (CLAVEPED.CP_DESCARGABLE = 'N' AND PEDIMP.PI_GENERASALDOF4<>'S') OR (PEDIMP.PI_GENERASALDOF4<>'S' AND PEDIMP.PI_ESTATUS in ('R', 'E', 'F', 'G', 'N'))
	GROUP BY PIDescarga.PI_CODIGO)
	*/


--Query modificado por lentitud en sql2008 Manuel G. 05-Oct-2010
--delete from kardesped where kap_factrans not in (select fe_codigo from factexp)
--or kap_factrans is null

delete from kardesped
where kap_factrans in 
 (select k.kap_factrans	
    from (select KAP_FACTRANS
			from KARDESPED group by KAP_FACTRANS) k
	where k.KAP_FACTRANS not in (select fe_codigo from FACTEXP))				


--exec LlenaPIDescargaNoDescFinal	

	ALTER TABLE PIDESCARGA DISABLE TRIGGER INSERT_PIDESCARGA

--if exists(select * from kardesped)
begin
	delete from pidescarga where pi_codigo not in (select pi_codigo from vpedimp)
	delete from pidescarga where pid_indiced not in (select pid_indiced from vpedimp inner join pedimpdet on vpedimp.pi_codigo=pedimpdet.pi_codigo)


	 print 'inserta en la tabla pidescarga los que hagan falta  por precaucion'


	update configuracion
	set cf_pedsaldoinc='N'


end

-------

--		 print 'inserta en la tabla pidescarga los que hagan falta  por precaucion'
		insert into PIDescarga(PI_CODIGO, PID_INDICED, PID_SALDOGEN, MA_CODIGO, MA_GENERICO, PI_FEC_ENT, PI_ACTIVOFIJO, DI_DEST_ORIGEN)
		SELECT PEDIMPDET.PI_CODIGO, PEDIMPDET.PID_INDICED, PID_CAN_GEN, PEDIMPDET.MA_CODIGO, PEDIMPDET.MA_GENERICO, 
		CASE WHEN PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('TS')) then ISNULL(PEDIMPDET.PID_FECHAPEDTRANS,PEDIMP.PI_FEC_ENTPED) 
			else PEDIMP.PI_FEC_ENT end, 
		'PI_ACTIVOFIJO'=CASE WHEN PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IA', 'IB', 'IM')) OR
					PEDIMP.CP_RECTIFICA in (select cp_codigo from configuraclaveped where ccp_tipo in ('IA', 'IB', 'IM')) 
					OR (PEDIMP.PI_DESP_EQUIPO='S' AND (PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ( 'VT', 'IV')) OR
					PEDIMP.CP_RECTIFICA in (select cp_codigo from configuraclaveped where ccp_tipo in ('VT', 'IV')))) OR
					PEDIMPDET.TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN('H', 'Q', 'X', 'C')) THEN 'S' ELSE 'N' END,
		PEDIMP.DI_DEST_ORIGEN
		FROM PEDIMP 

		LEFT OUTER JOIN CLAVEPED ON PEDIMP.CP_CODIGO = CLAVEPED.CP_CODIGO 
		--Yolanda Avila
		--2010-05-30
		--Los pedimentos que tengan detalles son los que deben incluirse en la relacion, ya que de lo contrario se genera un error por ser NULL el campo de pedimpdet.pid_indiced
		--LEFT OUTER JOIN PEDIMPDET ON PEDIMP.PI_CODIGO = PEDIMPDET.PI_CODIGO 
		inner join PEDIMPDET ON PEDIMP.PI_CODIGO = PEDIMPDET.PI_CODIGO 
		WHERE (PEDIMP.PI_ACTIVO_DESCARGA = 'S') AND (PEDIMP.PI_MOVIMIENTO='E') 
				and ((CLAVEPED.CP_DESCARGABLE = 'S' and PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo not in ('RE'))) 
					or (PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('RE'))  and PI_GENERASALDOF4 ='S'))
				and (pedimpdet.pid_descargable='S') 
				--AND pedimpdet.PID_INDICED NOT IN (SELECT PID_INDICED FROM PIDescarga)
				  AND (pedimpdet.PID_INDICED NOT IN (SELECT PID_INDICED FROM PIDescarga where PIDescarga.PID_INDICED =  pedimpdet.PID_INDICED))
		and ((PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IT', 'IV', 'OC', 'TR', 'VT', 'RG', 'IR', 'IB', 'RE', 'IA', 'IM', 'ED'))
		        or (PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IT', 'IV', 'OC', 'TR', 'VT', 'RG', 'IR', 'IB', 'RE', 'IA', 'IM', 'ED'))
			and  CLAVEPED.cp_descargable='S'))) AND PEDIMP.PI_ESTATUS<>'R'
		ORDER BY PEDIMP.PI_FEC_ENT ASC, PEDIMP.PI_CODIGO ASC




		--if (select CF_USASALDOPEDIMPDEFINITO from configuracion)='S'
		-- se les debe de generar saldo a los pedimentos que PI_GENERASALDOF4 ='S' aunque no tengan seleccionado CF_USASALDOPEDIMPDEFINITO 
		begin 
			insert into PIDescarga(PI_CODIGO, PID_INDICED, PID_SALDOGEN, MA_CODIGO, MA_GENERICO, PI_FEC_ENT, PI_ACTIVOFIJO, PI_DEFINITIVO, DI_DEST_ORIGEN)
			SELECT PEDIMPDET.PI_CODIGO, PEDIMPDET.PID_INDICED, 0, PEDIMPDET.MA_CODIGO, PEDIMPDET.MA_GENERICO, 
			CASE WHEN PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('TS')) then ISNULL(PEDIMPDET.PID_FECHAPEDTRANS,PEDIMP.PI_FEC_ENTPED) 
			else PEDIMP.PI_FEC_ENT end, 
			'PI_ACTIVOFIJO'=CASE WHEN PEDIMPDET.TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN('H', 'Q', 'X', 'C')) THEN 'S' ELSE 'N' END,
			'S', PEDIMP.DI_DEST_ORIGEN
			FROM PEDIMP 

			LEFT OUTER JOIN CLAVEPED ON PEDIMP.CP_CODIGO = CLAVEPED.CP_CODIGO 
			--Yolanda Avila
			--2010-05-30
			--Los pedimentos que tengan detalles son los que deben incluirse en la relacion, ya que de lo contrario se genera un error por ser NULL el campo de pedimpdet.pid_indiced
			--LEFT OUTER JOIN PEDIMPDET ON PEDIMP.PI_CODIGO = PEDIMPDET.PI_CODIGO 
			inner join PEDIMPDET ON PEDIMP.PI_CODIGO = PEDIMPDET.PI_CODIGO 
			WHERE (PEDIMP.PI_MOVIMIENTO='E')  
			--AND pedimpdet.PID_INDICED NOT IN (SELECT PID_INDICED FROM PIDescarga)
			  AND (pedimpdet.PID_INDICED NOT IN (SELECT PID_INDICED FROM PIDescarga where PIDescarga.PID_INDICED =  pedimpdet.PID_INDICED))
			and (PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IE', 'RG', 'SI', 'CN')) and PI_GENERASALDOF4 ='S')
			AND (PEDIMP.PI_ACTIVO_DESCARGA = 'S') AND PEDIMP.PI_ESTATUS<>'R'
			ORDER BY PEDIMP.PI_FEC_ENT ASC, PEDIMP.PI_CODIGO ASC


		end

-------



		 print 'actualizando el saldo del pedimento que no se encuentran en kardesped y que el saldo es <> cant_gen'

		UPDATE PIDESCARGA
		SET     PID_SALDOGEN= PEDIMPDET.PID_CAN_GEN
		FROM         PIDESCARGA INNER JOIN PEDIMPDET ON PIDESCARGA.PID_INDICED=PEDIMPDET.PID_INDICED
		WHERE-- PIDESCARGA.PID_INDICED NOT IN (SELECT KAP_INDICED_PED FROM KARDESPED WHERE KAP_INDICED_PED IS NOT NULL GROUP BY KAP_INDICED_PED)
		--AND 
		round(PIDESCARGA.PID_SALDOGEN,6) <> round(PEDIMPDET.PID_CAN_GEN,6) 



		
		UPDATE PIDescarga
		--Yolanda Avila
		--2010-07-29
		--SET PIDescarga.PID_SALDOGEN= round(PEDIMPDET.PID_CAN_GEN- (ISNULL(KAP_CANTDESC, 0) + ISNULL(CANTLIGA, 0))  ,6)
		SET PIDescarga.PID_SALDOGEN= round(PEDIMPDET.PID_CAN_GEN- (ISNULL(KAP_CANTDESC, 0) + ISNULL(CANTLIGA, 0)/*+ isnull(pidescarga.pid_congelasubmaq,0)*/)  ,6)
		FROM PEDIMPDET 
		INNER JOIN PEDIMP ON PEDIMPDET.PI_CODIGO = PEDIMP.PI_CODIGO 
		LEFT OUTER JOIN PIDescarga ON PEDIMPDET.PID_INDICED = PIDescarga.PID_INDICED 
		LEFT OUTER JOIN	(SELECT SUM(KAP_CANTDESC) AS KAP_CANTDESC, KAP_INDICED_PED
		                 FROM KARDESPED
		                 WHERE KAP_INDICED_PED IS NOT NULL
				 GROUP BY KAP_INDICED_PED) CANTDESC ON PEDIMPDET.PID_INDICED=CANTDESC.KAP_INDICED_PED 
		LEFT OUTER JOIN (SELECT SUM(FACTEXPDET.FED_CANT * FACTEXPDET.EQ_GEN) CANTLIGA, factexpdet.pid_indiced
				 FROM factexpdet 
				 INNER JOIN factexp ON factexpdet.fe_codigo = factexp.fe_codigo
				 WHERE factexp.fe_estatus IN ('D', 'P') AND factexpdet.pid_indiced<>-1
				 --Yolanda Avila (2009-11-20)
				 --Se agrego esta linea ya que solo debe considerarlo si la factura de exportacion se genero en forma automatica a partir de la factura de importacion 
				 --como es el caso de Kent LandsBerg
				 --2010-04-01
				 --and (select cf_genautfactexppo from configuracion) = 'S'
				 GROUP BY factexpdet.pid_indiced) CANTLIGADA 
				 		ON PEDIMPDET.PID_INDICED=CANTLIGADA.pid_indiced
		WHERE (PEDIMP.PI_ESTATUS <> 'R') AND (PEDIMP.PI_MOVIMIENTO = 'E') AND (PIDescarga.PID_INDICED IS NOT NULL)
		--Yolanda Avila
		--2010-07-29
		--AND PIDescarga.PID_SALDOGEN<> round(PEDIMPDET.PID_CAN_GEN- (ISNULL(KAP_CANTDESC, 0) + ISNULL(CANTLIGA, 0)) ,6)
		AND PIDescarga.PID_SALDOGEN<> round(PEDIMPDET.PID_CAN_GEN- (ISNULL(KAP_CANTDESC, 0) + ISNULL(CANTLIGA, 0)/*+ isnull(pidescarga.pid_congelasubmaq,0)*/) ,6)



		UPDATE PIDESCARGA
		SET     PID_SALDOGEN=0
		WHERE PID_SALDOGEN <0 


	
	
		UPDATE PIDESCARGA
		SET PI_ACTIVOFIJO=(CASE WHEN PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IA', 'IB', 'IM')) OR
				PEDIMP.CP_RECTIFICA in (select cp_codigo from configuraclaveped where ccp_tipo in ('IA', 'IB', 'IM')) 
				OR (PEDIMP.PI_DESP_EQUIPO='S' AND (PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ( 'VT', 'IV')) OR
				PEDIMP.CP_RECTIFICA in (select cp_codigo from configuraclaveped where ccp_tipo in ('VT', 'IV')))) OR
				PEDIMPDET.TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN('H', 'Q', 'X', 'C')) THEN 'S' ELSE 'N' END)
		FROM PEDIMP LEFT OUTER JOIN PEDIMPDET ON PEDIMP.PI_CODIGO = PEDIMPDET.PI_CODIGO INNER JOIN PIDESCARGA
			ON PEDIMPDET.PID_INDICED=PIDESCARGA.PID_INDICED
		WHERE PI_ACTIVOFIJO<>(CASE WHEN PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IA', 'IB', 'IM')) OR
				PEDIMP.CP_RECTIFICA in (select cp_codigo from configuraclaveped where ccp_tipo in ('IA', 'IB', 'IM')) 
				OR (PEDIMP.PI_DESP_EQUIPO='S' AND (PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ( 'VT', 'IV')) OR
				PEDIMP.CP_RECTIFICA in (select cp_codigo from configuraclaveped where ccp_tipo in ('VT', 'IV')))) OR
				PEDIMPDET.TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN('H', 'Q', 'X', 'C')) THEN 'S' ELSE 'N' END) 


		UPDATE PIDESCARGA
		SET PIDESCARGA.PI_FEC_ENT = PEDIMP.PI_FEC_ENT
		FROM PEDIMP LEFT OUTER JOIN PEDIMPDET ON PEDIMP.PI_CODIGO = PEDIMPDET.PI_CODIGO INNER JOIN PIDESCARGA
			ON PEDIMPDET.PID_INDICED=PIDESCARGA.PID_INDICED
		WHERE PIDESCARGA.PI_FEC_ENT <> PEDIMP.PI_FEC_ENT and PEDIMP.CP_CODIGO not in (select cp_codigo from configuraclaveped where ccp_tipo in ('TS'))







	ALTER TABLE PIDESCARGA ENABLE TRIGGER INSERT_PIDESCARGA

	
	print 'actualizando el estatus del pedimento'
	EXEC SP_ACTUALIZAESTATUSPEDIMPALL


		-- borra los definitivos
		--Yolanda Avila (2009-06-16)
		--Se agrego la parte del "OR" en el where, ya que borraba al inicio algunos pedimentos sin antes actualizarles el saldo para que les cambiara el estatus del pedimento de acuerdo al saldo
		--if (select CF_USASALDOPEDIMPDEFINITO from configuracion)<>'S'

		DELETE FROM PIDescarga
		WHERE PI_CODIGO IN
		(SELECT     PIDescarga.PI_CODIGO
		FROM         CLAVEPED INNER JOIN
		                      PEDIMP ON CLAVEPED.CP_CODIGO = PEDIMP.CP_CODIGO INNER JOIN
		                      PIDescarga ON PEDIMP.PI_CODIGO = PIDescarga.PI_CODIGO
		WHERE     (CLAVEPED.CP_DESCARGABLE = 'N' AND isnull(PEDIMP.PI_GENERASALDOF4,'N')<>'S') OR 
			  (isnull(PEDIMP.PI_GENERASALDOF4,'N')<>'S' AND PEDIMP.PI_ESTATUS in ('R', 'E', 'F', 'G', 'N'))
		GROUP BY PIDescarga.PI_CODIGO)


	-- revisa si existen saldos incorrectos
	exec sp_SaldoIncorrecto


	update factimp
	set fi_cuentadet=(select isnull(count(factimpdet.fi_codigo),0) from factimpdet where factimpdet.fi_codigo =factimp.fi_codigo)
	where fi_cuentadet<>(select isnull(count(factimpdet.fi_codigo),0) from factimpdet where factimpdet.fi_codigo =factimp.fi_codigo)

	update factexp
	set fe_cuentadet=(select isnull(count(factexpdet.fe_codigo),0) from factexpdet where factexpdet.fe_codigo =factexp.fe_codigo)
	where fe_cuentadet<>(select isnull(count(factexpdet.fe_codigo),0) from factexpdet where factexpdet.fe_codigo =factexp.fe_codigo)

	update pedimp
	set pi_cuentadet=(select isnull(count(pedimpdet.pi_codigo),0) from pedimpdet where pedimpdet.pi_codigo =pedimp.pi_codigo)
	where pi_cuentadet<>(select isnull(count(pedimpdet.pi_codigo),0) from pedimpdet where pedimpdet.pi_codigo =pedimp.pi_codigo)

	update pedimp
	set pi_cuentadetb=(select isnull(count(pedimpdetb.pi_codigo),0) from pedimpdetb where pedimpdetb.pi_codigo =pedimp.pi_codigo)
	where pi_cuentadetb<>(select isnull(count(pedimpdetb.pi_codigo),0) from pedimpdetb where pedimpdetb.pi_codigo =pedimp.pi_codigo)


	--if exists (select pidescarga.pi_codigo from pidescarga inner join pedimp on pidescarga.pi_codigo=pedimp.pi_codigo
	--	where pid_fechavence is null and cp_codigo in (select cp_codigo from configuraclaveped where ccp_tipo='IT') and pid_saldogen>0)
	exec sp_actualizapedimpvencimientoall

	--Actualiza los saldos del Control de Retrabajo
	update ControlRetrabajo set CR_Saldo = CR_Saldo + isnull(CRS_CantidadDescargada ,0)
	 from ControlRetrabajo 
		left outer join controlRetrabajoSaldo on ControlRetrabajo.CR_Codigo = ControlRetrabajoSaldo.CR_Codigo
		left outer join Kardesped on controlRetrabajoSaldo.FED_Indiced = Kardesped.KAP_INDICED_FACT
	where kardesped.kap_codigo is null

	delete from controlRetrabajoSaldo 
	where CRS_Codigo in (select CRS_Codigo 
						   from ControlRetrabajo
							left outer join Kardesped on controlRetrabajoSaldo.FED_Indiced = Kardesped.KAP_INDICED_FACT
							where kardesped.kap_codigo is null)

	update ControlRetrabajo set ControlRetrabajo.CR_Saldo = cr.CR_Cantidad
	from controlRetrabajo cr
		left outer join ControlRetrabajoSaldo crs on cr.CR_Codigo = crs.CR_Codigo
	where crs.cr_codigo is null


GO
