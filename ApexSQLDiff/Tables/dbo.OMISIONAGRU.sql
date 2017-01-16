SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[OMISIONAGRU] (
		[EM_CODIGO]          [int] NOT NULL,
		[OMA_TIPOAGRU]       [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TF_CODIGO]          [smallint] NOT NULL,
		[TQ_CODIGO]          [smallint] NOT NULL,
		[AG_MEX]             [smallint] NULL,
		[AG_USA]             [smallint] NULL,
		[PR_CODIGO]          [int] NULL,
		[FE_DESTINO]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_PROD]            [int] NULL,
		[CL_EXP]             [int] NULL,
		[CL_DESTFIN]         [int] NULL,
		[CL_COMPFIN]         [int] NULL,
		[CL_EXPFIN]          [int] NULL,
		[CL_DESTINI]         [int] NULL,
		[CL_VEND]            [int] NULL,
		[CL_IMP]             [int] NULL,
		[CL_IMPFIN]          [int] NULL,
		[CL_COMP]            [int] NULL,
		[PU_SALIDA]          [int] NULL,
		[PU_DESTINO]         [int] NULL,
		[PU_ENTRADA]         [int] NULL,
		[PU_CARGA]           [int] NULL,
		[OMA_CATPROD]        [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OMA_CATEXP]         [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OMA_CATCOMPFIN]     [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OMA_CATEXPFIN]      [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OMA_CATDESTINI]     [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OMA_CATVEND]        [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OMA_CATIMPFIN]      [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OMA_CATCOMP]        [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OMA_CATPROVEE]      [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OMA_CATDESTFIN]     [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OMA_CATIMP]         [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OMA_SCPROD]         [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OMA_SCEXP]          [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OMA_SCCOMPFIN]      [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OMA_SCEXPFIN]       [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OMA_SCDESTINI]      [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OMA_SCVEND]         [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OMA_SCIMPFIN]       [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OMA_SCCOMP]         [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OMA_SCPROVEE]       [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OMA_SCDESTFIN]      [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OMA_SCIMP]          [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OMISIONAGRU]
	ADD
	CONSTRAINT [PK_OMISIONAGRU]
	PRIMARY KEY
	NONCLUSTERED
	([EM_CODIGO], [OMA_TIPOAGRU], [TF_CODIGO], [TQ_CODIGO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[OMISIONAGRU] SET (LOCK_ESCALATION = TABLE)
GO
