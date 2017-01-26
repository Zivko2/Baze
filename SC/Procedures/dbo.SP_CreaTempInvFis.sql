SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_CreaTempInvFis] (@FechaInv varchar(11))   as

		exec sp_droptable 'TempInvFis'
	CREATE TABLE [dbo].[TempInvFis] (
		[Codigo] [int] IDENTITY (1, 1) NOT NULL ,
		[Linea] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[NoCatalogo] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Descripcion] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[UMInv] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[UMCom] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[UMAlm] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Cantidad] decimal(38,6) NULL ,
		[CantidadInvFis] decimal(38,6) NULL ,
		[DifAmapsVSFis] decimal(38,6) NULL ,
		[ValorDifAmapsVSFis] decimal(38,6) NULL ,
		[CostoStd] decimal(38,6) NULL ,
		[FechaUltCompra] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[CantUltCompra] decimal(38,6) NULL ,
		[Proveedor] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NombreProveedor] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[ValorAmaps] decimal(38,6) NULL ,
		[AMU] [int] NULL ,
		[Clasificacion] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_TempInvFis] UNIQUE  NONCLUSTERED 
		(
			[Codigo]
		) WITH  FILLFACTOR = 90  ON [PRIMARY] 
	) ON [PRIMARY]



	exec sp_droptable 'TempTotInventario'
	CREATE TABLE [dbo].[TempTotInventario] (
		[Codigo] [int] IDENTITY (1, 1) NOT NULL ,
		[Linea] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[NoCatalogo] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Descripcion] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[UMInv] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[UMCom] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[UMAlm] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Cantidad] decimal(38,6) NULL ,
		[CantidadInvFis] decimal(38,6) NULL ,
		[DifAmapsVSFis] decimal(38,6) NULL ,
		[ValorDifAmapsVSFis] decimal(38,6) NULL ,
		[CostoStd] decimal(38,6) NULL ,
		[FechaUltCompra] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[CantUltCompra] decimal(38,6) NULL ,
		[Proveedor] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NombreProveedor] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[ValorAmaps] decimal(38,6) NULL ,
		[AMU] [int] NULL ,
		[Clasificacion] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,

		[NoCatalogoInTrade] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[DescripcionInTrade] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[CantidadSaldoInTrade] decimal(38,6) NULL ,
		[CantidadOrigInTrade] decimal(38,6) NULL ,
		[ValorSaldoInTrade] decimal(38,6) NULL ,
		[ValorOrigInTrade] decimal(38,6) NULL ,
		[FechaEntradaInTrade] [Datetime] NULL ,
		[CantidadMaqInTrade] decimal(38,6) NULL ,
		[UMInTrade] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[CostoUnitDlsInTrade] decimal(38,6) NULL ,
		[FArancelariaInTrade] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[FechaVencCertOrig] [Datetime] NULL ,
		[FechaEntradCertOrig] [Datetime] NULL ,
		[TasaGral] decimal(38,6) NULL ,
		[TasaTLCAN] decimal(38,6) NULL ,
		[Tipo] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Diferencia] decimal(38,6) NULL ,
		[DiferenciaValor] decimal(38,6) NULL ,
		[TipoDif] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[TipoProvee] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		CONSTRAINT [IX_TempTotInventario] UNIQUE  NONCLUSTERED 
		(
			[Codigo]
		) WITH  FILLFACTOR = 90  ON [PRIMARY] 
	) ON [PRIMARY]


	exec('exec sp_droptable ''VInvFisInTrade'', ''V''')


		exec ('CREATE VIEW dbo.VInvFisInTrade
	as
	SELECT PEDIMPDET.PID_NOPARTE, MAX(PEDIMPDET.PID_NOMBRE) PID_NOMBRE, ROUND(SUM(PIDescarga.PID_SALDOGEN / PEDIMPDET.EQ_GENERICO), 6) as CantidadSaldoInTrade, 
	      ROUND(SUM(PEDIMPDET.PID_CAN_GEN / PEDIMPDET.EQ_GENERICO), 6) as CantidadOrigInTrade, 
	      SUM(PEDIMPDET.PID_CTOT_DLS) as ValorOrigInTrade, 
	       MAX(MEDIDA.ME_CORTO) AS UMInTrade, SUM(PIDescarga.PID_SALDOGEN * PEDIMPDET.PID_COS_UNIGEN * PEDIMPDET.EQ_GENERICO) as ValorSaldoInTrade, MAX(PIDescarga.PI_FEC_ENT) FechaEntradaInTrade,
	      MAX(ARANCEL.AR_FRACCION) AS FArancelariaInTrade
	FROM   PIDescarga INNER JOIN 
	       PEDIMPDET ON PIDescarga.PID_INDICED = PEDIMPDET.PID_INDICED INNER JOIN 
	       MEDIDA ON PEDIMPDET.ME_CODIGO = MEDIDA.ME_CODIGO LEFT OUTER JOIN ARANCEL
                    ON PEDIMPDET.AR_IMPMX = ARANCEL.AR_CODIGO 
	WHERE (PIDescarga.PI_ACTIVOFIJO = ''N'') AND 
	      (PIDescarga.PI_FEC_ENT <='''+@FechaInv+''') AND (PIDescarga.PID_SALDOGEN > 0) 
	GROUP BY PEDIMPDET.PID_NOPARTE')

	exec sp_droptable 'TempInvFisCierre'
	CREATE TABLE [dbo].[TempInvFisCierre] (
		[Codigo] [int] IDENTITY (1, 1) NOT NULL ,
		[Concepto1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Concepto2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[ValorCosto] decimal(38,6) NULL ,
		[ValorCant] decimal(38,6) NULL ,
		CONSTRAINT [IX_TempInvFisCierre] UNIQUE  NONCLUSTERED 
		(
			[Codigo]
		) WITH  FILLFACTOR = 90  ON [PRIMARY] 
	) ON [PRIMARY]


-- CONCEPTOS CIERRE

	insert into TempInvFisCierre(Concepto2)
	values('Saldo INTRADE')
	
	insert into TempInvFisCierre(Concepto2)
	values( '   ')
	
	insert into TempInvFisCierre(Concepto1, Concepto2)
	values('Menos:', 'Partidas no en AMAPS')
	
	insert into TempInvFisCierre(Concepto1, Concepto2)
	values('( F4 )', '-NE Error de captura')

	insert into TempInvFisCierre(Concepto2)
	values('-NE Manufacturados')
	
	insert into TempInvFisCierre(Concepto2)
	values('-NE Gastos')
	
	insert into TempInvFisCierre(Concepto2)
	values('-NE Kits')
	
	insert into TempInvFisCierre(Concepto2)
	values('-NE PT')
	
	insert into TempInvFisCierre(Concepto2)
	values('-NE Imp')
	
	insert into TempInvFisCierre(Concepto2)
	values('-NE Nal')
	
	insert into TempInvFisCierre(Concepto2)
	values( '-Nacional (sobrante)')
	
	insert into TempInvFisCierre(Concepto2)
	values( '-Nacional Obsoletos (sobrante)')
	
	insert into TempInvFisCierre(Concepto2)
	values( '-Importados (sobrante) Dif en costo')
	
	insert into TempInvFisCierre(Concepto2)
	values( '-Importados (sobrante) Obsoleto')
	
	insert into TempInvFisCierre(Concepto2)
	values( '-Importados (sobrante) Fabricados')
	
	insert into TempInvFisCierre(Concepto2)
	values( '-Importados (sobrante)')
	
	insert into TempInvFisCierre(Concepto2)
	values( '   ')
	
	insert into TempInvFisCierre(Concepto1, Concepto2)
	values('Mas:', 'Partidas no en INTRADE')
	
	insert into TempInvFisCierre(Concepto1, Concepto2)
	values('( A3 )', '-NA Importados')
	
	insert into TempInvFisCierre(Concepto2)
	values( '-NA Nacional')
	
	insert into TempInvFisCierre(Concepto2)
	values( '-NA Obsoletos')
	
	insert into TempInvFisCierre(Concepto2)
	values( '-NA Definitivos')
	
	insert into TempInvFisCierre(Concepto2)
	values( '-NA Ami Doduco')
	
	insert into TempInvFisCierre(Concepto2)
	values( '-NA Sin movimientos')
	
	insert into TempInvFisCierre(Concepto2)
	values( '-Nacional (Faltante)')
	
	insert into TempInvFisCierre(Concepto2)
	values( '-Nacional obsoleto (Faltante)')
	
	insert into TempInvFisCierre(Concepto2)
	values( '-Importados (faltante) Dif en costo')
	
	insert into TempInvFisCierre(Concepto2)
	values( '-Importados (faltante) Gastos')
	
	insert into TempInvFisCierre(Concepto2)
	values( '-Importados (faltante) Fabricados')
	
	insert into TempInvFisCierre(Concepto2)
	values( '-Importados (Faltante) Obsoleto')
	
	insert into TempInvFisCierre(Concepto2)
	values( '-Importados (Faltante)')
	
	
	insert into TempInvFisCierre(Concepto2)
	values( '   ')
	
	insert into TempInvFisCierre(Concepto2)
	values( 'Saldo AMAPS')


GO
