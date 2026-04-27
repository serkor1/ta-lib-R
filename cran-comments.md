## R CMD check results

0 errors | 0 warnings | 0 note

### Days since last update: 2

This submission is an immediate response to a macOS build-failure on CRAN
(r-devel, x86_64-apple-darwin20) for v0.9-1, where installation failed at
the `[4s/9s] ERROR` stage. The full install log was not accessible to the
maintainer; the surface output reported only "Installation failed. See
the install log for details." All other check flavors (Linux, Windows,
including r-devel) passed.

* The `configure` script has been hardened along the lines of WRE Section 1.2.6
  ("Using `cmake`") to address the most likely macOS-specific causes of
  early install failure when the vendored TA-Lib is built via CMake:

    - R's compiler configuration (`CC`, `CXX`, `CFLAGS`, `CXXFLAGS`,
      `CPPFLAGS`, `LDFLAGS` from `R CMD config`) is now propagated to the
      CMake invocation. Previously CMake auto-detected its own toolchain,
      which on the CRAN macOS builder picked up `/usr/bin/clang` instead
      of the R toolchain at `/opt/R/<arch>/bin/clang`, producing a static
      `libta-lib.a` whose ABI / SDK did not match the `.so` linked by R.

    - `CMAKE_OSX_DEPLOYMENT_TARGET` is now set from R's
      `-mmacosx-version-min=...` flag, and `CMAKE_OSX_ARCHITECTURES` is
      set from `uname -m`, ensuring the static library targets the same
      macOS version and architecture as the R-built shared object.

    - `nproc --ignore 2` (GNU coreutils, absent on macOS) has been
      replaced by `getconf _NPROCESSORS_ONLN` (POSIX, present on both
      Linux and macOS), with a safe fallback. Previously the failed
      `nproc` substitution silently produced an empty `-j` argument
      tolerated by Make but rejected by Ninja.

  These changes are a no-op on Linux and Windows (the macOS-specific
  CMake args are gated by `uname -s = Darwin`).

* No changes to package functionality, exported API, or test suite.