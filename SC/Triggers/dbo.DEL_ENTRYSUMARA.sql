SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE TRIGGER DEL_ENTRYSUMARA ON dbo.ENTRYSUMARA  FOR DELETE AS
declare @eta_codigo int

	select @eta_codigo=eta_codigo from deleted



	update factexpdet
	set eta_codigo=-1
	where eta_codigo =@eta_codigo



























GO
