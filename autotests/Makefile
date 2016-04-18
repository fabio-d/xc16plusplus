TESTS := $(sort $(patsubst %/,%.test,$(wildcard */)))

export XC16DIR=/opt/microchip/xc16/v1.23
#export XC16DIR=/opt/microchip/xc16/v1.24
#export XC16DIR=/opt/microchip/xc16/v1.25

QUIET=-q

.DEFAULT: test
.PHONY: test

%.test:
	./run_test.sh $(QUIET) $*

# "make test" runs all tests except those that are known to be broken
test: $(filter-out %.knownbroken.test,$(TESTS))
	@echo All tests passed
