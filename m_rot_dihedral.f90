module m_rot_dihedral
    use m_constants, only: phi_CC_mod, n_atoms
    implicit none

    contains

    function calc_dihedral(coord, i) result(phi)
        real(8), intent(in) :: coord(3, n_atoms)
        integer, intent(in) :: i
        real(8) :: phi
        real(8), parameter :: PI = 3.141592653589793d0

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
        phi = atan2(dot_product(m1, n2), dot_product(n1, n2)) * 180.0d0 / PI

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


    !It makes a rotation of one atom perpendiculary arround the direction
    !defined by two reference atoms from a given dihedral angle

    subroutine ang_rot(pref_1, pref_2, prot, phi_CC_mod)
        real(8), intent(in) :: pref_1(3), pref_2(3), phi_CC_mod
        real(8), intent(inout) :: prot(3)
        real(8) :: u(3), v(3), w(3), norm_v(3), norm_w(3), x_vec(3), y_vec(3), proy_uv(3)
        real(8) :: rad, v_mod, w_mod, p_prim(3)

        u = prot - pref_1
        v = pref_2 - pref_1

        !Proyect u onto v direction
        proy_uv = dot_product(u, v) / dot_product(v, v) * v

        !Calculate the perpendicular component of u to v
        w = u - proy_uv
        p_prim = pref_1 + proy_uv

        v_mod = sqrt(dot_product(v, v))
        norm_v = v / v_mod
        w_mod = sqrt(dot_product(w, w))
        norm_w = w / w_mod

        !Reference axis to 2d rotation
        x_vec = norm_w
        y_vec = cross_product(norm_v, norm_w)

        !Rotation in 2D
        rad = w_mod
        if (w_mod < 1.0d-10) return ! No hay nada que rotar, el átomo está en el eje
        prot = p_prim + rad *cos(phi_CC_mod) * x_vec + rad * sin(phi_CC_mod) * y_vec

    end subroutine ang_rot

    subroutine dihedral_rotation(i, coords, phi_CC_mod, n_atoms)
        integer, intent(in) :: i, n_atoms
        real(8), intent(inout) :: coords(3, n_atoms)
        real(8), intent(in) :: phi_CC_mod
        integer :: j

        do j = i + 1, n_atoms

            call ang_rot(coords(:, i-1), coords(:, i), coords(:, j), phi_CC_mod)
        end do

    end subroutine dihedral_rotation

end module m_rot_dihedral





