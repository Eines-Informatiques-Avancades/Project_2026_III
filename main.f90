program main
    use m_MC_step
    use m_init_conf
    use m_constants
    use m_write
    implicit none

    integer :: accepted_moves, rejected_moves, i
    real(8) :: old_coord(3, 500), new_coord(3, 500), phi_rot
    integer(8) :: seed
    seed = 123456789 

    ! Initialize parameters
    accepted_moves = 0
    rejected_moves = 0

    ! Initialize old coordinates (for example, a linear chain)
    call init_conf(old_coord, 'initial_config.xyz')

    open(2, file='trayectory.xyz', status='replace')
    call write_coord(2, old_coord, step = 0)

    call init_rng(seed) ! Initialize random number generator with a fixed seed for reproducibility


    do i = 1, n_steps
        if (mod(i, 2) == 0) then
            phi_rot = phi_CC_mod
        else
            phi_rot = -phi_CC_mod
        end if
        call MC_step(old_coord, n_atoms, phi_rot, new_coord, temp, accepted_moves, rejected_moves)
        if (mod(i, 100) == 0) then
            call write_coord(2, new_coord, step = i)
        end if
        if(mod(i, n_steps/100) == 0) then
            print *, i/(n_steps/100), '% completed', 'Accepted moves: ', accepted_moves, 'Rejected moves: ', rejected_moves
        end if
        old_coord = new_coord
    end do

    close(2)
    call close_rng() ! Close the random number generator
end program main
   