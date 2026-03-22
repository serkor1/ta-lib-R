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
	@tools/generate_API.sh src/ src/api.h && tools/generate_FFI.sh src/api.h src/init.c && $(MAKE) fmt
	@$(MAKE) document
	@R CMD build . --no-build-vignettes && R CMD INSTALL $(tarball_location)
	@rm -rf README.md
	@Rscript -e "rmarkdown::render('README.Rmd', output_format = rmarkdown::github_document(html_preview = FALSE), clean = TRUE)"

check: fmt document ## Check the R package
	@R CMD build . && R CMD check --as-cran $(tarball_location)

check-full: fmt document ## Check the R package with valgrind
	@R CMD build .  && R CMD check --as-cran --use-valgrind $(tarball_location)

test: fmt ## Run tests
	@Rscript --verbose -e "library(talib); testthat::test_dir('tests/testthat')"

clean: ## Remove artifacts
	@rm -rf src/*.o
	@rm -rf src/*.so
	@rm -rf $(tarball_location)
	@rm -rf src/Makevars
	@rm -rf $(package_name).Rcheck
	@rm -rf docs
	@rm -rf tools/table.csv

purge: clean ## Remove TA-Lib arifacts
	@git -C src/ta-lib restore --staged --worktree .
	@git -C src/ta-lib clean -fdx
	@Rscript -e "try(remove.packages('$(package_name)'))"

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

unit-tests: ## Generate, or update, unit-tests
	@Rscript ./tools/generate_table.R
	@GEN=./tools/generate_unit-tests.sh; \
	UNIT_CSV=$${UNIT_CSV:-tools/table.csv}; \
	awk -F, 'NR==1{next} /^[[:space:]]*$$/{next} { \
	  for(i=1;i<=4;i++){ \
	    gsub(/^[ \t]+|[ \t]+$$/,"",$$i); \
	    sub(/^"/,"",$$i); sub(/"$$/,"",$$i); \
	  } \
	  gate=$$4; if(gate=="") gate="FALSE"; \
	  printf "%s\t%s\t%s\t%s\n", $$1,$$2,$$3,gate \
	}' "$$UNIT_CSV" | \
	while IFS=$$'\t' read -r f alias cols gate; do \
	  "$$GEN" "$$f" "$$alias" "$$cols" "$$gate"; \
	done

	$(MAKE) fmt

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
	R CMD SHLIB tools/validation/validate.c
	@Rscript tools/validation/validate.R
	@rm -f tools/validation/validate.o tools/validation/validate.so

gen-code: ## Generate R wrappers and unit-tests
	@Rscript --verbose ./tools/gen_code/generate.R
	$(MAKE) fmt