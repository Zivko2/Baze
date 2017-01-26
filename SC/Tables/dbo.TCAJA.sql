SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TCAJA] (
		[TCA_CODIGO]      [smallint] IDENTITY(1, 1) NOT NULL,
		[TCA_NOMBRE]      [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TCA_CLA_PED]     [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TCA_NAME]        [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		CONSTRAINT [IX_TCAJA]
		UNIQUE
		NONCLUSTERED
		([TCA_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TCAJA]
	ADD
	CONSTRAINT [PK_TCAJA]
	PRIMARY KEY
	NONCLUSTERED
	([TCA_CLA_PED])
	ON [PRIMARY]
GO
