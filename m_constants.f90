module m_constants
    implicit none
    
    real(8), parameter :: dist_CC  = 1.54d0    ! Angstroms
    real(8), parameter :: angle_CC = 109.5d0   ! Degrees
    real(8), parameter :: phi_CC_mod   = 0.5d0    ! Degrees (dihedral)
    real(8), parameter :: sigma    = 3.94d0    ! LJ parameter
    real(8), parameter :: epsil    = 0.382d0   ! kJ/mol
    
    integer, parameter :: n_atoms  = 500
    integer, parameter :: l_box    = 2000      ! Angstroms

    

end module m_constants