# Faker.Pizza

Functions for generating Pizza related data in English.

## cheese()

Returns a cheese string

## Examples

    iex> Faker.Pizza.cheese()
    "Mozzarella"
    iex> Faker.Pizza.cheese()
    "Marscapone"
    iex> Faker.Pizza.cheese()
    "Blue (Bleu) Cheese"
    iex> Faker.Pizza.cheese()
    "Smoked Mozzarella"

## combo()

Returns a combo string

## Examples

    iex> Faker.Pizza.combo()
    "Breakfast"
    iex> Faker.Pizza.combo()
    "Caprese"
    iex> Faker.Pizza.combo()
    "Mockba"
    iex> Faker.Pizza.combo()
    "Poutine"

## company()

Returns a Pizza Restaurant string

## Examples

    iex> Faker.Pizza.company()
    "Papa Plastique"
    iex> Faker.Pizza.company()
    "Chicago Deep Dish"
    iex> Faker.Pizza.company()
    "Pizza Joe’s"
    iex> Faker.Pizza.company()
    "CosaNostra Pizza"

## inches()

Returns an inches string

## Examples

    iex> Faker.Pizza.inches()
    "9\""
    iex> Faker.Pizza.inches()
    "10\""
    iex> Faker.Pizza.inches()
    "16\""
    iex> Faker.Pizza.inches()
    "14\""

## meat()

Returns a meat string

## Examples

    iex> Faker.Pizza.meat()
    "Buffalo Chicken"
    iex> Faker.Pizza.meat()
    "Meatballs"
    iex> Faker.Pizza.meat()
    "Chicken"
    iex> Faker.Pizza.meat()
    "Meatballs"

## pizza()

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

## pizzas(range \\ 2..5)

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

## sauce()

Returns a sauce string

## Examples

    iex> Faker.Pizza.sauce()
    "Spicy Tomato Sauce"
    iex> Faker.Pizza.sauce()
    "Hummus"
    iex> Faker.Pizza.sauce()
    "Pesto Sauce"
    iex> Faker.Pizza.sauce()
    "Hummus"

## size()

Returns a size string

## Examples

    iex> Faker.Pizza.size()
    "Personal"
    iex> Faker.Pizza.size()
    "Family"
    iex> Faker.Pizza.size()
    "Large"
    iex> Faker.Pizza.size()
    "Medium"

## size_or_inches()

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

## style()

Returns a pizza style

## Examples

    iex> Faker.Pizza.style()
    "Pizza Frittata"
    iex> Faker.Pizza.style()
    "Gluten-Free Corn"
    iex> Faker.Pizza.style()
    "Detroit-style"
    iex> Faker.Pizza.style()
    "Stuffed Crust"

## topping()

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

## toppings(range \\ 2..5)

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

## vegetable()

Returns a vegetable string

## Examples

    iex> Faker.Pizza.vegetable()
    "Mango"
    iex> Faker.Pizza.vegetable()
    "Black Olives"
    iex> Faker.Pizza.vegetable()
    "Green Olives"
    iex> Faker.Pizza.vegetable()
    "Sauerkraut"