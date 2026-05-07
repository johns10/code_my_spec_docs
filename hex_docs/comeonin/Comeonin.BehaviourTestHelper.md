# Comeonin.BehaviourTestHelper

Test helper functions for Comeonin behaviours.

## add_hash_creates_map(module, password)

Checks that the `add_hash/2` function creates a map with the `password_hash` set.

## ascii_passwords()

List of passwords that just contain basic ascii characters.

## check_pass_nil_user(module)

Checks that the `check_pass/3` function returns an error when no user is found.

## check_pass_returns_error(module, password)

Checks that the `check_pass/3` function returns an error for incorrect passwords.

## check_pass_returns_user(module, password)

Checks that the `check_pass/3` function returns the user for correct passwords.

## correct_password_true(module, password)

Checks that the `verify_pass/2` function returns true for correct password.

## non_ascii_passwords()

List of passwords that contain non-ascii characters.

## wrong_password_false(module, password)

Checks that the `verify_pass/2` function returns false for incorrect passwords.