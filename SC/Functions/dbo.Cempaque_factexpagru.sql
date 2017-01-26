SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






























CREATE FUNCTION Cempaque_factexpagru(@cf_pais_usa int, @cfq_tipo char(1), @cft_tipo char(1), @eq_gen decimal(28,14), @fed_cos_uni decimal(38,6), @fed_nafta char(1), @fed_ng_emp decimal(38,6), @pa_codigo int)
RETURNS decimal(38,6)  AS  
begin
   if ( (@cft_tipo = 'P' or @cft_tipo = 'S') and @cfq_tipo <> 'T' and @eq_gen > 0)
    begin
	RETURN (@fed_ng_emp / @eq_gen);   
    end
     else
           if ( (@cfq_tipo = 'T' and @cft_tipo = 'E') and (@pa_codigo = @cf_pais_usa) and @fed_nafta = 'S')
           begin
                  return (@fed_cos_uni / @eq_gen);
            end

 RETURN 0;
end






























GO
