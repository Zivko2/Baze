SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

create function [dbo].[ValorUnidadCove](@Corto varchar(50))
returns int as
begin
	return case @corto 
	when 'KG' then  1
	when 'GRM' then 2
    when 'MT' then 3
    when 'M2' then 4
    when 'M3' then 5
	when 'EA' then 6
	when 'HED' then 7
	when 'LT' then 8
	when 'PAR' then 9
	when 'KW' then 10
	when 'MIL' then 11
	when 'SET' then 12
	when 'KWH' then 13
	when 'TONM' then 14
	when 'BRL' then 15
	when 'GRN' then 16
	when 'DEC' then 17
	when 'CEN' then 18
	when 'DZ' then 19
	when 'BOX' then 20
	when 'BTL' then 21
	end
	
end
GO
