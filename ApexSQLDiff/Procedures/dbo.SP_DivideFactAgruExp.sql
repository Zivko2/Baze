SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





































--La nueva Factura Agrupadora que se genere se llama igual +'_C'+ consecutivo

CREATE PROCEDURE [dbo].[SP_DivideFactAgruExp] (@agrupadora int)   as

SET NOCOUNT ON 
--declare @agrupadora int  
declare @cont_detalles int 
declare @nuevo_valor varchar(25)
declare @CONSECUTIVO int
declare @total int

--set @agrupadora=68
set @cont_detalles=0 --cada que inicia una agrupadora igualar a cero

select @total=isnull(sum(fe_cuentadet),0)/2 from factexp where fe_factagru=@agrupadora


        declare @FOLIO varchar(25)
        set @FOLIO=(select FEA_FOLIO FROM FactExpAgru where FEA_CODIGO=@agrupadora) 
	if exists (select * from FactExpAgru where FEA_FOLIO=@FOLIO)
	begin
		if exists (select * from FactExpAgru where FEA_FOLIO like @FOLIO+'_C%' and FEA_FOLIO not like @FOLIO+' _C%')
		begin
	               SET @nuevo_valor= @FOLIO+'_C'+convert(varchar(15),(SELECT max(REPLACE(RIGHT(FEA_FOLIO, 3), '_C', '  '))+1  FROM FactExpAgru where FEA_FOLIO like @FOLIO+'_C%' and FEA_FOLIO not like @FOLIO+' _C%'))
		end
		else
		       SET @nuevo_valor= @FOLIO+'_C1'
	end
	else
	begin
		SET @nuevo_valor= @FOLIO
	
	end

	 EXEC SP_GETCONSECUTIVO @TIPO='FEA', @VALUE=@CONSECUTIVO OUTPUT
        --> Agrega la nueva agrupadora a la tabla FactExpAgru
        insert into factexpagru ( FEA_CODIGO, FEA_FOLIO, FEA_FECHA, TF_CODIGO, TQ_CODIGO, FEA_TIPO, FEA_PINICIAL, FEA_PFINAL, TN_CODIGO, FEA_NO_SEM, 
                      FEA_DOCUMENTO, FEA_DESTINO, FEA_TIPOCAMBIO, AG_MX, AG_US, CL_PROD, DI_PROD, CL_COMP, DI_COMP, CO_COMP, CL_COMPFIN, 
                      DI_COMPFIN, CO_COMPFIN, CL_EXP, DI_EXP, CL_EXPFIN, DI_EXPFIN, CL_DESTINI, DI_DESTINI, CO_DESTINI, CL_DESTFIN, DI_DESTFIN, 
                      CO_DESTFIN, CL_VEND, DI_VEND, CL_IMP, DI_IMP, PU_CARGA, PU_SALIDA, PU_ENTRADA, PU_DESTINO, FEA_FEC_ENV, FEA_FEC_ARR, 
                      FEA_NUM_ENV, FEA_ENV_INST, FEA_ORD_COMP, FEA_NUM_CTL, FEA_NUM_INBON, FEA_TIPO_INBON, FEA_FEC_INBON, FEA_FIRMS, 
                      FEA_COMENTA, FEA_COMENTAUS, US_CODIGO, CT_COMPANY1, CA_COMPANY1, CJ_COMPANY1, CT_COMPANY2, CA_COMPANY2, CJ_COMPANY2, 
                      FEA_TPAGO_FLETE1, FEA_TPAGO_FLETE2, FEA_TRAC_US1, FEA_TRAC_MX1, FEA_CONT1_REG, FEA_CONT1_US, FEA_CONT1_MX, 
                      FEA_CONT1_SELL, PG_COMPANY1, FEA_TRAC_CHO1, FEA_LIM1, RU_COMPANY1, FEA_FAIRE_MAR1, FEA_F_TERR1, FEA_G_MANEJO1, 
                      FEA_OTROS_CAR1, FEA_SEGURO1, FEA_TOTAL_TRANS1, FEA_TRAB_EXT1, FEA_TRANSFER1, MT_COMPANY1, FEA_GUIA1, FEA_TRAC_US2, 
                      FEA_TRAC_MX2, FEA_CONT2_REG, FEA_CONT2_US, FEA_CONT2_MX, FEA_CONT2_SELL, PG_COMPANY2, FEA_TRAC_CHO2, FEA_LIM2, 
                      RU_COMPANY2, FEA_FAIRE_MAR2, FEA_F_TERR2, FEA_G_MANEJO2, FEA_OTROS_CAR2, FEA_SEGURO2, FEA_TOTAL_TRANS2, FEA_TRAB_EXT2, 
                      FEA_TRANSFER2, MT_COMPANY2, FEA_GUIA2, FEA_TOTALB, FEA_MANIF, FEA_MANIF_DATE, FEA_AWB, fea_NUM_MANIFIES, FEA_VREDONDO1, 
                      FEA_VREDONDO2, FEA_FLETE2, FEA_FLETE, FEA_INCOTLUGAR1, FEA_INCOTLUGAR2, FEA_T_AND_E, FEA_B_OF_L, FEA_LAGNO, FEA_ESTATUS, 
                      MO_CODIGO, SPI_CODIGO, FEA_DESCRIPTION1, FEA_DESCRIPTION2, FEA_INVOICETYPE, FEA_HEADER, FEA_FOOTER, IT_COMPANY1, 
                      IT_COMPANY2, TCA_CONT1, TCA_CONT2, FEA_CA_MARCA1, FEA_CA_MODELO1, FEA_CA_MARCA2, FEA_CA_MODELO2, FEA_TIPOTRANS)
	 select  @CONSECUTIVO, @nuevo_valor, FEA_FECHA, TF_CODIGO, TQ_CODIGO, FEA_TIPO, FEA_PINICIAL, FEA_PFINAL, TN_CODIGO, FEA_NO_SEM, 
                      FEA_DOCUMENTO, FEA_DESTINO, FEA_TIPOCAMBIO, AG_MX, AG_US, CL_PROD, DI_PROD, CL_COMP, DI_COMP, CO_COMP, CL_COMPFIN, 
                      DI_COMPFIN, CO_COMPFIN, CL_EXP, DI_EXP, CL_EXPFIN, DI_EXPFIN, CL_DESTINI, DI_DESTINI, CO_DESTINI, CL_DESTFIN, DI_DESTFIN, 
                      CO_DESTFIN, CL_VEND, DI_VEND, CL_IMP, DI_IMP, PU_CARGA, PU_SALIDA, PU_ENTRADA, PU_DESTINO, FEA_FEC_ENV, FEA_FEC_ARR, 
                      FEA_NUM_ENV, FEA_ENV_INST, FEA_ORD_COMP, FEA_NUM_CTL, FEA_NUM_INBON, FEA_TIPO_INBON, FEA_FEC_INBON, FEA_FIRMS, 
                      FEA_COMENTA, FEA_COMENTAUS, US_CODIGO, CT_COMPANY1, CA_COMPANY1, CJ_COMPANY1, CT_COMPANY2, CA_COMPANY2, CJ_COMPANY2, 
                      FEA_TPAGO_FLETE1, FEA_TPAGO_FLETE2, FEA_TRAC_US1, FEA_TRAC_MX1, FEA_CONT1_REG, FEA_CONT1_US, FEA_CONT1_MX, 
                      FEA_CONT1_SELL, PG_COMPANY1, FEA_TRAC_CHO1, FEA_LIM1, RU_COMPANY1, FEA_FAIRE_MAR1, FEA_F_TERR1, FEA_G_MANEJO1, 
                      FEA_OTROS_CAR1, FEA_SEGURO1, FEA_TOTAL_TRANS1, FEA_TRAB_EXT1, FEA_TRANSFER1, MT_COMPANY1, FEA_GUIA1, FEA_TRAC_US2, 
                      FEA_TRAC_MX2, FEA_CONT2_REG, FEA_CONT2_US, FEA_CONT2_MX, FEA_CONT2_SELL, PG_COMPANY2, FEA_TRAC_CHO2, FEA_LIM2, 
                      RU_COMPANY2, FEA_FAIRE_MAR2, FEA_F_TERR2, FEA_G_MANEJO2, FEA_OTROS_CAR2, FEA_SEGURO2, FEA_TOTAL_TRANS2, FEA_TRAB_EXT2, 
                      FEA_TRANSFER2, MT_COMPANY2, FEA_GUIA2, FEA_TOTALB, FEA_MANIF, FEA_MANIF_DATE, FEA_AWB, fea_NUM_MANIFIES, FEA_VREDONDO1, 
                      FEA_VREDONDO2, FEA_FLETE2, FEA_FLETE, FEA_INCOTLUGAR1, FEA_INCOTLUGAR2, FEA_T_AND_E, FEA_B_OF_L, FEA_LAGNO, FEA_ESTATUS, 
                      MO_CODIGO, SPI_CODIGO, FEA_DESCRIPTION1, FEA_DESCRIPTION2, FEA_INVOICETYPE, FEA_HEADER, FEA_FOOTER, IT_COMPANY1, 
                      IT_COMPANY2, TCA_CONT1, TCA_CONT2, FEA_CA_MARCA1, FEA_CA_MODELO1, FEA_CA_MARCA2, FEA_CA_MODELO2, FEA_TIPOTRANS
	 from factexpagru
	 where fea_codigo=@agrupadora

--Pasa las facturas a otra factura agrupadora
declare @FEA_CODIGO int , @FEA_FOLIO varchar(25), @FE_CODIGO int,@FE_CUENTADET int


declare cur_cambiaAgrup cursor for
   SELECT     FACTEXPAGRU.FEA_CODIGO,FACTEXPAGRU.FEA_FOLIO,FACTEXP.FE_CODIGO, FACTEXP.FE_CUENTADET 
   FROM         FACTEXPAGRU INNER JOIN FACTEXP ON FACTEXPAGRU.FEA_CODIGO = FACTEXP.FE_FACTAGRU
   WHERE FEA_CODIGO=@agrupadora
   ORDER BY FACTEXPAGRU.FEA_CODIGO,factexp.fe_codigo
 
open cur_cambiaAgrup
FETCH NEXT FROM cur_cambiaAgrup INTO @FEA_CODIGO, @FEA_FOLIO, @FE_CODIGO,@FE_CUENTADET

  WHILE (@@FETCH_STATUS=0)
  BEGIN
        --este va factura por factura que contiene la Fact. Agrupadora que se va a dividir en dos facturas
	set @cont_detalles=@cont_detalles+@FE_CUENTADET
      
        if  @cont_detalles > @total 
        begin
        
             -->Inicio Cambia la factura agrupadora x la nueva fact agrupadora
     		   	update factexp
              	     	set fe_factagru=@CONSECUTIVO
              	     	where fe_codigo=@FE_CODIGO       
 	     --<Fin Cambia la factura agrupadora x la nueva fact agrupadora



        end --fin del if cuando la suma de detalles es mayor al minimo permitido
       FETCH NEXT FROM cur_cambiaAgrup INTO @FEA_CODIGO, @FEA_FOLIO, @FE_CODIGO,@FE_CUENTADET   
   END
		
CLOSE cur_cambiaAgrup
DEALLOCATE cur_cambiaAgrup
































GO
