# CodeMySpecWeb.ServerLive.Show

One server's page: what is running on it, and what setup put there. Two halves with different truth sources, and the page says which is which — containers are read live from the box every time it loads, while the resources setup created are our own records. The live read happens off the mount so a box that hangs cannot hold up the records beside it, and gives up after a stated wait rather than spinning. A step that never ran reads differently from one that ran and failed, because "no backups" and "backups broke" are different problems.

## Type

liveview

## Dependencies

- CodeMySpec.Servers
- CodeMySpec.Provisioning
