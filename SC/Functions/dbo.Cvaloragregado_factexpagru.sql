SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






























CREATE FUNCTION Cvaloragregado_factexpagru(@cf_pedexpvausa char(1), @eq_gen decimal(28,14), @fed_gra_gi decimal(38,6), @fed_gra_mo decimal(38,6), @fed_gra_gi_mx decimal(38,6))
RETURNS decimal(38,6)  AS  
begin
   if (@cf_pedexpvausa = 'S')
    begin
        if (@eq_gen >0)
        begin
              return ( (@fed_gra_gi_mx + @fed_gra_gi + @fed_gra_mo) / @eq_gen)
        end
        else
             return ( @fed_gra_gi_mx + @fed_gra_gi + @fed_gra_mo);
    end
     else
           if (@eq_gen >0)
           begin
                  return ( (@fed_gra_gi_mx + @fed_gra_mo) / @eq_gen );
           end

 RETURN 0;
end






























GO
