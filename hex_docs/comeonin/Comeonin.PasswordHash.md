# Comeonin.PasswordHash

Defines a behaviour for password hashing functions.

## hash_pwd_salt/2

Generates a random salt and then hashes the password.

## verify_pass/2

Checks the password by comparing it with a stored hash.

Please note that the first argument to `verify_pass` should be the
password, and the second argument should be the password hash.