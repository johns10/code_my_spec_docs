# Faker.Lorem

Functions for generating Lorem Ipsum data

## characters(range_or_length \\ 15..255)

Returns a character list of the given length.

If a range is provided, the length of the list is random in between the
specified range.

Defaults to a range between 15 and 255 (inclusive).

## Examples

    iex> Faker.Lorem.characters()
    'ppkQqaIfGqxsjFoNITNnu6eXyJicLJNth88PrhGDhwp4LNQMt5pCFh7XGEZUiBOjqwcnSUTH94vu8a9XKUwNAs48lHzPITbFXSfTS0pHfBSmHkbj9kOsd7qRuGeXKTgCgI1idI3uwENwTqc'
    iex> Faker.Lorem.characters(3..5)
    'EFbv'
    iex> Faker.Lorem.characters(2)
    'vx'
    iex> Faker.Lorem.characters(7)
    'jycADSd'

## paragraph(range \\ 2..5)

Returns a string with a given amount of sentences.

If a range is provided, the number of sentences is random in between the
specified range.

Defaults to a range between 2 and 5 (inclusive).

## Examples

    iex> Faker.Lorem.paragraph()
    "Deleniti consequatur et qui vitae et. Sit aut expedita cumque est necessitatibus beatae ex sunt! Soluta asperiores qui vitae animi et id et vitae. Quisquam corporis quisquam ab harum!"
    iex> Faker.Lorem.paragraph(1..2)
    "Numquam maxime ut aut inventore eius rerum beatae. Qui officia vel quaerat expedita."
    iex> Faker.Lorem.paragraph(1)
    "Perspiciatis rerum nam repellendus inventore nihil."
    iex> Faker.Lorem.paragraph(2)
    "Sequi ducimus qui voluptates magni quisquam sed odio. Vel error non impedit tempora minus."

## paragraphs(range \\ 2..5)

Returns a list with a given amount of paragraphs.

If a range is provided, the number of paragraphs is random in between the
specified range.

Defaults to a range between 2 and 5 (inclusive)

## Examples

    iex> Faker.Lorem.paragraphs()
    ["Consequatur et qui vitae? Et sit aut expedita cumque est necessitatibus beatae ex. Possimus soluta asperiores qui vitae.", "Et vitae vitae ut quisquam corporis quisquam ab harum ipsa. Numquam maxime ut aut inventore eius rerum beatae. Qui officia vel quaerat expedita. Perspiciatis rerum nam repellendus inventore nihil. Sequi ducimus qui voluptates magni quisquam sed odio.", "Error non impedit tempora minus voluptatem qui fugit. Ab consectetur harum earum possimus. Provident quisquam modi accusantium eligendi numquam illo voluptas. Est non id quibusdam qui omnis?", "Dicta dolores at ut delectus magni atque eos beatae nulla. Laudantium qui dolorem pariatur voluptatibus sed et enim?"]
    iex> Faker.Lorem.paragraphs(2..3)
    ["Voluptate reiciendis repellat et praesentium quia sed nemo. Vero repellat cumque nihil similique repudiandae corrupti rerum? Accusamus suscipit perspiciatis cum et sint dolore et ut. Eos reprehenderit cupiditate omnis et doloremque omnis.", "Quo et est culpa eum ex et veniam aut aut! Labore fuga tenetur alias est provident?", "Illo consequatur maiores illum et quia culpa sunt! Cumque porro ut eum porro est id maxime dolorum animi. Deserunt ipsa consequuntur eveniet asperiores. Quia numquam voluptas vitae repellat tempore."]
    iex> Faker.Lorem.paragraphs(1)
    ["Voluptas harum modi omnis quam dolor a aliquam officiis. Neque voluptas consequatur sed cupiditate dolorum pariatur et."]
    iex> Faker.Lorem.paragraphs(2)
    ["Voluptatem natus amet eius eos non dolorum quaerat dolores pariatur. Aliquam rerum ab voluptatem exercitationem nobis enim delectus tempore eos. Ex enim dolore ut consequuntur eaque expedita dicta eius totam. A eveniet ab magni rerum enim consequatur.", "Nihil laudantium ea veniam necessitatibus qui. Minus ad omnis quaerat quidem impedit sint. Id ut repellat qui repudiandae!"]

## sentence(range \\ 4..10)

Returns a string with a given amount of words.

If a range is provided, the number of words is random in between the
specified range.

Defaults to a range between 4 and 10 (inclusive).

## Examples

    iex> Faker.Lorem.sentence()
    "Sint deleniti consequatur et qui vitae et quibusdam et sit."
    iex> Faker.Lorem.sentence(2..3)
    "Cumque est?"
    iex> Faker.Lorem.sentence(3)
    "Beatae ex sunt."
    iex> Faker.Lorem.sentence(5)
    "Possimus soluta asperiores qui vitae."

## sentence(num, mark)

Returns a string with an amount of words equal to the parameter provided,
concatenating the specified mark

## Examples

    iex> Faker.Lorem.sentence(7, "...")
    "Aliquam ut sint deleniti consequatur et qui..."
    iex> Faker.Lorem.sentence(1, "?")
    "Vitae?"
    iex> Faker.Lorem.sentence(5, ".")
    "Et quibusdam et sit aut."
    iex> Faker.Lorem.sentence(3, ";")
    "Expedita cumque est;"

## sentences(range \\ 2..5)

Returns a list of strings of the given length, each representing a sentence.

If a range is provided, the length of the list is random in between the
specified range.

Defaults to a range between 2 and 5 (inclusive).

## Examples

    iex> Faker.Lorem.sentences()
    ["Deleniti consequatur et qui vitae et.", "Sit aut expedita cumque est necessitatibus beatae ex sunt!", "Soluta asperiores qui vitae animi et id et vitae.", "Quisquam corporis quisquam ab harum!"]
    iex> Faker.Lorem.sentences(3..4)
    ["Numquam maxime ut aut inventore eius rerum beatae.", "Qui officia vel quaerat expedita.", "Perspiciatis rerum nam repellendus inventore nihil.", "Sequi ducimus qui voluptates magni quisquam sed odio."]
    iex> Faker.Lorem.sentences(4)
    ["Vel error non impedit tempora minus.", "Fugit cupiditate fuga ab consectetur harum earum possimus totam.", "Quisquam modi accusantium eligendi numquam.", "Quod blanditiis est non id quibusdam qui omnis alias!"]
    iex> Faker.Lorem.sentences(3)
    ["Dicta dolores at ut delectus magni atque eos beatae nulla.", "Laudantium qui dolorem pariatur voluptatibus sed et enim?", "Minima laudantium voluptate reiciendis repellat."]

## word()

Returns a random word from @data

## Examples

    iex> Faker.Lorem.word()
    "aliquam"
    iex> Faker.Lorem.word()
    "ut"
    iex> Faker.Lorem.word()
    "sint"
    iex> Faker.Lorem.word()
    "deleniti"

## words(range \\ 3..6)

Returns a list of strings of the given length, each representing a word.

If a range is provided, the length of the list is random in between the
provided range.

Defaults to a range between 3 and 6.

## Examples

    iex> Faker.Lorem.words()
    ["ut", "sint", "deleniti", "consequatur", "et"]
    iex> Faker.Lorem.words(1..2)
    ["vitae"]
    iex> Faker.Lorem.words(2)
    ["et", "quibusdam"]
    iex> Faker.Lorem.words(6)
    ["et", "sit", "aut", "expedita", "cumque", "est"]