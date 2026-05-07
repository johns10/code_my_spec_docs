# Faker.Person.Fr

Functions for name data in French

## first_name()

Returns a random first name

## Examples
  
    iex> Faker.Person.Fr.first_name()
    "Damien"
    iex> Faker.Person.Fr.first_name()
    "Madeleine"
    iex> Faker.Person.Fr.first_name()
    "Marcel"
    iex> Faker.Person.Fr.first_name()
    "Fabrice"

## last_name()

Returns a random last name

  ## Examples

  iex> Faker.Person.Fr.last_name()
  "Bassett"
  iex> Faker.Person.Fr.last_name()
  "Duplantier"
  iex> Faker.Person.Fr.last_name()
  "Boivin"
  iex> Faker.Person.Fr.last_name()
  "Duplantier"

## name()

Returns a complete name (may include a suffix/prefix or both)

## Examples
    iex> Faker.Person.Fr.name()
    "Madame Marcel Duplantier MD"
    iex> Faker.Person.Fr.name()
    "Quentin Garnier"
    iex> Faker.Person.Fr.name()
    "Docteur Camille Fontaine"
    iex> Faker.Person.Fr.name()
    "Serge Bassett V"

## prefix()

Returns a random prefix

## Examples
    
    iex> Faker.Person.Fr.prefix()
    "Docteur"
    iex> Faker.Person.Fr.prefix()
    "Madame"
    iex> Faker.Person.Fr.prefix()
    "Docteur"
    iex> Faker.Person.Fr.prefix()
    "Professeur"

## suffix()

Returns a random suffix

## Examples

    iex> Faker.Person.Fr.suffix()
    "V"
    iex> Faker.Person.Fr.suffix()
    "I"
    iex> Faker.Person.Fr.suffix()
    "PhD"
    iex> Faker.Person.Fr.suffix()
    "MD"