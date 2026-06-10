# Faker.Pizza

Functions for generating Pizza related data in English.

## pizzas/1

Returns a list with a number of pizzas.

If an integer is provided, exactly that number of pizzas will be returned.
If a range is provided, the number will be in the range.
If no range or integer is specified it defaults to 2..5

## Examples

    iex> Faker.Pizza.pizzas()
    [
      "14\" Greek Maltija",
      "Large with Reindeer, Buffalo Chicken, Egg, Chorizo, and Clam",
      "9\" Capricciosa",
      "9\" Sicilian Style Frutti di mare"
    ]
    iex> Faker.Pizza.pizzas(2..3)
    [
      "12\" Fajita",
      "Medium Fajita"
    ]
    iex> Faker.Pizza.pizzas(3..4)
    [
      "Large Gluten-Free Corn with Oysters, Bacon, and Steak",
      "10\" Flatbread Grilled Vegetarian",
      "30\" Thai Chicken",
      "Small with Sauerkraut"
    ]
    iex> Faker.Pizza.pizzas(5)
    [
      "Large Quattro Formaggio",
      "Small Sweet Potato Crust with Mackerel, Jalapeños, Smoked Mozzarella, and Smoked Salmon",
      "30\" with Pickled Ginger, Meatballs, Goat Cheese, Prosciutto, and Pineapple",
      "9\" Detroit-style with Steak",
      "Family with Clam, Cherry Tomatoes, Salmon, and Chicken"
    ]

## pizza/0

Returns a pizza

## Examples

    iex> Faker.Pizza.pizza()
    "16\" with Fior di latte"
    iex> Faker.Pizza.pizza()
    "Medium New York Style with Clam and Reindeer"
    iex> Faker.Pizza.pizza()
    "9\" Supreme"
    iex> Faker.Pizza.pizza()
    "16\" Shrimp Club"

## toppings/1

Returns a list with a number of toppings.

If an integer is provided, exactly that number of toppings will be returned.
If a range is provided, the number will be in the range.
If no range or integer is specified it defaults to 2..5

## Examples

    iex> Faker.Pizza.toppings()
    ["Pesto Sauce", "Fior di latte", "Broccoli", "Banana Peppers"]
    iex> Faker.Pizza.toppings(4)
    ["Clam", "Reindeer", "Buffalo Chicken", "Egg"]
    iex> Faker.Pizza.toppings(2..3)
    ["Sausage", "Green Peas"]
    iex> Faker.Pizza.toppings(2..3)
    ["Shellfish", "Smoked Salmon"]

## topping/0

Returns a random cheese, sauce, meat or vegetarian topping

## Examples

    iex> Faker.Pizza.topping()
    "Black Olives"
    iex> Faker.Pizza.topping()
    "Meatballs"
    iex> Faker.Pizza.topping()
    "Asiago"
    iex> Faker.Pizza.topping()
    "Philly Steak"

## size_or_inches/0

Returns a random size or inches

## Examples

    iex> Faker.Pizza.size_or_inches()
    "Family"
    iex> Faker.Pizza.size_or_inches()
    "14\""
    iex> Faker.Pizza.size_or_inches()
    "Personal"
    iex> Faker.Pizza.size_or_inches()
    "Medium"