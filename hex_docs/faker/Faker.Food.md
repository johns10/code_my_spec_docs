# Faker.Food

Functions for generating food data.

## description()

Returns a random description.

## Examples

    iex> Faker.Food.description()
    "Two buttermilk waffles, topped with whipped cream and maple syrup, a side of two eggs served any style, and your choice of smoked bacon or smoked ham."
    iex> Faker.Food.description()
    "28-day aged 300g USDA Certified Prime Ribeye, rosemary-thyme garlic butter, with choice of two sides."
    iex> Faker.Food.description()
    "Breaded fried chicken with waffles, and a side of maple syrup."
    iex> Faker.Food.description()
    "Creamy mascarpone cheese and custard layered between espresso and rum soaked house-made ladyfingers, topped with Valrhona cocoa powder."

## dish()

Returns a random complete dish.

## Examples

    iex> Faker.Food.dish()
    "Vegetable Soup"
    iex> Faker.Food.dish()
    "Fish and chips"
    iex> Faker.Food.dish()
    "Pork belly buns"
    iex> Faker.Food.dish()
    "Pasta Carbonara"

## ingredient()

Returns a random ingredient.

## Examples

    iex> Faker.Food.ingredient()
    "Tomatoes"
    iex> Faker.Food.ingredient()
    "Albacore Tuna"
    iex> Faker.Food.ingredient()
    "Potatoes"
    iex> Faker.Food.ingredient()
    "Tinned"

## measurement()

Returns a random measurement.

## Examples

    iex> Faker.Food.measurement()
    "teaspoon"
    iex> Faker.Food.measurement()
    "gallon"
    iex> Faker.Food.measurement()
    "pint"
    iex> Faker.Food.measurement()
    "cup"

## measurement_size()

Returns a random measurement size.

## Examples

    iex> Faker.Food.measurement_size()
    "1/4"
    iex> Faker.Food.measurement_size()
    "3"
    iex> Faker.Food.measurement_size()
    "1"
    iex> Faker.Food.measurement_size()
    "1/2"

## metric_measurement()

Returns a random metric measurement.

## Examples

    iex> Faker.Food.metric_measurement()
    "centiliter"
    iex> Faker.Food.metric_measurement()
    "deciliter"
    iex> Faker.Food.metric_measurement()
    "liter"
    iex> Faker.Food.metric_measurement()
    "milliliter"

## spice()

Returns a random spicy ingredient.

## Examples

    iex> Faker.Food.spice()
    "Garlic Salt"
    iex> Faker.Food.spice()
    "Ras-el-Hanout"
    iex> Faker.Food.spice()
    "Curry Hot"
    iex> Faker.Food.spice()
    "Peppercorns Mixed"

## sushi()

Returns a type of sushi.

## Examples

    iex> Faker.Food.sushi()
    "Whitespotted conger"
    iex> Faker.Food.sushi()
    "Japanese horse mackerel"
    iex> Faker.Food.sushi()
    "Salmon"
    iex> Faker.Food.sushi()
    "Octopus"