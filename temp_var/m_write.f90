module m_write
    use m_constants, only: n_atoms
    implicit none
 contains
 
     subroutine write_coord(unit, coord, step)
         integer, intent(in) :: unit
         real(8), intent(in) :: coord(3, n_atoms)
         integer, intent(in) :: step
         integer :: i
         write(unit,*) n_atoms
         write(unit,*) '#step ', step
         do i = 1, n_atoms
             write(unit, '(A1,3F12.6)') 'C', coord(1, i), coord(2, i), coord(3, i)
         end do
     end subroutine write_coord
 
end module m_write