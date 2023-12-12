# GetToLater

### Current Limitations

The *ResearchKit framework* feature list will continue to grow as useful modules are contributed by
the community.  Keep in mind that the *ResearchKit framework* currently doesn’t include:

* Background sensor data collection. APIs like *HealthKit* and *CoreMotion* on *iOS* already support
    this.
* Secure communication mechanisms between your app and your server; you will need to provide this.
* The ability to schedule surveys and active tasks for your participants.
* A defined data format for how the *ResearchKit framework* structured data is serialized. All the
    *ResearchKit framework* objects conform to the `NSSecureCoding` protocol, and sample code exists
  protocol, and sample code exists outside the framework for
  serializing objects to JSON.

You are responsible for complying with applicable law for each
territory in which the app is made available.

### Logging Errors and Warnings

The *ResearchKit framework* supports four log levels, controlled by four preprocessor macros and their corresponding *`NSLog()`-like* logging macros:
* `ORK_LOG_LEVEL_NONE`
* `ORK_LOG_LEVEL_DEBUG`, `ORK_Log_Debug()`
* `ORK_LOG_LEVEL_WARNING`, `ORK_Log_Warning()`
* `ORK_LOG_LEVEL_ERROR`, `ORK_Log_Error()`

Setting the *ResearchKit framework* `ORK_LOG_LEVEL_NONE` macro to `1` completely silences all ResearchKit logs, overriding any other specified log level. Setting `ORK_LOG_LEVEL_DEBUG`, `ORK_LOG_LEVEL_WARNING`, or `ORK_LOG_LEVEL_ERROR` to `1` enables logging at that level and at those of higher seriousness.

If you do not explicitly set a log level, `ORK_LOG_LEVEL_WARNING=1` is used by default.

You have to set any of these preprocessor macros in your ResearchKit subproject, not in your main project. Within *Xcode*, you can do so by setting any of them in the `Preprocessor Macros` list on the `Build Settings` of your `ResearchKit` framework target.

See these resources if you are using ResearchKit through CocoaPods and need to change the log level: [[1]](http://stackoverflow.com/a/30038120/269753) [[2]](http://www.mokacoding.com/blog/cocoapods-and-custom-build-configurations/).

### Digital Object Identifier for ResearchKit
The ResearchKit repository has an assigned digital object identifier (DOI), which is a persistent identifier that can be used to reference ResearchKit in academic papers. The DOI is registered on zenodo.org.  See  https://doi.org/10.5281/zenodo.826964 .
