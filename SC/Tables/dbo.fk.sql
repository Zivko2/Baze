SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[fk] (
		[fk_cuenta]     [int] NOT NULL,
		[tabla]         [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fk]
	ADD
	CONSTRAINT [DF_fk_fk_cuenta]
	DEFAULT (0) FOR [fk_cuenta]
GO
