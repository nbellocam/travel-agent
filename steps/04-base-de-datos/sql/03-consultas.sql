-- Validación: deberías ver 32 filas.
SELECT * FROM hotels;

-- Conteo por país.
SELECT country, COUNT(*) AS hoteles
FROM hotels
GROUP BY country
ORDER BY hoteles DESC;

-- La misma consulta que va a ejecutar la tool `search-hotels-by-location`.
SELECT *
FROM hotels
WHERE location ILIKE '%' || 'Mendoza' || '%'
ORDER BY
  CASE price_tier
    WHEN 'Midscale' THEN 1
    WHEN 'Upper Midscale' THEN 2
    WHEN 'Upscale' THEN 3
    WHEN 'Upper Upscale' THEN 4
    WHEN 'Luxury' THEN 5
    ELSE 99
  END;
