SET search_path TO dw;

CREATE TABLE dim_time (
  time_key      SERIAL PRIMARY KEY,
  full_date     DATE        NOT NULL,
  year          SMALLINT    NOT NULL,
  month_num     SMALLINT    NOT NULL,
  month_name    VARCHAR(9)  NOT NULL,
  day           SMALLINT    NOT NULL
);
CREATE UNIQUE INDEX ix_dim_time_d ON dim_time(full_date);

CREATE TABLE dim_customer (
  customer_key  SERIAL PRIMARY KEY,
  first_name    VARCHAR(45),
  last_name     VARCHAR(45),
  email         VARCHAR(120),
  city          VARCHAR(120),
  country       VARCHAR(120)
);

CREATE TABLE dim_store (
  store_key     SERIAL PRIMARY KEY,
  store_name    VARCHAR(120),
  address       VARCHAR(200),
  city          VARCHAR(120),
  country       VARCHAR(120)
);

CREATE TABLE dim_film (
  film_key      SERIAL PRIMARY KEY,
  title         VARCHAR(255),
  release_year  SMALLINT,
  rating        VARCHAR(10),
  length_min    SMALLINT
);

CREATE TABLE dim_genre (
  genre_key     SERIAL PRIMARY KEY,
  name          VARCHAR(50) UNIQUE,
  description   TEXT
);

CREATE TABLE fact_sales (
  sales_key     BIGSERIAL PRIMARY KEY,
  amount        DECIMAL(10,2) NOT NULL,
  quantity      SMALLINT      NOT NULL DEFAULT 1,

  customer_key  INT NOT NULL REFERENCES dim_customer(customer_key),
  store_key     INT NOT NULL REFERENCES dim_store(store_key),
  film_key      INT NOT NULL REFERENCES dim_film(film_key),
  genre_key     INT NOT NULL REFERENCES dim_genre(genre_key),
  time_key      INT NOT NULL REFERENCES dim_time(time_key)
);

CREATE INDEX ix_fs_time      ON fact_sales(time_key);
CREATE INDEX ix_fs_customer  ON fact_sales(customer_key);
CREATE INDEX ix_fs_store     ON fact_sales(store_key);
CREATE INDEX ix_fs_film      ON fact_sales(film_key);
CREATE INDEX ix_fs_genre     ON fact_sales(genre_key);