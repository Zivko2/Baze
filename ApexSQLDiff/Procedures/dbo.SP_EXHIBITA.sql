SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_EXHIBITA] (@CS_CODIGO INT)   as

SET NOCOUNT ON 
declare @csa_ng_mat decimal(38,6), @csa_grav_mat decimal(38,6), @csa_grav_desp decimal(38,6), @csa_ng_desp decimal(38,6), @csa_mo_dir_fo decimal(38,6), @csa_va_grav decimal(38,6),
	@csa_emp_us decimal(38,6), @csa_emp_fo decimal(38,6), @csa_98020080 decimal(38,6), @csa_98010010 decimal(38,6), @csa_98020040 decimal(38,6),
	@csa_98020060 decimal(38,6)

	select @csa_ng_mat=round(isnull(csa_ng_mat,0),0), @csa_grav_mat=round(isnull(csa_grav_mat,0),0), @csa_grav_desp=round(isnull(csa_grav_desp,0),0),  @csa_ng_desp=round(isnull(csa_ng_desp,0),0), 
	@csa_mo_dir_fo=round(isnull(csa_mo_dir_fo,0),0), @csa_va_grav=round(isnull(csa_va_grav,0),0), @csa_emp_us=round(isnull(csa_emp_us,0),0), @csa_emp_fo=round(isnull(csa_emp_fo,0),0), @csa_98020080=round(isnull(csa_98020080,0),0), 
	@csa_98010010=round(isnull(csa_98010010,0),0), @csa_98020040=round(isnull(csa_98020040,0),0), @csa_98020060=round(isnull(csa_98020060,0),0) 
	from vexhibit_a where cs_codigo = @cs_codigo 


IF NOT EXISTS (SELECT * FROM COSTSUBA WHERE CS_CODIGO = @CS_CODIGO) 
BEGIN
            INSERT INTO COSTSUBA(CS_CODIGO, CSA_NG_MAT, CSA_NG_DESP, CSA_GRAV_MAT,
             CSA_GRAV_DESP, CSA_MO_DIR_FO, CSA_VA_GRAV, 
	CSA_EMP_US, CSA_EMP_FO, CSA_98020080, CSA_98010010, CSA_98020040, CSA_98020060) 

	VALUES (@CS_CODIGO, @CSA_NG_MAT, @CSA_NG_DESP, @CSA_GRAV_MAT,
             @CSA_GRAV_DESP, @CSA_MO_DIR_FO, @CSA_VA_GRAV, 
	@CSA_EMP_US, @CSA_EMP_FO, @CSA_98020080, @CSA_98010010, @CSA_98020040, @CSA_98020060)


END
ELSE



IF EXISTS (SELECT * FROM COSTSUBA WHERE CS_CODIGO = @CS_CODIGO) 
BEGIN


	update costsuba
	set csa_ng_mat=@csa_ng_mat,
	csa_ng_desp=@csa_ng_desp,
	csa_grav_mat=@csa_grav_mat,
	csa_grav_desp=@csa_grav_desp,
	csa_mo_dir_fo=@csa_mo_dir_fo,
	csa_va_grav=@csa_va_grav,
	csa_emp_us = @csa_emp_us,
	csa_emp_fo = @csa_emp_fo,
	csa_98020080 = isnull(@csa_98020080,0),
	csa_98010010 = isnull(@csa_98010010,0),
	csa_98020040 = isnull(@csa_98020040,0),
	csa_98020060 = isnull(@csa_98020060,0)
	where cs_codigo= @cs_codigo

END

GO
