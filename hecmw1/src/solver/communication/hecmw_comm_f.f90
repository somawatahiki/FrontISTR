!======================================================================!
!                                                                      !
!   Software Name : HEC-MW Library for PC-cluster                      !
!         Version : 2.1                                                !
!                                                                      !
!     Last Update : 2006/06/01                                         !
!        Category : Linear Solver                                      !
!                                                                      !
!            Written by Kengo Nakajima (Univ. of Tokyo)                !
!                                                                      !
!     Contact address :  IIS,The University of Tokyo RSS21 project     !
!                                                                      !
!     "Structural Analysis System for General-purpose Coupling         !
!      Simulations Using High End Computing Middleware (HEC-MW)"       !
!                                                                      !
!======================================================================!

module m_hecmw_comm_f
contains

!C
!C***
!C*** hecmw_barrier
!C***
!C
      subroutine hecmw_barrier (hecMESH)
      use hecmw_util
      implicit none
      integer(kind=kint):: ierr
      type (hecmwST_local_mesh) :: hecMESH

      call MPI_BARRIER (hecMESH%MPI_COMM, ierr)
      end subroutine hecmw_barrier

      subroutine hecmw_scatterv_DP(sbuf, sc, disp, rbuf, rc, root, comm)
      use hecmw_util
      integer(kind=kint) :: sc      !send counts
      double precision   :: sbuf(sc) !send buffer
      integer(kind=kint) :: disp    !displacement
      integer(kind=kint) :: rc      !receive counts
      double precision   :: rbuf(rc) !receive buffer
      integer(kind=kint) :: root
      integer(kind=kint) :: comm
      integer(kind=kint) :: ierr

      CALL MPI_scatterv( sbuf, sc, disp, MPI_DOUBLE_PRECISION, &
                         rbuff, rc, MPI_DOUBLE_PRECISION, &
                         root, comm, ierr )

      end subroutine hecmw_scatterv_DP

!C
!C***
!C*** hecmw_allREDUCE
!C***
!C
      subroutine hecmw_allreduce_DP(VAL,VALM,n,hec_op,comm )
      use hecmw_util
      implicit none
      integer(kind=kint) :: n, hec_op,op, comm, ierr
      double precision, dimension(n) :: VAL
      double precision, dimension(n) :: VALM

      select case( hec_op )
      case ( hecmw_sum )
          op = MPI_SUM
      case ( hecmw_prod )
          op = MPI_PROD
      case ( hecmw_max )
          op = MPI_MAX
      case ( hecmw_min )
          op = MPI_MIN
      end select
      call MPI_allREDUCE(VAL,VALM,n,MPI_DOUBLE_PRECISION,op,comm,ierr)

      end subroutine hecmw_allREDUCE_DP

      subroutine hecmw_allreduce_DP1(s1,s2,hec_op,comm )
      use hecmw_util
      implicit none
      integer(kind=kint) ::  hec_op, comm
      double precision :: s1, s2
      double precision, dimension(1) :: VAL
      double precision, dimension(1) :: VALM
      VAL(1) = s1
      VALM(1) = s2
      call hecmw_allreduce_DP(VAL,VALM,1,hec_op,comm )
      s1 = VAL(1)
      s2 = VALM(1)
      end subroutine hecmw_allreduce_DP1
!C
!C***
!C*** hecmw_allREDUCE_R
!C***
!C
      subroutine hecmw_allreduce_R (hecMESH, VAL, n, ntag)
      use hecmw_util
      implicit none
      integer(kind=kint):: n, ntag, ierr
      real(kind=kreal), dimension(n) :: VAL
      real(kind=kreal), dimension(:), allocatable :: VALM
      type (hecmwST_local_mesh) :: hecMESH

      allocate (VALM(n))
      VALM= 0.d0
      if (ntag .eq. hecmw_sum) then
        call MPI_allREDUCE                                              &
     &       (VAL, VALM, n, MPI_DOUBLE_PRECISION, MPI_SUM,              &
     &        hecMESH%MPI_COMM, ierr)
      endif

      if (ntag .eq. hecmw_max) then
        call MPI_allREDUCE                                              &
     &       (VAL, VALM, n, MPI_DOUBLE_PRECISION, MPI_MAX,              &
     &        hecMESH%MPI_COMM, ierr)
      endif

      if (ntag .eq. hecmw_min) then
        call MPI_allREDUCE                                              &
     &       (VAL, VALM, n, MPI_DOUBLE_PRECISION, MPI_MIN,              &
     &        hecMESH%MPI_COMM, ierr)
      endif

      VAL= VALM
      deallocate (VALM)

      end subroutine hecmw_allreduce_R

      subroutine hecmw_allreduce_R1 (hecMESH, s, ntag)
      use hecmw_util
      implicit none
      integer(kind=kint):: ntag
      real(kind=kreal) :: s
      real(kind=kreal), dimension(1) :: VAL
      type (hecmwST_local_mesh) :: hecMESH
      VAL(1) = s
      call hecmw_allreduce_R(hecMESH, VAL, 1, ntag )
      s = VAL(1)
      end subroutine hecmw_allreduce_R1

!C
!C***
!C*** hecmw_allREDUCE_I
!C***
!C
      subroutine hecmw_allreduce_I(hecMESH, VAL, n, ntag)
      use hecmw_util
      implicit none
      integer(kind=kint):: n, ntag, ierr
      integer(kind=kint), dimension(n) :: VAL
      integer(kind=kint), dimension(:), allocatable :: VALM
      type (hecmwST_local_mesh) :: hecMESH

      allocate (VALM(n))
      VALM= 0
      if (ntag .eq. hecmw_sum) then
        call MPI_allREDUCE                                              &
     &       (VAL, VALM, n, MPI_INTEGER, MPI_SUM,                       &
     &        hecMESH%MPI_COMM, ierr)
      endif

      if (ntag .eq. hecmw_max) then
        call MPI_allREDUCE                                              &
     &       (VAL, VALM, n, MPI_INTEGER, MPI_MAX,                       &
     &        hecMESH%MPI_COMM, ierr)
      endif

      if (ntag .eq. hecmw_min) then
        call MPI_allREDUCE                                              &
     &       (VAL, VALM, n, MPI_INTEGER, MPI_MIN,                       &
     &        hecMESH%MPI_COMM, ierr)
      endif


      VAL= VALM
      deallocate (VALM)
      end subroutine hecmw_allreduce_I

      subroutine hecmw_allreduce_I1 (hecMESH, s, ntag)
      use hecmw_util
      implicit none
      integer(kind=kint)::  ntag, s
      integer(kind=kint), dimension(1) :: VAL
      type (hecmwST_local_mesh) :: hecMESH

      VAL(1) = s
      call hecmw_allreduce_I(hecMESH, VAL, 1, ntag )
      s = VAL(1)
      end subroutine hecmw_allreduce_I1

!C
!C***
!C*** hecmw_bcast_R
!C***
!C
      subroutine hecmw_bcast_R (hecMESH, VAL, n, nbase)
      use hecmw_util
      implicit none
      integer(kind=kint):: n, nbase, ierr
      real(kind=kreal), dimension(n) :: VAL
      type (hecmwST_local_mesh) :: hecMESH
      call MPI_BCAST (VAL, n, MPI_DOUBLE_PRECISION, nbase, hecMESH%MPI_COMM, ierr)
      end subroutine hecmw_bcast_R

      subroutine hecmw_bcast_R1 (hecMESH, s, nbase)
      use hecmw_util
      implicit none
      integer(kind=kint):: nbase, ierr
      real(kind=kreal) :: s
      real(kind=kreal), dimension(1) :: VAL
      type (hecmwST_local_mesh) :: hecMESH
      VAL(1)=s
      call MPI_BCAST (VAL, 1, MPI_DOUBLE_PRECISION, nbase, hecMESH%MPI_COMM, ierr)
      s = VAL(1)
      end subroutine hecmw_bcast_R1
!C
!C***
!C*** hecmw_bcast_I
!C***
!C
      subroutine hecmw_bcast_I (hecMESH, VAL, n, nbase)
      use hecmw_util
      implicit none
      integer(kind=kint):: n, nbase, ierr
      integer(kind=kint), dimension(n) :: VAL
      type (hecmwST_local_mesh) :: hecMESH
      call MPI_BCAST (VAL, n, MPI_INTEGER, nbase, hecMESH%MPI_COMM, ierr)
      end subroutine hecmw_bcast_I

      subroutine hecmw_bcast_I1 (hecMESH, s, nbase)
      use hecmw_util
      implicit none
      integer(kind=kint):: nbase, ierr,s
      integer(kind=kint), dimension(1) :: VAL
      type (hecmwST_local_mesh) :: hecMESH
      VAL(1) = s
      call MPI_BCAST (VAL, 1, MPI_INTEGER, nbase, hecMESH%MPI_COMM, ierr)
      s = VAL(1)
      end subroutine hecmw_bcast_I1
!C
!C***
!C*** hecmw_bcast_C
!C***
!C
      subroutine hecmw_bcast_C (hecMESH, VAL, n, nn, nbase)
      use hecmw_util
      implicit none
      integer(kind=kint):: n, nn, nbase, ierr
      character(len=n) :: VAL(nn)
      type (hecmwST_local_mesh) :: hecMESH

      call MPI_BCAST (VAL, n*nn, MPI_CHARACTER, nbase, hecMESH%MPI_COMM,&
     &                                                 ierr)
      end subroutine hecmw_bcast_C

!C
!C***
!C*** hecmw_update_1_R
!C***
!C
!C    1-DOF, REAL
!C
      subroutine hecmw_update_1_R (hecMESH, VAL, n)
      use hecmw_util
      use  hecmw_solver_SR_11

      implicit none
      integer(kind=kint):: n
      real(kind=kreal), dimension(n) :: VAL
      real(kind=kreal), dimension(:), allocatable :: WS, WR
      type (hecmwST_local_mesh) :: hecMESH

      n = hecMESH%n_node

      allocate (WS(n), WR(n))
      WS= 0.d0
      WR= 0.d0
      call hecmw_solve_SEND_RECV_11                                     &
     &   ( n, hecMESH%n_neighbor_pe, hecMESH%neighbor_pe,               &
     &     hecMESH%import_index, hecMESH%import_item,                   &
     &     hecMESH%export_index, hecMESH%export_item,                   &
     &     WS, WR, VAL , hecMESH%MPI_COMM, hecMESH%my_rank)
      deallocate (WS, WR)

      end subroutine hecmw_update_1_R

!C
!C***
!C*** hecmw_update_2_R
!C***
!C
!C    2-DOF, REAL
!C
      subroutine hecmw_update_2_R (hecMESH, VAL, n)
      use hecmw_util
      use  hecmw_solver_SR_22

      implicit none
      integer(kind=kint):: n
      real(kind=kreal), dimension(2*n) :: VAL
      real(kind=kreal), dimension(:), allocatable :: WS, WR
      type (hecmwST_local_mesh) :: hecMESH

      n = hecMESH%n_node

      allocate (WS(2*n), WR(2*n))
      WS= 0.d0
      WR= 0.d0
      call hecmw_solve_SEND_RECV_22                                     &
     &   ( n, hecMESH%n_neighbor_pe, hecMESH%neighbor_pe,               &
     &     hecMESH%import_index, hecMESH%import_item,                   &
     &     hecMESH%export_index, hecMESH%export_item,                   &
     &     WS, WR, VAL , hecMESH%MPI_COMM, hecMESH%my_rank)
      deallocate (WS, WR)

      end subroutine hecmw_update_2_R

!C
!C***
!C*** hecmw_update_3_R
!C***
!C
!C    3-DOF, REAL
!C
      subroutine hecmw_update_3_R (hecMESH, VAL, n)
      use hecmw_util
      use  hecmw_solver_SR_33

      implicit none
      integer(kind=kint):: n
      real(kind=kreal), dimension(3*n) :: VAL
      real(kind=kreal), dimension(:), allocatable :: WS, WR
      type (hecmwST_local_mesh) :: hecMESH

      n = hecMESH%n_node

      allocate (WS(3*n), WR(3*n))
      WS= 0.d0
      WR= 0.d0
      call hecmw_solve_SEND_RECV_33                                     &
     &   ( n, hecMESH%n_neighbor_pe, hecMESH%neighbor_pe,               &
     &     hecMESH%import_index, hecMESH%import_item,                   &
     &     hecMESH%export_index, hecMESH%export_item,                   &
     &     WS, WR, VAL , hecMESH%MPI_COMM, hecMESH%my_rank)
      deallocate (WS, WR)

      end subroutine hecmw_update_3_R

!C
!C***
!C*** hecmw_update_m_R
!C***
!C
!C    m-DOF, REAL
!C
      subroutine hecmw_update_m_R (hecMESH, VAL, n, m)
      use hecmw_util
      use  hecmw_solver_SR_mm

      implicit none
      integer(kind=kint):: n, m
      real(kind=kreal), dimension(m*n) :: VAL
      real(kind=kreal), dimension(:), allocatable :: WS, WR
      type (hecmwST_local_mesh) :: hecMESH

      n = hecMESH%n_node

      allocate (WS(m*n), WR(m*n))
      WS= 0.d0
      WR= 0.d0
      call hecmw_solve_SEND_RECV_mm                                     &
     &   ( n, m, hecMESH%n_neighbor_pe, hecMESH%neighbor_pe,            &
     &     hecMESH%import_index, hecMESH%import_item,                   &
     &     hecMESH%export_index, hecMESH%export_item,                   &
     &     WS, WR, VAL , hecMESH%MPI_COMM, hecMESH%my_rank)
      deallocate (WS, WR)

      end subroutine hecmw_update_m_R

!C
!C***
!C*** hecmw_update_1_I
!C***
!C
!C    1-DOF, INTEGER
!C
      subroutine hecmw_update_1_I (hecMESH, VAL, n)
      use hecmw_util
      use  hecmw_solver_SR_11i

      implicit none
      integer(kind=kint):: n
      integer(kind=kint), dimension(n) :: VAL
      integer(kind=kint), dimension(:), allocatable :: WS, WR
      type (hecmwST_local_mesh) :: hecMESH

      n = hecMESH%n_node

      allocate (WS(n), WR(n))
      WS= 0.d0
      WR= 0.d0
      call hecmw_solve_SEND_RECV_11i                                    &
     &   ( n, hecMESH%n_neighbor_pe, hecMESH%neighbor_pe,               &
     &     hecMESH%import_index, hecMESH%import_item,                   &
     &     hecMESH%export_index, hecMESH%export_item,                   &
     &     WS, WR, VAL , hecMESH%MPI_COMM, hecMESH%my_rank)
      deallocate (WS, WR)

      end subroutine hecmw_update_1_I

!C
!C***
!C*** hecmw_update_2_I
!C***
!C
!C    2-DOF, INTEGER
!C
      subroutine hecmw_update_2_I (hecMESH, VAL, n)
      use hecmw_util
      use  hecmw_solver_SR_22i

      implicit none
      integer(kind=kint):: n
      integer(kind=kint), dimension(2*n) :: VAL
      integer(kind=kint), dimension(:), allocatable :: WS, WR
      type (hecmwST_local_mesh) :: hecMESH

      n = hecMESH%n_node

      allocate (WS(2*n), WR(2*n))
      WS= 0.d0
      WR= 0.d0
      call hecmw_solve_SEND_RECV_22i                                    &
     &   ( n, hecMESH%n_neighbor_pe, hecMESH%neighbor_pe,               &
     &     hecMESH%import_index, hecMESH%import_item,                   &
     &     hecMESH%export_index, hecMESH%export_item,                   &
     &     WS, WR, VAL , hecMESH%MPI_COMM, hecMESH%my_rank)
      deallocate (WS, WR)

      end subroutine hecmw_update_2_I

!C
!C***
!C*** hecmw_update_3_I
!C***
!C
!C    3-DOF, INTEGER
!C
      subroutine hecmw_update_3_I (hecMESH, VAL, n)
      use hecmw_util
      use  hecmw_solver_SR_33i

      implicit none
      integer(kind=kint):: n
      integer(kind=kint), dimension(3*n) :: VAL
      integer(kind=kint), dimension(:), allocatable :: WS, WR
      type (hecmwST_local_mesh) :: hecMESH

      n = hecMESH%n_node

      allocate (WS(3*n), WR(3*n))
      WS= 0.d0
      WR= 0.d0
      call hecmw_solve_SEND_RECV_33i                                    &
     &   ( n, hecMESH%n_neighbor_pe, hecMESH%neighbor_pe,               &
     &     hecMESH%import_index, hecMESH%import_item,                   &
     &     hecMESH%export_index, hecMESH%export_item,                   &
     &     WS, WR, VAL , hecMESH%MPI_COMM, hecMESH%my_rank)
      deallocate (WS, WR)

      end subroutine hecmw_update_3_I

!C
!C***
!C*** hecmw_update_m_I
!C***
!C
!C    m-DOF, REAL
!C
      subroutine hecmw_update_m_I (hecMESH, VAL, n, m)
      use hecmw_util
      use  hecmw_solver_SR_mmi

      implicit none
      integer(kind=kint):: n, m
      integer(kind=kint), dimension(m*n) :: VAL
      integer(kind=kint), dimension(:), allocatable :: WS, WR
      type (hecmwST_local_mesh) :: hecMESH

      n = hecMESH%n_node

      allocate (WS(m*n), WR(m*n))
      WS= 0.d0
      WR= 0.d0
      call hecmw_solve_SEND_RECV_mmi                                    &
     &   ( n, m, hecMESH%n_neighbor_pe, hecMESH%neighbor_pe,            &
     &     hecMESH%import_index, hecMESH%import_item,                   &
     &     hecMESH%export_index, hecMESH%export_item,                   &
     &     WS, WR, VAL , hecMESH%MPI_COMM, hecMESH%my_rank)
      deallocate (WS, WR)

      end subroutine hecmw_update_m_I

end module m_hecmw_comm_f

