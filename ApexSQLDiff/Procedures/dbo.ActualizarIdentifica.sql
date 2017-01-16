SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.ActualizarIdentifica as
declare 
@IdentificaDet Int
/*Yolanda 18-julio-2005 */

		/*Se cancelo la actualizacion del ide_tipo ya que este solo debera actualizarse siempre y cuando este diferente Manuel G. 08-Nov-2010  */
		update identifica
		set ide_nombre=IdentificaOrig.ide_nombre,ide_desc=IdentificaOrig.ide_desc,/*ide_tipo=IdentificaOrig.ide_tipo,*/ide_cantcamp=IdentificaOrig.ide_cantcamp,ide_incluidoap=IdentificaOrig.ide_incluidoap,ide_motivo=IdentificaOrig.ide_motivo,
                                             ide_tabla=IdentificaOrig.ide_tabla,ide_campo=IdentificaOrig.ide_campo,ide_campo2=IdentificaOrig.ide_campo2,ide_aplica=IdentificaOrig.ide_aplica,ide_usafact=IdentificaOrig.ide_usafact,ide_motivob=IdentificaOrig.ide_motivob,
                                             ide_tipob=IdentificaOrig.ide_tipob,ide_tablab=IdentificaOrig.ide_tablab,ide_campob=IdentificaOrig.ide_campob,ide_campo2b=IdentificaOrig.ide_campo2b,ide_motivoc=IdentificaOrig.ide_motivoc,ide_tipoc=IdentificaOrig.ide_tipoc,
                                             ide_tablac=IdentificaOrig.ide_tablac,ide_campoc=IdentificaOrig.ide_campoc,ide_campo2c =IdentificaOrig.ide_campo2c, ide_obsoleto = IdentificaOrig.ide_obsoleto
		from identifica inner join original.dbo.identifica IdentificaOrig on
		identifica.ide_clave=IdentificaOrig.ide_clave  and identifica.ide_nivel=IdentificaOrig.ide_nivel  and identifica.ide_identperm=IdentificaOrig.ide_identperm
		
		/*Actualizar tipo cuando sea diferente, esto porque al ser diferente eliminara con el triger los detalles Manuel G. 08-Nov-2010 */
		update identifica 
		set ide_tipo=IdentificaOrig.ide_tipo
		from identifica inner join original.dbo.identifica IdentificaOrig on
		identifica.ide_clave=IdentificaOrig.ide_clave  and identifica.ide_nivel=IdentificaOrig.ide_nivel  and identifica.ide_identperm=IdentificaOrig.ide_identperm
		where identifica.ide_tipo <> IdentificaOrig.ide_tipo

		


                insert into identifica (ide_clave ,ide_nombre ,ide_desc ,ide_nivel ,ide_tipo ,ide_cantcamp ,ide_incluidoap ,ide_motivo ,ide_identperm ,
                                       ide_tabla ,ide_campo ,ide_campo2 ,ide_aplica ,ide_usafact ,ide_motivob ,ide_tipob ,ide_tablab ,ide_campob ,ide_campo2b ,ide_motivoc ,ide_tipoc ,
                                       ide_tablac ,ide_campoc ,ide_campo2c)
                select IdentificaOrig.ide_clave ,IdentificaOrig.ide_nombre ,IdentificaOrig.ide_desc ,IdentificaOrig.ide_nivel ,IdentificaOrig.ide_tipo ,IdentificaOrig.ide_cantcamp ,IdentificaOrig.ide_incluidoap ,IdentificaOrig.ide_motivo ,IdentificaOrig.ide_identperm ,
                                                           IdentificaOrig.ide_tabla ,IdentificaOrig.ide_campo ,IdentificaOrig.ide_campo2 ,IdentificaOrig.ide_aplica ,IdentificaOrig.ide_usafact ,IdentificaOrig.ide_motivob ,IdentificaOrig.ide_tipob ,IdentificaOrig.ide_tablab ,IdentificaOrig.ide_campob ,IdentificaOrig.ide_campo2b ,IdentificaOrig.ide_motivoc ,IdentificaOrig.ide_tipoc ,
                                                           IdentificaOrig.ide_tablac ,IdentificaOrig.ide_campoc ,IdentificaOrig.ide_campo2c
		from original.dbo.identifica IdentificaOrig
		where IdentificaOrig.ide_clave  + IdentificaOrig.ide_nivel  + IdentificaOrig.ide_identperm
		not in (select Identifica.ide_clave  + Identifica.ide_nivel  + Identifica.ide_identperm from identifica)

update identifica set ide_obsoleto = 'S'
from identifica
where ide_clave+'-'+ide_nivel+'-'+ide_identperm not in (select ide_clave+'-'+ide_nivel+'-'+ide_identperm from original.dbo.identifica)



/*Yolanda 18-julio-2005*/
SELECT  @IdentificaDet = COUNT(IDED_CODIGO)
FROM dbo.IdentificaDet
print @IdentificaDet

if @IdentificaDet = 0
	Insert INTO dbo.IdentificaDet  (IDED_CODIGO, IDE_CODIGO, IDED_COMPL, IDED_DESC, IDED_VALOR, IDED_APLICA, IDED_OBSOLETO)
	SELECT     Original.dbo.IdentificaDet.IDED_CODIGO, dbo.IDENTIFICA.IDE_CODIGO,Original.dbo.IdentificaDet.IDED_COMPL,
	Original.dbo.IdentificaDet.IDED_DESC, Original.dbo.IdentificaDet.IDED_VALOR, Original.dbo.IdentificaDet.IDED_APLICA, Original.dbo.IdentificaDet.IDED_OBSOLETO
	FROM         Original.dbo.IDENTIFICADET 
	    INNER JOIN Original.dbo.IDENTIFICA ON Original.dbo.IDENTIFICADET.IDE_CODIGO = Original.dbo.IDENTIFICA.IDE_CODIGO 
	    INNER JOIN dbo.IDENTIFICA ON Original.dbo.IDENTIFICA.IDE_CLAVE = dbo.IDENTIFICA.IDE_CLAVE AND Original.dbo.IDENTIFICA.IDE_NIVEL = dbo.IDENTIFICA.IDE_NIVEL AND 
                      Original.dbo.IDENTIFICA.IDE_IDENTPERM = dbo.IDENTIFICA.IDE_IDENTPERM	
else
BEGIN

        --Borro tabla temporal
				exec sp_droptable 'IDENTIFICADET_temporal'

        --Crear tabla temporal
				CREATE TABLE [dbo].[IDENTIFICADET_temporal] (
						[IDED_CODIGO] [int] IDENTITY (1, 1) NOT NULL ,
						[IDE_CODIGO] [int] NOT NULL ,
						[IDED_COMPL] [smallint] NOT NULL ,
						[IDED_DESC] [varchar] (1100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
						[IDED_VALOR] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
						[IDED_APLICA] [varchar] (2100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
						--Se agrego el campo obsoleto para complementos Manuel G. 4-ENE-2011
						[IDED_OBSOLETO] [char] (1) 
				) ON [PRIMARY]
				--GO

				ALTER TABLE [dbo].[IDENTIFICADET_temporal] ADD 
				CONSTRAINT [DF_IDENTIFICADET_temporal_IDED_COMPL] DEFAULT (1) FOR [IDED_COMPL],
				CONSTRAINT [DF_IDENTIFICADET_temporal_IDED_DESC] DEFAULT ('') FOR [IDED_DESC],
				CONSTRAINT [DF_IDENTIFICADET_temporal_IDED_OBSOLETO] DEFAULT ('N') FOR [IDED_OBSOLETO]
				--GO

				--Pasar la informacion de la tabla "dbo.identificadet" a la tabla "dbo.identificadet_temporal" y asi 
        -- mantener los mismos numeros consecutivos de IDED_CODIGO que ya tenia el cliente en su base de datos
				SET IDENTITY_INSERT IDENTIFICADET_temporal ON
					insert into IDENTIFICADET_temporal (IDED_CODIGO,IDE_CODIGO, IDED_COMPL, IDED_DESC, IDED_VALOR, IDED_APLICA, IDED_OBSOLETO)
					select IDED_CODIGO,IDE_CODIGO, IDED_COMPL, IDED_DESC, IDED_VALOR, IDED_APLICA, IDED_OBSOLETO
					from identificadet
				SET IDENTITY_INSERT IDENTIFICADET_temporal OFF
	
				--Identificar el consecutivo mayor de la tabla "dbo.identificadet_temporal" y a partir de ese numero insertar los nuevos datos
				declare @maximo_IDED_codigo int
				select     @maximo_IDED_codigo= isnull(MAX(IDED_CODIGO),0)
				FROM       identificadet_temporal
				dbcc checkident (IDENTIFICADET_temporal, reseed,@maximo_IDED_codigo)



 				--Inserto en la tabla temporal los datos que no se encuentran en la tabla de "dbo.identificadet"
				Insert Into dbo.IDENTIFICADET_temporal(IDE_CODIGO,IDED_DESC,IDED_COMPL,IDED_VALOR,IDED_APLICA,IDED_OBSOLETO)
				SELECT      dbo.IDENTIFICA.IDE_CODIGO, Original.dbo.IDENTIFICADET.IDED_DESC, Original.dbo.IDENTIFICADET.IDED_COMPL,
	                      Original.dbo.IDENTIFICADET.IDED_VALOR, Original.dbo.IDENTIFICADET.IDED_APLICA COLLATE SQL_Latin1_General_CP1_CI_AS, Original.dbo.IDENTIFICADET.IDED_OBSOLETO
				FROM         Original.dbo.IDENTIFICADET INNER JOIN
                      Original.dbo.IDENTIFICA ON Original.dbo.IDENTIFICADET.IDE_CODIGO = Original.dbo.IDENTIFICA.IDE_CODIGO INNER JOIN
                      dbo.IDENTIFICA ON Original.dbo.IDENTIFICA.IDE_CLAVE COLLATE SQL_Latin1_General_CP1_CI_AS = dbo.IDENTIFICA.IDE_CLAVE AND 
                      Original.dbo.IDENTIFICA.IDE_IDENTPERM COLLATE SQL_Latin1_General_CP1_CI_AS = dbo.IDENTIFICA.IDE_IDENTPERM
                       AND   Original.dbo.IDENTIFICA.ide_nivel COLLATE SQL_Latin1_General_CP1_CI_AS = dbo.IDENTIFICA.ide_nivel
 				where 
 						--Se valida si es nulo, ya que algunos complementos en su lista no tienen valor
						isnull(Original.dbo.IDENTIFICADET.IDED_VALOR+'-'+Convert(varchar(2),Original.dbo.IDENTIFICADET.IDED_COMPL),'')
						NOT IN
									(SELECT UPPER(identificadet_A.IDED_VALOR+'-'+convert(varchar(2),identificadet_A.IDED_COMPL)) 
									 FROM         dbo.IDENTIFICADET identificadet_A 
									 INNER JOIN  dbo.IDENTIFICA identifica_A ON identificadet_A.IDE_CODIGO = identifica_A.IDE_CODIGO
    									where identificadet_A.IDE_CODIGO=dbo.IDENTIFICA.IDE_CODIGO
								   GROUP BY UPPER(identificadet_A.IDED_VALOR+'-'+convert(varchar(2),identificadet_A.IDED_COMPL))) 				--Se comento ya que algunas listas no traen valor.
				--and Original.dbo.IDENTIFICADET.IDED_VALOR is not null 




 				--Borro los datos que tiene identificadet, los cuales se pasaron previamente a la tabla  dbo.identificadet_temporal  
 				delete from dbo.identificadet     
 				
 				--Paso los datos de la tabla "dbo.identificadet_temporal"  a la tabla "dbo.identificadet"
 				--La tabla temporal ya incluye la info que tenia el cliente mas la que no tenia al comprar la info con la tabla que esta en Original
 				insert into dbo.identificadet(ided_codigo,ide_codigo,ided_compl, ided_desc, ided_valor, ided_aplica, ided_obsoleto)
        select ided_codigo,ide_codigo,ided_compl, ided_desc, ided_valor, ided_aplica, ided_obsoleto
        from dbo.identificadet_temporal 
        
        --Se agrego para que actualice las descripciones de los complementos 
		UPDATE IDENTIFICADET set IDED_DESC = Original.dbo.IDENTIFICADET.IDED_DESC
		FROM  Original.dbo.IDENTIFICADET 
			INNER JOIN  Original.dbo.IDENTIFICA ON Original.dbo.IDENTIFICADET.IDE_CODIGO = Original.dbo.IDENTIFICA.IDE_CODIGO 
			INNER JOIN dbo.IDENTIFICA ON Original.dbo.IDENTIFICA.IDE_CLAVE COLLATE SQL_Latin1_General_CP1_CI_AS = dbo.IDENTIFICA.IDE_CLAVE 
					AND Original.dbo.IDENTIFICA.IDE_IDENTPERM COLLATE SQL_Latin1_General_CP1_CI_AS = dbo.IDENTIFICA.IDE_IDENTPERM
					AND Original.dbo.IDENTIFICA.ide_nivel COLLATE SQL_Latin1_General_CP1_CI_AS = dbo.IDENTIFICA.ide_nivel
			left outer join IDENTIFICADET on IDENTIFICA.IDE_CODIGO = IDENTIFICADET.IDE_CODIGO
		where Original.dbo.IDENTIFICADET.IDED_VALOR = IDENTIFICADET.IDED_VALOR and Original.dbo.IDENTIFICADET.IDED_COMPL = IDENTIFICADET.IDED_COMPL

	-- Se agrego para que actualice los complementos obsoletos
		UPDATE IDENTIFICADET set IDED_OBSOLETO = Original.dbo.IDENTIFICADET.IDED_obsoleto
		FROM  Original.dbo.IDENTIFICADET 
			INNER JOIN  Original.dbo.IDENTIFICA ON Original.dbo.IDENTIFICADET.IDE_CODIGO = Original.dbo.IDENTIFICA.IDE_CODIGO 
			INNER JOIN dbo.IDENTIFICA ON Original.dbo.IDENTIFICA.IDE_CLAVE COLLATE SQL_Latin1_General_CP1_CI_AS = dbo.IDENTIFICA.IDE_CLAVE 
					AND Original.dbo.IDENTIFICA.IDE_IDENTPERM COLLATE SQL_Latin1_General_CP1_CI_AS = dbo.IDENTIFICA.IDE_IDENTPERM
					AND Original.dbo.IDENTIFICA.ide_nivel COLLATE SQL_Latin1_General_CP1_CI_AS = dbo.IDENTIFICA.ide_nivel
			left outer join IDENTIFICADET on IDENTIFICA.IDE_CODIGO = IDENTIFICADET.IDE_CODIGO
		where Original.dbo.IDENTIFICADET.IDED_VALOR = IDENTIFICADET.IDED_VALOR and Original.dbo.IDENTIFICADET.IDED_COMPL = IDENTIFICADET.IDED_COMPL

	-- Pone obsoletos todos aquellos que no esten en los nuevos identificadores
		UPDATE IDENTIFICADET set IDED_OBSOLETO = 'S'
		from identifica a
			left outer join identificadet b on a.ide_codigo = b.ide_codigo
			left outer join original.dbo.identifica c on a.ide_clave = c.ide_clave and a.ide_identperm = c.ide_identperm and a.ide_nivel = c.ide_nivel
			left outer join original.dbo.identificadet d on c.ide_codigo = d.ide_codigo and b.ided_valor = d.ided_valor
		where d.ided_codigo is null and b.ided_codigo is not null

 
END


GO
