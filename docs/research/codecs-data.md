# Catálogo de códecs de cámara y flujos de datos (storage / DIT)

**Proyecto:** On Set Pro — módulo de dirección de fotografía
**Archivo:** `onset-docs/research/codecs-data.md`
**Fecha de recolección:** 2026-11-12
**Uso previsto:** alimentar el catálogo en Dart (`codec|resolucion|fps|mbps|notas` + `soporte|...`)

---

## 0. Convenciones, unidades y niveles de confianza

| Símbolo | Significado | Nota |
|---|---|---|
| **Mbps** | megabits por segundo (decimal, 10⁶) | Es la unidad de los white papers de Apple, Sony, ARRI (los de ARRI van en Gbit/s o GB/h). |
| **MB/s** | megabytes por segundo (decimal, 10⁶ bytes) | `MB/s = Mbps / 8`. |
| **GB/h** | gigabytes por hora (decimal, 10⁹ bytes/h) | `GB/h = MB/s × 3,6`. |
| **GiB/h** | gibibytes por hora (2³⁰) | **No** lo usa ningún fabricante citado; no mezclar. |

> ⚠️ **Trampa clásica:** ARRI publica "2.055 GB/h" en su tabla de la ALEXA 35. Son **2.055 GB/h decimales
> = 2,055 TB/h**, no 2.055 *gigabytes por hora*. Un cálculo naíf de 12 bits da 1.890 GB/h y "no cierra";
> la diferencia es que la ALEXA 35 graba ARRIRAW a **13 bits**, no 12 (§1).

**Niveles de confianza usados en todo el documento:**

- **OFICIAL** — cifra publicada textualmente por el fabricante (tabla o ficha). Ver batim.
- **CALCULADO** — derivada de una fórmula oficial + parámetros oficiales (p. ej. resolución y bit depth).
  Se indica siempre la fórmula y el punto de control contra el que se validó.
- **NO VERIFICADO** — no se encontró dato oficial. **No se rellena con estimaciones.**

**Sobre fps:** casi todos los fabricantes publican la tabla a **23.98/24**, **25** y **29.97/30**.
El valor exacto a 29.97 es ~0,1 % menor que a 30; ninguna tabla oficial hace esa distinción,
así que se usa el valor publicado para "29.97/30" y se anota.

---

## 1. ARRIRAW

### 1.1 Fórmula exacta

ARRIRAW es **RAW sin comprimir y sin encriptar**: no hay ratio de compresión que aplicar, solo
resolución × profundidad de bits × fps.

```
bytes_por_fotograma = ancho × alto × (bit_depth / 8)
MB/s                = bytes_por_fotograma × fps / 1.000.000
Mbps                = MB/s × 8
GB/h                = MB/s × 3.600 / 1.000
```

`bytes por fotosito`:

| Cámara | Bit depth ARRIRAW | Bytes/fotosito |
|---|---|---|
| ALEXA 35 | **13-bit Log** (procesa 18-bit lineal interno) | **1,625 B** |
| ALEXA Mini LF / ALEXA LF | **12-bit** | **1,5 B** |
| ALEXA 65 | 12-bit | 1,5 B |

**Validación del bit depth de la ALEXA 35:** la guía rápida de ARRI lista literalmente
"Procesamiento lineal de 18 bits en cámara / **ARRIRAW: 13-bit Log** / Apple ProRes: 12-bit Log".
Con 13 bits el cálculo coincide con la tabla oficial de ARRI a 0,4 % (la diferencia es el audio
y las cabeceras, que la tabla de ARRI incluye explícitamente: *"Data Rate @ 24 fps (incl. audio)"*).

### 1.2 ALEXA 35 — 4.6K 3:2 Open Gate (4608 × 3164)

`4608 × 3164 = 14.579.712 fotositos × 13 bits = 189.536.256 bits = 23.692.032 B = 23,69 MB/frame`

| fps | MB/frame | MB/s | Mbps | GB/h | Control |
|---|---|---|---|---|---|
| 24 | 23,69 | **568,6** | **4.549** | **2.047** | ARRI publica **2.055 GB/h** (incl. audio) ✅ |
| 25 | 23,69 | 592,3 | 4.738 | 2.132 | — |
| 30 | 23,69 | 710,8 | 5.686 | 2.559 | — |
| 48 | 23,69 | 1.137,2 | 9.098 | 4.094 | — |
| 60 | 23,69 | 1.421,5 | 11.372 | 5.117 | máx. del modo: 60 fps (75 fps con Compact Drive 2 TB) |

**Duraciones oficiales (Compact Drive):** 24 fps → **0:28 en 1 TB**, **0:56 en 2 TB**.
Nótese que 2.055 GB/h × 0,4667 h = 959 GB: ARRI cuenta ~955–960 GB útiles por drive "1 TB".
Ese detalle importa para la calculadora de la app (ver §8 y RIESGOS).

### 1.3 ALEXA Mini LF — 4.5K LF 3:2 Open Gate (4448 × 3096)

`4448 × 3096 = 13.771.008 fotositos × 12 bits = 165.252.096 bits = 20.656.512 B = 20,66 MB/frame`

| fps | MB/frame | MB/s | Mbps | GB/h |
|---|---|---|---|---|
| 24 | 20,66 | **495,8** | **3.966** | **1.785** |
| 25 | 20,66 | 516,4 | 4.131 | 1.859 |
| 30 | 20,66 | 619,7 | 4.958 | 2.231 |
| 40 (máx. del modo) | 20,66 | 826,3 | 6.610 | 2.975 |

**Control cruzado:** ARRI publica para Mini LF 4.5K LF 3:2 Open Gate **0:32 de grabación en 1 TB a 24 fps**.
1.785 GB/h × (32/60) h = 952 GB → consistente con la misma convención de capacidad útil que la ALEXA 35.
Por eso el valor de 12 bits se marca **CALCULADO validado** y no "inventado".

> ⚠️ **No confundir 4.6K de la ALEXA 35 con 4.5K de la Mini LF.** Cambia resolución (4608×3164 vs 4448×3096)
> **y** bit depth (13 vs 12). Un catálogo que use una sola fórmula "12-bit" sobrestima la Mini LF en ~0 %
> pero **subestima la ALEXA 35 en un 8,3 %**.

### 1.4 ARRIRAW HDE

ARRI distribuye un *ARRIRAW HDE Transcoder* (compresión sin pérdida, "High Density Encoding").
**NO VERIFICADO**: no se encontró tasa ni factor de reducción oficial publicado en las fuentes consultadas.
→ En la app: ofrecer HDE como *flag* cualitativo, nunca como número.

**Fuentes**
- ARRI, *ALEXA 35 User Manual SUP 1.0*, §25.1 "Data Rates, Recording Times and Max. FPS" (tabla completa por sensor mode) — https://movie-men.com/wp-content/uploads/2022/08/ALEXA-35-SUP-1.0-User-Manual.pdf (copia espejo del manual oficial; el original vive en arri.com/technical-documentation)
- ARRI, *ALEXA 35 Quick Guide* (ARRIRAW 13-bit Log, sensor 4608×3164) — https://www.videocineimport.com/wp-content/uploads/2022/06/Quick_guide_Alexa35V01.pdf
- ARRI, *ALEXA Mini LF SUP 7.1 Release Notes* (tabla de formatos y "Compact Drive 1TB 0:32 @ 24 fps") — https://www.arri.com/resource/blob/248088/9d5c0847f148449fb75d1195cd783341/release-notes-sup-7-1-beta-data.pdf
- ARRI, *Formats & Data Rate Calculator* (herramienta oficial; útil para contrastar la implementación Dart) — https://www.arri.com/en/technical-documentation

---

## 2. Apple ProRes (Proxy, LT, 422, 422 HQ, 4444, 4444 XQ)

### 2.1 Tabla oficial de velocidades de datos finales

Valores **Mbps** tal como los publica el libro blanco de Apple (apéndice "Velocidades de datos finales").
La fila "60i, 30p" es la que cubre **29.97/30 fps**.

**1920 × 1080 — 29.97/30 fps (fila "60i, 30p")**

| Códec | Mbps | MB/s | GB/h |
|---|---|---|---|
| ProRes 422 Proxy | **45** | 5,6 | 20 |
| ProRes 422 LT | **102** | 12,8 | 46 |
| ProRes 422 | **147** | 18,4 | 66 |
| ProRes 422 HQ | **220** | 27,5 | 99 |
| ProRes 4444 (sin alfa) | **330** | 41,2 | 148 |
| ProRes 4444 XQ (sin alfa) | **495** | 61,9 | 223 |

**3840 × 2160 (UHD) — 30p**

| Códec | Mbps | MB/s | GB/h |
|---|---|---|---|
| ProRes 422 Proxy | **182** | 22,8 | 82 |
| ProRes 422 LT | **410** | 51,2 | 185 |
| ProRes 422 | **589** | 73,6 | 265 |
| ProRes 422 HQ | **884** | 110,5 | 398 |
| ProRes 4444 (sin alfa) | **1.326** | 165,8 | 597 |
| ProRes 4444 XQ (sin alfa) | **1.989** | 248,6 | 895 |

**4096 × 2160 (4K DCI) — 30p**

| Códec | Mbps | MB/s | GB/h |
|---|---|---|---|
| ProRes 422 Proxy | **194** | 24,2 | 87 |
| ProRes 422 LT | **437** | 54,6 | 197 |
| ProRes 422 | **629** | 78,6 | 283 |
| ProRes 422 HQ | **943** | 117,9 | 424 |
| ProRes 4444 (sin alfa) | **1.414** | 176,8 | 636 |
| ProRes 4444 XQ (sin alfa) | **2.121** | 265,1 | 955 |

**Referencia a 24p y 25p** (para interpolación y para el catálogo):

| Resolución | fps | Proxy | LT | 422 | 422 HQ | 4444 | 4444 XQ |
|---|---|---|---|---|---|---|---|
| 1920×1080 | 24p | 36 | 82 | 117 | 176 | 264 | 396 |
| 1920×1080 | 25p | 38 | 85 | 122 | 184 | 275 | 413 |
| 3840×2160 | 24p | 145 | 328 | 471 | 707 | 1.061 | 1.591 |
| 4096×2160 | 24p | 155 | 350 | 503 | 754 | 1.131 | 1.697 |

(Valores en **Mbps**; todos tomados de la misma tabla del apéndice del libro blanco.)

> **Nota 4444 XQ:** el texto del white paper dice "aproximadamente 500 Mb/s" para 1080p29.97,
> pero la tabla del apéndice dice **495**. Usar 495 (la tabla es el dato duro; el texto es redondeo).

### 2.2 Cómo escala

ProRes es **VBR**, pero con un *target* fijo de **bits por fotograma** por códec. Por eso, en primera
aproximación, la tasa escala **linealmente** con fps y con cantidad de píxeles:

```
mbps(fps, W, H) ≈ mbps_ref × (fps / fps_ref) × ( (W×H) / (W_ref×H_ref) )
```

Verificación contra la tabla oficial (ProRes 422 HQ, ref 1920×1080@30 = 220 Mbps):

| Caso | Fórmula | Oficial | Error |
|---|---|---|---|
| 1920×1080 @ 60p | 220 × 2 = 440 | **440** | 0 % |
| 3840×2160 @ 30p | 220 × 4 = 880 | **884** | +0,5 % |
| 4096×2160 @ 30p | 220 × 4,2667 = 938,7 | **943** | +0,5 % |

→ El error de la fórmula lineal es **< 1 %**. Sirve para cualquier resolución/fps no listada.
Advertencia: los redondeos de Apple van en el sentido del múltiplo de 4, así que para un catálogo
"exacto" conviene guardar la tabla y usar la fórmula solo como fallback.

**Sobre el VBR real:** el white paper aclara que el pico por fotograma puede llegar a ~**10 % por encima**
del target, y que los fotogramas simples usan bastante menos. Para duración de toma y para copia,
**planificar con el target**, no con el pico.

**Fuentes**
- Apple, *Apple ProRes — Libro blanco*, junio 2014 (apéndice "Velocidades de datos finales", pp. 21-22; §"Velocidad de datos") — https://www.apple.com/support/assets/docs/products/finalcutpro/Apple_ProRes_June_2014_loc_es_GLOBAL.pdf
- Apple, *Apple ProRes* (página oficial de la familia de códecs) — https://www.apple.com/final-cut-pro/docs/Apple_ProRes.pdf

---

## 3. Sony X-OCN (XT, ST, LT)

### 3.1 Qué es y relación con 16-bit lineal

X-OCN es el RAW comprimido de Sony: **16-bit scene linear**, con codificación **CBR** (bitrate constante,
no depende de la complejidad de la imagen — relevante para la app: la duración de toma es predecible).

Relación respecto a **16-bit lineal sin comprimir** (`W×H×2 B×fps`), medida sobre la tabla oficial
de VENICE 2 a 24p:

| Perfil | Ratio vs 16-bit lineal | % del 16-bit lineal |
|---|---|---|
| X-OCN **XT** | ≈ **3,6 : 1** | ~28 % |
| X-OCN **ST** | ≈ **5,2 : 1** | ~19 % |
| X-OCN **LT** | ≈ **8,8 : 1** | ~11 % |

Cálculo: 8.6K 3:2 (8640×5760) a 24p sin comprimir = 8640×5760×2×24 = **2.388,8 MB/s (19.119 Mbps)**.
XT 5.345 → 3,58:1 · ST 3.658 → 5,23:1 · LT 2.155 → 8,87:1.
El ratio se mantiene en 6K (XT 2.631 → 3,56:1), o sea que **escalan lineal con píxeles y fps**.

### 3.2 VENICE 2 — 23.98/24.0p (tabla oficial, Mbps)

**Sensor 8K**

| Perfil | 8.6K 3:2 | 8.6K 17:9 | 8.2K 2.39:1 | 8.2K 17:9 | 8.1K 16:9 | 7.6K 16:9 | 5.8K 6:5 | 5.8K 4:3 | 5.8K 17:9 | 5.5K 2.39:1 | 5.4K 16:9 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| X-OCN XT | **5.345** | 4.233 | 3.079 | 3.861 | 4.233 | 3.861 | 3.040 | 2.676 | 1.919 | 1.446 | 1.919 |
| X-OCN ST | **3.658** | 2.897 | 2.107 | 2.642 | 2.897 | 2.642 | 2.080 | 1.832 | 1.313 | 990 | 1.313 |
| X-OCN LT | **2.155** | 1.706 | 1.241 | 1.556 | 1.706 | 1.556 | 1.225 | 1.079 | 773 | 583 | 773 |

**Sensor 6K**

| Perfil | 6K 3:2 | 6K 1.85:1 |
|---|---|---|
| X-OCN XT | **2.631** | 2.143 |
| X-OCN ST | **1.800** | 1.467 |
| X-OCN LT | **1.061** | 864 |

**Equivalencias en MB/s (8.6K 3:2 y 8.6K 17:9):**

| Perfil | 8.6K 3:2 MB/s | 8.6K 17:9 MB/s |
|---|---|---|
| XT | 668,1 | 529,1 |
| ST | 457,3 | 362,1 |
| LT | **269,4** | **213,3** |

**Control cruzado:** Sony afirma en texto que *"at 24fps 8.6K 17:9 X-OCN LT is 1,706 Mbps while
4K ProRes 4444 XQ is 1,911 Mbps"*. La tabla da exactamente **1.706** en esa celda → la lectura de
la tabla es correcta.

> ⚠️ **Discrepancia detectada (no propagar):** Sony cita 1.911 Mbps para "4K ProRes 4444 XQ", pero la
> tabla oficial de Apple da **1.697 Mbps** para 4096×2160 a 24p (§2). No coinciden. Probablemente Sony
> se refiera a otro raster o a 4444 XQ **con** alfa. Se deja como **NO VERIFICADO**; para ProRes,
> la fuente de verdad es Apple.

### 3.3 BURANO — 23.98/24p (X-OCN LT, Mbps)

| FF 8.6K 16:9 | FF 8.6K 17:9 | FFc 6K 16:9 | FFc 6K 17:9 | S35 5.8K 16:9 | S35 5.8K 17:9 | S35c 4K 17:9 |
|---|---|---|---|---|---|---|
| 1.812 | 1.699 | 894 | 838 | 813 | 762 | 385 |

A 60p (misma fuente): FFc 6K 16:9 = **2.235**, S35 5.8K 16:9 = **2.032**, S35c 4K = **962**.
→ Doblar fps un 2,5× escala ~2,5× la tasa (CBR, como se esperaba).

**Fuentes**
- Sony, *X-OCN White Paper v2.0* (secciones "X-OCN Specifications / Recording Bitrate" y "Recording Time"; tablas VENICE 2 8K, VENICE 2 6K y BURANO) — https://77snszqv.media.zestyio.com/Sony-Cine_Sony_X-OCN_WhitePaper_v2.0.pdf
- Sony, *Download the X-OCN White Paper* (portal del documento) — https://sony-cinematography.com/articles/download-the-xocn-white-paper/
- Sony, *X-OCN Workflow Benefits* (nota sobre 8.6K 17:9 LT = 1.706 Mbps a 24p) — https://pro.sony/s3/2018/06/01110529/X-OCN-Workflow-Benefits-2023.pdf (requiere navegador; bloquea descarga directa por Akamai)

---

## 4. REDCODE RAW (R3D)

### 4.1 Fórmula

REDCODE RAW comprime el RAW de sensor de **16 bits**. El ratio (3:1, 5:1, 8:1…) es, por definición,
**RAW de 16 bits sin comprimir ÷ tamaño grabado**:

```
MB/s = (ancho × alto × 2 bytes × fps) / ratio / 1.000.000
Mbps = MB/s × 8
```

### 4.2 Validación contra un dato oficial de RED

RED publica en la ficha técnica de la EPIC-W (HELIUM 8K) que el **"best available REDCODE" para
8K Full Format (8192×4320) a 24 fps es 6:1**, y que la **"Max Data Rate" es 275 MB/s** con MINI-MAG.

Fórmula: `8192 × 4320 × 2 × 24 = 1.698,7 MB/s / 6 = 283,1 MB/s`.
→ 283 MB/s calculado vs **275 MB/s** declarado como techo de la tarjeta: el ratio de 16 bits queda
confirmado (±3 %, dentro del redondeo comercial de RED). **No es una estimación.**

### 4.3 Tabla (CALCULADO sobre la fórmula validada)

**8K VV — 8192 × 4320 (16-bit base = 1.698,7 MB/s a 24p)**

| Ratio | 24 fps MB/s | 24 fps Mbps | 30 fps MB/s | 60 fps MB/s |
|---|---|---|---|---|
| 3:1 | **566,2** | 4.530 | 707,8 | 1.415,6 |
| 5:1 | **339,7** | 2.718 | 424,7 | 849,3 |
| 6:1 | **283,1** | 2.265 | 353,9 | 707,8 |
| 8:1 | **212,3** | 1.699 | 265,4 | 530,8 |
| 12:1 | **141,6** | 1.132 | 176,9 | 353,9 |
| 18:1 | **94,4** | 755 | 118,0 | 235,9 |

**4K 17:9 — 4096 × 2160 (16-bit base = 424,7 MB/s a 24p)**

| Ratio | 24 fps MB/s | 24 fps Mbps | 60 fps MB/s |
|---|---|---|---|
| 3:1 | 141,6 | 1.132 | 353,9 |
| 5:1 | 84,9 | 680 | 212,3 |
| 8:1 | 53,1 | 425 | 132,7 |
| 12:1 | 35,4 | 283 | 88,5 |
| 18:1 | 23,6 | 189 | 59,0 |

### 4.4 Nomenclatura en cámaras actuales (V-RAPTOR / DSMC3)

Las V-RAPTOR **no** exponen "3:1 / 5:1…" sino niveles **HQ, MQ, LQ, ELQ**. La ficha oficial dice:

> *Best Available REDCODE: HQ, MQ, LQ y ELQ a 8K 17:9 hasta 60 fps; **LQ y ELQ a 8K 17:9 hasta 120 fps**.*
> *Max Data Rates: **hasta 800 MB/s** con CFexpress calificadas.*

Control de coherencia: 8K 17:9 a 120 fps en 16-bit = 8.493 MB/s. Para entrar en 800 MB/s hace falta
un ratio ≥ 10,6:1 → encaja con que a 120 fps solo estén habilitados LQ/ELQ. Consistente.

**NO VERIFICADO:** la equivalencia numérica exacta de HQ/MQ/LQ/ELQ a ratios (5:1, 7:1, 9:1, 12:1…)
**no está publicada** por RED en las fuentes consultadas. No la hardcodees: modelá `HQ|MQ|LQ|ELQ`
como enum y dejá el ratio como campo opcional "desconocido".

**Fuentes**
- RED, *Benefits & Evolution of REDCODE RAW* (§"Data Rate") — https://docs.red.com/955-0179/REV-B/Benefits%20%26%20Evolution%20of%20REDCODE%20RAW.pdf
- RED, *V-RAPTOR [X] 8K VV Operation Guide — Technical Specifications* (Max Data Rates 800 MB/s; Best Available REDCODE) — https://docs.red.com/955-0225/955-0225_V2.0%20Rev-B%20RED%20PS,%20V-RAPTOR%20%5BX%5D%208K%20VV%20Operation%20Guide%20HTML/Content/B_TechSpecs/Specs_V-RAPTOR%20%5BX%5D.htm
- RED, *EPIC-W HELIUM Operation Guide v7.4* ("Max Data Rates Up to 275 MB/s using RED MINI-MAG"; "6:1 REDCODE for 8K Full Format at 24 fps") — https://docs.red.com/955-0138_v7.4/955-0138_V7.4-EPIC-W_HELIUM_Operation_Guide_v7_4.pdf

---

## 5. Blackmagic RAW

### 5.1 Ratios y naturaleza

- **Ratio constante (CBR):** 3:1, 4:1, 5:1, 6:1, 8:1, 12:1, 18:1 (la disponibilidad depende del modelo:
  la URSA Cine 12K no ofrece 4:1 ni 6:1; la URSA Mini Pro 12K no ofrece 3:1).
- **Calidad constante (VBR):** **Q0, Q1, Q3, Q5** → BMD publica **rangos** (mín–máx), no un valor.
  En la app: para Q*, mostrar rango y usar el **máximo** para planificar almacenamiento.
- Base de cálculo: **12 bits por fotosito** (`W×H×1,5 B×fps`). Verificado: 12K 12288×8040 a 24p
  → 3.556 MB/s / 3 = 1.185 MB/s calculado vs **1.194 MB/s** publicado (0,7 % de overhead de contenedor).

```
MB/s ≈ (ancho × alto × 1,5 × fps) / ratio / 1.000.000       [CBR]
```

### 5.2 URSA Cine 12K LF — 12K 12288 × 8040 @ 24 fps (OFICIAL)

| Ratio | MB/s | Mbps |
|---|---|---|
| BRAW 3:1 | **1.194** | 9.552 |
| BRAW 8:1 | **448** | 3.584 |
| BRAW 12:1 | **299** | 2.392 |
| BRAW 18:1 | **199** | 1.592 |
| BRAW Q0 | **398 – 1.433** | 3.184 – 11.464 |
| BRAW Q1 | **326 – 796** | 2.608 – 6.368 |
| BRAW Q3 | **179 – 448** | 1.432 – 3.584 |
| BRAW Q5 | **120 – 358** | 960 – 2.864 |

**8K 8192 × 5360 @ 24 fps:** 3:1 **533** · 5:1 **320** · 8:1 **200** · 12:1 **133** MB/s.
Q0 320–639 · Q1 228–533 · Q3 133–400 · Q5 100–266 MB/s.

**4K 4096 × 2680 @ 24 fps:** 3:1 **135** · 4:1 **101** · 5:1 **81** · 6:1 **68** MB/s.

### 5.3 URSA Mini Pro 12K — 12K 12288 × 6480 @ 24 fps (OFICIAL)

| Ratio | MB/s | Mbps |
|---|---|---|
| BRAW 5:1 | **578** | 4.624 |
| BRAW 8:1 | **361** | 2.888 |
| BRAW 12:1 | **241** | 1.928 |
| BRAW 18:1 | **160** | 1.280 |
| BRAW Q0 | **289 – 1.156** | 2.312 – 9.248 |
| BRAW Q1 | **241 – 963** | 1.928 – 7.704 |
| BRAW Q3 | **145 – 722** | 1.160 – 5.776 |
| BRAW Q5 | **97 – 413** | 776 – 3.304 |

**8K 8192 × 4320 @ 24 fps:** 5:1 **257** · 8:1 **161** · 12:1 **107** · 18:1 **71** MB/s.
**6K S16 6144 × 3240 @ 24 fps:** 5:1 **146** · 8:1 **91** · 12:1 **61** · 18:1 **40** MB/s.

> BMD publica además las equivalencias de Q por resolución:
> *12K/17K:* Q0 9:1–2,5:1 · Q1 11:1–4,5:1 · Q3 20:1–8:1 · Q5 30:1–10:1.
> *8K:* Q0 5:1–2,5:1 · Q1 7:1–3:1 · Q3 12:1–4:1 · Q5 16:1–6:1.
> *4K:* Q0 2:1–1,2:1 · Q1 3:1–1,3:1 · Q3 4:1–1,7:1 · Q5 5:1–2:1.
> Y la advertencia textual: *"Actual storage rates are dependent on image subject matter"*.

**Fuentes**
- Blackmagic Design, *Blackmagic URSA Cine 12K LF — Tech Specs* (§Storage Rates) — https://www.blackmagicdesign.com/products/blackmagicursacine/techspecs/W-URSA-73
- Blackmagic Design, *Blackmagic URSA Mini Pro 12K — Tech Specs* (§Storage Rates) — https://www.blackmagicdesign.com/products/blackmagicursaminipro/techspecs/W-CIN-12

---

## 6. H.265/HEVC, H.264 y familia XAVC

### 6.1 XAVC-I (intra, H.264, 4:2:2 10-bit)

| Formato | fps | Mbps | MB/s | Notas |
|---|---|---|---|---|
| XAVC-I QFHD 3840×2160 | 59.94/50p | **600** | 75,0 | CBG, "Class 600" |
| XAVC-I 4K 4096×2160 | 29.97p | **300** | 37,5 | VBR máx, "Class 300" |
| XAVC-I QFHD 3840×2160 | 29.97/25p | **300** | 37,5 | Class 300 |
| XAVC-I 4K/QFHD | 23.98p | **240** | 30,0 | Class 240 |
| XAVC-I HD 1920×1080 | 59.94p | **222** | 27,8 | CBG |
| XAVC-I HD 1920×1080 | 50p | **223** | 27,9 | CBG |
| XAVC-I HD 1920×1080 | 29.97p | **111** | 13,9 | CBG |
| XAVC-I HD 1920×1080 | 25p | **112** | 14,0 | CBG |
| XAVC-I HD 1920×1080 | 23.98p | **89** | 11,1 | CBG |

### 6.2 XAVC-L (Long GOP, H.264)

| Formato | fps | Mbps | MB/s |
|---|---|---|---|
| XAVC-L QFHD 3840×2160 | 59.94/50p | **150** (máx) | 18,8 |
| XAVC-L QFHD | 29.97/25p | **100** (máx) | 12,5 |
| XAVC-L HD "50" | 59.94p/50p | **50** (máx) | 6,3 |
| XAVC-L HD "35" | 29.97/25p | **35** (máx) | 4,4 |

### 6.3 XAVC HS (HEVC / H.265, 10-bit)

| Formato | fps | Mbps | Croma |
|---|---|---|---|
| XAVC HS 4K | 119.88/100p | **280** | 4:2:2 10-bit |
| XAVC HS 4K | 119.88/100p | **200** | 4:2:0 10-bit |
| XAVC HS 4K | 59.94/50p | **200** | 4:2:2 10-bit |
| XAVC HS 4K | 59.94/50p | **150 / 100 / 75 / 45** | 4:2:0 / mixto |
| XAVC HS 4K | 23.98p | **100 / 50 / 30** | 4:2:0 y 4:2:2 |

### 6.4 H.264 / H.265 "genéricos" — qué usar como referencia

No existe una tabla única: dependen del encoder y del contenido. Para el catálogo, anclá en:

| Familia | Rango típico | Uso en la app |
|---|---|---|
| H.264 Long GOP prosumer | **35 – 150 Mbps** | XAVC-L / AVCHD alto |
| H.264 Intra profesional | **89 – 600 Mbps** | XAVC-I |
| H.265/HEVC 4K | **30 – 280 Mbps** | XAVC HS, drones, mirrorless |
| H.264 proxy / streaming | **10 – 50 Mbps** | Proxies de cámara, H.264 proxy BMD 1080p |

> ⚠️ Para **H.264/H.265 nunca prometas un número exacto** salvo que sea un modo nominal de cámara
> (XAVC HS 200M, XAVC-L 150M…). Son VBR agresivos: el mismo modo puede variar ±30 % según escena.

**Fuentes**
- Sony, *PXW-FX9 Specifications / Recording Format* (XAVC-I DCI4K 300 Mbps, HD 222/223/111/112/89 Mbps) — https://pro.sony/bp_BR/pdf/products/handheld-camcorders/pxw-fx9
- Sony, *ILME-FX6 Specifications* (misma tabla XAVC-I / XAVC-L) — https://www.sony.co.nz/interchangeable-lens-cameras/products/ilme-fx6/spec
- Sony, *ILME-FX3 Specifications* (XAVC HS 4K 280/200/150/100/75/45 Mbps, HEVC) — https://www.sony.com/fr-ga/interchangeable-lens-cameras/products/ilme-fx3/spec
- Sony, *XAVC Profiles and Operating Points v2.10* (definición normativa de clases y bitrates máximos) — https://assets.pro.sony.eu/Web/supportcontent/XAVC_Profiles_and_OperatingPoints_210.pdf

---

## 7. Soportes físicos: velocidades sostenidas reales

### 7.1 El problema "pico vs sostenido"

Todos los fabricantes publican **"up to"** (pico de ráfaga, normalmente con SLC cache y durante pocos
segundos). Para calcular duración de toma y tiempos de copia hace falta la **velocidad sostenida**.

Solo tres fabricantes de los consultados publican un número **garantizado de escritura sostenida**:

- **Lexar** — "minimum sustained write speed" (Diamond: 1.600 MB/s).
- **Angelbird** — "minimum sustained write speed" (AV PRO MK2 Type B: 1.300 MB/s).
- **SanDisk / Sony** — vía certificación **VPG** (Video Performance Guarantee): VPG-130 = 130 MB/s
  mínimos sostenidos; VPG-400 = 400 MB/s mínimos sostenidos.

El resto: **NO VERIFICADO** como sostenido.

### 7.2 CFexpress Type B

| Producto | Escritura pico | Lectura pico | Escritura sostenida | Cert. |
|---|---|---|---|---|
| SanDisk Extreme PRO CFexpress Type B | **1.400 MB/s** | **1.700 MB/s** | NO VERIFICADO | — |
| Sony CEB-G (Tough) | **1.750 MB/s** | **1.850 MB/s** | NO VERIFICADO (≥400 por VPG400 en G960T/G1920T) | VPG400 |
| Lexar Professional Diamond | **1.700 MB/s** | **1.900 MB/s** | **1.600 MB/s** (mín. garantizado) | VPG400 |
| Angelbird AV PRO CFexpress MK2 | **1.550 MB/s** | **1.785 MB/s** | **1.300 MB/s** (mín. garantizado) | — |

### 7.3 CFexpress Type A

| Producto | Escritura pico | Lectura pico | Sostenida | Cert. |
|---|---|---|---|---|
| Sony CEA-G (Gen3, 80–640 GB) | **700 MB/s** | **800 MB/s** | NO VERIFICADO (VPG400) | VPG400 |
| Sony CEA-G (Gen4) | **1.700 MB/s** | **1.800 MB/s** | NO VERIFICADO | VPG400 |

> Type A es **el cuello de botella más subestimado** del mercado: pico de 700–800 MB/s, pero el mínimo
> **sostenido garantizado es 400 MB/s** (VPG400). Con eso **no se sostiene ARRIRAW 4.6K (568,6 MB/s)**
> ni X-OCN XT 8.6K (668,1 MB/s). Solo válido para ProRes, XAVC y BRAW Q5.

### 7.4 CFast 2.0

| Producto | Escritura pico | Lectura pico | Sostenida | Cert. |
|---|---|---|---|---|
| SanDisk Extreme PRO CFast 2.0 | **450 MB/s** | **525 MB/s** | **130 MB/s** (garantizado) | VPG-130 |

> CFast 2.0 es **SATA III**: 525 MB/s es el techo físico del bus. No hay margen para más.
> Por eso no sirve para ARRIRAW 4.6K (568 MB/s) ni para BRAW 12K 3:1 — pero sí para ProRes 4444 XQ 4K.

### 7.5 SD UHS-II

| Producto | Escritura pico | Lectura pico | Sostenida | Cert. |
|---|---|---|---|---|
| SanDisk Extreme PRO SDHC/SDXC UHS-II | **260 MB/s** | **300 MB/s** | NO VERIFICADO | U3 |
| SanDisk Extreme PRO SD UHS-II **V90** | **260 – 300 MB/s** | **300 MB/s** | **90 MB/s** (mínimo, V90) | V90 |

> El número que importa de una V90 es **90 MB/s sostenidos**, no los 300 de pico. Es 1/6 del pico.

### 7.6 SSD externos

| Producto | Escritura | Lectura | Interfaz | Nota |
|---|---|---|---|---|
| Samsung T7 Shield | **1.000 MB/s** | **1.050 MB/s** | USB 3.2 Gen 2 (10 Gb/s) | techo real del bus ≈ 1.000 MB/s |
| SSD NVMe en enclosure USB 3.2 Gen 2 | ≈ 900–1.000 MB/s | ≈ 1.000 MB/s | 10 Gb/s | NO VERIFICADO por fabricante |
| SSD NVMe en enclosure Thunderbolt 3/4 | NO VERIFICADO | NO VERIFICADO | 40 Gb/s | necesario para exprimir CFexpress B |

**Regla de oro para la app:** el **bus** manda. Un lector CFexpress B USB 3.2 Gen 2 **nunca** pasa de
~1.000 MB/s aunque la tarjeta haga 1.700. Para copiar a velocidad de tarjeta hace falta
lector + destino en **Thunderbolt/USB4**.

**Fuentes**
- SanDisk, *Extreme PRO CFexpress Type B* (hasta 1.700 MB/s lectura / 1.400 MB/s escritura) — https://www.sandisk.com/products/memory-cards/cfast-cfexpress-compactflash/sandisk-extreme-pro-cfexpress-type-b
- SanDisk, *Extreme PRO CFast 2.0* (525/450 MB/s; VPG-130 = mínimo sostenido 130 MB/s) — https://www.sandisk.com/products/memory-cards/cfast-cfexpress-compactflash/sandisk-extreme-pro-cfast-2-0
- SanDisk, *Extreme PRO SDHC/SDXC UHS-II* (300/260 MB/s; V90 = 90 MB/s mínimos) — https://www.sandisk.com/products/memory-cards/sd-cards/sandisk-extreme-pro-uhs-ii-sd
- Sony, *CEB-G Series CFexpress Type B* (1.850/1.750 MB/s, VPG400 en G960T/G1920T) — https://www.sony.co.nz/electronics/xqd-memory-cards/cfexpress-type-b-memory-card
- Sony, *CEA-G Series CFexpress Type A — Specifications* (800/700 MB/s Gen3; 1.800/1.700 MB/s Gen4) — https://www.sony.com.ar/electronics/tarjetas-de-memoria-xqd/cea-g-series/specifications
- Lexar, *Professional CFexpress 2.0 Type B DIAMOND Series* (1.900/1.700; sostenido 1.600 MB/s) — https://americas.lexar.com/product/lexar-professional-cfexpress-type-b-card-diamond-series/
- Angelbird, *AV PRO CFexpress B MK2* (máx. 1.785 lectura / 1.550 escritura; mínimo sostenido 1.300 MB/s) — https://www.angelbird.com/ (ficha reproducida por distribuidores autorizados: https://www.adorama.com/us1686432.html)
- Samsung, *Portable SSD T7 Shield* (1.050/1.000 MB/s, USB 3.2 Gen 2) — https://www.samsung.com/us/support/answer/ANS10002047/

---

## 8. Tiempo de copia DIT (fórmula correcta)

### 8.1 La fórmula que NO hay que usar

```
t = tamaño / velocidad_nominal        ❌
```

Falla porque: (a) la nominal es pico de ráfaga, (b) el destino nunca sostiene su nominal,
(c) hay overhead de sistema de archivos, verificación y contención.

### 8.2 Fórmula correcta

```
v_util   = min(v_lectura_sostenida_origen, v_escritura_sostenida_destino) × (1 − overhead)
t_copia  = tamaño_total / v_util
t_total  = t_copia + t_verificacion + t_operativo
```

- **overhead** = **0,20 – 0,30** (20–30 %) → `v_util ≈ 0,70–0,80 × v_nominal`.
- **t_verificacion** ≈ `t_copia × 0,6–1,0` si se hace checksum read-back (recomendado en set).
- **t_operativo** = montaje, reporte, renombre, 1–3 min por tarjeta.

**Por qué 20–30 % y no 10 %:** en copia real de DIT conviven archivos grandes (RAW) y miles de
archivos chicos (ProRes + sidecars), el destino suele ser un RAID/USB con su propia curva de
degradación, y el checksum agrega I/O.

### 8.3 Ejemplos verificables

**Caso A — ARRIRAW 4.6K 3:2, 1 hora de material**
- Tamaño: 2.047 GB/h → **~2.047 GB**
- Origen: Angelbird AV PRO MK2 → sostenido **1.300 MB/s**
- Destino: SSD USB 3.2 Gen 2 → sostenido real ≈ **800 MB/s** (no 1.000)
- `v_util = min(1300, 800) × 0,75 = 600 MB/s`
- `t_copia = 2.047.000 MB / 600 = 3.412 s ≈ **57 min**`
- Con verificación: **~1 h 45 min** por hora grabada. → **el DIT necesita ~2× tiempo real.**

**Caso B — ProRes 422 HQ UHD 30p, 1 hora**
- Tamaño: 398 GB/h → **398 GB**
- `v_util = min(1700, 800) × 0,75 = 600 MB/s`
- `t_copia = 398.000 / 600 = 663 s ≈ **11 min**`

**Caso C — BRAW 12K 3:1, 1 hora**
- Tamaño: 1.194 MB/s × 3.600 = **4.298 GB/h**
- `v_util = 600 MB/s` → `t_copia = 4.298.000 / 600 = 7.163 s ≈ **2 h por hora grabada**`
- ⚠️ **Inviable en un solo destino.** Requiere copia paralela a 2 destinos o downgrade de ratio.

### 8.4 Chequeos que la app debe hacer sola

1. `v_escritura_sostenida_destino >= mbps/8 × 1,25` (25 % de margen) — si no, **alerta roja**.
2. `v_lectura_sostenida_origen >= mbps/8 × 1,25`.
3. Si `ratio_toma / ratio_disco > 0,8` → avisar "destino al límite".
4. Capacidad: usar **GB decimales** y descontar 5 % de overhead de filesystem.

---

## TABLA PARA DART

### A) Códecs — `codec|resolucion|fps|mbps|notas`

> **`mbps` está en MEGABITS por segundo (bits).** Para MB/s dividir por 8.
> `fps` es el project rate. `notas` incluye la fuente abreviada y el equivalente en MB/s.

```
codec|resolucion|fps|mbps|notas
ARRIRAW|4608x3164|24|4549|ALEXA 35 13-bit Log; 568,6 MB/s; 2047 GB/h calc (ARRI: 2.055 GB/h c/audio); OFICIAL+CALC
ARRIRAW|4608x3164|25|4738|ALEXA 35; 592,3 MB/s; CALC
ARRIRAW|4608x3164|30|5686|ALEXA 35; 710,8 MB/s; CALC
ARRIRAW|4608x3164|48|9098|ALEXA 35; 1137,2 MB/s; CALC
ARRIRAW|4608x3164|60|11372|ALEXA 35; 1421,5 MB/s; max 60fps (75fps con 2TB); CALC
ARRIRAW|4448x3096|24|3966|ALEXA Mini LF 12-bit; 495,8 MB/s; 1785 GB/h; ARRI 0:32 en 1TB; OFICIAL+CALC
ARRIRAW|4448x3096|25|4131|ALEXA Mini LF; 516,4 MB/s; CALC
ARRIRAW|4448x3096|30|4958|ALEXA Mini LF; 619,7 MB/s; CALC
ARRIRAW|4448x3096|40|6610|ALEXA Mini LF; 826,3 MB/s; max 40fps; CALC
ProRes 422 Proxy|1920x1080|29.97|45|5,6 MB/s; tabla Apple 60i/30p; OFICIAL
ProRes 422 LT|1920x1080|29.97|102|12,8 MB/s; OFICIAL
ProRes 422|1920x1080|29.97|147|18,4 MB/s; OFICIAL
ProRes 422 HQ|1920x1080|29.97|220|27,5 MB/s; OFICIAL
ProRes 4444|1920x1080|29.97|330|41,2 MB/s; sin alfa; OFICIAL
ProRes 4444 XQ|1920x1080|29.97|495|61,9 MB/s; sin alfa; texto Apple dice ~500; OFICIAL
ProRes 422 Proxy|3840x2160|30|182|22,8 MB/s; OFICIAL
ProRes 422 LT|3840x2160|30|410|51,2 MB/s; OFICIAL
ProRes 422|3840x2160|30|589|73,6 MB/s; OFICIAL
ProRes 422 HQ|3840x2160|30|884|110,5 MB/s; OFICIAL
ProRes 4444|3840x2160|30|1326|165,8 MB/s; sin alfa; OFICIAL
ProRes 4444 XQ|3840x2160|30|1989|248,6 MB/s; sin alfa; OFICIAL
ProRes 422 Proxy|4096x2160|30|194|24,2 MB/s; OFICIAL
ProRes 422 LT|4096x2160|30|437|54,6 MB/s; OFICIAL
ProRes 422|4096x2160|30|629|78,6 MB/s; OFICIAL
ProRes 422 HQ|4096x2160|30|943|117,9 MB/s; OFICIAL
ProRes 4444|4096x2160|30|1414|176,8 MB/s; sin alfa; OFICIAL
ProRes 4444 XQ|4096x2160|30|2121|265,1 MB/s; sin alfa; OFICIAL
X-OCN XT|8640x5760|24|5345|VENICE2 8.6K 3:2; 668,1 MB/s; ~3,6:1 vs 16-bit lin; OFICIAL
X-OCN ST|8640x5760|24|3658|VENICE2 8.6K 3:2; 457,3 MB/s; ~5,2:1; OFICIAL
X-OCN LT|8640x5760|24|2155|VENICE2 8.6K 3:2; 269,4 MB/s; ~8,8:1; OFICIAL
X-OCN XT|8640x4576|24|4233|VENICE2 8.6K 17:9; 529,1 MB/s; OFICIAL
X-OCN ST|8640x4576|24|2897|VENICE2 8.6K 17:9; 362,1 MB/s; OFICIAL
X-OCN LT|8640x4576|24|1706|VENICE2 8.6K 17:9; 213,3 MB/s; confirmado en texto Sony; OFICIAL
X-OCN XT|6048x4032|24|2631|VENICE2 6K 3:2; 328,9 MB/s; OFICIAL
X-OCN ST|6048x4032|24|1800|VENICE2 6K 3:2; 225,0 MB/s; OFICIAL
X-OCN LT|6048x4032|24|1061|VENICE2 6K 3:2; 132,6 MB/s; OFICIAL
REDCODE 3:1|8192x4320|24|4530|566,2 MB/s; base 16-bit; CALC validado
REDCODE 5:1|8192x4320|24|2718|339,7 MB/s; CALC
REDCODE 6:1|8192x4320|24|2265|283,1 MB/s; RED publica 275 MB/s max en HELIUM; CALC validado
REDCODE 8:1|8192x4320|24|1699|212,3 MB/s; CALC
REDCODE 12:1|8192x4320|24|1132|141,6 MB/s; CALC
REDCODE 18:1|8192x4320|24|755|94,4 MB/s; CALC
REDCODE 5:1|8192x4320|60|6794|849,3 MB/s; CALC
REDCODE 5:1|4096x2160|24|680|84,9 MB/s; CALC
REDCODE 8:1|4096x2160|24|425|53,1 MB/s; CALC
BRAW 3:1|12288x8040|24|9552|URSA Cine 12K LF; 1194 MB/s; OFICIAL
BRAW 8:1|12288x8040|24|3584|URSA Cine 12K; 448 MB/s; OFICIAL
BRAW 12:1|12288x8040|24|2392|URSA Cine 12K; 299 MB/s; OFICIAL
BRAW 18:1|12288x8040|24|1592|URSA Cine 12K; 199 MB/s; OFICIAL
BRAW Q0|12288x8040|24|11464|VBR 398-1433 MB/s; usar max para storage; OFICIAL
BRAW Q1|12288x8040|24|6368|VBR 326-796 MB/s; OFICIAL
BRAW Q3|12288x8040|24|3584|VBR 179-448 MB/s; OFICIAL
BRAW Q5|12288x8040|24|2864|VBR 120-358 MB/s; OFICIAL
BRAW 5:1|12288x6480|24|4624|URSA Mini Pro 12K; 578 MB/s; OFICIAL
BRAW 8:1|12288x6480|24|2888|URSA Mini Pro 12K; 361 MB/s; OFICIAL
BRAW 12:1|12288x6480|24|1928|URSA Mini Pro 12K; 241 MB/s; OFICIAL
BRAW 18:1|12288x6480|24|1280|URSA Mini Pro 12K; 160 MB/s; OFICIAL
BRAW 5:1|8192x4320|24|2056|URSA Mini Pro 12K 8K; 257 MB/s; OFICIAL
BRAW 8:1|8192x4320|24|1288|URSA Mini Pro 12K 8K; 161 MB/s; OFICIAL
BRAW 5:1|6144x3240|24|1168|URSA Mini Pro 12K 6K S16; 146 MB/s; OFICIAL
XAVC-I|3840x2160|59.94|600|75,0 MB/s; CBG; OFICIAL
XAVC-I|4096x2160|29.97|300|37,5 MB/s; VBR max; Class 300; OFICIAL
XAVC-I|3840x2160|29.97|300|37,5 MB/s; Class 300; OFICIAL
XAVC-I|4096x2160|23.98|240|30,0 MB/s; OFICIAL
XAVC-I HD|1920x1080|59.94|222|27,8 MB/s; CBG; OFICIAL
XAVC-I HD|1920x1080|29.97|111|13,9 MB/s; CBG; OFICIAL
XAVC-I HD|1920x1080|23.98|89|11,1 MB/s; CBG; OFICIAL
XAVC-L|3840x2160|59.94|150|18,8 MB/s; VBR max; OFICIAL
XAVC-L|3840x2160|29.97|100|12,5 MB/s; VBR max; OFICIAL
XAVC-L HD|1920x1080|59.94|50|6,3 MB/s; modo 50M; OFICIAL
XAVC-L HD|1920x1080|29.97|35|4,4 MB/s; modo 35M; OFICIAL
XAVC HS|3840x2160|59.94|200|25,0 MB/s; HEVC 4:2:2 10-bit; OFICIAL
XAVC HS|3840x2160|59.94|150|18,8 MB/s; HEVC 4:2:0; OFICIAL
XAVC HS|3840x2160|29.97|100|12,5 MB/s; HEVC; OFICIAL
XAVC HS|3840x2160|119.88|280|35,0 MB/s; HEVC 4:2:2; OFICIAL
H.264 generico|1920x1080|29.97|50|6,3 MB/s; rango 10-150 segun encoder; NO VERIFICADO exacto
H.265 generico|3840x2160|29.97|100|12,5 MB/s; rango 30-280; VBR agresivo; NO VERIFICADO exacto
```

### B) Soportes — `soporte|velocidad_escritura_mbps|velocidad_lectura_mbps`

> ⚠️ **Los valores de esta tabla están en MB/s (BYTES), no en megabits.** El sufijo `_mbps`
> viene del esquema pedido; si tu modelo Dart asume bits, multiplicá por 8 al importar
> (o renombrá el campo a `_mb_s`, que es lo correcto para medios).
> Filas `_pico` = cifra "up to" del fabricante. Filas `_sostenido` = mínimo garantizado.
> `0` = no aplica / no publicado (tratar como NO VERIFICADO, no como cero real).

```
soporte|velocidad_escritura_mbps|velocidad_lectura_mbps
cfexpress_b_sandisk_extreme_pro_pico|1400|1700
cfexpress_b_sandisk_extreme_pro_sostenido|0|0
cfexpress_b_sony_ceb_g_pico|1750|1850
cfexpress_b_sony_ceb_g_sostenido|0|0
cfexpress_b_lexar_diamond_pico|1700|1900
cfexpress_b_lexar_diamond_sostenido|1600|0
cfexpress_b_angelbird_av_pro_mk2_pico|1550|1785
cfexpress_b_angelbird_av_pro_mk2_sostenido|1300|1785
cfexpress_a_sony_cea_g_gen3_pico|700|800
cfexpress_a_sony_cea_g_gen4_pico|1700|1800
cfexpress_a_sony_cea_g_sostenido|400|0
cfast2_sandisk_extreme_pro_pico|450|525
cfast2_sandisk_extreme_pro_sostenido_vpg130|130|0
sd_uhs2_sandisk_extreme_pro_pico|260|300
sd_uhs2_sandisk_extreme_pro_v90_sostenido|90|0
ssd_samsung_t7_shield_usb32gen2|1000|1050
ssd_nvme_usb32gen2_enclosure|0|0
ssd_nvme_thunderbolt|0|0
```

> La fila `cfexpress_a_sony_cea_g_sostenido|400` se deriva de la certificación **VPG400** de Sony
> (mínimo 400 MB/s sostenidos), no de una tabla de velocidad: es el piso garantizado, no el promedio.

---

## RIESGOS

1. **Bit depth de ARRIRAW mal asumido (riesgo ALTO).** Si la app usa 12 bits para todo, subestima la
   ALEXA 35 un **8,3 %** (568,6 vs 524,9 MB/s) y todas las duraciones de toma y ETAs de copia quedan
   cortas. La ALEXA 35 es **13-bit**; la Mini LF/LF es 12-bit. Es el error más caro de este catálogo.

2. **Confundir GB/h con TB/h (riesgo ALTO).** ARRI publica "2.055 GB/h" para 4.6K 3:2, que es
   **2,055 TB/h**. Un parser que lea "2.055" como "dos coma cero cinco" se equivoca por 1.000×.

3. **Mezclar Mbps y MB/s (riesgo ALTO).** Factor 8. En este documento `mbps` es siempre bits y las
   tablas de soportes van en MB/s. Cualquier importación sin normalizar produce errores de 8×.
   Unidad recomendada en el modelo Dart: **guardar siempre bytes/s como `int`, y formatear al mostrar.**

4. **Usar el pico de la tarjeta como sostenido (riesgo ALTO).** Los "1.700 MB/s" de una CFexpress B
   son ráfaga. La misma tarjeta en escritura continua y llena cae bastante. Solo Lexar (1.600) y
   Angelbird (1.300) publican mínimo garantizado. Sin ese dato, la app debe aplicar el factor 0,70–0,80.

5. **Ignorar el bus antes que la tarjeta (riesgo MEDIO-ALTO).** Lector CFexpress B por USB 3.2 Gen 2
   = techo ~1.000 MB/s. Poner una tarjeta de 1.700 MB/s no acelera nada. La app debería modelar
   `min(tarjeta, lector, destino)` — **tres** términos, no dos.

6. **Ratios de REDCODE no oficiales en cámaras nuevas (riesgo MEDIO).** V-RAPTOR usa HQ/MQ/LQ/ELQ sin
   equivalencia numérica publicada. Hardcodear "HQ = 5:1" es inventar. Modelar como enum + ratio opcional.

7. **BRAW Q0–Q5 como valor único (riesgo MEDIO).** Son VBR con rango publicado (p. ej. Q0 398–1.433 MB/s).
   Para planificar almacenamiento hay que usar el **máximo**; para estimar duración de toma, el **mínimo**.
   Usar el promedio oculta el peor caso.

8. **ProRes 4444 XQ = 500 vs 495 (riesgo BAJO).** El texto del white paper redondea a 500; la tabla dice
   495. Diferencia 1 %: irrelevante en la práctica pero genera discrepancias si se mezclan fuentes.

9. **H.264/H.265 sin cifra fiable (riesgo MEDIO).** Son VBR dependientes de escena (±30 %). Solo los
   modos nominales de cámara (XAVC HS 200M, XAVC-L 150M) tienen número estable.

10. **Capacidad útil ≠ capacidad nominal (riesgo MEDIO).** ARRI calcula 0:28 de ARRIRAW en un drive
    "1 TB", lo que implica ~955 GB útiles. Si la app usa 1.000 GB, promete un 5 % más de autonomía
    del que hay. Aplicar 0,95 de factor de capacidad.

11. **X-OCN XT/ST/LT y el "16-bit lineal" (riesgo BAJO).** Los ratios 3,6/5,2/8,8 son **derivados**
    (calculados sobre la tabla oficial), no publicados como tales por Sony. Sirven para interpolar;
    no citarlos como si Sony los declarara.

12. **Fuentes espejo (riesgo BAJO, trazabilidad).** El manual de la ALEXA 35 y la guía rápida se
    leyeron desde copias espejo (movie-men.com, videocineimport.com) porque arri.com sirve los PDFs
    detrás de blobs con ID variable. Las cifras coinciden con el resto de la cadena (0:28 en 1 TB,
    13-bit, 2.055 GB/h), pero conviene re-verificar contra arri.com antes de publicar el catálogo.

13. **Datos no cubiertos en este relevamiento (NO VERIFICADO).** ARRIRAW HDE (factor de compresión),
    equivalencia numérica HQ/MQ/LQ/ELQ de RED, sostenidos de SanDisk/Sony, y SSDs Thunderbolt.
    No completar con estimaciones.
