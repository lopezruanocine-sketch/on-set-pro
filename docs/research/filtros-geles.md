# Filtros de cámara y gelatinas de iluminación

**Proyecto:** On Set Pro  
**Fecha de verificación:** 2026-11-12  
**Uso:** catálogo Dart, cálculo de exposición y corrección de color en set.

> **Convención de signos (leer antes de usar las tablas).**  
> `stops` es **pérdida de luz**: positivo = el filtro/gel quita luz. Un valor 0.67 significa “compensar +0.67 EV”.  
> `mired` es el desplazamiento de temperatura de color: **positivo = ámbar/CTO (calienta)**; **negativo = azul/CTB (enfría)**.  
> `transmision_pct` es el porcentaje de luz visible que pasa. Cuando el fabricante no publica transmisión, se indica si es derivada de los pasos o del factor de exposición.  
> `—` = no aplica. `NO VERIFICADO` = dato no disponible en fuentes consultadas.

## Convenciones técnicas

- **Mired:** `M = 1.000.000 / K`. El desplazamiento es `ΔM = 1.000.000/K_destino − 1.000.000/K_fuente`.
- **Densidad neutra:** `D = log10(1/T)`; `T = 10^(−D)`.
- **Pasos:** `stops = log2(1/T) = D / 0.30103`. Por eso **1 paso exacto = densidad 0.30103**; el valor comercial 0.30 es un redondeo y equivale a 0.9966 pasos.
- **Factor de exposición:** `factor = 2^stops = 10^D`.
- **Temperaturas:** las conversiones indicadas son las que publica cada fabricante; no son intercambiables entre marcas sin test.

---

## A. Filtros de cámara

### A.1 ND: densidad óptica, pasos y factor de exposición

El criterio exacto se deduce de la definición de densidad óptica:

```text
D     = log10(1/T)
stops = log2(1/T) = D / 0.30103
factor = 2^stops = 10^D
```

Por lo tanto, **1 paso = ND 0.30103**, no 0.3 exacto. La tabla usa los valores comerciales redondeados y aclara cuáles son calculados.

| Categoría | Filtro | Pasos (pérdida) | Mired | Transm. % | Factor exp. | Notas |
|---|---|---:|---:|---:|---:|---|
| ND | ND 0.3 | 1.0 | — | 50.1 | 2 | 0.9966 pasos exactos; el estándar comercial lo llama “1 stop” |
| ND | ND 0.45 | 1.5 | — | 35.5 | 2.83 | Densidad menos común; valor calculado con la fórmula |
| ND | ND 0.6 | 2.0 | — | 25.1 | 4 | 1.993 pasos exactos |
| ND | ND 0.75 | 2.5 | — | 17.8 | 5.66 | Densidad menos común; valor calculado |
| ND | ND 0.9 | 3.0 | — | 12.6 | 8 | 2.989 pasos exactos |
| ND | ND 1.2 | 4.0 | — | 6.31 | 16 | 3.986 pasos exactos |
| ND | ND 1.5 | 5.0 | — | 3.16 | 32 | 4.982 pasos exactos |
| ND | ND 1.8 | 6.0 | — | 1.58 | 64 | 5.979 pasos exactos |
| ND | ND 2.1 | 7.0 | — | 0.79 | 128 | 6.975 pasos exactos |
| ND | ND 2.4 | 8.0 | — | 0.40 | 256 | 7.972 pasos exactos |
| ND | ND 2.7 | 9.0 | — | 0.20 | 512 | 8.968 pasos exactos |
| ND | ND 3.0 | 10.0 | — | 0.10 | 1024 | 9.966 pasos exactos; también llamado ND1000 |
| ND variable | ND variable 2–8 stops | 2.0–8.0 | — | 25.0–0.39 | 4–256 | Rango típico del Tiffen Variable ND; en el máximo aparecen viñeteo y “X” |
| Polarizador | Polarizador lineal | 2.0 | — | 25.0 | 4 | Tiffen publica ~2 stops; la pérdida real depende de la orientación y de la escena |
| Polarizador | Polarizador circular | 1.5–2.0 | — | 35.4–25.0 | 2.8–4.0 | Lee SW150: factor 2.8–4× = 1.5–2 stops; necesario para AF/medición con espejo |
| Conversión | 85 | 0.67 | +112 | 62.9 | — | 5500→3400 K; Tiffen 2/3 stop; factor 1.6 |
| Conversión | 85B | 0.67 | +131 | 62.9 | — | 5500→3200 K; Tiffen 2/3 stop; factor 1.5 |
| Conversión | 85C | 0.30 | +81 | 81.2 | — | 5500→3800 K; Tiffen 0.3 stop; algunas tablas indican 2/3 |
| Conversión | 80A | 2.0 | −131 | 25.0 | — | 3200→5500 K; factor 4; 2 stops |
| Conversión | 80B | 1.67 | −112 | 31.5 | — | 3400→5500 K; factor 3; 1 2/3 stops |
| Conversión | 80C | 1.0 | −81 | 50.0 | — | 3800→5500 K; factor 2; 1 stop |
| Balance | 81A | 0.33 | +18 | 79.4 | — | Calienta +18 mired (~200 K a 3200 K); factor 1.4; Tiffen indica 1/3 stop y otras fichas 1/2 |
| Balance | 81B | 0.33 | +27 | 79.4 | — | Factor 1.4; Tiffen 1/3 stop |
| Balance | 81EF | 0.67 | +52 | 62.9 | — | Tiffen 2/3 stop; el más cálido de la serie 81 |
| Fluorescente | FLD | 1.0 | — | 50.0 | — | Magenta para corregir el verde de fluorescentes con película daylight; factor 2×; mired no aplica |
| IRND | IRND 0.9 | 3.0 | — | 12.6 | 8 | ND 0.9 + corte de infrarrojo; misma densidad nominal, para sensores digitales |
| IRND | IRND 1.2 | 4.0 | — | 6.31 | 16 | ND 1.2 + corte de infrarrojo |
| Combinado | 85/ND 1.2 | 4.67 | — | 3.9 | — | Suma 85 (0.67) + ND 1.2 (4.0); ejemplo Tiffen 85/ND 1.2 |

**Lectura rápida del ND.** 0.3 = 1 paso; 0.6 = 2; 0.9 = 3; 1.2 = 4; 1.5 = 5; 1.8 = 6; 2.1 = 7; 2.4 = 8; 2.7 = 9; 3.0 = 10. Los valores 0.45 = 1.5 y 0.75 = 2.5 son correctos por fórmula, aunque no todos los fabricantes los ofrecen. Las densidades se suman al apilar filtros: dos ND 0.6 equivalen a ND 1.2 (2 + 2 = 4 pasos).

### A.2 ND variable: rango y advertencias

- **Rango típico:** 2–8 pasos en el Tiffen Variable ND; también existen 1–5 y 1–8.6 de otras marcas. El rango útil suele ser menor que el máximo anunciado.
- **Construcción:** dos polarizadores lineales; al girar el frontal se atenúa la luz. Eso explica los artefactos.
- **Advertencias:** viñeteo en angulares y en el extremo máximo; patrón de “X” o bandas; dominante de color; pérdida de resolución por dos elementos; no tiene topes duros, por lo que es fácil pasarse; interactúa con la polarización de la escena.
- **Recomendación:** usar ND fijos para tomas críticas y el variable para cobertura rápida; no trabajar en el máximo; verificar en monitor y con carta de color.

### A.3 Polarizadores: pérdida real

- **Lineal:** Tiffen publica una pérdida de **2 stops** (factor 4). Puede engañar a fotómetros de espejo divisorio y a algunos sistemas de AF.
- **Circular:** el Lee SW150 declara factor 2.8–4×, es decir **1.5–2 stops**; Tiffen también publica ~2 stops para su circular. La pérdida depende de la orientación del filtro y de cuánta luz polarizada haya en la escena, no solo del filtro.
- **Uso:** en digital con AF/medición a través del objetivo, usar circular. El lineal solo es seguro en cámaras totalmente manuales o con medición externa.

### A.4 Filtros de corrección de color de cámara (85/80/81/FLD)

- **85 / 85B / 85C:** ámbar, calientan. Convierten luz daylight a la balance de tungsteno. 85B es el más fuerte (5500→3200 K, +131 mired); 85 va a 3400 K (+112); 85C a 3800 K (+81).
- **80A / 80B / 80C:** azul, enfrían. Convierten tungsteno a daylight. 80A es el más fuerte (3200→5500 K, −131 mired, 2 stops); 80B y 80C son progresivamente más suaves.
- **81A / 81B / 81EF:** filtros de balance fino, no conversión completa. Van de +18 a +52 mired y se usan para calentar sombras, piel o luz fría.
- **FLD:** magenta, no se define por Kelvin ni por mired en el eje ámbar-azul; corrige el pico verde de tubos fluorescentes con película daylight. **Su mired no está publicado: no aplica.** La pérdida típica es 1 stop (factor 2×).
- **Digital:** si la cámara ya está balanceada a tungsteno y se pone un 85, se produce doble corrección. Usar estos filtros solo cuando se busca el look óptico o se trabaja con una balance fija.

### A.5 IRND y filtros combinados

- **Qué son:** un ND al que se le añade una capa de corte de infrarrojo cercano (hot mirror). El ND solo atenúa visible y deja pasar parte del IR; en sensores CMOS/CCD eso contamina negros y genera dominantes magenta/rojo.
- **Cuánto afectan:** la exposición sigue siendo la del ND nominal (IRND 0.9 = 3 stops; IRND 1.2 = 4 stops). La capa IR puede añadir una densidad extra no estandarizada; **NO VERIFICADO** cuánto suma en cada fabricante. Verificar con test y carta de negros.
- **Combinados:** 85/ND suma pasos (0.67 + 4.0 = 4.67 en el ejemplo). Los combinados ahorran cristales, pero impiden ajustar la corrección de color por separado.

### Fuentes del bloque A

- Fórmula y tabla de densidades: [Wikipedia — Neutral-density filter](https://en.wikipedia.org/wiki/Neutral-density_filter).
- ND comerciales Lee: [LEE 0.3 ND](https://leefilters.com/colour/209-0-3nd/), [LEE 0.6 ND](https://leefilters.com/colour/210-0-6nd/), [LEE 0.9 ND](https://leefilters.com/colour/211-0-9nd/).
- Mired y pasos de la serie Wratten (tabla basada en Tiffen Practical Filter Manual): [Wikipedia — Wratten number](https://en.wikipedia.org/wiki/Wratten_number).
- Tiffen 85C (0.3 stop): [B&H — Tiffen Series 9 85C](https://www.bhphotovideo.com/c/product/55260-REG/Tiffen_S985C_Series_9_85C_Color.html).
- Tiffen 80A (factor 4, 2 stops): [B&H — Tiffen 49mm 80A](https://www.bhphotovideo.com/c/product/54500-REG/Tiffen_4980A_49mm_80A_Color_Conversion.html).
- Tiffen 81A (factor 1.4): [Adorama — Tiffen 58mm 81A](https://www.adorama.com/tf5881a.html).
- Tiffen FL-D (función y factor 2×): [Tiffen FL-D](https://tiffen.com/products/tiffen-37mm-fl-d-fluorescent-glass-filter-for-daylight-film) y [ficha comercial Tiffen FL-D 49 mm](https://www.amazon.ca/dp/B00004ZC9P).
- ND variable 2–8 stops: [Tiffen — Variable ND](https://tiffen.com/products/variable-nd-filter); calidad de imagen y dos polarizadores: [Wikipedia — Neutral-density filter](https://en.wikipedia.org/wiki/Neutral-density_filter).
- Polarizadores: [Tiffen Filter Facts (B&H)](https://www.bhphotovideo.com/find/Product_Resources/polarizerComu.jsp); [Lee SW150 Circular Polarizer — 2.8–4×, 1.5–2 stops](https://www.lensrentals.com/rent/lee-150-x-150mm-sw150-circular-polarizer-filter).
- IRND: [B&H — Schneider 77mm Platinum IRND 0.9](https://www.bhphotovideo.com/c/product/842807-REG/Schneider_68_060977_77mm_MPTV_Platinum_IRND.html).
- Combinado 85/ND: [B&H — Tiffen 85/ND 1.2](https://www.bhphotovideo.com/c/product/493249-REG/Tiffen_W456585N12_4x5_65_Combination_85C_Color.html).

---

## B. Gelatinas de iluminación (Lee y Rosco)

### B.1 Criterios de la tabla

- **Mired:** positivo = CTO/ámbar; negativo = CTB/azul. En plus/minus green y difusión **no aplica** (el primero corrige el eje verde-magenta; la difusión no cambia la temperatura de color).
- **Transmisión:** Lee publica valores a 3200 K y a 6774 K (Source C). Para CTO se usa el valor a 3200 K, que es el que suele citar el fabricante; cuando el gel se usa sobre daylight la pérdida es algo mayor (se indica en notas). Para CTB se usa el valor a 3200 K, que es la fuente que se está convirtiendo.
- **Pasos:** cuando el fabricante publica “Stop” se usa ese valor; si no, se calcula con `log2(1/T)`. Las pequeñas diferencias respecto de la transmisión son normales.

| Marca | N.º / nombre | Tipo | Mired | Pasos | Transm. % | Temp. color | Notas |
|---|---|---|---:|---:|---:|---|---|
| Lee | 204 Full CTO | Conversión CTO | +159 | 0.67 | 62.8 | 6500→3200 K | 0.85 stop sobre daylight (55.4%); el CTO más usado para tungsteno |
| Lee | 205 Half CTO | Conversión CTO | +109 | 0.42 | 74.5 | 6500→3800 K | 0.50 stop sobre daylight (70.8%) |
| Lee | 206 Quarter CTO | Conversión CTO | +64 | 0.28 | 82.6 | 6500→4600 K | 0.34 stop sobre daylight (79.1%) |
| Lee | 223 Eighth CTO | Conversión CTO | +26 | 0.23 | 85.0 | 6500→5550 K | 0.23 stop sobre daylight (85.2%) |
| Lee | 201 Full CTB | Conversión CTB | −137 | 1.51 | 35.0 | 3200→5700 K | El CTB completo de Lee; pérdida alta |
| Lee | 202 Half CTB | Conversión CTB | −78 | 0.91 | 53.2 | 3200→4300 K | 0.91 stop |
| Lee | 203 Quarter CTB | Conversión CTB | −35 | 0.50 | 70.5 | 3200→3600 K | 0.50 stop |
| Lee | 218 Eighth CTB | Conversión CTB | −18 | 0.32 | 80.2 | 3200→3400 K | 0.32 stop |
| Lee | 244 Plus Green | Plus Green | — | 0.43 | 74.0 | Sin cambio nominal | Aprox. CC30 Green; para igualar descarga/fluorescente |
| Lee | 245 Half Plus Green | Plus Green | — | 0.29 | 81.6 | Sin cambio nominal | Aprox. CC15 Green |
| Lee | 246 Quarter Plus Green | Plus Green | — | 0.23 | 85.0 | Sin cambio nominal | Aprox. CC7.5 Green |
| Lee | 247 Minus Green | Minus Green | — | 0.74 | 60.0 | Sin cambio nominal | Aprox. CC30 Magenta; corrige verde de descarga/LED |
| Lee | 248 Half Minus Green | Minus Green | — | 0.49 | 71.0 | Sin cambio nominal | Aprox. CC15 Magenta; 1/2 minus green típico para LED |
| Lee | 249 Quarter Minus Green | Minus Green | — | 0.31 | 80.5 | Sin cambio nominal | Aprox. CC7.5 Magenta; 1/4 minus green típico para LED |
| Lee | 216 White Diffusion | Difusión | — | 1.50 | 36.0 | Sin cambio nominal | Difusión fuerte; 1½ stops |
| Lee | 250 Half White Diffusion | Difusión | — | 0.75 | 60.0 | Sin cambio nominal | Difusión media; ¾ stop |
| Lee | 251 Quarter White Diffusion | Difusión | — | 0.33 | 80.0 | Sin cambio nominal | Difusión suave; ⅓ stop |
| Lee | 252 Eighth White Diffusion | Difusión | — | 0.23 | >85.0 | Sin cambio nominal | Menos de ¼ stop; no es opalescente |
| Rosco | 3401 Sun 85 | Conversión CTO | +131 | 0.79 | 58.0 | 5500→3200 K | Equivalente al Wratten 85; −0.8 stop |
| Rosco | 3407 Full CTO | Conversión CTO | +167 | 1.09 | 47.0 | 5500→2900 K | Más fuerte que Lee 204; −1.1 stops; mired publicado +167 |
| Rosco | 3408 Half CTO | Conversión CTO | +81 | 0.45 | 73.0 | 5500→3800 K | Equivalente aproximado a Lee 205 |
| Rosco | 3409 Quarter CTO | Conversión CTO | +40 | 0.30 | 81.0 | 5500→4500 K | Mired calculado desde la conversión publicada |
| Rosco | 3410 Eighth CTO | Conversión CTO | +22 | 0.12 | 92.0 | 5500→4900 K | Mired calculado; pérdida mínima |
| Rosco | 3411 3/4 CTO | Conversión CTO | +131 | 0.79 | 58.0 | 5500→3200 K | Mired calculado; ámbar fuerte, menos rosado que R04 |
| Rosco | 3202 Full CTB | Conversión CTB | −131 | 1.47 | 36.0 | 3200→5500 K | Equivalente aproximado a Lee 201; −1.5 stops |
| Rosco | 3204 Half CTB | Conversión CTB | −68 | 0.94 | 52.0 | 3200→4100 K | −0.9 stop |
| Rosco | 3208 Quarter CTB | Conversión CTB | −27 | 0.43 | 74.0 | 3200→3500 K | Mired calculado; Rosco usa 3208 para 1/4 y 3206 para 1/3 |
| Rosco | 3216 Eighth CTB | Conversión CTB | −9 | 0.30 | 81.0 | 3200→3300 K | Mired calculado; 1/8 CTB |
| Rosco | 3304 Tough Plusgreen | Plus Green | — | 0.40 | 76.0 | Sin cambio nominal | Equilibra daylight a fluorescente cool white |
| Rosco | 3315 Tough 1/2 Plusgreen | Plus Green | — | 0.15 | 90.0 | Sin cambio nominal | Equivalente a CC15 Green |
| Rosco | 3316 Tough 1/4 Plusgreen | Plus Green | — | 0.12 | 92.0 | Sin cambio nominal | Equivalente a CC7.5 Green |
| Rosco | 3308 Tough Minusgreen | Minus Green | — | 0.86 | 55.0 | Sin cambio nominal | Equivalente a CC30 Magenta |
| Rosco | 3313 Tough 1/2 Minusgreen | Minus Green | — | 0.49 | 71.0 | Sin cambio nominal | Equivalente a CC15 Magenta |
| Rosco | 3314 Tough 1/4 Minusgreen | Minus Green | — | 0.30 | 81.0 | Sin cambio nominal | Equivalente a CC7.5 Magenta |
| Rosco | 3318 Tough 1/8 Minusgreen | Minus Green | — | 0.17 | 89.0 | Sin cambio nominal | Corrección muy suave |

### B.2 Notas de uso

**CTO/CTB completos.** Lee 204 (+159) y Rosco 3407 (+167) no son equivalentes exactos: Lee publica el shift desde 6500 K y Rosco desde 5500 K. Para convertir 3200 K a daylight, Lee 201 (−137) y Rosco 3202 (−131) tampoco son idénticos; probar en cámara antes de mezclar marcas. Rosco 3401 es un “Sun 85” (+131, 58%) pensado para ventanas y corrección de daylight a tungsteno.

**Plus/minus green.** No llevan mired porque corrigen el eje verde-magenta, no el ámbar-azul. Lee 244 ≈ CC30 Green; 247 ≈ CC30 Magenta. En cámaras con LED verdes, empezar por **1/4 minus green** (Lee 249 / Rosco 3314) y subir a **1/2** (Lee 248 / Rosco 3313) solo si el monitor lo pide. El LED no es fluorescente: el pico verde cambia por modelo y por intensidad de dimming.

**Difusión.** Lee 216 (1.5 stops) es la más fuerte de la serie; 250 (0.75), 251 (0.33) y 252 (<0.25) son progresivamente más suaves. La pérdida real depende del ángulo del haz y de la distancia: en un fresnel abierto puede ser mayor que el dato de catálogo. Lee 252 es “White Diffusion”, no opalescente; para opalescente están Lee 410/420.

**Temperatura de color.** Las conversiones son aproximadas y suponen fuentes continuas (tungsteno/daylight). Con LED, HMI o fluorescente el resultado depende del espectro; el mired publicado no garantiza el mismo Kelvin.

### Fuentes del bloque B

- Fichas oficiales Lee (transmisión, mired y stop): [201](https://leefilters.com/colour/201-full-c-t-blue/), [202](https://leefilters.com/colour/202-half-c-t-blue/), [203](https://leefilters.com/colour/203-quarter-c-t-blue/), [204](https://leefilters.com/colour/204-full-c-t-orange/), [205](https://leefilters.com/colour/205-half-c-t-orange/), [206](https://leefilters.com/colour/206-quarter-c-t-orange/), [218](https://leefilters.com/colour/218-eighth-c-t-blue/), [223](https://leefilters.com/colour/223-eighth-c-t-orange/), [244](https://leefilters.com/colour/244-lee-plus-green/), [245](https://leefilters.com/colour/245-half-plus-green/), [246](https://leefilters.com/colour/246-quarter-plus-green/), [247](https://leefilters.com/colour/247-lee-minus-green/), [248](https://leefilters.com/colour/248-half-minus-green/), [249](https://leefilters.com/colour/249-quarter-minus-green/), [216](https://leefilters.com/colour/216/), [250](https://leefilters.com/colour/250-half-white-diffusion/), [251](https://leefilters.com/colour/251-quarter-white-diffusion/), [252](https://leefilters.com/colour/252-eighth-white-diffusion/).
- Fichas oficiales Rosco (transmisión): [3407](https://us.rosco.com/en/products/filters/r3407-roscosun-cto), [3408](https://us.rosco.com/en/products/filters/r3408-roscosun-12-cto), [3409](https://us.rosco.com/en/products/filters/r3409-roscosun-14-cto), [3410](https://us.rosco.com/en/products/filters/r3410-roscosun-18-cto), [3411](https://us.rosco.com/en/products/filters/r3411-roscosun-34-cto), [3202](https://us.rosco.com/en/products/filters/r3202-full-blue-ctb), [3204](https://us.rosco.com/en/products/filters/r3204-half-blue-ctb), [3208](https://us.rosco.com/en/products/filters/r3208-quarter-blue-ctb), [3216](https://us.rosco.com/en/products/filters/r3216-eighth-blue-ctb), [3304](https://us.rosco.com/en/products/filters/r3304-tough-plusgreen), [3315](https://us.rosco.com/en/products/filters/r3315-tough-12-plusgreen), [3316](https://us.rosco.com/en/products/filters/r3316-tough-14-plusgreen), [3308](https://us.rosco.com/en/products/filters/r3308-tough-minusgreen), [3313](https://us.rosco.com/en/products/filters/r3313-tough-12-minusgreen), [3314](https://us.rosco.com/en/products/filters/r3314-tough-14-minusgreen), [3318](https://us.rosco.com/en/products/filters/r3318-tough-18-minusgreen).
- Rosco 3401 (+131, 58%): [FilmTools — RoscoSun 3401 85](https://www.filmtools.com/rosco-roscosun-3401-85-60-x-20.html).
- Rosco 3407 (+167, −1.1 stops): [Stage Lighting Store — Rosco 3407](https://www.stagelightingstore.com/Rosco-Cinegel-3407-Roscosun-CTO-T8-36-Roscosleeve).
- Rosco 3202 (−131, 36%): [FilmTools — Rosco 3202 Full CTB](https://www.filmtools.com/ligdep/gels-and-diffusion/color-correction/rosco-cinegel-3202-full-ctb-48-x-25.html).
- Rosco 3204 (−68, 52%, −0.9 stop): [Adorama — Rosco 3204 Half CTB](https://www.adorama.com/ro3204r48.html).

---

## TABLA PARA DART

### Filtros de cámara

```text
nombre|stops|mired|transmision_pct|notas
ND 0.3|1.0||50.1|D=0.3; 0.9966 stop exacto; factor 2
ND 0.45|1.5||35.5|D=0.45; calculado; factor 2.83
ND 0.6|2.0||25.1|D=0.6; factor 4
ND 0.75|2.5||17.8|D=0.75; calculado; factor 5.66
ND 0.9|3.0||12.6|D=0.9; factor 8
ND 1.2|4.0||6.31|D=1.2; factor 16
ND 1.5|5.0||3.16|D=1.5; factor 32
ND 1.8|6.0||1.58|D=1.8; factor 64
ND 2.1|7.0||0.79|D=2.1; factor 128
ND 2.4|8.0||0.40|D=2.4; factor 256
ND 2.7|9.0||0.20|D=2.7; factor 512
ND 3.0|10.0||0.10|D=3.0; factor 1024; ND1000
ND variable 2-8|8.0||0.39|rango 2-8 stops; 25% a 2 stops; viñeteo y X en el máximo
Polarizador lineal|2.0||25.0|Tiffen ~2 stops; depende de orientación y escena
Polarizador circular|2.0||25.0|rango 1.5-2.0; Lee SW150 2.8-4x; AF/medición
85|0.67|112|62.9|5500K a 3400K; Tiffen 2/3 stop; factor 1.6
85B|0.67|131|62.9|5500K a 3200K; Tiffen 2/3 stop; factor 1.5
85C|0.30|81|81.2|5500K a 3800K; Tiffen 0.3 stop
80A|2.0|-131|25.0|3200K a 5500K; factor 4; 2 stops
80B|1.67|-112|31.5|3400K a 5500K; factor 3; 1 2/3 stops
80C|1.0|-81|50.0|3800K a 5500K; factor 2; 1 stop
81A|0.33|18|79.4|factor 1.4; Tiffen 1/3 stop; otras fichas 1/2
81B|0.33|27|79.4|factor 1.4; 1/3 stop
81EF|0.67|52|62.9|2/3 stop; el más cálido de la serie 81
FLD|1.0||50.0|magenta para fluorescente; mired no aplica; factor 2x
IRND 0.9|3.0||12.6|ND 0.9 + corte IR; misma densidad nominal
IRND 1.2|4.0||6.31|ND 1.2 + corte IR
85/ND 1.2|4.67||3.9|suma 85 (0.67) + ND 1.2 (4.0)
```

### Gelatinas

```text
nombre|stops|mired|transmision_pct|notas
Lee 204 Full CTO|0.67|159|62.8|6500K a 3200K; 0.85 stop sobre daylight (55.4%)
Lee 205 Half CTO|0.42|109|74.5|6500K a 3800K; 0.50 stop sobre daylight (70.8%)
Lee 206 Quarter CTO|0.28|64|82.6|6500K a 4600K; 0.34 stop sobre daylight (79.1%)
Lee 223 Eighth CTO|0.23|26|85.0|6500K a 5550K; 0.23 stop sobre daylight (85.2%)
Lee 201 Full CTB|1.51|-137|35.0|3200K a 5700K
Lee 202 Half CTB|0.91|-78|53.2|3200K a 4300K
Lee 203 Quarter CTB|0.50|-35|70.5|3200K a 3600K
Lee 218 Eighth CTB|0.32|-18|80.2|3200K a 3400K
Lee 244 Plus Green|0.43||74.0|mired no aplica; aprox CC30 Green
Lee 245 Half Plus Green|0.29||81.6|mired no aplica; aprox CC15 Green
Lee 246 Quarter Plus Green|0.23||85.0|mired no aplica; aprox CC7.5 Green
Lee 247 Minus Green|0.74||60.0|mired no aplica; aprox CC30 Magenta
Lee 248 Half Minus Green|0.49||71.0|mired no aplica; 1/2 minus green para LED
Lee 249 Quarter Minus Green|0.31||80.5|mired no aplica; 1/4 minus green para LED
Lee 216 White Diffusion|1.50||36.0|mired no aplica; difusión fuerte
Lee 250 Half White Diffusion|0.75||60.0|mired no aplica; difusión media
Lee 251 Quarter White Diffusion|0.33||80.0|mired no aplica; difusión suave
Lee 252 Eighth White Diffusion|0.23||85.0|mired no aplica; menos de 1/4 stop
Rosco 3401 Sun 85|0.79|131|58.0|5500K a 3200K; equivalente al Wratten 85
Rosco 3407 Full CTO|1.09|167|47.0|5500K a 2900K; mired publicado
Rosco 3408 Half CTO|0.45|81|73.0|5500K a 3800K
Rosco 3409 Quarter CTO|0.30|40|81.0|5500K a 4500K; mired calculado
Rosco 3410 Eighth CTO|0.12|22|92.0|5500K a 4900K; mired calculado
Rosco 3411 3/4 CTO|0.79|131|58.0|5500K a 3200K; mired calculado
Rosco 3202 Full CTB|1.47|-131|36.0|3200K a 5500K
Rosco 3204 Half CTB|0.94|-68|52.0|3200K a 4100K
Rosco 3208 Quarter CTB|0.43|-27|74.0|3200K a 3500K; mired calculado
Rosco 3216 Eighth CTB|0.30|-9|81.0|3200K a 3300K; mired calculado
Rosco 3304 Tough Plusgreen|0.40||76.0|mired no aplica; CC30 Green
Rosco 3315 1/2 Plusgreen|0.15||90.0|mired no aplica; CC15 Green
Rosco 3316 1/4 Plusgreen|0.12||92.0|mired no aplica; CC7.5 Green
Rosco 3308 Tough Minusgreen|0.86||55.0|mired no aplica; CC30 Magenta
Rosco 3313 1/2 Minusgreen|0.49||71.0|mired no aplica; CC15 Magenta
Rosco 3314 1/4 Minusgreen|0.30||81.0|mired no aplica; CC7.5 Magenta
Rosco 3318 1/8 Minusgreen|0.17||89.0|mired no aplica; corrección suave
```

---

## RIESGOS

1. **Stop mal interpretado.** Todas las cifras son pérdida: positivo = quitar luz. Si el código de la app suma el valor al EV en lugar de restarlo, la exposición se va dos veces.
2. **Densidad nominal vs. real.** ND 0.3 no es exactamente 1 paso: es 0.9966. Las densidades reales varían por lote y por fabricante; dos filtros “0.6” pueden no sumar exactamente 1.2. Medir con carta y fotómetro.
3. **Mired no es lineal en Kelvin.** No se puede sumar “200 K” a una fuente; hay que usar mired. El mismo gel produce shifts distintos según la fuente.
4. **Lee y Rosco no son equivalentes exactos.** 204 (+159) vs. 3407 (+167); 201 (−137) vs. 3202 (−131). Mezclar marcas sin test puede dejar un salto visible.
5. **La transmisión depende del espectro.** Un CTO sobre daylight pierde más que sobre tungsteno. La tabla usa el valor a 3200 K; en daylight verificar la columna de notas.
6. **ND variable.** Viñeteo, patrón de X, dominante y pérdida de nitidez, sobre todo en el máximo. No usarlo en el extremo; no reemplaza a un ND fijo para tomas críticas.
7. **Polarizador.** La pérdida real depende de la orientación y de la escena; el dato de 1.5–2 stops es una referencia. Un polarizador lineal puede arruinar la medición en cámaras con espejo divisorio.
8. **IRND.** El corte de IR es específico del sensor y del fabricante; la densidad extra no está estandarizada. **NO VERIFICADO** cuánto añade cada modelo. Probar negros, piel y telas negras.
9. **Geles y calor.** Los geles se decoloran y cambian transmisión con el calor y el tiempo. Un gel viejo puede haber perdido saturación y detalle espectral; no confiar en el catálogo para una corrección fina.
10. **Difusión.** El stop de catálogo (216 = 1.5; 250 = 0.75; 251 = 0.33; 252 <0.25) depende del ángulo del haz y de la distancia. En un fresnel muy abierto la pérdida puede ser mayor.
11. **LED y minus green.** El pico verde cambia por modelo, potencia y dimming. 1/4 y 1/2 minus green son puntos de partida, no una corrección universal. Medir con cámara y monitor calibrado.
12. **Doble corrección en digital.** Poner un 85/80A y además balancear la cámara a tungsteno/daylight puede duplicar el efecto. Definir primero la balance de la cámara y después el filtro.
13. **Datos en disputa.** 81A: Tiffen publica 1/3 stop pero el factor 1.4 implica ~1/2. 85C: Tiffen publica 0.3 stop y algunas tablas 2/3. Rosco 3407: +167 publicado vs. ≈+163 calculado desde 5500→2900 K. Documentar la fuente elegida.
14. **Datos calculados.** ND 0.45/0.75, mired de Rosco 3409/3410/3411/3208/3216 y varias transmisiones son derivados de fórmulas o de la conversión Kelvin publicada, no mediciones independientes. Están marcados en las tablas.
15. **Seguridad.** Un ND no es un filtro solar; nunca mirar al sol a través de la cámara con ND. Para sol directo usar filtros certificados ISO 12312-2.
