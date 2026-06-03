module m_tower
    use m_constants
    use m_ran_gen
    implicit none
    contains

    !It generates a tower of cumulative probabilities for selecting an atom
    !The probability of selecting an atom is proportional to its index raised to the power of k
    function tower_gen(n, k ) result(tower)
        integer, intent(in) :: n, k
        real(8) :: tower(n), tot_weight, weight(n)
        integer :: i, index_real

        do i = 1, n
            index_real = i + 3 ! We start from 4th atom, so we add 3 to the index
            weight(i) = real(index_real , 8) ** k
        end do

        tot_weight = sum(weight)

        do i = 1, n
            tower(i) =sum(weight(1:i)) / tot_weight
        end do

    end function tower_gen

    !It samples an atom index from the tower of cumulative probabilities
    function tower_sample(tower) result(sample)
        real(8), intent(in) :: tower(:)
        integer :: sample, inf, sup, center
        real(8) :: rand_val

        rand_val = get_random()
        inf = 1
        sup = size(tower)

        if (rand_val < tower(1)) then
            sample = 1
            return
        end if

        do while (inf <= sup)
            center = (inf + sup) / 2
            if (rand_val > tower(center)) then
                inf = center + 1
            else
                sup = center - 1
                sample = center
            end if
        end do
    end function tower_sample


    end module m_tower