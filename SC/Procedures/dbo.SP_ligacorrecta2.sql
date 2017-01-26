SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE dbo.SP_ligacorrecta2 @TIPO varchar(5)   as


/* Tipos
PIR=pedimento importacion r1
PI=pedimento importacion
PE=pedimento exportacion
PER=pedimento exportacion r1
FA=factura agrupadora */

	if @tipo ='PI'
	begin
		alter table factimp disable trigger UPDATE_FACTIMP
	
			update factimp
			set pi_codigo=-1
			where pi_codigo<>-1 and pi_codigo<0
			
	
		alter table factimp enable trigger UPDATE_FACTIMP
	end


	if @tipo ='PIR'
	begin
		alter table factimp disable trigger UPDATE_FACTIMP
			
			update factimp
			set pi_rectifica=-1
			where pi_rectifica<>-1 and pi_rectifica<0
	
		alter table factimp enable trigger UPDATE_FACTIMP
	end



	if @tipo ='PE'
	begin
		alter table factexp disable trigger UPDATE_FACTEXP
			update factexp
			set pi_codigo=-1
			where pi_codigo<>-1 and pi_codigo<0

		alter table factexp enable trigger UPDATE_FACTEXP
	end

	if @tipo ='PER'
	begin
		alter table factexp disable trigger UPDATE_FACTEXP
		
			update factexp
			set pi_rectifica=-1
			where pi_rectifica<>-1 and pi_rectifica<0

		alter table factexp enable trigger UPDATE_FACTEXP
	end




	if @tipo ='FA'
	begin

		alter table factimp disable trigger UPDATE_FACTIMP

			update factimp
			set fi_factagru=-1
			where fi_factagru<>-1 and fi_factagru<0

		alter table factimp enable trigger UPDATE_FACTIMP


		alter table factexp disable trigger UPDATE_FACTEXP

			update factexp
			set fe_factagru=-1
			where fe_factagru<>-1 and fe_factagru<0
		
		alter table factexp enable trigger UPDATE_FACTEXP

	end

/*	
alter table factimp disable trigger UPDATE_FACTIMP

		update factimp
		set pi_codigo=-1
		where pi_codigo<>-1 and pi_codigo<0
		
		
		update factimp
		set pi_rectifica=-1
		where pi_rectifica<>-1 and pi_rectifica<0

		update factimp
		set fi_factagru=-1
		where fi_factagru<>-1 and fi_factagru<0

	alter table factimp enable trigger UPDATE_FACTIMP

	alter table factexp disable trigger UPDATE_FACTEXP
		update factexp
		set pi_codigo=-1
		where pi_codigo<>-1 and pi_codigo<0
	
		update factexp
		set pi_rectifica=-1
		where pi_rectifica<>-1 and pi_rectifica<0

		update factexp
		set fe_factagru=-1
		where fe_factagru<>-1 and fe_factagru<0
	
	alter table factexp enable trigger UPDATE_FACTEXP*/



























GO
