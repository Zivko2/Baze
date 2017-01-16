SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CONTRIBUCIONFIJA] (
		[COF_CODIGO]          [int] IDENTITY(1, 1) NOT NULL,
		[CON_CODIGO]          [int] NOT NULL,
		[COF_TIPO]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[COF_VALOR]           [decimal](38, 6) NULL,
		[COF_PERINI]          [datetime] NOT NULL,
		[COF_PERFIN]          [datetime] NOT NULL,
		[COF_TIPOVALOR]       [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[COF_RANGOINI]        [decimal](38, 6) NULL,
		[COF_RANGOFIN]        [decimal](38, 6) NULL,
		[COF_PORCENTFIJA]     [decimal](38, 6) NULL,
		CONSTRAINT [IX_CONTRIBUCIONFIJA]
		UNIQUE
		NONCLUSTERED
		([COF_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CONTRIBUCIONFIJA]
	ADD
	CONSTRAINT [PK_CONTRIBUCIONFIJA]
	PRIMARY KEY
	NONCLUSTERED
	([CON_CODIGO], [COF_TIPO], [COF_PERINI], [COF_PERFIN], [COF_TIPOVALOR])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[CONTRIBUCIONFIJA]
	ADD
	CONSTRAINT [DF_CONTRIBUCIONFIJA_COF_PERFIN]
	DEFAULT ('01/01/9999') FOR [COF_PERFIN]
GO
ALTER TABLE [dbo].[CONTRIBUCIONFIJA]
	ADD
	CONSTRAINT [DF_CONTRIBUCIONFIJA_COF_PERINI]
	DEFAULT ('01/01/1980') FOR [COF_PERINI]
GO
ALTER TABLE [dbo].[CONTRIBUCIONFIJA] SET (LOCK_ESCALATION = TABLE)
GO
