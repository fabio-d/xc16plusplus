TESTS := $(sort $(patsubst %/,%.test,$(wildcard */)))
QUIET=-q

.DEFAULT: test
.PHONY: test

%.test:
	"$(shell pwd)/run_test.sh" $(QUIET) $*

# "make test" runs all tests except those that are known to be broken
test: $(filter-out %.knownbroken.test,$(TESTS))
