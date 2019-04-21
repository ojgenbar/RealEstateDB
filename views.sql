-- Todo: use median instead of average

CREATE VIEW public.address_view AS (
  SELECT a.id,
         d.name AS district_name,
         a.ru_address,
         a.en_address,
         a.building_type,
         a.floors,
         avg(ph.price_sqm) AS avg_price,
         a.geom
  FROM public.addresses as a
         JOIN public.districts as d ON a.district_id = d.id
         JOIN public.flats as f ON f.address_id = a.id
         JOIN public.price_history as ph ON ph.flat_id = f.id
  group by a.id, d.name
)