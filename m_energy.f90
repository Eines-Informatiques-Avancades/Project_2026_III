module m_energy
    use m_constants
    implicit none
contains

    function dih_energy(phi) result(E)
        implicit none
        real(8), intent(in)  :: phi    ! Dihedral angle in degrees
        real(8) :: E                   ! Energy in KJ/mol
        real(8) :: t1, t2, t3
        real(8), parameter :: pi = acos(-1.0d0)

        t1 = (phi * pi/180.0d0)
        t2 = ((phi + 57.3d0) * pi/180.0d0)
        t3 = ((phi*1.333d0 - 41.0d0) * pi/180.0d0)

        E = 0.0d0
        E = E + 2.7d0 * (1.0d0 - (2.0d0*cos(1.5d0*t1)**2 - 1.0d0))
        E = E + 1.2d0 * (1.0d0 - cos(t2 - 1.87d0))
        E = E + 0.8d0 * (1.0d0 - cos( (t3 + sin(t2)) ))
        E = E * 1.05
        print '(A15, F12.6)', 'Dihedral Energy: ', E

    end function dih_energy

    function LJ_energy(coord) result(E)
        implicit none
        real(8), intent(in) :: coord(3, n_atoms)
        real(8) :: E, r
        integer :: i, j
        E = 0.0d0
        do i = 1, n_atoms-1
            do j = i+1, n_atoms
                if (j - i > 2) then ! Exclude 1-2 and 1-3 interactions
                    r = sqrt((coord(1,i) - coord(1,j))**2 + &
                             (coord(2,i) - coord(2,j))**2 + &
                             (coord(3,i) - coord(3,j))**2)
                    E = E + 4.0d0 * epsil * ((sigma/r)**12 - (sigma/r)**6)
                end if
            end do
        end do
        print '(A15, F12.6)', 'LJ Energy: ', E
    end function LJ_energy

    function calc_energy(phi, coord) result(E)
        implicit none
        real(8), intent(in) :: phi, coord(3, n_atoms)
        real(8) :: E
        E = dih_energy(phi) + LJ_energy(coord)
        print '(A15, F12.6)', 'Total Energy: ', E
    end function calc_energy




    

end module m_energy