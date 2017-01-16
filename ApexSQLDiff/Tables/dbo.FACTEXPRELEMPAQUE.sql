SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FACTEXPRELEMPAQUE] (
		[FEE_INDICE]        [int] NOT NULL,
		[FED_INDICED]       [int] NOT NULL,
		[FE_CODIGO]         [int] NOT NULL,
		[REL_CANT]          [decimal](38, 6) NOT NULL,
		[REL_RELCAJAS]      [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[REL_RELTARIMA]     [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FACTEXPRELEMPAQUE]
	ADD
	CONSTRAINT [PK_FACTEXPRELEMPAQUE]
	PRIMARY KEY
	NONCLUSTERED
	([FEE_INDICE], [FED_INDICED], [FE_CODIGO], [REL_CANT])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[FACTEXPRELEMPAQUE] SET (LOCK_ESCALATION = TABLE)
GO
