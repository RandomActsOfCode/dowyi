# Architecture

## Modules

| Name      | Type       | Purpose                                        |
|-----------|------------|------------------------------------------------|
| `dowyi`     | Executable | Main entry, glues together all other libraries |
| `Model`     | Library    | Models for Package, Imports, and Configuration |
| `Sanitizer` | Library    | Sanitizers for validating Package manifest     |
| `Utility`   | Library    | Lightweight helpers                            |
| `Live`      | Library    | Heavyweight "live" dependencies                |

### Notes

- `Utility` contains lightweight extensions and types
- `Live` contains heavyweight types that in turn depend on "live" dependencies
  such as `Process`, `FileManager` that need to be abstracted away for testing

## Module Dependencies

```mermaid
---
title: Module Dependencies
---
graph LR;
    dowyi(dowyi)
    Model(Model)
    Sanitizer(Sanitizer)
    Live(Live)
    dowyi-. uses .->Model;
    dowyi-. uses .->Sanitizer;
    dowyi-. uses .->Live;
    Sanitizer-. uses .->Model;
```

### Notes

- All modules are free to depend on `Utility` hence it is omitted above

## Pipeline

```mermaid
---
title: Runtime Pipeline
---
graph TD;
    parseArgs(Parse Arguments)
    loadConfig(Load Configuration)
    createPackage(Create Package Manifest Model)
    createPackageImport(Create Package Import Model)
    sanitize(Run Sanitizers using Package and Package Import Models)
    output(Display Output)
    exit(Exit)
    parseArgs-->loadConfig
    loadConfig-->createPackage
    createPackage-->createPackageImport
    createPackageImport-->sanitize
    sanitize-->output
    output-->exit
```

## Key Implementation Details

- The model of the Swift Package Manifest is derived from the Swift driver's
[dump-package
command](https://github.com/apple/swift-package-manager/blob/main/Sources/PackageModel/Manifest/Manifest.swift#L526)
- this requires that a Swift toolchain is installed
