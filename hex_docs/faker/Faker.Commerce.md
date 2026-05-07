# Faker.Commerce

Functions for generating commerce related data

## color()

Returns a random color

## Examples

    iex> Faker.Commerce.color()
    "red"
    iex> Faker.Commerce.color()
    "sky blue"
    iex> Faker.Commerce.color()
    "lavender"
    iex> Faker.Commerce.color()
    "grey"

## department()

Returns a random department

## Examples

    iex> Faker.Commerce.department()
    "Home, Garden & Tools"
    iex> Faker.Commerce.department()
    "Electronics & Computers"
    iex> Faker.Commerce.department()
    "Clothing, Shoes & Jewelery"
    iex> Faker.Commerce.department()
    "Toys, Kids & Baby"

## price()

Returns a random number that represents a price

## Examples

    iex> Faker.Commerce.price()
    1.11
    iex> Faker.Commerce.price()
    4.02
    iex> Faker.Commerce.price()
    8.36
    iex> Faker.Commerce.price()
    3.05

## product_name()

Returns a complete product name, based on product adjectives, product
materials, product names

## Examples

    iex> Faker.Commerce.product_name()
    "Ergonomic Steel Shirt"
    iex> Faker.Commerce.product_name()
    "Fantastic Car"
    iex> Faker.Commerce.product_name()
    "Granite Gloves"
    iex> Faker.Commerce.product_name()
    "Plastic Shoes"

## product_name_adjective()

Returns a random adjective for a product

## Examples

    iex> Faker.Commerce.product_name_adjective()
    "Small"
    iex> Faker.Commerce.product_name_adjective()
    "Ergonomic"
    iex> Faker.Commerce.product_name_adjective()
    "Incredible"
    iex> Faker.Commerce.product_name_adjective()
    "Gorgeous"

## product_name_material()

Returns a random product material

## Examples

    iex> Faker.Commerce.product_name_material()
    "Rubber"
    iex> Faker.Commerce.product_name_material()
    "Concrete"
    iex> Faker.Commerce.product_name_material()
    "Steel"
    iex> Faker.Commerce.product_name_material()
    "Granite"

## product_name_product()

Returns a random product name

## Examples

    iex> Faker.Commerce.product_name_product()
    "Gloves"
    iex> Faker.Commerce.product_name_product()
    "Computer"
    iex> Faker.Commerce.product_name_product()
    "Table"
    iex> Faker.Commerce.product_name_product()
    "Shirt"