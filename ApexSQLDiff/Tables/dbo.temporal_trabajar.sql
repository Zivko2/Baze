SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[temporal_trabajar] (
		[mac_codigo]     [int] IDENTITY(1, 1) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[temporal_trabajar] SET (LOCK_ESCALATION = TABLE)
GO
