SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE dbo.[fillpedexpcont_rect] (@picodigo int, @user int)   as


declare @PIC_MARCA varchar(30), @PIC_MODELO varchar(30), @PIC_SERIE varchar(30), 
@PIC_EQUIPADOCON varchar(200), @CONSECUTIVO INT, @PIC_INDICEC int, @PID_INDICED int, @hora varchar(15), @FechaActual varchar(10), @em_codigo int,
@FEC_NOACTIVO VARCHAR(50)

	SET @FechaActual = convert(varchar(10), getdate(),101)

	select @em_codigo=em_codigo from intradeglobal.dbo.empresa where em_corto in
	(select replace(convert(sysname,db_name()),'intrade',''))

	select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)


	insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
	values (@user, 2, 'Insertando Contenido ', 'Inserting Content (Brands, Serials, etc.)  ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)

if exists (select * from pedimpcont where pi_codigo =@picodigo)
delete from pedimpcont where pi_codigo=@picodigo


declare cur_pedimpcont cursor for

SELECT     dbo.PEDIMPDET.PID_INDICED, dbo.FACTEXPCONT.FEC_MARCA, dbo.FACTEXPCONT.FEC_MODELO, dbo.FACTEXPCONT.FEC_SERIE, 
                      dbo.FACTEXPCONT.FEC_EQUIPADOCON, dbo.FACTEXPCONT.FEC_NOACTIVO
FROM         dbo.FACTEXPDET RIGHT OUTER JOIN
                      dbo.PEDIMPDET ON dbo.FACTEXPDET.PID_INDICEDLIGA = dbo.PEDIMPDET.PID_INDICED RIGHT OUTER JOIN
                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO LEFT OUTER JOIN
                      dbo.FACTEXPCONT ON dbo.FACTEXPDET.FED_INDICED = dbo.FACTEXPCONT.FED_INDICED LEFT OUTER JOIN
                      dbo.MAESTRO ON dbo.FACTEXPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
WHERE     (dbo.PEDIMPDET.PI_CODIGO = @picodigo) AND (dbo.FACTEXP.PI_RECTIFICA = @picodigo)
	and dbo.PEDIMPDET.PID_INDICED is not null and (dbo.FACTEXPCONT.FEC_MARCA is not null or dbo.FACTEXPCONT.FEC_MODELO  is not null or dbo.FACTEXPCONT.FEC_SERIE is not null or
                      dbo.FACTEXPCONT.FEC_EQUIPADOCON  is not null)
GROUP BY dbo.FACTEXPDET.MA_CODIGO, dbo.FACTEXPDET.FED_NOPARTE, dbo.FACTEXPDET.FED_COS_UNI, dbo.FACTEXPDET.FED_PES_UNI, 
                      dbo.FACTEXPDET.ME_CODIGO, dbo.FACTEXPDET.MA_GENERICO, dbo.FACTEXPDET.EQ_GEN, dbo.FACTEXPDET.EQ_EXPMX, 
                      dbo.FACTEXPDET.AR_EXPMX, dbo.FACTEXPDET.AR_IMPFO, dbo.FACTEXPDET.FED_RATEIMPFO, dbo.FACTEXPDET.FED_SEC_IMP, 
                      dbo.FACTEXPDET.FED_DEF_TIP, dbo.FACTEXPDET.FED_POR_DEF, dbo.FACTEXPDET.TI_CODIGO, dbo.FACTEXPDET.PA_CODIGO, 
                      dbo.FACTEXPDET.SPI_CODIGO, dbo.MAESTRO.PA_PROCEDE, dbo.FACTEXPDET.ME_GENERICO, dbo.FACTEXPDET.ME_AREXPMX, 
                      dbo.FACTEXPCONT.FEC_MARCA, dbo.FACTEXPCONT.FEC_MODELO, dbo.FACTEXPCONT.FEC_SERIE, dbo.FACTEXPCONT.FEC_EQUIPADOCON, 
                      dbo.PEDIMPDET.PID_INDICED, dbo.FACTEXPCONT.FEC_NOACTIVO


open cur_pedimpcont
fetch next from cur_pedimpcont into
@PID_INDICED, @PIC_MARCA, @PIC_MODELO, @PIC_SERIE, @PIC_EQUIPADOCON, @FEC_NOACTIVO

WHILE (@@FETCH_STATUS = 0) 
BEGIN

SELECT @CONSECUTIVO=ISNULL(MAX(PIC_INDICEC),0) FROM PEDIMPCONT

SET @CONSECUTIVO=@CONSECUTIVO+1

	INSERT INTO PEDIMPCONT (PI_CODIGO, PIC_INDICEC, PID_INDICED, PIC_MARCA, PIC_MODELO, PIC_SERIE, PIC_EQUIPADOCON, PIC_NOACTIVO)


	values(@PICODIGO, @CONSECUTIVO, @PID_INDICED, @PIC_MARCA, @PIC_MODELO, @PIC_SERIE, @PIC_EQUIPADOCON, @FEC_NOACTIVO)


fetch next from cur_pedimpcont into
@PID_INDICED, @PIC_MARCA, @PIC_MODELO, @PIC_SERIE, @PIC_EQUIPADOCON, @FEC_NOACTIVO

END

CLOSE cur_pedimpcont
DEALLOCATE cur_pedimpcont


select @Pic_indicec= max(pic_indicec) from pedimpcont

	update consecutivo
	set cv_codigo =  isnull(@pic_indicec,0) + 1
	where cv_tipo = 'PIC'



























GO
