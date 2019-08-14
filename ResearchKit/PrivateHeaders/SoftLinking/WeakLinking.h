//
//  WeakLinking.h
//  WeakLinking
//
//  Copyright (c) 2018 Apple Inc. All rights reserved.
//

/*
 * When using weak linking (-weak_framework or -weak_library) this is not
 * visible to the compiler which will treat symbols as strong references.  As a
 * result, any checks against NULL will be optimized out.
 *
 * To work around this, you should redeclare any such symbols as weak_import
 * before attempting the check.  This macro encapsulates that pattern.
 *
 * e.g.
 *
 * WEAK_LINK_FORCE_IMPORT(function_from_weak_library);
 * WEAK_LINK_FORCE_IMPORT(global_variable_from_weak_library);
 *
 * then later you can check the availability of the library with:
 *
 * if (function_from_weak_library != NULL) {
 *     function_from_weak_library(...);
 * }
 *
 * if (&global_variable_from_weak_library != NULL) {
 *     // Use the variable
 * }
 *
 */

#define WEAK_LINK_FORCE_IMPORT(sym) \
    extern __attribute__((weak_import)) typeof(sym) sym
