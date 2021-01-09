# ETH1 Resource Needs

For reference, here are disk, RAM and CPU requirements, as well as mainnet initial
synchronization times, for different Ethereum 1 clients.

PRs to add to this information welcome.

## Disk, RAM, CPU requirements

SSD, RAM and CPU use is after initial sync, when keeping up with head. 100% CPU is one core.

| Client | Version | DB Size  | DB Growth | RAM | CPU | Notes |
|--------|---------|----------|-----------|-----|-----|-------|
| OpenEthereum | 3.1.0rc1 | ~380 GiB | moderate | 1 GiB | 100-300% | DB grows with chain, prunes itself |
| Geth   | 1.9.24  | ~350 GiB | ~1-2 GiB/day | 9 GiB | 200-400% | offline prune available via snapshot |
| Nethermind | 1.10.2-beta | ~100 GiB | TBD | 6.5 GiB | 100-300% | pruning in beta; initial size lower bcs of ancient barrier |
| Besu | v20.10.2 | ~350 GiB | unknown | 5.5 GiB | | |

## Test Systems

| Name                 | RAM    | SSD Size | CPU        | Notes |
|----------------------|--------|----------|------------|-------|
| Homebrew Xeon        | 32 GiB | 700 GiB  | Intel Quad | Xeon E3-2225v6 |
| Dell R420            | 32 GiB | 1 TB     | Dual Intel Octo | Xeon E5-2450 |
| Contabo M VPS        | 16 GiB | 400 GiB  | AMD Hexa   |       |
| Contabo L VPS        | 30 GiB | 800 GiB  | AMD Octo   |       |

## Initial sync times

| Client | Test System | Time Taken | Cache Size | Notes |
|--------|-------------|------------|------------|-------|
| Geth   | Dell R420   | ~ 24 hours | default    | |
| Geth   | Homebrew Xeon | ~ 48 hours | default  | |
| Geth   | Contabo L VPS | ~ 24 hours | default  | |
