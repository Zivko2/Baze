SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[PRODUCLIGA] (
		[LIP_CODIGO]          [int] IDENTITY(1, 1) NOT NULL,
		[PROD_INDICED]        [int] NOT NULL,
		[OTD_INDICED]         [int] NOT NULL,
		[LIP_CANTDESC]        [decimal](38, 6) NOT NULL,
		[LIP_FECHADESC]       [datetime] NOT NULL,
		[LIP_SALDOORDTRA]     [decimal](38, 6) NOT NULL,
		[OTDP_INDICEP]        [int] NULL,
		CONSTRAINT [IX_PRODUCLIGA]
		UNIQUE
		NONCLUSTERED
		([LIP_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PRODUCLIGA]
	ADD
	CONSTRAINT [PK_PRODUCLIGA]
	PRIMARY KEY
	NONCLUSTERED
	([PROD_INDICED], [OTD_INDICED], [LIP_CANTDESC])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[PRODUCLIGA]
	ADD
	CONSTRAINT [DF_PRODUCLIGA_LIP_CANTDESC]
	DEFAULT (0) FOR [LIP_CANTDESC]
GO
ALTER TABLE [dbo].[PRODUCLIGA]
	ADD
	CONSTRAINT [DF_PRODUCLIGA_LIP_SALDOORDTRA]
	DEFAULT (0) FOR [LIP_SALDOORDTRA]
GO
