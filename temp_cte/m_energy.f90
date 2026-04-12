module m_energy
    use m_constants
    use m_rot_dihedral
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
        real(8) :: E, r2, sigma2, sigma6, sigma12
        real(8) :: dx, dy, dz, r2_inv, r6_inv
        real(8) :: r_cut2, r_cut2_inv, r_cut6_inv, E_cut
        integer :: i, j
        E = 0.0d0
        sigma2 = sigma**2
        sigma6 = sigma2**3
        sigma12 = sigma6**2

        r_cut2 = r_cut**2
        r_cut2_inv = 1.0d0 / r_cut2
        r_cut6_inv = r_cut2_inv**3
        E_cut = 4.0d0 * epsil * (sigma12 * r_cut6_inv**2 - sigma6 * r_cut6_inv)
        do i = 1, n_atoms-4
            do j = i+4, n_atoms
            !We calculate r2
            dx = coord(1,i) - coord(1,j)
            dy = coord(2,i) - coord(2,j)
            dz = coord(3,i) - coord(3,j)

            r2 = dx*dx + dy*dy + dz*dz
                if (r2 < r_cut2) then ! Exclude 1-2 and 1-3 interactions
                    r2_inv = 1.0d0 / r2
                    r6_inv = r2_inv**3

                    E = E + 4.0d0 * epsil * (sigma12 * r6_inv**2 - sigma6 * r6_inv)
                    E = E - E_cut ! Shift the energy to zero at the cutoff
                end if
            end do
        end do
    end function LJ_energy

    subroutine calc_energy(coord, dih_lst, E_LJ, E_dih)
        implicit none
        real(8), intent(in) :: coord(3, n_atoms), dih_lst(n_atoms-3)
        real(8), intent(out) :: E_LJ, E_dih
        integer :: i
        E_LJ = LJ_energy(coord)
        E_dih = 0.0d0

        do i = 3, n_atoms-1
            E_dih = E_dih + dih_energy(dih_lst(i-2))
        end do

    end subroutine calc_energy




    

end module m_energy