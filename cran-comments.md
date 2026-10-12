## R CMD check results

0 errors | 0 warnings | 0 note

### Changes

* This version fixes the pointer misalignment error given in M1-SAN. 
  If I have understood the error correctly the unit-tests for the edge cases passes a zero-length
  pointer to the underlying C-code which is considered undefined behaviour.