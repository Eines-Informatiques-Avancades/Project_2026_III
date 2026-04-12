program main
    use m_MC_step
    use m_init_conf
    use m_constants
    use m_write
    implicit none

    integer :: accepted_moves, accepted_moves_b, rejected_moves, j, step
    real(8) :: coord(3, n_atoms), phi_rot
    real(8) :: E_LJ, E_dih, energy, dihedral_lst(n_atoms-3)
    real(8) :: tower(n_atoms-3)
    integer(8) :: seed
    seed = 123456789 

    ! Initialize parameters
    accepted_moves = 0
    accepted_moves_b = 0
    rejected_moves = 0

    ! Initialize coordinates (linear zig-zag configuration)
    call init_conf(coord, 'initial_config.xyz')

    open(2, file='trayectory.xyz', status='replace')
    open(3, file='energy_log.txt', status='replace')
    open(4, file='dihedral_angles.txt', status='replace')
    call write_coord(2, coord, step = 0)

    call init_rng(seed) ! Initialize random number generator with a fixed seed for reproducibility

    tower = tower_gen(n_atoms-3, k_factor) ! Generate the tower for selecting dihedral angles


    !Calculate initial energy and dihedral angles

    call calc_energy(coord, dihedral_lst, E_LJ, E_dih)

    do step = 1, n_steps
        phi_rot = (get_random() - 0.5d0) * 2.0d0 * phi_CC_mod  ! Random rotation angle between phi_CC_mod and -phi_CC_mod
        call MC_step(coord, phi_rot, tower, &
         accepted_moves, rejected_moves, energy, dihedral_lst, &
         E_LJ, E_dih)
        if (mod(step, 100) == 0) then
            call write_coord(2, coord, step = step)
            write(3, *) energy, E_LJ, E_dih
            if (step > n_steps/2) then
                do j = 1, n_atoms-3
                    write(4, *) dihedral_lst(j)
                end do
            end if
        end if
        if(mod(step, n_steps/100) == 0) then
            print *, step/(n_steps/100), '% completed', 'Accepted:', accepted_moves &
            , 'Rejected : ', rejected_moves
        end if
    end do

    close(2)
    close(3)
    close(4)
    call close_rng() ! Close the random number generator
end program main
   