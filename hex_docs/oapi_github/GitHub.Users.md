# GitHub.Users

Provides API endpoints related to users

## add_email_for_authenticated_user(body, opts \\ [])

Add an email address for the authenticated user

OAuth app tokens and personal access tokens (classic) need the `user` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/users/emails#add-an-email-address-for-the-authenticated-user)

## add_social_account_for_authenticated_user(body, opts \\ [])

Add social accounts for the authenticated user

Add one or more social accounts to the authenticated user's profile.

OAuth app tokens and personal access tokens (classic) need the `user` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/users/social-accounts#add-social-accounts-for-the-authenticated-user)

## block(username, opts \\ [])

Block a user

Blocks the given user and returns a 204. If the authenticated user cannot block the given user a 422 is returned.

## Resources

  * [API method documentation](https://docs.github.com/rest/users/blocking#block-a-user)

## check_blocked(username, opts \\ [])

Check if a user is blocked by the authenticated user

Returns a 204 if the given user is blocked by the authenticated user. Returns a 404 if the given user is not blocked by the authenticated user, or if the given user account has been identified as spam by GitHub.

## Resources

  * [API method documentation](https://docs.github.com/rest/users/blocking#check-if-a-user-is-blocked-by-the-authenticated-user)

## check_following_for_user(username, target_user, opts \\ [])

Check if a user follows another user

## Resources

  * [API method documentation](https://docs.github.com/rest/users/followers#check-if-a-user-follows-another-user)

## check_person_is_followed_by_authenticated(username, opts \\ [])

Check if a person is followed by the authenticated user

## Resources

  * [API method documentation](https://docs.github.com/rest/users/followers#check-if-a-person-is-followed-by-the-authenticated-user)

## create_gpg_key_for_authenticated_user(body, opts \\ [])

Create a GPG key for the authenticated user

Adds a GPG key to the authenticated user's GitHub account.

OAuth app tokens and personal access tokens (classic) need the `write:gpg_key` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/users/gpg-keys#create-a-gpg-key-for-the-authenticated-user)

## create_public_ssh_key_for_authenticated_user(body, opts \\ [])

Create a public SSH key for the authenticated user

Adds a public SSH key to the authenticated user's GitHub account.

OAuth app tokens and personal access tokens (classic) need the `write:gpg_key` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/users/keys#create-a-public-ssh-key-for-the-authenticated-user)

## create_ssh_signing_key_for_authenticated_user(body, opts \\ [])

Create a SSH signing key for the authenticated user

Creates an SSH signing key for the authenticated user's GitHub account.

OAuth app tokens and personal access tokens (classic) need the `write:ssh_signing_key` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/users/ssh-signing-keys#create-a-ssh-signing-key-for-the-authenticated-user)

## delete_email_for_authenticated_user(body, opts \\ [])

Delete an email address for the authenticated user

OAuth app tokens and personal access tokens (classic) need the `user` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/users/emails#delete-an-email-address-for-the-authenticated-user)

## delete_gpg_key_for_authenticated_user(gpg_key_id, opts \\ [])

Delete a GPG key for the authenticated user

Removes a GPG key from the authenticated user's GitHub account.

OAuth app tokens and personal access tokens (classic) need the `admin:gpg_key` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/users/gpg-keys#delete-a-gpg-key-for-the-authenticated-user)

## delete_public_ssh_key_for_authenticated_user(key_id, opts \\ [])

Delete a public SSH key for the authenticated user

Removes a public SSH key from the authenticated user's GitHub account.

OAuth app tokens and personal access tokens (classic) need the `admin:public_key` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/users/keys#delete-a-public-ssh-key-for-the-authenticated-user)

## delete_social_account_for_authenticated_user(body, opts \\ [])

Delete social accounts for the authenticated user

Deletes one or more social accounts from the authenticated user's profile.

OAuth app tokens and personal access tokens (classic) need the `user` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/users/social-accounts#delete-social-accounts-for-the-authenticated-user)

## delete_ssh_signing_key_for_authenticated_user(ssh_signing_key_id, opts \\ [])

Delete an SSH signing key for the authenticated user

Deletes an SSH signing key from the authenticated user's GitHub account.

OAuth app tokens and personal access tokens (classic) need the `admin:ssh_signing_key` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/users/ssh-signing-keys#delete-an-ssh-signing-key-for-the-authenticated-user)

## follow(username, opts \\ [])

Follow a user

Note that you'll need to set `Content-Length` to zero when calling out to this endpoint. For more information, see "[HTTP verbs](https://docs.github.com/rest/guides/getting-started-with-the-rest-api#http-method)."

OAuth app tokens and personal access tokens (classic) need the `user:follow` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/users/followers#follow-a-user)

## get_authenticated(opts \\ [])

Get the authenticated user

OAuth app tokens and personal access tokens (classic) need the `user` scope in order for the response to include private profile information.

## Resources

  * [API method documentation](https://docs.github.com/rest/users/users#get-the-authenticated-user)

## get_by_username(username, opts \\ [])

Get a user

Provides publicly available information about someone with a GitHub account.

The `email` key in the following response is the publicly visible email address from your GitHub [profile page](https://github.com/settings/profile). When setting up your profile, you can select a primary email address to be “public” which provides an email entry for this endpoint. If you do not set a public email address for `email`, then it will have a value of `null`. You only see publicly visible email addresses when authenticated with GitHub. For more information, see [Authentication](https://docs.github.com/rest/guides/getting-started-with-the-rest-api#authentication).

The Emails API enables you to list all of your email addresses, and toggle a primary email to be visible publicly. For more information, see "[Emails API](https://docs.github.com/rest/users/emails)".

## Resources

  * [API method documentation](https://docs.github.com/rest/users/users#get-a-user)

## get_context_for_user(username, opts \\ [])

Get contextual information for a user

Provides hovercard information. You can find out more about someone in relation to their pull requests, issues, repositories, and organizations.

  The `subject_type` and `subject_id` parameters provide context for the person's hovercard, which returns more information than without the parameters. For example, if you wanted to find out more about `octocat` who owns the `Spoon-Knife` repository, you would use a `subject_type` value of `repository` and a `subject_id` value of `1300192` (the ID of the `Spoon-Knife` repository).

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Options

  * `subject_type`: Identifies which additional information you'd like to receive about the person's hovercard. Can be `organization`, `repository`, `issue`, `pull_request`. **Required** when using `subject_id`.
  * `subject_id`: Uses the ID for the `subject_type` you specified. **Required** when using `subject_type`.

## Resources

  * [API method documentation](https://docs.github.com/rest/users/users#get-contextual-information-for-a-user)

## get_gpg_key_for_authenticated_user(gpg_key_id, opts \\ [])

Get a GPG key for the authenticated user

View extended details for a single GPG key.

OAuth app tokens and personal access tokens (classic) need the `read:gpg_key` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/users/gpg-keys#get-a-gpg-key-for-the-authenticated-user)

## get_public_ssh_key_for_authenticated_user(key_id, opts \\ [])

Get a public SSH key for the authenticated user

View extended details for a single public SSH key.

OAuth app tokens and personal access tokens (classic) need the `read:public_key` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/users/keys#get-a-public-ssh-key-for-the-authenticated-user)

## get_ssh_signing_key_for_authenticated_user(ssh_signing_key_id, opts \\ [])

Get an SSH signing key for the authenticated user

Gets extended details for an SSH signing key.

OAuth app tokens and personal access tokens (classic) need the `read:ssh_signing_key` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/users/ssh-signing-keys#get-an-ssh-signing-key-for-the-authenticated-user)

## list(opts \\ [])

List users

Lists all users, in the order that they signed up on GitHub. This list includes personal user accounts and organization accounts.

Note: Pagination is powered exclusively by the `since` parameter. Use the [Link header](https://docs.github.com/rest/guides/using-pagination-in-the-rest-api#using-link-headers) to get the URL for the next page of users.

## Options

  * `since`: A user ID. Only return users with an ID greater than this ID.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/users/users#list-users)

## list_blocked_by_authenticated_user(opts \\ [])

List users blocked by the authenticated user

List the users you've blocked on your personal account.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/users/blocking#list-users-blocked-by-the-authenticated-user)

## list_emails_for_authenticated_user(opts \\ [])

List email addresses for the authenticated user

Lists all of your email addresses, and specifies which one is visible
to the public.

OAuth app tokens and personal access tokens (classic) need the `user:email` scope to use this endpoint.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/users/emails#list-email-addresses-for-the-authenticated-user)

## list_followed_by_authenticated_user(opts \\ [])

List the people the authenticated user follows

Lists the people who the authenticated user follows.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/users/followers#list-the-people-the-authenticated-user-follows)

## list_followers_for_authenticated_user(opts \\ [])

List followers of the authenticated user

Lists the people following the authenticated user.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/users/followers#list-followers-of-the-authenticated-user)

## list_followers_for_user(username, opts \\ [])

List followers of a user

Lists the people following the specified user.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/users/followers#list-followers-of-a-user)

## list_following_for_user(username, opts \\ [])

List the people a user follows

Lists the people who the specified user follows.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/users/followers#list-the-people-a-user-follows)

## list_gpg_keys_for_authenticated_user(opts \\ [])

List GPG keys for the authenticated user

Lists the current user's GPG keys.

OAuth app tokens and personal access tokens (classic) need the `read:gpg_key` scope to use this endpoint.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/users/gpg-keys#list-gpg-keys-for-the-authenticated-user)

## list_gpg_keys_for_user(username, opts \\ [])

List GPG keys for a user

Lists the GPG keys for a user. This information is accessible by anyone.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/users/gpg-keys#list-gpg-keys-for-a-user)

## list_public_emails_for_authenticated_user(opts \\ [])

List public email addresses for the authenticated user

Lists your publicly visible email address, which you can set with the
[Set primary email visibility for the authenticated user](https://docs.github.com/rest/users/emails#set-primary-email-visibility-for-the-authenticated-user)
endpoint.

OAuth app tokens and personal access tokens (classic) need the `user:email` scope to use this endpoint.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/users/emails#list-public-email-addresses-for-the-authenticated-user)

## list_public_keys_for_user(username, opts \\ [])

List public keys for a user

Lists the _verified_ public SSH keys for a user. This is accessible by anyone.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/users/keys#list-public-keys-for-a-user)

## list_public_ssh_keys_for_authenticated_user(opts \\ [])

List public SSH keys for the authenticated user

Lists the public SSH keys for the authenticated user's GitHub account.

OAuth app tokens and personal access tokens (classic) need the `read:public_key` scope to use this endpoint.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/users/keys#list-public-ssh-keys-for-the-authenticated-user)

## list_social_accounts_for_authenticated_user(opts \\ [])

List social accounts for the authenticated user

Lists all of your social accounts.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/users/social-accounts#list-social-accounts-for-the-authenticated-user)

## list_social_accounts_for_user(username, opts \\ [])

List social accounts for a user

Lists social media accounts for a user. This endpoint is accessible by anyone.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/users/social-accounts#list-social-accounts-for-a-user)

## list_ssh_signing_keys_for_authenticated_user(opts \\ [])

List SSH signing keys for the authenticated user

Lists the SSH signing keys for the authenticated user's GitHub account.

OAuth app tokens and personal access tokens (classic) need the `read:ssh_signing_key` scope to use this endpoint.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/users/ssh-signing-keys#list-ssh-signing-keys-for-the-authenticated-user)

## list_ssh_signing_keys_for_user(username, opts \\ [])

List SSH signing keys for a user

Lists the SSH signing keys for a user. This operation is accessible by anyone.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/users/ssh-signing-keys#list-ssh-signing-keys-for-a-user)

## set_primary_email_visibility_for_authenticated_user(body, opts \\ [])

Set primary email visibility for the authenticated user

Sets the visibility for your primary email addresses.

## Resources

  * [API method documentation](https://docs.github.com/rest/users/emails#set-primary-email-visibility-for-the-authenticated-user)

## unblock(username, opts \\ [])

Unblock a user

Unblocks the given user and returns a 204.

## Resources

  * [API method documentation](https://docs.github.com/rest/users/blocking#unblock-a-user)

## unfollow(username, opts \\ [])

Unfollow a user

OAuth app tokens and personal access tokens (classic) need the `user:follow` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/users/followers#unfollow-a-user)

## update_authenticated(body, opts \\ [])

Update the authenticated user

**Note:** If your email is set to private and you send an `email` parameter as part of this request to update your profile, your privacy settings are still enforced: the email address will not be displayed on your public profile or via the API.

## Resources

  * [API method documentation](https://docs.github.com/rest/users/users#update-the-authenticated-user)