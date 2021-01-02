# Recommendations

Some recommendations on security of the host, general operation,
and key security.

## Operation

**Do not run two validator clients with the same validator keys imported at the same time**<br />
You'd get yourself slashed, and no-one wants that. Protecting you from this
is a work in progress. Choose one client, and one client only, and run that.

**You need an eth1 source**<br />
This project assumes you'll use openethereum or geth. It doesn't have to be that, it can
be a 3rd party. You need some source for eth1, so that your validator can
successfully propose blocks.

## Host Security

The [bare metal installation guide](https://medium.com/@SomerEsat/guide-to-staking-on-ethereum-2-0-ubuntu-medalla-nimbus-5f4b2b0f2d7c)
by /u/SomerEsat has excellent notes on Linux host security. Running `ntpd`
is highly recommended, time matters to validators. Note the ports
you will need to open in `ufw` depend on the client you choose.

## Firewalling

eth1: 30303 tcp/udp, forwarded to your server<br />
lighthouse: 9000 tcp/udp, forwarded to your server<br />
prysm: 13000 tcp and 12000 udp, forwarded to your server<br />
grafana: 3000 tcp, open on ufw but not forwarded to your server.<br />
> The grafana port is insecure http:// and should only be accessed locally.
> For cloud-hosted instances, a reverse proxy such as nginx or
> traefik can be used. An [SSH tunnel](https://www.howtogeek.com/168145/how-to-use-ssh-tunneling/)
> is also a great option.

## Before depositing

You likely want to wait to deposit your eth until you can see in the logs
that the eth1 node (e.g. openethereum) is synchronized and the eth2 beacon node
is fully synchronized, which happens after that. This takes hours on
testnet and could take days on mainnet.

If you deposit before your client stack is fully synchronized and running,
you risk getting penalized for being offline. The offline penalty during
the first 5 months of mainnet will be roughly 0.13% of your deposit per
week.

## Wallet and key security

The security of the wallet mnemonic you create is **critical**. If it is compromised, you will lose
your balance. Please make sure you understand eth2 staking before you use this project.

When you create the deposit and keystore files, write down your wallet mnemonic and
choose a cryptographically strong password for your keystores. Something long
and not used anywhere else, ideally randomized by a generator.

The directory `.eth2/validator_keys` will contain the `deposit_data-TIMESTAMP.json` and `keystore-m_ID.json`
files created by eth2.0-deposit-cli.

Use `deposit_data-TIMESTAMP.json` for your initial deposit. After that, it can be disposed of.

Use `keystore-m_ID.json` files to import your validator secret keys into the validator client
instance of the client you are running. These files need to be secured when you are done
with the initial import.

### Validator Key Security

The `keystore-m_ID.json` files have to be stored securely outside of this server. Offline
is best, on media that cannot be remotely compromised. Keep the password(s) for
these files secure as well, for example in a local (not cloud-connected) password vault
on a PC that is not on the network, or at the very least not used for online access.

Once you have the keystore files secure and they've been imported to the validator client container
on your server, you should delete them from the `.eth2` directory.

These files will be needed in case you need to restore your validator(s).

**Caution**<br />
An attacker with access to these files could slash your validator(s) or threaten
to slash your validator(s).

For more on validator key security, read this article: https://www.attestant.io/posts/protecting-validator-keys/

### Withdrawal Key Security

**Critical**<br />
When you ran eth2.0-deposit-cli, a 24-word mnemonic was created. This mnemonic
will be used for eth2 withdrawals in the future. It must be securely kept offline.
Without this mnemonic, there is **no** way to withdraw your funds.

Precise methods are beyond this README, but consider something as simple as
a sheet of paper kept in a fireproof envelope in a safe, or one of the [steel
mnemonic safeguards](https://jlopp.github.io/metal-bitcoin-storage-reviews/) that are available.

Test your mnemonic **before** you deposit, so you know that you will be able
to withdraw funds in future.

An attacker with access to your mnemonic can drain your funds.

For more on withdrawal key security, read this article: https://www.attestant.io/posts/protecting-withdrawal-keys/

> Testing your mnemonic can be as simple as typing it into deposit-cli
> with `existing-mnemonic`, then comparing the public key(s) of the resulting
> keystore-m signing key files to the public keys you know your validator(s)
> to have. The safest way to do this is offline, on a machine that will
> never be connected to Internet and will be wiped after use.

## Resources, hardware

See the client team recommendations. Generally, however, 8 GiB of RAM is a tight
fit, and 16 GiB is recommended. Some clients such as Teku may need more RAM out
of the box. 2 or 4 CPU cores, and an SSD for storage because the node databases
are so IOPS-heavy. The Geth eth1 node would require around 350GiB of storage by
itself initially, which can grow to 500 GiB over 1 year. Offline pruning is available.
Other clients grow at different rates, see [resource use](RESOURCE-USE.md).
The beacon node database is small, around 11 GiB, but we don't know what growth will
look like once the merge with Eth1 is done.
If you are running a slasher, that might be another 100 to 300 GiB by itself.

Two home server builds that I like and am happy to recommend are below. Both support
IPMI, which means they can be managed and power-cycled remotely and need neither
a GPU nor monitor. Both support ECC RAM, though the AMD option as of Sept 2020
was unable to report ECC errors via IPMI, only OS-level reporting worked.

**Intel**

* mITX: 
  * SuperMicro X11SCL-IF(-O) (1 NVMe)
* uATX:
  * SuperMicro X11SCL-F(-O) (1 NVMe) or X11SCH-F(-O) (2 NVMe)
* Common components:
  * Intel i3-9100F or Intel Xeon E-2xxx (i5/7 do not support ECC)
  * 16 GiB of Micron or Samsung DDR4 UDIMM ECC RAM (unbuffered, **not** registered)
  * 1TB M.2 NVMe SSD or SATA SSD, e.g. Samsung 970 EVO or Samsung 860 EVO

**AMD**

* mITX:
  * AsRock Rack X570D4I-2T (1 NVMe)
* uATX:
  * AsRock Rack X470D4U or X570D4U (2 NVMe both)
* Common components:
  * AMD Ryzen CPU, but not APU (APUs do not support ECC)
  * 16 GiB of Micron or Samsung DDR4 UDIMM ECC RAM (unbuffered, **not** registered)
  * 1TB M.2 NVMe SSD or SATA SSD, e.g. Samsung 970 EVO or Samsung 860 EVO

Plus, obviously, a case, PSU, case fans. Pick your own. Well-liked
options are Node 304 (mITX) and Node 804 (uATX) with Seasonic PSUs,
but really any quality case that won't cook your components will do.

On SSD size, 1TB is very, very conservative and assumes you are running
an eth1 node as well, which currently takes about 330 GiB and keeps
growing. The eth2 db is expected to be far smaller, though exact figures
won't be seen until the merge with eth1 is complete.

You'll want decent write endurance. The two models mentioned here have 600TB
write endurance each.<br />
Intel SSDs are also well-liked, their data center SSDs are quite reliable, if a bit pricey.

You may also consider getting two SSDs and running them in a software mirror
(RAID-1) setup, in the OS. That way, data loss becomes less likely for the
chain databases, reducing potential down time because of hardware issues.

Why ECC? This is a personal preference. The cost difference is minimal,
and the potential time savings huge. An eth2 client does not require
ECC RAM; I maintain it is very nice to have regardless.

With non-ECC RAM, if your RAM goes bad, you will be troubleshooting server
crashes, and potentially spending days with RAM testing tools.

With ECC RAM, if your RAM goes bad, your OS and, if Intel, IPMI, will alert
you to corrected (or uncorrected) RAM errors. You'll want to have set up
email alerts for this. You then buy replacement RAM and schedule downtime.
No RAM troubleshooting required, you will know whether your RAM is functional or has issues
because it will report this to you, and correct single-bit errors.

I am so protective of my time these days that I build even my
home PCs with ECC RAM. You know your own tolerance for troubleshooting
RAM best.
