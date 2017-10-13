-- [Problem 3]
-- Clean up tables if they already exist, respecting referential integrity.
DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS uploaded;
DROP TABLE IF EXISTS albums;
DROP TABLE IF EXISTS photo;
DROP TABLE IF EXISTS video;
DROP TABLE IF EXISTS media_item;
DROP TABLE IF EXISTS user_accounts;

-- Keeps track of user accounts. An account has a unique username, a required
-- email address (not necessarily unique), a salt, and a hashed password.
CREATE TABLE user_accounts(
    username        VARCHAR(20),
    email_address   VARCHAR(50) NOT NULL,
    -- Added a salt attribute in order to make it harder for people to
    -- figure out the unhashed password.
    salt            VARCHAR(20) NOT NULL,
    password_hash   CHAR(64) NOT NULL,  -- generated with SHA2
    PRIMARY KEY(username),
    CHECK (LEN(salt) >= 5)              -- don't want the salt to be too short
);

-- Keeps track of all media items. Has an autoincrementing item_id for easier
-- identification, a required title, an optional description, the upload time,
-- and how many times the item has been viewed/downloaded from the website which
-- defaults to 0. More specific info can be found in photo and video.
CREATE TABLE media_item(
    item_id             INT AUTO_INCREMENT,
    title               VARCHAR(200) NOT NULL,
    item_description    TEXT,
    upload_time         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    downloads           INT NOT NULL DEFAULT 0,
    PRIMARY KEY(item_id)
);

-- Keeps track of extra info that photos have. This includes the filename and
-- the data for the photo stored as a BLOB.
CREATE TABLE photo(
    item_id         INT,
    -- Just the filename and not the path for the photo.
    photo_filename  VARCHAR(100) NOT NULL,
    photo_data      BLOB NOT NULL,
    PRIMARY KEY (item_id),
    FOREIGN KEY (item_id) REFERENCES media_item(item_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Keeps track of extra info the videos have.
CREATE TABLE video(
    item_id         INT,
    -- Path and filename for where video is stored.
    video_filename  VARCHAR(4000) NOT NULL,
    -- Length of video in seconds, rounded up
    length          INT NOT NULL,
    PRIMARY KEY (item_id),
    -- UNIQUE (video_filename),-- candidate key because no two videos can be
                               -- stored in the same place with the same name.
    -- this actually doesn't work because max key length is 767 bytes, which
    -- is less than the 4000 bytes that this filename could be
    FOREIGN KEY (item_id) REFERENCES media_item(item_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Keeps track of each user's albums. An album has a user associated with it,
-- a required title, and an optional description and summary photo.
CREATE TABLE albums(
    username    VARCHAR(20),
    album_name  VARCHAR(100) NOT NULL,
    album_description   TEXT,
    summary_photo   BLOB,
    PRIMARY KEY (username, album_name),
    FOREIGN KEY (username) REFERENCES user_accounts(username)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
        
    -- this didn't work either because BLOB is too big
    -- FOREIGN KEY (summary_photo) REFERENCES photo(photo_data)
        -- ON DELETE CASCADE
        -- ON UPDATE CASCADE
        
    -- This checks that the summary_photo has been previously uploaded.
    CHECK((summary_photo) IN (SELECT photo_data FROM photo))
    
    -- Check that summary_photo is in the album?
);

-- Keeps track of which user uploaded what media_item to which album.
-- There is a many-to-one relationship between media_item and user_accounts.
-- There is a many-to-one relationship between media_item and albums.
-- There is a many-to-one relationship between albums and user_accounts.
CREATE TABLE uploaded(
    username    VARCHAR(20),
    item_id     INT,
    -- Doesn't have a nullity constraint because it is possible
    -- to upload something without putting it in an album.
    album_name  VARCHAR(100),
    PRIMARY KEY (username, item_id, album_name),
    FOREIGN KEY (item_id) REFERENCES media_item(item_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (username, album_name) REFERENCES albums(username, album_name)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- Keeps track of which user commented on which media_item at what time.
-- The primary key has username, item_id, and create_time because a user can't
-- make multiple comments at the same time on one media_item, but could make
-- multiple comments simultaenously on different items.
CREATE TABLE comments(
    username        VARCHAR(20),
    item_id         INT,
    create_time     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    text            VARCHAR(500) NOT NULL,
    PRIMARY KEY (username, item_id, create_time),
    FOREIGN KEY (username) REFERENCES user_accounts(username)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (item_id) REFERENCES media_item(item_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

