SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CONFIGURAPROVEETempCertOrigen] (
		[CFP_CODIGO]               [int] IDENTITY(1, 1) NOT NULL,
		[CFP_PROVEEDORARCHIVO]     [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CL_CODIGO]                [int] NOT NULL,
		CONSTRAINT [IX_CONFIGURAPROVEETempCertOrigen]
		UNIQUE
		NONCLUSTERED
		([CFP_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CONFIGURAPROVEETempCertOrigen]
	ADD
	CONSTRAINT [PK_CONFIGURAPROVEETempCertOrigen]
	PRIMARY KEY
	CLUSTERED
	([CFP_PROVEEDORARCHIVO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[CONFIGURAPROVEETempCertOrigen]
	ADD
	CONSTRAINT [DF_CONFIGURAPROVEETempCertOrigen_CL_CODIGO]
	DEFAULT (0) FOR [CL_CODIGO]
GO