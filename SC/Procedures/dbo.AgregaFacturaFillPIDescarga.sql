SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[AgregaFacturaFillPIDescarga] (@picodigo int, @user int)   as

declare  @maximo int, @FechaActual varchar(10), @hora varchar(15),
@kap_indiced_ped int, @pid_saldogenr decimal(38,6),  @pid_can_genr decimal(38,6),@Sumkap_CantDesc decimal(38,6), @em_codigo int, @PI_USA_TIP_CAMFACT char(1),
 @ccp_tipo varchar(5), @pi_rectifica int, @ccp_tipo2 varchar(5)

	if (select min(pid_indiced) from TempPedImpDet)=0
		SELECT     @maximo= isnull(MAX(PID_INDICED),0)+1
		FROM         PEDIMPDET
	else
		SELECT     @maximo= isnull(MAX(PID_INDICED),1)
		FROM         PEDIMPDET


	select @ccp_tipo=ccp_tipo from configuraclaveped where cp_codigo in (select cp_codigo from pedimp where pi_codigo=@picodigo)
	select @pi_rectifica=pi_rectifica from pedimp where pi_codigo=@picodigo
	select @ccp_tipo2=ccp_tipo from configuraclaveped where cp_codigo in (select cp_codigo from pedimp where pi_codigo=@pi_rectifica)


	delete from pidescarga where pi_codigo not in (select pi_codigo from vpedimp)
	delete from pidescarga where pid_indiced not in (select pid_indiced from vpedimp inner join pedimpdet on vpedimp.pi_codigo=pedimpdet.pi_codigo)


	insert into PIDescarga(PI_CODIGO, PID_INDICED, PID_SALDOGEN, MA_CODIGO, MA_GENERICO, PI_FEC_ENT, PI_ACTIVOFIJO, DI_DEST_ORIGEN)
	SELECT TempPedImpDet.PI_CODIGO, TempPedImpDet.PID_INDICED+@maximo, TempPedImpDet.PID_CAN_GEN, TempPedImpDet.MA_CODIGO, TempPedImpDet.MA_GENERICO, PEDIMP.PI_FEC_ENT, 
	'PI_ACTIVOFIJO'=(CASE WHEN PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IA', 'IB', 'IM')) OR
				PEDIMP.CP_RECTIFICA in (select cp_codigo from configuraclaveped where ccp_tipo in ('IA', 'IB', 'IM')) 
				OR (PEDIMP.PI_DESP_EQUIPO='S' AND (PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ( 'VT', 'IV')) OR
				PEDIMP.CP_RECTIFICA in (select cp_codigo from configuraclaveped where ccp_tipo in ('VT', 'IV')))) OR
				TempPedImpDet.TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN('H', 'Q', 'X', 'C')) THEN 'S' ELSE 'N' END),
	PEDIMP.DI_DEST_ORIGEN
	FROM PEDIMP LEFT OUTER JOIN
	                      CLAVEPED ON PEDIMP.CP_CODIGO = CLAVEPED.CP_CODIGO INNER JOIN
	                      TempPedImpDet ON PEDIMP.PI_CODIGO = TempPedImpDet.PI_CODIGO
	WHERE (PEDIMP.PI_ACTIVO_DESCARGA = 'S') AND (PEDIMP.PI_MOVIMIENTO='E') 
			and ((CLAVEPED.CP_DESCARGABLE = 'S' and @ccp_tipo<>'RE') or (@ccp_tipo='RE'  and PI_GENERASALDOF4 ='S'))		
			and (TempPedImpDet.pid_descargable='S') 
	and  TempPedImpDet.PI_CODIGO=@picodigo
	ORDER BY PEDIMP.PI_FEC_ENT ASC, PEDIMP.PI_CODIGO ASC


--	if (select CF_USASALDOPEDIMPDEFINITO from configuracion)='S' or (select cp_descargable from claveped where cp_codigo in (select cp_codigo from pedimp where pi_codigo=@picodigo))='S'
	begin
		insert into PIDescarga(PI_CODIGO, PID_INDICED, PID_SALDOGEN, MA_CODIGO, MA_GENERICO, PI_FEC_ENT, PI_ACTIVOFIJO, PI_DEFINITIVO, DI_DEST_ORIGEN)
		SELECT TempPedImpDet.PI_CODIGO, TempPedImpDet.PID_INDICED+@maximo, TempPedImpDet.PID_CAN_GEN, TempPedImpDet.MA_CODIGO, TempPedImpDet.MA_GENERICO, PEDIMP.PI_FEC_ENT, 
		'PI_ACTIVOFIJO'=CASE WHEN TempPedImpDet.TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN('H', 'Q', 'X', 'C')) THEN 'S' ELSE 'N' END,
		'S', PEDIMP.DI_DEST_ORIGEN
		FROM PEDIMP LEFT OUTER JOIN
		                      CLAVEPED ON PEDIMP.CP_CODIGO = CLAVEPED.CP_CODIGO LEFT OUTER JOIN
		                      TempPedImpDet ON PEDIMP.PI_CODIGO = TempPedImpDet.PI_CODIGO 
		WHERE (PEDIMP.PI_MOVIMIENTO='E') 
		and (PEDIMP.CP_CODIGO in (select cp_codigo from configuraclaveped where ccp_tipo in ('IE', 'RG', 'SI', 'CN'))
                -- se agregó referencia a bandera de descargable en PedImpDet en base a versión 2.0.0.34 (glr)
		and PI_GENERASALDOF4 ='S') and TempPedImpDet.pid_descargable = 'S'
		AND (PEDIMP.PI_ACTIVO_DESCARGA = 'S')		and  TempPedImpDet.PI_CODIGO=@picodigo
		ORDER BY PEDIMP.PI_FEC_ENT ASC, PEDIMP.PI_CODIGO ASC


	end

GO
