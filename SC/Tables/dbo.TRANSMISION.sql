SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TRANSMISION] (
		[TRM_CODIGO]             [int] NOT NULL,
		[TRM_RECORDID]           [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TRM_FECHA]              [datetime] NULL,
		[CL_CODIGO]              [int] NULL,
		[TRM_TMOVIMIENTO]        [smallint] NULL,
		[CP_CODIGO]              [int] NULL,
		[AGC_CODIGO]             [int] NULL,
		[TRM_TIPO]               [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TRM_TIPOSAAI]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TRM_PREVIOCONS]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TRM_SAAI_CONS]          [int] NULL,
		[AGT_CODIGO]             [int] NULL,
		[VAL_CODIGO]             [int] NULL,
		[BAN_CODIGO]             [int] NULL,
		[TRM_ESTATUS]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TRM_FOLIOPED]           [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TRM_CONSECUTIVOPED]     [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TRANSMISION]
	ADD
	CONSTRAINT [PK_TRANSMISSION]
	PRIMARY KEY
	NONCLUSTERED
	([TRM_RECORDID])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[TRANSMISION]
	ADD
	CONSTRAINT [DF_TRANSMISION_CL_CODIGO]
	DEFAULT (1) FOR [CL_CODIGO]
GO
ALTER TABLE [dbo].[TRANSMISION]
	ADD
	CONSTRAINT [DF_TRANSMISION_TRM_PREVIOCONS]
	DEFAULT ('F') FOR [TRM_PREVIOCONS]
GO
ALTER TABLE [dbo].[TRANSMISION]
	ADD
	CONSTRAINT [DF_TRANSMISION_TRM_TIPO]
	DEFAULT ('X') FOR [TRM_TIPO]
GO
ALTER TABLE [dbo].[TRANSMISION]
	ADD
	CONSTRAINT [DF_TRANSMISION_TRM_TIPOSAAI]
	DEFAULT ('1') FOR [TRM_TIPOSAAI]
GO
