DROP TABLE IF EXISTS pedigree;
DROP TABLE IF EXISTS breed_registry;


-- A simple table for recording a breed registry of animals that are related
-- to each other.  The table isn't specific to a particular kind of animal
-- (e.g. horse, dog, cat, ...), but in general all animals in the database
-- would be of the same kind.
CREATE TABLE breed_registry (
    -- Unique ID assigned to each animal in the registry.
    animal_id  INTEGER AUTO_INCREMENT PRIMARY KEY,

    -- The date that the animal was born.
    birth_date DATE NOT NULL,

    -- The sex of the animal, 'M' for male and 'F' for female.
    sex CHAR(1) NOT NULL,

    -- The unique name under which the animal is registered.  This name is
    -- usually long and fancy, and therefore not what the animal actually
    -- recognizes as its name.
    registered_name VARCHAR(200) NOT NULL UNIQUE,

    -- The (potentially non-unique) "pet name" (a.k.a. the "stable name" for
    -- horses, or the "call name" for dogs) that the animal is actually
    -- called by.
    pet_name VARCHAR(50) NOT NULL,

    -- The animal's breed.
    breed VARCHAR(200) NOT NULL,

    -- The animal's coloration.
    coloration VARCHAR(200) NOT NULL,

    -- Other general notes about the animal.
    notes VARCHAR(10000),

    -- If known, this is the ID of the animal's male parent.
    -- It may also be NULL if the male parent is unknown.
    sire_id INTEGER REFERENCES breed_registry (animal_id),

    -- If known, this is the ID of the animal's female parent.
    -- It may also be NULL if the female parent is unknown.
    dam_id INTEGER REFERENCES breed_registry (animal_id)
);


-- This table is used to generate the pedigree of a particular animal.
-- It is populated by the stored procedure sp_make_pedigree.  When the
-- procedure runs, it will clear this table, and then put in a row for the
-- animal itself, plus a row for every known ancestor of the animal back to
-- a certain number of generations.  Each row also includes a "relationship"
-- value, indicating how the animal in the row is related to the animal
-- being pedigreed.
CREATE TABLE pedigree (
    -- The ID of an animal that appears in a particular animal's pedigree.
    animal_id INTEGER NOT NULL REFERENCES breed_registry (animal_id),

    -- The relationship of this animal to the animal being pedigreed.  This
    -- value specifies the path from the animal being pedigreed, to the
    -- animal in this particular row.
    --
    -- * The animal being pedigreed will have the string 'A' for this value.
    --
    -- * The sire (father) of the animal being pedigreed will have the string
    --   'A.S' (animal's sire).
    --
    -- * The dam (mother) of the animal being pedigreed will have the string
    --   'A.D' (animal's dam).
    --
    -- * The sire's sire will have the string 'A.S.S' (animal's sire's sire).
    --
    -- * ...and so forth.
    --
    relationship VARCHAR(200) NOT NULL UNIQUE
);
