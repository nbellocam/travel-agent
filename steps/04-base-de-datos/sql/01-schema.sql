-- Esquema de la tabla de hoteles.
-- Respecto del codelab original se agrega la columna `country`, que habilita
-- la tool extra `search-hotels-by-country` del paso 5.
CREATE TABLE hotels(
  id            INTEGER NOT NULL PRIMARY KEY,
  name          VARCHAR NOT NULL,
  location      VARCHAR NOT NULL,
  country       VARCHAR NOT NULL,
  price_tier    VARCHAR NOT NULL,
  checkin_date  DATE    NOT NULL,
  checkout_date DATE    NOT NULL,
  booked        BIT     NOT NULL
);
