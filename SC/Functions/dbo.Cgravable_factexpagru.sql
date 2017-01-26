SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






























CREATE FUNCTION Cgravable_factexpagru(@cf_pais_usa int, @cfq_tipo char(1), @cft_tipo char(1), @eq_gen decimal(28,14), @fed_cos_uni decimal(38,6), @fed_nafta char (1), @pa_codigo int,@cf_pedexpvausa char(1), @fed_gra_add decimal(38,6), @fed_gra_emp decimal(38,6), @fed_gra_gi decimal(38,6), @fed_gra_gi_mx decimal(38,6), @fed_gra_mo decimal(38,6), @fed_gra_mp decimal(38,6), @fed_ng_add decimal(38,6), @fed_ng_emp decimal(38,6), @fed_ng_mp decimal(38,6), @fed_ng_usa decimal(38,6))
RETURNS decimal(38,6)  AS  
begin
   if ((@cft_tipo = 'P' or @cft_tipo = 'S') and @cfq_tipo <> 'T' and @eq_gen > 0)
    begin
	RETURN (dbo.CCosUni_factexpagru(@cf_pedexpvausa, @cfq_tipo, @cft_tipo, @eq_gen, @fed_cos_uni, @fed_gra_add, @fed_gra_emp, @fed_gra_gi, @fed_gra_gi_mx, @fed_gra_mo, @fed_gra_mp, @fed_ng_add, @fed_ng_emp, @fed_ng_mp) - (dbo.CmatNoGravable_factexpagru(@cf_pedexpvausa, @cf_pais_usa, @cfq_tipo, @cft_tipo, @eq_gen, @fed_cos_uni, @fed_gra_gi, @fed_nafta, @fed_ng_usa, @pa_codigo) + dbo.Cempaque_factexpagru(@cf_pais_usa, @cfq_tipo, @cft_tipo, @eq_gen, @fed_cos_uni, @fed_nafta, @fed_ng_emp, @pa_codigo) + dbo.Cvaloragregado_factexpagru(@cf_pedexpvausa, @eq_gen, @fed_gra_gi, @fed_gra_mo, @fed_gra_gi_mx)));   
    end
     else
           if ( (@cft_tipo = 'P' or @cft_tipo = 'S') and @cfq_tipo = 'T' and @fed_nafta <> 'S' and @eq_gen > 0)
           begin
                  return (@fed_cos_uni / @eq_gen);
           end
           else
               if ( (@cft_tipo <> 'P' and @cft_tipo <> 'S') and @pa_codigo <> @cf_pais_usa)
               begin
                     return (@fed_cos_uni / @eq_gen);
               end
           else
               if ((@cft_tipo <> 'P' and @cft_tipo <> 'S') and (@pa_codigo = @cf_pais_usa) and @fed_nafta <> 'S')
               begin
                    return (@fed_cos_uni / @eq_gen);
               end
 RETURN 0;
end








































GO
