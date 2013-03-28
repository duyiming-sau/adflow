   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.7 (r4786) - 21 Feb 2013 15:53
   !
   !  Differentiation of turbbcnswall in forward (tangent) mode (with options debugTangent i4 dr8 r8):
   !   variations   of useful results: *rev *bvtj1 *bvtj2 *bmtk1 *w
   !                *bmtk2 *bvtk1 *bvtk2 *bmti1 *bmti2 *bvti1 *bvti2
   !                *bmtj1 *bmtj2
   !   with respect to varying inputs: *rev *bvtj1 *bvtj2 *bmtk1 *w
   !                *bmtk2 *rlv *bvtk1 *bvtk2 *bmti1 *bmti2 *bvti1
   !                *bvti2 *bmtj1 *bmtj2
   !   Plus diff mem management of: rev:in bvtj1:in bvtj2:in bmtk1:in
   !                w:in bmtk2:in rlv:in bvtk1:in bvtk2:in bmti1:in
   !                bmti2:in bvti1:in bvti2:in bmtj1:in bmtj2:in bcdata:in
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
   SUBROUTINE TURBBCNSWALL_T(secondhalo)
   USE FLOWVARREFSTATE
   USE BLOCKPOINTERS_D
   USE BCTYPES
   USE DIFFSIZES
   !  Hint: ISIZE4OFDrfbmtj2 should be the size of dimension 4 of array *bmtj2
   !  Hint: ISIZE3OFDrfbmtj2 should be the size of dimension 3 of array *bmtj2
   !  Hint: ISIZE2OFDrfbmtj2 should be the size of dimension 2 of array *bmtj2
   !  Hint: ISIZE1OFDrfbmtj2 should be the size of dimension 1 of array *bmtj2
   !  Hint: ISIZE4OFDrfbmtj1 should be the size of dimension 4 of array *bmtj1
   !  Hint: ISIZE3OFDrfbmtj1 should be the size of dimension 3 of array *bmtj1
   !  Hint: ISIZE2OFDrfbmtj1 should be the size of dimension 2 of array *bmtj1
   !  Hint: ISIZE1OFDrfbmtj1 should be the size of dimension 1 of array *bmtj1
   !  Hint: ISIZE3OFDrfbvti2 should be the size of dimension 3 of array *bvti2
   !  Hint: ISIZE2OFDrfbvti2 should be the size of dimension 2 of array *bvti2
   !  Hint: ISIZE1OFDrfbvti2 should be the size of dimension 1 of array *bvti2
   !  Hint: ISIZE3OFDrfbvti1 should be the size of dimension 3 of array *bvti1
   !  Hint: ISIZE2OFDrfbvti1 should be the size of dimension 2 of array *bvti1
   !  Hint: ISIZE1OFDrfbvti1 should be the size of dimension 1 of array *bvti1
   !  Hint: ISIZE4OFDrfbmti2 should be the size of dimension 4 of array *bmti2
   !  Hint: ISIZE3OFDrfbmti2 should be the size of dimension 3 of array *bmti2
   !  Hint: ISIZE2OFDrfbmti2 should be the size of dimension 2 of array *bmti2
   !  Hint: ISIZE1OFDrfbmti2 should be the size of dimension 1 of array *bmti2
   !  Hint: ISIZE4OFDrfbmti1 should be the size of dimension 4 of array *bmti1
   !  Hint: ISIZE3OFDrfbmti1 should be the size of dimension 3 of array *bmti1
   !  Hint: ISIZE2OFDrfbmti1 should be the size of dimension 2 of array *bmti1
   !  Hint: ISIZE1OFDrfbmti1 should be the size of dimension 1 of array *bmti1
   !  Hint: ISIZE3OFDrfbvtk2 should be the size of dimension 3 of array *bvtk2
   !  Hint: ISIZE2OFDrfbvtk2 should be the size of dimension 2 of array *bvtk2
   !  Hint: ISIZE1OFDrfbvtk2 should be the size of dimension 1 of array *bvtk2
   !  Hint: ISIZE3OFDrfbvtk1 should be the size of dimension 3 of array *bvtk1
   !  Hint: ISIZE2OFDrfbvtk1 should be the size of dimension 2 of array *bvtk1
   !  Hint: ISIZE1OFDrfbvtk1 should be the size of dimension 1 of array *bvtk1
   !  Hint: ISIZE3OFDrfrlv should be the size of dimension 3 of array *rlv
   !  Hint: ISIZE2OFDrfrlv should be the size of dimension 2 of array *rlv
   !  Hint: ISIZE1OFDrfrlv should be the size of dimension 1 of array *rlv
   !  Hint: ISIZE4OFDrfbmtk2 should be the size of dimension 4 of array *bmtk2
   !  Hint: ISIZE3OFDrfbmtk2 should be the size of dimension 3 of array *bmtk2
   !  Hint: ISIZE2OFDrfbmtk2 should be the size of dimension 2 of array *bmtk2
   !  Hint: ISIZE1OFDrfbmtk2 should be the size of dimension 1 of array *bmtk2
   !  Hint: ISIZE4OFDrfw should be the size of dimension 4 of array *w
   !  Hint: ISIZE3OFDrfw should be the size of dimension 3 of array *w
   !  Hint: ISIZE2OFDrfw should be the size of dimension 2 of array *w
   !  Hint: ISIZE1OFDrfw should be the size of dimension 1 of array *w
   !  Hint: ISIZE4OFDrfbmtk1 should be the size of dimension 4 of array *bmtk1
   !  Hint: ISIZE3OFDrfbmtk1 should be the size of dimension 3 of array *bmtk1
   !  Hint: ISIZE2OFDrfbmtk1 should be the size of dimension 2 of array *bmtk1
   !  Hint: ISIZE1OFDrfbmtk1 should be the size of dimension 1 of array *bmtk1
   !  Hint: ISIZE3OFDrfbvtj2 should be the size of dimension 3 of array *bvtj2
   !  Hint: ISIZE2OFDrfbvtj2 should be the size of dimension 2 of array *bvtj2
   !  Hint: ISIZE1OFDrfbvtj2 should be the size of dimension 1 of array *bvtj2
   !  Hint: ISIZE3OFDrfbvtj1 should be the size of dimension 3 of array *bvtj1
   !  Hint: ISIZE2OFDrfbvtj1 should be the size of dimension 2 of array *bvtj1
   !  Hint: ISIZE1OFDrfbvtj1 should be the size of dimension 1 of array *bvtj1
   !  Hint: ISIZE3OFDrfrev should be the size of dimension 3 of array *rev
   !  Hint: ISIZE2OFDrfrev should be the size of dimension 2 of array *rev
   !  Hint: ISIZE1OFDrfrev should be the size of dimension 1 of array *rev
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
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rev0d, rev1d, rev2d
   EXTERNAL DEBUG_TGT_HERE
   LOGICAL :: DEBUG_TGT_HERE
   IF (.TRUE. .AND. DEBUG_TGT_HERE('entry', .FALSE.)) THEN
   CALL DEBUG_TGT_REAL8ARRAY('rev', rev, revd, ISIZE1OFDrfrev*&
   &                        ISIZE2OFDrfrev*ISIZE3OFDrfrev)
   CALL DEBUG_TGT_REAL8ARRAY('bvtj1', bvtj1, bvtj1d, ISIZE1OFDrfbvtj1*&
   &                        ISIZE2OFDrfbvtj1*ISIZE3OFDrfbvtj1)
   CALL DEBUG_TGT_REAL8ARRAY('bvtj2', bvtj2, bvtj2d, ISIZE1OFDrfbvtj2*&
   &                        ISIZE2OFDrfbvtj2*ISIZE3OFDrfbvtj2)
   CALL DEBUG_TGT_REAL8ARRAY('bmtk1', bmtk1, bmtk1d, ISIZE1OFDrfbmtk1*&
   &                        ISIZE2OFDrfbmtk1*ISIZE3OFDrfbmtk1*&
   &                        ISIZE4OFDrfbmtk1)
   CALL DEBUG_TGT_REAL8ARRAY('w', w, wd, ISIZE1OFDrfw*ISIZE2OFDrfw*&
   &                        ISIZE3OFDrfw*ISIZE4OFDrfw)
   CALL DEBUG_TGT_REAL8ARRAY('bmtk2', bmtk2, bmtk2d, ISIZE1OFDrfbmtk2*&
   &                        ISIZE2OFDrfbmtk2*ISIZE3OFDrfbmtk2*&
   &                        ISIZE4OFDrfbmtk2)
   CALL DEBUG_TGT_REAL8ARRAY('rlv', rlv, rlvd, ISIZE1OFDrfrlv*&
   &                        ISIZE2OFDrfrlv*ISIZE3OFDrfrlv)
   CALL DEBUG_TGT_REAL8ARRAY('bvtk1', bvtk1, bvtk1d, ISIZE1OFDrfbvtk1*&
   &                        ISIZE2OFDrfbvtk1*ISIZE3OFDrfbvtk1)
   CALL DEBUG_TGT_REAL8ARRAY('bvtk2', bvtk2, bvtk2d, ISIZE1OFDrfbvtk2*&
   &                        ISIZE2OFDrfbvtk2*ISIZE3OFDrfbvtk2)
   CALL DEBUG_TGT_REAL8ARRAY('bmti1', bmti1, bmti1d, ISIZE1OFDrfbmti1*&
   &                        ISIZE2OFDrfbmti1*ISIZE3OFDrfbmti1*&
   &                        ISIZE4OFDrfbmti1)
   CALL DEBUG_TGT_REAL8ARRAY('bmti2', bmti2, bmti2d, ISIZE1OFDrfbmti2*&
   &                        ISIZE2OFDrfbmti2*ISIZE3OFDrfbmti2*&
   &                        ISIZE4OFDrfbmti2)
   CALL DEBUG_TGT_REAL8ARRAY('bvti1', bvti1, bvti1d, ISIZE1OFDrfbvti1*&
   &                        ISIZE2OFDrfbvti1*ISIZE3OFDrfbvti1)
   CALL DEBUG_TGT_REAL8ARRAY('bvti2', bvti2, bvti2d, ISIZE1OFDrfbvti2*&
   &                        ISIZE2OFDrfbvti2*ISIZE3OFDrfbvti2)
   CALL DEBUG_TGT_REAL8ARRAY('bmtj1', bmtj1, bmtj1d, ISIZE1OFDrfbmtj1*&
   &                        ISIZE2OFDrfbmtj1*ISIZE3OFDrfbmtj1*&
   &                        ISIZE4OFDrfbmtj1)
   CALL DEBUG_TGT_REAL8ARRAY('bmtj2', bmtj2, bmtj2d, ISIZE1OFDrfbmtj2*&
   &                        ISIZE2OFDrfbmtj2*ISIZE3OFDrfbmtj2*&
   &                        ISIZE4OFDrfbmtj2)
   CALL DEBUG_TGT_DISPLAY('entry')
   END IF
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Begin execution                                                *
   !      *                                                                *
   !      ******************************************************************
   !
   ! Loop over the viscous subfaces of this block.
   bocos:DO nn=1,nviscbocos
   CALL DEBUG_TGT_CALL('BCTURBWALL', .TRUE., .FALSE.)
   ! Set the corresponding arrays.
   CALL BCTURBWALL_T(nn)
   CALL DEBUG_TGT_EXIT()
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
   rev0d => revd(0, 1:, 1:)
   rev0 => rev(0, 1:, 1:)
   rev1d => revd(1, 1:, 1:)
   rev1 => rev(1, 1:, 1:)
   rev2d => revd(2, 1:, 1:)
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
   rev0d => revd(ib, 1:, 1:)
   rev0 => rev(ib, 1:, 1:)
   rev1d => revd(ie, 1:, 1:)
   rev1 => rev(ie, 1:, 1:)
   rev2d => revd(il, 1:, 1:)
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
   rev0d => revd(1:, 0, 1:)
   rev0 => rev(1:, 0, 1:)
   rev1d => revd(1:, 1, 1:)
   rev1 => rev(1:, 1, 1:)
   rev2d => revd(1:, 2, 1:)
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
   rev0d => revd(1:, jb, 1:)
   rev0 => rev(1:, jb, 1:)
   rev1d => revd(1:, je, 1:)
   rev1 => rev(1:, je, 1:)
   rev2d => revd(1:, jl, 1:)
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
   rev0d => revd(1:, 1:, 0)
   rev0 => rev(1:, 1:, 0)
   rev1d => revd(1:, 1:, 1)
   rev1 => rev(1:, 1:, 1)
   rev2d => revd(1:, 1:, 2)
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
   rev0d => revd(1:, 1:, kb)
   rev0 => rev(1:, 1:, kb)
   rev1d => revd(1:, 1:, ke)
   rev1 => rev(1:, 1:, ke)
   rev2d => revd(1:, 1:, kl)
   rev2 => rev(1:, 1:, kl)
   END IF
   END SELECT
   ! Loop over the faces and set the state in
   ! the turbulent halo cells.
   DO j=bcdata(nn)%jcbeg,bcdata(nn)%jcend
   DO i=bcdata(nn)%icbeg,bcdata(nn)%icend
   DO l=nt1,nt2
   IF (.TRUE. .AND. DEBUG_TGT_HERE('middle', .FALSE.)) THEN
   CALL DEBUG_TGT_REAL8ARRAY('rev', rev, revd, ISIZE1OFDrfrev*&
   &                                ISIZE2OFDrfrev*ISIZE3OFDrfrev)
   CALL DEBUG_TGT_REAL8ARRAY('bvtj1', bvtj1, bvtj1d, &
   &                                ISIZE1OFDrfbvtj1*ISIZE2OFDrfbvtj1*&
   &                                ISIZE3OFDrfbvtj1)
   CALL DEBUG_TGT_REAL8ARRAY('bvtj2', bvtj2, bvtj2d, &
   &                                ISIZE1OFDrfbvtj2*ISIZE2OFDrfbvtj2*&
   &                                ISIZE3OFDrfbvtj2)
   CALL DEBUG_TGT_REAL8ARRAY('bmtk1', bmtk1, bmtk1d, &
   &                                ISIZE1OFDrfbmtk1*ISIZE2OFDrfbmtk1*&
   &                                ISIZE3OFDrfbmtk1*ISIZE4OFDrfbmtk1)
   CALL DEBUG_TGT_REAL8ARRAY('w', w, wd, ISIZE1OFDrfw*&
   &                                ISIZE2OFDrfw*ISIZE3OFDrfw*ISIZE4OFDrfw)
   CALL DEBUG_TGT_REAL8ARRAY('bmtk2', bmtk2, bmtk2d, &
   &                                ISIZE1OFDrfbmtk2*ISIZE2OFDrfbmtk2*&
   &                                ISIZE3OFDrfbmtk2*ISIZE4OFDrfbmtk2)
   CALL DEBUG_TGT_REAL8ARRAY('rlv', rlv, rlvd, ISIZE1OFDrfrlv*&
   &                                ISIZE2OFDrfrlv*ISIZE3OFDrfrlv)
   CALL DEBUG_TGT_REAL8ARRAY('bvtk1', bvtk1, bvtk1d, &
   &                                ISIZE1OFDrfbvtk1*ISIZE2OFDrfbvtk1*&
   &                                ISIZE3OFDrfbvtk1)
   CALL DEBUG_TGT_REAL8ARRAY('bvtk2', bvtk2, bvtk2d, &
   &                                ISIZE1OFDrfbvtk2*ISIZE2OFDrfbvtk2*&
   &                                ISIZE3OFDrfbvtk2)
   CALL DEBUG_TGT_REAL8ARRAY('bmti1', bmti1, bmti1d, &
   &                                ISIZE1OFDrfbmti1*ISIZE2OFDrfbmti1*&
   &                                ISIZE3OFDrfbmti1*ISIZE4OFDrfbmti1)
   CALL DEBUG_TGT_REAL8ARRAY('bmti2', bmti2, bmti2d, &
   &                                ISIZE1OFDrfbmti2*ISIZE2OFDrfbmti2*&
   &                                ISIZE3OFDrfbmti2*ISIZE4OFDrfbmti2)
   CALL DEBUG_TGT_REAL8ARRAY('bvti1', bvti1, bvti1d, &
   &                                ISIZE1OFDrfbvti1*ISIZE2OFDrfbvti1*&
   &                                ISIZE3OFDrfbvti1)
   CALL DEBUG_TGT_REAL8ARRAY('bvti2', bvti2, bvti2d, &
   &                                ISIZE1OFDrfbvti2*ISIZE2OFDrfbvti2*&
   &                                ISIZE3OFDrfbvti2)
   CALL DEBUG_TGT_REAL8ARRAY('bmtj1', bmtj1, bmtj1d, &
   &                                ISIZE1OFDrfbmtj1*ISIZE2OFDrfbmtj1*&
   &                                ISIZE3OFDrfbmtj1*ISIZE4OFDrfbmtj1)
   CALL DEBUG_TGT_REAL8ARRAY('bmtj2', bmtj2, bmtj2d, &
   &                                ISIZE1OFDrfbmtj2*ISIZE2OFDrfbmtj2*&
   &                                ISIZE3OFDrfbmtj2*ISIZE4OFDrfbmtj2)
   CALL DEBUG_TGT_DISPLAY('middle')
   END IF
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
   rev1d(i, j) = -rev2d(i, j)
   rev1(i, j) = -rev2(i, j)
   END DO
   END DO
   IF (secondhalo) THEN
   DO j=bcdata(nn)%jcbeg,bcdata(nn)%jcend
   DO i=bcdata(nn)%icbeg,bcdata(nn)%icend
   rev0d(i, j) = rev1d(i, j)
   rev0(i, j) = rev1(i, j)
   END DO
   END DO
   END IF
   END IF
   END DO bocos
   IF (.TRUE. .AND. DEBUG_TGT_HERE('exit', .FALSE.)) THEN
   CALL DEBUG_TGT_REAL8ARRAY('rev', rev, revd, ISIZE1OFDrfrev*&
   &                        ISIZE2OFDrfrev*ISIZE3OFDrfrev)
   CALL DEBUG_TGT_REAL8ARRAY('bvtj1', bvtj1, bvtj1d, ISIZE1OFDrfbvtj1*&
   &                        ISIZE2OFDrfbvtj1*ISIZE3OFDrfbvtj1)
   CALL DEBUG_TGT_REAL8ARRAY('bvtj2', bvtj2, bvtj2d, ISIZE1OFDrfbvtj2*&
   &                        ISIZE2OFDrfbvtj2*ISIZE3OFDrfbvtj2)
   CALL DEBUG_TGT_REAL8ARRAY('bmtk1', bmtk1, bmtk1d, ISIZE1OFDrfbmtk1*&
   &                        ISIZE2OFDrfbmtk1*ISIZE3OFDrfbmtk1*&
   &                        ISIZE4OFDrfbmtk1)
   CALL DEBUG_TGT_REAL8ARRAY('w', w, wd, ISIZE1OFDrfw*ISIZE2OFDrfw*&
   &                        ISIZE3OFDrfw*ISIZE4OFDrfw)
   CALL DEBUG_TGT_REAL8ARRAY('bmtk2', bmtk2, bmtk2d, ISIZE1OFDrfbmtk2*&
   &                        ISIZE2OFDrfbmtk2*ISIZE3OFDrfbmtk2*&
   &                        ISIZE4OFDrfbmtk2)
   CALL DEBUG_TGT_REAL8ARRAY('bvtk1', bvtk1, bvtk1d, ISIZE1OFDrfbvtk1*&
   &                        ISIZE2OFDrfbvtk1*ISIZE3OFDrfbvtk1)
   CALL DEBUG_TGT_REAL8ARRAY('bvtk2', bvtk2, bvtk2d, ISIZE1OFDrfbvtk2*&
   &                        ISIZE2OFDrfbvtk2*ISIZE3OFDrfbvtk2)
   CALL DEBUG_TGT_REAL8ARRAY('bmti1', bmti1, bmti1d, ISIZE1OFDrfbmti1*&
   &                        ISIZE2OFDrfbmti1*ISIZE3OFDrfbmti1*&
   &                        ISIZE4OFDrfbmti1)
   CALL DEBUG_TGT_REAL8ARRAY('bmti2', bmti2, bmti2d, ISIZE1OFDrfbmti2*&
   &                        ISIZE2OFDrfbmti2*ISIZE3OFDrfbmti2*&
   &                        ISIZE4OFDrfbmti2)
   CALL DEBUG_TGT_REAL8ARRAY('bvti1', bvti1, bvti1d, ISIZE1OFDrfbvti1*&
   &                        ISIZE2OFDrfbvti1*ISIZE3OFDrfbvti1)
   CALL DEBUG_TGT_REAL8ARRAY('bvti2', bvti2, bvti2d, ISIZE1OFDrfbvti2*&
   &                        ISIZE2OFDrfbvti2*ISIZE3OFDrfbvti2)
   CALL DEBUG_TGT_REAL8ARRAY('bmtj1', bmtj1, bmtj1d, ISIZE1OFDrfbmtj1*&
   &                        ISIZE2OFDrfbmtj1*ISIZE3OFDrfbmtj1*&
   &                        ISIZE4OFDrfbmtj1)
   CALL DEBUG_TGT_REAL8ARRAY('bmtj2', bmtj2, bmtj2d, ISIZE1OFDrfbmtj2*&
   &                        ISIZE2OFDrfbmtj2*ISIZE3OFDrfbmtj2*&
   &                        ISIZE4OFDrfbmtj2)
   CALL DEBUG_TGT_DISPLAY('exit')
   END IF
   END SUBROUTINE TURBBCNSWALL_T