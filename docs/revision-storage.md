# Revisión — Data / Almacenamiento y Chasis / Metraje

Fecha: 13/11/2026 · Estado: **implementado y verificado**.

---

## Digital: lo que estaba mal

1. **Sólo ProRes.** La app manejaba seis variantes de ProRes en dos resoluciones. Nada de
   ARRIRAW, X-OCN, REDCODE, BRAW ni XAVC, que es lo que graban las cámaras del catálogo.
2. **Resolución como texto libre** ("4K (UHD)") que no decía nada del sensor ni del modo.
3. **GB calculados en base 1024.** Los fabricantes de soportes y las hojas de cámara usan
   1000 MB por GB. Un 2,4 % de diferencia que se acumula en jornadas largas.
4. **Sólo un sentido:** de minutos a GB. En set se pregunta más "¿cuánto entra en esta tarjeta?".
5. **La copia DIT usaba la velocidad nominal del disco**, sin el overhead real del 20–30 %.

## Digital: lo que hace ahora

- **32 familias de códec y 77 tasas verificadas** (ARRIRAW 13-bit, ProRes, X-OCN XT/ST/LT,
  REDCODE por ratio, BRAW por ratio, XAVC I/L/HS, H.264/265).
- Si el fps pedido no está en la tabla, **escala linealmente desde la fila más cercana** y lo avisa.
- Muestra la tasa en Mbps, MB/s y GB/hora.
- **Dos sentidos**: "tengo estos GB" (tiempo que entra) y "necesito estos minutos" (espacio).
- **Descuenta 5 % de overhead** del sistema de archivos.
- **Copia DIT** con lectura, escritura, cuello de botella y 25 % de overhead.

## Fílmico: lo que estaba mal

1. **Todos los formatos caían en 90 ft/min.** La pantalla buscaba el consumo por el nombre del
   sensor digital ("ALEXA 35 · 4.6K…"), que nunca coincidía con la tabla fílmica, así que usaba
   el valor por defecto. Una Super 16 y un 65 mm daban el mismo consumo.
2. No mostraba el cuadro ni las perforaciones del formato.
3. No había tamaños de chasis habituales (100/400/1000 ft).

## Fílmico: lo que hace ahora

- Toma el formato elegido en el plano, con su **cuadro real, perforaciones y CoC**.
- Consumo correcto por formato y por fps (a 24 fps: 35 mm 4-perf 90 ft/min, 3-perf 67.5,
  2-perf 45, 16 mm 36, 65 mm 5-perf 112.5).
- Tiempo restante en el chasis con lo ya consumido, y duración total del chasis.
- Atajos de 100 / 400 / 1000 ft.

## Verificado

- ARRIRAW 4.6K a 24 fps: 4549 Mbps, 568,6 MB/s, 2047 GB/h. 512 GB con overhead dan 14m 15s.
- Copia de 512 GB con lectura 1000 y escritura 500: 375 MB/s efectivos, 22m 45s.
- 400 ft de 35 mm 4-perf a 24 fps: 4m 27s.

## Pendientes de decisión

- ¿Querés que la app **sume el audio** (las tasas de ARRI incluyen audio y las de RED no)?
- ¿Agregamos **cantidad de tarjetas** ("necesitás 3 CFexpress de 512 GB") en vez de sólo GB?
- ¿El modo fílmico debe permitir cargar **el stock real** (5219, 250D, etc.) para llevar registro?
