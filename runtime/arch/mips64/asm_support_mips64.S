/*
 * Copyright (C) 2014 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef ART_RUNTIME_ARCH_MIPS64_ASM_SUPPORT_MIPS64_S_
#define ART_RUNTIME_ARCH_MIPS64_ASM_SUPPORT_MIPS64_S_

#include "asm_support_mips64.h"

// Define special registers.

// Register holding suspend check count down.
#define rSUSPEND $s0
// Register holding Thread::Current().
#define rSELF $s1


    // Declare a function called name, sets up $gp.
    // This macro modifies t8.
.macro ENTRY name
    .type \name, %function
    .global \name
    // Cache alignment for function entry.
    .balign 16
\name:
    .cfi_startproc
    // Set up $gp and store the previous $gp value to $t8. It will be pushed to the
    // stack after the frame has been constructed.
    .cpsetup $t9, $t8, \name
    // Ensure we get a sane starting CFA.
    .cfi_def_cfa $sp,0
    // Declare a local convenience label to be branched to when $gp is already set up.
.L\name\()_gp_set:
.endm

     // Declare a function called name, doesn't set up $gp.
.macro ENTRY_NO_GP name
    .type \name, %function
    .global \name
    // Cache alignment for function entry.
    .balign 16
\name:
    .cfi_startproc
     // Ensure we get a sane starting CFA.
    .cfi_def_cfa $sp,0
.endm

.macro END name
    .cfi_endproc
    .size \name, .-\name
.endm

.macro UNIMPLEMENTED name
    ENTRY \name
    break
    break
    END \name
.endm

// Macros to poison (negate) the reference for heap poisoning.
.macro POISON_HEAP_REF rRef
#ifdef USE_HEAP_POISONING
    subu \rRef, $zero, \rRef
#endif  // USE_HEAP_POISONING
.endm

// Macros to unpoison (negate) the reference for heap poisoning.
.macro UNPOISON_HEAP_REF rRef
#ifdef USE_HEAP_POISONING
    subu \rRef, $zero, \rRef
#endif  // USE_HEAP_POISONING
.endm

// Based on contents of creg select the minimum integer
// At the end of the macro the original value of creg is lost
.macro MINint dreg,rreg,sreg,creg
  .set push
  .set noat
  .ifc \dreg, \rreg
  selnez \dreg, \rreg, \creg
  seleqz \creg, \sreg, \creg
  .else
  seleqz \dreg, \sreg, \creg
  selnez \creg, \rreg, \creg
  .endif
  or     \dreg, \dreg, \creg
  .set pop
.endm

// Find minimum of two signed registers
.macro MINs dreg,rreg,sreg
  .set push
  .set noat
  slt    $at, \rreg, \sreg
  MINint \dreg, \rreg, \sreg, $at
  .set pop
.endm

// Find minimum of two unsigned registers
.macro MINu dreg,rreg,sreg
  .set push
  .set noat
  sltu   $at, \rreg, \sreg
  MINint \dreg, \rreg, \sreg, $at
  .set pop
.endm

#endif  // ART_RUNTIME_ARCH_MIPS64_ASM_SUPPORT_MIPS64_S_
