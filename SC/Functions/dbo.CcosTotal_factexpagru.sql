SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






























CREATE FUNCTION CcosTotal_factexpagru(@ma_generico int, @fed_cant decimal(38,6), @eq_gen decimal(28,14), @cf_pedexpvausa char(1), @cfq_tipo char(1), @cft_tipo char(1), @fed_cos_uni decimal(38,6), @fed_gra_add decimal(38,6), @fed_gra_emp decimal(38,6), @fed_gra_gi decimal(38,6), @fed_gra_gi_mx decimal(38,6), @fed_gra_mo decimal(38,6), @fed_gra_mp decimal(38,6), @fed_ng_add decimal(38,6), @fed_ng_emp decimal(38,6), @fed_ng_mp decimal(38,6))
RETURNS decimal(38,6) AS
begin
     if (@ma_generico = 0 or @ma_generico = NULL)
     begin
          return (@fed_Cant * dbo.CCosUni_factexpagru(@cf_pedexpvausa, @cfq_tipo, @cft_tipo, @eq_gen, @fed_cos_uni, @fed_gra_add, @fed_gra_emp, @fed_gra_gi, @fed_gra_gi_mx, @fed_gra_mo, @fed_gra_mp, @fed_ng_add, @fed_ng_emp, @fed_ng_mp));
     end
     
     return (@fed_cant * @eq_gen * dbo.CCosUni_factexpagru(@cf_pedexpvausa, @cfq_tipo, @cft_tipo, @eq_gen, @fed_cos_uni, @fed_gra_add, @fed_gra_emp, @fed_gra_gi, @fed_gra_gi_mx, @fed_gra_mo, @fed_gra_mp, @fed_ng_add, @fed_ng_emp, @fed_ng_mp));
end






























GO
