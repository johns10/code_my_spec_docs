# GitHub.Classroom

Provides API endpoints related to classroom

## get_a_classroom(classroom_id, opts \\ [])

Get a classroom

Gets a GitHub Classroom classroom for the current user. Classroom will only be returned if the current user is an administrator of the GitHub Classroom.

## Resources

  * [API method documentation](https://docs.github.com/rest/classroom/classroom#get-a-classroom)

## get_an_assignment(assignment_id, opts \\ [])

Get an assignment

Gets a GitHub Classroom assignment. Assignment will only be returned if the current user is an administrator of the GitHub Classroom for the assignment.

## Resources

  * [API method documentation](https://docs.github.com/rest/classroom/classroom#get-an-assignment)

## get_assignment_grades(assignment_id, opts \\ [])

Get assignment grades

Gets grades for a GitHub Classroom assignment. Grades will only be returned if the current user is an administrator of the GitHub Classroom for the assignment.

## Resources

  * [API method documentation](https://docs.github.com/rest/classroom/classroom#get-assignment-grades)

## list_accepted_assigments_for_an_assignment(assignment_id, opts \\ [])

List accepted assignments for an assignment

Lists any assignment repositories that have been created by students accepting a GitHub Classroom assignment. Accepted assignments will only be returned if the current user is an administrator of the GitHub Classroom for the assignment.

## Options

  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/classroom/classroom#list-accepted-assignments-for-an-assignment)

## list_assignments_for_a_classroom(classroom_id, opts \\ [])

List assignments for a classroom

Lists GitHub Classroom assignments for a classroom. Assignments will only be returned if the current user is an administrator of the GitHub Classroom.

## Options

  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/classroom/classroom#list-assignments-for-a-classroom)

## list_classrooms(opts \\ [])

List classrooms

Lists GitHub Classroom classrooms for the current user. Classrooms will only be returned if the current user is an administrator of one or more GitHub Classrooms.

## Options

  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/classroom/classroom#list-classrooms)