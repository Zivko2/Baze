SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[SP_ACTUALIZACATEGORIAPERM] (@ma_codigo int,@CPE_CODIGONVO INT)   as


declare
  @eq1 int, @eq2 Int, @ma_peso_kg decimal(38,6), @EQ_CANT decimal(28,14)


    if (select me_com from maestro where ma_codigo=@ma_codigo ) is not null 
     select @eq1 = me_com, @ma_peso_kg=ma_peso_kg from maestro where ma_codigo=@ma_codigo


    if (select me_codigo from categpermiso where cpe_codigo=@CPE_CODIGONVO) is not null
    select @eq2 = me_codigo from categpermiso where cpe_codigo=@CPE_CODIGONVO


    if (@eq1 > -1) and (@eq2 > -1)
    begin
      if exists(select eq_cant from equivale where me_codigo1 = @eq1 and me_codigo2 = @eq2)
      begin
	  select @EQ_CANT=eq_cant from equivale where me_codigo1 = @eq1 and me_codigo2 = @eq2      
      end
      else
      begin
	      if @eq2 = (select me_kilogramos from configuracion) 
	      begin
	        if @ma_peso_kg > 0 
	          set @EQ_CANT=@ma_peso_kg
	        else
	          set @EQ_CANT = 1;
	      end
	      else
	        set @EQ_CANT = 1;
       end;
    end
    else
       set @EQ_CANT = 1


	/*=============================== insercion ==============================*/
	if not exists (select * from maestrocateg where ma_codigo=@ma_codigo and cpe_codigo=@CPE_CODIGONVO)
	insert into maestrocateg(ma_codigo, cpe_codigo, eq_cant)
	values (@ma_codigo, @CPE_CODIGONVO, @eq_cant)







GO
