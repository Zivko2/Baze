SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_filltablaimplosionsub] (@BSU_SUBENSAMBLE Int, @entravigor datetime)   as


declare @BST_padre int, @BST_PERFIN datetime, @CFT_TIPO char(1) , @BST_PERINI datetime


if not exists (select * from dbo.sysobjects where name='tempImplosionSub')
create table [dbo].[tempImplosionSub]
( Bsu_subensamble int,
bst_hijo int,
BST_PERINI datetime,
BST_PERFIN datetime)


if exists (select * from tempImplosionSub WHERE bst_hijo = @BSU_SUBENSAMBLE)
DELETE FROM tempImplosionSub WHERE bst_hijo = @BSU_SUBENSAMBLE


			insert into tempImplosionSub(bst_perini, bst_perfin, bst_hijo, Bsu_subensamble)

			SELECT     bst_perini, bst_perfin, bst_hijo, bsu_subensamble
			from bom_struct
			where bst_hijo= @BSU_SUBENSAMBLE and bst_perini<=@entravigor 
			group by  bst_perini, bst_perfin, bsu_subensamble, bst_hijo
			ORDER BY dbo.BOM_STRUCT.bsu_subensamble





declare CUR_TABLAIMPLOSIONSUB cursor for

	SELECT     bst_perini, bst_perfin, bsu_subensamble
	from bom_struct left outer join maestro on bom_struct.bst_hijo = maestro.ma_codigo
	where bst_hijo= @BSU_SUBENSAMBLE and bst_perini<=@entravigor and
	maestro.ti_codigo in (select ti_codigo from configuratipo where cft_tipo='S' or cft_tipo='P')
	group by  bst_perini, bst_perfin, bsu_subensamble
	ORDER BY dbo.BOM_STRUCT.bsu_subensamble


 OPEN CUR_TABLAIMPLOSIONSUB


	FETCH NEXT FROM CUR_TABLAIMPLOSIONSUB INTO @bst_perini, @bst_perfin, @bst_padre

  WHILE (@@fetch_status = 0) 

  BEGIN  

			exec  SP_filltablaimplosionsub1 @BST_padre, @BSU_SUBENSAMBLE, @bst_perini


	FETCH NEXT FROM CUR_TABLAIMPLOSIONSUB INTO @bst_perini, @bst_perfin, @bst_padre

END

	CLOSE CUR_TABLAIMPLOSIONSUB
	DEALLOCATE CUR_TABLAIMPLOSIONSUB


GO
