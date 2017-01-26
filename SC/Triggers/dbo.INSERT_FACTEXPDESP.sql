SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






































CREATE TRIGGER [INSERT_FACTEXPDESP] ON [dbo].[FACTEXPDESP] 
FOR INSERT
AS

declare @fei_totalpeso decimal(38,6), @fei_totalcosto decimal(38,6)

	SELECT     @fei_totalpeso = FEI_TOTALPESO, @fei_totalcosto = FEI_TOTALCOSTO
	FROM         FACTEXPDESP where FE_CODIGO
	IN (SELECT FE_CODIGO FROM INSERTED) AND
	FEI_TOTALPESO>0

--	if not update(FEI_TOTALPESO)
	if exists(select fei_totalpeso from factexpdesp where fe_codigo in (select fe_codigo from inserted) and fei_totalpeso <> @fei_totalpeso)
	update factexpdesp
	set fei_totalpeso = @fei_totalpeso
	where fe_codigo in (select fe_codigo from inserted)
	and fei_totalpeso <> @fei_totalpeso	


	if exists(select fei_totalcosto from factexpdesp where fe_codigo in (select fe_codigo from inserted) and fei_totalcosto <> @fei_totalcosto)
	update factexpdesp
	set fei_totalcosto = @fei_totalcosto
	where fe_codigo in (select fe_codigo from inserted)
	and fei_totalcosto <> @fei_totalcosto

--	UPDATE FACTEXPDESP 
--	SET FEI_TOTALPESO = @fei_totalpeso
--	where fe_codigo in (select fe_codigo from inserted)
--	and FEI_TOTALPESO =0




































































GO
