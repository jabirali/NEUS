
      program test_materials
        use module_assert
        use module_conductor
        use module_superconductor
        use module_ferromagnet
        integer              :: n
        real(dp)             :: erg(600)=[ ((n*1.5_dp/500),n=1,500),(1.51_dp+n*((cosh(5.0_dp)-1.5_dp)/100.0_dp),n=1,100) ]
        type(conductor)      :: m
        type(superconductor) :: s
        type(ferromagnet)    :: f

        f = ferromagnet(erg, [3.0_dp, 0.1_dp, 0.1_dp])
        m = conductor(erg)
        s = superconductor(erg)
        call connect(s, f, 0.3_dp, 0.3_dp)
        !call connect(m, f, 0.3_dp, 0.3_dp)

        forall (n=1:size(f%location))
          f%exchange(1,n) = 0.5_dp*sin(1.57*f%location(n))
          f%exchange(2,n) = 0.5_dp*cos(1.57*f%location(n))
          f%exchange(3,n) = 0.0_dp
        end forall

        ! Scalar and array exchange

        open(unit=1, file='test_materials.dat')
        call m%write_dos(1, 0.0_dp, 1.0_dp)
        call s%write_dos(1, 1.0_dp, 2.0_dp)
        close(unit=1)

        !call s%internals_update
        do n=1,128
          print *,s%get_gap(s%location(n))
        end do

        !do n=1,3
          call f%update
          !call m%update
          call s%update
          !call m%update
          call f%update
          !call m%update
          call s%update
        !end do

        do n=1,128
          print *,s%get_gap(s%location(n))
        end do

        open(unit=1, file='test_materials.dat')
        call f%write_dos(1, 0.0_dp, 1.0_dp)
        call m%write_dos(1, 1.0_dp, 2.0_dp)
        call s%write_dos(1, 2.0_dp, 3.0_dp)
        close(unit=1)


        !call b%update
        !print *,b%state(50,64)%get_dos()
        !call c%update
        !print *,c%state(50,64)%get_dos()
        !call b%update
        !print *,b%state(50,64)%get_dos()
        !call a%update
        !print *,a%state(50,64)%get_dos()
        !call b%update
        !print *,b%state(50,64)%get_dos()

        !print *, metal%state(50,64)%get_dos()

        !system = [ metal, metal, metal ]

        !subroutine write_test(fd)
        !end subroutine
      end program
