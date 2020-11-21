# Windows, and its challenges

Windows may seem like an "easy button". For eth2-docker, it is anything but, and even for
other ways of running a client, there are multiple challenges. They can all be overcome,
and, I have yet to see a comprehensive document that addresses all of them.

Things to think about with Windows:

- Time sync is off by (up to) a second out of the box in Windows, and can be so bad in WSL2 you can't attest. 
  Solve w/ 3rd party in Windows. Check via https://time.is
- Time sync in WSL 2 worse, which comes into play when using Docker Desktop. I've heard "I sync it manually" - not sustainable for 2+ years.
- Running as a service. It's 100% doable, and, not terribly well documented for this use case right now. How to differs between Docker Desktop
  and other ways of running. You'd be looking into Windows Task Scheduler.
- Client diversity. Prysm does Windows-native, Lighthouse will soon. The other two would rely on a setup that runs them in Docker Desktop and WSL2,
  thus Linux, afaik.
- eth1 node - Prysm sidesteps this with 3rd-party, and Geth runs natively. For other clients, you're looking at Docker Desktop again.
- Remote administration - SSH? RDP? If RDP, do you need a "proper" cert to encrypt?
- If using Docker Desktop and WSL2, consider that WSL2 runs as a virtual network. Work-around is to run a Powerscript that addresses needed port-forwarding.
- I've had Docker Desktop fail to start, rarely. It appears to be related to when there is an update available, which would typically be the case
  upon restart of the host. This needs to be solved, I am not sure how.
- Let's harp on "running as a service" one more time: By default, Docker Desktop doesn't start until the user logs in. You need to
  be up 24/7 and your node won't start until someone logs in. Which can be solved - the instructions looked involved. You also want security, which
  means auto login of user is not a solution here.

The best bet for Windows is likely to run Prysm or Lighthouse natively, with Geth, some way of starting them as a service without a user needing to be logged
in (Task Scheduler), and 3rd-party software to improve time sync.

That is absolutely doable.