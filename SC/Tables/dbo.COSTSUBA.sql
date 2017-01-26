SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[COSTSUBA] (
		[CS_CODIGO]           [int] NOT NULL,
		[CSA_NG_MAT]          [decimal](38, 6) NOT NULL,
		[CSA_NG_DESP]         [decimal](38, 6) NOT NULL,
		[CSA_NG_FLETE]        [decimal](38, 6) NOT NULL,
		[CSA_GRAV_MAT]        [decimal](38, 6) NOT NULL,
		[CSA_GRAV_DESP]       [decimal](38, 6) NOT NULL,
		[CSA_GRAV_FLETE]      [decimal](38, 6) NOT NULL,
		[CSA_MO_DIR_FO]       [decimal](38, 6) NOT NULL,
		[CSA_VA_GRAV]         [decimal](38, 6) NOT NULL,
		[CSA_PROD_VA_FO]      [decimal](38, 6) NOT NULL,
		[CSA_GRAL_ADM_FO]     [decimal](38, 6) NOT NULL,
		[CSA_NG_FO]           [decimal](38, 6) NOT NULL,
		[CSA_TOOLS]           [decimal](38, 6) NOT NULL,
		[CSA_MERCHAN]         [decimal](38, 6) NOT NULL,
		[CSA_ENG_DEV]         [decimal](38, 6) NOT NULL,
		[CSA_DEP_GRAL]        [decimal](38, 6) NOT NULL,
		[CSA_PROFIT]          [decimal](38, 6) NOT NULL,
		[CSA_EMP_US]          [decimal](38, 6) NOT NULL,
		[CSA_EMP_FO]          [decimal](38, 6) NOT NULL,
		[CSA_TOTALVALUE]      [decimal](38, 6) NOT NULL,
		[CSA_98020080]        [decimal](38, 6) NOT NULL,
		[CSA_98010010]        [decimal](38, 6) NOT NULL,
		[CSA_98020040]        [decimal](38, 6) NOT NULL,
		[CSA_98020060]        [decimal](38, 6) NOT NULL,
		[CSA_DUTVALUE]        [decimal](38, 6) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[COSTSUBA]
	ADD
	CONSTRAINT [PK_COSTSUBA]
	PRIMARY KEY
	NONCLUSTERED
	([CS_CODIGO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[COSTSUBA]
	ADD
	CONSTRAINT [DF_COSTSUBA_CSA_98010010]
	DEFAULT (0) FOR [CSA_98010010]
GO
ALTER TABLE [dbo].[COSTSUBA]
	ADD
	CONSTRAINT [DF_COSTSUBA_CSA_98020040]
	DEFAULT (0) FOR [CSA_98020040]
GO
ALTER TABLE [dbo].[COSTSUBA]
	ADD
	CONSTRAINT [DF_COSTSUBA_CSA_98020060]
	DEFAULT (0) FOR [CSA_98020060]
GO
ALTER TABLE [dbo].[COSTSUBA]
	ADD
	CONSTRAINT [DF_COSTSUBA_CSA_98020080]
	DEFAULT (0) FOR [CSA_98020080]
GO
ALTER TABLE [dbo].[COSTSUBA]
	ADD
	CONSTRAINT [DF_COSTSUBA_CSA_DEP_GRAL]
	DEFAULT (0) FOR [CSA_DEP_GRAL]
GO
ALTER TABLE [dbo].[COSTSUBA]
	ADD
	CONSTRAINT [DF_COSTSUBA_CSA_DUTVALUE]
	DEFAULT (0) FOR [CSA_DUTVALUE]
GO
ALTER TABLE [dbo].[COSTSUBA]
	ADD
	CONSTRAINT [DF_COSTSUBA_CSA_EMP_FO]
	DEFAULT (0) FOR [CSA_EMP_FO]
GO
ALTER TABLE [dbo].[COSTSUBA]
	ADD
	CONSTRAINT [DF_COSTSUBA_CSA_EMP_US]
	DEFAULT (0) FOR [CSA_EMP_US]
GO
ALTER TABLE [dbo].[COSTSUBA]
	ADD
	CONSTRAINT [DF_COSTSUBA_CSA_ENG_DEV]
	DEFAULT (0) FOR [CSA_ENG_DEV]
GO
ALTER TABLE [dbo].[COSTSUBA]
	ADD
	CONSTRAINT [DF_COSTSUBA_CSA_GRAL_ADM_FO]
	DEFAULT (0) FOR [CSA_GRAL_ADM_FO]
GO
ALTER TABLE [dbo].[COSTSUBA]
	ADD
	CONSTRAINT [DF_COSTSUBA_CSA_GRAV_DESP]
	DEFAULT (0) FOR [CSA_GRAV_DESP]
GO
ALTER TABLE [dbo].[COSTSUBA]
	ADD
	CONSTRAINT [DF_COSTSUBA_CSA_GRAV_FLETE]
	DEFAULT (0) FOR [CSA_GRAV_FLETE]
GO
ALTER TABLE [dbo].[COSTSUBA]
	ADD
	CONSTRAINT [DF_COSTSUBA_CSA_GRAV_MAT]
	DEFAULT (0) FOR [CSA_GRAV_MAT]
GO
ALTER TABLE [dbo].[COSTSUBA]
	ADD
	CONSTRAINT [DF_COSTSUBA_CSA_MERCHAN]
	DEFAULT (0) FOR [CSA_MERCHAN]
GO
ALTER TABLE [dbo].[COSTSUBA]
	ADD
	CONSTRAINT [DF_COSTSUBA_CSA_MO_DIR_FO]
	DEFAULT (0) FOR [CSA_MO_DIR_FO]
GO
ALTER TABLE [dbo].[COSTSUBA]
	ADD
	CONSTRAINT [DF_COSTSUBA_CSA_NG_DESP]
	DEFAULT (0) FOR [CSA_NG_DESP]
GO
ALTER TABLE [dbo].[COSTSUBA]
	ADD
	CONSTRAINT [DF_COSTSUBA_CSA_NG_FLETE]
	DEFAULT (0) FOR [CSA_NG_FLETE]
GO
ALTER TABLE [dbo].[COSTSUBA]
	ADD
	CONSTRAINT [DF_COSTSUBA_CSA_NG_FO]
	DEFAULT (0) FOR [CSA_NG_FO]
GO
ALTER TABLE [dbo].[COSTSUBA]
	ADD
	CONSTRAINT [DF_COSTSUBA_CSA_NG_MAT]
	DEFAULT (0) FOR [CSA_NG_MAT]
GO
ALTER TABLE [dbo].[COSTSUBA]
	ADD
	CONSTRAINT [DF_COSTSUBA_CSA_PROD_VA_FO]
	DEFAULT (0) FOR [CSA_PROD_VA_FO]
GO
ALTER TABLE [dbo].[COSTSUBA]
	ADD
	CONSTRAINT [DF_COSTSUBA_CSA_PROFIT]
	DEFAULT (0) FOR [CSA_PROFIT]
GO
ALTER TABLE [dbo].[COSTSUBA]
	ADD
	CONSTRAINT [DF_COSTSUBA_CSA_TOOLS]
	DEFAULT (0) FOR [CSA_TOOLS]
GO
ALTER TABLE [dbo].[COSTSUBA]
	ADD
	CONSTRAINT [DF_COSTSUBA_CSA_TOTALVALUE]
	DEFAULT (0) FOR [CSA_TOTALVALUE]
GO
ALTER TABLE [dbo].[COSTSUBA]
	ADD
	CONSTRAINT [DF_COSTSUBA_CSA_VA_GRAV]
	DEFAULT (0) FOR [CSA_VA_GRAV]
GO
