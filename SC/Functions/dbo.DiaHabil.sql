SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


















































CREATE FUNCTION DiaHabil (@fechaini datetime) 
-- revisa la fecha del parametro y si es festivo o fin de semana da la fecha mas proxima que sea dia habil
RETURNS varchar(11) AS  
begin
declare @fecha datetime, @fechafinal datetime, @contador int

	set @contador=1
	SET  @fecha=@fechaini

	WHILE (@contador>0) 
	BEGIN

		if month(@fecha)=1 and day(@fecha)=1  --Ao Nuevo
		or
		month(@fecha)=2 and day(@fecha)=5  --Dias de la Constitucion
		or
		 month(@fecha)=3 and day(@fecha)=21  --Aniversario del Natalicio de Benito Juarez
		or
		month(@fecha)=5 and day(@fecha)=1  --Dia del Trabajo
		or
		month(@fecha)=5 and day(@fecha)=5  --Dia de la Batalla de Puebla
		or
		month(@fecha)=5 and day(@fecha)=10  --Dia de las Madres
		or
		month(@fecha)=9 and day(@fecha)=16  --Dia de la Independencia
		or
		month(@fecha)=10 and day(@fecha)=12  --Dia de la Raza
		or
		month(@fecha)=11 and day(@fecha)=2  --Dia de los Muertos
		or
		month(@fecha)=11 and day(@fecha)=20  --Dia de la Revolucion
		or
		month(@fecha)=12 and day(@fecha)=12  --Dia de la Virgen de Guadalupe
		or
		month(@fecha)=12 and day(@fecha)=25  --Navidad
		or
		7 in (SELECT DATEPART(dw, @fecha))
		or
		1 in (SELECT DATEPART(dw, @fecha))
		begin
			set @fecha=@fecha+1
			set @contador=@contador+1
		end
		else
		begin
			set @fecha=@fecha
			set @contador=0

		end

	END

		set @fechafinal=@fecha


	RETURN (@fechafinal);
end



























































GO
