# ETH1 Resource Needs

For reference, here are disk, RAM and CPU requirements, as well as mainnet initial
synchronization times, for different Ethereum 1 clients.

PRs to add to this information welcome.

## Disk, RAM, CPU requirements

SSD, RAM and CPU use is after initial sync, when keeping up with head. 100% CPU is one core.

| Client | Version | DB Size  | DB Growth | RAM | CPU | Notes |
|--------|---------|----------|-----------|-----|-----|-------|
| OpenEthereum | 3.1.0rc1 | ~380 GiB | ~ 3.2 GiB / week | 1 GiB | 100-300% | DB grows with chain, prunes itself |
| Geth   | 1.9.24  | ~350 GiB | ~ 10 GiB / week | 9 GiB | 200-400% | DB size can be reduced by [using removedb](https://blog.ethereum.org/2019/07/10/geth-v1-9-0/) |
| Nethermind | 1.10.7-beta | ~130 GiB | TBD | 7 - 11.5 GiB | 100-300% | memory use w/ pruning; initial size lower bcs of ancient barrier |
| Besu | v20.10.2 | ~350 GiB | unknown | 5.5 GiB | | |

## Test Systems

IOPS is random read-write IOPS [measured by fio with "typical" DB parameters](https://arstech.net/how-to-measure-disk-performance-iops-with-fio-in-linux/).

A note on Contabo: Stability of their service [is questionable](https://www.reddit.com/r/ethstaker/comments/l5d69l/if_youre_struggling_with_contabo/).

| Name                 | RAM    | SSD Size | CPU        | IOPS | Notes |
|----------------------|--------|----------|------------|------|-------|
| Homebrew Xeon        | 32 GiB | 700 GiB  | Intel Quad | 18.3k read / 6.1k write | Xeon E3-2225v6 |
| Dell R420            | 32 GiB | 1 TB     | Dual Intel Octo | 28.9k read / 9.6k write | Xeon E5-2450 |
| Contabo M VPS        | 16 GiB | 400 GiB  | Intel Hexa   | 3k read / 1k write | Xeon E5-2630 v4 - some Contabo VPS are AMD |
| Contabo L VPS        | 30 GiB | 800 GiB  | Intel Octo   | 3k read / 1k write | Xeon E5-2630 v4 - some Contabo VPS are AMD |
| [Netcup](https://netcup.eu) VPS 2000 G9   | 16 GiB | 320 GiB  | AMD Quad | 46.4k read / 15.5k write | |

## Initial sync times

NB: All eth1 clients need to [download state](https://github.com/ethereum/go-ethereum/issues/20938#issuecomment-616402016)
after getting blocks. If state isn't "in" yet, your sync is not done. This is a heavily disk IOPS dependent
operation, which is why HDD cannot be used for a node. For Nethermind, seeing "branches" percentage reset to "0.00%"
after state root changes with "Setting sync state root to" is normal and expected. With sufficient IOPS, the
node will "catch up" and get in sync.

| Client | Version | Test System | Time Taken | Cache Size | Notes |
|--------|---------|-------------|------------|------------|-------|
| Geth   | 1.9.24  | Dell R420   | ~ 24 hours | default    | |
| Geth   | 1.9.24  | Homebrew Xeon | ~ 48 hours | default  | |
| Geth   | 1.9.25  | Contabo L VPS | ~ 24 hours | default  | |
| Nethermind | 1.10.7-beta | Contabo L VPS | Never | default | VPS IOPS too low to finish Nethermind sync |
| Nethermind | 1.10.7-beta | Homebrew Xeon | ~ 27 hours | default | |
| Nethermind | 1.10.9 | Netcup VPS 2000 G9 | ~ 20 hours | default | |
