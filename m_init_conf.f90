module m_init_conf
    use m_constants
    implicit none
contains



    subroutine init_conf(coord, filename)

        real(8), intent(out) :: coord(3, n_atoms)
        character(len=*), intent(in) :: filename
        integer :: i, rot_factor

        real(8) :: sa, ca
        real(8) :: angle_rad

        real(8) :: ux, uy, ux_rot, uy_rot


        !Convert angles to radians 
        angle_rad = angle_CC * 3.141592653589793d0 / 180.0d0
        
        sa = sin(angle_rad)
        ca = cos(angle_rad)

        open(1, file=filename)
        
        write(1, *) n_atoms
        write(1, *) '#Initial configuration'
        
        !Atom 1
        coord(:, 1) = l_box / 2.0d0
        write(1, *) 'C', coord(1, 1), coord(2, 1),  coord(3, 1)

        !Atom 2
        coord(1,2) = coord(1,1) + dist_CC
        coord(2,2) = coord(2,1)
        coord(3,2) = coord(3,1)
        write(1, *) 'C', coord(1, 2), coord(2, 2), coord(3, 2)


        !Atom 3 to n_atoms
        do i = 3, n_atoms
            if (mod(i, 2) == 0) then
                rot_factor = -1.0d0
            else
                rot_factor = 1.0d0
            end if
            
            !Calculate vector conecting two last atoms from new to oldest
            ux = coord(1, i-2) - coord(1, i-1)
            uy = coord(2, i-2) - coord(2, i-1)

            !Rotating vector 
            ux_rot = ux * ca + uy * sa * rot_factor
            uy_rot = -ux * sa * rot_factor + uy * ca

            !Adding vector to last atom to calculate new position
            coord(1, i) = coord(1, i-1) + ux_rot
            coord(2, i) = coord(2, i-1) + uy_rot
            coord(3, i) = coord(3, i-1)
            write(1, *) 'C', coord(1, i), coord(2, i), coord(3, i)

        end do
        close(1)
    end subroutine init_conf


    
    
end module m_init_conf