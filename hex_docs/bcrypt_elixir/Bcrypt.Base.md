# Bcrypt.Base

Base module for the Bcrypt password hashing library.

## checkpass_nif(password, stored_hash)

Verify the password by comparing it with the stored hash.

## gen_salt(log_rounds \\ 12, legacy \\ false)

Generate a salt for use with the `hash_password` function.

The `:log_rounds` parameter determines the computational complexity
of the generation of the password hash. Its default is 12, the minimum is 4,
and the maximum is 31.

The `:legacy` option is for generating salts with the old `$2a$` prefix.
Only use this option if you need to generate hashes that are then checked
by older libraries.

## gensalt_nif(random, log_rounds, minor)

Generate a salt for use with Bcrypt.

## hash_nif(password, salt)

Hash the password and salt with the Bcrypt hashing algorithm.

## hash_password(password, salt)

Hash a password using Bcrypt.