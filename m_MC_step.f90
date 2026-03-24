module m_MC_step
    use m_constants
    use m_rot_dihedral
    use m_ran_gen
    use m_energy
    implicit none
    contains

    subroutine MC_step(old_coord, n_atoms, phi_CC_mod, new_coord, temp, accepted_moves, rejected_moves)
        integer, intent(in) :: n_atoms
        real(8), intent(in) :: phi_CC_mod, old_coord(3, n_atoms), temp
        real(8), intent(out) :: new_coord(3, n_atoms)
        real(8) :: old_energy, new_energy, rand_num
        integer, intent(inout):: accepted_moves, rejected_moves
        integer :: i, rand_atom

        old_energy = 0.0d0
        new_energy = 0.0d0

        do i = 3, n_atoms-1
            old_energy = old_energy + calc_energy(calc_dihedral(old_coord, i), old_coord)
        end do

        new_coord = old_coord ! Start with the old coordinates for the new configuration

        do i = 3, n_atoms-1
            rand_num = get_random()
            rand_atom = int(3.0d0 + ((n_atoms - 1.0d0) - 3.0d0)* rand_num) ! Randomly select an atom between 3 and n_atoms-1
            call dihedral_rotation(rand_atom, new_coord, phi_CC_mod, n_atoms) ! Rotate the dihedral angle of the selected atom   
        end do

        do i = 3, n_atoms-1
            new_energy = new_energy + calc_energy(calc_dihedral(new_coord, i), new_coord)
        end do

        if (new_energy < old_energy) then
            accepted_moves = accepted_moves + 1

        else
            !Metropolis criterion
            if (get_random() < exp(-(1/temp)*(new_energy - old_energy))) then
                accepted_moves = accepted_moves + 1
            else
                rejected_moves = rejected_moves + 1
                new_coord = old_coord ! Revert to old coordinates if the new configuration is not accepted
            end if
        end if

    end subroutine MC_step

end module m_MC_step

