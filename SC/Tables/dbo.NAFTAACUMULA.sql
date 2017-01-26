SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[NAFTAACUMULA] (
		[MA_CODIGO]     [int] NOT NULL,
		[CL_CODIGO]     [int] NOT NULL,
		[DI_INDICE]     [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NAFTAACUMULA]
	ADD
	CONSTRAINT [PK_NAFTAACUMULA]
	PRIMARY KEY
	NONCLUSTERED
	([MA_CODIGO], [CL_CODIGO])
	ON [PRIMARY]
GO
