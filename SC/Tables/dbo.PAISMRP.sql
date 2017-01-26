SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PAISMRP] (
		[PA_INTRADE]       [int] NOT NULL,
		[PA_TEXTOMRP]      [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PA_NOMBRESYS]     [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PAISMRP]
	ADD
	CONSTRAINT [PK_PAISMRP]
	PRIMARY KEY
	CLUSTERED
	([PA_TEXTOMRP])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[PAISMRP]
	ADD
	CONSTRAINT [DF_PAISMRP_PA_NOMBRESYS]
	DEFAULT ('') FOR [PA_NOMBRESYS]
GO
