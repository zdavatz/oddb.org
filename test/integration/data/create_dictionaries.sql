-- Drop
DROP TEXT SEARCH CONFIGURATION default_german;
DROP TEXT SEARCH DICTIONARY german_ispell;

-- Creation
CREATE TEXT SEARCH CONFIGURATION public.default_german ( COPY = pg_catalog.german );

CREATE TEXT SEARCH DICTIONARY german_ispell (
  TEMPLATE = ispell,
  DictFile = fulltext,
  AffFile  = fulltext,
  StopWords = fulltext
);

ALTER TEXT SEARCH CONFIGURATION default_german
ALTER MAPPING FOR
  word, hword, hword_part, hword_numpart,
  numword, numhword
WITH german_ispell, german_stem;

ALTER TEXT SEARCH CONFIGURATION default_german
ALTER MAPPING FOR
 asciiword, asciihword, hword_asciipart,
 email, protocol, url, host, url_path, file,
 sfloat, float, int, uint, version, tag, entity, blank
WITH simple;