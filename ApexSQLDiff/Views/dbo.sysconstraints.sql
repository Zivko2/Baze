SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW dbo.sysconstraints  with encryption as
SELECT
	constid = convert(int, id),
	id = convert(int, parent_obj),
	colid = convert(smallint, info),
	spare1 = convert(tinyint, 0),
	status = convert(int,
			CASE xtype
				WHEN 'PK' THEN 1 WHEN 'UQ' THEN 2 WHEN 'F' THEN 3
				WHEN 'C' THEN 4 WHEN 'D' THEN 5 ELSE 0 END
			+ CASE WHEN info != 0			-- CNST_COLUMN / CNST_TABLE
					THEN (16) ELSE (32) END
			+ CASE WHEN (status & 16)!=0	-- CNST_CLINDEX
					THEN (512) ELSE 0 END
			+ CASE WHEN (status & 32)!=0	-- CNST_NCLINDEX
					THEN (1024) ELSE 0 END
			+ (2048)						-- CNST_NOTDEFERRABLE
			+ CASE WHEN (status & 256)!=0	-- CNST_DISABLE
					THEN (16384) ELSE 0 END
			+ CASE WHEN (status & 512)!=0	-- CNST_ENABLE
					THEN (32767) ELSE 0 END
			+ CASE WHEN (status & 4)!=0		-- CNST_NONAME
					THEN (131072) ELSE 0 END
			+ CASE WHEN (status & 1)!=0		-- CNST_NEW
					THEN (1048576) ELSE 0 END
			+ CASE WHEN (status & 1024)!=0	-- CNST_REPL
					THEN (2097152) ELSE 0 END),
	actions = convert(int,  4096),
	error = convert(int, 0)
FROM sysobjects WHERE xtype in ('C', 'F', 'PK', 'UQ', 'D')
					AND (status & 64) = 0

GO
