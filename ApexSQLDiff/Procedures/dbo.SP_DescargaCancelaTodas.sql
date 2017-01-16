SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO








CREATE PROCEDURE [dbo].[SP_DescargaCancelaTodas]    as

SET NOCOUNT ON 
declare @fe_codigo int, @fe_folio varchar(30)


	TRUNCATE TABLE KARDESPED

	TRUNCATE TABLE KARDESPEDTEMP 	

	exec sp_CreaBOM_DESCTEMP


	TRUNCATE TABLE BOM_DESCTEMP


	print 'actualizando el saldo del pedimento que no se encuentran en kardesped y que el saldo es <> cant_gen'
	-- actualiza el saldo del pedimento que no se encuentran en kardesped y que el saldo es <> cant_gen
		/*UPDATE PIDescarga
		SET     PIDescarga.PID_SALDOGEN= dbo.PEDIMPDET.PID_CAN_GEN
		FROM         dbo.PEDIMPDET INNER JOIN
		                      dbo.VPEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.VPEDIMP.PI_CODIGO LEFT OUTER JOIN
		                      dbo.KARDESPED ON dbo.PEDIMPDET.PID_INDICED = dbo.KARDESPED.KAP_INDICED_PED
				INNER JOIN PIDescarga on dbo.PEDIMPDET.PID_INDICED = PIDescarga.PID_INDICED
		WHERE     (dbo.KARDESPED.KAP_INDICED_PED IS NULL)  */


	 print 'inserta en la tabla pidescarga los que hagan falta  por precaucion'
	insert into PIDescarga(PI_CODIGO, PID_INDICED, PID_SALDOGEN, MA_CODIGO, MA_GENERICO, PI_FEC_ENT, PI_ACTIVOFIJO, PI_DEFINITIVO, DI_DEST_ORIGEN)
	SELECT PEDIMPDET.PI_CODIGO, PEDIMPDET.PID_INDICED, PEDIMPDET.PID_CAN_GEN, PEDIMPDET.MA_CODIGO, PEDIMPDET.MA_GENERICO, PEDIMP.PI_FEC_ENT, 
	'PI_ACTIVOFIJO'=CASE WHEN PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IA', 'IB', 'IM')) THEN 'S' ELSE 'N' END,
	'N', PEDIMP.DI_DEST_ORIGEN
	FROM PEDIMP LEFT OUTER JOIN
	                      CLAVEPED ON PEDIMP.CP_CODIGO = CLAVEPED.CP_CODIGO LEFT OUTER JOIN
	                      PEDIMPDET ON PEDIMP.PI_CODIGO = PEDIMPDET.PI_CODIGO
	WHERE (PEDIMP.PI_ACTIVO_DESCARGA = 'S') AND (PEDIMP.PI_MOVIMIENTO='E') 
			and ((CLAVEPED.CP_DESCARGABLE = 'S' and PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo not in ('RE'))) 
				or (PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('RE'))  and PI_GENERASALDOF4 ='S'))
			and (pedimpdet.pid_descargable='S') AND PID_INDICED NOT IN (SELECT PID_INDICED FROM PIDescarga)
	and PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IT', 'IV', 'OC', 'TR', 'VT', 'RG', 'IR', 'IB', 'RE', 'IA', 'IM', 'ED'))
	ORDER BY PEDIMP.PI_FEC_ENT ASC, PEDIMP.PI_CODIGO ASC



	--if (select CF_USASALDOPEDIMPDEFINITO from configuracion)='S'
	begin
		insert into PIDescarga(PI_CODIGO, PID_INDICED, PID_SALDOGEN, MA_CODIGO, MA_GENERICO, PI_FEC_ENT, PI_ACTIVOFIJO, PI_DEFINITIVO, DI_DEST_ORIGEN)
		SELECT PEDIMPDET.PI_CODIGO, PEDIMPDET.PID_INDICED, 0, PEDIMPDET.MA_CODIGO, PEDIMPDET.MA_GENERICO, PEDIMP.PI_FEC_ENT, 
		'PI_ACTIVOFIJO'=CASE WHEN PEDIMPDET.TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN('H', 'Q', 'X', 'C')) THEN 'S' ELSE 'N' END,
		'S', PEDIMP.DI_DEST_ORIGEN
		FROM PEDIMP LEFT OUTER JOIN
		                      CLAVEPED ON PEDIMP.CP_CODIGO = CLAVEPED.CP_CODIGO LEFT OUTER JOIN
		                      PEDIMPDET ON PEDIMP.PI_CODIGO = PEDIMPDET.PI_CODIGO 
		WHERE (PEDIMP.PI_MOVIMIENTO='E')  AND PID_INDICED NOT IN (SELECT PID_INDICED FROM PIDescarga)
		and PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IE', 'RG', 'SI', 'CN'))
                -- se agregó referencia a bandera de descargable en PedImpDet en base a versión 2.0.0.34 (glr)
		and PI_GENERASALDOF4 = 'S' and PEDIMPDET.pid_descargable = 'S'
--		(PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('CN')) and PI_GENERASALDOF4 ='S'))
		AND (PEDIMP.PI_ACTIVO_DESCARGA = 'S')
		ORDER BY PEDIMP.PI_FEC_ENT ASC, PEDIMP.PI_CODIGO ASC
	end




	print 'actualizando fed_descargado de las facturas que no se encuentran en kardesped '
	-- actualiza fed_descargado de las facturas que no se encuentran en kardesped 
	UPDATE dbo.FACTEXPDET
	SET     dbo.FACTEXPDET.FED_DESCARGADO='N'
	FROM         dbo.FACTEXP INNER JOIN
	                      dbo.FACTEXPDET ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO LEFT OUTER JOIN
	                      dbo.KARDESPED ON dbo.FACTEXP.FE_CODIGO = dbo.KARDESPED.KAP_FACTRANS
	WHERE     (dbo.KARDESPED.KAP_FACTRANS IS NULL) AND (dbo.FACTEXPDET.FED_DESCARGADO <> 'N')
	and (dbo.FACTEXP.FE_TIPO<>'T')



	DELETE FROM ALMACENDESP WHERE  FETR_CODIGO not in
	(select KAP_FACTRANS from kardesped)


	alter table factexp disable trigger UPDATE_FACTEXP

	print 'actualizando fe_descargada de las facturas que no se encuentran en kardesped'

	UPDATE FACTEXP
	SET     FACTEXP.FE_DESCARGADA='N', FACTEXP.FE_FECHADESCARGA=NULL, FACTEXP.FE_DESCMANUAL='N'
	FROM         FACTEXP LEFT OUTER JOIN
	                      KARDESPED ON FACTEXP.FE_CODIGO = KARDESPED.KAP_FACTRANS
	WHERE     (KARDESPED.KAP_FACTRANS IS NULL) and (FACTEXP.FE_DESCARGADA='S' OR
	FACTEXP.FE_FECHADESCARGA IS NOT NULL)

	alter table factexp enable trigger UPDATE_FACTEXP

	print 'actualizando estatus de las facturas que no se encuentran en kardesped'
		Exec SP_ACTUALIZAESTATUSFACTEXPALL


		UPDATE PIDescarga
		SET     PIDescarga.PID_SALDOGEN= round(PEDIMPDET.PID_CAN_GEN- (ISNULL(KAP_CANTDESC, 0) + ISNULL(CANTLIGA, 0))  ,6)
		FROM         PEDIMPDET INNER JOIN
		                      PEDIMP ON PEDIMPDET.PI_CODIGO = PEDIMP.PI_CODIGO LEFT OUTER JOIN
		                      PIDescarga ON PEDIMPDET.PID_INDICED = PIDescarga.PID_INDICED LEFT OUTER JOIN
		                        (SELECT     SUM(KAP_CANTDESC) AS KAP_CANTDESC, KAP_INDICED_PED
		                              FROM         KARDESPED
		                              WHERE     KAP_INDICED_PED IS NOT NULL
					GROUP BY KAP_INDICED_PED) CANTDESC ON PEDIMPDET.PID_INDICED=CANTDESC.KAP_INDICED_PED LEFT OUTER JOIN
					(SELECT     SUM(FACTEXPDET.FED_CANT * FACTEXPDET.EQ_GEN) CANTLIGA, factexpdet.pid_indiced
		                              FROM         factexpdet INNER JOIN
		                                                    factexp ON factexpdet.fe_codigo = factexp.fe_codigo
		                              WHERE     factexp.fe_estatus IN ('D', 'P') AND factexpdet.pid_indiced<>-1
					GROUP BY factexpdet.pid_indiced)  CANTLIGADA ON PEDIMPDET.PID_INDICED=CANTLIGADA.pid_indiced
		WHERE     (PEDIMP.PI_ESTATUS <> 'R') AND (PEDIMP.PI_MOVIMIENTO = 'E') AND (PIDescarga.PID_INDICED IS NOT NULL)
		AND PIDescarga.PID_SALDOGEN<> round(PEDIMPDET.PID_CAN_GEN- (ISNULL(KAP_CANTDESC, 0) + ISNULL(CANTLIGA, 0)) ,6)


	print 'actualizando el estatus de los pedimentos'
	-- actualiza el estatus del pedimento 
	EXEC SP_ACTUALIZAESTATUSPEDIMPALL

	print 'actualizando la bandera de configuracion '
	-- actualiza la bandera de configuracion 
	update configuracion
	set cf_descargando='N', US_DESCARGANDO=0



GO
