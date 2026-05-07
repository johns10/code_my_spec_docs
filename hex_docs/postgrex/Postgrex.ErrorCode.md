# Postgrex.ErrorCode



## code_to_name(code)

Translates a PostgreSQL error code into a name

Examples:
    iex> code_to_name("23505")
    :unique_violation

## name_to_code(name)

Translates a PostgreSQL error name into a list of possible codes.
Most error names have only a single code, but there are exceptions.

Examples:
    iex> name_to_code(:prohibited_sql_statement_attempted)
    "2F003"