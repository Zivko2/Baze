SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_descargaGrPaisNoEncon] (@fed_indiced int, @tipodescarga varchar(2))   as

declare @fe_fecha varchar(10), @CodigoFactura int, @CF_DESCARGAVENCIDOS char(1),
@destinofin char(1)


	select @fe_fecha=convert(varchar(10),fe_fecha,101), @CodigoFactura=fe_codigo from factexp where fe_codigo in (select fe_codigo from factexpdet where fed_indiced=@fed_indiced)

	SELECT     @CF_DESCARGAVENCIDOS=CF_DESCARGAVENCIDOS
	FROM         CONFIGURACION



	if @CF_DESCARGAVENCIDOS='S'
	begin
		INSERT INTO KARDESPEDtemp(KAP_FACTRANS,  KAP_CantTotADescargar, KAP_CANTDESC, KAP_INDICED_FACT, 
					MA_HIJO, KAP_TIPO_DESC, KAP_Saldo_FED, KAP_FisComp, KAP_ESTATUS, KAP_PADRESUST)
	
		SELECT     TOP 100 PERCENT @CodigoFactura, round(VBOM_DESCTEMPPais.CANTDESC,6), 0, VBOM_DESCTEMPPais.FED_INDICED, 
				VBOM_DESCTEMPPais.BST_HIJO, VBOM_DESCTEMPPais.BST_TIPODESC,
				round(VBOM_DESCTEMPPais.CANTDESC,6) , 'MA_TIP_ENS' = case when VBOM_DESCTEMPPais.MA_TIP_ENS='A'  THEN 'S' ELSE 'N' END, 'N',
				VBOM_DESCTEMPPais.MA_GENERICO
		FROM         VBOM_DESCTEMPPais
		WHERE     VBOM_DESCTEMPPais.MA_GENERICO not in (SELECT MA_GENERICO FROM vPIDescarga 
				WHERE vPIDescarga.PID_SALDOGEN > 0 and vPIDescarga.PI_FEC_ENT<= @fe_fecha
				AND vPIDescarga.Pa_origen = VBOM_DESCTEMPPais.pa_codigo)
		and (VBOM_DESCTEMPPais.BST_TIPODESC=left(@tipodescarga,1) or VBOM_DESCTEMPPais.BST_TIPODESC=right(@tipodescarga,1))
		AND VBOM_DESCTEMPPais.FED_INDICED=@fed_indiced AND VBOM_DESCTEMPPais.BST_HIJO IS NOT NULL
		and round(VBOM_DESCTEMPPais.CANTDESC,6)>0
	end
	else
	begin
		INSERT INTO KARDESPEDtemp(KAP_FACTRANS,  KAP_CantTotADescargar, KAP_CANTDESC, KAP_INDICED_FACT, 
					MA_HIJO, KAP_TIPO_DESC, KAP_Saldo_FED, KAP_FisComp, KAP_ESTATUS, KAP_PADRESUST)
	
		SELECT     TOP 100 PERCENT @CodigoFactura, round(VBOM_DESCTEMPPais.CANTDESC,6), 0, VBOM_DESCTEMPPais.FED_INDICED, 
				VBOM_DESCTEMPPais.BST_HIJO, VBOM_DESCTEMPPais.BST_TIPODESC,
				round(VBOM_DESCTEMPPais.CANTDESC,6) , 'MA_TIP_ENS' = case when VBOM_DESCTEMPPais.MA_TIP_ENS='A'  THEN 'S' ELSE 'N' END, 'N',
			     VBOM_DESCTEMPPais.MA_GENERICO
		FROM         VBOM_DESCTEMPPais
		WHERE     VBOM_DESCTEMPPais.MA_GENERICO not in (SELECT MA_GENERICO FROM vPIDescarga
				WHERE vPIDescarga.PID_SALDOGEN > 0 and vPIDescarga.Pa_origen = VBOM_DESCTEMPPais.pa_codigo and
				vPIDescarga.PI_FEC_ENT<= @fe_fecha and vPIDescarga.pid_fechavence>=@fe_fecha )
		and (VBOM_DESCTEMPPais.BST_TIPODESC=left(@tipodescarga,1) or VBOM_DESCTEMPPais.BST_TIPODESC=right(@tipodescarga,1))
		AND VBOM_DESCTEMPPais.FED_INDICED=@fed_indiced AND VBOM_DESCTEMPPais.BST_HIJO IS NOT NULL
		and round(VBOM_DESCTEMPPais.CANTDESC,6)>0
	end
GO
