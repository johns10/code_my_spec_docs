# GitHub.Activity

Provides API endpoints related to activity

## check_repo_is_starred_by_authenticated_user(owner, repo, opts \\ [])

Check if a repository is starred by the authenticated user

Whether the authenticated user has starred the repository.

## Resources

  * [API method documentation](https://docs.github.com/rest/activity/starring#check-if-a-repository-is-starred-by-the-authenticated-user)

## delete_repo_subscription(owner, repo, opts \\ [])

Delete a repository subscription

This endpoint should only be used to stop watching a repository. To control whether or not you wish to receive notifications from a repository, [set the repository's subscription manually](https://docs.github.com/rest/activity/watching#set-a-repository-subscription).

## Resources

  * [API method documentation](https://docs.github.com/rest/activity/watching#delete-a-repository-subscription)

## delete_thread_subscription(thread_id, opts \\ [])

Delete a thread subscription

Mutes all future notifications for a conversation until you comment on the thread or get an **@mention**. If you are watching the repository of the thread, you will still receive notifications. To ignore future notifications for a repository you are watching, use the [Set a thread subscription](https://docs.github.com/rest/activity/notifications#set-a-thread-subscription) endpoint and set `ignore` to `true`.

## Resources

  * [API method documentation](https://docs.github.com/rest/activity/notifications#delete-a-thread-subscription)

## get_feeds(opts \\ [])

Get feeds

Lists the feeds available to the authenticated user. The response provides a URL for each feed. You can then get a specific feed by sending a request to one of the feed URLs.

*   **Timeline**: The GitHub global public timeline
*   **User**: The public timeline for any user, using `uri_template`. For more information, see "[Hypermedia](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#hypermedia)."
*   **Current user public**: The public timeline for the authenticated user
*   **Current user**: The private timeline for the authenticated user
*   **Current user actor**: The private timeline for activity created by the authenticated user
*   **Current user organizations**: The private timeline for the organizations the authenticated user is a member of.
*   **Security advisories**: A collection of public announcements that provide information about security-related vulnerabilities in software on GitHub.

By default, timeline resources are returned in JSON. You can specify the `application/atom+xml` type in the `Accept` header to return timeline resources in Atom format. For more information, see "[Media types](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#media-types)."

**Note**: Private feeds are only returned when [authenticating via Basic Auth](https://docs.github.com/rest/overview/other-authentication-methods#basic-authentication) since current feed URIs use the older, non revocable auth tokens.

## Resources

  * [API method documentation](https://docs.github.com/rest/activity/feeds#get-feeds)

## get_repo_subscription(owner, repo, opts \\ [])

Get a repository subscription

Gets information about whether the authenticated user is subscribed to the repository.

## Resources

  * [API method documentation](https://docs.github.com/rest/activity/watching#get-a-repository-subscription)

## get_thread(thread_id, opts \\ [])

Get a thread

Gets information about a notification thread.

## Resources

  * [API method documentation](https://docs.github.com/rest/activity/notifications#get-a-thread)

## get_thread_subscription_for_authenticated_user(thread_id, opts \\ [])

Get a thread subscription for the authenticated user

This checks to see if the current user is subscribed to a thread. You can also [get a repository subscription](https://docs.github.com/rest/activity/watching#get-a-repository-subscription).

Note that subscriptions are only generated if a user is participating in a conversation--for example, they've replied to the thread, were **@mentioned**, or manually subscribe to a thread.

## Resources

  * [API method documentation](https://docs.github.com/rest/activity/notifications#get-a-thread-subscription-for-the-authenticated-user)

## list_events_for_authenticated_user(username, opts \\ [])

List events for the authenticated user

If you are authenticated as the given user, you will see your private events. Otherwise, you'll only see public events.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/activity/events#list-events-for-the-authenticated-user)

## list_notifications_for_authenticated_user(opts \\ [])

List notifications for the authenticated user

List all notifications for the current user, sorted by most recently updated.

## Options

  * `all`: If `true`, show notifications marked as read.
  * `participating`: If `true`, only shows notifications in which the user is directly participating or mentioned.
  * `since`: Only show results that were last updated after the given time. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
  * `before`: Only show notifications updated before the given time. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `per_page`: The number of results per page (max 50). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/activity/notifications#list-notifications-for-the-authenticated-user)

## list_org_events_for_authenticated_user(username, org, opts \\ [])

List organization events for the authenticated user

This is the user's organization dashboard. You must be authenticated as the user to view this.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/activity/events#list-organization-events-for-the-authenticated-user)

## list_public_events(opts \\ [])

List public events

We delay the public events feed by five minutes, which means the most recent event returned by the public events API actually occurred at least five minutes ago.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/activity/events#list-public-events)

## list_public_events_for_repo_network(owner, repo, opts \\ [])

List public events for a network of repositories

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/activity/events#list-public-events-for-a-network-of-repositories)

## list_public_events_for_user(username, opts \\ [])

List public events for a user

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/activity/events#list-public-events-for-a-user)

## list_public_org_events(org, opts \\ [])

List public organization events

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/activity/events#list-public-organization-events)

## list_received_events_for_user(username, opts \\ [])

List events received by the authenticated user

These are events that you've received by watching repositories and following users. If you are authenticated as the given user, you will see private events. Otherwise, you'll only see public events.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/activity/events#list-events-received-by-the-authenticated-user)

## list_received_public_events_for_user(username, opts \\ [])

List public events received by a user

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/activity/events#list-public-events-received-by-a-user)

## list_repo_events(owner, repo, opts \\ [])

List repository events

**Note**: This API is not built to serve real-time use cases. Depending on the time of day, event latency can be anywhere from 30s to 6h.


## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/activity/events#list-repository-events)

## list_repo_notifications_for_authenticated_user(owner, repo, opts \\ [])

List repository notifications for the authenticated user

Lists all notifications for the current user in the specified repository.

## Options

  * `all`: If `true`, show notifications marked as read.
  * `participating`: If `true`, only shows notifications in which the user is directly participating or mentioned.
  * `since`: Only show results that were last updated after the given time. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
  * `before`: Only show notifications updated before the given time. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/activity/notifications#list-repository-notifications-for-the-authenticated-user)

## list_repos_starred_by_authenticated_user(opts \\ [])

List repositories starred by the authenticated user

Lists repositories the authenticated user has starred.

This endpoint supports the following custom media types. For more information, see "[Media types](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#media-types)."

- **`application/vnd.github.star+json`**: Includes a timestamp of when the star was created.

## Options

  * `sort`: The property to sort the results by. `created` means when the repository was starred. `updated` means when the repository was last pushed to.
  * `direction`: The direction to sort the results by.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/activity/starring#list-repositories-starred-by-the-authenticated-user)

## list_repos_starred_by_user(username, opts \\ [])

List repositories starred by a user

Lists repositories a user has starred.

This endpoint supports the following custom media types. For more information, see "[Media types](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#media-types)."

- **`application/vnd.github.star+json`**: Includes a timestamp of when the star was created.

## Options

  * `sort`: The property to sort the results by. `created` means when the repository was starred. `updated` means when the repository was last pushed to.
  * `direction`: The direction to sort the results by.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/activity/starring#list-repositories-starred-by-a-user)

## list_repos_watched_by_user(username, opts \\ [])

List repositories watched by a user

Lists repositories a user is watching.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/activity/watching#list-repositories-watched-by-a-user)

## list_stargazers_for_repo(owner, repo, opts \\ [])

List stargazers

Lists the people that have starred the repository.

This endpoint supports the following custom media types. For more information, see "[Media types](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#media-types)."

- **`application/vnd.github.star+json`**: Includes a timestamp of when the star was created.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/activity/starring#list-stargazers)

## list_watched_repos_for_authenticated_user(opts \\ [])

List repositories watched by the authenticated user

Lists repositories the authenticated user is watching.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/activity/watching#list-repositories-watched-by-the-authenticated-user)

## list_watchers_for_repo(owner, repo, opts \\ [])

List watchers

Lists the people watching the specified repository.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/activity/watching#list-watchers)

## mark_notifications_as_read(body, opts \\ [])

Mark notifications as read

Marks all notifications as "read" for the current user. If the number of notifications is too large to complete in one request, you will receive a `202 Accepted` status and GitHub will run an asynchronous process to mark notifications as "read." To check whether any "unread" notifications remain, you can use the [List notifications for the authenticated user](https://docs.github.com/rest/activity/notifications#list-notifications-for-the-authenticated-user) endpoint and pass the query parameter `all=false`.

## Resources

  * [API method documentation](https://docs.github.com/rest/activity/notifications#mark-notifications-as-read)

## mark_repo_notifications_as_read(owner, repo, body, opts \\ [])

Mark repository notifications as read

Marks all notifications in a repository as "read" for the current user. If the number of notifications is too large to complete in one request, you will receive a `202 Accepted` status and GitHub will run an asynchronous process to mark notifications as "read." To check whether any "unread" notifications remain, you can use the [List repository notifications for the authenticated user](https://docs.github.com/rest/activity/notifications#list-repository-notifications-for-the-authenticated-user) endpoint and pass the query parameter `all=false`.

## Resources

  * [API method documentation](https://docs.github.com/rest/activity/notifications#mark-repository-notifications-as-read)

## mark_thread_as_done(thread_id, opts \\ [])

Mark a thread as done

Marks a thread as "done." Marking a thread as "done" is equivalent to marking a notification in your notification inbox on GitHub as done: https://github.com/notifications.

## Resources

  * [API method documentation](https://docs.github.com/rest/activity/notifications#mark-a-thread-as-done)

## mark_thread_as_read(thread_id, opts \\ [])

Mark a thread as read

Marks a thread as "read." Marking a thread as "read" is equivalent to clicking a notification in your notification inbox on GitHub: https://github.com/notifications.

## Resources

  * [API method documentation](https://docs.github.com/rest/activity/notifications#mark-a-thread-as-read)

## set_repo_subscription(owner, repo, body, opts \\ [])

Set a repository subscription

If you would like to watch a repository, set `subscribed` to `true`. If you would like to ignore notifications made within a repository, set `ignored` to `true`. If you would like to stop watching a repository, [delete the repository's subscription](https://docs.github.com/rest/activity/watching#delete-a-repository-subscription) completely.

## Resources

  * [API method documentation](https://docs.github.com/rest/activity/watching#set-a-repository-subscription)

## set_thread_subscription(thread_id, body, opts \\ [])

Set a thread subscription

If you are watching a repository, you receive notifications for all threads by default. Use this endpoint to ignore future notifications for threads until you comment on the thread or get an **@mention**.

You can also use this endpoint to subscribe to threads that you are currently not receiving notifications for or to subscribed to threads that you have previously ignored.

Unsubscribing from a conversation in a repository that you are not watching is functionally equivalent to the [Delete a thread subscription](https://docs.github.com/rest/activity/notifications#delete-a-thread-subscription) endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/activity/notifications#set-a-thread-subscription)

## star_repo_for_authenticated_user(owner, repo, opts \\ [])

Star a repository for the authenticated user

Note that you'll need to set `Content-Length` to zero when calling out to this endpoint. For more information, see "[HTTP method](https://docs.github.com/rest/guides/getting-started-with-the-rest-api#http-method)."

## Resources

  * [API method documentation](https://docs.github.com/rest/activity/starring#star-a-repository-for-the-authenticated-user)

## unstar_repo_for_authenticated_user(owner, repo, opts \\ [])

Unstar a repository for the authenticated user

Unstar a repository that the authenticated user has previously starred.

## Resources

  * [API method documentation](https://docs.github.com/rest/activity/starring#unstar-a-repository-for-the-authenticated-user)