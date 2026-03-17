# BMW Parts Catalog

A full-stack BMW OEM parts catalog with NHTSA VIN decoding, exploded part diagrams, OE numbers,
and Bulgarian supplier pricing.

## Tech Stack

| Layer        | Technology                          |
|--------------|-------------------------------------|
| Backend      | Java 17 + Spring Boot 3.2           |
| Persistence  | Spring Data JPA + MySQL 8           |
| Templates    | Thymeleaf                           |
| Frontend     | Vanilla HTML5 / CSS3 / JavaScript   |
| External API | NHTSA vPIC (VIN decode)             |

---

## Project Structure

```
bmw-parts/
├── pom.xml
├── sql/
│   └── schema.sql                         ← DB schema + seed data
└── src/main/
    ├── java/com/bmwparts/
    │   ├── BmwPartsApplication.java
    │   ├── AppConfig.java
    │   ├── controller/
    │   │   ├── MainController.java         ← Page routes
    │   │   └── ApiController.java          ← REST API (VIN JSON)
    │   ├── service/
    │   │   ├── VinDecodeService.java       ← NHTSA API integration
    │   │   └── CatalogService.java         ← Parts catalog logic
    │   ├── model/
    │   │   ├── PartGroup.java
    │   │   ├── ComponentGroup.java
    │   │   ├── Part.java
    │   │   └── PartPrice.java
    │   ├── repository/
    │   │   ├── PartGroupRepository.java
    │   │   └── ComponentGroupRepository.java
    │   └── dto/
    │       ├── VehicleInfo.java
    │       └── NhtsaResponse.java
    └── resources/
        ├── application.properties
        ├── templates/
        │   ├── index.html                  ← VIN entry home page
        │   ├── groups.html                 ← Part system groups
        │   ├── components.html             ← Component list for a group
        │   └── part-detail.html            ← Exploded diagram + parts list
        └── static/
            ├── css/main.css
            └── js/
                ├── main.js                 ← General interactivity
                └── diagram.js              ← SVG diagram renderer
```

---

## Setup

### 1. Prerequisites

- Java 17+
- Maven 3.8+
- MySQL 8.0+

### 2. Database

```bash
mysql -u root -p < sql/schema.sql
```

This creates the `bmw_parts` database, all tables, and inserts seed data for:
- 8 part groups (Engine, Transmission, Suspension, Brakes, Cooling, Electrical, Exhaust, Fuel)
- 20+ component groups with descriptions
- Full parts list for **Mechanical Clutch** (14 parts), **Timing Chain Kit**, **Brake Disc**, and **Water Pump**
- Brand pricing with Bulgarian supplier links (autodoc.bg)

### 3. Configure database credentials

Edit `src/main/resources/application.properties`:

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/bmw_parts?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
spring.datasource.username=root
spring.datasource.password=YOUR_PASSWORD
```

### 4. Run the application

```bash
cd bmw-parts
mvn spring-boot:run
```

Open browser at: **http://localhost:8080**

---

## Application Flow

```
[Home / VIN Entry]
       ↓ POST /decode (NHTSA API validates VIN + confirms BMW)
[Part Groups Page]    ← 8 system categories displayed as cards
       ↓ Click a group card
[Component List]      ← Component cards showing diagram previews
       ↓ Click a component
[Part Detail Page]
  ├── Interactive SVG exploded diagram (hover to see part name + OE)
  ├── Click diagram part → highlights table row
  ├── Parts table:
  │     #  | Part Name | OE Number | Brand | Price Range (лв.) | BG Supplier Link
  │    ...
  └── Back navigation
```

---

## Key Features

### NHTSA VIN Decoding
- Calls `https://vpic.nhtsa.dot.gov/api/vehicles/decodevin/{vin}?format=json`
- Validates VIN is exactly 17 characters
- Verifies vehicle is a **BMW** — shows error for other makes
- Extracts: Make, Model, Year, Series, Engine, Transmission, Body Class, Fuel Type, Plant Country

### Interactive Exploded Diagram
- SVG rendered dynamically in `diagram.js` from database parts data
- Each part numbered with a circle badge matching the parts table
- Hover tooltip shows part name + OE number
- Click legend item or table row → highlights corresponding SVG shape

### Parts Table
- Numbered parts (matching diagram)
- OE (BMW original equipment) part number with one-click copy
- Per-brand pricing rows (LuK, Sachs, Valeo, Brembo, ATE, Bosch, etc.)
- Price range in Bulgarian Lev (лв.)
- Direct link to Bulgarian supplier (autodoc.bg)

---

## Adding More Parts Data

Simply insert into the database tables. Example — add a part for the clutch:

```sql
USE bmw_parts;

-- Add a new part to Mechanical Clutch (component_group_id = 1)
INSERT INTO parts (component_group_id, diagram_number, name, oe_number, description)
VALUES (1, 15, 'Clutch Alignment Tool', '83302211243', 'Plastic alignment mandrel for clutch fitting');

-- Add prices for that part
INSERT INTO part_prices (part_id, brand, price_min, price_max, shop_url, shop_name)
VALUES
  (LAST_INSERT_ID(), 'BMW Original', 25.00, 35.00, 'https://www.autodoc.bg/', 'autodoc.bg');
```

---

## REST API

| Endpoint          | Method | Description                 |
|-------------------|--------|-----------------------------|
| `/`               | GET    | Home / VIN entry page       |
| `/decode`         | POST   | Process VIN, redirect       |
| `/groups`         | GET    | All part groups              |
| `/group/{code}`   | GET    | Components in a group        |
| `/component/{code}` | GET  | Part detail + diagram        |
| `/api/vin/{vin}`  | GET    | JSON VIN decode response     |

---

## Extending with Real Diagrams

To replace the generated SVG diagram with a real image:

1. Add your image to `src/main/resources/static/images/diagrams/`
2. Update the `diagram_path` column in `component_groups` table
3. In `part-detail.html`, add an `<img>` tag using `th:src="${component.diagramPath}"`

The `diagram.js` script overlays numbered hotspot markers on top of real diagram images by positioning `<div>` elements absolutely over the image container.
