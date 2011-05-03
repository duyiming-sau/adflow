   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.4 (r3375) - 10 Feb 2010 15:08
   !
   !  Differentiation of vectorrotationforces in reverse (adjoint) mode:
   !   gradient     of useful results: xp yp angle zp
   !   with respect to varying inputs: x y z angle
   !
   !     ******************************************************************
   !     *                                                                *
   !     * File:          vectorRotation.f90                              *
   !     * Author:        Andre C. Marta                                  *
   !     * Starting date: 06-23-2006                                      *
   !     * Last modified: 07-28-2006                                      *
   !     *                                                                *
   !     ******************************************************************
   !
   SUBROUTINE VECTORROTATIONFORCES_B(xp, xpb, yp, ypb, zp, zpb, iaxis, &
   &  angle, angleb, x, xb, y, yb, z, zb)
   USE PRECISION
   IMPLICIT NONE
   !
   !     ****************************************************************
   !     *                                                              *
   !     * vectorRotation rotates a given vector with respect to a      *
   !     * specified axis by a given angle.                             *
   !     *                                                              *
   !     *    input arguments:                                          *
   !     *       iaxis      = rotation axis (1-x, 2-y, 3-z)             *
   !     *       angle      = rotation angle (measured ccw in radians)  *
   !     *       x, y, z    = coordinates in original system            *
   !     *    output arguments:                                         *
   !     *       xp, yp, zp = coordinates in rotated system             *
   !     *                                                              *
   !     ****************************************************************
   !
   !
   !     Subroutine arguments.
   !
   INTEGER(kind=inttype), INTENT(IN) :: iaxis
   REAL(kind=realtype), INTENT(IN) :: angle, x, y, z
   REAL(kind=realtype) :: angleb, xb, yb, zb
   REAL(kind=realtype) :: xp, yp, zp
   REAL(kind=realtype) :: xpb, ypb, zpb
   INTRINSIC COS
   INTRINSIC SIN
   !
   !     ******************************************************************
   !     *                                                                *
   !     * Begin execution                                                *
   !     *                                                                *
   !     ******************************************************************
   !
   ! rotation about specified axis by specified angle
   SELECT CASE  (iaxis) 
   CASE (1) 
   xb = xpb
   angleb = angleb + (z*COS(angle)-y*SIN(angle))*ypb + (-(z*SIN(angle))&
   &      -y*COS(angle))*zpb
   yb = COS(angle)*ypb - SIN(angle)*zpb
   zb = SIN(angle)*ypb + COS(angle)*zpb
   CASE (2) 
   angleb = angleb + (-(z*COS(angle))-x*SIN(angle))*xpb + (x*COS(angle)&
   &      -z*SIN(angle))*zpb
   xb = COS(angle)*xpb + SIN(angle)*zpb
   yb = ypb
   zb = COS(angle)*zpb - SIN(angle)*xpb
   CASE (3) 
   xb = COS(angle)*xpb - SIN(angle)*ypb
   yb = COS(angle)*ypb + SIN(angle)*xpb
   zb = zpb
   angleb = angleb + (y*COS(angle)-x*SIN(angle))*xpb + (-(x*COS(angle))&
   &      -y*SIN(angle))*ypb
   CASE DEFAULT
   STOP
   END SELECT
   END SUBROUTINE VECTORROTATIONFORCES_B
