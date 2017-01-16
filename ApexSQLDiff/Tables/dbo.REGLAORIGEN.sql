SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[REGLAORIGEN] (
		[ARR_CODIGO]         [int] NOT NULL,
		[SPI_CODIGO]         [int] NOT NULL,
		[ARR_PARTIDAPT]      [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ARR_PARTIDAPTF]     [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ARR_VTMINIMO]       [decimal](38, 6) NULL,
		[ARR_CNMINIMO]       [decimal](38, 6) NULL,
		[ARR_SALTOARA]       [decimal](38, 6) NULL,
		[ARR_MINIMIS]        [decimal](38, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[REGLAORIGEN]
	ADD
	CONSTRAINT [PK_REGLAORIGEN]
	PRIMARY KEY
	NONCLUSTERED
	([SPI_CODIGO], [ARR_PARTIDAPT])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[REGLAORIGEN]
	ADD
	CONSTRAINT [DF_REGLAORIGEN_ARR_PARTIDAPTF]
	DEFAULT ('0') FOR [ARR_PARTIDAPTF]
GO
ALTER TABLE [dbo].[REGLAORIGEN]
	ADD
	CONSTRAINT [DF_REGLAORIGEN_SPI_CODIGO]
	DEFAULT (22) FOR [SPI_CODIGO]
GO
ALTER TABLE [dbo].[REGLAORIGEN] SET (LOCK_ESCALATION = TABLE)
GO
