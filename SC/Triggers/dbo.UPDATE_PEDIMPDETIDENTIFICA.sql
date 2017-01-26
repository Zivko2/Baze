SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[UPDATE_PEDIMPDETIDENTIFICA] ON [dbo].[PEDIMPDETIDENTIFICA]
AFTER INSERT, UPDATE
AS
SET NOCOUNT ON
declare @IDED_CODIGO int, @IDED_CODIGO2 int, @IDED_CODIGO3 int
declare @piid_codigo int

select @ided_codigo = ided_codigo, @piid_codigo = piid_codigo,
	@ided_codigo2 = ided_codigo2,
	@ided_codigo3 = ided_codigo3
from inserted
if (update(ided_codigo))
	begin
		update pedimpdetidentifica
		set piid_desc = (select ided_valor from identificadet where identificadet.ided_codigo = @ided_codigo)
		from pedimpdetidentifica
		where piid_codigo = @piid_codigo
	end

if (update(ided_codigo2)) 
	begin	
		update pedimpdetidentifica
		set piid_desc2 = (select ided_valor from identificadet where identificadet.ided_codigo = @ided_codigo2)
		from pedimpdetidentifica
		where piid_codigo = @piid_codigo
	end
if (update(ided_codigo3)) 
	begin
		update pedimpdetidentifica
		set piid_desc3 = (select ided_valor from identificadet where identificadet.ided_codigo = @ided_codigo3)
		from pedimpdetidentifica
		where piid_codigo = @piid_codigo
	end

GO
