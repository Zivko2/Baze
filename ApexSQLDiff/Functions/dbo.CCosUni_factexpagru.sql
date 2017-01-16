SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION dbo.CCosUni_factexpagru(@cf_pedexpvausa char(1), @cfq_tipo char(1), @cft_tipo char(1), @eq_gen decimal(28,14), @fed_cos_uni decimal(38,6), @fed_gra_add decimal(38,6), @fed_gra_emp decimal(38,6), @fed_gra_gi decimal(38,6), @fed_gra_gi_mx decimal(38,6), @fed_gra_mo decimal(38,6), @fed_gra_mp decimal(38,6), @fed_ng_add decimal(38,6), @fed_ng_emp decimal(38,6), @fed_ng_mp decimal(38,6))
RETURNS decimal(38,6)  AS  
begin
   if ((@cft_tipo = 'P' or @cft_tipo = 'S') and @cfq_tipo <> 'T' and @cfq_tipo <> 'D' and @eq_gen > 0 and @cf_pedexpvausa = 'N')
    begin
	RETURN ((@fed_gra_mp + @fed_gra_add + @fed_gra_emp + @fed_ng_mp + @fed_ng_add + @fed_gra_gi + @fed_ng_emp + @fed_gra_gi_mx + @fed_gra_mo) / @eq_gen);   
    end
     else
           if ( (@cft_tipo = 'P' or @cft_tipo = 'S') and @cfq_tipo <> 'T' and @cfq_tipo <> 'D' and @eq_gen <= 0 and @cf_pedexpvausa = 'N')
           begin
                  return (@fed_gra_mp + @fed_gra_add + @fed_gra_emp + @fed_ng_mp + @fed_ng_add + @fed_gra_gi + @fed_ng_emp + @fed_gra_gi_mx + @fed_gra_mo);
           end
           else
               if ( (@cft_tipo = 'P' or @cft_tipo = 'S') and @cfq_tipo <> 'T' and @cfq_tipo <>'D' and @eq_gen > 0 and @cf_pedexpvausa <> 'N')
               begin
                     return ((@fed_gra_mp + @fed_gra_add + @fed_gra_emp + @fed_ng_mp + @fed_ng_add + @fed_ng_emp + @fed_gra_gi_mx + @fed_gra_gi + @fed_gra_mo) / @eq_gen);
               end
           else
               if ( (@cft_tipo = 'P' or @cft_tipo = 'S') and @cfq_tipo <> 'T'and @cfq_tipo <> 'D' and @eq_gen <= 0)
               begin
                    return (@fed_gra_mp + @fed_gra_add + @fed_gra_emp + @fed_ng_mp + @fed_ng_add + @fed_ng_emp + @fed_gra_gi_mx + @fed_gra_gi + @fed_gra_mo);
               end
           else
               if( @eq_gen > 0)
               begin 
                    return (@fed_cos_uni / @eq_gen)
               end
 RETURN 0;
end































GO
