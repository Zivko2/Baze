SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






























CREATE FUNCTION CmatNoGravable_factexpagru(@cf_pedexpvausa char(1), @cf_pais_usa int, @cfq_tipo char(1), @cft_tipo char(1), @eq_gen decimal(28,14), @fed_cos_uni decimal(38,6), @fed_gra_gi decimal(38,6), @fed_nafta char(1), @fed_ng_usa decimal(38,6), @pa_codigo int)
RETURNS decimal(38,6)  AS  
begin
   if ( (@cft_tipo = 'P' or @cft_tipo = 'S') and @cfq_tipo <> 'T' and @eq_gen > 0 and @cf_pedexpvausa = 'N')
    begin
	RETURN ((@fed_ng_usa + @fed_gra_gi) / @eq_gen);   
    end
     else
           if ( (@cft_tipo = 'P' or @cft_tipo = 'S') and @cfq_tipo <> 'T' and @eq_gen > 0 and @cf_pedexpvausa <> 'N' )
           begin
                  return (@fed_ng_usa / @eq_gen);
           end
           else
               if ( (@cft_tipo = 'P' or @cft_tipo = 'S') and @cfq_tipo = 'T' and @fed_nafta = 'S' and @eq_gen >0 )
               begin
                     return (@fed_cos_uni / @eq_gen);
               end
           else
               if ( (@cft_tipo <> 'P' and @cft_tipo <> 'S' and @cft_tipo <> 'E') and (@pa_codigo = @cf_pais_usa) and @fed_nafta = 'S')
               begin
                    return (@fed_cos_uni / @eq_gen);
               end
 RETURN 0;
end





























GO
