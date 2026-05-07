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

document: ## Build R documentation
	@Rscript --verbose -e "devtools::document()"

build: clean fmt ## Build the R package
	@codegen/generate_API.sh src/ src/api.h && codegen/generate_FFI.sh src/api.h src/init.c && $(MAKE) fmt
	@$(MAKE) document
	@R CMD build . --no-build-vignettes && R CMD INSTALL $(tarball_location)
	@rm -rf README.md
	@Rscript -e "rmarkdown::render('dev/README.Rmd', output_dir = '.', output_format = rmarkdown::github_document(html_preview = FALSE), clean = TRUE)"

check: fmt document build parity-prepare ## Check the R package
	@TALIB_PARITY_SNAPSHOT_DIR=$$(pwd)/tests/parity/snapshot \
	 TALIB_STRICT_WARNINGS=1 \
	 R CMD check --as-cran $(tarball_location)

check-full: fmt document build parity-prepare ## Check the R package with valgrind
	@TALIB_PARITY_SNAPSHOT_DIR=$$(pwd)/tests/parity/snapshot \
	 TALIB_STRICT_WARNINGS=1 \
	 R CMD check --as-cran --use-valgrind $(tarball_location)

test: fmt parity-prepare ## Run tests (incl. parity)
	@TALIB_PARITY_SNAPSHOT_DIR=$$(pwd)/tests/parity/snapshot \
	 Rscript --verbose -e "library(talib); testthat::test_dir('tests/testthat', stop_on_failure = TRUE)"

clean: ## Remove artifacts
	@rm -rf src/*.o
	@rm -rf src/*.so
	@rm -rf $(tarball_location)
	@rm -rf src/Makevars
	@rm -rf $(package_name).Rcheck
	@rm -rf docs
	@rm -f tests/testthat/test-parity.R

purge: clean ## Remove TA-Lib arifacts
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

pkgdown-build: ## Build {pkgdown} documentation
	@$(MAKE) document
	@Rscript -e "pkgdown::clean_site()"
	@Rscript -e "pkgdown::init_site()"
	@Rscript -e "pkgdown::build_site()"

pkgdown-preview: ## Preview {pkgdown} documetation
	@Rscript -e "pkgdown::preview_site()"

bench: ## Run benchmark(s)
	@echo -e "Running benchmark..."
	@echo -e ""
	@Rscript ./benchmark/benchmark-overhead.R
	@echo -e ""
	@echo -e "Benchmark information:"
	@echo -e " -baseline: no R overhead"
	@echo -e " -data.frame: data.frame methods"
	@echo -e " -baseline: matrix methods"
	@cd benchmark && Rscript -e "rmarkdown::render('README.Rmd', output_format = rmarkdown::github_document(html_preview = FALSE), clean = TRUE)"
	

n ?= 1e6
bench-data: ## Generate data for benchmark(s) 
	@Rscript ./benchmark/benchmark-data.R $(n)

validate: ## Validate R output against TA-Lib core
	@PKG_CFLAGS="-Isrc/ta-lib/local/include -Isrc/ta-lib/local/include/ta-lib" \
	PKG_LIBS="src/ta-lib/local/lib/libta-lib.a -lm" \
	R CMD SHLIB codegen/validation/validate.c
	@Rscript codegen/validation/validate.R
	@rm -f codegen/validation/validate.o codegen/validation/validate.so

parity-gen: ## Build the standalone parity_gen exe (pure C, no R linkage)
	@CC=$${CC:-gcc}; \
	$$CC -O2 -Wall -Wextra \
	  -Isrc/ta-lib/local/include -Isrc/ta-lib/local/include/ta-lib \
	  codegen/parity/parity_gen.c \
	  src/ta-lib/local/lib/libta-lib.a -lm \
	  -o codegen/parity/parity_gen

## Internal helper: build the C exe, regenerate the upstream snapshot,
## and stage tests/testthat/test-parity.R from the template. Invoked
## by `make parity`, `make test`, `make check`, `make check-full`.
parity-prepare: parity-gen
	@TMPDIR=$$(mktemp -d); \
	trap 'rm -rf "$$TMPDIR"' EXIT; \
	mkdir -p "$$TMPDIR/csv" tests/parity/snapshot; \
	Rscript codegen/parity/btc_to_csv.R "$$TMPDIR/btc.csv"; \
	./codegen/parity/parity_gen "$$TMPDIR/btc.csv" "$$TMPDIR/csv"; \
	Rscript codegen/parity/csv_to_rds.R "$$TMPDIR/csv" tests/parity/snapshot
	@cp codegen/parity/test_parity_template.R tests/testthat/test-parity.R

parity: parity-prepare ## Regenerate the upstream snapshot and run the parity test only
	@TALIB_PARITY_SNAPSHOT_DIR=$$(pwd)/tests/parity/snapshot \
	 Rscript -e "library(talib); testthat::test_file('tests/testthat/test-parity.R', stop_on_failure = TRUE)"

parity-clean: ## Remove parity build artifacts and the generated test file
	@rm -f codegen/parity/parity_gen
	@rm -f tests/testthat/test-parity.R
	@rm -rf tests/parity/snapshot

gen-code: ## Generate R wrappers and unit-tests
	@Rscript --verbose ./codegen/gen_code/generate.R
	$(MAKE) fmt