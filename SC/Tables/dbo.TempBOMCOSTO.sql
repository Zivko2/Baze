SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[TempBOMCOSTO] (
		[MA_CODIGO]         [int] NULL,
		[MA_GRAV_MP]        [decimal](38, 6) NULL,
		[MA_GRAV_ADD]       [decimal](38, 6) NULL,
		[MA_GRAV_EMP]       [decimal](38, 6) NULL,
		[MA_GRAV_GI]        [decimal](38, 6) NULL,
		[MA_GRAV_GI_MX]     [decimal](38, 6) NULL,
		[MA_GRAV_MO]        [decimal](38, 6) NULL,
		[MA_NG_MP]          [decimal](38, 6) NULL,
		[MA_NG_ADD]         [decimal](38, 6) NULL,
		[MA_NG_EMP]         [decimal](38, 6) NULL,
		[MA_NG_USA]         [decimal](38, 6) NULL,
		[MA_NG_MX]          [decimal](38, 6) NULL
) ON [PRIMARY]
GO
