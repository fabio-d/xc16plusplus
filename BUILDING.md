# Building XC16++ from source

XC16++ can be built with the `build_xc16plusplus.sh` script, present in the
[xc16plusplus-source](https://github.com/fabio-d/xc16plusplus-source/branches/all)
repository.

It has only been tested on Linux, and it takes the target operating system as
the only argument. Possible values are:

 * `linux32`: Linux, 32-bit executable.
 * `linux64`: Linux, 64-bit executable.
 * `windows32`: Windows, 32-bit executable.
 * `windows64`: Windows, 64-bit executable.
 * `osx32`: OS X, 32-bit executable (no longer supported by OS X since 10.15).
 * `osx64`: OS X, 64-bit executable.

All build prerequisites must be preinstalled. If Windows or OS X is chosen, the
proper cross-compiler must be available in the `PATH` environment variable. In
order, to make the build environment easily reproducible, support for Dockerized
build environment has been developed. In particular, the following Dockerfiles
describe the three build environments (each image contains cross-compilers for
both the 32-bit and 64-bit variants of the target operating system):

 * `build-scripts/containers/linux-build.Dockerfile`
 * `build-scripts/containers/windows-build.Dockerfile`
 * `build-scripts/containers/osx-build.Dockerfile`

Refer to the three files above for the updated list of build prerequisites. The
released binary packages are built in the above Dockerized environments by
GitHub's continuous integration workflow (see below for details).

## Running the tests

In order to automatically assess if a set of compiler executables work or not,
a minimal suite of tests has been developed. Source code for the test framework,
and the tests themselves, is in the `autotest` subdirectory.

Each test is executed in two distinct phases:
 * the *compilation* step, which runs on the target operating system, is the one
   that invokes the XC16++ compiler under test (and possibly some XC16
   executables as well), usually to compile a firmware that stresses a certain
   feature and produces a known output on the UART.
 * the *validation* step, which can be run on any operating system supported by
   the MPLAB X IDE (i.e. Linux, Windows, or OS X). For most tests, this phase
   consists in executing the previously compiled firmware in MPLAB X's `mdb`
   PIC24/dsPIC simulator, whose UART output is recorded and then checked against
   a known "good output" reference.

Between the two phases, which can potentially be executed on different machines
and/or operating systems, intermediate test data is serialized as a ZIP file
called **test bundle**.

Aftewrwards, given an existing XC16++ installation (e.g. XC16 v1.00 with XC16++
executables, installed in `/opt/microchip/xc16/v1.00`) the *compilation* step
can be executed with:
```
cd autotests
python3 -um testrun compile /opt/microchip/xc16/v1.00 -o test_bundle.zip
```

Specific tests can be executed by appending their names to the previous
command-line. If no specific names are given, all tests will be executed.

Given an existing MPLAB X IDE installation and a test bundle, the *validation*
step can be executed as follows:
```
cd autotests
python3 -um testrun validate /opt/microchip/mplabx/v5.30 test-bundle.zip -o test-report.zip
```

A **test report**, containing the final outcome of all tests, will be generated.

**Note**: The `validate` command optionally accepts more than one input test
bundle. In such a case, it behaves as if it was invoked independently for each
input test bundle, but a single, cumulative, test report will be generated.

## The Continuous Integration workflow

Thanks to GitHub's free-of-charge "Actions" feature, XC16++ can be compiled and
tested by its servers in a fully automated and reproducible way. This is how
binary releases are made.

As mentioned above, the build environments are defined in the three
`build-scripts/containers/<TARGET_OS>-build.Dockerfile` files. Similarly, test
environments are defined in the following Dockerfiles:

 * `build-scripts/containers/linux-test-compile.Dockerfile`
 * `build-scripts/containers/windows-test-compile.Dockerfile`
 * `build-scripts/containers/osx-test-compile.Dockerfile`
 * `build-scripts/containers/all-test-validate.Dockerfile`

The first three images define the environment for the tests' *compilation* step.
Non-Linux platforms are actually tested in Linux using an emulator of the target
operating system: WINE for Windows and maloader for OS X.

The fourth image contains a Linux installation of MPLAB X IDE. It is used for
the *validation* step of all tests, regardless of the actual target operating
system.

Dockerized compilation and testing scripts are called by the GitHub-specific
workflow definition file (`.github/workflows/continuous-integration.yaml`). An
equivalent Bash script, which can be run offline without GitHub's Actions
infrastructure, is implemented in `build-scripts/continuous-integration.sh`.

Please note that running `continuous-integration.sh` on a local machine will
take several hours. If you only need to build/test a single XC16++ variant, it
is very straightforward to inspect the script and, then, manually run only some
of its subcommands in an interactive shell.
