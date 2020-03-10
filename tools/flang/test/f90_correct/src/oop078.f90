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

module shape_mod

  type shape
     integer :: color
     logical :: filled
     integer :: x
     integer :: y
   contains
     procedure,pass(this) :: write => write_shape
     procedure :: draw => draw_shape
  end type shape
  
  type, EXTENDS ( shape ) :: rectangle
  integer :: the_length
  integer :: the_width
contains
  procedure,pass(this) :: write => write_rec
  procedure :: draw => draw_rectangle
  procedure,pass(this) :: write_rec2
end type rectangle

interface
     subroutine draw_rectangle(this,results,i)
       import rectangle
       class (rectangle) :: this
       integer results(:)
       integer i
     end subroutine draw_rectangle
  end interface


type, extends (rectangle) :: square
contains
  !procedure :: draw => draw_sq
  !procedure,pass(this) :: write => write_sq
  procedure,pass(this) :: write_sq2
  
end type square
  interface
     subroutine write_rec2(results,i,this)
       import rectangle 
       class (rectangle) :: this
       integer i
       integer results(:)
     end subroutine write_rec2
  end interface
  interface
     subroutine write_sq(this,results,i)
       import square
       class (square) :: this
       integer results(:)
       integer i
     end subroutine write_sq
  end interface
  interface
     subroutine draw_sq(this,results,i)
       import square 
       class (square) :: this
       integer results(:)
       integer i
     end subroutine draw_sq
  end interface
  interface
     subroutine write_sq2(results,i,this)
       import square,rectangle
       class (square) :: this
       integer i
       integer results(:)
     end subroutine write_sq2
  end interface
  interface
     subroutine write_shape(this,results,i)
       import shape 
       class (shape) :: this
       integer results(:)
       integer i
     end subroutine write_shape
  end interface
  interface
     subroutine draw_shape(this,results,i)
       import  shape
       class (shape) :: this
       integer results(:)
       integer i
     end subroutine draw_shape
  end interface
  interface
     subroutine write_rec(this,results,i)
       import rectangle 
       class (rectangle) :: this
       integer results(:)
       integer i
     end subroutine write_rec
  end interface


end module shape_mod


subroutine write_shape(this,results,i)
  use shape_mod
  class (shape) :: this
  integer results(:)
  integer i
  type(shape) :: sh
  results(i) = same_type_as(sh,this)
end subroutine write_shape

subroutine write_rec(this,results,i)
  use shape_mod
  class (rectangle) :: this
  integer results(:)
  integer i
  type(rectangle) :: rec
  results(i) = same_type_as(rec,this)
end subroutine write_rec

subroutine draw_shape(this,results,i)
  use shape_mod
  class (rectangle) :: this
  integer results(:)
  integer i
end subroutine draw_shape

subroutine draw_rectangle(this,results,i)
  use shape_mod
  class (rectangle) :: this
  integer results(:)
  integer i
  type(rectangle) :: rec
  results(i) = same_type_as(this,rec)
end subroutine draw_rectangle

subroutine write_sq(this,results,i)
  use shape_mod
  class (square) :: this
  integer results(:)
  integer i
  type(rectangle) :: rec
  results(i) = extends_type_of(this,rec)
end subroutine write_sq

subroutine draw_sq(this,results,i)
  use shape_mod
  class (square) :: this
  integer results(:)
  integer i
  type(rectangle) :: rec
  results(i) = extends_type_of(this,rec)
end subroutine draw_sq

subroutine write_sq2(results,i,this)
  use shape_mod
  class (rectangle) :: this
  integer i
  integer results(:)
  type(rectangle) :: rec
  type(square) :: sq
  results(i) = extends_type_of(this,rec)
end subroutine write_sq2

subroutine write_rec2(results,i,this)
  use shape_mod
  class (rectangle) :: this
  integer i
  integer results(:)
  type(rectangle) :: rec
  results(i) = same_type_as(this,rec)
end subroutine write_rec2




program p
USE CHECK_MOD
  use shape_mod
  
  logical l 
  integer results(6)
  integer expect(6)
  data expect /.true.,.false.,.false.,.true.,.true.,.true./
  data results /.false.,.true.,.true.,.false.,.false.,.false./
  class(square),allocatable :: s
  class(shape),allocatable :: sh
  type(rectangle) :: r
  
  allocate(s)
  s%the_length = 1000
  s%color = 1
  call s%write_sq2(results,1)
  call s%write(results,2)
  call s%draw(results,3)
  
  call s%rectangle%write(results,4);
  call draw_rectangle(s%rectangle,results,5)
  
  allocate(sh)
  call sh%write(results,6)
  
  call check(results,expect,6)
  
end program p


