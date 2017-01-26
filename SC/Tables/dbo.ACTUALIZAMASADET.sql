SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ACTUALIZAMASADET] (
		[AM_CODIGO]            [int] NOT NULL,
		[AMD_ORDEN]            [int] NOT NULL,
		[AMD_PARAMNOMBRE]      [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[AMD_PARAMTYPE]        [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[AMD_TYPEOBJECT]       [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[AMD_FIELDNAME]        [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[AMD_TABLENAME]        [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[AMD_DISPLAYTABLE]     [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AMD_DISPLAYFIELD]     [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AMD_LINKFIELD]        [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ACTUALIZAMASADET]
	ADD
	CONSTRAINT [PK_ACTUALIZAMASADET]
	PRIMARY KEY
	NONCLUSTERED
	([AM_CODIGO], [AMD_ORDEN])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[ACTUALIZAMASADET]
	ADD
	CONSTRAINT [DF_ACTUALIZAMASADET_AMD_FIELDNAME]
	DEFAULT ('') FOR [AMD_FIELDNAME]
GO
