# Besvarelse - Refleksjon og Analyse

**Student:** [Tahmina Nargis Noori]

**Studentnummer:** [tanoo6678]

**Dato:** [Innleveringsdato]

---

## Del 1: Datamodellering

### Oppgave 1.1: Entiteter og attributter

**Identifiserte entiteter:**
**Begrunnelse (kort):**
Systemet består av sykkelstasjoner der sykler kan leies og leveres. Hver sykkel har unik ID og er låst med en lås ved en stasjon. Kunder registrerer seg og kan gjennomføre flere utleier. For hver utleie må starttidspunkt, eventuelt sluttidspunkt og leiebeløp lagres.


- Station (sykkelstasjon)
- Lock (lås)
- Bike (sykkel)
- Customer (kunde)
- Rental (utleie)



**Attributter for hver entitet:**

**Station (sykkelstasjon)**
- station_id
- name
- location

**Lock (lås)**
- lock_id
- station_id

**Bike (sykkel)**
- bike_id
- station_id (NULL når sykkelen er utleid)
- lock_id (NULL når sykkelen er utleid)

**Customer (kunde)**
- customer_id
- mobile_number
- email
- first_name
- last_name

**Rental (utleie)**
- rental_id
- customer_id
- bike_id
- start_time (utlevert)
- end_time (innlevert, NULL til sykkelen leveres)
- amount (leiebeløp)



### Oppgave 1.2: Datatyper og `CHECK`-constraints

**Valgte datatyper og begrunnelser:**

Jeg har valgt datatyper i PostgreSQL som passer til innholdet og gir god dataintegritet:

**Customer (kunde)**
- customer_id: BIGSERIAL – surrogatnøkkel, enkel og effektiv.
- mobile_number: VARCHAR(20) – telefonnummer kan ha landskode (+) og varierer i lengde.
- email: VARCHAR(320) – tilstrekkelig lengde for e-postadresser.
- first_name: VARCHAR(100) – navn er kort tekst.
- last_name: VARCHAR(100) – navn er kort tekst.

**Station (sykkelstasjon)**
- station_id: BIGSERIAL – surrogatnøkkel.
- name: VARCHAR(120) – kort navn.
- location: TEXT – kan være adresse/beskrivelse (ukjent format i case).

**Lock (lås)**
- lock_id: BIGSERIAL – surrogatnøkkel.
- station_id: BIGINT – peker til station.

**Bike (sykkel)**
- bike_id: BIGSERIAL – unik ID per sykkel.
- station_id: BIGINT NULL – NULL når sykkelen er utleid (i følge hint).
- lock_id: BIGINT NULL – NULL når sykkelen er utleid (i følge hint).

**Rental (utleie)**
- rental_id: BIGSERIAL – surrogatnøkkel.
- customer_id: BIGINT – peker til kunde.
- bike_id: BIGINT – peker til sykkel.
- start_time: TIMESTAMPTZ – tidspunkt med tidssone.
- end_time: TIMESTAMPTZ NULL – NULL til sykkelen leveres.
- amount: NUMERIC(10,2) – pengebeløp må lagres nøyaktig.

**`CHECK`-constraints:**

Jeg har lagt til CHECK-constraints der det gir mening for å sikre gyldige verdier:

**Customer**
- mobile_number: bare tall og evt. + i starten, og rimelig lengde  
  CHECK (mobile_number ~ '^\+?[0-9]{8,20}$')

- email: enkel validering av e-postformat  
  CHECK (email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$')

- first_name / last_name: ikke tom streng  
  CHECK (length(trim(first_name)) > 0)  
  CHECK (length(trim(last_name)) > 0)

**Station**
- name: ikke tom streng  
  CHECK (length(trim(name)) > 0)

**Rental**
- end_time må være NULL (pågående utleie) eller etter/lik start_time  
  CHECK (end_time IS NULL OR end_time >= start_time)

- amount kan ikke være negativt  
  CHECK (amount >= 0)



**ER-diagram:**

```mermaid

erDiagram
  STATION {
    BIGINT station_id
    VARCHAR name
    TEXT location
  }

  LOCK {
    BIGINT lock_id
    BIGINT station_id
  }

  BIKE {
    BIGINT bike_id
    BIGINT station_id "NULL when rented"
    BIGINT lock_id "NULL when rented"
  }

  CUSTOMER {
    BIGINT customer_id
    VARCHAR mobile_number
    VARCHAR email
    VARCHAR first_name
    VARCHAR last_name
  }

  RENTAL {
    BIGINT rental_id
    BIGINT customer_id
    BIGINT bike_id
    TIMESTAMPTZ start_time
    TIMESTAMPTZ end_time "NULL when ongoing"
    NUMERIC amount
  }

  STATION ||--o{ LOCK : has
  STATION ||--o{ BIKE : parks
  LOCK ||--o| BIKE : secures
  CUSTOMER ||--o{ RENTAL : makes
  BIKE ||--o{ RENTAL : used_in
```



### Oppgave 1.3: Primærnøkler

**Valgte primærnøkler og begrunnelser:**

Jeg bruker en primærnøkkel per entitet for å identifisere rader unikt:

- **Station:** station_id som primærnøkkel (surrogatnøkkel).
- **Lock:** lock_id som primærnøkkel (surrogatnøkkel).
- **Bike:** bike_id som primærnøkkel (unik ID per sykkel).
- **Customer:** customer_id som primærnøkkel (surrogatnøkkel).
- **Rental:** rental_id som primærnøkkel (surrogatnøkkel), fordi en kunde kan leie samme sykkel flere ganger og vi trenger en unik identifikator per utleie.




**Naturlige vs. surrogatnøkler:**

Jeg har hovedsakelig valgt **surrogatnøkler** (BIGSERIAL) som primærnøkler fordi de er stabile, korte og effektive, og de endrer seg ikke selv om forretningsdata endres.

Det finnes også **naturlige kandidatnøkler**, spesielt for Customer:
- `email` og/eller `mobile_number` kan ofte være unike.
Jeg bruker dem ikke som primærnøkkel fordi de kan endres (kunden kan bytte e-post/telefonnummer) og fordi format/validering kan variere. Derfor er det bedre å bruke `customer_id` som PK, og heller sette **UNIQUE** på `email` og/eller `mobile_number` senere.



**Oppdatert ER-diagram:**

```mermaid
erDiagram
  STATION {
    BIGINT station_id PK
    VARCHAR name
    TEXT location
  }

  LOCK {
    BIGINT lock_id PK
    BIGINT station_id
  }

  BIKE {
    BIGINT bike_id PK
    BIGINT station_id "NULL when rented"
    BIGINT lock_id "NULL when rented"
  }

  CUSTOMER {
    BIGINT customer_id PK
    VARCHAR mobile_number
    VARCHAR email
    VARCHAR first_name
    VARCHAR last_name
  }

  RENTAL {
    BIGINT rental_id PK
    BIGINT customer_id
    BIGINT bike_id
    TIMESTAMPTZ start_time
    TIMESTAMPTZ end_time "NULL when ongoing"
    NUMERIC amount
  }

  STATION ||--o{ LOCK : has
  STATION ||--o{ BIKE : parks
  LOCK ||--o| BIKE : secures
  CUSTOMER ||--o{ RENTAL : makes
  BIKE ||--o{ RENTAL : used_in
  ```


### Oppgave 1.4: Forhold og fremmednøkler

**Identifiserte forhold og kardinalitet:**

- **Station → Lock:** 1-til-mange  
  En stasjon kan ha mange låser, og hver lås tilhører nøyaktig en stasjon.

- **Station → Bike:** 1-til-mange  
  En stasjon kan ha mange sykler parkert. En sykkel er parkert ved maks en stasjon, men kan også være utleid (da er `station_id` NULL).

- **Lock → Bike:** 1-til-0/1  
  En lås kan være tilknyttet maks en sykkel om gangen. En sykkel som står parkert bruker én lås, men når sykkelen er utleid er `lock_id` NULL.

- **Customer → Rental:** 1-til-mange  
  En kunde kan gjennomføre mange utleier, og hver utleie tilhører én kunde.

- **Bike → Rental:** 1-til-mange  
  En sykkel kan bli leid mange ganger over tid, og hver utleie gjelder én sykkel.



**Fremmednøkler:**

**Fremmednøkler (FK) og hvordan de implementerer forholdene:**

- **LOCK.station_id → STATION.station_id**  
  Implementerer forholdet Station (1) → Lock (mange). Hver lås må høre til en stasjon.

- **BIKE.station_id → STATION.station_id** (kan være NULL)  
  Implementerer forholdet Station (1) → Bike (mange). Når sykkelen er utleid settes `station_id` til NULL.

- **BIKE.lock_id → LOCK.lock_id** (kan være NULL)  
  Implementerer forholdet Lock (1) → Bike (0/1). Når sykkelen er utleid settes `lock_id` til NULL.

- **RENTAL.customer_id → CUSTOMER.customer_id**  
  Implementerer forholdet Customer (1) → Rental (mange). Hver utleie tilhører en kunde.

- **RENTAL.bike_id → BIKE.bike_id**  
  Implementerer forholdet Bike (1) → Rental (mange). Hver utleie gjelder en bestemt sykkel.

**Oppdatert ER-diagram:**
 
 ```mermaid

 erDiagram
  STATION {
    BIGINT station_id PK
    VARCHAR name
    TEXT location
  }

  LOCK {
    BIGINT lock_id PK
    BIGINT station_id FK
  }

  BIKE {
    BIGINT bike_id PK
    BIGINT station_id FK "NULL when rented"
    BIGINT lock_id FK "NULL when rented"
  }

  CUSTOMER {
    BIGINT customer_id PK
    VARCHAR mobile_number
    VARCHAR email
    VARCHAR first_name
    VARCHAR last_name
  }

  RENTAL {
    BIGINT rental_id PK
    BIGINT customer_id FK
    BIGINT bike_id FK
    TIMESTAMPTZ start_time
    TIMESTAMPTZ end_time "NULL when ongoing"
    NUMERIC amount
  }

  STATION ||--o{ LOCK : has
  STATION ||--o{ BIKE : parks
  LOCK ||--o| BIKE : secures
  CUSTOMER ||--o{ RENTAL : makes
  BIKE ||--o{ RENTAL : used_in
  ```


### Oppgave 1.5: Normalisering

**Vurdering av 1. normalform (1NF):**

Datamodellen tilfredsstiller 1NF fordi alle tabeller har atomiske attributter (en verdi per felt), og det finnes ingen repeterende grupper eller lister i en kolonne. For eksempel lagres e-post og mobilnummer som egne felt, og en utleie (Rental) er en rad per utleiehendelse.




**Vurdering av 2. normalform (2NF):**

Datamodellen tilfredsstiller 2NF fordi alle tabeller bruker enkolonne-primærnøkler (surrogatnøkler), og dermed kan ingen ikke-nøkkelattributter være delvis avhengige av en sammensatt nøkkel. Alle ikke-nøkkelattributter i hver tabell avhenger av hele primærnøkkelen (f.eks. i RENTAL avhenger start_time, end_time og amount av rental_id).




**Vurdering av 3. normalform (3NF):**

Datamodellen tilfredsstiller 3NF fordi alle ikke-nøkkelattributter avhenger direkte av primærnøkkelen, og det finnes ingen transitive avhengigheter (ikke-nøkkel → ikke-nøkkel) innenfor samme tabell. 
For eksempel ligger kundeinformasjon (navn, e-post, mobil) kun i CUSTOMER-tabellen og ikke i RENTAL, og stasjonsinformasjon ligger kun i STATION og ikke i BIKE/LOCK. Dermed unngås redundans og oppdateringsanomalier.


**Eventuelle justeringer:**
 Modellen var allerede på 3NF basert på valgte entiteter og attributter, så det var ikke nødvendig med større justeringer. Eventuelle unike forretningsregler (som unikhet på e-post/mobil) kan håndteres med UNIQUE-constraints, men påvirker ikke normalformene.

---

## Del 2: Database-implementering

### Oppgave 2.1: SQL-skript for database-initialisering

**Plassering av SQL-skript:**

SQL-skriptet er lagt i init-scripts/01-init-database.sql.


**Antall testdata:**

- Kunder: [3]
- Sykler: [5]
- Sykkelstasjoner: [3]
- Låser (bike_lock): [7]
- Utleier: [2]

---

### Oppgave 2.2: Kjøre initialiseringsskriptet

**Dokumentasjon av vellykket kjøring:**

Jeg kjørte `docker compose up -d --build` uten feil, og databasen startet.

Jeg verifiserte at containeren kjører med `docker ps`:

[ [+] up 1/1
✔ Container data1500-postgres Created
CONTAINER ID   IMAGE               COMMAND                  CREATED          STATUS                    PORTS                     NAMES
9f1e3f892c7d   postgres:15-alpine   "docker-entrypoint.s…"   32 seconds ago   Up 32 seconds (healthy)   0.0.0.0:5432->5432/tcp    data1500-postgres]





**Spørring mot systemkatalogen:**

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_type = 'BASE TABLE'
ORDER BY table_name;
```

**Resultat:**

```
bike
bike_lock
customer
rental
station

```

---

## Del 3: Tilgangskontroll

### Oppgave 3.1: Roller og brukere

**SQL for å opprette rolle:**

```sql
 CREATE ROLE kunde NOLOGIN;
```

**SQL for å opprette bruker:**

```sql
CREATE USER kunde_1 WITH PASSWORD 'kunde123';
```

**SQL for å tildele rettigheter:**

```sql
-- gjør bruker til medlem av rollen
GRANT kunde TO kunde_1;

-- gi rollen tilgang til databasen
GRANT CONNECT ON DATABASE oblig01 TO kunde;

-- gi tilgang til schema
GRANT USAGE ON SCHEMA public TO kunde;

-- gi lesetilgang til alle tabeller (nåværende)
GRANT SELECT ON ALL TABLES IN SCHEMA public TO kunde;

-- sørg for at nye tabeller også får SELECT automatisk
ALTER DEFAULT PRIVILEGES FOR USER admin IN SCHEMA public
GRANT SELECT ON TABLES TO kunde;
```

---

### Oppgave 3.2: Begrenset visning for kunder

**SQL for VIEW:**

```sql
-- Mapper database-bruker til customer_id
CREATE TABLE IF NOT EXISTS app_user (
  db_username TEXT PRIMARY KEY,
  customer_id BIGINT NOT NULL REFERENCES customer(customer_id)
);

-- Eksempel: koble kunde_1 til customer_id = 1
INSERT INTO app_user (db_username, customer_id)
VALUES ('kunde_1', 1)
ON CONFLICT (db_username) DO NOTHING;

-- View: viser bare utleier for innlogget bruker
CREATE OR REPLACE VIEW v_mine_utleier AS
SELECT r.rental_id,
       r.bike_id,
       r.start_time,
       r.end_time,
       r.amount
FROM rental r
JOIN app_user au ON au.customer_id = r.customer_id
WHERE au.db_username = CURRENT_USER;

-- Gi kunder tilgang til viewet (ikke direkte til tabellen)
GRANT SELECT ON v_mine_utleier TO kunde;
```

**Ulempe med VIEW vs. POLICIES:**

 En ulempe med å bruke VIEW for autorisasjon er at det ikke gir like finmasket og robust tilgangskontroll som POLICIES (Row level security). Med VIEW må man ofte lage flere views og passe på at brukere ikke får dirikte tilgang til underliggende tabeller. POLICIES håndheves derimot dirikte i databasen på rad-nivå for alle spørringer mot tabllen, og er vanskeligere å omgå ved en feilkonfigurasjon. 

---

## Del 4: Analyse og Refleksjon

### Oppgave 4.1: Lagringskapasitet

**Gitte tall for utleierate:**

- Høysesong (mai-september): 20000 utleier/måned
- Mellomsesong (mars, april, oktober, november): 5000 utleier/måned
- Lavsesong (desember-februar): 500 utleier/måned

**Totalt antall utleier per år:**

  Høysesong: 5 * 20000 = 100000
  Mellomsesong: 4 * 5000 = 20000
  Lavsesong: 3 * 500 = 1500
  Totalt per år: 100000 + 20000 + 1500 = 121500 utleier 



**Estimat for lagringskapasitet:**

Jeg estimerer lagringsbehov ved å ta (omtrent) antall bytes per rad * antall rader.

**RENTAL (størst vekst):**
Kolonner: 3*BIGINT (24B) + 2*TIMESTAMPTZ (16B) + NUMERIC(10,2) (~16B) ≈ 56B data.
Med overhead per rad (header/alignment) antar jeg totalt ca. 100B per rad.

Antall utleier første år: 121500
=> 121500 * 100B ≈ 12 150 000B ≈ ca. 12 MB for RENTAL.

**Andre tabeller (grovt):**
STATION, BIKE_LOCK, BIKE og CUSTOMER forventes å ha langt færre rader enn RENTAL det første året og vil typisk være i størrelsesorden noen få MB til sammen.
Med indekser og overhead antar jeg samlet ca. 10–20 MB ekstra.

Totalt anslag første år (inkl. indekser/overhead): ca. 25–35 MB.

**Totalt for første år:**
Totalt estimat for første år: ca. 25–35 MB (inkludert indekser og overhead).
  

---

### Oppgave 4.2: Flat fil vs. relasjonsdatabase

**Analyse av CSV-filen (`data/utleier.csv`):**

**Problem 1: Redundans**

CSV-filen har mye redundans fordi kundedata, stasjonsdata og sykkelmodell-data gjentas på mange rader. 
For eksempel gjentas Ole Hansen tre ganger med samme mobilnr (+4791234567) og e-post (ole.hansen@example.com), og Kari Olsen gjentas tre ganger med samme mobilnr (+4792345678) og e-post (kari.olsen@example.com). 
Stasjoner gjentas også: “Sentrum Stasjon” med adressen “Karl Johans gate 1 Oslo” forekommer i flere rader, og det samme gjelder f.eks. “Aker Brygge Stasjon / Stranden 1 Oslo”. 
Sykkelmodell og innkjøpsdato gjentas også (f.eks. “City Bike Pro, 2023-03-15” og “Urban Cruiser, 2023-04-20”).
Dette betyr at samme fakta lagres om igjen i stedet for én gang med referanser (kunde_id, stasjon_id, osv.).

**Problem 2: Inkonsistens**

Redundans kan føre til inkonsistens fordi samme informasjon må oppdateres mange steder. 
Hvis Ole Hansen endrer e-post, må alle rader der mobilnr +4791234567 / e-post ole.hansen@example.com forekommer oppdateres. Hvis én rad blir glemt, får vi inkonsistens (noen rader med gammel e-post, andre med ny). 
Det samme gjelder stasjonsadresser: hvis “Karl Johans gate 1 Oslo” skrives litt ulikt i en rad (f.eks. “Karl Johans gt 1 Oslo”), vil databasen tro det er to ulike adresser for samme stasjon, og spørringer/rapporter kan bli feil.

**Problem 3: Oppdateringsanomalier**

- **Oppdateringsanomalier:** Endring av kundedata (f.eks. mobilnr/epost) krever oppdatering av flere rader. Risiko for feil hvis ikke alle rader oppdateres.
- **Innsettingsanomalier:** Man kan ikke enkelt legge inn en ny stasjon (navn + adresse) eller en ny kunde uten at det samtidig finnes en utleie. I en relasjonsdatabase kunne man lagt inn kunde/stasjon i egne tabeller først.
- **Sletteanomalier:** Hvis man sletter siste utleie-rad som inneholder en bestemt stasjon eller kunde, mister man all informasjon om at stasjonen/kunden finnes (fordi all info bare ligger i utleie-radene).

**Fordeler med en indeks:**

En indeks gjør spørringer mer effektive fordi DBMS kan finne rader uten å lese gjennom hele tabellen/filen (full scan). 
For eksempel, hvis man ofte søker etter utleier for en bestemt kunde (mobilnr/epost), kan en indeks på disse feltene gjøre at systemet raskt hopper direkte til relevante rader, i stedet for å lese alle utleier.
Dette reduserer antall disk-I/O og gir lavere responstid.

**Case 1: Indeks passer i RAM**

Hvis indeksen får plass i RAM, kan DBMS holde hele indeksstrukturen i minnet. Oppslag blir da raskt fordi man traverserer indeksen i RAM og kun leser de aktuelle datasidene fra disk. 
Dette gir svært god ytelse, spesielt for mange små oppslag (f.eks. “finn alle utleier for ole.hansen@example.com”).

**Case 2: Indeks passer ikke i RAM**

Hvis indeksen ikke får plass i RAM, må DBMS hente indeks-sider fra disk under oppslag, som gir flere diskaksesser og lavere ytelse. 
Når man bygger en indeks over store datamengder, kan DBMS bruke flettesortering (external merge sort): først sorteres deler (“runs”) som får plass i minnet, skrives til disk, og deretter flettes disse delene i flere runder til én sortert struktur. 
Dette gjør at man kan bygge/vedlikeholde indekser selv når data er større enn minnet.

**Datastrukturer i DBMS:**

**B+-tre-indeks:** Nøklene lagres sortert. Dette er bra for både eksakte oppslag og intervallspørringer (range), f.eks. utleier mellom to tidspunkt (utleie_tidspunkt). Bladnodene er lenket slik at man kan lese intervaller effektivt.
**Hash-indeks:** Veldig rask for eksakte oppslag (=), f.eks. på e-post eller mobilnr. Ulempen er at den ikke støtter intervallspørringer like godt, fordi hashing ikke bevarer sorteringsrekkefølge.

---

### Oppgave 4.3: Datastrukturer for logging

**Foreslått datastruktur:**

[Skriv ditt svar her - f.eks. heap-fil, LSM-tree, eller annen egnet datastruktur]

**Begrunnelse:**

**Skrive-operasjoner:**

[Skriv ditt svar her - forklar hvorfor datastrukturen er egnet for mange skrive-operasjoner]

**Lese-operasjoner:**

[Skriv ditt svar her - forklar hvordan datastrukturen håndterer sjeldne lese-operasjoner]

---

### Oppgave 4.4: Validering i flerlags-systemer

**Hvor bør validering gjøres:**

[Skriv ditt svar her - argumenter for validering i ett eller flere lag]

**Validering i nettleseren:**

[Skriv ditt svar her - diskuter fordeler og ulemper]

**Validering i applikasjonslaget:**

[Skriv ditt svar her - diskuter fordeler og ulemper]

**Validering i databasen:**

[Skriv ditt svar her - diskuter fordeler og ulemper]

**Konklusjon:**

[Skriv ditt svar her - oppsummer hvor validering bør gjøres og hvorfor]

---

### Oppgave 4.5: Refleksjon over læringsutbytte

**Hva har du lært så langt i emnet:**

[Skriv din refleksjon her - diskuter sentrale konsepter du har lært]

**Hvordan har denne oppgaven bidratt til å oppnå læringsmålene:**

[Skriv din refleksjon her - koble oppgaven til læringsmålene i emnet]

Se oversikt over læringsmålene i en PDF-fil i Canvas https://oslomet.instructure.com/courses/33293/files/folder/Plan%20v%C3%A5ren%202026?preview=4370886

**Hva var mest utfordrende:**

[Skriv din refleksjon her - diskuter hvilke deler av oppgaven som var mest krevende]

**Hva har du lært om databasedesign:**

[Skriv din refleksjon her - reflekter over prosessen med å designe en database fra bunnen av]

---

## Del 5: SQL-spørringer og Automatisk Testing

**Plassering av SQL-spørringer:**

[Bekreft at du har lagt SQL-spørringene i `test-scripts/queries.sql`]


**Eventuelle feil og rettelser:**

[Skriv ditt svar her - hvis noen tester feilet, forklar hva som var feil og hvordan du rettet det]

---

## Del 6: Bonusoppgaver (Valgfri)

### Oppgave 6.1: Trigger for lagerbeholdning

**SQL for trigger:**

```sql
[Skriv din SQL-kode for trigger her, hvis du har løst denne oppgaven]
```

**Forklaring:**

[Skriv ditt svar her - forklar hvordan triggeren fungerer]

**Testing:**

[Skriv ditt svar her - vis hvordan du har testet at triggeren fungerer som forventet]

---

### Oppgave 6.2: Presentasjon

**Lenke til presentasjon:**

[Legg inn lenke til video eller presentasjonsfiler her, hvis du har løst denne oppgaven]

**Hovedpunkter i presentasjonen:**

[Skriv ditt svar her - oppsummer de viktigste punktene du dekket i presentasjonen]

---

**Slutt på besvarelse**
