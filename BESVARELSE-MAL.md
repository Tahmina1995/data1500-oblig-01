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

LSM-tree (Log-Structured Merge-Tree)

**Begrunnelse:**

**Skrive-operasjoner:**

LSM-tree er godt egnet for mange skrive-operasjoner fordi nye poster først skrives sekvensielt til en logg og/eller en minnestruktur (memtable). Når memtable blir full, flushes data som en sortert fil (SSTable) til disk. Sekvensielle skriver er raske på disk, og strukturen unngår mange tilfeldige (random) disk-skriver som er dyre.

**Lese-operasjoner:**

Ved sjeldne lese-operasjoner kan LSM-tree likevel fungere bra ved hjelp av indekser i SSTables og en Bloom filter som raskt kan avvise filer som ikke inneholder nøkkelen. Hvis man må lese, kan systemet søke i memtable først og deretter i et begrenset antall SSTables. Siden lesing skjer sjelden i dette caset (logging), er det akseptabelt at lesing kan være litt dyrere enn i en struktur optimalisert for lesing.

---

### Oppgave 4.4: Validering i flerlags-systemer

**Hvor bør validering gjøres:**

Validering bør gjøres i flere lag: i nettleseren for rask tilbakemelding til brukeren, i applikasjonslaget for forretningsregler og sikkerhet, og i databasen som siste “sikkerhetsnett” for dataintegritet (constraints). Hvis man bare validerer ett sted kan validering omgås eller feile, og dårlige data kan likevel ende i databasen.

**Validering i nettleseren:**

**Fordeler:** Gir rask tilbakemelding (bedre brukeropplevelse), kan redusere unødvendige kall til serveren, og fanger enkle feil tidlig (f.eks. tomme felter, format på e-post).
**Ulemper:** Kan omgås (bruker kan slå av JavaScript eller sende request direkte), derfor kan man ikke stole på dette laget alene. Regler i nettleseren kan også bli utdaterte hvis de ikke holdes i sync med server.

**Validering i applikasjonslaget:**

**Fordeler:** Dette laget kan håndheve forretningsregler og sikkerhet (autorisering), og validering kan være mer fleksibel (kryssfelt-regler, sjekk mot eksisterende data, rate limits). Det er også enklere å logge og gi gode feilmeldinger til klienten.
**Ulemper:** Hvis flere tjenester/klienter skriver til samme database, må man sikre at alle implementerer reglene riktig. Validering her alene gir ikke en absolutt garanti, fordi feil i applikasjonskode eller bypass kan slippe gjennom uten database-constraints.

**Validering i databasen:**

**Fordeler:** Databasen er siste linje av forsvar og sikrer dataintegritet uansett hvilken klient som skriver (constraints som NOT NULL, CHECK, FOREIGN KEY, UNIQUE). Dette hindrer at ugyldige data lagres selv om applikasjonen har feil eller validering omgås.
**Ulemper:** Databasen bør ikke inneholde for mye kompleks forretningslogikk (kan bli vanskeligere å vedlikeholde og teste). Feilmeldinger kan også være mindre “brukervennlige”, og avansert validering i databasen kan gi ekstra kompleksitet/ytelses-kostnad.



**Konklusjon:**

Validering bør gjøres i flere lag. Nettleseren brukes for rask og brukervennlig feedback, applikasjonslaget håndhever forretningsregler og sikkerhet, og databasen sikrer integritet med constraints slik at ugyldige data ikke kan lagres. Sammen gir dette både god brukeropplevelse og robust sikkerhet/datakvalitet.

---

### Oppgave 4.5: Refleksjon over læringsutbytte

**Hva har du lært så langt i emnet:**

Jeg har lært grunnleggende prinsipper i databasedesign og relasjonsmodellen, som entiteter/attributter, primær- og fremmednøkler, kardinalitet og normalisering (1NF–3NF). Jeg har også fått bedre forståelse for hvordan constraints (NOT NULL, CHECK, UNIQUE, FK) sikrer datakvalitet, og hvordan SQL brukes til å opprette tabeller, sette rettigheter og skrive spørringer. I tillegg har jeg lært mer om ytelse, spesielt hvorfor indekser er viktige og hvordan datastrukturer som B+-trær og LSM-trær påvirker lese- og skriveytelse.

**Hvordan har denne oppgaven bidratt til å oppnå læringsmålene:**

Denne oppgaven har bidratt til læringsmålene i emnet ved at jeg måtte jobbe gjennom hele kjeden fra modellering til implementering og bruk. Jeg har brukt teori om relasjonsmodellen, ER-modellering, nøkler og normalisering for å designe et godt skjema. Videre har jeg implementert databasen i PostgreSQL med riktige datatyper og constraints for å sikre dataintegritet. Jeg har også øvd på SQL i praksis (DDL/DML og spørringer), samt forstått hvordan indekser og datastrukturer påvirker ytelse. Til slutt har oppgaven gitt erfaring med tilgangskontroll (roller, GRANT og VIEW) og hvordan man kan begrense tilgang til data i et reelt system. Dette samsvarer med læringsmålene om å kunne designe, implementere og analysere relasjonsdatabaser med fokus på integritet, sikkerhet og ytelse.



**Hva var mest utfordrende:**

Det mest utfordrende var å oversette case-beskrivelsen til en korrekt og enkel datamodell uten å ta med unødvendige entiteter, og samtidig velge riktige nøkler, relasjoner og constraints. Det var også krevende å få alt til å fungere i praksis med Docker/PostgreSQL (init-script, testdata og verifisering). I tillegg var tilgangskontroll (roller/GRANT og VIEW) litt utfordrende fordi det krevde at jeg forstod både SQL og hvordan databasen faktisk håndhever rettigheter.

**Hva har du lært om databasedesign:**

Jeg har lært at databasedesign handler om å modellere data slik at man unngår redundans og inkonsistens, og at normalisering (1NF–3NF) hjelper med dette. Jeg har også lært hvor viktig det er å velge gode primær- og fremmednøkler, slik at relasjoner mellom tabeller blir korrekte og enkle å bruke. I tillegg har jeg sett at constraints (NOT NULL, CHECK, UNIQUE, FK) fungerer som et “sikkerhetsnett” som beskytter datakvaliteten. Til slutt har jeg lært at man må tenke på sikkerhet og ytelse tidlig, f.eks. med tilgangskontroll (roller/GRANT/VIEW) og indekser.

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
