# Faker.Vehicle

Functions for generating Vehicle related data

## model/1

Returns a vehicle model string belonging to the given make

## Examples
    iex> Faker.Vehicle.model("Ford")
    "Focus"
    iex> Faker.Vehicle.model("BMW")
    "X5"
    iex> Faker.Vehicle.model("Audi")
    "A4"
    iex> Faker.Vehicle.model("Toyota")
    "Corolla"

## options/1

Returns a list of vehicle options()

## Examples
    iex> Faker.Vehicle.options
    ["Power Steering", "A/C: Front", "Keyless Entry", "AM/FM Stereo", "Power Steering", "Antilock Brakes", "8-Track Player", "Leather Interior"]
    iex> Faker.Vehicle.options
    ["MP3 (Multi Disc)", "A/C: Rear", "Fog Lights", "Power Windows", "Cruise Control", "Premium Sound", "A/C: Front"]
    iex> Faker.Vehicle.options
    ["Tinted Glass", "MP3 (Single Disc)", "CD (Multi Disc)"]
    iex> Faker.Vehicle.options
    ["Fog Lights", "Rear Window Wiper", "MP3 (Multi Disc)", "Navigation", "Airbag: Side", "Rear Window Defroster", "Premium Sound"]

## standard_specs/0

Returns a list of vehicle standard specs

## Examples
    iex> Faker.Vehicle.standard_specs()
    ["20\" x 9.0\" front & 20\" x 10.0\" rear aluminum wheels", "Deluxe insulation group", "Torsion beam rear suspension w/stabilizer bar", "High performance suspension", "200mm front axle", "Traveler/mini trip computer", "P235/50R18 all-season tires", "Front door tinted glass"]
    iex> Faker.Vehicle.standard_specs()
    ["625-amp maintenance-free battery", "Body color sill extension", "Cargo compartment cover", "Dana 44/226mm rear axle", "Tachometer", "Leather-wrapped parking brake handle", "Side-impact door beams"]
    iex> Faker.Vehicle.standard_specs()
    ["Tilt steering column", "Luxury front & rear floor mats w/logo", "HomeLink universal transceiver"]
    iex> Faker.Vehicle.standard_specs()
    ["Multi-reflector halogen headlamps", "Multi-info display -inc: driving range, average MPG, current MPG, average speed, outside temp, elapsed time, maintenance & diagnostic messages", "Zone body construction -inc: front/rear crumple zones, hood deformation point", "60/40 split fold-down rear seat w/outboard adjustable headrests", "Trim-panel-mounted storage net", "Front side-impact airbags", "Front/rear spot-lamp illumination"]

## standard_specs/1

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

## vin/0

Returns a vehicle identification number string

## Examples
    iex> Faker.Vehicle.vin()
    "1C68203VCV0360337"
    iex> Faker.Vehicle.vin()
    "5190V7FL8YX113016"
    iex> Faker.Vehicle.vin()
    "4RSE9035H9JA97940"
    iex> Faker.Vehicle.vin()
    "59E4A13G890C97377"