# ETH1 Resource Needs

For reference, here are disk, RAM and CPU requirements, as well as mainnet initial
synchronization times, for different Ethereum 1 clients.

PRs to add to this information welcome.

## Disk, RAM, CPU requirements

SSD, RAM and CPU use is after initial sync, when keeping up with head. 100% CPU is one core.

| Client | Version | DB Size  | DB Growth | RAM | CPU | Notes |
|--------|---------|----------|-----------|-----|-----|-------|
| OpenEthereum | 3.1.0rc1 | ~100 GiB | unknown | 1 GiB | 100-300% | 200 GiB during initial sync, then prunes |
| Geth   | 1.9.24  | ~330 GiB | ~500 GiB after 1 year | 8.5 GiB | 200-400% | "Freezer Trick" can be used to prune state |
| Nethermind | 1.9.47 | ~100 GiB | ~ 8 GiB/day |  | 100-200% | no pruning, will grow until it fills disk |
| Besu | v20.10.2 | ~330 GiB | unknown | 5.5 GiB | | |

## Test Systems

| Name                 | RAM    | SSD Size | CPU        | Notes |
|----------------------|--------|----------|------------|-------|
| Homebrew Xeon        | 32 GiB | 700 GiB  | Intel Quad | Xeon E3-2225v6 |
| Dell R420            | 32 GiB | 1 TB     | Dual Intel Octo | Xeon E5-2450 |
| Contabo M VPS        | 16 GiB | 400 GiB  | AMD Hexa   |       |

## Initial sync times

| Client | Test System | Time Taken | Cache Size | Notes |
|--------|-------------|------------|------------|-------|
| Geth   | Dell R420   | ~ 24 hours | default    | |
| Geth   | Homebrew Xeon | ~ 48 hours | default  | |
| OpenEthereum | Homebrew Xeon | ~ 29 hours | 8192 | Restart gave it a higher block snapshot |
| OpenEthereum | Homebrew Xeon | | 8192 | Restart did not snapshot again |
| Besu | Contabo M | | default | |
