//
//  SoftLinking.h
//  SoftLinking
//
//  Copyright (c) 2009-2018 Apple Inc. All rights reserved.
//

#include <dlfcn.h>
#include <libc_private.h>

#if defined(__OBJC__)
#import <objc/runtime.h>
#endif

#define SOFT_LINK_ASSERT_MSG(expr, msg, ...) \
if (!expr) { \
    abort_report_np(msg, ## __VA_ARGS__); \
}

#define SOFT_LINK_FRAMEWORK(directory, framework) \
static void* framework##Library(void) \
{ \
    static void* frameworkLibrary = nil; \
    if (!frameworkLibrary) frameworkLibrary = dlopen("/System/Library/" #directory "/" #framework ".framework/" #framework, RTLD_LAZY); \
    SOFT_LINK_ASSERT_MSG(frameworkLibrary, "%s", dlerror()); \
    return frameworkLibrary; \
}

// Just like SOFT_LINK_FRAMEWORK, but it won't assert if the framework is missing.
#define SOFT_LINK_FRAMEWORK_SAFE(directory, framework) \
static void* framework##LibraryCore(void) \
{ \
    static void* frameworkLibrary = nil; \
    if (!frameworkLibrary) frameworkLibrary = dlopen("/System/Library/" #directory "/" #framework ".framework/" #framework, RTLD_LAZY); \
    return frameworkLibrary; \
} \
static void* framework##Library(void) \
{ \
    void* frameworkLibrary = framework##LibraryCore(); \
    SOFT_LINK_ASSERT_MSG(frameworkLibrary, "%s", dlerror()); \
    return frameworkLibrary; \
} \
static BOOL is##framework##Available(void) \
{ \
    return (framework##LibraryCore() != nil); \
} \

#define SOFT_LINK_DYLIB(framework) \
static void* framework##Library(void) \
{ \
    static void* frameworkLibrary = nil; \
    if (!frameworkLibrary) frameworkLibrary = dlopen("/usr/lib/" #framework ".dylib", RTLD_LAZY); \
    if (!frameworkLibrary) frameworkLibrary = dlopen("/usr/local/lib/" #framework ".dylib", RTLD_LAZY); \
    SOFT_LINK_ASSERT_MSG(frameworkLibrary, "%s", dlerror()); \
    return frameworkLibrary; \
}

#define SOFT_LINK_BUNDLE(directory, framework) \
static void* framework##Library(void) \
{ \
    static void* frameworkLibrary = nil; \
    if (!frameworkLibrary) frameworkLibrary = dlopen("/System/Library/" #directory "/" #framework ".bundle/" #framework, RTLD_LAZY); \
    SOFT_LINK_ASSERT_MSG(frameworkLibrary, "%s", dlerror()); \
    return frameworkLibrary; \
}

#define SOFT_LINK_FUNCTION(framework, functionName, localNameForFunction, resultType, parameterDeclarations, parameterNames) \
static resultType init##functionName parameterDeclarations; \
static resultType (*softLink##functionName) parameterDeclarations = init##functionName; \
\
static resultType init##functionName parameterDeclarations \
{ \
    softLink##functionName = (resultType (*) parameterDeclarations) dlsym(framework##Library(), #functionName); \
    SOFT_LINK_ASSERT_MSG(softLink##functionName, "%s", dlerror()); \
    return softLink##functionName parameterNames; \
} \
\
__attribute__((unused)) static inline resultType localNameForFunction parameterDeclarations \
{ \
    return softLink##functionName parameterNames; \
}

#if defined(__OBJC__)
#define SOFT_LINK_CLASS(framework, className) \
static Class init##className(void); \
static Class (*get##className##Class)(void) = init##className; \
static Class class##className; \
\
static Class className##Function(void) \
{ \
    return class##className; \
} \
\
static Class init##className(void) \
{ \
    framework##Library(); \
    class##className = objc_getClass(#className); \
    SOFT_LINK_ASSERT_MSG(class##className, "Unable to find class %s", #className); \
    get##className##Class = className##Function; \
    return class##className; \
}
#endif

#if defined(__cplusplus)
#define SOFT_LINK_CONVERT(name, type) \
constant##name = *static_cast<type*>(constant);
#elif defined(__OBJC__) && __has_feature(objc_arc)
#define SOFT_LINK_CONVERT(name, type) \
constant##name = (__bridge type)(*(void**)constant);
#else
#define SOFT_LINK_CONVERT(name, type) \
constant##name = (type)(*(void**)constant);
#endif

#define SOFT_LINK_CONSTANT(framework, name, type) \
static type init##name(void); \
static type (*get##name)(void) = init##name; \
static type constant##name; \
\
static type name##Function(void) \
{ \
    return constant##name; \
} \
\
static type init##name(void) \
{ \
    void* constant = dlsym(framework##Library(), #name); \
    SOFT_LINK_ASSERT_MSG(constant, "%s", dlerror()); \
    SOFT_LINK_CONVERT(name, type) \
    get##name = name##Function; \
    return constant##name; \
}

#if defined(__cplusplus)
#define SOFT_LINK_CONVERT_NONOBJECT(name, type) \
constant##name = *static_cast<type*>(constant);
#else
#define SOFT_LINK_CONVERT_NONOBJECT(name, type) \
constant##name = *((type *)constant);
#endif

#define SOFT_LINK_NONOBJECT_CONSTANT(framework, name, type) \
static type init##name(void); \
static type (*get##name)(void) = init##name; \
static type constant##name; \
\
static type name##Function(void) \
{ \
    return constant##name; \
} \
\
static type init##name(void) \
{ \
    void* constant = dlsym(framework##Library(), #name); \
    SOFT_LINK_ASSERT_MSG(constant, "%s", dlerror()); \
    SOFT_LINK_CONVERT_NONOBJECT(name, type) \
    get##name = name##Function; \
    return constant##name; \
}



/* WARNING WARNING WARNING: This macro has a serious problem; the symbol it exports is public, which causes problems when an application links two public frameworks, one of which softlinks a function from the other. The linker may choose the exported symbol from the wrong framework, which makes applications linked on a later version of the OS unable to deploy on earlier versions of the OS. The 'inline' declaration is not sufficient.

    This macro is left here until everyone can get off it.

    You should use the SOFT_LINK_FUNCTION macro above instead.
 */

#define SOFT_LINK(framework, functionName, resultType, parameterDeclarations, parameterNames) \
static resultType init##functionName parameterDeclarations; \
static resultType (*softLink##functionName) parameterDeclarations = init##functionName; \
\
static resultType init##functionName parameterDeclarations \
{ \
    softLink##functionName = (resultType (*) parameterDeclarations) dlsym(framework##Library(), #functionName); \
    SOFT_LINK_ASSERT_MSG(softLink##functionName, "%s", dlerror()); \
    return softLink##functionName parameterNames; \
} \
\
inline resultType functionName parameterDeclarations \
{ \
    return softLink##functionName parameterNames; \
}
