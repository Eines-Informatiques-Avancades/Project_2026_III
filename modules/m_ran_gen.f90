!module to generate random numbers with MKL Intel

module m_ran_gen
    implicit none
    
    integer, parameter :: BUFFER_SIZE = 100000 ! Bloques de 10^5 números
    real(8), save      :: rand_buffer(BUFFER_SIZE)
    integer, save      :: buffer_index = BUFFER_SIZE + 1 ! Fuerza el llenado inicial

contains

subroutine init_rng(seed)
        integer, intent(in) :: seed
        integer :: i, n
        integer, allocatable :: seed_array(:)

        call random_seed(size = n)
        allocate(seed_array(n))

        do i = 1, n
            seed_array(i) = seed + (i - 1) * 1000
        end do

        call random_seed(put = seed_array)
        deallocate(seed_array)

        buffer_index = BUFFER_SIZE + 1
    end subroutine init_rng


    function get_random() result(rand_val)
        real(8) :: rand_val
        integer :: i

        if (buffer_index > BUFFER_SIZE) then
            call random_number(rand_buffer)
            buffer_index = 1 
        end if

        rand_val = rand_buffer(buffer_index)
        buffer_index = buffer_index + 1
    end function get_random


    subroutine close_rng()
    end subroutine close_rng

end module m_ran_gen
