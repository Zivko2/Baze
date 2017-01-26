SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_INVENTARIOFECHAPI] (@macodigo int, @cft_tipo char(1), @picodigo int, @fecha datetime)   as

SET NOCOUNT ON 
declare @NoPedimento varchar(50),  @FechaPedimento datetime, @FechaPagoPedimento datetime,  @PID_saldoCANT decimal(38,6), @ME_CORTO varchar(5), 
	@PID_SALDOGEN decimal(38,6), @ME_GEN varchar(5), @PID_COS_UNI decimal(38,6), @AR_FRACCION varchar(20), @PID_POR_DEF decimal(38,6), @MA_CODIGO int, 
	@SE_CLAVE varchar(5), @SPI_CLAVE varchar(20), @TI_CODIGO int, @PID_NOPARTE varchar(50), @PID_DEF_TIP varchar(50), @PI_CODIGO int,
	@CFT_TIPO1 varchar(80)



		insert into INVENTARIOTempFecha (NoPedimento,  FechaPedimento, FechaPagoPedimento,  PID_saldoCANT, ME_CORTO, 
	PID_SALDOGEN, ME_GEN, PID_COS_UNI, AR_FRACCION, PID_POR_DEF, MA_CODIGO, SE_CLAVE, SPI_CLAVE, TI_CODIGO, 
	PID_NOPARTE, PID_DEF_TIP, PI_CODIGO)

	SELECT       CASE WHEN dbo.PEDIMP.PI_TIPO IN ('C', 'A') THEN isnull(dbo.AGENCIAPATENTE.AGT_PATENTE, '') 
                      + '-' + dbo.PEDIMP.PI_FOLIO ELSE dbo.PEDIMP.PI_FOLIO END AS NoPedimento, dbo.PEDIMP.PI_FEC_ENT AS FechaPedimento, dbo.PEDIMP.PI_FEC_PAG AS FechaPagoPedimento, SUM(dbo.PIDESCARGA.PID_SALDOGEN / ISNULL(dbo.PEDIMPDET.EQ_GENERICO, 
	                      1)) AS PID_saldoCANT, MEDIDA_1.ME_CORTO, SUM(dbo.PIDESCARGA.PID_SALDOGEN) AS PID_SALDOGEN, MEDIDA_2.ME_CORTO AS ME_GEN, 
	                      MAX(dbo.PEDIMPDET.PID_COS_UNI) AS PID_COS_UNI, dbo.ARANCEL.AR_FRACCION, dbo.PEDIMPDET.PID_POR_DEF, 
	                      dbo.PEDIMPDET.MA_CODIGO, dbo.SECTOR.SE_CLAVE, dbo.SPI.SPI_CLAVE, dbo.PEDIMPDET.TI_CODIGO, dbo.PEDIMPDET.PID_NOPARTE,
	'PID_DEF_TIP' = CASE dbo.PEDIMPDET.PID_DEF_TIP WHEN 'G' THEN 'General' WHEN 'S' THEN 'PPS' WHEN 'P' THEN 'Bajo Tratado'  WHEN 'R' THEN 'Regla Octava' END, dbo.PEDIMP.PI_CODIGO
	FROM         dbo.AGENCIAPATENTE RIGHT OUTER JOIN
	                      dbo.PEDIMP ON dbo.AGENCIAPATENTE.AGT_CODIGO = dbo.PEDIMP.AGT_CODIGO RIGHT OUTER JOIN
	                      dbo.SPI RIGHT OUTER JOIN
	                      dbo.PEDIMPDET ON dbo.SPI.SPI_CODIGO = dbo.PEDIMPDET.SPI_CODIGO LEFT OUTER JOIN
	                      dbo.SECTOR ON dbo.PEDIMPDET.PID_SEC_IMP = dbo.SECTOR.SE_CODIGO ON 
	                      dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO LEFT OUTER JOIN
	                      dbo.ARANCEL ON dbo.PEDIMPDET.AR_IMPMX = dbo.ARANCEL.AR_CODIGO LEFT OUTER JOIN
	                      dbo.MAESTRO ON dbo.PEDIMPDET.MA_GENERICO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
	                      dbo.MEDIDA MEDIDA_1 ON dbo.PEDIMPDET.ME_CODIGO = MEDIDA_1.ME_CODIGO LEFT OUTER JOIN
	                      dbo.MEDIDA MEDIDA_2 ON dbo.PEDIMPDET.ME_GENERICO = MEDIDA_2.ME_CODIGO  LEFT OUTER JOIN
		      dbo.PIDESCARGA ON dbo.PEDIMPDET.PID_INDICED = dbo.PIDESCARGA.PID_INDICED
	WHERE     (dbo.PEDIMP.PI_ESTATUS <> 'R') and dbo.PEDIMP.PI_MOVIMIENTO='E' and dbo.PEDIMP.PI_CODIGO=@picodigo AND dbo.PEDIMP.PI_FEC_ENT<=@fecha
	GROUP BY   CASE WHEN dbo.PEDIMP.PI_TIPO IN ('C', 'A') THEN isnull(dbo.AGENCIAPATENTE.AGT_PATENTE, '') 
                      + '-' + dbo.PEDIMP.PI_FOLIO ELSE dbo.PEDIMP.PI_FOLIO END, dbo.PEDIMP.PI_FEC_PAG, MEDIDA_2.ME_CORTO, MEDIDA_1.ME_CORTO, dbo.ARANCEL.AR_FRACCION, 
	                      dbo.PEDIMPDET.PID_POR_DEF, dbo.PEDIMPDET.PID_DEF_TIP, dbo.SECTOR.SE_CLAVE, dbo.SPI.SPI_CLAVE, 
	                      dbo.PEDIMPDET.MA_CODIGO, dbo.PEDIMPDET.TI_CODIGO, dbo.PEDIMPDET.PID_NOPARTE, dbo.PEDIMP.PI_FEC_ENT, dbo.PEDIMP.PI_CODIGO
	HAVING      (SUM(dbo.PIDESCARGA.PID_SALDOGEN) > 0) 
	UNION
	-- se suma la cantidad que ha sido descargada en base a la fecha de la factura de exportacion 
	SELECT       CASE WHEN dbo.PEDIMP.PI_TIPO IN ('C', 'A') THEN isnull(dbo.AGENCIAPATENTE.AGT_PATENTE, '') 
                      + '-' + dbo.PEDIMP.PI_FOLIO ELSE dbo.PEDIMP.PI_FOLIO END AS NoPedimento, dbo.PEDIMP.PI_FEC_ENT AS FechaPedimento, dbo.PEDIMP.PI_FEC_PAG AS FechaPagoPedimento,
	                      SUM(dbo.VINVENTARIOKARSUM.KAP_CANTDESC / ISNULL(dbo.PEDIMPDET.EQ_GENERICO, 1)) AS PID_saldoCANT, MEDIDA_1.ME_CORTO, 
	                      SUM(dbo.VINVENTARIOKARSUM.KAP_CANTDESC) AS PID_SALDOGEN, MEDIDA_2.ME_CORTO AS ME_GEN, MAX(dbo.PEDIMPDET.PID_COS_UNI) AS PID_COS_UNI, 
	                      dbo.ARANCEL.AR_FRACCION, dbo.PEDIMPDET.PID_POR_DEF, dbo.PEDIMPDET.MA_CODIGO, dbo.SECTOR.SE_CLAVE, dbo.SPI.SPI_CLAVE, 
	                      dbo.PEDIMPDET.TI_CODIGO, dbo.PEDIMPDET.PID_NOPARTE, 'PID_DEF_TIP' = CASE dbo.PEDIMPDET.PID_DEF_TIP WHEN 'G' THEN 'General' WHEN 'S' THEN 'PPS' WHEN 'P' THEN 'Bajo Tratado'  WHEN 'R' THEN 'Regla Octava' END, dbo.PEDIMP.PI_CODIGO
	FROM         dbo.SECTOR RIGHT OUTER JOIN
	                      dbo.VINVENTARIOKARSUM RIGHT OUTER JOIN
	                      dbo.PEDIMPDET ON dbo.VINVENTARIOKARSUM.KAP_INDICED_PED = dbo.PEDIMPDET.PID_INDICED LEFT OUTER JOIN
	                      dbo.SPI ON dbo.PEDIMPDET.SPI_CODIGO = dbo.SPI.SPI_CODIGO ON dbo.SECTOR.SE_CODIGO = dbo.PEDIMPDET.PID_SEC_IMP LEFT OUTER JOIN
	                      dbo.AGENCIAPATENTE RIGHT OUTER JOIN
	                      dbo.PEDIMP ON dbo.AGENCIAPATENTE.AGT_CODIGO = dbo.PEDIMP.AGT_CODIGO ON 
	                      dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO LEFT OUTER JOIN
	                      dbo.ARANCEL ON dbo.PEDIMPDET.AR_IMPMX = dbo.ARANCEL.AR_CODIGO LEFT OUTER JOIN
	                      dbo.MAESTRO ON dbo.PEDIMPDET.MA_GENERICO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
	                      dbo.MEDIDA MEDIDA_1 ON dbo.PEDIMPDET.ME_CODIGO = MEDIDA_1.ME_CODIGO LEFT OUTER JOIN
	                      dbo.MEDIDA MEDIDA_2 ON dbo.PEDIMPDET.ME_GENERICO = MEDIDA_2.ME_CODIGO
	WHERE     (dbo.PEDIMP.PI_ESTATUS <> 'R')  and dbo.PEDIMP.PI_MOVIMIENTO='E' and dbo.PEDIMP.PI_CODIGO=@picodigo AND dbo.VINVENTARIOKARSUM.FE_FECHA>=@fecha
		and dbo.PEDIMP.PI_FEC_ENT <= @fecha
	GROUP BY   CASE WHEN dbo.PEDIMP.PI_TIPO IN ('C', 'A') THEN isnull(dbo.AGENCIAPATENTE.AGT_PATENTE, '') 
                      + '-' + dbo.PEDIMP.PI_FOLIO ELSE dbo.PEDIMP.PI_FOLIO END, MEDIDA_2.ME_CORTO, MEDIDA_1.ME_CORTO, dbo.ARANCEL.AR_FRACCION, 
	                      dbo.PEDIMPDET.PID_POR_DEF, dbo.PEDIMPDET.PID_DEF_TIP, dbo.SECTOR.SE_CLAVE, dbo.SPI.SPI_CLAVE, 
	                      dbo.PEDIMPDET.MA_CODIGO, dbo.PEDIMPDET.TI_CODIGO, dbo.PEDIMPDET.PID_NOPARTE, dbo.PEDIMP.PI_FEC_ENT, dbo.PEDIMP.PI_FEC_PAG, dbo.PEDIMP.PI_CODIGO
	HAVING    (SUM(dbo.VINVENTARIOKARSUM.KAP_CANTDESC) > 0)


/* Con este cursor se hace una agrupacion de la tabla INVENTARIOTempFecha y se inserta en la tabla INVENTARIOTEMP */

		insert into INVENTARIOTEMP (NoPedimento,  FechaPedimento, FechaPagoPedimento,  PID_saldoCANT, ME_CORTO, 
	PID_SALDOGEN, ME_GEN, PID_COS_UNI, AR_FRACCION, PID_POR_DEF, MA_CODIGO, SE_CLAVE, SPI_CLAVE, TI_CODIGO, 
	PID_NOPARTE, PID_DEF_TIP, PI_CODIGO)

		select NoPedimento,  FechaPedimento, FechaPagoPedimento,  round(sum(PID_saldoCANT),6), ME_CORTO, 
		round(sum(PID_SALDOGEN),6), ME_GEN, max(PID_COS_UNI), AR_FRACCION, PID_POR_DEF, MA_CODIGO, SE_CLAVE, SPI_CLAVE, TI_CODIGO, 
		PID_NOPARTE, PID_DEF_TIP, PI_CODIGO
		from INVENTARIOTempFecha
		group by NoPedimento,  FechaPedimento, FechaPagoPedimento,  ME_CORTO, 
		ME_GEN, AR_FRACCION, PID_POR_DEF, MA_CODIGO, SE_CLAVE, SPI_CLAVE, TI_CODIGO, 
		PID_NOPARTE, PID_DEF_TIP, PI_CODIGO
		order by MA_CODIGO, FechaPedimento
GO
