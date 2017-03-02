SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TREPORTE] (
		[TRE_CODIGO]            [int] NOT NULL,
		[TRE_NOMBRE]            [varchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TRE_RUTA]              [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TRE_NOMBRE_RTM]        [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TRE_FRMTAG]            [int] NULL,
		[TRE_LOOKUPFLD]         [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TRE_LookUpFldDT]       [int] NULL,
		[TRE_LOOKUPTBL]         [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TRE_Field2Relate]      [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TRE_Field2Show]        [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TRE_Fld2ShowDType]     [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TRE_Field2ShowTbl]     [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TRE_LABELFIELD]        [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TRE_CampoEtiqueta]     [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TRE_ReporteClasif]     [int] NULL,
		[TRE_ORDEN]             [smallint] NULL,
		[TRE_PARAMETRO]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TRE_DESCARGA]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TRE_DELUSUARIO]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TRE_NAME]              [varchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TRE_QRYPARAMSQL]       [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TRE_MASUSADO]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TRE_PROCANTES]         [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TRE_MULTIPLEVALOR]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TREPORTE]
	ADD
	CONSTRAINT [PK_TREPORTE]
	PRIMARY KEY
	NONCLUSTERED
	([TRE_NOMBRE], [TRE_NOMBRE_RTM], [TRE_LOOKUPFLD], [TRE_LOOKUPTBL])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[TREPORTE]
	ADD
	CONSTRAINT [DF_TREPORTE_TRE_DELUSUARIO]
	DEFAULT ('S') FOR [TRE_DELUSUARIO]
GO
ALTER TABLE [dbo].[TREPORTE]
	ADD
	CONSTRAINT [DF_TREPORTE_TRE_DESCARGA]
	DEFAULT ('A') FOR [TRE_DESCARGA]
GO
ALTER TABLE [dbo].[TREPORTE]
	ADD
	CONSTRAINT [DF_TREPORTE_TRE_MASUSADO]
	DEFAULT ('N') FOR [TRE_MASUSADO]
GO
ALTER TABLE [dbo].[TREPORTE]
	ADD
	CONSTRAINT [DF_TREPORTE_TRE_MULTIPLEVALOR]
	DEFAULT ('N') FOR [TRE_MULTIPLEVALOR]
GO
ALTER TABLE [dbo].[TREPORTE]
	ADD
	CONSTRAINT [DF_TREPORTE_TRE_PARAMETRO]
	DEFAULT ('S') FOR [TRE_PARAMETRO]
GO