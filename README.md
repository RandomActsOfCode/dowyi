Depend On What You Import (DOWYI) 0.1.0
===============================

<img
  alt="Project Logo"
  src="https://github.com/RandomActsOfCode/dowyi/blob/main/dowyi.png"
  width="200"
  height="200"
  />

[![Swift 5.9](https://img.shields.io/badge/swift-5.9-red.svg?style=flat)](https://developer.apple.com/swift)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)
[![.github/workflows/build.yml](https://github.com/RandomActsOfCode/dowyi/actions/workflows/build.yml/badge.svg)](https://github.com/RandomActsOfCode/dowyi/actions/workflows/build.yml)

## What

A command line tool for sanitizing a Swift Package Manager manifest to enable
reliable, consistent builds.

## Why

Forgetting to depend on a dependency you are importing _may_ or _may not_ fail
to be build. This is because Apple's build system stores built artifacts in a
common directory which is referenced when building all targets. If another
target that happens to rely on the same dependency was built first (or the
dependency is cached from a previous build), then the missing dependency's built
product will be found and the `import` will succeed.  However, the build system
is highly parallel and is non-deterministic, so while it may succeed locally, it
might not on CI or on an other developer's machine.

## How

The provided package manifest is loaded into memory, sources for each target are
located, and `import` statements extracted. Each `import` statement is then
compared to the target's definition and any provided configuration options. If
any discrepancies are found between the `import` statements and the target's
dependencies, an error is reported.

## Errors

| Error                | Meaning                                                                                                                       |
|----------------------|-------------------------------------------------------------------------------------------------------------------------------|
| Missing Dependency   | An `import` was detected without a corresponding `dependency` for the `target`                                                |
| Unused Dependency    | A `dependency` for a `target` was found without any corresponding `import` statements                                         |
| Redundant Dependency | A `dependency` for a `target` was found but the same dependency is an exported import of another `dependency` of the `target` |
| Redundant Import     | An `import` was detected for a `dependency` which is an exported import of another `dependency` used by the `target`          |

## How to Use

Once built and installed simply invoke the command in a repository containing a
Swift Package manifest. Example:

```sh
> dowyi

Number of errors found: 2

------------------------------------------------------------------------------------
1.    SomeTarget                          Missing Dependency       File:   Foo.swift
                                                                   Line:   2
                                                                   Module: Model
------------------------------------------------------------------------------------
2.    SomeOtherTarget                     Unused Dependency        File:   Bar.swift
                                                                   Line:   1
                                                                   Module: Util
------------------------------------------------------------------------------------
```

In addition to the default behavior of running in the same directory as the
Package manifest, the tool can also be invoked with an explicit path to the
Package manifest analyze:

```sh
> dowyi --package-manifest-dir Packages/Model

No errors found!
```

### Configuration Options

This tool uses a configuration file to help guide the analysis. The
configuration file contains many options that can be customized to meet the
needs of each individual project. To get started, generate a sample config
file:

```sh
# Will create a sample .dowyi.json file in same directory
> dowyi --write-configuration
```

Customization options are:

| Option               | Purpose                                                              |
|----------------------|----------------------------------------------------------------------|
| `swiftExecPath`      | The Swift driver to use for Package inspection                       |
| `ignoredFrameworks`  | Dependencies which should never be considered during validation      |
| `ignoredTargets`     | Package manifest targets to skip during validation                   |
| `systemFrameworks`   | Frameworks provided by the system which are implicitly depended upon |
| `exportedFrameworks` | Frameworks which are implicitly imported by other frameworks         |

The tool will look for a configuration file in the same directory as the Package
manifest, and if one isn't found, it will load one from the current working
directory (i.e. the directory which the tool was invoked from). If a
configuration file is still not found, defaults will be used.

### Output Format

By default, the tool displays human friendly table output as illustrated in the
examples above. Currently, two output formatters exist: `table`, and `json`
which can be provided when invoking the tool. For example:

```sh
> dowyi --output-format json
```

would yield output similar to:

```json
[
  {
    "missingDependency" : {
      "detail" : {
        "sourceImport" : {
          "file" : "file:\/\/\/Users\/SomeUser\/SomeProject\/Sources\/SomeTarget/Foo.swift",
          "lineNumber" : 2,
          "module" : "Model",
          "rawText" : "import Model"
        },
        "targetName" : "SomeTarget"
      }
    }
  }
]
```

### Exit Codes

The exit code can be used to quickly determine if errors occurred which is useful
when invoking from other scripts or tools:

| Exit Code | Meaning               | Details                                |
|-----------|-----------------------|----------------------------------------|
| -1        | Configuration Error   | The Package manifest was not found     |
| -2        | Configuration Error   | The Package manifest could be not read |
| 0         | Successful invocation | The tool ran, no errors were found     |
| `N` (>0)  | Successful invocation | The tool ran, `N` errors were found    |

### Pre-commit Support

To add this tool as a [pre-commit](https://pre-commit.com/) check, simply add the following to your `.pre-commit-config.yaml` configuration file:

```yaml
 -  repo: https://github.com/RandomActsOfCode/dowyi
    rev: 0.1.0
    hooks:
    - id: dowyi
```
