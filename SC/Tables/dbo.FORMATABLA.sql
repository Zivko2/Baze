SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FORMATABLA] (
		[FT_ID]            [int] NOT NULL,
		[FT_TABLA]         [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FT_IDDETALLE]     [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FORMATABLA]
	ADD
	CONSTRAINT [PK_FormaTabla]
	PRIMARY KEY
	NONCLUSTERED
	([FT_ID], [FT_IDDETALLE])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[FORMATABLA]
	ADD
	CONSTRAINT [DF_FormaTabla_FT_IdDetalle]
	DEFAULT (0) FOR [FT_IDDETALLE]
GO
CREATE NONCLUSTERED INDEX [IX_FormaTabla]
	ON [dbo].[FORMATABLA] ([FT_ID])
	ON [PRIMARY]
GO
