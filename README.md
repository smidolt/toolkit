# Toolkit

Automation for smart contract auditing. 

## Commands

- `make init` — Bootstrap a new Foundry project with structure and config
- `make build` — Compile contracts with Foundry
- `make static_analyze` — Run Slither, Aderyn, and Forge coverage
- `make symbolic_exec` — Run symbolic execution tools (Mythril & optional Manticore)
- `make fuzz` — Run Echidna fuzz tests
- `make clean` — Clean all build artifacts and reports
- `make format` — Format code with Forge

## Notes

- Reports are saved in the `reports/` directory.
- Solidity version is pinned via `SOLC_VERSION`.
- Manticore is disabled by default; enable in `Makefile` if needed.
