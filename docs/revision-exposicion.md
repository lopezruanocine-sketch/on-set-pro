# Revisión — Departamento de Exposición

Fecha: 13/11/2026 · Estado: **análisis previo a los cambios**.

Cuatro herramientas: Mapa de Zonas · Fall-Off · Compensar · Fotometría (Lux ⇄ f).
Todas siguen calculando con las fórmulas viejas dentro de la pantalla, aunque el motor
nuevo (`lib/domain/exposure/`) ya está probado y disponible.

---

## 1. Mapa de Zonas

**Qué hace hoy:** elegís el diafragma de cámara, escribís la lectura del fotómetro, tocás la
zona destino y devuelve los stops de corrección sobre una escala de 11 grises.

**Lo que está bien:** el concepto es correcto y el gesto de tocar la zona destino funciona.

**Problemas:**

1. **No conoce el ISO.** La zona se calcula sólo con diafragma. Si la cámara está a ISO 1600 y
   la medición se hizo a 800, la zona está un stop corrida y la corrección también.
2. **Defaults que asustan:** cámara f/2.8 y fotómetro f/16 arrancan la pantalla en zona 10
   (todo quemado). Debería abrir en zona 5 (gris medio) o recordar la última lectura.
3. **No sugiere ND.** La biblia v5.2 lo pedía explícitamente: "cierra 2 pasos o usa ND 0.6".
4. **No marca la zona de la lectura**: sólo la zona actual y la destino.
5. **No muestra latitud**: no dice cuántos stops de rango tiene el sensor elegido ni si el
   destino está fuera de rango.

## 2. Fall-Off (inversa del cuadrado)

**Qué hace hoy:** dos distancias (referencia y nueva) y devuelve pérdida o ganancia en stops,
con un dibujo de persona + fuente.

**Problemas:**

1. **El gráfico no muestra la distancia de referencia.** Dibuja sólo la nueva distancia, así
   que no se ve el "antes y después", que es justamente lo que hay que entender.
2. **El haz de luz apunta al revés**: la fuente debería iluminar al sujeto, no al revés.
3. **No dice qué hacer.** El número solo no resuelve el plano: falta "acercá la fuente a 2.8 m"
   o "compensá abriendo 2 stops" o "necesitás ND 0.6".
4. **Sólo metros.** En sets con equipo americano se trabaja en pies.
5. **No advierte el límite de la ley**: vale para fuentes puntuales; a menos de 1 m, o con
   fuentes grandes (difusores, booklights), la ley inversa pura no se cumple.

## 3. Compensar — el más importante

**Qué hace hoy:** f/ deseado, lectura del fotómetro, ISO, FPS, ángulo de obturador, ND y gel;
devuelve un único número de stops.

**Problemas:**

1. **ISO base fijo en 800.** La app ya conoce la cámara: VENICE 2 6K tiene base 500, y para
   ALEXA 265 ARRI no publica base. Si el ISO base está mal, la corrección está un stop corrida.
2. **Se perdió el modo de obturador 1/x.** Existía antes de una de las reescrituras de Gemini;
   hoy sólo se puede elegir ángulo.
3. **No explica el número.** La promesa de la app es que el resultado diga de dónde sale.
   Hoy no hay desglose: ISO, obturador, ND y geles no aparecen.
4. **No propone la solución.** Devuelve "−1.0 stops" cuando en set hay que decidir algo:
   ¿cierro?, ¿pongo ND 0.3?, ¿bajo ISO?, ¿muevo la luz?
5. **El signo es ambiguo.** "−1.0 STOPS" en rojo no dice si es "quitá luz" o "abrí".
6. **Usa los catálogos viejos**: `CineData.cameraFilters` y `lightGels` tienen 13 gelatina
   inventadas, mientras la app ya tiene 31 Lee/Rosco con mireds y pérdidas verificadas.
7. **No usa la cámara elegida** para nada: ni ISO base, ni rango.

## 4. Fotometría (Lux ⇄ f)

**Qué hace hoy:** convierte lux a diafragma (y al revés) con el ISO elegido.

**Problemas:**

1. **Obturador fijo en 1/48 s.** Grabando a 48 fps o con 90° la respuesta está uno o dos stops
   corrida. Es el error más grave de esta pestaña.
2. **C = 250 fija y sin explicar.** La constante del exposímetro (plano vs domo) debería poder
   elegirse o al menos estar documentada en pantalla.
3. **ISO arranca en 100**, en vez del ISO base de la cámara.
4. **Rangos pobres**: los sliders no permiten valores de set (0.01 lux a 200.000; f/1.4 a f/22).
5. **No muestra equivalencias**: "f/2.8 a 1/48 = f/4 a 1/96" es la información que se usa.

---

## Propuesta

### A. Un estado de plano compartido

Cámara · ISO · FPS · obturador · ND · gel, en un solo lugar que **todas** las pestañas lean.
Cambiar el FPS en Compensar tiene que actualizar Fotometría. Es lo que convierte cuatro
calculadoras sueltas en un sistema.

### B. Compensar v2

- ISO base del catálogo de cámaras (con aviso cuando el fabricante no lo publica).
- Obturador en ángulo **y** en velocidad 1/x.
- Resultado con desglose: "Estás 1 stop sobre: ISO +1 · ND −1".
- **Recetario**: tres alternativas táctiles para resolver la corrección.
- **Anclas**: fijar ISO, fijar obturador, o fijar diafragma, y que la app resuelva el resto.

### C. Zonas v2

- ISO de cámara y del fotómetro.
- Sugerencia de ND cuando hay que quitar luz.
- Marcar la zona de la lectura y el rango útil del sensor.

### D. Fall-Off v2

- Gráfico con las dos distancias (referencia fantasma + nueva).
- Metros y pies.
- "Qué hacer" debajo del número.
- Advertencia de fuente puntual vs fuente grande.

### E. Fotometría v2

- Obturador real del estado de plano.
- C elegible (plano / domo) y visible.
- ISO base como valor inicial.

### F. Un solo criterio de signo

Negativo = **quitar luz** (rojo). Positivo = **añadir luz** (dorado). Hoy el motor y la
pantalla usan signos opuestos y eso es una bomba de tiempo.

---

## Filtros y gelatinas: las dos familias (13/11/2026)

En set hay dos familias de filtros y las dos cuestan luz, siempre en pasos:

| Familia | Dónde va | Ejemplos | ¿Se compensa siempre? |
|---|---|---|---|
| **Filtros de cámara** | delante del sensor | ND, IRND, polarizador, 85/80A, 81x | **Sí**: la luz que pierden no está en la lectura del fotómetro |
| **Gelatinas en la luz** | delante de la fuente | CTO/CTB, plus/minus green, difusión | **Depende**: si la lectura se tomó con la gelatina puesta, ya está contada |

Cómo quedó implementado:

- **Se apilan.** Se pueden poner ND 1.2 + polarizador delante del sensor, y CTO + difusión en
  la fuente. Cada uno aporta sus pasos y el total se muestra aparte:
  "cámara −5.7 · luz −0.7 · total −6.4".
- **Cada familia tiene su lista** en Compensar, con chips que se agregan y se quitan.
- **Un interruptor aclara la medición**: "la lectura ya incluye las gelatinas". Si está
  activado, la app no descuenta dos veces la gelatina.
- **Las pérdidas entran en las cuatro herramientas**: Compensar, Zonas (la escena baja de
  zona), Fall-Off (por las distancias) y Fotometría (el diafragma necesario se abre).
- **El recetario entiende la estructura**: con 6 pasos de filtro puestos ya no propone ISO
  25600 ni f/0.4; propone **quitar el ND 1.2**, que es lo que haría un DP.

### Mover la fuente (13/11/2026)

El recetario ahora arranca por la herramienta que más se usa en set: **mover la luz**.

- Se carga la distancia a la fuente principal ("FUENTE PRINCIPAL A (m)").
- Con eso, el recetario propone **"Acercá la fuente a X m"** antes que tocar el diafragma o
  el ISO. La distancia sale de la ley inversa: cada paso son un factor raíz de 2.
- Si sobra luz, propone **"Alejá la fuente a X m"**.
- Sólo propone distancias razonables (entre 0,2 y 40 m): si hay que mover la fuente 80 metros,
  no es una receta, es otra escena.
- Orden del recetario: mover la fuente → quitar un filtro → diafragma → ISO.

Ejemplo: ND 0.6 + CTO sobre la base piden +2,7 stops; con la fuente a 2,5 m propone acercarla
a **1,0 m** (o quitar el ND 0.6, o abrir a f/1.6).

---

## Estado de implementación (13/11/2026)

Ya está hecho y con pruebas:

- **Estado de plano compartido** (`lib/state/shot_state.dart`): ISO, fps, obturador, ND y
  gelatina en un solo lugar; las cuatro pestañas lo leen y se actualizan entre sí.
- **Signo único** en motor y pantalla: negativo = quitar luz, positivo = añadir luz.
- **ISO base real** de la cámara elegida (VENICE 2 6K = 500, ALEXA 35 = 800, ALEXA 265 = 800
  por falta de dato oficial).
- **Obturador en ángulo y en velocidad 1/x** (recuperado).
- **Desglose "de dónde sale"** con el mismo signo que el resultado y una fila TOTAL.
- **Recetario** de tres alternativas: diafragma, ISO y ND/obturador.
- **Zonas**: contexto del plano, defaults neutros (zona 5), sugerencia de ND y leyenda.
- **Fall-Off**: gráfico con d₁ y d₂, metros y pies, "qué hacer" y advertencia de fuente grande.
- **Fotometría**: obturador real del plano, C plano/domo seleccionable, diafragma más cercano.
- Catálogo nuevo de filtros (ND 0.3–3.0, IRND, polarizadores, 85/80A, 81x, FLD) que reemplaza
  los mapas viejos de `CineData`.

Pendiente de decisión del usuario: anclas, si el recetario queda con este formato, y latitud.

---

## Decisiones para el usuario

1. ¿El resultado de Compensar debe ser un número o un recetario de tres opciones?
2. ¿Qué variables querés poder anclar (fijar) al compensar?
3. ¿Zonas debe sugerir ND?
4. ¿Fall-off en metros y pies, o sólo metros?
5. ¿Mostramos latitud y riesgo de quemar altas?
