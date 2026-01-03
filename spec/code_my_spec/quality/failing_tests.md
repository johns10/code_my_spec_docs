# CodeMySpec.Quality.Tdd

Manages validation of test execution state to enforce TDD workflows. 
Checks whether tests are in appropriate passing/failing states based on implementation status.
If there's no implementation file, we should expect all the tests to fail.
If there's an implementation file, we allow passing tests. 
