SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ARANCELENTRY] (
		[ARE_CODIGO]          [int] NOT NULL,
		[AR_CODIGO]           [int] NOT NULL,
		[PA_CODIGO]           [int] NOT NULL,
		[ARE_MPF]             [decimal](38, 6) NULL,
		[ARE_MPFNOTLC]        [decimal](38, 6) NULL,
		[ARE_ADACVD_CASE]     [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ARE_ADACVD_RATE]     [decimal](38, 6) NULL,
		[ARE_IRC_RATE]        [decimal](38, 6) NULL,
		[ARE_VISA]            [decimal](38, 6) NULL,
		[ARE_DESCRIPCC]       [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_ARANCELENTRY]
		UNIQUE
		NONCLUSTERED
		([ARE_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ARANCELENTRY]
	ADD
	CONSTRAINT [PK_ARANCELENTRY]
	PRIMARY KEY
	NONCLUSTERED
	([AR_CODIGO], [PA_CODIGO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[ARANCELENTRY]
	ADD
	CONSTRAINT [DF_ARANCELENTRY_ARE_ADACVD_RATE]
	DEFAULT (0) FOR [ARE_ADACVD_RATE]
GO
ALTER TABLE [dbo].[ARANCELENTRY]
	ADD
	CONSTRAINT [DF_ARANCELENTRY_ARE_IRC_RATE]
	DEFAULT (0) FOR [ARE_IRC_RATE]
GO
ALTER TABLE [dbo].[ARANCELENTRY]
	ADD
	CONSTRAINT [DF_ARANCELENTRY_ARE_MPF]
	DEFAULT (0) FOR [ARE_MPF]
GO
ALTER TABLE [dbo].[ARANCELENTRY]
	ADD
	CONSTRAINT [DF_ARANCELENTRY_ARE_MPFNOTLC]
	DEFAULT (0) FOR [ARE_MPFNOTLC]
GO
ALTER TABLE [dbo].[ARANCELENTRY]
	ADD
	CONSTRAINT [DF_ARANCELENTRY_ARE_VISA]
	DEFAULT (0) FOR [ARE_VISA]
GO
ALTER TABLE [dbo].[ARANCELENTRY]
	ADD
	CONSTRAINT [DF_ARANCELENTRY_PA_CODIGO]
	DEFAULT (0) FOR [PA_CODIGO]
GO
ALTER TABLE [dbo].[ARANCELENTRY] SET (LOCK_ESCALATION = TABLE)
GO
