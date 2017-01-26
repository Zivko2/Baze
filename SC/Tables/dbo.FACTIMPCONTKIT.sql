SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FACTIMPCONTKIT] (
		[FIK_CODIGO]      [int] IDENTITY(1, 1) NOT NULL,
		[FID_INDICED]     [int] NOT NULL,
		[MA_CODIGO]       [int] NOT NULL,
		[FIK_MARCA]       [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FIK_MODELO]      [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FIK_SERIE]       [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		CONSTRAINT [IX_FACTIMPCONTKIT]
		UNIQUE
		NONCLUSTERED
		([FIK_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FACTIMPCONTKIT]
	ADD
	CONSTRAINT [PK_FACTIMPCONTKIT]
	PRIMARY KEY
	NONCLUSTERED
	([FID_INDICED], [MA_CODIGO], [FIK_MARCA], [FIK_MODELO], [FIK_SERIE])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[FACTIMPCONTKIT]
	ADD
	CONSTRAINT [DF_FACTIMPCONTKIT_FIK_MARCA]
	DEFAULT ('') FOR [FIK_MARCA]
GO
ALTER TABLE [dbo].[FACTIMPCONTKIT]
	ADD
	CONSTRAINT [DF_FACTIMPCONTKIT_FIK_MODELO]
	DEFAULT ('') FOR [FIK_MODELO]
GO
ALTER TABLE [dbo].[FACTIMPCONTKIT]
	ADD
	CONSTRAINT [DF_FACTIMPCONTKIT_FIK_SERIE]
	DEFAULT ('') FOR [FIK_SERIE]
GO
