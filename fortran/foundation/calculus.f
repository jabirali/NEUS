!> Author:   Jabir Ali Ouassou
!> Date:     2015-04-26
!> Category: Foundation
!>
!> This file defines functions that perform some common calculus operations.

module calculus_m
  use :: math_m
  private

  ! Declare which routines to export
  public :: differentiate, integrate, interpolate, linspace

  interface differentiate
    !! Public interface for various differentiation routines.
    module procedure differentiate_linear, differentiate_linear_cx
  end interface

  ! Declare public interfaces
  interface integrate
    !! Public interface for various integration routines.
    module procedure integrate_linear, integrate_linear_cx, &
                     integrate_pchip,  integrate_pchip_cx
  end interface

  interface interpolate
    !! Public interface for various interpolation routines.
    module procedure interpolate_pchip, interpolate_pchip_cx
  end interface
contains
  pure subroutine linspace(array, first, last)
    !! Populates an array with elements from `first` to `last`, inclusive.
    real(wp), intent(out) :: array(:)   !! Output array to populate
    real(wp), intent(in)  :: first      !! Value of first element
    real(wp), intent(in)  :: last       !! Value of last  element
    integer               :: n

    do n=1,size(array)
      array(n) = first + ((last-first)*(n-1))/(size(array)-1)
    end do
  end subroutine

  pure function differentiate_linear(x, y) result(r)
    !! This function calculates the numerical derivative of an array y with respect to x, using a central difference approximation
    !! at the interior points and forward/backward difference approximations at the exterior points. Note that since all the three
    !! approaches yield two-point approximations of the derivative, the mesh spacing of x does not necessarily have to be uniform.
    real(wp), intent(in)  :: x(:)         !! Variable x
    real(wp), intent(in)  :: y(size(x))   !! Function y(x)
    real(wp)              :: r(size(x))   !! Derivative dy/dx

    ! Differentiate using finite differences
    associate(n => size(x))
      r(   1   ) = (y( 1+1 ) - y(  1  ))/(x( 1+1 ) - x(  1  ))
      r(1+1:n-1) = (y(1+2:n) - y(1:n-2))/(x(1+2:n) - x(1:n-2))
      r(   n   ) = (y(  n  ) - y( n-1 ))/(x(  n  ) - x( n-1 ))
    end associate
  end function

  pure function differentiate_linear_cx(x, y) result(r)
    !! Complex version of differentiate_linear.
    real(wp),    intent(in)  :: x(:)         !! Variable x
    complex(wp), intent(in)  :: y(size(x))   !! Function y(x)
    complex(wp)              :: r(size(x))   !! Derivative dy/dx

    ! Differentiate using finite differences
    associate(n => size(x))
      r(   1   ) = (y( 1+1 ) - y(  1  ))/(x( 1+1 ) - x(  1  ))
      r(1+1:n-1) = (y(1+2:n) - y(1:n-2))/(x(1+2:n) - x(1:n-2))
      r(   n   ) = (y(  n  ) - y( n-1 ))/(x(  n  ) - x( n-1 ))
    end associate
  end function

  pure function integrate_linear(x, y) result(r)
    !! This function calculates the integral of an array y with respect to x using a trapezoid
    !! approximation. Note that the mesh spacing of x does not necessarily have to be uniform.
    real(wp), intent(in)  :: x(:)         !! Variable x
    real(wp), intent(in)  :: y(size(x))   !! Function y(x)
    real(wp)              :: r            !! Integral ∫y(x)·dx

    ! Integrate using the trapezoidal rule
    associate(n => size(x))
      r = sum((y(1+1:n-0) + y(1+0:n-1))*(x(1+1:n-0) - x(1+0:n-1)))/2
    end associate
  end function

  pure function integrate_linear_cx(x, y) result(r)
    !! Complex version of integrate_linear.
    real(wp),    intent(in) :: x(:)         !! Variable x
    complex(wp), intent(in) :: y(size(x))   !! Function y(x)
    complex(wp)             :: r            !! Integral ∫y(x)·dx

    ! Integrate using the trapezoidal rule
    associate(n => size(x))
      r = sum((y(1+1:n-0) + y(1+0:n-1))*(x(1+1:n-0) - x(1+0:n-1)))/2
    end associate
  end function

  function integrate_pchip(x, y, a, b) result(r)
    !! This function constructs a piecewise hermitian cubic interpolation of an array y(x) based on
    !! discrete numerical data, and subsequently evaluates the integral of the interpolation in the
    !! range (a,b). Note that the mesh spacing of x does not necessarily have to be uniform.
    real(wp), intent(in)  :: x(:)        !! Variable x
    real(wp), intent(in)  :: y(size(x))  !! Function y(x)
    real(wp), intent(in)  :: a           !! Left endpoint
    real(wp), intent(in)  :: b           !! Right endpoint
    real(wp)              :: r           !! Integral ∫y(x)·dx

    real(wp), external    :: dpchqa
    real(wp)              :: d(size(x))
    integer               :: err

    ! Create a PCHIP interpolation of the input data
    call dpchez(size(x), x, y, d, .false., 0, 0, err)

    ! Integrate the interpolation in the provided range
    r = dpchqa(size(x), x, y, d, a, b, err)
  end function

  function integrate_pchip_cx(x, y, a, b) result(r)
    !! Wrapper for integrate_pchip that accepts complex arguments.
    real(wp),    intent(in)  :: x(:)         !! Variable x
    complex(wp), intent(in)  :: y(size(x))   !! Function y(x)
    real(wp),    intent(in)  :: a            !! Left endpoint
    real(wp),    intent(in)  :: b            !! Right endpoint
    complex(wp)              :: r            !! Integral ∫y(x)·dx

    ! Integrate the real and imaginary parts separately
    r = cx( integrate_pchip(x, re(y), a, b),&
            integrate_pchip(x, im(y), a, b) )
  end function

  function interpolate_pchip(x, y, p) result(r)
    !! This function constructs a piecewise hermitian cubic interpolation of an array y(x) based on discrete numerical data,
    !! and evaluates the interpolation at points p. Note that the mesh spacing of x does not necessarily have to be uniform.
    real(wp), intent(in)  :: x(:)         !! Variable x
    real(wp), intent(in)  :: y(size(x))   !! Function y(x)
    real(wp), intent(in)  :: p(:)         !! Interpolation domain p
    real(wp)              :: r(size(p))   !! Interpolation result y(p)

    real(wp)              :: d(size(x))
    integer               :: err

    ! Create a PCHIP interpolation of the input data
    call dpchez(size(x), x, y, d, .false., 0, 0, err)

    ! Extract the interpolated data at provided points
    call dpchfe(size(x), x, y, d, 1, .false., size(p), p, r, err)
  end function

  function interpolate_pchip_cx(x, y, p) result(r)
    !! Wrapper for interpolate_pchip that accepts complex arguments.
    real(wp),    intent(in)  :: x(:)         !! Variable x
    complex(wp), intent(in)  :: y(size(x))   !! Function y(x)
    real(wp),    intent(in)  :: p(:)         !! Interpolation domain p
    complex(wp)              :: r(size(p))   !! Interpolation result y(p)

    ! Interpolate the real and imaginary parts separately
    r = cx( interpolate_pchip(x, re(y), p),&
            interpolate_pchip(x, im(y), p) )
  end function
end module