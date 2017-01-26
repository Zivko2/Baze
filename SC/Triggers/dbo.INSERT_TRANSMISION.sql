SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE TRIGGER [INSERT_TRANSMISION] ON dbo.TRANSMISION 
FOR INSERT 
AS

	update transmision
	set trm_fecha = convert(varchar(10), getdate(),101)
	where trm_codigo in (select trm_codigo from inserted)




























GO
