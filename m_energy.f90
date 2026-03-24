module m_energy
    use m_constants
    implicit none
contains

    function dih_energy(phi) result(E)
        implicit none
        real(8), intent(in)  :: phi    ! Dihedral angle in degrees
        real(8) :: E                   ! Energy in KJ/mol
        real(8) :: c0, c1, c2, c3

        ! Force field parameters in kcal/mol
        c0 = 1.736d0
        c1 = -4.490d0
        c2 = 0.776d0
        c3 = 6.990d0

        E = 0.0d0
        E = E + c0
        E = E + c1 * cosd(phi)
        E = E + c2 * (cosd(phi))**2
        E = E + c3 * (cosd(phi))**3

            ! Convert from kcal/mol to KJ/mol

        E = E * 4.184d0

        

    end function dih_energy

    function LJ_energy(coord) result(E)
        implicit none
        real(8), intent(in) :: coord(3, n_atoms)
        real(8) :: E, r2, sigma2
        integer :: i, j
        E = 0.0d0
        sigma2 = sigma**2
        do i = 1, n_atoms-1
            do j = i+1, n_atoms
                if (j - i > 2 .and. r2 < r_cut**2) then ! Exclude 1-2 and 1-3 interactions
                    r2 = sqrt((coord(1,i) - coord(1,j))**2 + &
                             (coord(2,i) - coord(2,j))**2 + &
                             (coord(3,i) - coord(3,j))**2)
                    E = E + 4.0d0 * epsil * ((sigma2/r2)**6 - (sigma2/r2)**3)
                end if
            end do
        end do
    end function LJ_energy

    function calc_energy(phi, coord) result(E)
        implicit none
        real(8), intent(in) :: phi, coord(3, n_atoms)
        real(8) :: E
        E = dih_energy(phi) + LJ_energy(coord)
    end function calc_energy




    

end module m_energy