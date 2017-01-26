SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


























CREATE FUNCTION FormatoFecha (@Valor VARCHAR(7000), @PXP_ORDENFECHA char(1), @PXP_MESCONLETRAS char(1), @PXP_CUATROCIFRAS char(1), @PXP_SEPARAFECHA varchar(5))
RETURNS Varchar(7000) AS  
BEGIN
	declare @ValorFecha datetime, @ValorNvo varchar(7000), @DIACORTO varchar(5), @MESCORTO varchar(5), @YEAR varchar(5), @YEARCORTO varchar(5),
@MESLETRA varchar(50)

if @Valor is null
set @Valor='01/01/1900'

select @ValorFecha=convert(datetime,@Valor)

select @DIACORTO=LEFT(convert(varchar(12),@ValorFecha,103),2),
        @MESCORTO=LEFT(convert(varchar(12),@ValorFecha,110),2), @MESLETRA=LEFT(convert(varchar(12),@ValorFecha,107),3),
        @YEAR=RIGHT(convert(varchar(12),@ValorFecha,103),4), @YEARCORTO=RIGHT(convert(varchar(12),@ValorFecha,103),2)



      if @PXP_CUATROCIFRAS = 'S'
	begin

		if @YEAR<>'1900'
		begin
		     if @PXP_MESCONLETRAS = 'N' 
		     begin
			             if @PXP_ORDENFECHA = '1'   ----DMA
				 select @ValorNvo =@DIACORTO+@PXP_SEPARAFECHA+@MESCORTO+@PXP_SEPARAFECHA+@YEAR
			             else
			             if @PXP_ORDENFECHA = '2'   ----DAM
			                select @ValorNvo =@DIACORTO+@PXP_SEPARAFECHA+@YEAR+@PXP_SEPARAFECHA+@MESCORTO
			             else
			             if @PXP_ORDENFECHA = '3'   ----MDA
			                select @ValorNvo = @MESCORTO+@PXP_SEPARAFECHA+@DIACORTO+@PXP_SEPARAFECHA+@YEAR
			             else
			             if @PXP_ORDENFECHA = '4'   --MAD
			                select @ValorNvo = @MESCORTO+@PXP_SEPARAFECHA+@YEAR+@PXP_SEPARAFECHA+@DIACORTO
			             else
			             if @PXP_ORDENFECHA = '5'   --AMD
			                select @ValorNvo = @YEAR+@PXP_SEPARAFECHA+@MESCORTO+@PXP_SEPARAFECHA+@DIACORTO
			             else
			             if @PXP_ORDENFECHA = '6'   --ADM
			                select @ValorNvo = @YEAR+@PXP_SEPARAFECHA+@DIACORTO+@PXP_SEPARAFECHA+@MESCORTO
	
		     end
		     else -- mes con letra
		     begin
			             if @PXP_ORDENFECHA = '1'   ----DMA
				 select @ValorNvo =@DIACORTO+@PXP_SEPARAFECHA+@MESLETRA+@PXP_SEPARAFECHA+@YEAR
			             else
			             if @PXP_ORDENFECHA = '2'   ----DAM
			                select @ValorNvo =@DIACORTO+@PXP_SEPARAFECHA+@YEAR+@PXP_SEPARAFECHA+@MESLETRA
			             else
			             if @PXP_ORDENFECHA = '3'   ----MDA
			                select @ValorNvo = @MESLETRA+@PXP_SEPARAFECHA+@DIACORTO+@PXP_SEPARAFECHA+@YEAR
			             else
			             if @PXP_ORDENFECHA = '4'   --MAD
			                select @ValorNvo = @MESLETRA+@PXP_SEPARAFECHA+@YEAR+@PXP_SEPARAFECHA+@DIACORTO
			             else
			             if @PXP_ORDENFECHA = '5'   --AMD
			                select @ValorNvo = @YEAR+@PXP_SEPARAFECHA+@MESLETRA+@PXP_SEPARAFECHA+@DIACORTO
			             else
			             if @PXP_ORDENFECHA = '6'   --ADM
			                select @ValorNvo = @YEAR+@PXP_SEPARAFECHA+@DIACORTO+@PXP_SEPARAFECHA+@MESLETRA
		     end
	
	
		end
		else
		begin

			if @PXP_MESCONLETRAS = 'N' 
			begin
			             if @PXP_ORDENFECHA = '1'   ----DMA
				 select @ValorNvo ='00'+@PXP_SEPARAFECHA+'00'+@PXP_SEPARAFECHA+'0000'
			             else
			             if @PXP_ORDENFECHA = '2'   ----DAM
			                select @ValorNvo ='00'+@PXP_SEPARAFECHA+'0000'+@PXP_SEPARAFECHA+'00'
			             else
			             if @PXP_ORDENFECHA = '3'   ----MDA
			                select @ValorNvo = '00'+@PXP_SEPARAFECHA+'00'+@PXP_SEPARAFECHA+'0000'
			             else
			             if @PXP_ORDENFECHA = '4'   --MAD
			                select @ValorNvo = '00'+@PXP_SEPARAFECHA+'0000'+@PXP_SEPARAFECHA+'00'
			             else
			             if @PXP_ORDENFECHA = '5'   --AMD
			                select @ValorNvo = '0000'+@PXP_SEPARAFECHA+'00'+@PXP_SEPARAFECHA+'00'
			             else
			             if @PXP_ORDENFECHA = '6'   --ADM
			                select @ValorNvo = '0000'+@PXP_SEPARAFECHA+'00'+@PXP_SEPARAFECHA+'00'
			end	
			else
			begin
			             if @PXP_ORDENFECHA = '1'   ----DMA
				 select @ValorNvo ='00'+@PXP_SEPARAFECHA+'000'+@PXP_SEPARAFECHA+'0000'
			             else
			             if @PXP_ORDENFECHA = '2'   ----DAM
			                select @ValorNvo ='00'+@PXP_SEPARAFECHA+'0000'+@PXP_SEPARAFECHA+'000'
			             else
			             if @PXP_ORDENFECHA = '3'   ----MDA
			                select @ValorNvo = '000'+@PXP_SEPARAFECHA+'00'+@PXP_SEPARAFECHA+'0000'
			             else
			             if @PXP_ORDENFECHA = '4'   --MAD
			                select @ValorNvo = '000'+@PXP_SEPARAFECHA+'0000'+@PXP_SEPARAFECHA+'00'
			             else
			             if @PXP_ORDENFECHA = '5'   --AMD
			                select @ValorNvo = '0000'+@PXP_SEPARAFECHA+'000'+@PXP_SEPARAFECHA+'00'
			             else
			             if @PXP_ORDENFECHA = '6'   --ADM
			                select @ValorNvo = '0000'+@PXP_SEPARAFECHA+'00'+@PXP_SEPARAFECHA+'000'


			end
		end

	  end
	  else ---- anio con 2 caracteres

		if @YEAR<>'1900'
		begin
		     if @PXP_MESCONLETRAS = 'N'
		     begin
			             if @PXP_ORDENFECHA = '1'   ----DMA
				 select @ValorNvo =@DIACORTO+@PXP_SEPARAFECHA+@MESCORTO+@PXP_SEPARAFECHA+@YEARCORTO
			             else
			             if @PXP_ORDENFECHA = '2'   ----DAM
			                select @ValorNvo =@DIACORTO+@PXP_SEPARAFECHA+@YEARCORTO+@PXP_SEPARAFECHA+@MESCORTO
			             else
			             if @PXP_ORDENFECHA = '3'   ----MDA
			                select @ValorNvo = @MESCORTO+@PXP_SEPARAFECHA+@DIACORTO+@PXP_SEPARAFECHA+@YEARCORTO
			             else
			             if @PXP_ORDENFECHA = '4'   --MAD
			                select @ValorNvo = @MESCORTO+@PXP_SEPARAFECHA+@YEARCORTO+@PXP_SEPARAFECHA+@DIACORTO
			             else
			             if @PXP_ORDENFECHA = '5'   --AMD
			                select @ValorNvo = @YEARCORTO+@PXP_SEPARAFECHA+@MESCORTO+@PXP_SEPARAFECHA+@DIACORTO
			             else
			             if @PXP_ORDENFECHA = '6'   --ADM
			                select @ValorNvo = @YEARCORTO+@PXP_SEPARAFECHA+@DIACORTO+@PXP_SEPARAFECHA+@MESCORTO
	
		     end
		     else -- mes con letra
		     begin
			             if @PXP_ORDENFECHA = '1'   ----DMA
				 select @ValorNvo =@DIACORTO+@PXP_SEPARAFECHA+@MESLETRA+@PXP_SEPARAFECHA+@YEARCORTO
			             else
			             if @PXP_ORDENFECHA = '2'   ----DAM
			                select @ValorNvo =@DIACORTO+@PXP_SEPARAFECHA+@YEARCORTO+@PXP_SEPARAFECHA+@MESLETRA
			             else
			             if @PXP_ORDENFECHA = '3'   ----MDA
			                select @ValorNvo = @MESLETRA+@PXP_SEPARAFECHA+@DIACORTO+@PXP_SEPARAFECHA+@YEARCORTO
			             else
			             if @PXP_ORDENFECHA = '4'   --MAD
			                select @ValorNvo = @MESLETRA+@PXP_SEPARAFECHA+@YEARCORTO+@PXP_SEPARAFECHA+@DIACORTO
			             else
			             if @PXP_ORDENFECHA = '5'   --AMD
			                select @ValorNvo = @YEARCORTO+@PXP_SEPARAFECHA+@MESLETRA+@PXP_SEPARAFECHA+@DIACORTO
			             else
			             if @PXP_ORDENFECHA = '6'   --ADM
			                select @ValorNvo = @YEARCORTO+@PXP_SEPARAFECHA+@DIACORTO+@PXP_SEPARAFECHA+@MESLETRA
		     end
		end
		else
		begin
			if @PXP_MESCONLETRAS = 'N' 
			begin
			             if @PXP_ORDENFECHA = '1'   ----DMA
				 select @ValorNvo ='00'+@PXP_SEPARAFECHA+'00'+@PXP_SEPARAFECHA+'00'
			             else
			             if @PXP_ORDENFECHA = '2'   ----DAM
			                select @ValorNvo ='00'+@PXP_SEPARAFECHA+'00'+@PXP_SEPARAFECHA+'00'
			             else
			             if @PXP_ORDENFECHA = '3'   ----MDA
			                select @ValorNvo = '00'+@PXP_SEPARAFECHA+'00'+@PXP_SEPARAFECHA+'00'
			             else
			             if @PXP_ORDENFECHA = '4'   --MAD
			                select @ValorNvo = '00'+@PXP_SEPARAFECHA+'00'+@PXP_SEPARAFECHA+'00'
			             else
			             if @PXP_ORDENFECHA = '5'   --AMD
			                select @ValorNvo = '00'+@PXP_SEPARAFECHA+'00'+@PXP_SEPARAFECHA+'00'
			             else
			             if @PXP_ORDENFECHA = '6'   --ADM
			                select @ValorNvo = '00'+@PXP_SEPARAFECHA+'00'+@PXP_SEPARAFECHA+'00'
			end	
			else
			begin
			             if @PXP_ORDENFECHA = '1'   ----DMA
				 select @ValorNvo ='00'+@PXP_SEPARAFECHA+'000'+@PXP_SEPARAFECHA+'00'
			             else
			             if @PXP_ORDENFECHA = '2'   ----DAM
			                select @ValorNvo ='00'+@PXP_SEPARAFECHA+'00'+@PXP_SEPARAFECHA+'000'
			             else
			             if @PXP_ORDENFECHA = '3'   ----MDA
			                select @ValorNvo = '000'+@PXP_SEPARAFECHA+'00'+@PXP_SEPARAFECHA+'00'
			             else
			             if @PXP_ORDENFECHA = '4'   --MAD
			                select @ValorNvo = '000'+@PXP_SEPARAFECHA+'00'+@PXP_SEPARAFECHA+'00'
			             else
			             if @PXP_ORDENFECHA = '5'   --AMD
			                select @ValorNvo = '00'+@PXP_SEPARAFECHA+'000'+@PXP_SEPARAFECHA+'00'
			             else
			             if @PXP_ORDENFECHA = '6'   --ADM
			                select @ValorNvo = '00'+@PXP_SEPARAFECHA+'00'+@PXP_SEPARAFECHA+'000'
			end


		end
	RETURN @ValorNvo
END















































GO
