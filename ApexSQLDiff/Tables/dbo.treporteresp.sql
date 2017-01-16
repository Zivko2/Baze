SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[treporteresp] (
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
ALTER TABLE [dbo].[treporteresp] SET (LOCK_ESCALATION = TABLE)
GO
