SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IMPLEMENTAKARDES] (
		[BST_HIJO]              [int] NOT NULL,
		[PID_CANT_ST]           [decimal](38, 6) NOT NULL,
		[FE_FECHA]              [datetime] NOT NULL,
		[ME_CODIGO]             [int] NULL,
		[FACTCONV]              [decimal](28, 14) NOT NULL,
		[MA_COSTO]              [decimal](38, 6) NULL,
		[ORIGENREG]             [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PID_INDICED]           [int] NULL,
		[IMK_CANTDESC]          [decimal](38, 6) NULL,
		[IMK_CANTPORDESC]       [decimal](38, 6) NULL,
		[IMK_CANTTOTALDESC]     [decimal](38, 6) NULL,
		[IMK_ESTATUSDESC]       [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IMPLEMENTAKARDES]
	ADD
	CONSTRAINT [DF_IMPLEMENTAKARDES_ORIGENREG]
	DEFAULT ('E') FOR [ORIGENREG]
GO
ALTER TABLE [dbo].[IMPLEMENTAKARDES] SET (LOCK_ESCALATION = TABLE)
GO
