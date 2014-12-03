   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.10 (r5363) -  9 Sep 2014 09:53
   !
   !  Differentiation of viscousfluxapprox in reverse (adjoint) mode (with options i4 dr8 r8 noISIZE):
   !   gradient     of useful results: *p *gamma *w *x *si *sj *sk
   !                *fw
   !   with respect to varying inputs: *rev *p *gamma *w *rlv *x *si
   !                *sj *sk *fw
   !   Plus diff mem management of: rev:in p:in gamma:in w:in rlv:in
   !                x:in si:in sj:in sk:in fw:in
   SUBROUTINE VISCOUSFLUXAPPROX_B()
   USE BLOCKPOINTERS_B
   USE FLOWVARREFSTATE
   USE INPUTPHYSICS
   USE ITERATION
   IMPLICIT NONE
   !
   !      Local parameter.
   !
   REAL(kind=realtype), PARAMETER :: twothird=two*third
   !
   !      Local variables.
   !
   INTEGER(kind=inttype) :: i, j, k
   INTEGER(kind=inttype) :: ii, jj, kk
   REAL(kind=realtype) :: rfilv, por, mul, mue, mut, heatcoef
   REAL(kind=realtype) :: mulb, mueb, mutb, heatcoefb
   REAL(kind=realtype) :: gm1, factlamheat, factturbheat
   REAL(kind=realtype) :: gm1b, factlamheatb, factturbheatb
   REAL(kind=realtype) :: u_x, u_y, u_z, v_x, v_y, v_z, w_x, w_y, w_z
   REAL(kind=realtype) :: u_xb, u_yb, u_zb, v_xb, v_yb, v_zb, w_xb, w_yb&
   & , w_zb
   REAL(kind=realtype) :: q_x, q_y, q_z, ubar, vbar, wbar
   REAL(kind=realtype) :: q_xb, q_yb, q_zb, ubarb, vbarb, wbarb
   REAL(kind=realtype) :: corr, ssx, ssy, ssz, ss, fracdiv
   REAL(kind=realtype) :: ssxb, ssyb, sszb, ssb, fracdivb
   REAL(kind=realtype) :: tauxx, tauyy, tauzz
   REAL(kind=realtype) :: tauxxb, tauyyb, tauzzb
   REAL(kind=realtype) :: tauxy, tauxz, tauyz
   REAL(kind=realtype) :: tauxyb, tauxzb, tauyzb
   REAL(kind=realtype) :: fmx, fmy, fmz, frhoe
   REAL(kind=realtype) :: fmxb, fmyb, fmzb, frhoeb
   REAL(kind=realtype) :: dd
   REAL(kind=realtype) :: ddb
   LOGICAL :: correctfork
   INTRINSIC ABS
   INTEGER :: branch
   REAL(kind=realtype) :: temp3
   REAL(kind=realtype) :: temp2
   REAL(kind=realtype) :: temp1
   REAL(kind=realtype) :: temp0
   REAL(kind=realtype) :: tempb9
   REAL(kind=realtype) :: tempb8
   REAL(kind=realtype) :: tempb7
   REAL(kind=realtype) :: tempb6
   REAL(kind=realtype) :: tempb5
   REAL(kind=realtype) :: tempb4
   REAL(kind=realtype) :: tempb19
   REAL(kind=realtype) :: tempb3
   REAL(kind=realtype) :: tempb18
   REAL(kind=realtype) :: tempb2
   REAL(kind=realtype) :: tempb17
   REAL(kind=realtype) :: tempb1
   REAL(kind=realtype) :: tempb16
   REAL(kind=realtype) :: tempb0
   REAL(kind=realtype) :: tempb15
   REAL(kind=realtype) :: tempb14
   REAL(kind=realtype) :: tempb13
   REAL(kind=realtype) :: tempb12
   REAL(kind=realtype) :: tempb11
   REAL(kind=realtype) :: tempb10
   REAL(kind=realtype) :: tempb
   REAL(kind=realtype) :: abs0
   REAL(kind=realtype) :: temp
   REAL(kind=realtype) :: tempb24
   REAL(kind=realtype) :: tempb23
   REAL(kind=realtype) :: tempb22
   REAL(kind=realtype) :: tempb21
   REAL(kind=realtype) :: tempb20
   REAL(kind=realtype) :: temp4
   ! Set rFilv to rFil to indicate that this is the viscous part.
   ! If rFilv == 0 the viscous residuals need not to be computed
   ! and a return can be made.
   rfilv = rfil
   IF (rfilv .GE. 0.) THEN
   abs0 = rfilv
   ELSE
   abs0 = -rfilv
   END IF
   IF (abs0 .LT. thresholdreal) THEN
   revb = 0.0_8
   rlvb = 0.0_8
   ELSE
   ! Determine whether or not the pressure must be corrected
   ! for the presence of the turbulent kinetic energy.
   IF (kpresent) THEN
   IF (currentlevel .LE. groundlevel .OR. turbcoupled) THEN
   correctfork = .true.
   ELSE
   correctfork = .false.
   END IF
   ELSE
   correctfork = .false.
   END IF
   ! Store the speed of sound squared instead of the pressure.
   ! To be 100 percent correct, substract 2/3*rho*k (if present)
   ! from the pressure to obtain the true presssure. First layer of
   ! halo's, because that's what is needed by the viscous stencil.
   DO k=1,ke
   DO j=1,je
   DO i=1,ie
   IF (correctfork) THEN
   CALL PUSHREAL8(p(i, j, k))
   p(i, j, k) = p(i, j, k) - twothird*w(i, j, k, irho)*w(i, j, &
   &             k, itu1)
   CALL PUSHCONTROL1B(0)
   ELSE
   CALL PUSHCONTROL1B(1)
   END IF
   CALL PUSHREAL8(p(i, j, k))
   p(i, j, k) = gamma(i, j, k)*p(i, j, k)/w(i, j, k, irho)
   END DO
   END DO
   END DO
   mue = zero
   ! Viscous fluxes in the I-direction
   DO k=2,kl
   DO j=2,jl
   DO i=1,il
   ! Compute the vector from the center of cell i to cell i+1           
   CALL PUSHREAL8(ssx)
   ssx = eighth*(x(i+1, j-1, k-1, 1)-x(i-1, j-1, k-1, 1)+x(i+1, j&
   &           -1, k, 1)-x(i-1, j-1, k, 1)+x(i+1, j, k-1, 1)-x(i-1, j, k-1&
   &           , 1)+x(i+1, j, k, 1)-x(i-1, j, k, 1))
   CALL PUSHREAL8(ssy)
   ssy = eighth*(x(i+1, j-1, k-1, 2)-x(i-1, j-1, k-1, 2)+x(i+1, j&
   &           -1, k, 2)-x(i-1, j-1, k, 2)+x(i+1, j, k-1, 2)-x(i-1, j, k-1&
   &           , 2)+x(i+1, j, k, 2)-x(i-1, j, k, 2))
   CALL PUSHREAL8(ssz)
   ssz = eighth*(x(i+1, j-1, k-1, 3)-x(i-1, j-1, k-1, 3)+x(i+1, j&
   &           -1, k, 3)-x(i-1, j-1, k, 3)+x(i+1, j, k-1, 3)-x(i-1, j, k-1&
   &           , 3)+x(i+1, j, k, 3)-x(i-1, j, k, 3))
   ! And determine one/ length of vector squared
   CALL PUSHREAL8(ss)
   ss = one/(ssx*ssx+ssy*ssy+ssz*ssz)
   CALL PUSHREAL8(ssx)
   ssx = ss*ssx
   CALL PUSHREAL8(ssy)
   ssy = ss*ssy
   CALL PUSHREAL8(ssz)
   ssz = ss*ssz
   ! Now compute each gradient
   dd = w(i+1, j, k, ivx) - w(i, j, k, ivx)
   CALL PUSHREAL8(u_x)
   u_x = dd*ssx
   CALL PUSHREAL8(u_y)
   u_y = dd*ssy
   CALL PUSHREAL8(u_z)
   u_z = dd*ssz
   dd = w(i+1, j, k, ivy) - w(i, j, k, ivy)
   CALL PUSHREAL8(v_x)
   v_x = dd*ssx
   CALL PUSHREAL8(v_y)
   v_y = dd*ssy
   CALL PUSHREAL8(v_z)
   v_z = dd*ssz
   dd = w(i+1, j, k, ivz) - w(i, j, k, ivz)
   CALL PUSHREAL8(w_x)
   w_x = dd*ssx
   CALL PUSHREAL8(w_y)
   w_y = dd*ssy
   CALL PUSHREAL8(w_z)
   w_z = dd*ssz
   dd = p(i+1, j, k) - p(i, j, k)
   CALL PUSHREAL8(q_x)
   q_x = -(dd*ssx)
   CALL PUSHREAL8(q_y)
   q_y = -(dd*ssy)
   CALL PUSHREAL8(q_z)
   q_z = -(dd*ssz)
   CALL PUSHREAL8(por)
   por = half*rfilv
   IF (pori(i, j, k) .EQ. noflux) por = zero
   ! Compute the laminar and (if present) the eddy viscosities
   ! multiplied by the porosity. Compute the factor in front of
   ! the gradients of the speed of sound squared for the heat
   ! flux.
   mul = por*(rlv(i, j, k)+rlv(i+1, j, k))
   IF (eddymodel) THEN
   CALL PUSHREAL8(mue)
   mue = por*(rev(i, j, k)+rev(i+1, j, k))
   CALL PUSHCONTROL1B(0)
   ELSE
   CALL PUSHCONTROL1B(1)
   END IF
   CALL PUSHREAL8(mut)
   gm1 = half*(gamma(i, j, k)+gamma(i+1, j, k)) - one
   factlamheat = one/(prandtl*gm1)
   factturbheat = one/(prandtlturb*gm1)
   heatcoef = mul*factlamheat + mue*factturbheat
   ! Compute the stress tensor and the heat flux vector.
   CALL PUSHREAL8(fracdiv)
   fracdiv = twothird*(u_x+v_y+w_z)
   CALL PUSHREAL8(q_x)
   q_x = heatcoef*q_x
   CALL PUSHREAL8(q_y)
   q_y = heatcoef*q_y
   CALL PUSHREAL8(q_z)
   q_z = heatcoef*q_z
   ! Compute the average velocities for the face. Remember that
   ! the velocities are stored and not the momentum.
   ! Compute the viscous fluxes for this i-face.
   ! Update the residuals of cell i and i+1.
   END DO
   END DO
   END DO
   ! Viscous fluxes in the J-direction
   DO k=2,kl
   DO j=1,jl
   DO i=2,il
   ! Compute the vector from the center of cell j to cell j+1           
   CALL PUSHREAL8(ssx)
   ssx = eighth*(x(i-1, j+1, k-1, 1)-x(i-1, j-1, k-1, 1)+x(i-1, j&
   &           +1, k, 1)-x(i-1, j-1, k, 1)+x(i, j+1, k-1, 1)-x(i, j-1, k-1&
   &           , 1)+x(i, j+1, k, 1)-x(i, j-1, k, 1))
   CALL PUSHREAL8(ssy)
   ssy = eighth*(x(i-1, j+1, k-1, 2)-x(i-1, j-1, k-1, 2)+x(i-1, j&
   &           +1, k, 2)-x(i-1, j-1, k, 2)+x(i, j+1, k-1, 2)-x(i, j-1, k-1&
   &           , 2)+x(i, j+1, k, 2)-x(i, j-1, k, 2))
   CALL PUSHREAL8(ssz)
   ssz = eighth*(x(i-1, j+1, k-1, 3)-x(i-1, j-1, k-1, 3)+x(i-1, j&
   &           +1, k, 3)-x(i-1, j-1, k, 3)+x(i, j+1, k-1, 3)-x(i, j-1, k-1&
   &           , 3)+x(i, j+1, k, 3)-x(i, j-1, k, 3))
   ! And determine one/ length of vector squared
   CALL PUSHREAL8(ss)
   ss = one/(ssx*ssx+ssy*ssy+ssz*ssz)
   CALL PUSHREAL8(ssx)
   ssx = ss*ssx
   CALL PUSHREAL8(ssy)
   ssy = ss*ssy
   CALL PUSHREAL8(ssz)
   ssz = ss*ssz
   ! Now compute each gradient
   dd = w(i, j+1, k, ivx) - w(i, j, k, ivx)
   CALL PUSHREAL8(u_x)
   u_x = dd*ssx
   CALL PUSHREAL8(u_y)
   u_y = dd*ssy
   CALL PUSHREAL8(u_z)
   u_z = dd*ssz
   dd = w(i, j+1, k, ivy) - w(i, j, k, ivy)
   CALL PUSHREAL8(v_x)
   v_x = dd*ssx
   CALL PUSHREAL8(v_y)
   v_y = dd*ssy
   CALL PUSHREAL8(v_z)
   v_z = dd*ssz
   dd = w(i, j+1, k, ivz) - w(i, j, k, ivz)
   CALL PUSHREAL8(w_x)
   w_x = dd*ssx
   CALL PUSHREAL8(w_y)
   w_y = dd*ssy
   CALL PUSHREAL8(w_z)
   w_z = dd*ssz
   dd = p(i, j+1, k) - p(i, j, k)
   CALL PUSHREAL8(q_x)
   q_x = -(dd*ssx)
   CALL PUSHREAL8(q_y)
   q_y = -(dd*ssy)
   CALL PUSHREAL8(q_z)
   q_z = -(dd*ssz)
   CALL PUSHREAL8(por)
   por = half*rfilv
   IF (porj(i, j, k) .EQ. noflux) por = zero
   ! Compute the laminar and (if present) the eddy viscosities
   ! multiplied by the porosity. Compute the factor in front of
   ! the gradients of the speed of sound squared for the heat
   ! flux.
   mul = por*(rlv(i, j, k)+rlv(i, j+1, k))
   IF (eddymodel) THEN
   CALL PUSHREAL8(mue)
   mue = por*(rev(i, j, k)+rev(i, j+1, k))
   CALL PUSHCONTROL1B(0)
   ELSE
   CALL PUSHCONTROL1B(1)
   END IF
   CALL PUSHREAL8(mut)
   gm1 = half*(gamma(i, j, k)+gamma(i, j+1, k)) - one
   factlamheat = one/(prandtl*gm1)
   factturbheat = one/(prandtlturb*gm1)
   heatcoef = mul*factlamheat + mue*factturbheat
   ! Compute the stress tensor and the heat flux vector.
   CALL PUSHREAL8(fracdiv)
   fracdiv = twothird*(u_x+v_y+w_z)
   CALL PUSHREAL8(q_x)
   q_x = heatcoef*q_x
   CALL PUSHREAL8(q_y)
   q_y = heatcoef*q_y
   CALL PUSHREAL8(q_z)
   q_z = heatcoef*q_z
   ! Compute the average velocities for the face. Remember that
   ! the velocities are stored and not the momentum.
   ! Compute the viscous fluxes for this j-face.
   ! Update the residuals of cell j and j+1.
   END DO
   END DO
   END DO
   ! Viscous fluxes in the K-direction
   DO k=1,kl
   DO j=2,jl
   DO i=2,il
   ! Compute the vector from the center of cell k to cell k+1           
   CALL PUSHREAL8(ssx)
   ssx = eighth*(x(i-1, j-1, k+1, 1)-x(i-1, j-1, k-1, 1)+x(i-1, j&
   &           , k+1, 1)-x(i-1, j, k-1, 1)+x(i, j-1, k+1, 1)-x(i, j-1, k-1&
   &           , 1)+x(i, j, k+1, 1)-x(i, j, k-1, 1))
   CALL PUSHREAL8(ssy)
   ssy = eighth*(x(i-1, j-1, k+1, 2)-x(i-1, j-1, k-1, 2)+x(i-1, j&
   &           , k+1, 2)-x(i-1, j, k-1, 2)+x(i, j-1, k+1, 2)-x(i, j-1, k-1&
   &           , 2)+x(i, j, k+1, 2)-x(i, j, k-1, 2))
   CALL PUSHREAL8(ssz)
   ssz = eighth*(x(i-1, j-1, k+1, 3)-x(i-1, j-1, k-1, 3)+x(i-1, j&
   &           , k+1, 3)-x(i-1, j, k-1, 3)+x(i, j-1, k+1, 3)-x(i, j-1, k-1&
   &           , 3)+x(i, j, k+1, 3)-x(i, j, k-1, 3))
   ! And determine one/ length of vector squared
   CALL PUSHREAL8(ss)
   ss = one/(ssx*ssx+ssy*ssy+ssz*ssz)
   CALL PUSHREAL8(ssx)
   ssx = ss*ssx
   CALL PUSHREAL8(ssy)
   ssy = ss*ssy
   CALL PUSHREAL8(ssz)
   ssz = ss*ssz
   ! Now compute each gradient
   dd = w(i, j, k+1, ivx) - w(i, j, k, ivx)
   CALL PUSHREAL8(u_x)
   u_x = dd*ssx
   CALL PUSHREAL8(u_y)
   u_y = dd*ssy
   CALL PUSHREAL8(u_z)
   u_z = dd*ssz
   dd = w(i, j, k+1, ivy) - w(i, j, k, ivy)
   CALL PUSHREAL8(v_x)
   v_x = dd*ssx
   CALL PUSHREAL8(v_y)
   v_y = dd*ssy
   CALL PUSHREAL8(v_z)
   v_z = dd*ssz
   dd = w(i, j, k+1, ivz) - w(i, j, k, ivz)
   CALL PUSHREAL8(w_x)
   w_x = dd*ssx
   CALL PUSHREAL8(w_y)
   w_y = dd*ssy
   CALL PUSHREAL8(w_z)
   w_z = dd*ssz
   dd = p(i, j, k+1) - p(i, j, k)
   CALL PUSHREAL8(q_x)
   q_x = -(dd*ssx)
   CALL PUSHREAL8(q_y)
   q_y = -(dd*ssy)
   CALL PUSHREAL8(q_z)
   q_z = -(dd*ssz)
   CALL PUSHREAL8(por)
   por = half*rfilv
   IF (pork(i, j, k) .EQ. noflux) por = zero
   ! Compute the laminar and (if present) the eddy viscosities
   ! multiplied by the porosity. Compute the factor in front of
   ! the gradients of the speed of sound squared for the heat
   ! flux.
   mul = por*(rlv(i, j, k)+rlv(i, j, k+1))
   IF (eddymodel) THEN
   CALL PUSHREAL8(mue)
   mue = por*(rev(i, j, k)+rev(i, j, k+1))
   CALL PUSHCONTROL1B(0)
   ELSE
   CALL PUSHCONTROL1B(1)
   END IF
   CALL PUSHREAL8(mut)
   gm1 = half*(gamma(i, j, k)+gamma(i, j, k+1)) - one
   factlamheat = one/(prandtl*gm1)
   factturbheat = one/(prandtlturb*gm1)
   heatcoef = mul*factlamheat + mue*factturbheat
   ! Compute the stress tensor and the heat flux vector.
   CALL PUSHREAL8(fracdiv)
   fracdiv = twothird*(u_x+v_y+w_z)
   CALL PUSHREAL8(q_x)
   q_x = heatcoef*q_x
   CALL PUSHREAL8(q_y)
   q_y = heatcoef*q_y
   CALL PUSHREAL8(q_z)
   q_z = heatcoef*q_z
   ! Compute the average velocities for the face. Remember that
   ! the velocities are stored and not the momentum.
   ! Compute the viscous fluxes for this j-face.
   ! Update the residuals of cell j and j+1.
   END DO
   END DO
   END DO
   ! Restore the pressure in p. Again only the first layer of
   ! halo cells.
   DO k=1,ke
   DO j=1,je
   DO i=1,ie
   CALL PUSHREAL8(p(i, j, k))
   p(i, j, k) = w(i, j, k, irho)*p(i, j, k)/gamma(i, j, k)
   END DO
   END DO
   END DO
   IF (correctfork) THEN
   DO k=ke,1,-1
   DO j=je,1,-1
   DO i=ie,1,-1
   wb(i, j, k, irho) = wb(i, j, k, irho) + twothird*w(i, j, k, &
   &             itu1)*pb(i, j, k)
   wb(i, j, k, itu1) = wb(i, j, k, itu1) + twothird*w(i, j, k, &
   &             irho)*pb(i, j, k)
   END DO
   END DO
   END DO
   END IF
   DO k=ke,1,-1
   DO j=je,1,-1
   DO i=ie,1,-1
   CALL POPREAL8(p(i, j, k))
   temp4 = gamma(i, j, k)
   temp3 = p(i, j, k)/temp4
   tempb24 = w(i, j, k, irho)*pb(i, j, k)/temp4
   wb(i, j, k, irho) = wb(i, j, k, irho) + temp3*pb(i, j, k)
   gammab(i, j, k) = gammab(i, j, k) - temp3*tempb24
   pb(i, j, k) = tempb24
   END DO
   END DO
   END DO
   revb = 0.0_8
   rlvb = 0.0_8
   mueb = 0.0_8
   DO k=kl,1,-1
   DO j=jl,2,-1
   DO i=il,2,-1
   frhoeb = fwb(i, j, k+1, irhoe) - fwb(i, j, k, irhoe)
   fmzb = fwb(i, j, k+1, imz) - fwb(i, j, k, imz)
   fmyb = fwb(i, j, k+1, imy) - fwb(i, j, k, imy)
   fmxb = fwb(i, j, k+1, imx) - fwb(i, j, k, imx)
   mul = por*(rlv(i, j, k)+rlv(i, j, k+1))
   mut = mul + mue
   tauzz = mut*(two*w_z-fracdiv)
   wbar = half*(w(i, j, k, ivz)+w(i, j, k+1, ivz))
   vbar = half*(w(i, j, k, ivy)+w(i, j, k+1, ivy))
   tauxx = mut*(two*u_x-fracdiv)
   tauxy = mut*(u_y+v_x)
   tauxz = mut*(u_z+w_x)
   ubar = half*(w(i, j, k, ivx)+w(i, j, k+1, ivx))
   tauyy = mut*(two*v_y-fracdiv)
   tauyz = mut*(v_z+w_y)
   tempb20 = sk(i, j, k, 1)*frhoeb
   tempb21 = sk(i, j, k, 2)*frhoeb
   tempb22 = sk(i, j, k, 3)*frhoeb
   ubarb = tauxz*tempb22 + tauxy*tempb21 + tauxx*tempb20
   tauxxb = sk(i, j, k, 1)*fmxb + ubar*tempb20
   vbarb = tauyz*tempb22 + tauyy*tempb21 + tauxy*tempb20
   tauxyb = sk(i, j, k, 1)*fmyb + sk(i, j, k, 2)*fmxb + ubar*&
   &           tempb21 + vbar*tempb20
   wbarb = tauzz*tempb22 + tauyz*tempb21 + tauxz*tempb20
   tauxzb = sk(i, j, k, 1)*fmzb + sk(i, j, k, 3)*fmxb + ubar*&
   &           tempb22 + wbar*tempb20
   skb(i, j, k, 1) = skb(i, j, k, 1) + (ubar*tauxx-q_x+vbar*tauxy&
   &           +wbar*tauxz)*frhoeb
   tauyyb = sk(i, j, k, 2)*fmyb + vbar*tempb21
   tauyzb = sk(i, j, k, 2)*fmzb + sk(i, j, k, 3)*fmyb + vbar*&
   &           tempb22 + wbar*tempb21
   skb(i, j, k, 2) = skb(i, j, k, 2) + (ubar*tauxy-q_y+vbar*tauyy&
   &           +wbar*tauyz)*frhoeb
   tauzzb = sk(i, j, k, 3)*fmzb + wbar*tempb22
   skb(i, j, k, 3) = skb(i, j, k, 3) + (ubar*tauxz-q_z+vbar*tauyz&
   &           +wbar*tauzz)*frhoeb
   q_xb = -(sk(i, j, k, 1)*frhoeb)
   q_yb = -(sk(i, j, k, 2)*frhoeb)
   q_zb = -(sk(i, j, k, 3)*frhoeb)
   skb(i, j, k, 1) = skb(i, j, k, 1) + tauxz*fmzb
   skb(i, j, k, 2) = skb(i, j, k, 2) + tauyz*fmzb
   skb(i, j, k, 3) = skb(i, j, k, 3) + tauzz*fmzb
   skb(i, j, k, 1) = skb(i, j, k, 1) + tauxy*fmyb
   skb(i, j, k, 2) = skb(i, j, k, 2) + tauyy*fmyb
   skb(i, j, k, 3) = skb(i, j, k, 3) + tauyz*fmyb
   skb(i, j, k, 1) = skb(i, j, k, 1) + tauxx*fmxb
   skb(i, j, k, 2) = skb(i, j, k, 2) + tauxy*fmxb
   skb(i, j, k, 3) = skb(i, j, k, 3) + tauxz*fmxb
   wb(i, j, k, ivz) = wb(i, j, k, ivz) + half*wbarb
   wb(i, j, k+1, ivz) = wb(i, j, k+1, ivz) + half*wbarb
   wb(i, j, k, ivy) = wb(i, j, k, ivy) + half*vbarb
   wb(i, j, k+1, ivy) = wb(i, j, k+1, ivy) + half*vbarb
   wb(i, j, k, ivx) = wb(i, j, k, ivx) + half*ubarb
   wb(i, j, k+1, ivx) = wb(i, j, k+1, ivx) + half*ubarb
   dd = p(i, j, k+1) - p(i, j, k)
   gm1 = half*(gamma(i, j, k)+gamma(i, j, k+1)) - one
   factlamheat = one/(prandtl*gm1)
   factturbheat = one/(prandtlturb*gm1)
   heatcoef = mul*factlamheat + mue*factturbheat
   CALL POPREAL8(q_z)
   CALL POPREAL8(q_y)
   CALL POPREAL8(q_x)
   heatcoefb = q_y*q_yb + q_x*q_xb + q_z*q_zb
   q_zb = heatcoef*q_zb
   q_yb = heatcoef*q_yb
   q_xb = heatcoef*q_xb
   mutb = (u_z+w_x)*tauxzb + (two*w_z-fracdiv)*tauzzb + (two*u_x-&
   &           fracdiv)*tauxxb + (two*v_y-fracdiv)*tauyyb + (u_y+v_x)*&
   &           tauxyb + (v_z+w_y)*tauyzb
   v_zb = mut*tauyzb
   w_yb = mut*tauyzb
   u_zb = mut*tauxzb
   w_xb = mut*tauxzb
   u_yb = mut*tauxyb
   v_xb = mut*tauxyb
   fracdivb = -(mut*tauyyb) - mut*tauxxb - mut*tauzzb
   CALL POPREAL8(fracdiv)
   tempb23 = twothird*fracdivb
   w_zb = tempb23 + mut*two*tauzzb
   v_yb = tempb23 + mut*two*tauyyb
   u_xb = tempb23 + mut*two*tauxxb
   mulb = mutb + factlamheat*heatcoefb
   factlamheatb = mul*heatcoefb
   mueb = mueb + mutb + factturbheat*heatcoefb
   factturbheatb = mue*heatcoefb
   gm1b = -(one*factlamheatb/(prandtl*gm1**2)) - one*&
   &           factturbheatb/(prandtlturb*gm1**2)
   gammab(i, j, k) = gammab(i, j, k) + half*gm1b
   gammab(i, j, k+1) = gammab(i, j, k+1) + half*gm1b
   CALL POPREAL8(mut)
   CALL POPCONTROL1B(branch)
   IF (branch .EQ. 0) THEN
   CALL POPREAL8(mue)
   revb(i, j, k) = revb(i, j, k) + por*mueb
   revb(i, j, k+1) = revb(i, j, k+1) + por*mueb
   mueb = 0.0_8
   END IF
   rlvb(i, j, k) = rlvb(i, j, k) + por*mulb
   rlvb(i, j, k+1) = rlvb(i, j, k+1) + por*mulb
   CALL POPREAL8(por)
   CALL POPREAL8(q_z)
   ddb = -(ssy*q_yb) - ssx*q_xb - ssz*q_zb
   sszb = -(dd*q_zb)
   CALL POPREAL8(q_y)
   ssyb = -(dd*q_yb)
   CALL POPREAL8(q_x)
   ssxb = -(dd*q_xb)
   pb(i, j, k+1) = pb(i, j, k+1) + ddb
   pb(i, j, k) = pb(i, j, k) - ddb
   dd = w(i, j, k+1, ivz) - w(i, j, k, ivz)
   CALL POPREAL8(w_z)
   ddb = ssy*w_yb + ssx*w_xb + ssz*w_zb
   sszb = sszb + dd*w_zb
   CALL POPREAL8(w_y)
   ssyb = ssyb + dd*w_yb
   CALL POPREAL8(w_x)
   ssxb = ssxb + dd*w_xb
   wb(i, j, k+1, ivz) = wb(i, j, k+1, ivz) + ddb
   wb(i, j, k, ivz) = wb(i, j, k, ivz) - ddb
   dd = w(i, j, k+1, ivy) - w(i, j, k, ivy)
   CALL POPREAL8(v_z)
   ddb = ssy*v_yb + ssx*v_xb + ssz*v_zb
   sszb = sszb + dd*v_zb
   CALL POPREAL8(v_y)
   ssyb = ssyb + dd*v_yb
   CALL POPREAL8(v_x)
   ssxb = ssxb + dd*v_xb
   wb(i, j, k+1, ivy) = wb(i, j, k+1, ivy) + ddb
   wb(i, j, k, ivy) = wb(i, j, k, ivy) - ddb
   dd = w(i, j, k+1, ivx) - w(i, j, k, ivx)
   CALL POPREAL8(u_z)
   ddb = ssy*u_yb + ssx*u_xb + ssz*u_zb
   sszb = sszb + dd*u_zb
   CALL POPREAL8(u_y)
   ssyb = ssyb + dd*u_yb
   CALL POPREAL8(u_x)
   ssxb = ssxb + dd*u_xb
   wb(i, j, k+1, ivx) = wb(i, j, k+1, ivx) + ddb
   wb(i, j, k, ivx) = wb(i, j, k, ivx) - ddb
   CALL POPREAL8(ssz)
   CALL POPREAL8(ssy)
   CALL POPREAL8(ssx)
   ssb = ssy*ssyb + ssx*ssxb + ssz*sszb
   temp2 = ssx**2 + ssy**2 + ssz**2
   tempb16 = -(one*ssb/temp2**2)
   sszb = 2*ssz*tempb16 + ss*sszb
   ssyb = 2*ssy*tempb16 + ss*ssyb
   ssxb = 2*ssx*tempb16 + ss*ssxb
   CALL POPREAL8(ss)
   CALL POPREAL8(ssz)
   tempb17 = eighth*sszb
   xb(i-1, j-1, k+1, 3) = xb(i-1, j-1, k+1, 3) + tempb17
   xb(i-1, j-1, k-1, 3) = xb(i-1, j-1, k-1, 3) - tempb17
   xb(i-1, j, k+1, 3) = xb(i-1, j, k+1, 3) + tempb17
   xb(i-1, j, k-1, 3) = xb(i-1, j, k-1, 3) - tempb17
   xb(i, j-1, k+1, 3) = xb(i, j-1, k+1, 3) + tempb17
   xb(i, j-1, k-1, 3) = xb(i, j-1, k-1, 3) - tempb17
   xb(i, j, k+1, 3) = xb(i, j, k+1, 3) + tempb17
   xb(i, j, k-1, 3) = xb(i, j, k-1, 3) - tempb17
   CALL POPREAL8(ssy)
   tempb18 = eighth*ssyb
   xb(i-1, j-1, k+1, 2) = xb(i-1, j-1, k+1, 2) + tempb18
   xb(i-1, j-1, k-1, 2) = xb(i-1, j-1, k-1, 2) - tempb18
   xb(i-1, j, k+1, 2) = xb(i-1, j, k+1, 2) + tempb18
   xb(i-1, j, k-1, 2) = xb(i-1, j, k-1, 2) - tempb18
   xb(i, j-1, k+1, 2) = xb(i, j-1, k+1, 2) + tempb18
   xb(i, j-1, k-1, 2) = xb(i, j-1, k-1, 2) - tempb18
   xb(i, j, k+1, 2) = xb(i, j, k+1, 2) + tempb18
   xb(i, j, k-1, 2) = xb(i, j, k-1, 2) - tempb18
   CALL POPREAL8(ssx)
   tempb19 = eighth*ssxb
   xb(i-1, j-1, k+1, 1) = xb(i-1, j-1, k+1, 1) + tempb19
   xb(i-1, j-1, k-1, 1) = xb(i-1, j-1, k-1, 1) - tempb19
   xb(i-1, j, k+1, 1) = xb(i-1, j, k+1, 1) + tempb19
   xb(i-1, j, k-1, 1) = xb(i-1, j, k-1, 1) - tempb19
   xb(i, j-1, k+1, 1) = xb(i, j-1, k+1, 1) + tempb19
   xb(i, j-1, k-1, 1) = xb(i, j-1, k-1, 1) - tempb19
   xb(i, j, k+1, 1) = xb(i, j, k+1, 1) + tempb19
   xb(i, j, k-1, 1) = xb(i, j, k-1, 1) - tempb19
   END DO
   END DO
   END DO
   DO k=kl,2,-1
   DO j=jl,1,-1
   DO i=il,2,-1
   frhoeb = fwb(i, j+1, k, irhoe) - fwb(i, j, k, irhoe)
   fmzb = fwb(i, j+1, k, imz) - fwb(i, j, k, imz)
   fmyb = fwb(i, j+1, k, imy) - fwb(i, j, k, imy)
   fmxb = fwb(i, j+1, k, imx) - fwb(i, j, k, imx)
   mul = por*(rlv(i, j, k)+rlv(i, j+1, k))
   mut = mul + mue
   tauzz = mut*(two*w_z-fracdiv)
   wbar = half*(w(i, j, k, ivz)+w(i, j+1, k, ivz))
   vbar = half*(w(i, j, k, ivy)+w(i, j+1, k, ivy))
   tauxx = mut*(two*u_x-fracdiv)
   tauxy = mut*(u_y+v_x)
   tauxz = mut*(u_z+w_x)
   ubar = half*(w(i, j, k, ivx)+w(i, j+1, k, ivx))
   tauyy = mut*(two*v_y-fracdiv)
   tauyz = mut*(v_z+w_y)
   tempb12 = sj(i, j, k, 1)*frhoeb
   tempb13 = sj(i, j, k, 2)*frhoeb
   tempb14 = sj(i, j, k, 3)*frhoeb
   ubarb = tauxz*tempb14 + tauxy*tempb13 + tauxx*tempb12
   tauxxb = sj(i, j, k, 1)*fmxb + ubar*tempb12
   vbarb = tauyz*tempb14 + tauyy*tempb13 + tauxy*tempb12
   tauxyb = sj(i, j, k, 1)*fmyb + sj(i, j, k, 2)*fmxb + ubar*&
   &           tempb13 + vbar*tempb12
   wbarb = tauzz*tempb14 + tauyz*tempb13 + tauxz*tempb12
   tauxzb = sj(i, j, k, 1)*fmzb + sj(i, j, k, 3)*fmxb + ubar*&
   &           tempb14 + wbar*tempb12
   sjb(i, j, k, 1) = sjb(i, j, k, 1) + (ubar*tauxx-q_x+vbar*tauxy&
   &           +wbar*tauxz)*frhoeb
   tauyyb = sj(i, j, k, 2)*fmyb + vbar*tempb13
   tauyzb = sj(i, j, k, 2)*fmzb + sj(i, j, k, 3)*fmyb + vbar*&
   &           tempb14 + wbar*tempb13
   sjb(i, j, k, 2) = sjb(i, j, k, 2) + (ubar*tauxy-q_y+vbar*tauyy&
   &           +wbar*tauyz)*frhoeb
   tauzzb = sj(i, j, k, 3)*fmzb + wbar*tempb14
   sjb(i, j, k, 3) = sjb(i, j, k, 3) + (ubar*tauxz-q_z+vbar*tauyz&
   &           +wbar*tauzz)*frhoeb
   q_xb = -(sj(i, j, k, 1)*frhoeb)
   q_yb = -(sj(i, j, k, 2)*frhoeb)
   q_zb = -(sj(i, j, k, 3)*frhoeb)
   sjb(i, j, k, 1) = sjb(i, j, k, 1) + tauxz*fmzb
   sjb(i, j, k, 2) = sjb(i, j, k, 2) + tauyz*fmzb
   sjb(i, j, k, 3) = sjb(i, j, k, 3) + tauzz*fmzb
   sjb(i, j, k, 1) = sjb(i, j, k, 1) + tauxy*fmyb
   sjb(i, j, k, 2) = sjb(i, j, k, 2) + tauyy*fmyb
   sjb(i, j, k, 3) = sjb(i, j, k, 3) + tauyz*fmyb
   sjb(i, j, k, 1) = sjb(i, j, k, 1) + tauxx*fmxb
   sjb(i, j, k, 2) = sjb(i, j, k, 2) + tauxy*fmxb
   sjb(i, j, k, 3) = sjb(i, j, k, 3) + tauxz*fmxb
   wb(i, j, k, ivz) = wb(i, j, k, ivz) + half*wbarb
   wb(i, j+1, k, ivz) = wb(i, j+1, k, ivz) + half*wbarb
   wb(i, j, k, ivy) = wb(i, j, k, ivy) + half*vbarb
   wb(i, j+1, k, ivy) = wb(i, j+1, k, ivy) + half*vbarb
   wb(i, j, k, ivx) = wb(i, j, k, ivx) + half*ubarb
   wb(i, j+1, k, ivx) = wb(i, j+1, k, ivx) + half*ubarb
   dd = p(i, j+1, k) - p(i, j, k)
   gm1 = half*(gamma(i, j, k)+gamma(i, j+1, k)) - one
   factlamheat = one/(prandtl*gm1)
   factturbheat = one/(prandtlturb*gm1)
   heatcoef = mul*factlamheat + mue*factturbheat
   CALL POPREAL8(q_z)
   CALL POPREAL8(q_y)
   CALL POPREAL8(q_x)
   heatcoefb = q_y*q_yb + q_x*q_xb + q_z*q_zb
   q_zb = heatcoef*q_zb
   q_yb = heatcoef*q_yb
   q_xb = heatcoef*q_xb
   mutb = (u_z+w_x)*tauxzb + (two*w_z-fracdiv)*tauzzb + (two*u_x-&
   &           fracdiv)*tauxxb + (two*v_y-fracdiv)*tauyyb + (u_y+v_x)*&
   &           tauxyb + (v_z+w_y)*tauyzb
   v_zb = mut*tauyzb
   w_yb = mut*tauyzb
   u_zb = mut*tauxzb
   w_xb = mut*tauxzb
   u_yb = mut*tauxyb
   v_xb = mut*tauxyb
   fracdivb = -(mut*tauyyb) - mut*tauxxb - mut*tauzzb
   CALL POPREAL8(fracdiv)
   tempb15 = twothird*fracdivb
   w_zb = tempb15 + mut*two*tauzzb
   v_yb = tempb15 + mut*two*tauyyb
   u_xb = tempb15 + mut*two*tauxxb
   mulb = mutb + factlamheat*heatcoefb
   factlamheatb = mul*heatcoefb
   mueb = mueb + mutb + factturbheat*heatcoefb
   factturbheatb = mue*heatcoefb
   gm1b = -(one*factlamheatb/(prandtl*gm1**2)) - one*&
   &           factturbheatb/(prandtlturb*gm1**2)
   gammab(i, j, k) = gammab(i, j, k) + half*gm1b
   gammab(i, j+1, k) = gammab(i, j+1, k) + half*gm1b
   CALL POPREAL8(mut)
   CALL POPCONTROL1B(branch)
   IF (branch .EQ. 0) THEN
   CALL POPREAL8(mue)
   revb(i, j, k) = revb(i, j, k) + por*mueb
   revb(i, j+1, k) = revb(i, j+1, k) + por*mueb
   mueb = 0.0_8
   END IF
   rlvb(i, j, k) = rlvb(i, j, k) + por*mulb
   rlvb(i, j+1, k) = rlvb(i, j+1, k) + por*mulb
   CALL POPREAL8(por)
   CALL POPREAL8(q_z)
   ddb = -(ssy*q_yb) - ssx*q_xb - ssz*q_zb
   sszb = -(dd*q_zb)
   CALL POPREAL8(q_y)
   ssyb = -(dd*q_yb)
   CALL POPREAL8(q_x)
   ssxb = -(dd*q_xb)
   pb(i, j+1, k) = pb(i, j+1, k) + ddb
   pb(i, j, k) = pb(i, j, k) - ddb
   dd = w(i, j+1, k, ivz) - w(i, j, k, ivz)
   CALL POPREAL8(w_z)
   ddb = ssy*w_yb + ssx*w_xb + ssz*w_zb
   sszb = sszb + dd*w_zb
   CALL POPREAL8(w_y)
   ssyb = ssyb + dd*w_yb
   CALL POPREAL8(w_x)
   ssxb = ssxb + dd*w_xb
   wb(i, j+1, k, ivz) = wb(i, j+1, k, ivz) + ddb
   wb(i, j, k, ivz) = wb(i, j, k, ivz) - ddb
   dd = w(i, j+1, k, ivy) - w(i, j, k, ivy)
   CALL POPREAL8(v_z)
   ddb = ssy*v_yb + ssx*v_xb + ssz*v_zb
   sszb = sszb + dd*v_zb
   CALL POPREAL8(v_y)
   ssyb = ssyb + dd*v_yb
   CALL POPREAL8(v_x)
   ssxb = ssxb + dd*v_xb
   wb(i, j+1, k, ivy) = wb(i, j+1, k, ivy) + ddb
   wb(i, j, k, ivy) = wb(i, j, k, ivy) - ddb
   dd = w(i, j+1, k, ivx) - w(i, j, k, ivx)
   CALL POPREAL8(u_z)
   ddb = ssy*u_yb + ssx*u_xb + ssz*u_zb
   sszb = sszb + dd*u_zb
   CALL POPREAL8(u_y)
   ssyb = ssyb + dd*u_yb
   CALL POPREAL8(u_x)
   ssxb = ssxb + dd*u_xb
   wb(i, j+1, k, ivx) = wb(i, j+1, k, ivx) + ddb
   wb(i, j, k, ivx) = wb(i, j, k, ivx) - ddb
   CALL POPREAL8(ssz)
   CALL POPREAL8(ssy)
   CALL POPREAL8(ssx)
   ssb = ssy*ssyb + ssx*ssxb + ssz*sszb
   temp1 = ssx**2 + ssy**2 + ssz**2
   tempb8 = -(one*ssb/temp1**2)
   sszb = 2*ssz*tempb8 + ss*sszb
   ssyb = 2*ssy*tempb8 + ss*ssyb
   ssxb = 2*ssx*tempb8 + ss*ssxb
   CALL POPREAL8(ss)
   CALL POPREAL8(ssz)
   tempb9 = eighth*sszb
   xb(i-1, j+1, k-1, 3) = xb(i-1, j+1, k-1, 3) + tempb9
   xb(i-1, j-1, k-1, 3) = xb(i-1, j-1, k-1, 3) - tempb9
   xb(i-1, j+1, k, 3) = xb(i-1, j+1, k, 3) + tempb9
   xb(i-1, j-1, k, 3) = xb(i-1, j-1, k, 3) - tempb9
   xb(i, j+1, k-1, 3) = xb(i, j+1, k-1, 3) + tempb9
   xb(i, j-1, k-1, 3) = xb(i, j-1, k-1, 3) - tempb9
   xb(i, j+1, k, 3) = xb(i, j+1, k, 3) + tempb9
   xb(i, j-1, k, 3) = xb(i, j-1, k, 3) - tempb9
   CALL POPREAL8(ssy)
   tempb10 = eighth*ssyb
   xb(i-1, j+1, k-1, 2) = xb(i-1, j+1, k-1, 2) + tempb10
   xb(i-1, j-1, k-1, 2) = xb(i-1, j-1, k-1, 2) - tempb10
   xb(i-1, j+1, k, 2) = xb(i-1, j+1, k, 2) + tempb10
   xb(i-1, j-1, k, 2) = xb(i-1, j-1, k, 2) - tempb10
   xb(i, j+1, k-1, 2) = xb(i, j+1, k-1, 2) + tempb10
   xb(i, j-1, k-1, 2) = xb(i, j-1, k-1, 2) - tempb10
   xb(i, j+1, k, 2) = xb(i, j+1, k, 2) + tempb10
   xb(i, j-1, k, 2) = xb(i, j-1, k, 2) - tempb10
   CALL POPREAL8(ssx)
   tempb11 = eighth*ssxb
   xb(i-1, j+1, k-1, 1) = xb(i-1, j+1, k-1, 1) + tempb11
   xb(i-1, j-1, k-1, 1) = xb(i-1, j-1, k-1, 1) - tempb11
   xb(i-1, j+1, k, 1) = xb(i-1, j+1, k, 1) + tempb11
   xb(i-1, j-1, k, 1) = xb(i-1, j-1, k, 1) - tempb11
   xb(i, j+1, k-1, 1) = xb(i, j+1, k-1, 1) + tempb11
   xb(i, j-1, k-1, 1) = xb(i, j-1, k-1, 1) - tempb11
   xb(i, j+1, k, 1) = xb(i, j+1, k, 1) + tempb11
   xb(i, j-1, k, 1) = xb(i, j-1, k, 1) - tempb11
   END DO
   END DO
   END DO
   DO k=kl,2,-1
   DO j=jl,2,-1
   DO i=il,1,-1
   frhoeb = fwb(i+1, j, k, irhoe) - fwb(i, j, k, irhoe)
   fmzb = fwb(i+1, j, k, imz) - fwb(i, j, k, imz)
   fmyb = fwb(i+1, j, k, imy) - fwb(i, j, k, imy)
   fmxb = fwb(i+1, j, k, imx) - fwb(i, j, k, imx)
   mul = por*(rlv(i, j, k)+rlv(i+1, j, k))
   mut = mul + mue
   tauzz = mut*(two*w_z-fracdiv)
   wbar = half*(w(i, j, k, ivz)+w(i+1, j, k, ivz))
   vbar = half*(w(i, j, k, ivy)+w(i+1, j, k, ivy))
   tauxx = mut*(two*u_x-fracdiv)
   tauxy = mut*(u_y+v_x)
   tauxz = mut*(u_z+w_x)
   ubar = half*(w(i, j, k, ivx)+w(i+1, j, k, ivx))
   tauyy = mut*(two*v_y-fracdiv)
   tauyz = mut*(v_z+w_y)
   tempb4 = si(i, j, k, 1)*frhoeb
   tempb5 = si(i, j, k, 2)*frhoeb
   tempb6 = si(i, j, k, 3)*frhoeb
   ubarb = tauxz*tempb6 + tauxy*tempb5 + tauxx*tempb4
   tauxxb = si(i, j, k, 1)*fmxb + ubar*tempb4
   vbarb = tauyz*tempb6 + tauyy*tempb5 + tauxy*tempb4
   tauxyb = si(i, j, k, 1)*fmyb + si(i, j, k, 2)*fmxb + ubar*&
   &           tempb5 + vbar*tempb4
   wbarb = tauzz*tempb6 + tauyz*tempb5 + tauxz*tempb4
   tauxzb = si(i, j, k, 1)*fmzb + si(i, j, k, 3)*fmxb + ubar*&
   &           tempb6 + wbar*tempb4
   sib(i, j, k, 1) = sib(i, j, k, 1) + (ubar*tauxx-q_x+vbar*tauxy&
   &           +wbar*tauxz)*frhoeb
   tauyyb = si(i, j, k, 2)*fmyb + vbar*tempb5
   tauyzb = si(i, j, k, 2)*fmzb + si(i, j, k, 3)*fmyb + vbar*&
   &           tempb6 + wbar*tempb5
   sib(i, j, k, 2) = sib(i, j, k, 2) + (ubar*tauxy-q_y+vbar*tauyy&
   &           +wbar*tauyz)*frhoeb
   tauzzb = si(i, j, k, 3)*fmzb + wbar*tempb6
   sib(i, j, k, 3) = sib(i, j, k, 3) + (ubar*tauxz-q_z+vbar*tauyz&
   &           +wbar*tauzz)*frhoeb
   q_xb = -(si(i, j, k, 1)*frhoeb)
   q_yb = -(si(i, j, k, 2)*frhoeb)
   q_zb = -(si(i, j, k, 3)*frhoeb)
   sib(i, j, k, 1) = sib(i, j, k, 1) + tauxz*fmzb
   sib(i, j, k, 2) = sib(i, j, k, 2) + tauyz*fmzb
   sib(i, j, k, 3) = sib(i, j, k, 3) + tauzz*fmzb
   sib(i, j, k, 1) = sib(i, j, k, 1) + tauxy*fmyb
   sib(i, j, k, 2) = sib(i, j, k, 2) + tauyy*fmyb
   sib(i, j, k, 3) = sib(i, j, k, 3) + tauyz*fmyb
   sib(i, j, k, 1) = sib(i, j, k, 1) + tauxx*fmxb
   sib(i, j, k, 2) = sib(i, j, k, 2) + tauxy*fmxb
   sib(i, j, k, 3) = sib(i, j, k, 3) + tauxz*fmxb
   wb(i, j, k, ivz) = wb(i, j, k, ivz) + half*wbarb
   wb(i+1, j, k, ivz) = wb(i+1, j, k, ivz) + half*wbarb
   wb(i, j, k, ivy) = wb(i, j, k, ivy) + half*vbarb
   wb(i+1, j, k, ivy) = wb(i+1, j, k, ivy) + half*vbarb
   wb(i, j, k, ivx) = wb(i, j, k, ivx) + half*ubarb
   wb(i+1, j, k, ivx) = wb(i+1, j, k, ivx) + half*ubarb
   dd = p(i+1, j, k) - p(i, j, k)
   gm1 = half*(gamma(i, j, k)+gamma(i+1, j, k)) - one
   factlamheat = one/(prandtl*gm1)
   factturbheat = one/(prandtlturb*gm1)
   heatcoef = mul*factlamheat + mue*factturbheat
   CALL POPREAL8(q_z)
   CALL POPREAL8(q_y)
   CALL POPREAL8(q_x)
   heatcoefb = q_y*q_yb + q_x*q_xb + q_z*q_zb
   q_zb = heatcoef*q_zb
   q_yb = heatcoef*q_yb
   q_xb = heatcoef*q_xb
   mutb = (u_z+w_x)*tauxzb + (two*w_z-fracdiv)*tauzzb + (two*u_x-&
   &           fracdiv)*tauxxb + (two*v_y-fracdiv)*tauyyb + (u_y+v_x)*&
   &           tauxyb + (v_z+w_y)*tauyzb
   v_zb = mut*tauyzb
   w_yb = mut*tauyzb
   u_zb = mut*tauxzb
   w_xb = mut*tauxzb
   u_yb = mut*tauxyb
   v_xb = mut*tauxyb
   fracdivb = -(mut*tauyyb) - mut*tauxxb - mut*tauzzb
   CALL POPREAL8(fracdiv)
   tempb7 = twothird*fracdivb
   w_zb = tempb7 + mut*two*tauzzb
   v_yb = tempb7 + mut*two*tauyyb
   u_xb = tempb7 + mut*two*tauxxb
   mulb = mutb + factlamheat*heatcoefb
   factlamheatb = mul*heatcoefb
   mueb = mueb + mutb + factturbheat*heatcoefb
   factturbheatb = mue*heatcoefb
   gm1b = -(one*factlamheatb/(prandtl*gm1**2)) - one*&
   &           factturbheatb/(prandtlturb*gm1**2)
   gammab(i, j, k) = gammab(i, j, k) + half*gm1b
   gammab(i+1, j, k) = gammab(i+1, j, k) + half*gm1b
   CALL POPREAL8(mut)
   CALL POPCONTROL1B(branch)
   IF (branch .EQ. 0) THEN
   CALL POPREAL8(mue)
   revb(i, j, k) = revb(i, j, k) + por*mueb
   revb(i+1, j, k) = revb(i+1, j, k) + por*mueb
   mueb = 0.0_8
   END IF
   rlvb(i, j, k) = rlvb(i, j, k) + por*mulb
   rlvb(i+1, j, k) = rlvb(i+1, j, k) + por*mulb
   CALL POPREAL8(por)
   CALL POPREAL8(q_z)
   ddb = -(ssy*q_yb) - ssx*q_xb - ssz*q_zb
   sszb = -(dd*q_zb)
   CALL POPREAL8(q_y)
   ssyb = -(dd*q_yb)
   CALL POPREAL8(q_x)
   ssxb = -(dd*q_xb)
   pb(i+1, j, k) = pb(i+1, j, k) + ddb
   pb(i, j, k) = pb(i, j, k) - ddb
   dd = w(i+1, j, k, ivz) - w(i, j, k, ivz)
   CALL POPREAL8(w_z)
   ddb = ssy*w_yb + ssx*w_xb + ssz*w_zb
   sszb = sszb + dd*w_zb
   CALL POPREAL8(w_y)
   ssyb = ssyb + dd*w_yb
   CALL POPREAL8(w_x)
   ssxb = ssxb + dd*w_xb
   wb(i+1, j, k, ivz) = wb(i+1, j, k, ivz) + ddb
   wb(i, j, k, ivz) = wb(i, j, k, ivz) - ddb
   dd = w(i+1, j, k, ivy) - w(i, j, k, ivy)
   CALL POPREAL8(v_z)
   ddb = ssy*v_yb + ssx*v_xb + ssz*v_zb
   sszb = sszb + dd*v_zb
   CALL POPREAL8(v_y)
   ssyb = ssyb + dd*v_yb
   CALL POPREAL8(v_x)
   ssxb = ssxb + dd*v_xb
   wb(i+1, j, k, ivy) = wb(i+1, j, k, ivy) + ddb
   wb(i, j, k, ivy) = wb(i, j, k, ivy) - ddb
   dd = w(i+1, j, k, ivx) - w(i, j, k, ivx)
   CALL POPREAL8(u_z)
   ddb = ssy*u_yb + ssx*u_xb + ssz*u_zb
   sszb = sszb + dd*u_zb
   CALL POPREAL8(u_y)
   ssyb = ssyb + dd*u_yb
   CALL POPREAL8(u_x)
   ssxb = ssxb + dd*u_xb
   wb(i+1, j, k, ivx) = wb(i+1, j, k, ivx) + ddb
   wb(i, j, k, ivx) = wb(i, j, k, ivx) - ddb
   CALL POPREAL8(ssz)
   CALL POPREAL8(ssy)
   CALL POPREAL8(ssx)
   ssb = ssy*ssyb + ssx*ssxb + ssz*sszb
   temp0 = ssx**2 + ssy**2 + ssz**2
   tempb0 = -(one*ssb/temp0**2)
   sszb = 2*ssz*tempb0 + ss*sszb
   ssyb = 2*ssy*tempb0 + ss*ssyb
   ssxb = 2*ssx*tempb0 + ss*ssxb
   CALL POPREAL8(ss)
   CALL POPREAL8(ssz)
   tempb1 = eighth*sszb
   xb(i+1, j-1, k-1, 3) = xb(i+1, j-1, k-1, 3) + tempb1
   xb(i-1, j-1, k-1, 3) = xb(i-1, j-1, k-1, 3) - tempb1
   xb(i+1, j-1, k, 3) = xb(i+1, j-1, k, 3) + tempb1
   xb(i-1, j-1, k, 3) = xb(i-1, j-1, k, 3) - tempb1
   xb(i+1, j, k-1, 3) = xb(i+1, j, k-1, 3) + tempb1
   xb(i-1, j, k-1, 3) = xb(i-1, j, k-1, 3) - tempb1
   xb(i+1, j, k, 3) = xb(i+1, j, k, 3) + tempb1
   xb(i-1, j, k, 3) = xb(i-1, j, k, 3) - tempb1
   CALL POPREAL8(ssy)
   tempb2 = eighth*ssyb
   xb(i+1, j-1, k-1, 2) = xb(i+1, j-1, k-1, 2) + tempb2
   xb(i-1, j-1, k-1, 2) = xb(i-1, j-1, k-1, 2) - tempb2
   xb(i+1, j-1, k, 2) = xb(i+1, j-1, k, 2) + tempb2
   xb(i-1, j-1, k, 2) = xb(i-1, j-1, k, 2) - tempb2
   xb(i+1, j, k-1, 2) = xb(i+1, j, k-1, 2) + tempb2
   xb(i-1, j, k-1, 2) = xb(i-1, j, k-1, 2) - tempb2
   xb(i+1, j, k, 2) = xb(i+1, j, k, 2) + tempb2
   xb(i-1, j, k, 2) = xb(i-1, j, k, 2) - tempb2
   CALL POPREAL8(ssx)
   tempb3 = eighth*ssxb
   xb(i+1, j-1, k-1, 1) = xb(i+1, j-1, k-1, 1) + tempb3
   xb(i-1, j-1, k-1, 1) = xb(i-1, j-1, k-1, 1) - tempb3
   xb(i+1, j-1, k, 1) = xb(i+1, j-1, k, 1) + tempb3
   xb(i-1, j-1, k, 1) = xb(i-1, j-1, k, 1) - tempb3
   xb(i+1, j, k-1, 1) = xb(i+1, j, k-1, 1) + tempb3
   xb(i-1, j, k-1, 1) = xb(i-1, j, k-1, 1) - tempb3
   xb(i+1, j, k, 1) = xb(i+1, j, k, 1) + tempb3
   xb(i-1, j, k, 1) = xb(i-1, j, k, 1) - tempb3
   END DO
   END DO
   END DO
   DO k=ke,1,-1
   DO j=je,1,-1
   DO i=ie,1,-1
   CALL POPREAL8(p(i, j, k))
   temp = w(i, j, k, irho)
   tempb = pb(i, j, k)/temp
   gammab(i, j, k) = gammab(i, j, k) + p(i, j, k)*tempb
   wb(i, j, k, irho) = wb(i, j, k, irho) - gamma(i, j, k)*p(i, j&
   &           , k)*tempb/temp
   pb(i, j, k) = gamma(i, j, k)*tempb
   CALL POPCONTROL1B(branch)
   IF (branch .EQ. 0) THEN
   CALL POPREAL8(p(i, j, k))
   wb(i, j, k, irho) = wb(i, j, k, irho) - twothird*w(i, j, k, &
   &             itu1)*pb(i, j, k)
   wb(i, j, k, itu1) = wb(i, j, k, itu1) - twothird*w(i, j, k, &
   &             irho)*pb(i, j, k)
   END IF
   END DO
   END DO
   END DO
   END IF
   END SUBROUTINE VISCOUSFLUXAPPROX_B
