## R CMD check results

0 errors | 0 warnings | 1 note

* checking CRAN incoming feasibility ... [5s/20s] NOTE
Maintainer: ‘Serkan Korkmaz <serkor1@duck.com>’

Days since last update: 2

### Days since last update: 2

This submission is an immediate response to CRAN build-failures, warnings and Benjamin Altmann comments about
my DESCRIPTION file.

* This update comes with following fixes to build-failures and warnings on CRAN:
    - MacOS: CMake PATH is now properly identified using the recommended approach as per 'Writing R Exentions'
    - Windows: Fixed prototype warning in `lib.c` and `api.h`

* During these fixes a bug in the package have been identified and fixed. This have been
  mentioned in the `NEWS.md`.

* DESCRIPTION: Single quoted names and programming languages.