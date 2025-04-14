.PHONY: all build static_analyze symbolic_exec fuzz clean format init

SOLC_VERSION := 0.7.6
REPORT_DIR := reports
CONTRACT := src/BBot.sol

# Master Target
all: build static_analyze symbolic_exec fuzz

# Compile contracts using Foundry
build:
	@forge build

# Run static analyzers
static_analyze:
	@mkdir -p ${REPORT_DIR}
	@echo "Running static analysis..."
	@slither . --checklist > ${REPORT_DIR}/slither.md || true
	@slither . --print function-summary &> ${REPORT_DIR}/function-summary.md || true
	@aderyn . || true
	@mv report.md ${REPORT_DIR}/aderyn.md || true
	@forge coverage > ${REPORT_DIR}/coverage.md || true
	@echo "Static analysis reports saved to ${REPORT_DIR}/"

# Symbolic execution (Mythril + Manticore)
symbolic_exec:
	@mkdir -p ${REPORT_DIR}
	@echo "Running symbolic execution..."
	@myth analyze ${CONTRACT} > ${REPORT_DIR}/mythril.md || true
## Uncomment Manticore if needed
#	@docker run --rm --platform linux/amd64 \
#		-v ${PWD}:/workdir \
#		-e SOLC_VERSION=${SOLC_VERSION} \
#		trailofbits/manticore:0.3.7 \
#		sh -c "solc-select install ${SOLC_VERSION} && \
#			solc-select use ${SOLC_VERSION} && \
#			manticore /workdir/${CONTRACT} --contract ${CONTRACT} \
#			--workspace /workdir/${REPORT_DIR}/mcore_out \
#			--core.procs=1 --core.timeout=300" \
#		2>&1 | tee ${REPORT_DIR}/manticore.log || true
	@echo "Symbolic execution reports saved to ${REPORT_DIR}/"

# Run fuzzing with Echidna
fuzz:
	@mkdir -p ${REPORT_DIR}
	@echo "Running fuzzer..."
	@echidna-test . --contract ${CONTRACT} --config echidna.yml > ${REPORT_DIR}/echidna.md || true
	@echo "Fuzzing report saved to ${REPORT_DIR}/echidna.md"

# Clean artifacts and reports
clean:
	@forge clean
	@rm -rf ${REPORT_DIR} .fmtcache mcore_*

# Format contracts
format:
	@forge fmt

# Initialize new Foundry project
init:
	@forge init --force
	@rm -rf src test script
	@mkdir -p src test script
	@echo "[profile.default]\nsolc = '${SOLC_VERSION}'" > foundry.toml
#	libs	
	@forge install foundry-rs/forge-std --no-commit
#	@forge install OpenZeppelin/openzeppelin-contracts-upgradeable --no-commit
	@forge install OpenZeppelin/openzeppelin-contracts --no-commit
