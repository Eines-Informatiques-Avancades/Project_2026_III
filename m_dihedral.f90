module dihedral
    use m_constants, only : phi_CC_mod
    implicit none
contains

    function calc_energy(phi) result(E)
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

  end function calc_energy


    function calc_dihedral(coord, i) result(dihedral_angle)
        real(8), intent(in) :: coord(3, n_atoms)
        integer, intent(in) :: i
        real(8) :: dihedral_angle

        real(8) :: b1(3), b2(3), b3(3)
        real(8) :: n1(3), n2(3)
        real(8) :: m1(3)

        ! Calculate bond vectors
        b1 = coord(:, i-1) - coord(:, i-2)
        b2 = coord(:, i) - coord(:, i-1)
        b3 = coord(:, i+1) - coord(:, i)

        ! Calculate normal vectors
        n1 = cross_product(b1, b2)
        n2 = cross_product(b2, b3)

        ! Calculate m1 vector
        m1 = cross_product(n1, normalize(b2))

        ! Calculate dihedral angle
        dihedral_angle = atan2(dot_product(m1, n2), dot_product(n1, n2)) * 180.0d0 / 3.141592653589793d0

    end function calc_dihedral

    function cross_product(a, b) result(c)
        real(8), intent(in) :: a(3), b(3)
        real(8) :: c(3)

        c(1) = a(2)*b(3) - a(3)*b(2)
        c(2) = a(3)*b(1) - a(1)*b(3)
        c(3) = a(1)*b(2) - a(2)*b(1)

    end function cross_product

    function normalize(v) result(v_norm)
        real(8), intent(in) :: v(3)
        real(8) :: v_norm(3)
        real(8) :: norm

        norm = sqrt(dot_product(v, v))
        if (norm > 0.0d0) then
            v_norm = v / norm
        else
            v_norm = v
        end if

    end function normalize

    subroutine rot_dihedral(coord, i, phi_CC_mod)
        real(8), intent(inout) :: coord(3, n_atoms)
        integer, intent(in) :: i
        real(8), intent(in) :: phi_CC_mod

        real(8) :: phi_old, phi_new
        real(8) :: rot_matrix(3, 3)
        integer :: j

        ! Calculate current dihedral angle
        phi_old = calc_dihedral(coord, i)

        ! Calculate new dihedral angle
        phi_new = phi_old + phi_CC_mod

        ! Calculate rotation matrix for the dihedral change
        call calc_rotation_matrix(phi_new - phi_old, rot_matrix)

        ! Rotate the coordinates of the atoms after atom i
        do j = i+1, n_atoms
            coord(:, j) = matmul(rot_matrix, coord(:, j) - coord(:, i)) + coord(:, i)
        end do

    end subroutine rot_dihedral

end module dihedral