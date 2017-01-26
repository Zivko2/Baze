SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

























































CREATE TRIGGER [UPDATE_FACTEXPDESP] ON [dbo].[FACTEXPDESP] 
FOR UPDATE
AS
	declare @fei_totalpeso decimal(38,6), @fei_totalcosto decimal(38,6)

	select @fei_totalpeso = fei_totalpeso, @fei_totalcosto = fei_totalcosto
	from inserted where fei_totalpeso <> 0

--	if not update(FEI_TOTALPESO)  sino no funciona

/*	if update (fei_totalpeso)
	if exists(select fei_totalpeso from factexpdesp where fe_codigo in (select fe_codigo from inserted) and fei_totalpeso <> @fei_totalpeso)
	UPDATE FACTEXPDESP 
	SET FEI_TOTALPESO = @fei_totalpeso
	where fe_codigo in (select fe_codigo from inserted)
	and fei_totalpeso <> @fei_totalpeso

	if update (fei_totalcosto)
	if exists(select fei_totalcosto from factexpdesp where fe_codigo in (select fe_codigo from inserted) and fei_totalcosto <> @fei_totalcosto)
	UPDATE FACTEXPDESP 
	SET FEI_TOTALCOSTO = @fei_totalcosto
	where fe_codigo in (select fe_codigo from inserted)
	and fei_totalcosto <> @fei_totalcosto */



























































GO
