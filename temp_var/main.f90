program main
    use m_MC_step
    use m_init_conf
    use m_constants
    use m_write
    use m_distances
    use m_energy
    implicit none

    integer :: accepted_moves, accepted_moves_b, rejected_moves, j, step
    real(8) :: coord(3, n_atoms), phi_rot
    real(8) :: E_LJ, E_dih, energy, dihedral_lst(n_atoms-3)
    real(8) :: tower(n_atoms-3), temp
    integer(8) :: seed
    seed = 123456789 

    ! Initialize parameters
    accepted_moves = 0
    accepted_moves_b = 0
    rejected_moves = 0
    temp = i_temp

    ! Initialize coordinates (linear zig-zag configuration)
    call init_conf(coord, 'initial_config.xyz')

    ! Open files for output
    open(2, file='trayectory.xyz', status='replace')
    open(3, file='energy.txt', status='replace')
    open(4, file='dihedral_angles.txt', status='replace')
    open(5, file='distances.txt', status='replace')
    call write_coord(2, coord, step = 0)

    ! Initialize random number generator with a fixed seed for reproducibility
    call init_rng(seed) 

    !Generate the tower for the selection of atoms based on the dihedral angles
    tower = tower_gen(n_atoms-3, k_factor) 


    !Calculate initial energy and dihedral angles
    call calc_energy(coord, dihedral_lst, E_LJ, E_dih)

    !Write initial data to files
    call write_coord(2, coord, step = step)
    write(3, *) energy, E_LJ, E_dih, temp

    !Main Monte Carlo loop
    do step = 1, n_steps

        ! Generate a random rotation angle for the dihedral rotation
        phi_rot = (get_random() - 0.5d0) * 2.0d0 * phi_CC_mod
        
        !Temperature modification starting at 10% of the total steps and every n_steps/T_blocks steps
        if (step > n_steps/10 .and. mod(step- (n_steps/10), n_steps/T_blocks) == 0 .and. step < n_steps/2) then
            temp = temp * alpha
                print *, 'Temperature modified: ', temp
        end if
        
        ! Perform a Monte Carlo step
        call MC_step(coord, phi_rot, tower, &
         accepted_moves, rejected_moves, energy, dihedral_lst, &
         E_LJ, E_dih, temp)

        !Writing results to files every 100 steps
        if (mod(step, 100) == 0) then
            call write_coord(2, coord, step = step)
            write(3, *) energy, E_LJ, E_dih, temp

            !We write angles and distances when equilibration is reached
            if (step > n_steps/2) then
                do j = 1, n_atoms-3
                    write(4, *) dihedral_lst(j)
                    write(5, *) end_end_dist(coord), rad_gyr(coord)
                end do
            end if
        end if

        ! Print progress every 10% of the total steps
        if(mod(step, n_steps/10) == 0) then
            print *, step/(n_steps/100), '% completed', 'Accepted:', accepted_moves &
            , 'Rejected : ', rejected_moves
        end if
    end do

    close(2)
    close(3)
    close(4)
    close(5)
    call close_rng() ! Close the random number generator
end program main
   
