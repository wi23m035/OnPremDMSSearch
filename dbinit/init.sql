
-- ----------------------------------------
-- USERS  (Demo; löschen, wenn eigene Tabelle existiert)
-- ----------------------------------------
DROP TABLE IF EXISTS users CASCADE;

CREATE TABLE users (
    user_id  SERIAL PRIMARY KEY,
    username TEXT NOT NULL UNIQUE
);

INSERT INTO users (username) VALUES
    ('anna'),
    ('bernd'),
    ('carla');

-- ----------------------------------------
-- DMS_DOCUMENTS
-- ----------------------------------------
DROP TABLE IF EXISTS dms_documents CASCADE;

CREATE TABLE dms_documents (
    document_id   SERIAL PRIMARY KEY,
    user_id       INTEGER      NOT NULL REFERENCES users(user_id),
    doc_type      VARCHAR(50)  NOT NULL,
    title         TEXT         NOT NULL,
    created_at    TIMESTAMP    NOT NULL DEFAULT NOW(),
    file_name     TEXT         NOT NULL,
    file_size_kb  INTEGER,
    mime_type     VARCHAR(100) NOT NULL
);

-- ----------------------------------------
-- DMS_DOCUMENT_METADATA
-- ----------------------------------------
DROP TABLE IF EXISTS dms_document_metadata;

CREATE TABLE dms_document_metadata (
    metadata_id   SERIAL PRIMARY KEY,
    document_id   INTEGER NOT NULL REFERENCES dms_documents(document_id)
                           ON DELETE CASCADE,
    meta_key      TEXT    NOT NULL,
    meta_value    TEXT
);

-- ----------------------------------------
-- 50 TEST‑DOKUMENTE
-- ----------------------------------------
INSERT INTO dms_documents
  (user_id, doc_type, title, created_at, file_name, file_size_kb, mime_type)
VALUES
  (3,'letter',  'Anschreiben Tyrell',                 '2025-02-11 12:14','Tyrell_Letter_2025.pdf',             862,'application/pdf'),
  (2,'invoice', 'Rechnung ACME Feb 2025',             '2025-02-01 14:08','ACME_Invoice_2025-02.pdf',          305,'application/pdf'),
  (1,'contract','Vertrag Soylent',                    '2024-12-23 12:43','Soylent_Contract_2024.pdf',         214,'application/pdf'),
  (3,'report',  'Umbrella Bericht Q4 2024',           '2024-12-07 14:39','Umbrella_Report_Q4_2024.pdf',       671,'application/pdf'),
  (3,'invoice', 'Rechnung ACME Mär 2025',             '2025-03-07 09:49','ACME_Invoice_2025-03.pdf',          289,'application/pdf'),
  (3,'invoice', 'Rechnung Globex Jan 2025',           '2025-01-10 16:07','Globex_Invoice_2025-01.pdf',        520,'application/pdf'),
  (3,'letter',  'Anschreiben ACME',                   '2025-03-12 09:48','ACME_Letter_2025.pdf',              554,'application/pdf'),
  (1,'invoice', 'Rechnung Wayne Mär 2025',            '2025-03-17 12:43','Wayne_Invoice_2025-03.pdf',         824,'application/pdf'),
  (2,'receipt', 'Quittung Globex 12.01.2025',         '2025-01-12 12:44','Globex_Receipt_20250112.pdf',       238,'application/pdf'),
  (2,'letter',  'Anschreiben Oscorp',                 '2025-04-06 14:25','Oscorp_Letter_2025.pdf',            713,'application/pdf'),
  (1,'receipt', 'Quittung ACME 16.02.2025',           '2025-02-16 12:15','ACME_Receipt_20250216.pdf',         819,'application/pdf'),
  (1,'receipt', 'Quittung Tyrell 03.01.2025',         '2025-01-03 16:40','Tyrell_Receipt_20250103.pdf',       500,'application/pdf'),
  (3,'invoice', 'Rechnung Tyrell Feb 2025',           '2025-02-24 13:11','Tyrell_Invoice_2025-02.pdf',        402,'application/pdf'),
  (3,'report',  'ACME Bericht Q2 2025',               '2025-03-25 14:49','ACME_Report_Q2_2025.pdf',           610,'application/pdf'),
  (2,'letter',  'Anschreiben Globex',                 '2025-02-05 11:45','Globex_Letter_2025.pdf',            860,'application/pdf'),
  (2,'contract','Vertrag Wayne',                      '2024-12-14 16:26','Wayne_Contract_2024.pdf',           641,'application/pdf'),
  (1,'invoice', 'Rechnung Wayne Dez 2024',            '2024-12-06 08:54','Wayne_Invoice_2024-12.pdf',         567,'application/pdf'),
  (2,'invoice', 'Rechnung Globex Dez 2024',           '2024-12-17 08:52','Globex_Invoice_2024-12.pdf',        865,'application/pdf'),
  (3,'contract','Vertrag ACME',                       '2025-04-03 17:44','ACME_Contract_2025.pdf',            538,'application/pdf'),
  (2,'letter',  'Anschreiben Umbrella',               '2025-02-20 14:46','Umbrella_Letter_2025.pdf',          289,'application/pdf'),
  (3,'letter',  'Anschreiben Soylent',                '2025-01-30 11:42','Soylent_Letter_2025.pdf',           417,'application/pdf'),
  (2,'invoice', 'Rechnung Soylent Apr 2025',          '2025-04-04 14:22','Soylent_Invoice_2025-04.pdf',       313,'application/pdf'),
  (3,'contract','Vertrag Wayne',                      '2025-03-11 18:59','Wayne_Contract_2025.pdf',           433,'application/pdf'),
  (2,'invoice', 'Rechnung Oscorp Dez 2024',           '2024-12-07 16:59','Oscorp_Invoice_2024-12.pdf',        331,'application/pdf'),
  (1,'report',  'Soylent Bericht Q4 2024',            '2025-01-06 08:30','Soylent_Report_Q4_2024.pdf',        634,'application/pdf'),
  (3,'invoice', 'Rechnung Tyrell Apr 2025',           '2025-04-06 11:36','Tyrell_Invoice_2025-04.pdf',        631,'application/pdf'),
  (3,'invoice', 'Rechnung Soylent Mär 2025',          '2025-03-04 11:38','Soylent_Invoice_2025-03.pdf',       421,'application/pdf'),
  (1,'report',  'Oscorp Bericht Q2 2025',             '2025-03-26 17:03','Oscorp_Report_Q2_2025.pdf',         810,'application/pdf'),
  (3,'invoice', 'Rechnung Globex Dez 2024',           '2024-12-10 12:43','Globex_Invoice_2024-12.pdf',        345,'application/pdf'),
  (2,'invoice', 'Rechnung Umbrella Dez 2024',         '2024-12-04 14:56','Umbrella_Invoice_2024-12.pdf',      699,'application/pdf'),
  (1,'receipt', 'Quittung Umbrella 11.12.2024',       '2024-12-11 11:35','Umbrella_Receipt_20241211.pdf',     879,'application/pdf'),
  (2,'invoice', 'Rechnung Wayne Feb 2025',            '2025-02-13 09:56','Wayne_Invoice_2025-02.pdf',         844,'application/pdf'),
  (1,'invoice', 'Rechnung ACME Dez 2024',             '2024-12-08 14:24','ACME_Invoice_2024-12.pdf',          798,'application/pdf'),
  (3,'invoice', 'Rechnung Globex Apr 2025',           '2025-04-07 12:49','Globex_Invoice_2025-04.pdf',        868,'application/pdf'),
  (3,'receipt', 'Quittung Soylent 09.12.2024',        '2024-12-09 14:37','Soylent_Receipt_20241209.pdf',      384,'application/pdf'),
  (2,'receipt', 'Quittung Globex 13.02.2025',         '2025-02-13 09:15','Globex_Receipt_20250213.pdf',       328,'application/pdf'),
  (1,'invoice', 'Rechnung Oscorp Jan 2025',           '2025-01-08 10:55','Oscorp_Invoice_2025-01.pdf',        884,'application/pdf'),
  (3,'invoice', 'Rechnung Stark Feb 2025',            '2025-02-04 17:02','Stark_Invoice_2025-02.pdf',         411,'application/pdf'),
  (1,'invoice', 'Rechnung Soylent Dez 2024',          '2024-12-02 13:07','Soylent_Invoice_2024-12.pdf',       326,'application/pdf'),
  (1,'report',  'Wayne Bericht Q2 2025',              '2025-02-23 12:01','Wayne_Report_Q2_2025.pdf',          709,'application/pdf'),
  (1,'invoice', 'Rechnung Umbrella Feb 2025',         '2025-02-11 11:19','Umbrella_Invoice_2025-02.pdf',      483,'application/pdf'),
  (3,'invoice', 'Rechnung ACME Jan 2025',             '2025-01-05 17:57','ACME_Invoice_2025-01.pdf',          416,'application/pdf'),
  (2,'report',  'Tyrell Bericht Q1 2025',             '2025-02-28 09:01','Tyrell_Report_Q1_2025.pdf',         850,'application/pdf'),
  (2,'invoice', 'Rechnung Soylent Feb 2025',          '2025-02-09 09:03','Soylent_Invoice_2025-02.pdf',       210,'application/pdf'),
  (2,'invoice', 'Rechnung ACME Mär 2025',             '2025-03-08 12:55','ACME_Invoice_2025-03.pdf',          409,'application/pdf'),
  (3,'receipt', 'Quittung Stark 21.01.2025',          '2025-01-21 17:59','Stark_Receipt_20250121.pdf',        491,'application/pdf'),
  (1,'receipt', 'Quittung Oscorp 19.02.2025',         '2025-02-19 15:34','Oscorp_Receipt_20250219.pdf',       391,'application/pdf'),
  (2,'invoice', 'Rechnung ACME Jan 2025',             '2025-01-26 18:22','ACME_Invoice_2025-01.pdf',          434,'application/pdf'),
  (3,'letter',  'Anschreiben Wayne',                  '2025-03-23 09:10','Wayne_Letter_2025.pdf',             327,'application/pdf'),
  (3,'invoice', 'Rechnung Tyrell Mär 2025',           '2025-03-09 12:37','Tyrell_Invoice_2025-03.pdf',        736,'application/pdf'),
  (1,'report',  'Stark Bericht Q3 2025',              '2025-04-12 08:04','Stark_Report_Q3_2025.pdf',          751,'application/pdf'),
  (1,'invoice', 'Rechnung Umbrella Jan 2025',         '2025-01-27 17:43','Umbrella_Invoice_2025-01.pdf',      418,'application/pdf'),
  (2,'letter',  'Anschreiben Stark',                  '2025-03-15 10:19','Stark_Letter_2025.pdf',             793,'application/pdf');

COMMIT;

/* =========================================================================
   ENDE DES SETUP‑SKRIPTS
   ========================================================================= */
