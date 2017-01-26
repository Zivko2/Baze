SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PERSONAL] (
		[US_CODIGO]             [smallint] IDENTITY(1, 1) NOT NULL,
		[US_NOMBRE]             [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[US_PATERNO]            [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[US_MATERNO]            [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PO_CODIGO]             [int] NOT NULL,
		[DP_CODIGO]             [smallint] NOT NULL,
		[US_TEL]                [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[US_EXT]                [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[US_FAX]                [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[US_CELULAR]            [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[US_RADIOLOCALIZA]      [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[US_RFC]                [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[US_CURP]               [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[US_EMAIL]              [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[US_DIRECCION]          [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[US_FECHANAC]           [datetime] NULL,
		[US_PORCENCOMISION]     [decimal](38, 6) NULL,
		[UT_CODIGO]             [smallint] NULL,
		[US_PASSWORDPO]         [varchar](16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[US_FIRMA]              [image] NULL,
		[SYSUSRLST_ID]          [int] NULL,
		[TUR_CODIGO]            [smallint] NULL,
		CONSTRAINT [IX_PERSONAL]
		UNIQUE
		NONCLUSTERED
		([US_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[PERSONAL]
	ADD
	CONSTRAINT [PK_PERSONAL]
	PRIMARY KEY
	NONCLUSTERED
	([US_NOMBRE], [US_PATERNO], [US_MATERNO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[PERSONAL]
	ADD
	CONSTRAINT [DF_PERSONAL_US_EXT]
	DEFAULT ('') FOR [US_EXT]
GO
ALTER TABLE [dbo].[PERSONAL]
	ADD
	CONSTRAINT [DF_PERSONAL_US_FAX]
	DEFAULT ('') FOR [US_FAX]
GO
ALTER TABLE [dbo].[PERSONAL]
	ADD
	CONSTRAINT [DF_PERSONAL_US_MATERNO]
	DEFAULT ('') FOR [US_MATERNO]
GO
ALTER TABLE [dbo].[PERSONAL]
	ADD
	CONSTRAINT [DF_PERSONAL_US_RFC]
	DEFAULT ('') FOR [US_RFC]
GO
