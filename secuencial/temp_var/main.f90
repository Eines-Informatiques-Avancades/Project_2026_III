program main
    use m_MC_step
    use m_init_conf
    use m_constants
    use m_write
    use m_distances
    use m_energy
    use :: omp_lib
    implicit none

    integer :: accepted_moves, accepted_moves_b, rejected_moves, j, step
    real(8) :: coord(3, n_atoms), phi_rot
    real(8) :: E_LJ, E_dih, energy, dihedral_lst(n_atoms-3)
    real(8) :: tower(n_atoms-3), temp, alpha
    integer(8) :: seed
    integer :: tid
    real(8) :: temps(6)
    integer :: i
    character(len=50) :: dir_name, filename
    real(8) :: start_time, end_time
    integer :: step_ini, step_end, step_size
    
    ! Temperature array
    temps = (/200.0d0, 300.0d0, 400.0d0, 500.0d0, 600.0d0, 700.0d0/)
    
    !Initial seed
    seed = 123456789
    
    start_time = omp_get_wtime()
    

    do i = 1, 6
        
        temp = temps(i)
                
        ! Create directory for this temperature inside PARALEL_RESULTS
        write(dir_name, '(A,F0.1)') 'PARALEL_RESULTS/T_', temp
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

        !Calculate initial energy and dihedral angles
        call calc_energy(coord, dihedral_lst, E_LJ, E_dih)
        energy = E_LJ + E_dih

        !Write initial data to files
        call write_coord(2, coord, step = step)
        write(3, *) energy, E_LJ, E_dih, temp

        !Alpha for temperature modification (starting from 2500K to target temperature)
        alpha = (temp/2500.0d0)**(1.0d0/REAL(T_blocks))

        !Control points of the simulation
        step_ini = nint(n_steps * 0.15) ! 15%
        step_end = nint(n_steps * 0.6)  ! 60%
        step_size =  (step_end- step_ini)/ T_blocks
        
        ! Set initial temperature for annealing
        temp = 2500.0d0

        ! Main Monte Carlo loop
        do step = 1, n_steps
            ! Generate a random rotation angle for the dihedral rotation
            phi_rot = (get_random() - 0.5d0) * 2.0d0 * phi_CC_mod
            
            !Temperature modification starting at 15% to the 60% of the total steps and every n_steps/T_blocks steps
            if (step > step_ini .and. step <= step_end) then
                if (mod(step -step_ini, step_size) == 0) then
                    temp = temp * alpha
                    if (mod(step, n_steps/10) == 0) then
                        print *, 'Thread', tid, 'T=', temps(i), 'Modifying temperature. Current temperature: ', temp, ' K'
                    end if
                end if
            end if
            
            ! Perform a Monte Carlo step
            call MC_step(coord, phi_rot, tower, &
             accepted_moves, rejected_moves, energy, dihedral_lst, &
             E_LJ, E_dih, temp)

            !Writing results to files every 10 steps
            if (mod(step, 10) == 0) then
                call write_coord(2, coord, step = step)
                write(3, *) energy, E_LJ, E_dih, temp

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
                print *, 'Thread', tid, 'T=', temps(i), step/(n_steps/100), '% completed', &
                        'Accepted:', accepted_moves, 'Rejected : ', rejected_moves
            end if
        end do

        close(2)
        close(3)
        close(4)
        close(5)
        call close_rng() ! Close the random number generator
        print *, 'Thread', tid, 'T=', temps(i), 'Simulation completed. Total accepted moves: ', &
                 accepted_moves, 'Total rejected moves: ', rejected_moves
    end do
    
    end_time = omp_get_wtime()
    print *, "All simulations completed."
    print *, "Total execution time:", end_time - start_time, "seconds"
    
    ! Save timing data to file
    call save_timing_data(end_time - start_time)
    
end program main

! Subroutine to save timing data
subroutine save_timing_data(execution_time)
    implicit none
    real(8), intent(in) :: execution_time
    integer :: unit_num
    character(len=100) :: filename
    
    ! Generate filename
    write(filename, '(A,I0,A)') 'timing_data.txt'
    
    ! Open file in append mode
    open(newunit=unit_num, file=filename, status='unknown', position='append')
    
    ! Write timing data
    write(unit_num, '(A,F12.6,A,I0,A)') 'PARALLEL_VAR: ', execution_time, ' seconds'
    
    close(unit_num)
    print *, "Timing data saved to: ", trim(filename)
    
end subroutine save_timing_data
   
