SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PCKLIST] (
		[PL_CODIGO]          [int] NOT NULL,
		[PL_FOLIO]           [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TF_CODIGO]          [smallint] NOT NULL,
		[TQ_CODIGO]          [smallint] NOT NULL,
		[PL_FECHA]           [datetime] NOT NULL,
		[PL_HORA]            [datetime] NULL,
		[PR_CODIGO]          [int] NOT NULL,
		[DI_CODIGO]          [int] NULL,
		[PL_SEM]             [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[US_CODIGO]          [smallint] NULL,
		[PL_COMENTA]         [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PL_TOTALB]          [decimal](38, 6) NULL,
		[PL_ESTATUS]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CP_CODIGO]          [smallint] NULL,
		[CL_DESTFIN]         [int] NULL,
		[DI_DESTFIN]         [int] NULL,
		[CL_IMP]             [int] NULL,
		[DI_IMP]             [int] NULL,
		[CT_CODIGO]          [int] NULL,
		[PL_CTRLADD]         [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PL_RECIBIDO]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PL_PDOCUMEN]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PL_TRANSNOORIG]     [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PL_TRANSNO]         [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PL_TRAC_MX]         [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[RU_CODIGO]          [smallint] NULL,
		[PL_CONT_REG]        [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_PCKLIST]
		UNIQUE
		NONCLUSTERED
		([PL_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PCKLIST]
	ADD
	CONSTRAINT [PK_PCKLIST]
	PRIMARY KEY
	NONCLUSTERED
	([PL_FOLIO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[PCKLIST]
	ADD
	CONSTRAINT [DF_PCKLIST_PL_ESTATUS]
	DEFAULT ('A') FOR [PL_ESTATUS]
GO
ALTER TABLE [dbo].[PCKLIST]
	ADD
	CONSTRAINT [DF_PCKLIST_PL_PDOCUMEN]
	DEFAULT ('N') FOR [PL_PDOCUMEN]
GO
ALTER TABLE [dbo].[PCKLIST]
	ADD
	CONSTRAINT [DF_PCKLIST_PL_RECIBIDO]
	DEFAULT ('N') FOR [PL_RECIBIDO]
GO
CREATE CLUSTERED INDEX [IX_PCKLIST_1]
	ON [dbo].[PCKLIST] ([PL_CODIGO], [PL_FOLIO])
	ON [PRIMARY]
GO
