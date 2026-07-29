## settings
SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -euo pipefail -c

## Package information
package_name     := $(shell grep "^Package:" DESCRIPTION | sed "s/Package: //")
package_version  := $(shell grep "^Version:" DESCRIPTION | sed "s/Version: //")
tarball_location := $(package_name)_$(package_version).tar.gz

## default target
.PHONY: help
help:
	@grep -h -E '^[[:space:]]*[A-Za-z0-9_.-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sed -E 's/^[[:space:]]*//' \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[1;34m%-15s\033[m \xE2\x80\x94 %s\n", $$1, $$2}'

## This target are mainly included to
## ease the the development process of {talib}
## 	- The configure will always prefer system-level
##    TA-Lib, which means that downstream installs/checks
##    will be faster if pre-installed.
## 
## NOTE: It currently only works UNIX.
.PHONY: TA-Lib
TA-Lib: ## Install TA-Lib on system (Requires sudo)
	@if ! pkg-config --exists ta-lib; then 	\
		cd src/ta-lib;						\
		sudo chmod +x ./autogen.sh;			\
		./autogen.sh && ./configure;		\
		make;								\
		sudo make install;					\
		sudo ldconfig;						\
	fi

## This target is a precursor to all
## targets either directly or recursively
## and its a good idea to run to prevent shenanigans
## when creating new S3 functions or similar.
document: fmt ## Document R package using {devtools}
	@Rscript --verbose -e "devtools::document()"

## pkgdown
## 	Build the online documentation
##  and preview the built site
pkgdown: ## Build {pkgdown} documentation
	@$(MAKE) document
	@Rscript -e "pkgdown::clean_site()"
	@Rscript -e "pkgdown::init_site()"
	@Rscript -e "pkgdown::build_site()"
	@Rscript -e "pkgdown::preview_site()"

build: document
	@R CMD build . --no-build-vignettes --no-manual

install: build ## Install the R package
	@R CMD INSTALL $(tarball_location) --no-multiarch

## benchmarking
## 	This target runs the full benchmark suite
##  against {TTR} - if there is a need for modifying
##  plots and such do it in the folder
bench: ## Run benchmark(s) against {TTR}
	@echo -e "Running full benchmark suite (overhead + TTR comparison)..."
	@echo -e ""
	@Rscript ./benchmark/run-all.R
	@echo -e ""
	@echo -e "Rendering benchmark/README.Rmd..."
	@cd benchmark && Rscript -e "rmarkdown::render('README.Rmd', output_format = rmarkdown::github_document(html_preview = FALSE), clean = TRUE)"

## Checks
## 	check:
##  	This target is for R CMD checks during
##      local development
##  check-cran:
##  	This target is for full R CMD checks
##      that uses the vendored TA-Lib primarily
##      meant to be run before CRAN submissions
##      or pushes to Github 
##
## NOTE: There is no need to install the package
##       before checks.
check: build ## Check R package
	@R CMD check --no-multiarch --ignore-vignettes --no-manual $(tarball_location)
	@$(MAKE) README

check-cran: document ## Check R package (CRAN)
	@R CMD build .
	@R CMD check --install-args=--configure-args="--force-vendor" --as-cran --use-valgrind $(tarball_location)
	@$(MAKE) README

## Test
## 	This target runs the unit-tests including 
##  the parity tests without conducting the full check suite
test: install parity-prepare ## Run unit-tests
	@TALIB_PARITY_SNAPSHOT_DIR=$$(pwd)/tests/parity/snapshot \
	 Rscript --verbose -e "library(talib); testthat::test_dir('tests/testthat', stop_on_failure = TRUE)"
	@rm -f codegen/parity/parity_gen
	@rm -f tests/testthat/test-parity.R
	@rm -rf tests/parity/snapshot

## Janitor
## 	clean:
##  	Deletes simple build artifacts
##	purge:
##		Uninstalls TA-Lib and restores the 
##      vendored folder to its original state
##
## NOTE:
## 	If the system library is installed, and the
##  unistall fails, its no longer possible to uninstall
##  but it can be fixed by reinstalling TA-Lib and then
##  running purge again!
clean: ## Remove artifacts
	@rm -rf src/*.o
	@rm -rf src/*.so
	@rm -rf $(tarball_location)
	@rm -rf src/Makevars
	@rm -rf $(package_name).Rcheck
	@rm -rf docs

purge: clean ## Remove TA-Lib arifacts and system libraries
	@if pkg-config --exists ta-lib; then		   \
		(cd src/ta-lib && sudo $(MAKE) uninstall); \
	fi
	@git -C src/ta-lib restore --staged --worktree .
	@git -C src/ta-lib clean -fdx
	@Rscript -e "try(remove.packages('$(package_name)'))"
	@rm -rf tests/parity/snapshot
	@rm -f codegen/parity/parity_gen

fmt: ## Format code
	@clang-format \
	-style='{
		BasedOnStyle: LLVM,
		BinPackArguments: false,
		BinPackParameters: false,
		AlignAfterOpenBracket: AlwaysBreak,
		AllowAllArgumentsOnNextLine: false,
		ContinuationIndentWidth: 2
		}' \
	-i src/*.c src/*.h
	@air format R
	@air format tests/testthat
	@rm -rf ./.clang-format
	@cargo fmt --manifest-path codegen/Cargo.toml

.PHONY: codegen
codegen: ## Generate R wrappers and unit-tests
	@cargo run --manifest-path codegen/Cargo.toml
	$(MAKE) fmt

## Make helpers
##
## 	These helpers are not really meant to be run
##  directly but are used internally to support the
##  development in one form or the other

## Parity against upstream
## 	This target is an internal helper
##  used for the test target which compares
##  the output against upstream
parity-prepare:
	@CC=$${CC:-gcc}; 						\
	if pkg-config --exists ta-lib; then 	\
		$$CC -O2 -Wall -Wextra 				\
		  $$(pkg-config --cflags ta-lib) 	\
		  codegen/parity/parity_gen.c 		\
		  $$(pkg-config --libs ta-lib) -lm 	\
		  -o codegen/parity/parity_gen; 	\
	else 									\
		$$CC -O2 -Wall -Wextra 											\
		  -Isrc/ta-lib/local/include -Isrc/ta-lib/local/include/ta-lib 	\
		  codegen/parity/parity_gen.c 									\
		  src/ta-lib/local/lib/libta-lib.a -lm 							\
		  -o codegen/parity/parity_gen; 								\
	fi
	@TMPDIR=$$(mktemp -d); 												\
	trap 'rm -rf "$$TMPDIR"' EXIT; 										\
	mkdir -p "$$TMPDIR/csv" tests/parity/snapshot; 						\
	Rscript codegen/parity/btc_to_csv.R "$$TMPDIR/btc.csv"; 			\
	./codegen/parity/parity_gen "$$TMPDIR/btc.csv" "$$TMPDIR/csv"; 		\
	Rscript codegen/parity/csv_to_rds.R "$$TMPDIR/csv" tests/parity/snapshot
	@cp codegen/parity/test_parity_template.R tests/testthat/test-parity.R

## README
## 	Rebuild README
.PHONY: README
README:
	@rm -rf README.md
	@Rscript -e "rmarkdown::render('dev/README.Rmd', output_dir = '.', output_format = rmarkdown::github_document(html_preview = FALSE), clean = TRUE)"