!module to generate random numbers with fsgl
module m_ran_gen
    use fgsl
    implicit none

    !Private variable for generator
    type(fgsl_rng), save, private :: gen
    
contains

    !Subroutine to initialize the random number generator with a given seed
    subroutine init_rng(seed_value)
        implicit none
        integer(8), intent(in) :: seed_value
        type(fgsl_rng_type) :: type

        ! Initialize the random number generator
        type = fgsl_rng_mt19937
        gen = fgsl_rng_alloc(type)

        call fgsl_rng_set(gen, seed_value)
        print *, "RNG initialized with seed:", seed_value

    end subroutine init_rng


    !function to get a random number between 0 and 1
    real(8) function get_random()
        implicit none
        get_random = fgsl_rng_uniform(gen)
    end function get_random

    !Subroutine to close the random number generator and free memory
    subroutine close_rng()
        implicit none
        call fgsl_rng_free(gen)
        print *, "RNG closed"
    end subroutine close_rng


end module m_ran_gen
