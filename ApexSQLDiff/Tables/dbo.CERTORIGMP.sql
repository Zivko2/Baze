SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CERTORIGMP] (
		[CMP_CODIGO]          [int] NOT NULL,
		[CMP_IFECHA]          [datetime] NOT NULL,
		[CMP_VFECHA]          [datetime] NOT NULL,
		[PR_CODIGO]           [int] NOT NULL,
		[DI_PROD]             [int] NULL,
		[CL_IMP]              [int] NOT NULL,
		[DI_IMP]              [int] NULL,
		[SPI_CODIGO]          [smallint] NOT NULL,
		[CMP_TIPO]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[US_CODIGO]           [smallint] NULL,
		[CMP_FOLIO]           [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CMP_FECHA]           [datetime] NULL,
		[CL_EXP]              [int] NULL,
		[DI_EXP]              [int] NULL,
		[CMP_AFFIDAVIT]       [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CMP_DECLARAPROD]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CMP_OBSERVA]         [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CMP_FECHATRANS]      [datetime] NULL,
		[CMP_MODIFICABLE]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CMP_ESTATUS]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		CONSTRAINT [IX_CERTORIGMP]
		UNIQUE
		NONCLUSTERED
		([CMP_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CERTORIGMP]
	ADD
	CONSTRAINT [PK_CERTORIGMP]
	PRIMARY KEY
	NONCLUSTERED
	([CMP_IFECHA], [CMP_VFECHA], [PR_CODIGO], [CL_IMP], [CMP_TIPO], [CMP_FOLIO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[CERTORIGMP]
	ADD
	CONSTRAINT [DF_CERTORIGMP_CMP_AFFIDAVIT]
	DEFAULT ('N') FOR [CMP_AFFIDAVIT]
GO
ALTER TABLE [dbo].[CERTORIGMP]
	ADD
	CONSTRAINT [DF_CERTORIGMP_CMP_DECLARAPROD]
	DEFAULT ('N') FOR [CMP_DECLARAPROD]
GO
ALTER TABLE [dbo].[CERTORIGMP]
	ADD
	CONSTRAINT [DF_CERTORIGMP_CMP_ESTATUS]
	DEFAULT ('V') FOR [CMP_ESTATUS]
GO
ALTER TABLE [dbo].[CERTORIGMP]
	ADD
	CONSTRAINT [DF_CERTORIGMP_CMP_MODIFICABLE]
	DEFAULT ('S') FOR [CMP_MODIFICABLE]
GO
ALTER TABLE [dbo].[CERTORIGMP]
	ADD
	CONSTRAINT [DF_CERTORIGMP_CMP_TIPO]
	DEFAULT ('P') FOR [CMP_TIPO]
GO
ALTER TABLE [dbo].[CERTORIGMP]
	ADD
	CONSTRAINT [DF_CERTORIGMP_PR_CODIGO]
	DEFAULT (1) FOR [PR_CODIGO]
GO
ALTER TABLE [dbo].[CERTORIGMP]
	ADD
	CONSTRAINT [DF_CERTORIGMP_SPI_CODIGO]
	DEFAULT (22) FOR [SPI_CODIGO]
GO
ALTER TABLE [dbo].[CERTORIGMP] SET (LOCK_ESCALATION = TABLE)
GO
