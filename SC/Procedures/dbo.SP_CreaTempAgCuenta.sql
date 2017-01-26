SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_CreaTempAgCuenta]   as

		exec sp_droptable 'TempAgCuenta'
	CREATE TABLE [dbo].[TempAgCuenta] (
		[Codigo] [int] IDENTITY (1, 1) NOT NULL ,
		PatenteAgente varchar(4) null,
		Aduana varchar(4) null,
		Referencia varchar(10) null,
		Pedimento varchar(10) null,
		FechaPedimento varchar(20) null,
		TipoCambio decimal(38,6) null,
		ClavePedimento varchar(2) null,
		PaisVendComp varchar(5) null,
		PaisOrigDest varchar(5) null,
		PesoBruto decimal(38,6) null,
		TipoTransporte varchar(3) null,
		MonedaExtranjera decimal(38,6) null,
		PesosMexicanos decimal(38,6) null,
		IncrementablePMX decimal(38,6) null,
		ValorAduana decimal(38,6) null,
		DTA decimal(38,6) null,
		Prevalidacion decimal(38,6) null,
		Advalorem decimal(38,6) null,
		IVA decimal(38,6) null,
		IVAPrevalidacion decimal(38,6) null,
		FleteAereo decimal(38,6) null,
		IVAFleteAereo decimal(38,6) null,
		FleteTerrestre decimal(38,6) null,
		GastosXsuCuenta decimal(38,6) null,
		FletesPedimento decimal(38,6) null,
		Proveedor varchar(27) null,
		Factura varchar(15) null,
		Destino varchar(3) null,
		FechaCreacion  datetime null,
		ClasifImpExp varchar(3) null,
		ConsContab varchar(8) null,
		Indicador  varchar(1) null,
		CONSTRAINT [IX_TempAgCuenta] UNIQUE  NONCLUSTERED 
		(
			[Codigo]
		) WITH  FILLFACTOR = 90  ON [PRIMARY] 
	) ON [PRIMARY]


	exec sp_droptable 'TempAgTotCuenta'
	CREATE TABLE [dbo].[TempAgTotCuenta] (
		[Codigo] [int] IDENTITY (1, 1) NOT NULL ,
		Pedimento varchar(10) null,
		PatenteAgente varchar(4) null,
		Aduana varchar(4) null,
		ClavePedimento varchar(2) null,
		FechaPedimento varchar(20) null,
		ValorAduana decimal(38,6) null,
		Advalorem decimal(38,6) null,
		IVA decimal(38,6) null,
		PesosMexicanos decimal(38,6) null,
		Texto varchar(20) null,
		CONSTRAINT [IX_TempAgTotCuenta] UNIQUE  NONCLUSTERED 
		(
			[Codigo]
		) WITH  FILLFACTOR = 90  ON [PRIMARY] 
	) ON [PRIMARY]











GO
