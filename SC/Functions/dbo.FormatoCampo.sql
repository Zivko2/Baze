SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


























CREATE FUNCTION FormatoCampo (@PxfString varchar(50), @ValorCampo VARCHAR(2000))
RETURNS Varchar(2000) AS  
BEGIN

--PXP_FIJO_DELIM, F fijo y D Delimitado
	DECLARE @TipoDato VARCHAR(1), @SizeReal int, @Size int, @PXP_SEPARAFECHA char(1), @PXP_ORDENFECHA char(1), @PXP_CUATROCIFRAS char(1),
	@PXP_FIJO_DELIM char(1), @PXP_CHRRELLENO char(1), @PXP_MESCONLETRAS char(1), @ValorNvo VARCHAR(2000), @ValorFecha datetime, @BUM_REDONDEO smallint,
	@BUM_DECIMAL  smallint, @BUM_SEPARAMIL char(1), @PXP_SEPARADECIMAL char(1),
	@bum_dateorder char(1), @bum_mesformat  char(1), @bum_diaformat  char(1), @bum_anioformat  char(1), 
		@bum_datesepara  char(1)

	set @PxfString=replace(@PxfString, 'F','')

	SELECT     @TipoDato=PlntExpFormula.PXF_DATATYPE, @Size=PlntExpSeccDet.PXD_SIZE, @PXP_CHRRELLENO=PlantillaExp.PXP_CHRRELLENO,
		@PXP_SEPARAFECHA=replace(replace(replace(replace(PlantillaExp.PXP_SEPARAFECHA, 'D', '/'), 'E', ' '), 'G', '-'), 'N', ''),
		@PXP_ORDENFECHA=PlantillaExp.PXP_ORDENFECHA, @PXP_CUATROCIFRAS=PlantillaExp.PXP_CUATROCIFRAS,
		@PXP_MESCONLETRAS=PlantillaExp.PXP_MESCONLETRAS, @PXP_FIJO_DELIM=PlantillaExp.PXP_FIJO_DELIM,
		@BUM_REDONDEO=convert(smallint,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(BUM_REDONDEO,'A', 0),'B', 1),'C', 2),'D', 3),'E', 4),'F', 5),'G', 6),'H', 7),'I', 8),'J', 9),'K', 10)),
		@BUM_DECIMAL=convert(smallint,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(BUM_DECIMAL,'A', 0),'B', 1),'C', 2),'D', 3),'E', 4),'F', 5),'G', 6),'H', 7),'I', 8),'J', 9),'K', 10)),
		@BUM_SEPARAMIL=BUM_SEPARAMIL, @PXP_SEPARADECIMAL=PXP_SEPARADECIMAL,
		@bum_dateorder=bum_dateorder, @bum_mesformat=bum_mesformat, @bum_anioformat=bum_anioformat, 
		@bum_datesepara=bum_datesepara
	FROM         PlntExpFormula INNER JOIN
	                      PlntExpSeccDet ON PlntExpFormula.PXF_CODIGO = PlntExpSeccDet.PXF_CODIGO INNER JOIN
	                      PlntExpSecc ON PlntExpFormula.PXS_CODIGO = PlntExpSecc.PXS_CODIGO INNER JOIN
	                      PlantillaExp ON PlntExpSecc.PXP_CODIGO = PlantillaExp.PXP_CODIGO LEFT OUTER JOIN
	                      BUSQUEDAMASCARA ON PlntExpFormula.BUM_CODIGO = BUSQUEDAMASCARA.BUM_CODIGO
	WHERE     (PlntExpFormula.PXF_CODIGO = @PxfString)

	set @SizeReal= len(@ValorCampo)




  if @TipoDato IN ('2','6') 
  begin

	if @TipoDato = '2' -- flotante
	begin
		--select @ValorNvo=round(convert(decimal(38,6),@ValorCampo),@BUM_REDONDEO) 
		--select @ValorNvo=convert(varchar(2000),round(convert(decimal(38,6),@ValorCampo),@BUM_DECIMAL))

		if @PXP_SEPARADECIMAL='C' -- coma
		select @ValorNvo=replace(@ValorNvo,'.',',')
		else
		if @PXP_SEPARADECIMAL='N' -- ninguno
		select @ValorNvo=replace(@ValorNvo,'.','')

	end

	if @BUM_SEPARAMIL='S'
 	   select @ValorNvo =dbo.FormatoMiles (@ValorNvo,@BUM_DECIMAL)  
	else
	begin
	   if charIndex('.',@ValorNvo)>0
  	      select @ValorNvo =left(@ValorNvo,charIndex('.',@ValorNvo)-1)+left(substring(@ValorNvo,charindex('.',@ValorNvo),len(@ValorNvo)),@BUM_DECIMAL+1)
	   else
	      if convert(smallint,@BUM_DECIMAL) > 0	
  	      select @ValorNvo =@ValorNvo+'.'+replicate('0', @BUM_DECIMAL)
	     else
  	      select @ValorNvo =@ValorNvo
	end


  end


  if @ValorNvo=''
     set @ValorNvo=@ValorCampo


  if @TipoDato = '8' --and @PXP_FIJO_DELIM = 'F'     -- es String (rellena en caso de ser menor el size)
  begin
	if @PXP_FIJO_DELIM = 'F'
	select @ValorNvo =dbo.RellenaTexto (@ValorCampo,@Size, @PXP_CHRRELLENO)  
	else
	select @ValorNvo =left(@ValorCampo,@Size)  
  end

    if @TipoDato = '1'
    begin
	if @bum_dateorder is not null and @bum_dateorder<>''
	begin
		if @bum_dateorder='1'
		set @PXP_ORDENFECHA='5'
		else if @bum_dateorder='2'
		set @PXP_ORDENFECHA='1'
		else if @bum_dateorder='3'
		set @PXP_ORDENFECHA='3'

	end

	if @bum_mesformat is not null and @bum_mesformat<>'' and @bum_mesformat in ('3','4') 
	set @PXP_MESCONLETRAS='S'

	if @bum_anioformat is not null and @bum_anioformat<>'' and @bum_anioformat ='2' 
	set @PXP_CUATROCIFRAS='S'


	if @bum_datesepara is not null and @bum_datesepara<>''
	set @PXP_SEPARAFECHA=@bum_datesepara

	select @ValorFecha=convert(datetime,@ValorCampo)

	select @ValorNvo = dbo.FormatoFecha (@ValorCampo, @PXP_ORDENFECHA, @PXP_MESCONLETRAS, @PXP_CUATROCIFRAS, @PXP_SEPARAFECHA)

    end
   	

	RETURN @ValorNvo
END




















































GO
