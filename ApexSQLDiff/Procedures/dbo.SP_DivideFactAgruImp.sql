SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

































--La nueva Factura Agrupadora que se genere se llama igual +'_C'+ consecutivo


CREATE PROCEDURE [dbo].[SP_DivideFactAgruImp] (@agrupadora int)   as

SET NOCOUNT ON 
--declare @agrupadora int
declare @cont_detalles int 
declare @nuevo_valor varchar(25)
declare @CONSECUTIVO int
declare @total int

--set @agrupadora=68
set @cont_detalles=0 --cada que inicia una agrupadora igualar a cero

select @total=isnull(sum(fi_cuentadet),0)/2 from factimp where fi_factagru=@agrupadora


        declare @FOLIO varchar(25)
        set @FOLIO=(select FIA_FOLIO FROM FactImpAgru where FIA_CODIGO=@agrupadora) 
	if exists (select * from FactImpAgru where FIA_FOLIO=@FOLIO)
	begin
		if exists (select * from FactImpAgru where FIA_FOLIO like @FOLIO+'_C%' and FIA_FOLIO not like @FOLIO+' _C%')
		begin
	               SET @nuevo_valor= @FOLIO+'_C'+convert(varchar(15),(SELECT max(REPLACE(RIGHT(FIA_FOLIO, 3), '_C', '  '))+1  FROM FactImpAgru where FIA_FOLIO like @FOLIO+'_C%' and FIA_FOLIO not like @FOLIO+' _C%'))
		end
		else
		       SET @nuevo_valor= @FOLIO+'_C1'
	end
	else
	begin
		SET @nuevo_valor= @FOLIO
	
	end

	 EXEC SP_GETCONSECUTIVO @TIPO='FIA', @VALUE=@CONSECUTIVO OUTPUT
        --> Agrega la nueva agrupadora a la tabla FactImpAgru
        insert into factimpagru (FIA_CODIGO,FIA_FOLIO, TF_CODIGO, TQ_CODIGO, FIA_PINICIAL, FIA_PFINAL, FIA_FECHA, FIA_TIPOCAMBIO, FIA_TIPO, FIA_NO_SEM, US_CODIGO, 
                     			PR_CODIGO, DI_PROVEE, CL_DESTFIN, DI_DESTFIN, AG_MEX, AG_USA, PU_CARGA, PU_SALIDA, PU_ENTRADA, PU_DESTINO, FIA_FEC_ENV, 
                      			FIA_FEC_ARR, ZO_CODIGO, CT_CODIGO, MT_CODIGO, FIA_GUIA, RU_CODIGO, FIA_TRAC_CHO, IT_CODIGO, FIA_FLETE, CJ_CODIGO, FIA_CONT_MX, 
                      			FIA_CONT_US, FIA_CONT_REG, FIA_SELLO, CA_CODIGO, FIA_CA_MARCA, FIA_CA_MODELO, FIA_TRAC_MX, FIA_TRAC_US, YA_CODIGO, CL_COMP, 
			                DI_COMP, CL_IMP, DI_IMP, CL_DESTINT, DI_DESTINT, CL_EXP, DI_EXP, CL_VEND, DI_VEND, CL_PROD, DI_PROD, FIA_ESTATUS, FIA_COMENTA, 
                      			FIA_COMENTAUS, FIA_TOTALB, MO_CODIGO, FIA_MANIFIESTO, SPI_CODIGO, CP_CODIGO, FIA_SEGURO, FIA_EMBALAJE, TCA_CODIGO, TN_CODIGO, 
                    			FIA_NUM_INBON, FIA_TIPO_INBON, FIA_FEC_INBON, FIA_HEADER, FIA_FOOTER, MT_ORIGEN, FIA_GUIAORIGEN)
	 select  @CONSECUTIVO, @nuevo_valor, TF_CODIGO, TQ_CODIGO, FIA_PINICIAL, FIA_PFINAL, FIA_FECHA, FIA_TIPOCAMBIO, FIA_TIPO, FIA_NO_SEM, US_CODIGO, 
                      			PR_CODIGO, DI_PROVEE, CL_DESTFIN, DI_DESTFIN, AG_MEX, AG_USA, PU_CARGA, PU_SALIDA, PU_ENTRADA, PU_DESTINO, FIA_FEC_ENV, 
                      			FIA_FEC_ARR, ZO_CODIGO, CT_CODIGO, MT_CODIGO, FIA_GUIA, RU_CODIGO, FIA_TRAC_CHO, IT_CODIGO, FIA_FLETE, CJ_CODIGO, FIA_CONT_MX, 
                      			FIA_CONT_US, FIA_CONT_REG, FIA_SELLO, CA_CODIGO, FIA_CA_MARCA, FIA_CA_MODELO, FIA_TRAC_MX, FIA_TRAC_US, YA_CODIGO, CL_COMP, 
                      			DI_COMP, CL_IMP, DI_IMP, CL_DESTINT, DI_DESTINT, CL_EXP, DI_EXP, CL_VEND, DI_VEND, CL_PROD, DI_PROD, FIA_ESTATUS, FIA_COMENTA, 
                      			FIA_COMENTAUS, FIA_TOTALB, MO_CODIGO, FIA_MANIFIESTO, SPI_CODIGO, CP_CODIGO, FIA_SEGURO, FIA_EMBALAJE, TCA_CODIGO, TN_CODIGO, 
                   			FIA_NUM_INBON, FIA_TIPO_INBON, FIA_FEC_INBON, FIA_HEADER, FIA_FOOTER, MT_ORIGEN, FIA_GUIAORIGEN
	 from factimpagru
	 where fia_codigo=@agrupadora

--Pasa las facturas a otra factura agrupadora
declare @FIA_CODIGO int , @FIA_FOLIO varchar(25), @FI_CODIGO int,@FI_CUENTADET int


declare cur_cambiaAgrup cursor for
   SELECT     FACTIMPAGRU.FIA_CODIGO,FACTIMPAGRU.FIA_FOLIO,FACTIMP.FI_CODIGO, FACTIMP.FI_CUENTADET 
   FROM         FACTIMPAGRU INNER JOIN FACTIMP ON FACTIMPAGRU.FIA_CODIGO = FACTIMP.FI_FACTAGRU
   WHERE FIA_CODIGO=@agrupadora
   ORDER BY FACTIMPAGRU.FIA_CODIGO,factimp.fi_codigo
 
open cur_cambiaAgrup
FETCH NEXT FROM cur_cambiaAgrup INTO @FIA_CODIGO, @FIA_FOLIO, @FI_CODIGO,@FI_CUENTADET

  WHILE (@@FETCH_STATUS=0)
  BEGIN
        --este va factura por factura que contiene la Fact. Agrupadora que se va a dividir en dos facturas
	set @cont_detalles=@cont_detalles+@FI_CUENTADET
        
        if  @cont_detalles > @total 
        begin
        
             -->Inicio Cambia la factura agrupadora x la nueva fact agrupadora
     		   	update factimp
              	     	set fi_factagru=@CONSECUTIVO
              	     	where fi_codigo=@FI_CODIGO       
 	     --<Fin Cambia la factura agrupadora x la nueva fact agrupadora



        end --fin del if cuando la suma de detalles es mayor al minimo permitido
       FETCH NEXT FROM cur_cambiaAgrup INTO @FIA_CODIGO, @FIA_FOLIO, @FI_CODIGO,@FI_CUENTADET   
   END
		
CLOSE cur_cambiaAgrup
DEALLOCATE cur_cambiaAgrup
































GO
