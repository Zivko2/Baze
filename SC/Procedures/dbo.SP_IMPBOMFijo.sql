SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





















/* con este stored se suben materias primas que no esten el catalogo maestro*/
CREATE PROCEDURE [dbo].[SP_IMPBOMFijo]     as


DECLARE @ma_noparte varchar(30), @CONSECUTIVO INT, @ma_codigo int, @ma_noparteaux varchar(10)




/*UPDATE IMPORTTEMPBOM
SET     IMPORTTEMPBOM.TI_CODIGO= MAESTRO.TI_CODIGO, IMPORTTEMPBOM.ME_CODIGO= MAESTRO.ME_COM, IMPORTTEMPBOM.ME_GEN= 
                      MAESTRO_1.ME_COM, IMPORTTEMPBOM.PA_CODIGO= MAESTRO.PA_ORIGEN, IMPORTTEMPBOM.BST_TIP_ENS= MAESTRO.MA_TIP_ENS
FROM         MAESTRO MAESTRO_1 RIGHT OUTER JOIN
                      MAESTRO ON MAESTRO_1.MA_CODIGO = MAESTRO.MA_GENERICO RIGHT OUTER JOIN
                      IMPORTTEMPBOM ON MAESTRO.MA_NOPARTE = IMPORTTEMPBOM.BST_NOPARTE
WHERE IMPORTTEMPBOM.TI_CODIGO IS NULL*/



	--SELECT @CONSECUTIVO=ISNULL(MAX(MA_CODIGO),0)+1 FROM MAESTRO
	select @CONSECUTIVO=isnull(cv_codigo,0)+1 from consecutivo where cv_tabla='maestro'


	exec sp_droptable 'tempmp'
	CREATE TABLE [dbo].[tempmp] (
		[ma_codigo] [int] IDENTITY (1, 1) NOT NULL ,
		[ma_noparte] [varchar] (30) NOT NULL ,
		[ma_noparteaux] [varchar] (10)  NULL ,
		[me_codigo] [int] NULL ,
		[ti_codigo] [int] NULL ,		
	) ON [PRIMARY]

		--SELECT @CONSECUTIVO=ISNULL(MAX(MA_CODIGO),0) FROM MAESTRO
		select @CONSECUTIVO=isnull(cv_codigo,0)+1 from consecutivo where cv_tabla='maestro'


		dbcc checkident (tempmp, reseed, @CONSECUTIVO) WITH NO_INFOMSGS


		insert into tempmp(ma_noparte, ma_noparteaux, me_codigo, ti_codigo)
		SELECT IMPORTTEMPBOM.BST_NOPARTE, IMPORTTEMPBOM.BST_NOPARTEAUX, max(IMPORTTEMPBOM.ME_CODIGO),
		'ti_codigo'=case when 
		IMPORTTEMPBOM.BST_NOPARTE+IMPORTTEMPBOM.BST_NOPARTEAUX in (SELECT BSU_NOPARTE+BSU_NOPARTEAUX FROM dbo.IMPORTTEMPBOM
		GROUP BY BSU_NOPARTE+BSU_NOPARTEAUX) then 10  when IMPORTTEMPBOM.BST_NOPARTE+IMPORTTEMPBOM.BST_NOPARTEAUX NOT IN (SELECT BST_NOPARTE+BST_NOPARTEAUX FROM dbo.IMPORTTEMPBOM
		GROUP BY BST_NOPARTE+BST_NOPARTEAUX) then 14 else 16 end
		FROM IMPORTTEMPBOM 
		WHERE IMPORTTEMPBOM.BST_NOPARTE+IMPORTTEMPBOM.BST_NOPARTEAUX
		    NOT IN (SELECT dbo.MAESTRO.MA_NOPARTE+dbo.MAESTRO.MA_NOPARTEAUX FROM dbo.MAESTRO WHERE dbo.MAESTRO.MA_INV_GEN = 'I')
		GROUP BY IMPORTTEMPBOM.BST_NOPARTE, IMPORTTEMPBOM.BST_NOPARTEAUX


		insert into tempmp(ma_noparte, ma_noparteaux, me_codigo, ti_codigo)
		SELECT IMPORTTEMPBOM.BSU_NOPARTE, IMPORTTEMPBOM.BSU_NOPARTEAUX, max(IMPORTTEMPBOM.ME_CODIGO), 14
		FROM IMPORTTEMPBOM 
		WHERE IMPORTTEMPBOM.BSU_NOPARTE+IMPORTTEMPBOM.BSU_NOPARTEAUX
		    NOT IN (SELECT dbo.MAESTRO.MA_NOPARTE+dbo.MAESTRO.MA_NOPARTEAUX FROM dbo.MAESTRO WHERE dbo.MAESTRO.MA_INV_GEN = 'I')
		and IMPORTTEMPBOM.BSU_NOPARTE+IMPORTTEMPBOM.BSU_NOPARTEAUX
		    NOT IN (SELECT dbo.tempmp.MA_NOPARTE+dbo.tempmp.MA_NOPARTEAUX FROM dbo.tempmp)
		GROUP BY IMPORTTEMPBOM.BSU_NOPARTE, IMPORTTEMPBOM.BSU_NOPARTEAUX



		if exists (select * from tempmp)
		begin

			INSERT INTO MAESTRO(ma_noparte, ma_name, ma_nombre, ma_peso_kg, ma_peso_lb, pa_origen, pa_procede,
			ti_codigo, ma_inv_gen, me_com, ma_generico, ma_codigo, ma_tip_ens, ma_noparteaux)
	
		
			select ma_noparte, 'temp', 'temp', 0, 0, 233, 233, max(ti_codigo), 'I', isnull(min(me_codigo),19), 0, min(ma_codigo), 'ma_tip_ens'=case when max(ti_codigo)=10 then 'C' else 'F' end, ma_noparteaux
			from tempmp
			group by ma_noparte, ma_noparteaux
		end



	exec sp_droptable 'tempmp'
	


	select @MA_CODIGO= max(MA_CODIGO) from MAESTRO

	if exists(select * from maestrorefer) and (select isnull(max(ma_codigo),0) from maestrorefer)>@MA_CODIGO
	select @MA_CODIGO= isnull(max(MA_CODIGO),0) from MAESTROREFER

	update consecutivo
	set cv_codigo =  isnull(@ma_codigo,0) + 1
	where cv_tipo = 'MA'



























GO
