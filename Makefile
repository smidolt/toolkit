# make build #-> Just compile contracts
# make static_analyze #-> Only run static analyzers (Slither/Aderyn/Forge coverage)
# make formal_verification #-> Only run symbolic execution tools (Manticore/Mythril)
# make fuzz #-> Only run fuzzer (Echidna)
# make clean #-> Clean build artifacts and reports
# make format #-> Format code 
#----##----##----##----##----##----##----##----##----##----##----##----##----##----##----##----##----##----##----#
.PHONY: all build static_analyze formal_verification fuzz clean format
SOLC_VERSION := 0.7.6
REPORT_DIR := reports
CONTRACT := src/BBot.sol  # for formal verification

all: build static_analyze formal_verification

build:
	@forge build

static_analyze:
	@mkdir -p ${REPORT_DIR}
	@echo "Running static analysis..."
	@slither . --checklist > ${REPORT_DIR}/slither.md || true
	@aderyn . || true
	@mv report.md ${REPORT_DIR}/aderyn.md || true
	@forge coverage > ${REPORT_DIR}/coverage.md || true
	@echo "Static analysis reports saved to ${REPORT_DIR}/"

formal_verification:
	@mkdir -p ${REPORT_DIR}
	@echo "Running symbolic execution..."
##	manticore
#	@docker run --rm --platform linux/amd64 \
		-v ${PWD}:/workdir \
		-e SOLC_VERSION=${SOLC_VERSION} \
		trailofbits/manticore:0.3.7 \
		sh -c "solc-select install ${SOLC_VERSION} && \
			solc-select use ${SOLC_VERSION} && \
			manticore /workdir/src/BBot.sol --contract ${CONTRACT} \
			--workspace /workdir/${REPORT_DIR}/mcore_out \
			--core.procs=1 --core.timeout=300" \
		2>&1 | tee ${REPORT_DIR}/manticore.log || true
	@myth analyze ${CONTRACT} > ${REPORT_DIR}/mythril.md || true
#	@manticore src/*.sol --contract ${CONTRACT} 2>&1 | tee ${REPORT_DIR}/manticore.log || true
	@echo "Symbolic execution results saved to ${REPORT_DIR}/"

fuzz:
	@mkdir -p ${REPORT_DIR}
	@echo "Running fuzzer..."
	@echidna-test . --contract ${CONTRACT} --config echidna.yml > ${REPORT_DIR}/echidna.md || true
	@echo "Fuzzing report saved to ${REPORT_DIR}/echidna.md"

clean:
	@forge clean
	@rm -rf ${REPORT_DIR} .fmtcache mcore_* 

format:
	@forge fmt

init:
	@forge init --force
	@rm -rf src test script
	@mkdir -p src test script
	@echo "[profile.default]\nsolc = '${SOLC_VERSION}'" > foundry.toml
	@forge install foundry-rs/forge-std --no-commit


