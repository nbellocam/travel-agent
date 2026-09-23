-- Datos de ejemplo: hoteles de Argentina, Uruguay y Chile.
--
-- IMPORTANTE: los nombres de los hoteles son reales para que el workshop se
-- sienta familiar, pero TODO el resto del dato es ficticio e inventado para la
-- demo: las categorías, las fechas y la disponibilidad no representan
-- información real de ningún establecimiento.
INSERT INTO hotels(id, name, location, country, price_tier, checkin_date, checkout_date, booked)
VALUES
  -- Argentina
  (1,  'Alvear Palace Hotel',           'Buenos Aires',           'Argentina', 'Luxury',         '2026-10-05', '2026-10-09', B'0'),
  (2,  'Four Seasons Buenos Aires',     'Buenos Aires',           'Argentina', 'Luxury',         '2026-10-02', '2026-10-07', B'0'),
  (3,  'Hotel Madero',                  'Buenos Aires',           'Argentina', 'Upscale',        '2026-10-10', '2026-10-14', B'0'),
  (4,  'NH Buenos Aires Tango',         'Buenos Aires',           'Argentina', 'Upper Midscale', '2026-10-03', '2026-10-06', B'1'),
  (5,  'Ibis Buenos Aires Obelisco',    'Buenos Aires',           'Argentina', 'Midscale',       '2026-10-12', '2026-10-15', B'0'),
  (6,  'Sheraton Cordoba Hotel',        'Cordoba',                'Argentina', 'Upper Upscale',  '2026-10-08', '2026-10-11', B'0'),
  (7,  'Amerian Cordoba Park Hotel',    'Cordoba',                'Argentina', 'Upscale',        '2026-10-04', '2026-10-08', B'0'),
  (8,  'Holiday Inn Express Cordoba',   'Cordoba',                'Argentina', 'Upper Midscale', '2026-10-15', '2026-10-18', B'0'),
  (9,  'Park Hyatt Mendoza',            'Mendoza',                'Argentina', 'Luxury',         '2026-10-06', '2026-10-10', B'0'),
  (10, 'Diplomatic Hotel Mendoza',      'Mendoza',                'Argentina', 'Upscale',        '2026-10-09', '2026-10-13', B'0'),
  (11, 'Hotel Argentino Mendoza',       'Mendoza',                'Argentina', 'Midscale',       '2026-10-01', '2026-10-04', B'1'),
  (12, 'Llao Llao Resort',              'Bariloche',              'Argentina', 'Luxury',         '2026-10-07', '2026-10-12', B'0'),
  (13, 'Hotel Panamericano Bariloche',  'Bariloche',              'Argentina', 'Upper Upscale',  '2026-10-11', '2026-10-15', B'0'),
  (14, 'Selina Bariloche',              'Bariloche',              'Argentina', 'Midscale',       '2026-10-02', '2026-10-05', B'0'),
  (15, 'Sheraton Salta Hotel',          'Salta',                  'Argentina', 'Upper Upscale',  '2026-10-13', '2026-10-17', B'0'),
  (16, 'Legado Mitico Salta',           'Salta',                  'Argentina', 'Upscale',        '2026-10-05', '2026-10-08', B'0'),
  (17, 'Ros Tower Hotel',               'Rosario',                'Argentina', 'Upscale',        '2026-10-14', '2026-10-17', B'0'),
  (18, 'Holiday Inn Rosario',           'Rosario',                'Argentina', 'Upper Midscale', '2026-10-03', '2026-10-07', B'0'),
  -- Uruguay
  (19, 'Sofitel Montevideo Casino Carrasco', 'Montevideo',        'Uruguay',   'Luxury',         '2026-10-04', '2026-10-09', B'0'),
  (20, 'Radisson Montevideo',           'Montevideo',             'Uruguay',   'Upper Upscale',  '2026-10-10', '2026-10-13', B'0'),
  (21, 'Ibis Montevideo',               'Montevideo',             'Uruguay',   'Midscale',       '2026-10-06', '2026-10-09', B'1'),
  (22, 'Hotel Fasano Las Piedras',      'Punta del Este',         'Uruguay',   'Luxury',         '2026-10-12', '2026-10-18', B'0'),
  (23, 'Enjoy Punta del Este',          'Punta del Este',         'Uruguay',   'Upper Upscale',  '2026-10-08', '2026-10-12', B'0'),
  (24, 'Charco Hotel',                  'Colonia del Sacramento', 'Uruguay',   'Upscale',        '2026-10-02', '2026-10-05', B'0'),
  -- Chile
  (25, 'The Singular Santiago',         'Santiago',               'Chile',     'Luxury',         '2026-10-05', '2026-10-10', B'0'),
  (26, 'W Santiago',                    'Santiago',               'Chile',     'Upper Upscale',  '2026-10-07', '2026-10-11', B'0'),
  (27, 'Hotel Cumbres Lastarria',       'Santiago',               'Chile',     'Upscale',        '2026-10-11', '2026-10-14', B'0'),
  (28, 'Ibis Santiago Providencia',     'Santiago',               'Chile',     'Midscale',       '2026-10-01', '2026-10-04', B'0'),
  (29, 'Hotel Casa Higueras',           'Valparaiso',             'Chile',     'Upscale',        '2026-10-09', '2026-10-12', B'0'),
  (30, 'Sheraton Miramar Vina del Mar', 'Vina del Mar',           'Chile',     'Upper Upscale',  '2026-10-13', '2026-10-16', B'0'),
  (31, 'Hotel Awa',                     'Puerto Varas',           'Chile',     'Luxury',         '2026-10-06', '2026-10-11', B'0'),
  (32, 'Hotel Cabana del Lago',         'Puerto Varas',           'Chile',     'Upper Midscale', '2026-10-15', '2026-10-19', B'0');
