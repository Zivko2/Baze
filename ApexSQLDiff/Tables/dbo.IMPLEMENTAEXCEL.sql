SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[IMPLEMENTAEXCEL] (
		[BST_HIJO]        [int] NOT NULL,
		[PID_CANT_ST]     [decimal](38, 6) NOT NULL,
		[FE_FECHA]        [datetime] NOT NULL,
		[ME_CODIGO]       [int] NULL,
		[FACTCONV]        [decimal](28, 14) NOT NULL,
		[MA_COSTO]        [decimal](38, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IMPLEMENTAEXCEL]
	ADD
	CONSTRAINT [PK_IMPLEMENTAEXCEL]
	PRIMARY KEY
	NONCLUSTERED
	([BST_HIJO], [FE_FECHA])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[IMPLEMENTAEXCEL] SET (LOCK_ESCALATION = TABLE)
GO
