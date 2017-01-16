SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IMPORTSPECSGRP] (
		[IMG_CODIGO]     [int] NOT NULL,
		[IMG_NOMBRE]     [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IMG_TAG]        [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IMPORTSPECSGRP]
	ADD
	CONSTRAINT [PK_IMPORTSPECSGRP]
	PRIMARY KEY
	CLUSTERED
	([IMG_NOMBRE])
	WITH FILLFACTOR=90
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[IMPORTSPECSGRP]
	ADD
	CONSTRAINT [DF_IMPORTSPECSGRP_IMG_TAG]
	DEFAULT (0) FOR [IMG_TAG]
GO
ALTER TABLE [dbo].[IMPORTSPECSGRP] SET (LOCK_ESCALATION = TABLE)
GO
