# Phoenix.Endpoint.SyncCodeReloadPlug

Wraps an Endpoint, attempting to sync with Phoenix's code reloader if 
an exception is raised which indicates that we may be in the middle of a reload.

We detect this by looking at the raised exception and seeing if it indicates
that the endpoint is not defined. This indicates that the code reloader may be 
midway through a compile, and that we should attempt to retry the request
after the compile has completed. This is also why this must be implemented in
a separate module (one that is not recompiled in a typical code reload cycle),
since otherwise it may be the case that the endpoint itself is not defined.