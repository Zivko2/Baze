SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Descargas] (
		[PatenteImportacion]                            [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PedimentoImportacion]                          [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AduanaImportacion]                             [varchar](11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ClaveDocumentoImportacion]                     [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[SecuenciaImportacion]                          [int] NULL,
		[FechaEntradaImportacion]                       [datetime] NULL,
		[FechaVencimientoImportacion]                   [datetime] NULL,
		[NoParteImportacion]                            [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NoParteAuxiliarImportacion]                    [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NoParteGrupoGenericoImportacion]               [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DescripcionEspanolImportacion]                 [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DescripcionInglesImportacion]                  [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FraccionImportacion]                           [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[UnidadMedidaImportacion]                       [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TipoMaterialImportacion]                       [varchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[SaldoInicialImportacion]                       [decimal](38, 6) NULL,
		[SaldoFinalImportacion]                         [decimal](38, 6) NULL,
		[FacturaExportacion]                            [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PatenteExportacion]                            [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PedimentoExportacion]                          [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AduanaExportacion]                             [varchar](11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ClaveDocumentoExportacion]                     [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[SecuenciaExportacion]                          [int] NULL,
		[FechaEntradaExportacion]                       [datetime] NULL,
		[NoParteExportacion]                            [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NoParteAuxiliarExportacion]                    [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NoParteGrupoGenericoExportacion]               [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DescripcionEspanolExportacion]                 [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DescripcionInglesExportacion]                  [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FraccionExportacion]                           [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[UnidadMedidaExportacion]                       [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TipoMaterialExportacion]                       [varchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[SaldoRequeridoExportacion]                     [decimal](38, 6) NULL,
		[SaldoDescargadoExportacion]                    [decimal](38, 6) NULL,
		[SaldoFaltanteExportacion]                      [decimal](38, 6) NULL,
		[NoParteComponenteExportacion]                  [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NoParteComponenteAuxiliarExportacion]          [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NoParteComponenteGrupoGenericoExportacion]     [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DescripcionEspanolComponenteExportacion]       [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DescripcionInglesComponenteExportacion]        [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FraccionComponenteExportacion]                 [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[UnidadMedidaComponenteExportacion]             [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TipoMaterialComponenteExportacion]             [varchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FechaFacturaExportacion]                       [datetime] NULL,
		[CodigoDescarga]                                [int] NOT NULL,
		[CodigoFactura]                                 [int] NULL,
		[CodigoDetalleFactura]                          [int] NULL,
		[CodigoDetallePedimento]                        [int] NULL,
		[CodigoComponente]                              [int] NULL,
		[EstatusDescargaComponente]                     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TipoDescargaDetalle]                           [char](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CodigoComponentePadre]                         [int] NULL,
		[ContEstatus]                                   [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FisComp]                                       [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PadreMain]                                     [int] NULL,
		[CantidadDetalleExportacion]                    [decimal](38, 6) NULL,
		[CodigoParteDetalleExportacion]                 [int] NULL
) ON [PRIMARY]
GO
