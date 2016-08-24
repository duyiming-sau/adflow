!        generated by tapenade     (inria, tropics team)
!  tapenade 3.10 (r5363) -  9 sep 2014 09:53
!
!  differentiation of invisciddissfluxscalar in reverse (adjoint) mode (with options i4 dr8 r8 noisize):
!   gradient     of useful results: gammainf *p *w *fw
!   with respect to varying inputs: gammainf rhoinf pinfcorr *p
!                *w *radi *radj *radk
!   plus diff mem management of: p:in w:in fw:in radi:in radj:in
!                radk:in
!
!      ******************************************************************
!      *                                                                *
!      * file:          invisciddissfluxscalar.f90                      *
!      * author:        edwin van der weide                             *
!      * starting date: 03-24-2003                                      *
!      * last modified: 10-29-2007                                      *
!      *                                                                *
!      ******************************************************************
!
subroutine invisciddissfluxscalar_b()
!
!      ******************************************************************
!      *                                                                *
!      * invisciddissfluxscalar computes the scalar artificial          *
!      * dissipation, see aiaa paper 81-1259, for a given block.        *
!      * therefore it is assumed that the pointers in  blockpointers    *
!      * already point to the correct block.                            *
!      *                                                                *
!      ******************************************************************
!
  use constants
  use blockpointers, only : nx, ny, nz, il, jl, kl, ie, je, ke, ib, jb&
& , kb, w, wd, p, pd, pori, porj, pork, fw, fwd, radi, radid, radj, &
& radjd, radk, radkd, gamma
  use flowvarrefstate, only : gammainf, gammainfd, pinfcorr, pinfcorrd&
& , rhoinf, rhoinfd
  use inputdiscretization, only : vis2, vis4
  use inputphysics, only : equations
  use iteration, only : rfil
  use utils_b, only : mydim, mydim_b
  implicit none
!
!      local parameter.
!
  real(kind=realtype), parameter :: dssmax=0.25_realtype
!
!      local variables.
!
  integer(kind=inttype) :: i, j, k, ind, ii
  real(kind=realtype) :: sslim, rhoi
  real(kind=realtype) :: sslimd
  real(kind=realtype) :: sfil, fis2, fis4
  real(kind=realtype) :: ppor, rrad, dis2, dis4
  real(kind=realtype) :: rradd, dis2d, dis4d
  real(kind=realtype) :: ddw1, ddw2, ddw3, ddw4, ddw5, fs
  real(kind=realtype) :: ddw1d, ddw2d, ddw3d, ddw4d, ddw5d, fsd
  real(kind=realtype), dimension(ie, je, ke, 3) :: dss
  real(kind=realtype), dimension(ie, je, ke, 3) :: dssd
  real(kind=realtype), dimension(0:ib, 0:jb, 0:kb) :: ss
  real(kind=realtype), dimension(0:ib, 0:jb, 0:kb) :: ssd
  intrinsic abs
  intrinsic mod
  intrinsic max
  intrinsic min
  real(kind=realtype) :: arg1
  real(kind=realtype) :: arg1d
  integer :: branch
  real(kind=realtype) :: temp3
  real(kind=realtype) :: temp29
  real(kind=realtype) :: tempd14
  real(kind=realtype) :: temp2
  real(kind=realtype) :: temp28
  real(kind=realtype) :: tempd13
  real(kind=realtype) :: temp1
  real(kind=realtype) :: temp27
  real(kind=realtype) :: tempd12
  real(kind=realtype) :: temp0
  real(kind=realtype) :: tempd11
  real(kind=realtype) :: temp26
  real(kind=realtype) :: tempd10
  real(kind=realtype) :: temp25
  real(kind=realtype) :: temp24
  real(kind=realtype) :: temp23
  real(kind=realtype) :: temp22
  real(kind=realtype) :: temp21
  real(kind=realtype) :: temp20
  real(kind=realtype) :: min3
  real(kind=realtype) :: min2
  real(kind=realtype) :: min1
  real(kind=realtype) :: min1d
  real(kind=realtype) :: x3
  real(kind=realtype) :: x2
  real(kind=realtype) :: x2d
  real(kind=realtype) :: x1
  real(kind=realtype) :: temp19
  real(kind=realtype) :: temp18
  real(kind=realtype) :: temp17
  real(kind=realtype) :: temp16
  real(kind=realtype) :: temp15
  real(kind=realtype) :: temp14
  real(kind=realtype) :: temp13
  real(kind=realtype) :: y3d
  real(kind=realtype) :: temp12
  real(kind=realtype) :: temp11
  real(kind=realtype) :: temp10
  real(kind=realtype) :: temp41
  real(kind=realtype) :: temp40
  real(kind=realtype) :: tempd9
  real(kind=realtype) :: tempd
  real(kind=realtype) :: tempd8
  real(kind=realtype) :: tempd7
  real(kind=realtype) :: tempd6
  real(kind=realtype) :: tempd5
  real(kind=realtype) :: tempd4
  real(kind=realtype) :: tempd3
  real(kind=realtype) :: tempd2
  real(kind=realtype) :: tempd1
  real(kind=realtype) :: tempd0
  real(kind=realtype) :: x1d
  real(kind=realtype) :: min3d
  real(kind=realtype) :: y2d
  real(kind=realtype) :: temp39
  real(kind=realtype) :: temp38
  real(kind=realtype) :: temp37
  real(kind=realtype) :: temp36
  real(kind=realtype) :: tempd21
  real(kind=realtype) :: temp35
  real(kind=realtype) :: tempd20
  real(kind=realtype) :: temp34
  real(kind=realtype) :: temp33
  real(kind=realtype) :: temp32
  real(kind=realtype) :: temp31
  real(kind=realtype) :: temp30
  real(kind=realtype) :: abs0
  real(kind=realtype) :: temp
  real(kind=realtype) :: temp9
  real(kind=realtype) :: temp8
  real(kind=realtype) :: min2d
  real(kind=realtype) :: tempd19
  real(kind=realtype) :: temp7
  real(kind=realtype) :: tempd18
  real(kind=realtype) :: y3
  real(kind=realtype) :: temp6
  real(kind=realtype) :: tempd17
  real(kind=realtype) :: y2
  real(kind=realtype) :: temp5
  real(kind=realtype) :: x3d
  real(kind=realtype) :: tempd16
  real(kind=realtype) :: y1
  real(kind=realtype) :: temp4
  real(kind=realtype) :: y1d
  real(kind=realtype) :: tempd15
  if (rfil .ge. 0.) then
    abs0 = rfil
  else
    abs0 = -rfil
  end if
!
!      ******************************************************************
!      *                                                                *
!      * begin execution                                                *
!      *                                                                *
!      ******************************************************************
!
! check if rfil == 0. if so, the dissipative flux needs not to
! be computed.
  if (abs0 .lt. thresholdreal) then
    rhoinfd = 0.0_8
    pinfcorrd = 0.0_8
    radid = 0.0_8
    radjd = 0.0_8
    radkd = 0.0_8
  else
! determine the variables used to compute the switch.
! for the inviscid case this is the pressure; for the viscous
! case it is the entropy.
    select case  (equations) 
    case (eulerequations) 
! inviscid case. pressure switch is based on the pressure.
! also set the value of sslim. to be fully consistent this
! must have the dimension of pressure and it is therefore
! set to a fraction of the free stream value.
      sslim = 0.001_realtype*pinfcorr
! copy the pressure in ss. only need the entries used in the
! discretization, i.e. not including the corner halo's, but we'll
! just copy all anyway. 
      ss = p
      call pushcontrol2b(1)
    case (nsequations, ransequations) 
!===============================================================
! viscous case. pressure switch is based on the entropy.
! also set the value of sslim. to be fully consistent this
! must have the dimension of entropy and it is therefore
! set to a fraction of the free stream value.
      sslim = 0.001_realtype*pinfcorr/rhoinf**gammainf
! store the entropy in ss. see above. 
      do ii=0,(ib+1)*(jb+1)*(kb+1)-1
        i = mod(ii, ib + 1)
        j = mod(ii/(ib+1), jb + 1)
        k = ii/((ib+1)*(jb+1))
        ss(i, j, k) = p(i, j, k)/w(i, j, k, irho)**gamma(i, j, k)
      end do
      call pushcontrol2b(0)
    case default
      call pushcontrol2b(2)
    end select
    call pushinteger4(i)
    call pushinteger4(j)
! compute the pressure sensor for each cell, in each direction:
    do ii=0,ie*je*ke-1
      i = mod(ii, ie) + 1
      j = mod(ii/ie, je) + 1
      k = ii/(ie*je) + 1
      x1 = (ss(i+1, j, k)-two*ss(i, j, k)+ss(i-1, j, k))/(ss(i+1, j, k)+&
&       two*ss(i, j, k)+ss(i-1, j, k)+sslim)
      if (x1 .ge. 0.) then
        dss(i, j, k, 1) = x1
      else
        dss(i, j, k, 1) = -x1
      end if
      x2 = (ss(i, j+1, k)-two*ss(i, j, k)+ss(i, j-1, k))/(ss(i, j+1, k)+&
&       two*ss(i, j, k)+ss(i, j-1, k)+sslim)
      if (x2 .ge. 0.) then
        dss(i, j, k, 2) = x2
      else
        dss(i, j, k, 2) = -x2
      end if
      x3 = (ss(i, j, k+1)-two*ss(i, j, k)+ss(i, j, k-1))/(ss(i, j, k+1)+&
&       two*ss(i, j, k)+ss(i, j, k-1)+sslim)
      if (x3 .ge. 0.) then
        dss(i, j, k, 3) = x3
      else
        dss(i, j, k, 3) = -x3
      end if
    end do
! set a couple of constants for the scheme.
    fis2 = rfil*vis2
    fis4 = rfil*vis4
! initialize the dissipative residual to a certain times,
! possibly zero, the previously stored value. owned cells
! only, because the halo values do not matter.
    call pushinteger4(i)
    call pushinteger4(j)
    call pushinteger4(i)
    call pushinteger4(j)
    call pushreal8(dis4)
    call pushreal8(ddw2)
    call pushreal8(ddw3)
    call pushreal8(ddw4)
    call pushreal8(ddw5)
    call pushreal8(ppor)
    call pushinteger4(i)
    call pushinteger4(j)
    call pushreal8(dis4)
    call pushreal8(ddw2)
    call pushreal8(ddw3)
    call pushreal8(ddw4)
    call pushreal8(ddw5)
    call pushreal8(ppor)
    radkd = 0.0_8
    dssd = 0.0_8
    do ii=0,nx*ny*kl-1
      i = mod(ii, nx) + 2
      j = mod(ii/nx, ny) + 2
      k = ii/(nx*ny) + 1
! compute the dissipation coefficients for this face.
      ppor = zero
      if (pork(i, j, k) .eq. normalflux) ppor = half
      rrad = ppor*(radk(i, j, k)+radk(i, j, k+1))
      if (dss(i, j, k, 3) .lt. dss(i, j, k+1, 3)) then
        y3 = dss(i, j, k+1, 3)
        call pushcontrol1b(0)
      else
        y3 = dss(i, j, k, 3)
        call pushcontrol1b(1)
      end if
      if (dssmax .gt. y3) then
        min3 = y3
        call pushcontrol1b(0)
      else
        min3 = dssmax
        call pushcontrol1b(1)
      end if
      dis2 = fis2*rrad*min3
      arg1 = fis4*rrad
      dis4 = mydim(arg1, dis2)
! compute and scatter the dissipative flux.
! density. store it in the mass flow of the
! appropriate sliding mesh interface.
      ddw1 = w(i, j, k+1, irho) - w(i, j, k, irho)
! x-momentum.
      ddw2 = w(i, j, k+1, ivx)*w(i, j, k+1, irho) - w(i, j, k, ivx)*w(i&
&       , j, k, irho)
! y-momentum.
      ddw3 = w(i, j, k+1, ivy)*w(i, j, k+1, irho) - w(i, j, k, ivy)*w(i&
&       , j, k, irho)
! z-momentum.
      ddw4 = w(i, j, k+1, ivz)*w(i, j, k+1, irho) - w(i, j, k, ivz)*w(i&
&       , j, k, irho)
! energy.
      ddw5 = w(i, j, k+1, irhoe) + p(i, j, k+1) - (w(i, j, k, irhoe)+p(i&
&       , j, k))
      fsd = fwd(i, j, k+1, irhoe) - fwd(i, j, k, irhoe)
      tempd17 = -(dis4*fsd)
      dis2d = ddw5*fsd
      ddw5d = dis2*fsd - three*tempd17
      dis4d = -((w(i, j, k+2, irhoe)+p(i, j, k+2)-w(i, j, k-1, irhoe)-p(&
&       i, j, k-1)-three*ddw5)*fsd)
      wd(i, j, k+2, irhoe) = wd(i, j, k+2, irhoe) + tempd17
      pd(i, j, k+2) = pd(i, j, k+2) + tempd17
      wd(i, j, k-1, irhoe) = wd(i, j, k-1, irhoe) - tempd17
      pd(i, j, k-1) = pd(i, j, k-1) - tempd17
      wd(i, j, k+1, irhoe) = wd(i, j, k+1, irhoe) + ddw5d
      pd(i, j, k+1) = pd(i, j, k+1) + ddw5d
      wd(i, j, k, irhoe) = wd(i, j, k, irhoe) - ddw5d
      pd(i, j, k) = pd(i, j, k) - ddw5d
      fsd = fwd(i, j, k+1, imz) - fwd(i, j, k, imz)
      temp41 = w(i, j, k-1, irho)
      temp40 = w(i, j, k-1, ivz)
      temp39 = w(i, j, k+2, irho)
      temp38 = w(i, j, k+2, ivz)
      tempd18 = -(dis4*fsd)
      dis2d = dis2d + ddw4*fsd
      ddw4d = dis2*fsd - three*tempd18
      dis4d = dis4d - (temp38*temp39-temp40*temp41-three*ddw4)*fsd
      wd(i, j, k+2, ivz) = wd(i, j, k+2, ivz) + temp39*tempd18
      wd(i, j, k+2, irho) = wd(i, j, k+2, irho) + temp38*tempd18
      wd(i, j, k-1, ivz) = wd(i, j, k-1, ivz) - temp41*tempd18
      wd(i, j, k-1, irho) = wd(i, j, k-1, irho) - temp40*tempd18
      wd(i, j, k+1, ivz) = wd(i, j, k+1, ivz) + w(i, j, k+1, irho)*ddw4d
      wd(i, j, k+1, irho) = wd(i, j, k+1, irho) + w(i, j, k+1, ivz)*&
&       ddw4d
      wd(i, j, k, ivz) = wd(i, j, k, ivz) - w(i, j, k, irho)*ddw4d
      wd(i, j, k, irho) = wd(i, j, k, irho) - w(i, j, k, ivz)*ddw4d
      fsd = fwd(i, j, k+1, imy) - fwd(i, j, k, imy)
      temp37 = w(i, j, k-1, irho)
      temp36 = w(i, j, k-1, ivy)
      temp35 = w(i, j, k+2, irho)
      temp34 = w(i, j, k+2, ivy)
      tempd19 = -(dis4*fsd)
      dis2d = dis2d + ddw3*fsd
      ddw3d = dis2*fsd - three*tempd19
      dis4d = dis4d - (temp34*temp35-temp36*temp37-three*ddw3)*fsd
      wd(i, j, k+2, ivy) = wd(i, j, k+2, ivy) + temp35*tempd19
      wd(i, j, k+2, irho) = wd(i, j, k+2, irho) + temp34*tempd19
      wd(i, j, k-1, ivy) = wd(i, j, k-1, ivy) - temp37*tempd19
      wd(i, j, k-1, irho) = wd(i, j, k-1, irho) - temp36*tempd19
      wd(i, j, k+1, ivy) = wd(i, j, k+1, ivy) + w(i, j, k+1, irho)*ddw3d
      wd(i, j, k+1, irho) = wd(i, j, k+1, irho) + w(i, j, k+1, ivy)*&
&       ddw3d
      wd(i, j, k, ivy) = wd(i, j, k, ivy) - w(i, j, k, irho)*ddw3d
      wd(i, j, k, irho) = wd(i, j, k, irho) - w(i, j, k, ivy)*ddw3d
      fsd = fwd(i, j, k+1, imx) - fwd(i, j, k, imx)
      temp33 = w(i, j, k-1, irho)
      temp32 = w(i, j, k-1, ivx)
      temp31 = w(i, j, k+2, irho)
      temp30 = w(i, j, k+2, ivx)
      tempd20 = -(dis4*fsd)
      dis2d = dis2d + ddw2*fsd
      ddw2d = dis2*fsd - three*tempd20
      dis4d = dis4d - (temp30*temp31-temp32*temp33-three*ddw2)*fsd
      wd(i, j, k+2, ivx) = wd(i, j, k+2, ivx) + temp31*tempd20
      wd(i, j, k+2, irho) = wd(i, j, k+2, irho) + temp30*tempd20
      wd(i, j, k-1, ivx) = wd(i, j, k-1, ivx) - temp33*tempd20
      wd(i, j, k-1, irho) = wd(i, j, k-1, irho) - temp32*tempd20
      wd(i, j, k+1, ivx) = wd(i, j, k+1, ivx) + w(i, j, k+1, irho)*ddw2d
      wd(i, j, k+1, irho) = wd(i, j, k+1, irho) + w(i, j, k+1, ivx)*&
&       ddw2d
      wd(i, j, k, ivx) = wd(i, j, k, ivx) - w(i, j, k, irho)*ddw2d
      wd(i, j, k, irho) = wd(i, j, k, irho) - w(i, j, k, ivx)*ddw2d
      fsd = fwd(i, j, k+1, irho) - fwd(i, j, k, irho)
      tempd21 = -(dis4*fsd)
      dis2d = dis2d + ddw1*fsd
      ddw1d = dis2*fsd - three*tempd21
      dis4d = dis4d - (w(i, j, k+2, irho)-w(i, j, k-1, irho)-three*ddw1)&
&       *fsd
      wd(i, j, k+2, irho) = wd(i, j, k+2, irho) + tempd21
      wd(i, j, k-1, irho) = wd(i, j, k-1, irho) - tempd21
      wd(i, j, k+1, irho) = wd(i, j, k+1, irho) + ddw1d
      wd(i, j, k, irho) = wd(i, j, k, irho) - ddw1d
      arg1d = 0.0_8
      call mydim_b(arg1, arg1d, dis2, dis2d, dis4d)
      rradd = fis2*min3*dis2d + fis4*arg1d
      min3d = fis2*rrad*dis2d
      call popcontrol1b(branch)
      if (branch .eq. 0) then
        y3d = min3d
      else
        y3d = 0.0_8
      end if
      call popcontrol1b(branch)
      if (branch .eq. 0) then
        dssd(i, j, k+1, 3) = dssd(i, j, k+1, 3) + y3d
      else
        dssd(i, j, k, 3) = dssd(i, j, k, 3) + y3d
      end if
      radkd(i, j, k) = radkd(i, j, k) + ppor*rradd
      radkd(i, j, k+1) = radkd(i, j, k+1) + ppor*rradd
    end do
    call popreal8(ppor)
    call popreal8(ddw5)
    call popreal8(ddw4)
    call popreal8(ddw3)
    call popreal8(ddw2)
    call popreal8(dis4)
    call popinteger4(j)
    call popinteger4(i)
    radjd = 0.0_8
    do ii=0,nx*jl*nz-1
      i = mod(ii, nx) + 2
      j = mod(ii/nx, jl) + 1
      k = ii/(nx*jl) + 2
! compute the dissipation coefficients for this face.
      ppor = zero
      if (porj(i, j, k) .eq. normalflux) ppor = half
      rrad = ppor*(radj(i, j, k)+radj(i, j+1, k))
      if (dss(i, j, k, 2) .lt. dss(i, j+1, k, 2)) then
        y2 = dss(i, j+1, k, 2)
        call pushcontrol1b(0)
      else
        y2 = dss(i, j, k, 2)
        call pushcontrol1b(1)
      end if
      if (dssmax .gt. y2) then
        min2 = y2
        call pushcontrol1b(0)
      else
        min2 = dssmax
        call pushcontrol1b(1)
      end if
      dis2 = fis2*rrad*min2
      arg1 = fis4*rrad
      dis4 = mydim(arg1, dis2)
! compute and scatter the dissipative flux.
! density. store it in the mass flow of the
! appropriate sliding mesh interface.
      ddw1 = w(i, j+1, k, irho) - w(i, j, k, irho)
! x-momentum.
      ddw2 = w(i, j+1, k, ivx)*w(i, j+1, k, irho) - w(i, j, k, ivx)*w(i&
&       , j, k, irho)
! y-momentum.
      ddw3 = w(i, j+1, k, ivy)*w(i, j+1, k, irho) - w(i, j, k, ivy)*w(i&
&       , j, k, irho)
! z-momentum.
      ddw4 = w(i, j+1, k, ivz)*w(i, j+1, k, irho) - w(i, j, k, ivz)*w(i&
&       , j, k, irho)
! energy.
      ddw5 = w(i, j+1, k, irhoe) + p(i, j+1, k) - (w(i, j, k, irhoe)+p(i&
&       , j, k))
      fsd = fwd(i, j+1, k, irhoe) - fwd(i, j, k, irhoe)
      tempd12 = -(dis4*fsd)
      dis2d = ddw5*fsd
      ddw5d = dis2*fsd - three*tempd12
      dis4d = -((w(i, j+2, k, irhoe)+p(i, j+2, k)-w(i, j-1, k, irhoe)-p(&
&       i, j-1, k)-three*ddw5)*fsd)
      wd(i, j+2, k, irhoe) = wd(i, j+2, k, irhoe) + tempd12
      pd(i, j+2, k) = pd(i, j+2, k) + tempd12
      wd(i, j-1, k, irhoe) = wd(i, j-1, k, irhoe) - tempd12
      pd(i, j-1, k) = pd(i, j-1, k) - tempd12
      wd(i, j+1, k, irhoe) = wd(i, j+1, k, irhoe) + ddw5d
      pd(i, j+1, k) = pd(i, j+1, k) + ddw5d
      wd(i, j, k, irhoe) = wd(i, j, k, irhoe) - ddw5d
      pd(i, j, k) = pd(i, j, k) - ddw5d
      fsd = fwd(i, j+1, k, imz) - fwd(i, j, k, imz)
      temp29 = w(i, j-1, k, irho)
      temp28 = w(i, j-1, k, ivz)
      temp27 = w(i, j+2, k, irho)
      temp26 = w(i, j+2, k, ivz)
      tempd13 = -(dis4*fsd)
      dis2d = dis2d + ddw4*fsd
      ddw4d = dis2*fsd - three*tempd13
      dis4d = dis4d - (temp26*temp27-temp28*temp29-three*ddw4)*fsd
      wd(i, j+2, k, ivz) = wd(i, j+2, k, ivz) + temp27*tempd13
      wd(i, j+2, k, irho) = wd(i, j+2, k, irho) + temp26*tempd13
      wd(i, j-1, k, ivz) = wd(i, j-1, k, ivz) - temp29*tempd13
      wd(i, j-1, k, irho) = wd(i, j-1, k, irho) - temp28*tempd13
      wd(i, j+1, k, ivz) = wd(i, j+1, k, ivz) + w(i, j+1, k, irho)*ddw4d
      wd(i, j+1, k, irho) = wd(i, j+1, k, irho) + w(i, j+1, k, ivz)*&
&       ddw4d
      wd(i, j, k, ivz) = wd(i, j, k, ivz) - w(i, j, k, irho)*ddw4d
      wd(i, j, k, irho) = wd(i, j, k, irho) - w(i, j, k, ivz)*ddw4d
      fsd = fwd(i, j+1, k, imy) - fwd(i, j, k, imy)
      temp25 = w(i, j-1, k, irho)
      temp24 = w(i, j-1, k, ivy)
      temp23 = w(i, j+2, k, irho)
      temp22 = w(i, j+2, k, ivy)
      tempd14 = -(dis4*fsd)
      dis2d = dis2d + ddw3*fsd
      ddw3d = dis2*fsd - three*tempd14
      dis4d = dis4d - (temp22*temp23-temp24*temp25-three*ddw3)*fsd
      wd(i, j+2, k, ivy) = wd(i, j+2, k, ivy) + temp23*tempd14
      wd(i, j+2, k, irho) = wd(i, j+2, k, irho) + temp22*tempd14
      wd(i, j-1, k, ivy) = wd(i, j-1, k, ivy) - temp25*tempd14
      wd(i, j-1, k, irho) = wd(i, j-1, k, irho) - temp24*tempd14
      wd(i, j+1, k, ivy) = wd(i, j+1, k, ivy) + w(i, j+1, k, irho)*ddw3d
      wd(i, j+1, k, irho) = wd(i, j+1, k, irho) + w(i, j+1, k, ivy)*&
&       ddw3d
      wd(i, j, k, ivy) = wd(i, j, k, ivy) - w(i, j, k, irho)*ddw3d
      wd(i, j, k, irho) = wd(i, j, k, irho) - w(i, j, k, ivy)*ddw3d
      fsd = fwd(i, j+1, k, imx) - fwd(i, j, k, imx)
      temp21 = w(i, j-1, k, irho)
      temp20 = w(i, j-1, k, ivx)
      temp19 = w(i, j+2, k, irho)
      temp18 = w(i, j+2, k, ivx)
      tempd15 = -(dis4*fsd)
      dis2d = dis2d + ddw2*fsd
      ddw2d = dis2*fsd - three*tempd15
      dis4d = dis4d - (temp18*temp19-temp20*temp21-three*ddw2)*fsd
      wd(i, j+2, k, ivx) = wd(i, j+2, k, ivx) + temp19*tempd15
      wd(i, j+2, k, irho) = wd(i, j+2, k, irho) + temp18*tempd15
      wd(i, j-1, k, ivx) = wd(i, j-1, k, ivx) - temp21*tempd15
      wd(i, j-1, k, irho) = wd(i, j-1, k, irho) - temp20*tempd15
      wd(i, j+1, k, ivx) = wd(i, j+1, k, ivx) + w(i, j+1, k, irho)*ddw2d
      wd(i, j+1, k, irho) = wd(i, j+1, k, irho) + w(i, j+1, k, ivx)*&
&       ddw2d
      wd(i, j, k, ivx) = wd(i, j, k, ivx) - w(i, j, k, irho)*ddw2d
      wd(i, j, k, irho) = wd(i, j, k, irho) - w(i, j, k, ivx)*ddw2d
      fsd = fwd(i, j+1, k, irho) - fwd(i, j, k, irho)
      tempd16 = -(dis4*fsd)
      dis2d = dis2d + ddw1*fsd
      ddw1d = dis2*fsd - three*tempd16
      dis4d = dis4d - (w(i, j+2, k, irho)-w(i, j-1, k, irho)-three*ddw1)&
&       *fsd
      wd(i, j+2, k, irho) = wd(i, j+2, k, irho) + tempd16
      wd(i, j-1, k, irho) = wd(i, j-1, k, irho) - tempd16
      wd(i, j+1, k, irho) = wd(i, j+1, k, irho) + ddw1d
      wd(i, j, k, irho) = wd(i, j, k, irho) - ddw1d
      arg1d = 0.0_8
      call mydim_b(arg1, arg1d, dis2, dis2d, dis4d)
      rradd = fis2*min2*dis2d + fis4*arg1d
      min2d = fis2*rrad*dis2d
      call popcontrol1b(branch)
      if (branch .eq. 0) then
        y2d = min2d
      else
        y2d = 0.0_8
      end if
      call popcontrol1b(branch)
      if (branch .eq. 0) then
        dssd(i, j+1, k, 2) = dssd(i, j+1, k, 2) + y2d
      else
        dssd(i, j, k, 2) = dssd(i, j, k, 2) + y2d
      end if
      radjd(i, j, k) = radjd(i, j, k) + ppor*rradd
      radjd(i, j+1, k) = radjd(i, j+1, k) + ppor*rradd
    end do
    call popreal8(ppor)
    call popreal8(ddw5)
    call popreal8(ddw4)
    call popreal8(ddw3)
    call popreal8(ddw2)
    call popreal8(dis4)
    call popinteger4(j)
    call popinteger4(i)
    radid = 0.0_8
    do ii=0,il*ny*nz-1
      i = mod(ii, il) + 1
      j = mod(ii/il, ny) + 2
      k = ii/(il*ny) + 2
! compute the dissipation coefficients for this face.
      ppor = zero
      if (pori(i, j, k) .eq. normalflux) ppor = half
      rrad = ppor*(radi(i, j, k)+radi(i+1, j, k))
      if (dss(i, j, k, 1) .lt. dss(i+1, j, k, 1)) then
        y1 = dss(i+1, j, k, 1)
        call pushcontrol1b(0)
      else
        y1 = dss(i, j, k, 1)
        call pushcontrol1b(1)
      end if
      if (dssmax .gt. y1) then
        min1 = y1
        call pushcontrol1b(0)
      else
        min1 = dssmax
        call pushcontrol1b(1)
      end if
      dis2 = fis2*rrad*min1
      arg1 = fis4*rrad
      dis4 = mydim(arg1, dis2)
! compute and scatter the dissipative flux.
! density. store it in the mass flow of the
! appropriate sliding mesh interface.
      ddw1 = w(i+1, j, k, irho) - w(i, j, k, irho)
! x-momentum.
      ddw2 = w(i+1, j, k, ivx)*w(i+1, j, k, irho) - w(i, j, k, ivx)*w(i&
&       , j, k, irho)
! y-momentum.
      ddw3 = w(i+1, j, k, ivy)*w(i+1, j, k, irho) - w(i, j, k, ivy)*w(i&
&       , j, k, irho)
! z-momentum.
      ddw4 = w(i+1, j, k, ivz)*w(i+1, j, k, irho) - w(i, j, k, ivz)*w(i&
&       , j, k, irho)
! energy.
      ddw5 = w(i+1, j, k, irhoe) + p(i+1, j, k) - (w(i, j, k, irhoe)+p(i&
&       , j, k))
      fsd = fwd(i+1, j, k, irhoe) - fwd(i, j, k, irhoe)
      tempd7 = -(dis4*fsd)
      dis2d = ddw5*fsd
      ddw5d = dis2*fsd - three*tempd7
      dis4d = -((w(i+2, j, k, irhoe)+p(i+2, j, k)-w(i-1, j, k, irhoe)-p(&
&       i-1, j, k)-three*ddw5)*fsd)
      wd(i+2, j, k, irhoe) = wd(i+2, j, k, irhoe) + tempd7
      pd(i+2, j, k) = pd(i+2, j, k) + tempd7
      wd(i-1, j, k, irhoe) = wd(i-1, j, k, irhoe) - tempd7
      pd(i-1, j, k) = pd(i-1, j, k) - tempd7
      wd(i+1, j, k, irhoe) = wd(i+1, j, k, irhoe) + ddw5d
      pd(i+1, j, k) = pd(i+1, j, k) + ddw5d
      wd(i, j, k, irhoe) = wd(i, j, k, irhoe) - ddw5d
      pd(i, j, k) = pd(i, j, k) - ddw5d
      fsd = fwd(i+1, j, k, imz) - fwd(i, j, k, imz)
      temp17 = w(i-1, j, k, irho)
      temp16 = w(i-1, j, k, ivz)
      temp15 = w(i+2, j, k, irho)
      temp14 = w(i+2, j, k, ivz)
      tempd8 = -(dis4*fsd)
      dis2d = dis2d + ddw4*fsd
      ddw4d = dis2*fsd - three*tempd8
      dis4d = dis4d - (temp14*temp15-temp16*temp17-three*ddw4)*fsd
      wd(i+2, j, k, ivz) = wd(i+2, j, k, ivz) + temp15*tempd8
      wd(i+2, j, k, irho) = wd(i+2, j, k, irho) + temp14*tempd8
      wd(i-1, j, k, ivz) = wd(i-1, j, k, ivz) - temp17*tempd8
      wd(i-1, j, k, irho) = wd(i-1, j, k, irho) - temp16*tempd8
      wd(i+1, j, k, ivz) = wd(i+1, j, k, ivz) + w(i+1, j, k, irho)*ddw4d
      wd(i+1, j, k, irho) = wd(i+1, j, k, irho) + w(i+1, j, k, ivz)*&
&       ddw4d
      wd(i, j, k, ivz) = wd(i, j, k, ivz) - w(i, j, k, irho)*ddw4d
      wd(i, j, k, irho) = wd(i, j, k, irho) - w(i, j, k, ivz)*ddw4d
      fsd = fwd(i+1, j, k, imy) - fwd(i, j, k, imy)
      temp13 = w(i-1, j, k, irho)
      temp12 = w(i-1, j, k, ivy)
      temp11 = w(i+2, j, k, irho)
      temp10 = w(i+2, j, k, ivy)
      tempd9 = -(dis4*fsd)
      dis2d = dis2d + ddw3*fsd
      ddw3d = dis2*fsd - three*tempd9
      dis4d = dis4d - (temp10*temp11-temp12*temp13-three*ddw3)*fsd
      wd(i+2, j, k, ivy) = wd(i+2, j, k, ivy) + temp11*tempd9
      wd(i+2, j, k, irho) = wd(i+2, j, k, irho) + temp10*tempd9
      wd(i-1, j, k, ivy) = wd(i-1, j, k, ivy) - temp13*tempd9
      wd(i-1, j, k, irho) = wd(i-1, j, k, irho) - temp12*tempd9
      wd(i+1, j, k, ivy) = wd(i+1, j, k, ivy) + w(i+1, j, k, irho)*ddw3d
      wd(i+1, j, k, irho) = wd(i+1, j, k, irho) + w(i+1, j, k, ivy)*&
&       ddw3d
      wd(i, j, k, ivy) = wd(i, j, k, ivy) - w(i, j, k, irho)*ddw3d
      wd(i, j, k, irho) = wd(i, j, k, irho) - w(i, j, k, ivy)*ddw3d
      fsd = fwd(i+1, j, k, imx) - fwd(i, j, k, imx)
      temp9 = w(i-1, j, k, irho)
      temp8 = w(i-1, j, k, ivx)
      temp7 = w(i+2, j, k, irho)
      temp6 = w(i+2, j, k, ivx)
      tempd10 = -(dis4*fsd)
      dis2d = dis2d + ddw2*fsd
      ddw2d = dis2*fsd - three*tempd10
      dis4d = dis4d - (temp6*temp7-temp8*temp9-three*ddw2)*fsd
      wd(i+2, j, k, ivx) = wd(i+2, j, k, ivx) + temp7*tempd10
      wd(i+2, j, k, irho) = wd(i+2, j, k, irho) + temp6*tempd10
      wd(i-1, j, k, ivx) = wd(i-1, j, k, ivx) - temp9*tempd10
      wd(i-1, j, k, irho) = wd(i-1, j, k, irho) - temp8*tempd10
      wd(i+1, j, k, ivx) = wd(i+1, j, k, ivx) + w(i+1, j, k, irho)*ddw2d
      wd(i+1, j, k, irho) = wd(i+1, j, k, irho) + w(i+1, j, k, ivx)*&
&       ddw2d
      wd(i, j, k, ivx) = wd(i, j, k, ivx) - w(i, j, k, irho)*ddw2d
      wd(i, j, k, irho) = wd(i, j, k, irho) - w(i, j, k, ivx)*ddw2d
      fsd = fwd(i+1, j, k, irho) - fwd(i, j, k, irho)
      tempd11 = -(dis4*fsd)
      dis2d = dis2d + ddw1*fsd
      ddw1d = dis2*fsd - three*tempd11
      dis4d = dis4d - (w(i+2, j, k, irho)-w(i-1, j, k, irho)-three*ddw1)&
&       *fsd
      wd(i+2, j, k, irho) = wd(i+2, j, k, irho) + tempd11
      wd(i-1, j, k, irho) = wd(i-1, j, k, irho) - tempd11
      wd(i+1, j, k, irho) = wd(i+1, j, k, irho) + ddw1d
      wd(i, j, k, irho) = wd(i, j, k, irho) - ddw1d
      arg1d = 0.0_8
      call mydim_b(arg1, arg1d, dis2, dis2d, dis4d)
      rradd = fis2*min1*dis2d + fis4*arg1d
      min1d = fis2*rrad*dis2d
      call popcontrol1b(branch)
      if (branch .eq. 0) then
        y1d = min1d
      else
        y1d = 0.0_8
      end if
      call popcontrol1b(branch)
      if (branch .eq. 0) then
        dssd(i+1, j, k, 1) = dssd(i+1, j, k, 1) + y1d
      else
        dssd(i, j, k, 1) = dssd(i, j, k, 1) + y1d
      end if
      radid(i, j, k) = radid(i, j, k) + ppor*rradd
      radid(i+1, j, k) = radid(i+1, j, k) + ppor*rradd
    end do
    call popinteger4(j)
    call popinteger4(i)
    sslimd = 0.0_8
    ssd = 0.0_8
    do ii=0,ie*je*ke-1
      i = mod(ii, ie) + 1
      j = mod(ii/ie, je) + 1
      k = ii/(ie*je) + 1
      x1 = (ss(i+1, j, k)-two*ss(i, j, k)+ss(i-1, j, k))/(ss(i+1, j, k)+&
&       two*ss(i, j, k)+ss(i-1, j, k)+sslim)
      if (x1 .ge. 0.) then
        call pushcontrol1b(0)
      else
        call pushcontrol1b(1)
      end if
      x2 = (ss(i, j+1, k)-two*ss(i, j, k)+ss(i, j-1, k))/(ss(i, j+1, k)+&
&       two*ss(i, j, k)+ss(i, j-1, k)+sslim)
      if (x2 .ge. 0.) then
        call pushcontrol1b(0)
      else
        call pushcontrol1b(1)
      end if
      x3 = (ss(i, j, k+1)-two*ss(i, j, k)+ss(i, j, k-1))/(ss(i, j, k+1)+&
&       two*ss(i, j, k)+ss(i, j, k-1)+sslim)
      if (x3 .ge. 0.) then
        x3d = dssd(i, j, k, 3)
        dssd(i, j, k, 3) = 0.0_8
      else
        x3d = -dssd(i, j, k, 3)
        dssd(i, j, k, 3) = 0.0_8
      end if
      temp5 = ss(i, j, k+1) + two*ss(i, j, k) + ss(i, j, k-1) + sslim
      tempd5 = x3d/temp5
      tempd6 = -((ss(i, j, k+1)-two*ss(i, j, k)+ss(i, j, k-1))*tempd5/&
&       temp5)
      ssd(i, j, k+1) = ssd(i, j, k+1) + tempd6 + tempd5
      ssd(i, j, k) = ssd(i, j, k) + two*tempd6 - two*tempd5
      ssd(i, j, k-1) = ssd(i, j, k-1) + tempd6 + tempd5
      sslimd = sslimd + tempd6
      call popcontrol1b(branch)
      if (branch .eq. 0) then
        x2d = dssd(i, j, k, 2)
        dssd(i, j, k, 2) = 0.0_8
      else
        x2d = -dssd(i, j, k, 2)
        dssd(i, j, k, 2) = 0.0_8
      end if
      temp4 = ss(i, j+1, k) + two*ss(i, j, k) + ss(i, j-1, k) + sslim
      tempd3 = x2d/temp4
      tempd4 = -((ss(i, j+1, k)-two*ss(i, j, k)+ss(i, j-1, k))*tempd3/&
&       temp4)
      ssd(i, j+1, k) = ssd(i, j+1, k) + tempd4 + tempd3
      ssd(i, j, k) = ssd(i, j, k) + two*tempd4 - two*tempd3
      ssd(i, j-1, k) = ssd(i, j-1, k) + tempd4 + tempd3
      sslimd = sslimd + tempd4
      call popcontrol1b(branch)
      if (branch .eq. 0) then
        x1d = dssd(i, j, k, 1)
        dssd(i, j, k, 1) = 0.0_8
      else
        x1d = -dssd(i, j, k, 1)
        dssd(i, j, k, 1) = 0.0_8
      end if
      temp3 = ss(i+1, j, k) + two*ss(i, j, k) + ss(i-1, j, k) + sslim
      tempd1 = x1d/temp3
      tempd2 = -((ss(i+1, j, k)-two*ss(i, j, k)+ss(i-1, j, k))*tempd1/&
&       temp3)
      ssd(i+1, j, k) = ssd(i+1, j, k) + tempd2 + tempd1
      ssd(i, j, k) = ssd(i, j, k) + two*tempd2 - two*tempd1
      ssd(i-1, j, k) = ssd(i-1, j, k) + tempd2 + tempd1
      sslimd = sslimd + tempd2
    end do
    call popinteger4(j)
    call popinteger4(i)
    call popcontrol2b(branch)
    if (branch .eq. 0) then
      do ii=0,(ib+1)*(jb+1)*(kb+1)-1
        i = mod(ii, ib + 1)
        j = mod(ii/(ib+1), jb + 1)
        k = ii/((ib+1)*(jb+1))
        temp2 = gamma(i, j, k)
        temp1 = w(i, j, k, irho)
        temp0 = temp1**temp2
        pd(i, j, k) = pd(i, j, k) + ssd(i, j, k)/temp0
        if (.not.(temp1 .le. 0.0_8 .and. (temp2 .eq. 0.0_8 .or. temp2 &
&           .ne. int(temp2)))) wd(i, j, k, irho) = wd(i, j, k, irho) - p&
&           (i, j, k)*temp2*temp1**(temp2-1)*ssd(i, j, k)/temp0**2
        ssd(i, j, k) = 0.0_8
      end do
      temp = rhoinf**gammainf
      tempd = 0.001_realtype*sslimd/temp
      tempd0 = -(pinfcorr*tempd/temp)
      pinfcorrd = tempd
      if (rhoinf .le. 0.0_8 .and. (gammainf .eq. 0.0_8 .or. gammainf &
&         .ne. int(gammainf))) then
        rhoinfd = 0.0
      else
        rhoinfd = gammainf*rhoinf**(gammainf-1)*tempd0
      end if
      if (.not.rhoinf .le. 0.0_8) gammainfd = gammainfd + temp*log(&
&         rhoinf)*tempd0
    else if (branch .eq. 1) then
      pd = pd + ssd
      pinfcorrd = 0.001_realtype*sslimd
      rhoinfd = 0.0_8
    else
      rhoinfd = 0.0_8
      pinfcorrd = 0.0_8
    end if
  end if
end subroutine invisciddissfluxscalar_b
