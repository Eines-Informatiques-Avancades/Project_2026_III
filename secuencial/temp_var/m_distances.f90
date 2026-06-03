module m_distances
    use m_constants, only: n_atoms
    implicit none
    contains

    !It calculates the squared distance between the first and last atom of the chain
    function end_end_dist(coord) result(dist)
        real(8), intent(in) :: coord(3, n_atoms)
        real(8) :: dist
        real(8) :: dx, dy, dz

        dx = coord(1, n_atoms) - coord(1, 1)
        dy = coord(2, n_atoms) - coord(2, 1)
        dz = coord(3, n_atoms) - coord(3, 1)

        dist = dx*dx + dy*dy + dz*dz

    end function end_end_dist


    !It calculates the square radius of gyration of the chain
    function rad_gyr(coord) result(rg)
        real(8), intent(in) :: coord(3, n_atoms)
        real(8) :: rg
        real(8) :: x_cm, y_cm, z_cm
        real(8) :: dx, dy, dz
        integer :: i

        x_cm = sum(coord(1, :)) / n_atoms
        y_cm = sum(coord(2, :)) / n_atoms
        z_cm = sum(coord(3, :)) / n_atoms

        rg = 0.0d0
        do i = 1, n_atoms
            dx = coord(1, i) - x_cm
            dy = coord(2, i) - y_cm
            dz = coord(3, i) - z_cm
            rg = rg + dx*dx + dy*dy + dz*dz
        end do

        rg = rg / n_atoms

    end function rad_gyr

end module m_distances
