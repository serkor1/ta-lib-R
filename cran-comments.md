## R CMD check results

0 errors | 0 warnings | 0 note

### Changes

* This version fixes the `-Wlto-type-mismatch` warnings reported in the additional LTO check (init.c: `impl_ta_VOLUME_lookback`, `reset_candle_setting`).
  I reproduced the warnings locally with gcc 15 and `-flto`, and they are goneafter the fix.