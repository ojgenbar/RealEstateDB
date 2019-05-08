BEGIN;

CREATE OR REPLACE VIEW public.addresses_view AS (
  SELECT *
  FROM public.addresses AS a
         LEFT JOIN spatial_data.distances AS d ON d.address_id = a.id
);

END;