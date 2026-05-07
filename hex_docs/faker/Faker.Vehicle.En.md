# Faker.Vehicle.En

Functions for generating Vehicle related data in English

## body_style()

Returns a vehicle body style string

## Examples
    iex> Faker.Vehicle.En.body_style()
    "Minivan"
    iex> Faker.Vehicle.En.body_style()
    "Hatchback"
    iex> Faker.Vehicle.En.body_style()
    "Crew Cab Pickup"
    iex> Faker.Vehicle.En.body_style()
    "Regular Cab Pickup"

## drivetrain()

Returns a vehicle drivetrain string

## Examples
    iex> Faker.Vehicle.En.drivetrain()
    "4x2/2-wheel drive"
    iex> Faker.Vehicle.En.drivetrain()
    "4x4/4-wheel drive"
    iex> Faker.Vehicle.En.drivetrain()
    "4x2/2-wheel drive"
    iex> Faker.Vehicle.En.drivetrain()
    "RWD"

## fuel_type()

Returns a vehicle fuel type string

## Examples
    iex> Faker.Vehicle.En.fuel_type()
    "Ethanol"
    iex> Faker.Vehicle.En.fuel_type()
    "E-85/Gasoline"
    iex> Faker.Vehicle.En.fuel_type()
    "Compressed Natural Gas"
    iex> Faker.Vehicle.En.fuel_type()
    "Gasoline Hybrid"

## make()

Returns a vehicle make string

## Examples

    iex> Faker.Vehicle.En.make()
    "Lincoln"
    iex> Faker.Vehicle.En.make()
    "Dodge"
    iex> Faker.Vehicle.En.make()
    "Chevrolet"
    iex> Faker.Vehicle.En.make()
    "Honda"

## make_and_model()

Returns a vehicle make and model string

## Examples

    iex> Faker.Vehicle.En.make_and_model()
    "Lincoln MKZ"
    iex> Faker.Vehicle.En.make_and_model()
    "Chevrolet Malibu"
    iex> Faker.Vehicle.En.make_and_model()
    "Ford Focus"
    iex> Faker.Vehicle.En.make_and_model()
    "Ford Focus"

## model()

Returns a vehicle model string

## Examples

    iex> Faker.Vehicle.En.model()
    "Encore"
    iex> Faker.Vehicle.En.model()
    "S5"
    iex> Faker.Vehicle.En.model()
    "Fiesta"
    iex> Faker.Vehicle.En.model()
    "X1"

## model(make)

Returns a realistic vehicle model string
for the given model.

## Examples

    iex> Faker.Vehicle.En.model("Ford")
    "Focus"
    iex> Faker.Vehicle.En.model("BMW")
    "X5"
    iex> Faker.Vehicle.En.model("Audi")
    "A4"
    iex> Faker.Vehicle.En.model("Toyota")
    "Corolla"

## option()

Returns a vehicle option string

## Examples
    iex> Faker.Vehicle.En.option()
    "Premium Sound"
    iex> Faker.Vehicle.En.option()
    "Power Steering"
    iex> Faker.Vehicle.En.option()
    "A/C: Front"
    iex> Faker.Vehicle.En.option()
    "Keyless Entry"

## options()

Returns a list of vehicle options()

## Examples
    iex> Faker.Vehicle.En.options
    ["Power Steering", "A/C: Front", "Keyless Entry", "AM/FM Stereo", "Power Steering", "Antilock Brakes", "8-Track Player", "Leather Interior"]
    iex> Faker.Vehicle.En.options
    ["MP3 (Multi Disc)", "A/C: Rear", "Fog Lights", "Power Windows", "Cruise Control", "Premium Sound", "A/C: Front"]
    iex> Faker.Vehicle.En.options
    ["Tinted Glass", "MP3 (Single Disc)", "CD (Multi Disc)"]
    iex> Faker.Vehicle.En.options
    ["Fog Lights", "Rear Window Wiper", "MP3 (Multi Disc)", "Navigation", "Airbag: Side", "Rear Window Defroster", "Premium Sound"]

## options(number)

Returns a list of vehicle options of the given length

## Examples
    iex> Faker.Vehicle.En.options(3)
    ["Premium Sound", "Power Steering", "A/C: Front"]
    iex> Faker.Vehicle.En.options(3)
    ["Keyless Entry", "AM/FM Stereo", "Power Steering"]
    iex> Faker.Vehicle.En.options(3)
    ["Antilock Brakes", "8-Track Player", "Leather Interior"]
    iex> Faker.Vehicle.En.options(3)
    ["Cassette Player", "MP3 (Multi Disc)", "A/C: Rear"]

## standard_spec()

Reterns a vehicle standard option string

## Examples
    iex> Faker.Vehicle.En.standard_spec()
    "Tire pressure monitoring system (TPMS)"
    iex> Faker.Vehicle.En.standard_spec()
    "20\" x 9.0\" front & 20\" x 10.0\" rear aluminum wheels"
    iex> Faker.Vehicle.En.standard_spec()
    "Deluxe insulation group"
    iex> Faker.Vehicle.En.standard_spec()
    "Torsion beam rear suspension w/stabilizer bar"

## standard_specs()

Returns a list of vehicle standard specs

## Examples
    iex> Faker.Vehicle.En.standard_specs()
    ["20\" x 9.0\" front & 20\" x 10.0\" rear aluminum wheels", "Deluxe insulation group", "Torsion beam rear suspension w/stabilizer bar", "High performance suspension", "200mm front axle", "Traveler/mini trip computer", "P235/50R18 all-season tires", "Front door tinted glass"]
    iex> Faker.Vehicle.En.standard_specs()
    ["625-amp maintenance-free battery", "Body color sill extension", "Cargo compartment cover", "Dana 44/226mm rear axle", "Tachometer", "Leather-wrapped parking brake handle", "Side-impact door beams"]
    iex> Faker.Vehicle.En.standard_specs()
    ["Tilt steering column", "Luxury front & rear floor mats w/logo", "HomeLink universal transceiver"]
    iex> Faker.Vehicle.En.standard_specs()
    ["Multi-reflector halogen headlamps", "Multi-info display -inc: driving range, average MPG, current MPG, average speed, outside temp, elapsed time, maintenance & diagnostic messages", "Zone body construction -inc: front/rear crumple zones, hood deformation point", "60/40 split fold-down rear seat w/outboard adjustable headrests", "Trim-panel-mounted storage net", "Front side-impact airbags", "Front/rear spot-lamp illumination"]

## standard_specs(number)

Returns a list of vehicle standard specs of the given length

## Examples
    iex> Faker.Vehicle.En.standard_specs(3)
    ["Tire pressure monitoring system (TPMS)", "20\" x 9.0\" front & 20\" x 10.0\" rear aluminum wheels", "Deluxe insulation group"]
    iex> Faker.Vehicle.En.standard_specs(3)
    ["Torsion beam rear suspension w/stabilizer bar", "High performance suspension", "200mm front axle"]
    iex> Faker.Vehicle.En.standard_specs(3)
    ["Traveler/mini trip computer", "P235/50R18 all-season tires", "Front door tinted glass"]
    iex> Faker.Vehicle.En.standard_specs(3)
    ["XM satellite radio receiver -inc: 90 day trial subscription", "625-amp maintenance-free battery", "Body color sill extension"]

## transmission()

Returns a vehicle transmission string

## Examples
    iex> Faker.Vehicle.En.transmission()
    "CVT"
    iex> Faker.Vehicle.En.transmission()
    "Automatic"
    iex> Faker.Vehicle.En.transmission()
    "Manual"
    iex> Faker.Vehicle.En.transmission()
    "Automanual"