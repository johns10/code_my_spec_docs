# CodeMySpec.Resources.Acknowledgement

A record that a resource is there on purpose.

Keyed on provider and identifier at the account grain, not on a resource row — the resources it describes are frequently ones we have no row for. A DNS record added by hand for another tool appears in no step's resource list, so there is nothing to put a flag on, and it is precisely the case that needs marking.

Outlives the inventory being rebuilt, which happens on every page load. Marking something and having to mark it again on the next read would make the feature worse than useless.

What it buys is that deleting becomes safe to offer. Without it the page keeps reporting deliberate leftovers as broken, and a red mark that is wrong often enough stops being read at all — which costs more than the resource does. Reversible: unmarking puts the resource back among the dangling.

Distinct from `Provisioning.Resource.origin`, which says who created a resource we know about. This says who wants it kept.

## Type

schema
