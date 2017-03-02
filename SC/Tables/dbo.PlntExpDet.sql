SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PlntExpDet] (
		[PXP_CODIGO]       [int] NOT NULL,
		[PXT_TBLNAME]      [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PXT_SELECTED]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PlntExpDet]
	ADD
	CONSTRAINT [PK_PlntExpDet]
	PRIMARY KEY
	CLUSTERED
	([PXP_CODIGO], [PXT_TBLNAME])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[PlntExpDet]
	ADD
	CONSTRAINT [DF_PlntExpDet_PXT_SELECTED]
	DEFAULT ('N') FOR [PXT_SELECTED]
GO