/*
 * Copyright (c) 2017, NVIDIA CORPORATION.  All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

/* clang-format off */

/*	commitqq3f.c - Implements DFLIB commitqq subroutine.  */

/* must include ent3f.h AFTER io3f.h */
#include "io3f.h"
#include "ent3f.h"

extern FILE *__getfile3f();

int ENT3F(COMMITQQ, commitqq)(lu) int *lu;
{
  FILE *f;
  int i;

  f = __getfile3f(*lu);
  if (f) {
    fflush(f);
    i = -1; /* .true. returned if open unit is passed */
  } else
    i = 0; /* .false.  returned if unopened unit is passed */

  return i;
}
