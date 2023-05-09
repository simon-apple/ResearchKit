//
//  ORKSoftLinking.h
//  ResearchKit
//
//  Created by Shaishav Siddhpuria on 8/1/19.
//  Copyright © 2019 Apple, Inc. All rights reserved.
//

#include <dlfcn.h>

#if defined(__OBJC__)
#import <objc/runtime.h>
#endif

#define ORK_SOFT_LINK_FRAMEWORK(directory, framework) \
static void* framework##Library(void) \
{ \
static void* frameworkLibrary = nil; \
if (!frameworkLibrary) frameworkLibrary = dlopen("/System/Library/" #directory "/" #framework ".framework/" #framework, RTLD_NOW); \
return frameworkLibrary; \
}

// Just like ORK_SOFT_LINK_FRAMEWORK, but it won't assert if the framework is missing.
#define ORK_SOFT_LINK_FRAMEWORK_SAFE(directory, framework) \
static void* framework##LibraryCore(void) \
{ \
static void* frameworkLibrary = nil; \
if (!frameworkLibrary) frameworkLibrary = dlopen("/System/Library/" #directory "/" #framework ".framework/" #framework, RTLD_NOW); \
return frameworkLibrary; \
} \
static void* framework##Library(void) \
{ \
void* frameworkLibrary = framework##LibraryCore(); \
return frameworkLibrary; \
} \
static BOOL is##framework##Available(void) \
{ \
return (framework##LibraryCore() != nil); \
} \

#define ORK_SOFT_LINK_DYLIB(framework) \
static void* framework##Library(void) \
{ \
static void* frameworkLibrary = nil; \
if (!frameworkLibrary) frameworkLibrary = dlopen("/usr/local/lib/" #framework ".dylib", RTLD_NOW); \
return frameworkLibrary; \
}

// For soft-linking libmobilegestalt
#define ORK_SOFT_LINK_SYS_DYLIB(framework) \
static void* framework##Library(void) \
{ \
static void* frameworkLibrary = nil; \
if (!frameworkLibrary) frameworkLibrary = dlopen("/usr/lib/" #framework ".dylib", RTLD_NOW); \
return frameworkLibrary; \
}

#define ORK_SOFT_LINK_BUNDLE(directory, framework) \
static void* framework##Library(void) \
{ \
static void* frameworkLibrary = nil; \
if (!frameworkLibrary) frameworkLibrary = dlopen("/System/Library/" #directory "/" #framework ".bundle/" #framework, RTLD_NOW); \
return frameworkLibrary; \
}

#define ORK_SOFT_LINK_FUNCTION(framework, functionName, localNameForFunction, resultType, parameterDeclarations, parameterNames) \
static resultType init##functionName parameterDeclarations; \
static resultType (*softLink##functionName) parameterDeclarations = init##functionName; \
\
static resultType init##functionName parameterDeclarations \
{ \
softLink##functionName = (resultType (*) parameterDeclarations) dlsym(framework##Library(), #functionName); \
return softLink##functionName parameterNames; \
} \
\
__attribute__((unused)) static inline resultType localNameForFunction parameterDeclarations \
{ \
return softLink##functionName parameterNames; \
}

#if defined(__OBJC__)
#define ORK_SOFT_LINK_CLASS(framework, className) \
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
get##className##Class = className##Function; \
return class##className; \
}
#endif

#if defined(__cplusplus)
#define ORK_SOFT_LINK_CONVERT(name, type) \
constant##name = *static_cast<type*>(constant);
#elif defined(__OBJC__) && __has_feature(objc_arc)
#define ORK_SOFT_LINK_CONVERT(name, type) \
constant##name = (__bridge type)(*(void**)constant);
#else
#define ORK_SOFT_LINK_CONVERT(name, type) \
constant##name = (type)(*(void**)constant);
#endif

#define ORK_SOFT_LINK_CONSTANT(framework, name, type) \
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
ORK_SOFT_LINK_CONVERT(name, type) \
get##name = name##Function; \
return constant##name; \
}

#if defined(__cplusplus)
#define ORK_SOFT_LINK_CONVERT_NONOBJECT(name, type) \
constant##name = *static_cast<type*>(constant);
#else
#define ORK_SOFT_LINK_CONVERT_NONOBJECT(name, type) \
constant##name = *((type *)constant);
#endif

#define ORK_SOFT_LINK_NONOBJECT_CONSTANT(framework, name, type) \
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
ORK_SOFT_LINK_CONVERT_NONOBJECT(name, type) \
get##name = name##Function; \
return constant##name; \
}
