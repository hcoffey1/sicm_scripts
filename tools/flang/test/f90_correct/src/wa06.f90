

!* Copyright (c) 2000, NVIDIA CORPORATION.  All rights reserved.
!*
!* Licensed under the Apache License, Version 2.0 (the "License");
!* you may not use this file except in compliance with the License.
!* You may obtain a copy of the License at
!*
!*     http://www.apache.org/licenses/LICENSE-2.0
!*
!* Unless required by applicable law or agreed to in writing, software
!* distributed under the License is distributed on an "AS IS" BASIS,
!* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
!* See the License for the specific language governing permissions and
!* limitations under the License.
!
!  Test entity oriented variable initializations of character types (more to come)
!

module m
  character, parameter :: c_1x = 'x'
  character, parameter :: c_2y = 'yy'
  character(*), parameter :: c_param_3x = repeat(c_1x, 3)
  character(*), parameter :: c_param_3y = repeat('y', 3)
  character(*), parameter :: c_param_6y = repeat(c_2y, 3)
  character(*), parameter :: c_param_6x = repeat('xx', 3)

end module m

program wa06

 interface
  subroutine test_module( result )
    integer :: result(:)
  end subroutine
 end interface

  parameter(N=36)
  integer :: result(N)
  integer :: expect(N) =  (/         &
   !test 1-3, c_param_3x
     120, 120, 120,                  &
   !test 4-9, c_param_6y
     121,121,121,121,121,121,        &
   !test 10-12, c_param_3y
     121, 121, 121,                  &
   !test 12-18, c_param_6x
     120,120,120,120,120,120,        &

   ! from module_test
   !module test 1-3, c_param_3x
     120, 120, 120,                  &
   !module test 4-9, c_param_6y
     121,121,121,121,121,121,        &
   !module test 10-12, c_param_3y
     121, 121, 121,                  &
   !module test 12-18, c_param_6x
     120,120,120,120,120,120         &
  /)

  character, parameter :: c_1x = 'x'
  character, parameter :: c_2y = 'yy'
  character(*), parameter :: c_param_3x = repeat(c_1x, 3)
  character(*), parameter :: c_param_3y = repeat('y', 3)
  character(*), parameter :: c_param_6y = repeat(c_2y, 3)
  character(*), parameter :: c_param_6x = repeat('xx', 3)

  !test 1-3
  result(1:3) = ichar(c_param_3x)
  !print *,result(1:3)

  !test 4-9
  result(4:9) = ichar(c_param_6y)
  !print *,result(4:9)

  !test 10-12
  result(10:12) = ichar(c_param_3y)
  !print *,result(10:12)

  !test 13-18
  result(13:18) = ichar(c_param_6x)
  !print *,result(13:18)

  call test_module(result(19:N))

  call check(result, expect, N);
end program

subroutine test_module( result )
  use  m
  integer :: result(:)

  !module test 1-3
  result(1:3) = ichar(c_param_3x)
  !print *,result(1:3)

  !module test 4-9
  result(4:9) = ichar(c_param_6y)
  !print *,result(4:9)

  !module test 10-12
  result(10:12) = ichar(c_param_3y)
  !print *,result(10:12)

  !module test 13-18
  result(13:18) = ichar(c_param_6x)
  !print *,result(13:18)
end subroutine
