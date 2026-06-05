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
    real(8) :: tower(n_atoms-3)
    integer :: seed
    real(8) :: temps(6)
    integer :: i
    character(len=50) :: dir_name, filename
    
    ! Temperature array
    temps = (/200.0d0, 300.0d0, 400.0d0, 500.0d0, 600.0d0, 700.0d0/)
    
    !Initial seed
    seed = 123456789
    
    
    do i = 1, 6
        temp = temps(i)
        
        ! Create directory for this temperature inside RESULTS
        write(dir_name, '(A,F0.1)') 'RESULTS/T_', temp
        call system('mkdir -p '//trim(dir_name))
        
        ! Initialize parameters
        accepted_moves = 0
        accepted_moves_b = 0
        rejected_moves = 0
        
        ! Use different seed for each thread
        seed = 123456789 + temp * 1000

        ! Initialize coordinates (linear zig-zag configuration)
        call init_conf(coord, 'initial_config.xyz')


        ! Open files for output in temperature directory
        write(filename, '(A,A,A)') trim(dir_name), '/trayectory.xyz'
        open(2, file=trim(filename), status='replace')
        write(filename, '(A,A,A)') trim(dir_name), '/energy.txt'
        open(3, file=trim(filename), status='replace')
        write(filename, '(A,A,A)') trim(dir_name), '/dihedral_angles.txt'
        open(4, file=trim(filename), status='replace')
        write(filename, '(A,A,A)') trim(dir_name), '/distances.txt'
        open(5, file=trim(filename), status='replace')
        
        call write_coord(2, coord, step = 0)

        ! Initialize random number generator with thread-specific seed
        call init_rng(seed) 

        !Generate the tower for the selection of atoms based on the dihedral angles
        tower = tower_gen(n_atoms-3, k_factor) 

        dihedral_lst = phi_lst(coord) ! Calculate initial dihedral angles list

        !Calculate initial energy and dihedral angles
        call calc_energy(coord, dihedral_lst, E_LJ, E_dih)
        energy = E_LJ + E_dih

        !Write initial data to files
        call write_coord(2, coord, step = step)
        write(3, *) energy, E_LJ, E_dih
        
        ! Main Monte Carlo loop
        do step = 1, n_steps
            ! Generate a random rotation angle for the dihedral rotation
            phi_rot = (get_random() - 0.5d0) * 2.0d0 * phi_CC_mod  
            
            ! Perform a Monte Carlo step
            call MC_step(coord, phi_rot, tower, &
             accepted_moves, rejected_moves, energy, dihedral_lst, &
             E_LJ, E_dih)

            !Writing results to files every 10 steps
            if (mod(step, 10) == 0) then
                call write_coord(2, coord, step = step)
                write(3, *) energy, E_LJ, E_dih


                !We write angles and distances when equilibration is reached
                if (step > n_steps/2) then
                    write(5, *) end_end_dist(coord), rad_gyr(coord)
                    do j = 1, n_atoms-3
                        write(4, *) dihedral_lst(j)
                    end do
                end if
            end if

            ! Print progress every 10% of the total steps
            if(mod(step, n_steps/10) == 0) then
                print *, 'T=', temp, step/(n_steps/100), '% completed', &
                        'Accepted:', accepted_moves, 'Rejected : ', rejected_moves
            end if
        end do

        close(2)
        close(3)
        close(4)
        close(5)
        call close_rng() ! Close the random number generator
        print *,  'T=', temps(i), 'Simulation completed. Total accepted moves: ', &
                 accepted_moves, 'Total rejected moves: ', rejected_moves
    end do
    
    
    print *, "All simulations completed."
    

    
end program main


   
