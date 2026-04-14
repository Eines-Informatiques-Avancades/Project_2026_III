module m_MC_step
    use m_constants
    use m_rot_dihedral
    use m_ran_gen
    use m_energy
    use m_tower
    implicit none
    contains

    !It performs one MC step
    subroutine MC_step(coord, phi_rot, tower, &
         accepted_moves, rejected_moves, energy, dihedral_lst, &
         E_LJ, E_dih, temp)
        real(8), intent(in) :: phi_rot, tower(n_atoms-3), temp
        real(8) :: rand_num, new_phi_lst(n_atoms-3), old_coord(3, n_atoms)
        real(8) :: E_LJ_new, E_dih_new, new_energy
        real(8), intent(inout) :: coord(3, n_atoms), energy, dihedral_lst(n_atoms-3), E_LJ, E_dih
        integer, intent(inout):: accepted_moves, rejected_moves
        integer :: rand_atom

        ! Select an atom based on the tower
        rand_atom = tower_sample(tower) 
        
        ! Store the old coordinates before rotation
        old_coord = coord 
        
        ! Perform the dihedral rotation on the selected atom
        call dihedral_rotation(rand_atom, coord, phi_rot, n_atoms) 
       
        ! Calculate the dihedral angles list for the new configuration
        new_phi_lst = phi_lst(coord)

        !Calculate the energy of the new configuration
        call calc_energy(coord, new_phi_lst, E_LJ_new, E_dih_new) 

        ! Total energy of the new configuration
        new_energy = E_LJ_new + E_dih_new 

        !Acept if new energy is lower
        if (new_energy < energy) then
            accepted_moves = accepted_moves + 1
            energy = new_energy
            E_LJ = E_LJ_new
            E_dih = E_dih_new
            dihedral_lst = new_phi_lst

        else
            !Metropolis criterion
            if (get_random() < exp(-(1/(temp * Kb))*(new_energy - energy))) then
                accepted_moves = accepted_moves + 1
                energy = new_energy
                E_LJ = E_LJ_new
                E_dih = E_dih_new
                dihedral_lst = new_phi_lst
            else
                rejected_moves = rejected_moves + 1
                coord = old_coord ! Revert to the old coordinates
            end if
        end if

    end subroutine MC_step

end module m_MC_step

