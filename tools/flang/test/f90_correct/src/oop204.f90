! Copyright (c) 2010, NVIDIA CORPORATION.  All rights reserved.
!
! Licensed under the Apache License, Version 2.0 (the "License");
! you may not use this file except in compliance with the License.
! You may obtain a copy of the License at
!
!     http://www.apache.org/licenses/LICENSE-2.0
!
! Unless required by applicable law or agreed to in writing, software
! distributed under the License is distributed on an "AS IS" BASIS,
! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
! See the License for the specific language governing permissions and
! limitations under the License.
!       

program unlimited_poly
USE CHECK_MOD

  type my_type
  class(*),allocatable :: a
  class(*),pointer :: p
  end type

  integer z 
  logical,target :: l 
  logical results(6)
  logical expect(6)
  type(my_type) :: obj
  type(my_type),allocatable :: obj2

  class(*),allocatable :: a
  class(*),pointer :: p
  logical, pointer :: lp
  class(*), allocatable :: u(:)
  integer*8 ia(20)
  real*8 ra(20)

  do i=1,size(ia)
  ia(i) = i
  enddo

  do i=1,size(ra)
  ra(i) = i
  enddo

  results = .false.
  expect = .true.
  

  l = .false.

  allocate(integer*8::a)

  p => l

  select type(p)
  type is (logical)
  results(1) = .true.
  p = .true.
  end select 

  select type(a)
  type is (integer*8)
  results(2) = .true.
  type is (integer)
  results(2) = .false.
  end select

  results(3) = l

  allocate(u(size(ia)),source=ia)

  select type(x=>u)
  type is (integer*8)
  i = x(10)
  print *, i
  end select

  results(5) = size(u) .eq. size(ia)
  select type(zz=>u)
  type is(integer)
  results(4) = .true.
  results(6) = size(zz) .eq. size(ia)
  !!write(*,'(20(i3,",")/)') zz
  print *, zz
  type is(integer*8)
  results(4) = .true.
  results(6) = size(zz) .eq. size(ia)
  !write(*,'(20(i3,",")/)') zz
  print *, zz
  end select

 deallocate(u)

 allocate(u(20),source=ra)
 print *, size(u),size(ra)

 select type(zz=>u)
 type is (real)
 print *, zz
 type is (real*8)
 write(*,'(4f8.1)') zz
 end select

  deallocate(u)

  call check(results,expect,6)
  
end program unlimited_poly


