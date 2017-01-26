SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






















CREATE FUNCTION [SeparaCampoComa] (@cadena varchar(1500), @indice int)  
RETURNS varchar(500) AS  
BEGIN 
declare
  @cad varchar(1500), @ans varchar(1500), @temp int


  if @cadena is null
 set @cadena=''

  set @ans=''
  set @cad=@cadena
  if @cad <> '' 
  begin
    while @indice > 0 
    begin
      set @temp=charIndex(',',@cad)

      if @temp > 0 
      begin
        set @ans=substring(@cad,1,@temp-1)
        set @cad=substring(@cad,@temp+1,Len(@cad))
      end
      else
      begin
        if @indice > 1 
        begin
          set @ans=''
          set @indice=1
        end
        else
          set @ans=@cad
      end
      set @indice=@indice-1
    end
  end
  RETURN(rtrim(lTrim(@ans)))

END




































GO
