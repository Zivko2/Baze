SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[FACTEXPDESPACHO] (
		[FEH_CODIGO]             [int] IDENTITY(1, 1) NOT NULL,
		[FE_CODIGO]              [int] NOT NULL,
		[FEH_FECHACRUCE]         [datetime] NULL,
		[FEH_HORACRUCE]          [datetime] NULL,
		[FEH_HORADOC]            [datetime] NULL,
		[CP_CODIGO]              [int] NULL,
		[FEH_HORADESPACHO]       [datetime] NULL,
		[FEH_SECDESPACHOENV]     [int] NULL,
		CONSTRAINT [IX_FACTEXPDESPACHO]
		UNIQUE
		NONCLUSTERED
		([FEH_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FACTEXPDESPACHO]
	ADD
	CONSTRAINT [PK_FACTEXPDESPACHO]
	PRIMARY KEY
	CLUSTERED
	([FE_CODIGO])
	ON [PRIMARY]
GO