SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RELCLAVEPEDREG] (
		[CP_CODIGO]          [smallint] NOT NULL,
		[REG_CODIGO]         [smallint] NOT NULL,
		[REL_DEFAULT]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[REL_MOVIMIENTO]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RELCLAVEPEDREG]
	ADD
	CONSTRAINT [PK_RELCLAVEPEDREG]
	PRIMARY KEY
	NONCLUSTERED
	([CP_CODIGO], [REG_CODIGO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[RELCLAVEPEDREG]
	ADD
	CONSTRAINT [DF_RELCLAVEPEDREG_REL_DEFAULT]
	DEFAULT ('N') FOR [REL_DEFAULT]
GO
ALTER TABLE [dbo].[RELCLAVEPEDREG]
	ADD
	CONSTRAINT [DF_RELCLAVEPEDREG_REL_MOVIMIENTO]
	DEFAULT ('A') FOR [REL_MOVIMIENTO]
GO