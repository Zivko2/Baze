SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[OMISION] (
		[EM_CODIGO]         [int] NOT NULL,
		[OM_TIPO]           [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TF_CODIGO]         [smallint] NOT NULL,
		[TQ_CODIGO]         [smallint] NOT NULL,
		[AG_MEX]            [smallint] NULL,
		[AG_USA]            [smallint] NULL,
		[PR_CODIGO]         [int] NULL,
		[CL_PROD]           [int] NULL,
		[CL_EXP]            [int] NULL,
		[CL_DESTFIN]        [int] NULL,
		[CL_COMPFIN]        [int] NULL,
		[CL_EXPFIN]         [int] NULL,
		[CL_DESTINI]        [int] NULL,
		[CL_VEND]           [int] NULL,
		[CL_IMP]            [int] NULL,
		[CL_IMPFIN]         [int] NULL,
		[CL_COMP]           [int] NULL,
		[PU_SALIDA]         [int] NULL,
		[PU_DESTINO]        [int] NULL,
		[PU_ENTRADA]        [int] NULL,
		[PU_CARGA]          [int] NULL,
		[OM_CATPROD]        [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OM_CATEXP]         [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OM_CATCOMPFIN]     [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OM_CATEXPFIN]      [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OM_CATDESTINI]     [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OM_CATDESTFIN]     [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OM_CATVEND]        [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OM_CATIMP]         [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OM_CATIMPFIN]      [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OM_CATCOMP]        [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OM_CATPROVEE]      [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OM_SCPROD]         [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OM_SCEXP]          [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OM_SCCOMPFIN]      [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OM_SCEXPFIN]       [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OM_SCDESTINI]      [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OM_SCDESTFIN]      [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OM_SCVEND]         [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OM_SCIMP]          [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OM_SCIMPFIN]       [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OM_SCCOMP]         [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OM_SCPROVEE]       [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OMISION]
	ADD
	CONSTRAINT [PK_OMISION]
	PRIMARY KEY
	NONCLUSTERED
	([EM_CODIGO], [OM_TIPO], [TF_CODIGO], [TQ_CODIGO])
	ON [PRIMARY]
GO
