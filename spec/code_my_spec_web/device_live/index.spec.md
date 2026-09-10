# CodeMySpecWeb.DeviceLive.Index

Every machine on the account, and what it is: local or cloud, present or not, and which working copies sit on it.

The surface for story 958. One level above `CodeMySpecWeb.WorkingCopyLive.Index`, which lists checkouts — this lists the machines those checkouts are on, so a 105-row list of copies becomes a handful of machines you can actually read.

Three liveness questions live in a chain and only the middle one exists today: a **device** is present when its harness holds a connection, a **working copy** is present when its path still exists on that device, and an **agent** is present when its lane is joined and working. This surface owns the first, and must not present it as either of the other two — a machine being on is not the same as something happening on it.

Reading and naming only. No stop, no destroy: a device is somebody's machine, and the server observes it rather than reaching across to end anything on it. Same decision `WorkingCopyLive` makes about agents, for the same reason.

## Type

liveview
