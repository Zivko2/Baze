SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [INSERT_SYSUSRLOG64] ON dbo.sysusrlog64
	FOR INSERT, UPDATE
	AS 
	
	declare @diasantes varchar(25)
	
		SELECT     @diasantes = convert(varchar(25), getdate() - max(EM_DIASMANTLOG),101)
		FROM         dbo.CONFIGURACION 
		GROUP BY EM_DIASMANTLOG 
	
	 
		exec sp_fillsysusrlogHist @diasantes,64
GO
