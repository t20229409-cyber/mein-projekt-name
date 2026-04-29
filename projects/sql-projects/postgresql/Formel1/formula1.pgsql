CREATE TABLE IF NOT EXISTS circuits (
    circuitId SERIAL PRIMARY KEY,
    circuitRef VARCHAR(100) NULL,
    name VARCHAR(100) NULL,
    location VARCHAR(100) NULL,
    country VARCHAR(100) NULL,
    lat DECIMAL(10, 6) NULL,
    lng DECIMAL(10, 6) NULL,
    alt INT NULL,
    url TEXT NULL
);

CREATE TABLE IF NOT EXISTS races (
    raceId SERIAL PRIMARY KEY,
    year INT NULL,
    round INT NULL,
    circuitId INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    date DATE NOT NULL,
    time TIME NULL,
    url TEXT NULL
);

CREATE TABLE IF NOT EXISTS drivers (
    driverId SERIAL PRIMARY KEY,
    driverRef VARCHAR(100) NULL,
    number VARCHAR(50) NULL,
    code VARCHAR(50) NULL,
    forename VARCHAR(100) NOT NULL,
    surname VARCHAR(100) NOT NULL,
    dob VARCHAR(100) NULL,
    nationality VARCHAR(100) NULL,
    url TEXT null
);

CREATE TABLE IF NOT EXISTS results (
    resultId VARCHAR(25) PRIMARY KEY,
    raceId INT NOT NULL,
    driverId INT NOT NULL,
    constructorId INT,
    number INT,
    grid INT,
    position INT,
    positionText VARCHAR(10),
    positionOrder INT,
    points NUMERIC,
    laps INT,
    time VARCHAR(50),
    milliseconds INT,
    fastestLap VARCHAR(100),
    rank INT,
    fastestLapTime VARCHAR(50),
    fastestLapSpeed NUMERIC,
    statusId INT
);

DO $$
    DECLARE
        path_ TEXT;
        inhalt TEXT;
        full_path TEXT;
        dataList TEXT[] := ARRAY[
            'circuits',
            'races',
            'drivers',
            'results'
        ];
    BEGIN
        path_ := 'C:/Users/User/Documents/Modul 2/05 - Azure SQL/Tag 6/mein-projekt-name/projects/sql-projects/postgresql/Formel1/data/';

        FOREACH inhalt IN ARRAY dataList LOOP
            full_path := path_ || inhalt || '.csv';
            
            EXECUTE format(
                $f$
                COPY %I FROM %L WITH (
                    FORMAT csv,
                    HEADER true,
                    DELIMITER ',',
                    QUOTE '"',
                    NULL '',
                    ENCODING 'UTF8'
                )
                $f$,
                inhalt,
                full_path
            );
            RAISE NOTICE 'Importiert: %', full_path;
        END LOOP;
    END;
$$ LANGUAGE plpgsql;


SELECT * FROM results 
WHERE raceId NOT IN (SELECT raceId FROM races);

-- Lösche alle Ergebnisse, für die kein Rennen existiert
DELETE FROM results WHERE raceId NOT IN (SELECT raceId FROM races);

-- Lösche alle Ergebnisse, für die kein Fahrer existiert
DELETE FROM results WHERE driverId NOT IN (SELECT driverId FROM drivers);

ALTER TABLE races
ADD CONSTRAINT FK_races_circuitId_ID
FOREIGN KEY (circuitId) REFERENCES circuits(circuitId);

ALTER TABLE results
ADD CONSTRAINT FK_results_raceId_ID
FOREIGN KEY(raceId) REFERENCES races(raceId);

ALTER TABLE results
ADD CONSTRAINT FK_results_driverId_ID
FOREIGN KEY(driverId) REFERENCES drivers(driverId);