module m_constants
    implicit none
    
    real(8), parameter :: dist_CC     = 1.54d0    ! Angstroms
    real(8), parameter :: angle_CC    = 109.5d0   ! Degrees
    real(8), parameter :: phi_CC_mod  = 60.0d0    ! Degrees (dihedral)
    real(8), parameter :: sigma       = 3.94d0    ! LJ parameter
    real(8), parameter :: epsil       = 0.382d0   ! kJ/mol
    real(8), parameter :: temp        = 2000.0d0   ! Kelvin
    real(8), parameter :: r_cut       = 10.5d0   ! Angstroms
    real(8), parameter :: Kb          = 8.314d-3  ! kJ/mol/K

    integer, parameter :: k_factor = 2 !Scaling factor in probability to choose a dihedral angle
    integer, parameter :: n_atoms  = 500
    integer, parameter :: l_box    = 2000      ! Angstroms
    integer, parameter :: n_steps   = 100000

    

end module m_constants