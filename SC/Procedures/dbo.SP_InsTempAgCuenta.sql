SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE dbo.SP_InsTempAgCuenta
		(		
		@vPatenteAgente varchar(4),
		@vAduana varchar(4),
		@vReferencia varchar(10),
		@vPedimento varchar(10),
		@vFechaPedimento varchar(20),
		@fTipoCambio decimal(38,6),
		@vClavePedimento varchar(2),
		@vPaisVendComp varchar(5),
		@vPaisOrigDest varchar(5),
		@fPesoBruto decimal(38,6),
		@vTipoTransporte varchar(3),
		@fMonedaExtranjera decimal(38,6),
		@fPesosMexicanos decimal(38,6),
		@fIncrementablePMX decimal(38,6),
		@fValorAduana decimal(38,6),
		@fDTA decimal(38,6),
		@fPrevalidacion decimal(38,6),
		@fAdvalorem decimal(38,6),
		@fIVA decimal(38,6),
		@fIVAPrevalidacion decimal(38,6),
		@fFleteAereo decimal(38,6),
		@fIVAFleteAereo decimal(38,6),
		@fFleteTerrestre decimal(38,6),
		@fGastosXsuCuenta decimal(38,6),
		@fFletesPedimento decimal(38,6),
		@vProveedor varchar(27),
		@vFactura varchar(15),
		@vDestino varchar(3),
		@dtFechaCreacion  datetime,
		@vClasifImpExp varchar(3),
		@vConsContab varchar(8),
		@vIndicador  varchar(1)
)
AS
INSERT 		TempAgCuenta (PatenteAgente,
		Aduana,
		Referencia,
		Pedimento,
		FechaPedimento,
		TipoCambio,
		ClavePedimento,
		PaisVendComp,
		PaisOrigDest,
		PesoBruto,
		TipoTransporte,
		MonedaExtranjera,
		PesosMexicanos,
		IncrementablePMX,
		ValorAduana,
		DTA,
		Prevalidacion,
		Advalorem,
		IVA,
		IVAPrevalidacion,
		FleteAereo,
		IVAFleteAereo,
		FleteTerrestre,
		GastosXsuCuenta,
		FletesPedimento,
		Proveedor,
		Factura,
		Destino,
		FechaCreacion,
		ClasifImpExp,
		ConsContab,
		Indicador
)
VALUES
(
		@vPatenteAgente,
		@vAduana,
		@vReferencia,
		@vPedimento,
		@vFechaPedimento,
		@fTipoCambio,
		@vClavePedimento,
		@vPaisVendComp,
		@vPaisOrigDest,
		@fPesoBruto,
		@vTipoTransporte,
		@fMonedaExtranjera,
		@fPesosMexicanos,
		@fIncrementablePMX,
		@fValorAduana,
		@fDTA,
		@fPrevalidacion,
		@fAdvalorem,
		@fIVA,
		@fIVAPrevalidacion,
		@fFleteAereo,
		@fIVAFleteAereo,
		@fFleteTerrestre,
		@fGastosXsuCuenta,
		@fFletesPedimento,
		@vProveedor,
		@vFactura,
		@vDestino,
		@dtFechaCreacion,
		@vClasifImpExp,
		@vConsContab,
		@vIndicador
)





GO
