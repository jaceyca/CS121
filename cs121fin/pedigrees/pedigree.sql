-- [Problem 2a]
DROP PROCEDURE IF EXISTS sp_make_pedigree;

DELIMITER !

-- Makes an animal's pedigree tree. The input sp_animal_id is used
-- as the root, and the input generations specifies how many generations
-- back that the pedigree should contain. (generation 0 = root,
-- generation 1 = parents, etc). No animal should be its own parent.
-- Assumes that all inputs and breed-registry data are valid.
CREATE PROCEDURE sp_make_pedigree(
    IN sp_animal_id     INT,
    IN generations      INT
)

BEGIN
    -- Declaration of variables.
    -- Current generation; will be used to iterate through generations.
    DECLARE sp_generations INT;
    -- Track ancestors up to 10 generations ago.
    DECLARE sp_relationship VARCHAR(21);
    -- Concatenation of previous generations' relationships.
    DECLARE relationship_string VARCHAR(1024);
    -- Will be used to iterate through relationship_string
    DECLARE i INT;
    -- Substrings of relationship_string
    DECLARE substring VARCHAR(21);
    -- Temporary id that is checked for nullity.
    DECLARE sire_temp INT;
    -- Temp id that is checked for nullity.
    DECLARE dam_temp INT;
    
    -- Initialization of variables.
    SET sp_generations = 0;
    SET sp_relationship = 'A';
    SET relationship_string = '';
    SET i = 1;
    SET substring = '';
    SET sire_temp = NULL;
    SET dam_temp = NULL;
    
    -- Clear the pedigree table
    DELETE FROM pedigree;

    -- Insert the given animal_id into pedigree.
    INSERT INTO pedigree
    VALUE (sp_animal_id, sp_relationship);
    
    -- While the generation iterator is less than the desired generations:
    WHILE sp_generations < generations DO
    
        -- If we want more than just the input animal
        IF sp_generations > 0 THEN
        
            -- Find the last few relationships from pedigree.
            -- Guaranteed to have all relationships from past generation.
            -- The length of the relationship for the past generation will be
            -- 2 * generation + 1 because it starts with 1 character, and adds 2
            -- per generation.
            SELECT GROUP_CONCAT(relationship ORDER BY relationship SEPARATOR '')
            FROM pedigree
            WHERE CHAR_LENGTH(relationship) = 2*(sp_generations) + 1
            INTO relationship_string;
            
            
            -- Reset the string iterator
            SET i = 1;
            -- While the iterator hasn't reached the end of the string
            WHILE i < CHAR_LENGTH(relationship_string) DO
                -- Slice the string into the first relationship.
                SET substring = SUBSTRING(relationship_string, i,
                                        2*(sp_generations) + 1);
                                    
                SET sp_relationship = substring;
                
                SELECT animal_id
                FROM pedigree
                WHERE relationship = substring
                INTO sp_animal_id;
            
                SELECT sire_id FROM breed_registry
                WHERE animal_id = sp_animal_id
                INTO sire_temp;
                
                -- If the sire exists in the registry
                IF sire_temp IS NOT NULL THEN
                    -- Insert the sire into pedigree table
                    INSERT INTO pedigree (animal_id, relationship)
                    VALUE (sire_temp, CONCAT_WS('.', sp_relationship, 'S'));
                END IF;
            
                SELECT dam_id FROM breed_registry WHERE animal_id = sp_animal_id
                INTO dam_temp;
            
                -- If the dam exists in the registry
                IF dam_temp IS NOT NULL THEN
                    -- Insert the dam into pedigree table
                    INSERT INTO pedigree (animal_id, relationship)
                    VALUE (dam_temp, CONCAT_WS('.', sp_relationship, 'D'));
                END IF;
            
                -- Iterate to the next relationship in the relationship_string
                SET i = i + 2*(sp_generations) + 1;
        
            END WHILE;
                    
        -- Want to include parents
        ELSEIF sp_generations = 0 THEN
            
            SELECT sire_id FROM breed_registry WHERE animal_id = sp_animal_id
            INTO sire_temp;
            
            IF sire_temp IS NOT NULL THEN
                -- Insert the sire into pedigree table
                INSERT INTO pedigree (animal_id, relationship)
                VALUE (sire_temp, CONCAT_WS('.', sp_relationship, 'S'));
            END IF;
            
            SELECT dam_id FROM breed_registry WHERE animal_id = sp_animal_id
            INTO dam_temp;
            
            IF dam_temp IS NOT NULL THEN
                -- Insert the dam into pedigree table
                INSERT INTO pedigree (animal_id, relationship)
                VALUE (dam_temp, CONCAT_WS('.', sp_relationship, 'D'));
            END IF;
            
        END IF;
        
        -- Iterate generations
        SET sp_generations = sp_generations + 1;
        
    END WHILE;
    
END!

DELIMITER ;


-- [Problem 2b]
-- Reports animals that have appeared in current pedigree more than once.
SELECT animal_id, registered_name, num_times
FROM breed_registry NATURAL JOIN (
    SELECT animal_id, COUNT(animal_id) AS num_times
    FROM pedigree
    GROUP BY animal_id) AS appearance_counts
ORDER BY num_times DESC;

-- output of query for Dixie(id = 175) has Jack appearing 8 times and Macy
-- appearing 6 times, which means that Dixie is inbred and is likely
-- to have congenital defects.

