SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



































CREATE TRIGGER [INSERT_KARDESPEDtemp] ON dbo.KARDESPEDtemp
FOR INSERT, UPDATE
AS
SET NOCOUNT ON
declare @fed_retrabajo char(1), @kap_codigo int, @fed_indiced int, @KAP_INDICED_FACT int

	SELECT     @KAP_INDICED_FACT =KAP_INDICED_FACT, @kap_codigo = kap_codigo
	FROM         inserted

	select @fed_retrabajo=fed_retrabajo, @fed_indiced=fed_indiced from factexpdet where fed_indiced =@kap_indiced_fact


	if @fed_retrabajo='R' and exists (select * from almacendesp where fetr_tipo in ('F', 'V') and fetr_indiced=@fed_indiced
					and pid_indiced is null or pid_indiced=0)

	exec sp_actualizaalmacendesppt @fed_indiced




































GO
