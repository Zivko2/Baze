SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CLAVEPEDIDENTIFICA] (
		[CP_CODIGO]          [int] NOT NULL,
		[IDE_CODIGO]         [int] NOT NULL,
		[IDE_NIVEL]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CP_MOVIMIENTO]      [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CP_COMPLEMENTO]     [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CLAVEPEDIDENTIFICA]
	ADD
	CONSTRAINT [PK_CLAVEPEDIDENTIFICA]
	PRIMARY KEY
	CLUSTERED
	([CP_CODIGO], [IDE_CODIGO], [IDE_NIVEL], [CP_MOVIMIENTO])
	WITH FILLFACTOR=90
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[CLAVEPEDIDENTIFICA]
	ADD
	CONSTRAINT [DF_CLAVEPEDIDENTIFICA_IDE_NIVEL]
	DEFAULT ('G') FOR [IDE_NIVEL]
GO
ALTER TABLE [dbo].[CLAVEPEDIDENTIFICA] SET (LOCK_ESCALATION = TABLE)
GO
