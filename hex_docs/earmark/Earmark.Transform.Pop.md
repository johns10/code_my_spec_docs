# Earmark.Transform.Pop

A wrapper struct that wraps a mapping function and is pushed onto the
stack for traversal. This not only allows to pop from the stack onto
the result but to store an older mapper function for usage of a replacement
mapper function for the subtree traversal