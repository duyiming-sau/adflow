!        generated by tapenade     (inria, tropics team)
!  tapenade 3.10 (r5363) -  9 sep 2014 09:53
!
!  differentiation of unsteadyturbterm in reverse (adjoint) mode (with options i4 dr8 r8 noisize):
!   gradient     of useful results: timeref *dw *w
!   with respect to varying inputs: timeref *dw *w
!   plus diff mem management of: dw:in w:in
!
!      ******************************************************************
!      *                                                                *
!      * file:          unsteadyturbterm.f90                            *
!      * author:        edwin van der weide                             *
!      * starting date: 02-09-2004                                      *
!      * last modified: 11-27-2007                                      *
!      *                                                                *
!      ******************************************************************
!
subroutine unsteadyturbterm_b(madv, nadv, offset, qq)
!
!      ******************************************************************
!      *                                                                *
!      * unsteadyturbterm discretizes the time derivative of the        *
!      * turbulence transport equations and add it to the residual.     *
!      * as the time derivative is the same for all turbulence models,  *
!      * this generic routine can be used; both the discretization of   *
!      * the time derivative and its contribution to the central        *
!      * jacobian are computed by this routine.                         *
!      *                                                                *
!      * only nadv equations are treated, while the actual system has   *
!      * size madv. the reason is that some equations for some          *
!      * turbulence equations do not have a time derivative, e.g. the   *
!      * f equation in the v2-f model. the argument offset indicates    *
!      * the offset in the w vector where this subsystem starts. as a   *
!      * consequence it is assumed that the indices of the current      *
!      * subsystem are contiguous, e.g. if a 2*2 system is solved the   *
!      * last index in w is offset+1 and offset+2 respectively.         *
!      *                                                                *
!      ******************************************************************
!
  use blockpointers
  use flowvarrefstate
  use inputphysics
  use inputtimespectral
  use inputunsteady
  use iteration
  use section
  use turbmod
  implicit none
!
!      subroutine arguments.
!
  integer(kind=inttype), intent(in) :: madv, nadv, offset
  real(kind=realtype), dimension(2:il, 2:jl, 2:kl, madv, madv), intent(&
& inout) :: qq
!
!      local variables.
!
  integer(kind=inttype) :: i, j, k, ii, jj, nn
  real(kind=realtype) :: oneoverdt, tmp
  real(kind=realtype) :: oneoverdtd, tmpd
  real(kind=realtype) :: tmp0
  real(kind=realtype) :: tmpd0
!
!      ******************************************************************
!      *                                                                *
!      * begin execution                                                *
!      *                                                                *
!      ******************************************************************
!
! determine the equation mode.
  select case  (equationmode) 
  case (steady) 

  case (unsteady) 
!===============================================================
! the time deritvative term depends on the integration
! scheme used.
    select case  (timeintegrationscheme) 
    case (bdf) 
! backward difference formula is used as time
! integration scheme.
! store the inverse of the physical nondimensional
! time step a bit easier.
      oneoverdt = timeref/deltat
! loop over the number of turbulent transport equations.
nadvloopunsteady:do ii=1,nadv
! store the index of the current turbulent variable in jj.
        call pushinteger4(jj)
        jj = ii + offset
! loop over the owned cells of this block to compute the
! time derivative.
        do k=2,kl
          do j=2,jl
            do i=2,il
! initialize tmp to the value of the current
! level multiplied by the corresponding coefficient
! in the time integration scheme.
              call pushreal8(tmp)
              tmp = coeftime(0)*w(i, j, k, jj)
! loop over the old time levels and add the
! corresponding contribution to tmp.
              do nn=1,noldlevels
                tmp = tmp + coeftime(nn)*wold(nn, i, j, k, jj)
              end do
            end do
          end do
        end do
      end do nadvloopunsteady
      oneoverdtd = 0.0_8
      do ii=nadv,1,-1
        do k=kl,2,-1
          do j=jl,2,-1
            do i=il,2,-1
              oneoverdtd = oneoverdtd - tmp*dwd(i, j, k, idvt+ii-1)
              tmpd = -(oneoverdt*dwd(i, j, k, idvt+ii-1))
              call popreal8(tmp)
              wd(i, j, k, jj) = wd(i, j, k, jj) + coeftime(0)*tmpd
            end do
          end do
        end do
        call popinteger4(jj)
      end do
      timerefd = timerefd + oneoverdtd/deltat
    end select
  case (timespectral) 
!===============================================================
! time spectral method.
! loop over the number of turbulent transport equations.
nadvloopspectral:do ii=1,nadv
! store the index of the current turbulent variable in jj.
      call pushinteger4(jj)
      jj = ii + offset
! the time derivative has been computed earlier in
! unsteadyturbspectral and stored in entry jj of dw.
! substract this value for all owned cells. it must be
! substracted, because in the turbulent routines the
! residual is defined with an opposite sign compared to
! the residual of the flow equations.
! also add a term to the diagonal matrix, which corresponds
! to to the contribution of the highest frequency. this is
! equivalent to an explicit treatment of the time derivative
! and may need to be changed.
    end do nadvloopspectral
    do ii=nadv,1,-1
      do k=kl,2,-1
        do j=jl,2,-1
          do i=il,2,-1
            tmpd0 = dwd(i, j, k, idvt+ii-1)
            dwd(i, j, k, idvt+ii-1) = tmpd0
            dwd(i, j, k, jj) = dwd(i, j, k, jj) - tmpd0
          end do
        end do
      end do
      call popinteger4(jj)
    end do
  end select
end subroutine unsteadyturbterm_b
