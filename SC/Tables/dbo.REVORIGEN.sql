SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[REVORIGEN] (
		[FI_CODIGO]            [int] NOT NULL,
		[RVF_DESPACHO]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[RVF_FECHACRUCE]       [datetime] NULL,
		[RVF_HORACRUCE]        [datetime] NULL,
		[RVF_HORADOC]          [datetime] NULL,
		[CP_CODIGO]            [int] NULL,
		[RVF_HORADESPACHO]     [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[REVORIGEN]
	ADD
	CONSTRAINT [PK_REVORIGEN]
	PRIMARY KEY
	NONCLUSTERED
	([FI_CODIGO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[REVORIGEN]
	ADD
	CONSTRAINT [DF_REVORIGEN_RVF_DESPACHO]
	DEFAULT ('V') FOR [RVF_DESPACHO]
GO
