   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.4 (r3375) - 10 Feb 2010 15:08
   !
   !  Differentiation of turbbcnswall in forward (tangent) mode:
   !   variations   of useful results: *bvtj1 *bvtj2 *bmtk1 *w *bmtk2
   !                *bvtk1 *bvtk2 *bmti1 *bmti2 *bvti1 *bvti2 *bmtj1
   !                *bmtj2
   !   with respect to varying inputs: *bvtj1 *bvtj2 *bmtk1 *w *bmtk2
   !                *bvtk1 *bvtk2 *bmti1 *bmti2 *bvti1 *bvti2 *bmtj1
   !                *bmtj2
   !
   !      ******************************************************************
   !      *                                                                *
   !      * File:          turbBCNSWall.f90                                *
   !      * Author:        Edwin van der Weide                             *
   !      * Starting date: 05-30-2003                                      *
   !      * Last modified: 06-12-2005                                      *
   !      *                                                                *
   !      ******************************************************************
   !
   SUBROUTINE TURBBCNSWALL_D(secondhalo)
   USE FLOWVARREFSTATE
   USE BLOCKPOINTERS_D
   USE BCTYPES
   IMPLICIT NONE
   !
   !      ******************************************************************
   !      *                                                                *
   !      * turbBCNSWall applies the viscous wall boundary conditions      *
   !      * of the turbulent transport equations to a block. It is assumed *
   !      * that the pointers in blockPointers are already set to the      *
   !      * correct block on the correct grid level.                       *
   !      *                                                                *
   !      ******************************************************************
   !
   !
   !      Subroutine argument.
   !
   LOGICAL, INTENT(IN) :: secondhalo
   !
   !      Local variables.
   !
   INTEGER(kind=inttype) :: nn, i, j, l, m
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: bmt
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: bmtd
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: bvt
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: bvtd
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: ww0, ww1, ww2
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: ww0d, ww1d, ww2d
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rev0, rev1, rev2
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Begin execution                                                *
   !      *                                                                *
   !      ******************************************************************
   !
   ! Loop over the viscous subfaces of this block.
   bocos:DO nn=1,nviscbocos
   ! Set the corresponding arrays.
   CALL BCTURBWALL_D(nn)
   ! Determine the block face on which this subface is located
   ! and set some pointers accordingly.
   SELECT CASE  (bcfaceid(nn)) 
   CASE (imin) 
   bmtd => bmti1d
   bmt => bmti1
   bvtd => bvti1d
   bvt => bvti1
   ww0d => wd(0, 1:, 1:, :)
   ww0 => w(0, 1:, 1:, :)
   ww1d => wd(1, 1:, 1:, :)
   ww1 => w(1, 1:, 1:, :)
   ww2d => wd(2, 1:, 1:, :)
   ww2 => w(2, 1:, 1:, :)
   IF (eddymodel) THEN
   rev0 => rev(0, 1:, 1:)
   rev1 => rev(1, 1:, 1:)
   rev2 => rev(2, 1:, 1:)
   END IF
   CASE (imax) 
   bmtd => bmti2d
   bmt => bmti2
   bvtd => bvti2d
   bvt => bvti2
   ww0d => wd(ib, 1:, 1:, :)
   ww0 => w(ib, 1:, 1:, :)
   ww1d => wd(ie, 1:, 1:, :)
   ww1 => w(ie, 1:, 1:, :)
   ww2d => wd(il, 1:, 1:, :)
   ww2 => w(il, 1:, 1:, :)
   IF (eddymodel) THEN
   rev0 => rev(ib, 1:, 1:)
   rev1 => rev(ie, 1:, 1:)
   rev2 => rev(il, 1:, 1:)
   END IF
   CASE (jmin) 
   bmtd => bmtj1d
   bmt => bmtj1
   bvtd => bvtj1d
   bvt => bvtj1
   ww0d => wd(1:, 0, 1:, :)
   ww0 => w(1:, 0, 1:, :)
   ww1d => wd(1:, 1, 1:, :)
   ww1 => w(1:, 1, 1:, :)
   ww2d => wd(1:, 2, 1:, :)
   ww2 => w(1:, 2, 1:, :)
   IF (eddymodel) THEN
   rev0 => rev(1:, 0, 1:)
   rev1 => rev(1:, 1, 1:)
   rev2 => rev(1:, 2, 1:)
   END IF
   CASE (jmax) 
   bmtd => bmtj2d
   bmt => bmtj2
   bvtd => bvtj2d
   bvt => bvtj2
   ww0d => wd(1:, jb, 1:, :)
   ww0 => w(1:, jb, 1:, :)
   ww1d => wd(1:, je, 1:, :)
   ww1 => w(1:, je, 1:, :)
   ww2d => wd(1:, jl, 1:, :)
   ww2 => w(1:, jl, 1:, :)
   IF (eddymodel) THEN
   rev0 => rev(1:, jb, 1:)
   rev1 => rev(1:, je, 1:)
   rev2 => rev(1:, jl, 1:)
   END IF
   CASE (kmin) 
   bmtd => bmtk1d
   bmt => bmtk1
   bvtd => bvtk1d
   bvt => bvtk1
   ww0d => wd(1:, 1:, 0, :)
   ww0 => w(1:, 1:, 0, :)
   ww1d => wd(1:, 1:, 1, :)
   ww1 => w(1:, 1:, 1, :)
   ww2d => wd(1:, 1:, 2, :)
   ww2 => w(1:, 1:, 2, :)
   IF (eddymodel) THEN
   rev0 => rev(1:, 1:, 0)
   rev1 => rev(1:, 1:, 1)
   rev2 => rev(1:, 1:, 2)
   END IF
   CASE (kmax) 
   bmtd => bmtk2d
   bmt => bmtk2
   bvtd => bvtk2d
   bvt => bvtk2
   ww0d => wd(1:, 1:, kb, :)
   ww0 => w(1:, 1:, kb, :)
   ww1d => wd(1:, 1:, ke, :)
   ww1 => w(1:, 1:, ke, :)
   ww2d => wd(1:, 1:, kl, :)
   ww2 => w(1:, 1:, kl, :)
   IF (eddymodel) THEN
   rev0 => rev(1:, 1:, kb)
   rev1 => rev(1:, 1:, ke)
   rev2 => rev(1:, 1:, kl)
   END IF
   END SELECT
   ! Loop over the faces and set the state in
   ! the turbulent halo cells.
   DO j=bcdata(nn)%jcbeg,bcdata(nn)%jcend
   DO i=bcdata(nn)%icbeg,bcdata(nn)%icend
   DO l=nt1,nt2
   ww1d(i, j, l) = bvtd(i, j, l)
   ww1(i, j, l) = bvt(i, j, l)
   DO m=nt1,nt2
   ww1d(i, j, l) = ww1d(i, j, l) - bmtd(i, j, l, m)*ww2(i, j, m&
   &              ) - bmt(i, j, l, m)*ww2d(i, j, m)
   ww1(i, j, l) = ww1(i, j, l) - bmt(i, j, l, m)*ww2(i, j, m)
   END DO
   END DO
   END DO
   END DO
   ! Use constant extrapolation if the state in the second halo
   ! must be computed.
   IF (secondhalo) THEN
   DO j=bcdata(nn)%jcbeg,bcdata(nn)%jcend
   DO i=bcdata(nn)%icbeg,bcdata(nn)%icend
   DO l=nt1,nt2
   ww0d(i, j, l) = ww1d(i, j, l)
   ww0(i, j, l) = ww1(i, j, l)
   END DO
   END DO
   END DO
   END IF
   ! Set the eddy viscosity for an eddy model.
   IF (eddymodel) THEN
   DO j=bcdata(nn)%jcbeg,bcdata(nn)%jcend
   DO i=bcdata(nn)%icbeg,bcdata(nn)%icend
   rev1(i, j) = -rev2(i, j)
   END DO
   END DO
   IF (secondhalo) THEN
   DO j=bcdata(nn)%jcbeg,bcdata(nn)%jcend
   DO i=bcdata(nn)%icbeg,bcdata(nn)%icend
   rev0(i, j) = rev1(i, j)
   END DO
   END DO
   END IF
   END IF
   END DO bocos
   END SUBROUTINE TURBBCNSWALL_D
