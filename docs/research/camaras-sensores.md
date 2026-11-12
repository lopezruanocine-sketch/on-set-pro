# Cámaras digitales de cine — sensores, áreas de imagen y modos (2024–2026)

**Proyecto:** On Set Pro — catálogo de dirección de fotografía
**Alcance:** cámaras de cine digital vigentes o de uso profesional actual (se incluyen modelos descontinuados cuando siguen en alquiler/producción, marcados como *referencia*).
**Fecha de relevamiento:** 2026-11-12
**Regla de oro:** ningún número de este documento fue estimado "a ojo". Cada valor es **F** (dato de fábrica publicado por el fabricante) o **C** (calculado a partir de datos de fábrica: pitch de fotosito × número de píxeles). Lo que no se pudo verificar figura como **NO VERIFICADO**.

---

## 1. Metodología y convenciones

### 1.1 Origen del dato

| Marca | Significado |
|---|---|
| **F** | Dato publicado por el fabricante (ficha técnica, manual o PDF oficial). |
| **C** | Calculado: área = píxeles × pitch de fotosito publicado, o área derivada de la geometría oficial del sensor. Se indica la base del cálculo. |
| **NV** | NO VERIFICADO: no se encontró fuente fiable. |

### 1.2 Círculo de confusión (CoC)

Ningún fabricante de estas cámaras publica un CoC "oficial" por formato. La práctica técnica estándar para cine digital es:

- **CoC = diagonal del formato / 1500** (criterio d/1500, el más difundido; para FF 35 mm da ≈ 0.029 mm).
- **CoC = diagonal / 1730** (criterio Zeiss, equivale a 0.025 mm en FF 35 mm, ≈ 0.001").
- Convención histórica de cine: **0.03 mm** para 35 mm y **0.0254 mm (0.001")** en tablas de profundidad de campo de 35 mm.

En este documento el CoC se informa **calculado con d/1500** sobre la diagonal del área máxima del sensor, y entre paréntesis el valor d/1730. No es dato de fábrica.

Fuentes del criterio: <https://en.wikipedia.org/wiki/Circle_of_confusion> · <https://en.wikipedia.org/wiki/Zeiss_formula>

### 1.3 Advertencia sobre los mm "exactos"

Los fabricantes publican áreas con 1 o 2 decimales. Cuando el pitch de fotosito es público, la multiplicación píxeles × pitch da el valor exacto (p. ej. ALEXA 35: 4608 × 6.075 µm = 27.9936 mm → 27.99 mm). Se usa ese valor y se aclara cuando el fabricante redondea distinto.

### 1.4 Nomenclatura de aspect ratio

Se usa el formato `2.39:1`, `1.78:1`, `1.46:1`, etc., con punto decimal. Ningún número de este archivo usa coma decimal.

---

## 2. Índice rápido

| # | Fabricante | Modelo | Sensor (mm) | Res. máx. | ISO base | Montura |
|---|---|---|---|---|---|---|
| 1 | ARRI | ALEXA 35 | 27.99 × 19.22 | 4608 × 3164 | 800 | LPL |
| 2 | ARRI | ALEXA 35 Xtreme | 27.99 × 19.22 | 4608 × 3164 | 800 | LPL |
| 3 | ARRI | ALEXA Mini LF | 36.70 × 25.54 | 4448 × 3096 | 800 | LPL |
| 4 | ARRI | ALEXA 65 | 54.12 × 25.58 | 6560 × 3100 | 800 | XPL / LPL |
| 5 | ARRI | ALEXA 265 | 54.12 × 25.58 | 6560 × 3100 | NV | LPL |
| 6 | ARRI | ALEXA Mini (S35) | 28.25 × 18.17 | 3424 × 2202 | 800 | PL |
| 7 | RED | V-RAPTOR 8K VV / [X] | 40.96 × 21.60 | 8192 × 4320 | 800 | RF |
| 8 | RED | V-RAPTOR XL 8K VV | 40.96 × 21.60 | 8192 × 4320 | 800 | PL/EF interc. |
| 9 | RED | KOMODO-X | 27.03 × 14.26 | 6144 × 3240 | 800 | RF |
| 10 | RED | MONSTRO 8K VV | 40.96 × 21.60 | 8192 × 4320 | 800 | PL |
| 11 | Sony | VENICE 2 (8.6K) | 35.9 × 24.0 | 8640 × 5760 | 800 / 3200 | E (PL adapt.) |
| 12 | Sony | VENICE 2 (6K) | 35.9 × 24.0 | 6048 × 4032 | 500 / 2500 | E (PL adapt.) |
| 13 | Sony | BURANO | 36 × 24 | 8632 × 4856 | 800 / 3200 | PL + E adapt. |
| 14 | Sony | FX9 | 35.7 × 18.8 | 6K (6048 × 3192 C) | 800 / 4000 | E |
| 15 | Sony | FX6 | 35.6 × 23.8 | 4K | 800 / 12800 | E |
| 16 | Sony | FX3 | 35.6 × 23.8 | 4K | 800 / 12800 | E |
| 17 | Canon | EOS C400 | 36.0 × 19.0 | 6008 × 3170 | 800 / 3200 | RF |
| 18 | Canon | EOS C500 Mark II | 38.1 × 20.1 | 5952 × 3140 | 800 | EF / PL |
| 19 | Canon | EOS C70 | 26.2 × 13.8 | 4096 × 2160 | 800 | RF |
| 20 | Blackmagic | URSA Cine 12K LF | 35.64 × 23.32 | 12288 × 8040 | 800 | PL |
| 21 | Blackmagic | URSA Mini Pro 12K | 27.03 × 14.25 | 12288 × 6480 | 800 | PL |
| 22 | Blackmagic | PYXIS 6K | 36.0 × 24.0 | 6048 × 4032 | 400 / 3200 | L / PL / EF |
| 23 | Blackmagic | Pocket 6K Pro | 23.10 × 12.99 | 6144 × 3456 | 400 / 3200 | EF |
| 24 | Panavision | Millennium DXL2 | 40.96 × 21.60 | 8192 × 4320 | 1600 | SP70 |
| 25 | Phantom | Flex4K | 27.6 × 15.5 | 4096 × 2304 | 250 | PL |

---

## 3. ARRI

### 3.1 ARRI ALEXA 35 (2022 — hoy "legacy", aún en alquiler)

| Dato | Valor | Origen |
|---|---|---|
| Sensor | ARRI ALEV 4 CMOS, Bayer | F |
| Área máxima | **27.99 × 19.22 mm** (Ø 33.96 mm) | F (exacto: 4608 × 6.075 µm = 27.9936 × 19.2213) |
| Fotositos | 4608 × 3164 | F |
| Pitch | 6.075 µm | F |
| Rango dinámico | 17 stops | F |
| ISO | Base **EI 800**; ajustable EI 160–6400 en 1/3 | F |
| Montura | LPL (LBUS); adaptadores PL, PL Hirose, EF, Leitz M | F |
| Anamórfico | Sí: 3.3K 6:5, 3K 1:1, 2.7K 8:9 + desqueeze en cámara (licencia Open Gate/Anamorphic) | F |
| CoC (calc.) | **0.023 mm** (d/1500) · 0.020 mm (d/1730) | C |

| Modo | Resolución (px) | Área (mm) | Aspecto | Origen |
|---|---|---|---|---|
| 4.6K 3:2 Open Gate | 4608 × 3164 | 28.0 × 19.2 (exacto 27.99 × 19.22) | 1.46:1 | F |
| 4.6K 16:9 | 4608 × 2592 | 28.0 × 15.7 (exacto 27.99 × 15.75) | 1.78:1 | F |
| 4K 16:9 | 4096 × 2304 | 24.9 × 14.0 (exacto 24.88 × 14.00) | 1.78:1 | F |
| 4K 2:1 | 4096 × 2048 | 24.9 × 12.4 | 2.00:1 | F |
| 3.8K 16:9 | 3840 × 2160 | 23.3 × 13.1 | 1.78:1 | F |
| 3.8K 2.39:1 | 3840 × 1608 | 23.3 × 9.8 | 2.39:1 | F |
| 3.3K 6:5 (ana 2x) | 3328 × 2790 | 20.22 × 16.95 | 1.19:1 (2.39:1 desplegado) | F |
| 3K 1:1 | 3072 × 3072 | 18.7 × 18.7 | 1.00:1 | F |
| 2K 16:9 S16 | 2048 × 1152 | 12.4 × 7.0 | 1.78:1 | F |

Fuente: <https://www.arri.com/en/cine-systems/cine-cameras/legacy-cine-cameras/alexa-35>

### 3.2 ARRI ALEXA 35 Xtreme (2025 — reemplaza a la ALEXA 35)

Mismo sensor y mismas áreas de imagen que la ALEXA 35. Cambia el procesador: 330 fps con 17 stops y **Sensor Overdrive** hasta 660 fps con 11 stops y EI base 1600.

| Dato | Valor | Origen |
|---|---|---|
| Sensor | ARRI ALEV 4, 27.99 × 19.22 mm | F |
| Fotositos / pitch | 4608 × 3164 / 6.075 µm | F |
| Rango dinámico | 17 stops (11 en Sensor Overdrive) | F |
| ISO | EI 800 base; EI 160–6400; EI 1600 en Sensor Overdrive | F |
| Montura | LPL (LBUS); PL, PL Hirose, EF | F |
| CoC (calc.) | 0.023 mm (d/1500) | C |

| Modo | Resolución (px) | Área (mm) | Aspecto | Origen |
|---|---|---|---|---|
| 4.6K 3:2 Open Gate | 4608 × 3164 | 28.0 × 19.2 | 1.46:1 | F |
| 4.6K 16:9 | 4608 × 2592 | 28.0 × 15.7 | 1.78:1 | F |
| 4K 16:9 | 4096 × 2304 | 24.9 × 14.0 | 1.78:1 | F |
| 3.3K 6:5 (ana 2x) | 3328 × 2790 | 20.22 × 16.95 | 1.19:1 (2.39:1 desplegado) | F |

Fuente: <https://www.arri.com/en/cine-systems/cine-cameras/alexa-35-xtreme>

### 3.3 ARRI ALEXA Mini LF

| Dato | Valor | Origen |
|---|---|---|
| Sensor | ARRI A2X (ALEV III), 36.70 × 25.54 mm (Ø 44.71 mm) | F |
| Fotositos / pitch | 4448 × 3096 / 8.25 µm | F |
| Rango dinámico | 14+ stops (EI 160–3200) | F |
| ISO | Base **EI 800** | F |
| Montura | LPL con LBUS; adaptador PL-to-LPL | F |
| Anamórfico | Sí: S35 2.8K 4:3 + desqueeze 2x | F |
| CoC (calc.) | **0.030 mm** (d/1500) · 0.026 mm (d/1730) | C |

| Modo | Resolución (px) | Área (mm) | Aspecto | Origen |
|---|---|---|---|---|
| 4.5K LF 3:2 Open Gate | 4448 × 3096 | 36.70 × 25.54 | 1.44:1 | F |
| 4.5K LF 2.39:1 | 4448 × 1856 | 36.70 × 15.31 | 2.39:1 | F |
| 4.3K LF 16:9 | 4320 × 2430 | 35.64 × 20.05 | 1.78:1 | F |
| 3.8K LF 16:9 | 3840 × 2160 | 31.68 × 17.82 | 1.78:1 | F |
| 2.8K LF 1:1 | 2880 × 2880 | 23.76 × 23.76 | 1.00:1 | F |
| 3.4K S35 3:2 | 3424 × 2202 | 28.25 × 18.16 | 1.55:1 | F |
| 3.2K S35 16:9 | 3200 × 1800 | 26.40 × 14.85 | 1.78:1 | F |
| 2.8K S35 4:3 (ana 2x) | 2880 × 2160 | 23.76 × 17.81 | 1.33:1 (2.39:1 desplegado) | F |

Fuente: <https://www.arri.com/en/cine-systems/cine-cameras/alexa-mini-lf>

> La ALEXA LF usa el mismo sensor y las mismas áreas; solo cambia el cuerpo. <https://www.arri.com/en/cine-systems/cine-cameras/alexa-lf>

### 3.4 ARRI ALEXA 65 (referencia — 2014, aún en alquiler)

| Dato | Valor | Origen |
|---|---|---|
| Sensor | ARRI A3X (ALEV III), 54.12 × 25.58 mm (Ø 59.86 mm, 5-perf 65) | F |
| Fotositos / pitch | 6560 × 3100 / 8.25 µm | F |
| Rango dinámico | >14 stops | F (dealer) |
| ISO | Base **EI 800**; EI 200–3200 | F (dealer) |
| Montura | XPL original; unidades actuales con LPL (adaptable) | F/NV |
| Anamórfico | NV (no se encontró modo 4:3/6:5 documentado) | NV |
| CoC (calc.) | **0.040 mm** (d/1500) · 0.035 mm (d/1730) | C |

| Modo | Resolución (px) | Área (mm) | Aspecto | Origen |
|---|---|---|---|---|
| 6.5K Open Gate (5-perf 65) | 6560 × 3100 | 54.12 × 25.58 | 2.12:1 | F |
| 2.39:1 (recorte full-width) | 6560 × 2745 | 54.12 × 22.65 | 2.39:1 | C |
| 16:9 (recorte full-height) | 5511 × 3100 | 45.47 × 25.58 | 1.78:1 | C |

Fuentes: <https://www.illuminationdynamics.com/alexa-65> · <https://www.arri.com/en/learn/arri-camera-technology/alev-sensors> · <https://www.arri.com/en/cine-systems/cine-cameras/alexa-265> (confirma 54.12 × 25.58 para el formato 65)

> Ojo: algunos documentos ARRI citan 6560 × 3102; la ficha actual de ARRI (ALEXA 265, mismo formato) usa 6560 × 3100. Ver RIESGOS.

### 3.5 ARRI ALEXA 265 (anunciada 2024-12, disponible 2025)

| Dato | Valor | Origen |
|---|---|---|
| Sensor | ARRI A3X Rev.B, 65 mm, 54.12 × 25.58 mm (Ø 59.86 mm) | F |
| Fotositos / pitch | 6560 × 3100 / 8.25 µm | F |
| Rango dinámico | 15 stops | F |
| ISO | **NO VERIFICADO** (rango EI 160–6400; ARRI no publica EI base) | NV |
| Montura | LPL (LBUS) | F |
| Anamórfico | NV | NV |
| CoC (calc.) | 0.040 mm (d/1500) | C |

| Modo | Resolución (px) | Área (mm) | Aspecto | Origen |
|---|---|---|---|---|
| 6.5K 2.12:1 Open Gate | 6560 × 3100 | 54.12 × 25.58 | 2.12:1 | F |
| 5.1K 1.65:1 | 5120 × 3100 | 42.24 × 25.58 | 1.65:1 | F |
| 4.5K LF 3:2 | 4448 × 3096 | 36.70 × 25.54 | 1.44:1 | F |

Fuente: <https://www.arri.com/en/cine-systems/cine-cameras/alexa-265>

### 3.6 ARRI ALEXA Mini (S35) (referencia — 2015)

| Dato | Valor | Origen |
|---|---|---|
| Sensor | ARRI ALEV III, 28.25 × 18.17 mm | F |
| Fotositos / pitch | 3424 × 2202 / 8.25 µm | F |
| Rango dinámico | 14+ stops (EI 160–3200) | F |
| ISO | Base **EI 800** | F |
| Montura | PL (titanio) con LBUS; LPL opcional | F |
| Anamórfico | Sí: 2.8K 4:3 y 2K 2.39:1 Ana (2x) | F |
| CoC (calc.) | **0.022 mm** (d/1500) · 0.019 mm (d/1730) | C |

| Modo | Resolución (px) | Área (mm) | Aspecto | Origen |
|---|---|---|---|---|
| 3.4K Open Gate | 3424 × 2202 | 28.25 × 18.17 | 1.55:1 | F |
| 3.2K 16:9 | 3200 × 1800 | 26.40 × 14.85 | 1.78:1 | F |
| 2.8K 16:9 | 2880 × 1620 | 23.76 × 13.37 | 1.78:1 | F |
| 2.8K 4:3 | 2880 × 2160 | 23.76 × 17.82 | 1.33:1 | F |
| 2K 2.39:1 Ana 2x | 2560 × 2145 | 21.12 × 17.70 | 1.33:1 (2.39:1 desplegado) | F |
| HD Ana | 1920 × 2160 | 15.84 × 17.82 | 0.89:1 (1.78:1 desplegado) | F |

Fuente: <https://www.arri.com/en/cine-systems/cine-cameras/legacy-cine-cameras/alexa-mini>

---

## 4. RED

### 4.1 RED V-RAPTOR 8K VV / V-RAPTOR [X] 8K VV

| Dato | Valor | Origen |
|---|---|---|
| Sensor | V-RAPTOR 8K VV, 35.4 MP, global shutter | F |
| Área | **40.96 × 21.60 mm** (Ø 46.31 mm) | F |
| Píxeles / pitch | 8192 × 4320 / 5.0 µm | F / C |
| Rango dinámico | 17+ stops | F |
| ISO | **800** (valor por defecto RED; rango 250–12800 en la familia VV) | F |
| Montura | RF bloqueante; adaptadores RF→PL y RF→EF | F |
| Anamórfico | Sí: 2x, 1.8x, 1.6x, 1.5x, 1.3x, 1.25x | F |
| CoC (calc.) | **0.031 mm** (d/1500) · 0.027 mm (d/1730) | C |

| Modo | Resolución (px) | Área (mm) | Aspecto | Origen |
|---|---|---|---|---|
| 8K 17:9 | 8192 × 4320 | 40.96 × 21.60 | 1.89:1 | F |
| 8K 2.4:1 | 8192 × 3456 | 40.96 × 17.28 | 2.37:1 | C |
| 7K 17:9 | 7168 × 3780 | 35.84 × 18.90 | 1.89:1 | C |
| 6K 17:9 | 6144 × 3240 | 30.72 × 16.20 | 1.89:1 | C |
| 4K 17:9 | 4096 × 2160 | 20.48 × 10.80 | 1.89:1 | C |

Fuentes: <https://docs.red.com/955-0225/955-0225_V1.7+Rev-B+RED+PS,+V-RAPTOR+%5bX%5d+8K+VV+Operation+Guide+HTML/Content/B_TechSpecs/Specs_V-RAPTOR%20[X].htm> · <http://docs.red.com.s3.amazonaws.com/955-0160/WEAPONMONSTRO8KVVOperationGuide/zh-cn/Content/5_Advanced_Menus/1_Settings/Look/ISO_FLUT.htm> (ISO 800 por defecto, rango 250–12800)

### 4.2 RED V-RAPTOR XL 8K VV

Mismo sensor y áreas que la V-RAPTOR. Cuerpo XL con ND motorizado (2–7 stops), doble voltaje 14/26 V y montura intercambiable.

| Dato | Valor | Origen |
|---|---|---|
| Área | 40.96 × 21.60 mm | F |
| Píxeles | 8192 × 4320 | F |
| Montura | Intercambiable: PL incluida, EF bloqueante opcional | F |
| ISO | 800 por defecto | F |
| CoC (calc.) | 0.031 mm (d/1500) | C |

Fuente: <https://docs.red.com/955-0203/955-0203_V2.1%20Rev-A%20RED%20PS,%20V-RAPTOR%20XL%208K%20VV%20Operation%20Guide%20HTML/Content/B_TechSpecs/Specs_V-RAPTOR_XL.htm>

### 4.3 RED KOMODO-X

| Dato | Valor | Origen |
|---|---|---|
| Sensor | KOMODO-X 19.9 MP S35, global shutter | F |
| Área | **27.03 × 14.26 mm** (Ø 30.56 mm) | F |
| Píxeles / pitch | 6144 × 3240 / 4.4 µm | F / C |
| Rango dinámico | 16.5+ stops | F |
| ISO | **800** (por defecto RED) | F |
| Montura | RF; adaptadores RF→PL / EF | F |
| Anamórfico | Sí: 2x, 1.8x, 1.6x, 1.5x, 1.3x, 1.25x | F |
| CoC (calc.) | **0.020 mm** (d/1500) · 0.018 mm (d/1730) | C |

| Modo | Resolución (px) | Área (mm) | Aspecto | Origen |
|---|---|---|---|---|
| 6K 17:9 | 6144 × 3240 | 27.03 × 14.26 | 1.89:1 | F |
| 6K 2.4:1 | 6144 × 2592 | 27.03 × 11.40 | 2.37:1 | C |
| 5K 17:9 | 5120 × 2700 | 22.53 × 11.88 | 1.89:1 | C |
| 4K 17:9 | 4096 × 2160 | 18.02 × 9.50 | 1.89:1 | C |
| 2K 17:9 | 2048 × 1080 | 9.01 × 4.75 | 1.89:1 | C |

Fuente: <https://docs.red.com/955-0219/955-0219_V1.0beta%20Rev-A%20RED%20PS,%20KOMODO-X%20ST%20Operation%20Guide/Content/A_TechSpecs/Specs_KOMODO-X.htm>

### 4.4 RED MONSTRO 8K VV (DSMC2) (referencia)

| Dato | Valor | Origen |
|---|---|---|
| Sensor | MONSTRO 35.4 MP CMOS | F |
| Área | **40.96 × 21.60 mm** (Ø 46.31 mm) | F |
| Píxeles / pitch | 8192 × 4320 / 5.0 µm | F / C |
| Rango dinámico | 17+ stops | F |
| ISO | 800 por defecto (rango 250–12800) | F |
| Montura | PL (DSMC2) | F |
| Anamórfico | Sí (formatos ana 2x, 1.8x, 1.6x) | F |
| CoC (calc.) | 0.031 mm (d/1500) | C |

| Modo | Resolución (px) | Área (mm) | Aspecto | Origen |
|---|---|---|---|---|
| 8K Full Format | 8192 × 4320 | 40.96 × 21.60 | 1.89:1 | F |
| 8K 2.4:1 | 8192 × 3456 | 40.96 × 17.28 | 2.37:1 | C |
| 7K Full Format | 7168 × 3780 | 35.84 × 18.90 | 1.89:1 | C |
| 6K Full Format | 6144 × 3240 | 30.72 × 16.20 | 1.89:1 | C |
| 4K Full Format | 4096 × 2160 | 20.48 × 10.80 | 1.89:1 | C |

Fuente: <https://docs.red.com/955-0160_v7.0/WEAPONMONSTRO8KVVOperationGuide/en-us/Content/A_TechSpecs/Specs_DSMC2_MONSTRO.htm>

---

## 5. Sony

### 5.1 Sony VENICE 2 (8.6K) — MPC-3628

| Dato | Valor | Origen |
|---|---|---|
| Sensor | Full-frame 8.6K CMOS, 35.9 × 24.0 mm (3:2) | F |
| Resolución máx. | 8640 × 5760 | F |
| Rango dinámico | 16 stops | F |
| ISO | Dual: **800 / 3200** | F |
| Montura | E-mount; PL adapter incluido | F |
| ND | 8 posiciones ópticas (clear, 0.3–2.4) | F |
| Anamórfico | Sí: 5.8K 4:3 y 6:5 (licencia anamórfica) | F |
| CoC (calc.) | **0.029 mm** (d/1500) · 0.025 mm (d/1730) | C |

| Modo | Resolución (px) | Área (mm) | Aspecto | Origen |
|---|---|---|---|---|
| 8.6K 3:2 | 8640 × 5760 | 35.9 × 24.0 | 1.50:1 | F |
| 8.6K 17:9 | 8640 × 4556 | 35.9 × 19.0 | 1.89:1 | F |
| 8.2K 2.39:1 | 8192 × 3432 | 34.1 × 14.3 | 2.39:1 | F |
| 8.2K 17:9 | 8192 × 4320 | 34.1 × 18.0 | 1.89:1 | F |
| 8.1K 16:9 | 8100 × 4556 | 33.8 × 19.0 | 1.78:1 | F |
| 7.6K 16:9 | 7680 × 4320 | 32.0 × 18.0 | 1.78:1 | F |
| 5.8K 4:3 | 5792 × 4276 | 24.1 × 17.8 | 1.35:1 | F |
| 5.8K 6:5 | 5792 × 4854 | 24.1 × 20.2 | 1.19:1 | F |
| 5.8K 17:9 | 5792 × 3056 | 24.1 × 12.7 | 1.89:1 | F |
| 5.5K 2.39:1 | 5480 × 2296 | 22.8 × 9.55 | 2.39:1 | F |

Fuente: <https://www.sony.jp/ls-camera/reference/pdf/VENICE_2_MPC-3628_recording_format.pdf> (Sony, enero 2025)

> La ficha de Sony dice "フルフレーム 25.9mm x 24mm" — es una errata evidente por 35.9 mm; las tablas de modos usan 35.9. Ver RIESGOS.

### 5.2 Sony VENICE 2 (6K) — MPC-3626

| Dato | Valor | Origen |
|---|---|---|
| Sensor | Full-frame 6K CMOS, 35.9 × 24.0 mm (3:2) | F |
| Resolución máx. | 6048 × 4032 | F |
| Rango dinámico | 15+ stops | F |
| ISO | Dual: **500 / 2500** | F |
| Montura | E-mount; PL adapter | F |
| Anamórfico | Sí: 4K 6:5 / 4:3 | F |
| CoC (calc.) | 0.029 mm (d/1500) | C |

| Modo | Resolución (px) | Área (mm) | Aspecto | Origen |
|---|---|---|---|---|
| 6K 3:2 | 6048 × 4032 | 35.9 × 24.0 | 1.50:1 | F |
| 6K 1.85:1 | 6054 × 3272 | 36.0 × 19.4 | 1.85:1 | F |
| 6K 17:9 | 6054 × 3192 | 36.0 × 19.0 | 1.89:1 | F |
| 6K 2.39:1 | 6048 × 2534 | 35.9 × 15.0 | 2.39:1 | F |
| 5.7K 16:9 | 5674 × 3192 | 33.7 × 19.0 | 1.78:1 | F |
| 4K 6:5 | 4096 × 3432 | 24.3 × 20.4 | 1.19:1 | F |
| 4K 4:3 | 4096 × 3432 | 24.3 × 18.0 | 1.33:1 | F |
| 4K 17:9 | 4096 × 2160 | 24.3 × 12.8 | 1.89:1 | F |

Fuente: <https://www.sony.jp/ls-camera/reference/pdf/VENICE_2_MPC-3626_recording_format.pdf> (Sony, enero 2025)

### 5.3 Sony BURANO — MPC-2610

| Dato | Valor | Origen |
|---|---|---|
| Sensor | Full-frame 8.6K Exmor RS, 36 × 24 mm | F |
| Resolución máx. | 8632 × 4856 | F |
| Rango dinámico | 16 stops | F |
| ISO | Dual: **800 / 3200** | F |
| Montura | PL estándar; E-mount con adaptador | F |
| Estabilización | IBIS (mundo primero con PL) | F |
| ND | Variable electrónica 0.6–1.8 + clear | F |
| Anamórfico | Sí: S35 4.3K 4:3 y FF 8.6K (desqueeze) | F |
| CoC (calc.) | 0.029 mm (d/1500) | C |

| Modo | Resolución (px) | Área (mm) | Aspecto | Origen |
|---|---|---|---|---|
| FF 8.6K 16:9 | 8632 × 4856 | 35.9 × 20.2 | 1.78:1 | F |
| FF 8.6K 17:9 | 8632 × 4552 | 35.9 × 18.9 | 1.89:1 | F |
| FF 8K 17:9 (XAVC) | 8192 × 4320 | 35.9 × 18.9 | 1.89:1 | F |
| FFc 6K 17:9 | 6052 × 3192 | 33.6 × 17.7 | 1.89:1 | F |
| FFc 6K 16:9 | 6052 × 3404 | 33.6 × 18.9 | 1.78:1 | F |
| S35 5.8K 16:9 | 5760 × 3240 | 24.0 × 13.5 | 1.78:1 | F |
| S35 5.8K 17:9 | 5760 × 3036 | 24.0 × 12.6 | 1.89:1 | F |
| S35 4.3K 4:3 | 4256 × 3192 | 23.6 × 17.7 | 1.33:1 | F |
| S35c 4K 17:9 | 4096 × 2160 | 17.0 × 9.0 | 1.89:1 | F |

Fuente: <https://www.sony.jp/ls-camera/reference/pdf/BURANO_recording_format.pdf> (Sony, febrero 2026)

### 5.4 Sony PXW-FX9

| Dato | Valor | Origen |
|---|---|---|
| Sensor | 6K full-frame Exmor R, 35.7 × 18.8 mm (1.89:1) | F |
| Píxeles totales | ~20.5 MP | F |
| Rango dinámico | 15+ stops | F |
| ISO | Dual: **800 / 4000** | F |
| Montura | E | F |
| Anamórfico | No nativo (sin modo 4:3/6:5); desqueeze en monitor/post | F |
| CoC (calc.) | 0.027 mm (d/1500) | C |

| Modo | Resolución (px) | Área (mm) | Aspecto | Origen |
|---|---|---|---|---|
| 6K FF | 6048 × 3192 | 35.7 × 18.8 | 1.89:1 | F (área) / C (px) |
| 4K DCI FF | 4096 × 2160 | 35.7 × 18.8 | 1.89:1 | C |
| 5K S35 | 5120 × 2700 | 30.2 × 15.9 | 1.89:1 | C |
| 4K S35 | 4096 × 2160 | 24.2 × 12.7 | 1.89:1 | C |

Fuentes: <https://www.sony.jp/products/catalog/FX9_2104.pdf> (ISO 800/4000, 20.5 MP, 15+) · <https://sony-cinematography.com/articles/evaluating-the-sony-fx9-and-venice-sensors---an-abelcine-tutorial-and-guide/> (35.7 × 18.8 mm)

### 5.5 Sony FX6 (ILME-FX6)

| Dato | Valor | Origen |
|---|---|---|
| Sensor | Full-frame BSI CMOS, 35.6 × 23.8 mm | F/NV (mm vía ficha secundaria) |
| Píxeles | 12.9 MP totales / 10.26 MP efectivos | F |
| Rango dinámico | 15+ stops | F |
| ISO | Dual: **800 / 12800** | F |
| Montura | E | F |
| Anamórfico | No nativo | F |
| CoC (calc.) | 0.029 mm (d/1500) | C |

| Modo | Resolución (px) | Área (mm) | Aspecto | Origen |
|---|---|---|---|---|
| 4K DCI | 4096 × 2160 | 35.6 × 18.8 | 1.89:1 | C |
| UHD 4K | 3840 × 2160 | 35.6 × 20.0 | 1.78:1 | C |
| HD | 1920 × 1080 | 35.6 × 20.0 | 1.78:1 | C |

Fuentes: <https://www.sony.jp/pro-cam/products/ILME-FX6V/specification.html> (12.9/10.26 MP, E) · <https://www.sony.jp/pro-cam/products/ILME-FX6V/feature_1.html> (ISO 800/12800, 15+)

### 5.6 Sony FX3 (ILME-FX3 / FX3A)

| Dato | Valor | Origen |
|---|---|---|
| Sensor | Full-frame Exmor R, 35.6 × 23.8 mm | F |
| Píxeles | 12.1 MP efectivos foto / ~10.3 MP video | F |
| Rango dinámico | 15+ stops | F |
| ISO | Dual: **800 / 12800** | F |
| Montura | E | F |
| Anamórfico | No nativo | F |
| CoC (calc.) | 0.029 mm (d/1500) | C |

| Modo | Resolución (px) | Área (mm) | Aspecto | Origen |
|---|---|---|---|---|
| 4K DCI | 4096 × 2160 | 35.6 × 18.8 | 1.89:1 | C |
| UHD 4K | 3840 × 2160 | 35.6 × 20.0 | 1.78:1 | C |

Fuente: <https://www.sony.jp/pro-cam/products/archive/ILME-FX3A/spec.html>

---

## 6. Canon

> Canon no publica el área de imagen en mm de todos sus modos. Donde no hay dato oficial se calcula con el pitch derivado del área oficial del sensor y se marca **C**.

### 6.1 Canon EOS C400 (2024)

| Dato | Valor | Origen |
|---|---|---|
| Sensor | Full-frame BSI stacked CMOS, 36.0 × 19.0 mm (Ø 40.7 mm) | F (vía ficha Canon reproducida) |
| Píxeles | 26.7 MP totales; 19.05 MP efectivos (6008 × 3170) | F |
| Pitch | ~5.99 µm | C |
| Rango dinámico | 16 stops | F |
| ISO | **Triple base**: 800 / 3200 / 12800 para RAW y Canon Log; 400/1600/6400 en 709 | F |
| Montura | RF | F |
| Anamórfico | Sí, desqueeze de visualización 1.3x / 1.8x / 2x (sensor 1.90:1, sin modo 4:3) | F |
| CoC (calc.) | 0.027 mm (d/1500) | C |

| Modo | Resolución (px) | Área (mm) | Aspecto | Origen |
|---|---|---|---|---|
| 6K FF | 6000 × 3164 | 36.0 × 19.0 (exacto 35.95 × 18.96) | 1.90:1 | F |
| 4K FF (oversample) | 4096 × 2160 | 36.0 × 19.0 | 1.90:1 | C |
| S35 4.3K | 4368 × 2304 | 26.2 × 13.8 | 1.90:1 | C |
| S16 2.2K | 2184 × 1152 | 13.1 × 6.9 | 1.90:1 | C |

Fuentes: <https://m.canon.com.cn/product/eosc400/spec.html> (píxeles, ISO base, RF) · 16 stops y triple base ISO: <https://www.canon.com.au/cameras/eos-c400> · desqueeze 2x/1.8x/1.3x: <https://sg.canon/en/pro-imaging/eos-c400/main/product> · área 36.0 × 19.0 mm: ficha Canon reproducida en <https://www.glazerscamera.com/collections/canon/products/canon-eos-c400-cinema-camera>

### 6.2 Canon EOS C500 Mark II

| Dato | Valor | Origen |
|---|---|---|
| Sensor | Full-frame CMOS, **38.1 × 20.1 mm** (Ø 43.1 mm) | F |
| Píxeles | 20.8 MP totales (6062 × 3432); 18.69 MP efectivos (5952 × 3140) | F |
| Pitch | 6.4 µm | C |
| Rango dinámico | 15+ stops (Canon Log 2) / 14 (Log 3) | F |
| ISO | Base **800**; rango 100–102400 | F (base vía ficha secundaria) |
| Montura | EF (con bloqueo); PL opcional | F |
| Anamórfico | Sí: modos 4:3 (4192 × 3140) y 6:5 (3768 × 3140) | F |
| CoC (calc.) | 0.029 mm (d/1500) | C |

| Modo | Resolución (px) | Área (mm) | Aspecto | Origen |
|---|---|---|---|---|
| 5.9K FF | 5952 × 3140 | 38.1 × 20.1 | 1.90:1 | F |
| 4K DCI | 4096 × 2160 | 26.2 × 13.8 | 1.90:1 | C |
| UHD 4K | 3840 × 2160 | 35.7 × 20.1 (área 5580 × 3140) | 1.78:1 | F |
| 2K | 2048 × 1080 | 13.1 × 6.9 | 1.90:1 | C |

Fuentes: PDF técnico Canon <https://mnd-assets.mynewsdesk.com/image/upload/f_pdf,fl_attachment/sqvgpvxpflkpczssjrbr> · <https://www.canon.com.cn/product/eosc500markii/spec.html>

### 6.3 Canon EOS C70

| Dato | Valor | Origen |
|---|---|---|
| Sensor | Super 35 DGO CMOS, **26.2 × 13.8 mm** | F (ficha secundaria) |
| Píxeles | 9.6 MP totales; 8.85 MP efectivos (4096 × 2160) | F |
| Pitch | 6.4 µm | C |
| Rango dinámico | 16+ stops (DGO, Canon Log 2) | F (marketing Canon) |
| ISO | Base **800** (DGO); rango 100–102400 | F |
| Montura | RF | F |
| Anamórfico | No nativo | F |
| CoC (calc.) | 0.020 mm (d/1500) | C |

| Modo | Resolución (px) | Área (mm) | Aspecto | Origen |
|---|---|---|---|---|
| 4K DCI | 4096 × 2160 | 26.2 × 13.8 | 1.90:1 | F |
| UHD 4K | 3840 × 2160 | 24.6 × 13.8 | 1.78:1 | C |
| 2K S16 | 2048 × 1080 | 13.1 × 6.9 | 1.90:1 | C |

Fuentes: <https://m.canon.com.cn/product/eosc70/spec.html> · <https://www.bandpro.com/canon-eos-c70-cinema-camera-body-4k-super-35-rf-mount-4507c002.html> (26.2 × 13.8 mm, base ISO 800)

---

## 7. Blackmagic Design

### 7.1 Blackmagic URSA Cine 12K LF

| Dato | Valor | Origen |
|---|---|---|
| Sensor | RGBW 36 × 24 mm (área efectiva **35.64 × 23.32 mm**), rolling shutter | F |
| Píxeles | 12288 × 8040 | F |
| Pitch | **2.9 µm** | F |
| Rango dinámico | 16 stops | F |
| ISO | Nativo **800** (sin dual native ISO) | F (secundaria) |
| Montura | PL; intercambiable EF (LPL opcional) | F |
| Anamórfico | Sí: 12K 6:5 (9648 × 8040) | F |
| CoC (calc.) | 0.028 mm (d/1500) | C |

| Modo | Resolución (px) | Área (mm) | Aspecto | Origen |
|---|---|---|---|---|
| 12K 3:2 Open Gate | 12288 × 8040 | 35.64 × 23.32 | 1.53:1 | F |
| 12K 16:9 | 12288 × 6912 | 35.64 × 20.04 | 1.78:1 | C |
| 12K 17:9 | 12288 × 6480 | 35.64 × 18.79 | 1.89:1 | C |
| 12K 2.4:1 | 12288 × 5112 | 35.64 × 14.82 | 2.40:1 | C |
| 12K 6:5 (ana 2x) | 9648 × 8040 | 27.98 × 23.32 | 1.20:1 (2.40:1 desplegado) | C |
| 9K 3:2 S35 | 9408 × 6264 | 27.28 × 18.17 | 1.50:1 | C |
| 8K 17:9 | 8192 × 4320 | 23.76 × 12.53 | 1.89:1 | C |

Fuentes: <https://www.blackmagicdesign.com/products/blackmagicursacine/techspecs/W-URSA-70> · ISO 800: <https://www.filmmakersacademy.com/blog-ursa-cine-12k-lf-ergonomics/>

### 7.2 Blackmagic URSA Mini Pro 12K (referencia)

| Dato | Valor | Origen |
|---|---|---|
| Sensor | Super 35 12K, **27.03 × 14.25 mm** | F |
| Píxeles | 12288 × 6480 | F |
| Pitch | 2.2 µm | F |
| Rango dinámico | 14 stops | F |
| ISO | **800** | F |
| Montura | PL; EF/F opcionales | F |
| Anamórfico | Sí: 12K 6:5 (7680 × 6408) | F |
| CoC (calc.) | 0.020 mm (d/1500) | C |

| Modo | Resolución (px) | Área (mm) | Aspecto | Origen |
|---|---|---|---|---|
| 12K DCI | 12288 × 6480 | 27.03 × 14.25 | 1.90:1 | F |
| 12K 2.4:1 | 12288 × 5112 | 27.03 × 11.25 | 2.40:1 | C |
| 8K DCI | 8192 × 4320 | 18.02 × 9.50 | 1.90:1 | C |
| 6K | 6144 × 3240 | 13.52 × 7.13 | 1.90:1 | C |

Fuentes: <https://www.blackmagicdesign.com/api/print/to-pdf/au/products/blackmagicursaminipro/techspecs/W-URSA-40>

### 7.3 Blackmagic PYXIS 6K

| Dato | Valor | Origen |
|---|---|---|
| Sensor | Full-frame 6K, **36 × 24 mm** | F |
| Píxeles | 6048 × 4032 | F |
| Pitch | **5.94 µm** | F |
| Rango dinámico | 13 stops | F |
| ISO | Dual: **400 / 3200** | F |
| Montura | L-Mount (variantes PL y EF del mismo cuerpo) | F |
| Anamórfico | Sí: 6K 6:5 (4832 × 4032) | F |
| CoC (calc.) | 0.029 mm (d/1500) | C |

| Modo | Resolución (px) | Área (mm) | Aspecto | Origen |
|---|---|---|---|---|
| 6K 3:2 Open Gate | 6048 × 4032 | 36.0 × 24.0 (exacto 35.93 × 23.95) | 1.50:1 | F |
| 6K 6:5 (ana 2x) | 4832 × 4032 | 28.70 × 23.95 | 1.20:1 | C |
| 6K 16:9 | 6048 × 3408 | 35.93 × 20.24 | 1.78:1 | C |
| 6K DCI 17:9 | 6048 × 3200 | 35.93 × 19.01 | 1.89:1 | C |
| 6K 2.4:1 | 6048 × 2520 | 35.93 × 14.97 | 2.40:1 | C |
| 4K S35 4:3 | 4096 × 3072 | 24.33 × 18.25 | 1.33:1 | C |

Fuente: <https://www.blackmagicdesign.com/products/blackmagicpyxis/techspecs>

### 7.4 Blackmagic Pocket Cinema Camera 6K Pro

| Dato | Valor | Origen |
|---|---|---|
| Sensor | Super 35, **23.10 × 12.99 mm** | F |
| Píxeles | 6144 × 3456 | F |
| Pitch | 3.76 µm | C |
| Rango dinámico | 13 stops | F |
| ISO | Dual: **400 / 3200** | F |
| Montura | EF activa | F |
| Anamórfico | Sí: 3.7K 6:5 (3728 × 3104) | F |
| CoC (calc.) | 0.018 mm (d/1500) | C |

| Modo | Resolución (px) | Área (mm) | Aspecto | Origen |
|---|---|---|---|---|
| 6K | 6144 × 3456 | 23.10 × 12.99 | 1.78:1 | F |
| 6K 2.4:1 | 6144 × 2560 | 23.10 × 9.63 | 2.40:1 | C |
| 5.7K 17:9 | 5744 × 3024 | 21.60 × 11.37 | 1.90:1 | C |
| 4K DCI | 4096 × 2160 | 15.40 × 8.12 | 1.90:1 | C |
| 3.7K 6:5 (ana 2x) | 3728 × 3104 | 14.02 × 11.67 | 1.20:1 | C |

Fuente: <https://www.blackmagicdesign.com/products/blackmagicpocketcinemacamera/techspecs>

---

## 8. Panavision

### 8.1 Panavision Millennium DXL2

| Dato | Valor | Origen |
|---|---|---|
| Sensor | RED MONSTRO 8K VV, **40.96 × 21.60 mm** (Ø 46.3 mm) | F |
| Píxeles / pitch | 8192 × 4320 / 5.0 µm | F |
| Rango dinámico | 16+ stops | F |
| ISO | Nativo **1600** | F |
| Montura | SP70; adaptable a System 65, Panavision 35 y PL | F |
| Anamórfico | Sí (4K anamórfico) | F |
| CoC (calc.) | 0.031 mm (d/1500) | C |

| Modo | Resolución (px) | Área (mm) | Aspecto | Origen |
|---|---|---|---|---|
| 8K Full Format | 8192 × 4320 | 40.96 × 21.60 | 1.89:1 | F |
| 8K 2.4:1 | 8192 × 3456 | 40.96 × 17.28 | 2.37:1 | C |
| 5K S35 | 5120 × 2700 | 25.60 × 13.50 | 1.89:1 | C |
| 4K 17:9 | 4096 × 2160 | 20.48 × 10.80 | 1.89:1 | C |

Fuente: <https://www.panavision.com/camera-and-optics/cameras/product-detail/dxl2-millennium-dxl2>

---

## 9. Phantom

### 9.1 Vision Research Phantom Flex4K (referencia de alta velocidad)

| Dato | Valor | Origen |
|---|---|---|
| Sensor | Super 35 CMOS, **27.6 × 15.5 mm** (Ø 31.7 mm) | F |
| Píxeles | 4096 × 2304 | F |
| Pitch | **6.75 µm** | F |
| Rango dinámico | 12+ stops | F |
| ISO | Nativo **250** (grabación recomendada EI 800–1000) | F |
| Montura | PL; intercambiable EF / Nikon F | F |
| Anamórfico | No | F |
| CoC (calc.) | 0.021 mm (d/1500) | C |

| Modo | Resolución (px) | Área (mm) | Aspecto | Origen |
|---|---|---|---|---|
| 4K 4096 × 2304 | 4096 × 2304 | 27.6 × 15.5 | 1.78:1 | F |
| 4K 16:9 | 4096 × 2160 | 27.6 × 14.6 | 1.90:1 | C |
| 2K | 2048 × 1152 | 13.8 × 7.75 | 1.78:1 | C |

Fuentes: <https://fr.panavision.com/camera-and-optics/cameras/product-detail/phf4-phantom-flex4k> · <https://www.phantomcameras.cn/products/cameras/4kmedia/flex4k>

---

## 10. Notas sobre modelos 2025–2026

- **ARRI ALEXA 265** (ficha 3.5): 65 mm en cuerpo de 3.3 kg, 15 stops, LPL. Reemplaza a la ALEXA 65 para producción nueva.
- **ARRI ALEXA 35 Xtreme** (ficha 3.2): misma imagen que ALEXA 35, 330 fps con 17 stops y 660 fps en Sensor Overdrive (11 stops, EI 1600).
- **Blackmagic PYXIS 12K** (2025): mismo sensor y áreas que la URSA Cine 12K LF (12288 × 8040, 35.64 × 23.32 mm, 2.9 µm, ISO 800, 16 stops), en cuerpo PYXIS. Fuente: <https://www.blackmagicdesign.com/products/blackmagicpyxis/techspecs>
- **Sony VENICE 2 6K**: sigue listada por Sony (PDF enero 2025) con ISO base 500/2500, distinto de la 8.6K.

---

## 11. TABLA PARA DART

Formato: `fabricante|modelo|modo|resolucion|ancho_mm|alto_mm|base_iso|notas`
Sin comas decimales. `resolucion` = `ANCHOxALTO`. `base_iso` = valor numérico o `NV`. `notas` = origen + aspecto.

```text
ARRI|ALEXA 35|4.6K 3:2 Open Gate|4608x3164|27.99|19.22|800|fabrica; 1.46:1
ARRI|ALEXA 35|4.6K 16:9|4608x2592|27.99|15.75|800|fabrica; 1.78:1
ARRI|ALEXA 35|4K 16:9|4096x2304|24.88|14.00|800|fabrica; 1.78:1
ARRI|ALEXA 35|3.8K 2.39:1|3840x1608|23.33|9.77|800|fabrica; 2.39:1
ARRI|ALEXA 35|3.3K 6:5 ana 2x|3328x2790|20.22|16.95|800|fabrica; 2.39:1 desplegado
ARRI|ALEXA 35 Xtreme|4.6K 3:2 Open Gate|4608x3164|27.99|19.22|800|fabrica; 17 stops
ARRI|ALEXA 35 Xtreme|4.6K 16:9|4608x2592|27.99|15.75|800|fabrica; 1.78:1
ARRI|ALEXA Mini LF|4.5K LF 3:2 Open Gate|4448x3096|36.70|25.54|800|fabrica; 1.44:1
ARRI|ALEXA Mini LF|4.5K LF 2.39:1|4448x1856|36.70|15.31|800|fabrica; 2.39:1
ARRI|ALEXA Mini LF|4.3K LF 16:9|4320x2430|35.64|20.05|800|fabrica; 1.78:1
ARRI|ALEXA Mini LF|2.8K S35 4:3 ana 2x|2880x2160|23.76|17.81|800|fabrica; 2.39:1 desplegado
ARRI|ALEXA 65|6.5K Open Gate 5-perf|6560x3100|54.12|25.58|800|fabrica; 2.12:1
ARRI|ALEXA 65|2.39:1 recorte|6560x2745|54.12|22.65|800|calculado; 2.39:1
ARRI|ALEXA 265|6.5K 2.12:1 Open Gate|6560x3100|54.12|25.58|NV|fabrica; 15 stops
ARRI|ALEXA 265|5.1K 1.65:1|5120x3100|42.24|25.58|NV|fabrica; 1.65:1
ARRI|ALEXA 265|4.5K LF 3:2|4448x3096|36.70|25.54|NV|fabrica; 1.44:1
ARRI|ALEXA Mini|3.4K Open Gate|3424x2202|28.25|18.17|800|fabrica; 1.55:1
ARRI|ALEXA Mini|3.2K 16:9|3200x1800|26.40|14.85|800|fabrica; 1.78:1
ARRI|ALEXA Mini|2.8K 4:3 ana 2x|2880x2160|23.76|17.82|800|fabrica; 2.39:1 desplegado
RED|V-RAPTOR 8K VV|8K 17:9|8192x4320|40.96|21.60|800|fabrica; 1.89:1
RED|V-RAPTOR 8K VV|8K 2.4:1|8192x3456|40.96|17.28|800|calculado; 2.37:1
RED|V-RAPTOR 8K VV|6K 17:9|6144x3240|30.72|16.20|800|calculado; 1.89:1
RED|V-RAPTOR 8K VV|4K 17:9|4096x2160|20.48|10.80|800|calculado; 1.89:1
RED|V-RAPTOR XL 8K VV|8K 17:9|8192x4320|40.96|21.60|800|fabrica; montura PL/EF
RED|V-RAPTOR XL 8K VV|8K 2.4:1|8192x3456|40.96|17.28|800|calculado; 2.37:1
RED|KOMODO-X|6K 17:9|6144x3240|27.03|14.26|800|fabrica; 1.89:1
RED|KOMODO-X|6K 2.4:1|6144x2592|27.03|11.40|800|calculado; 2.37:1
RED|KOMODO-X|4K 17:9|4096x2160|18.02|9.50|800|calculado; 1.89:1
RED|MONSTRO 8K VV|8K Full Format|8192x4320|40.96|21.60|800|fabrica; 1.89:1
RED|MONSTRO 8K VV|8K 2.4:1|8192x3456|40.96|17.28|800|calculado; 2.37:1
RED|MONSTRO 8K VV|6K Full Format|6144x3240|30.72|16.20|800|calculado; 1.89:1
SONY|VENICE 2 8.6K|8.6K 3:2|8640x5760|35.9|24.0|800|fabrica; dual 800/3200
SONY|VENICE 2 8.6K|8.6K 17:9|8640x4556|35.9|19.0|800|fabrica; 1.89:1
SONY|VENICE 2 8.6K|8.2K 2.39:1|8192x3432|34.1|14.3|800|fabrica; 2.39:1
SONY|VENICE 2 8.6K|7.6K 16:9|7680x4320|32.0|18.0|800|fabrica; 1.78:1
SONY|VENICE 2 8.6K|5.8K 4:3|5792x4276|24.1|17.8|800|fabrica; 1.35:1
SONY|VENICE 2 8.6K|5.8K 6:5|5792x4854|24.1|20.2|800|fabrica; 1.19:1
SONY|VENICE 2 6K|6K 3:2|6048x4032|35.9|24.0|500|fabrica; dual 500/2500
SONY|VENICE 2 6K|6K 17:9|6054x3192|36.0|19.0|500|fabrica; 1.89:1
SONY|VENICE 2 6K|6K 2.39:1|6048x2534|35.9|15.0|500|fabrica; 2.39:1
SONY|VENICE 2 6K|4K 6:5|4096x3432|24.3|20.4|500|fabrica; 1.19:1
SONY|BURANO|FF 8.6K 16:9|8632x4856|35.9|20.2|800|fabrica; dual 800/3200
SONY|BURANO|FF 8.6K 17:9|8632x4552|35.9|18.9|800|fabrica; 1.89:1
SONY|BURANO|FFc 6K 17:9|6052x3192|33.6|17.7|800|fabrica; 1.89:1
SONY|BURANO|S35 5.8K 16:9|5760x3240|24.0|13.5|800|fabrica; 1.78:1
SONY|BURANO|S35 4.3K 4:3|4256x3192|23.6|17.7|800|fabrica; 1.33:1
SONY|FX9|6K FF|6048x3192|35.7|18.8|800|mm fabrica; px calculado
SONY|FX9|4K DCI FF|4096x2160|35.7|18.8|800|calculado; 1.89:1
SONY|FX9|5K S35|5120x2700|30.2|15.9|800|calculado; 1.89:1
SONY|FX6|4K DCI|4096x2160|35.6|18.8|800|calculado; 1.89:1
SONY|FX6|UHD 4K|3840x2160|35.6|20.0|800|calculado; 1.78:1
SONY|FX3|4K DCI|4096x2160|35.6|18.8|800|calculado; 1.89:1
SONY|FX3|UHD 4K|3840x2160|35.6|20.0|800|calculado; 1.78:1
CANON|EOS C400|6K FF|6000x3164|36.0|19.0|800|fabrica; 1.90:1
CANON|EOS C400|S35 4.3K|4368x2304|26.2|13.8|800|calculado; 1.90:1
CANON|EOS C400|S16 2.2K|2184x1152|13.1|6.9|800|calculado; 1.90:1
CANON|EOS C500 Mark II|5.9K FF|5952x3140|38.1|20.1|800|fabrica; 1.90:1
CANON|EOS C500 Mark II|4K DCI|4096x2160|26.2|13.8|800|calculado; 1.90:1
CANON|EOS C500 Mark II|UHD 4K|3840x2160|35.7|20.1|800|fabrica; area 5580x3140
CANON|EOS C70|4K DCI|4096x2160|26.2|13.8|800|fabrica; 1.90:1
CANON|EOS C70|UHD 4K|3840x2160|24.6|13.8|800|calculado; 1.78:1
BLACKMAGIC|URSA Cine 12K LF|12K 3:2 Open Gate|12288x8040|35.64|23.32|800|fabrica; 1.53:1
BLACKMAGIC|URSA Cine 12K LF|12K 16:9|12288x6912|35.64|20.04|800|calculado; 1.78:1
BLACKMAGIC|URSA Cine 12K LF|12K 17:9|12288x6480|35.64|18.79|800|calculado; 1.89:1
BLACKMAGIC|URSA Cine 12K LF|12K 2.4:1|12288x5112|35.64|14.82|800|calculado; 2.40:1
BLACKMAGIC|URSA Cine 12K LF|12K 6:5 ana 2x|9648x8040|27.98|23.32|800|calculado; 2.40:1 desplegado
BLACKMAGIC|URSA Cine 12K LF|9K 3:2 S35|9408x6264|27.28|18.17|800|calculado; 1.50:1
BLACKMAGIC|URSA Mini Pro 12K|12K DCI|12288x6480|27.03|14.25|800|fabrica; 1.90:1
BLACKMAGIC|URSA Mini Pro 12K|12K 2.4:1|12288x5112|27.03|11.25|800|calculado; 2.40:1
BLACKMAGIC|URSA Mini Pro 12K|8K DCI|8192x4320|18.02|9.50|800|calculado; 1.90:1
BLACKMAGIC|PYXIS 6K|6K 3:2 Open Gate|6048x4032|36.0|24.0|400|fabrica; dual 400/3200
BLACKMAGIC|PYXIS 6K|6K 6:5 ana 2x|4832x4032|28.70|23.95|400|calculado; 2.40:1 desplegado
BLACKMAGIC|PYXIS 6K|6K 16:9|6048x3408|35.93|20.24|400|calculado; 1.78:1
BLACKMAGIC|PYXIS 6K|4K S35 4:3|4096x3072|24.33|18.25|400|calculado; 1.33:1
BLACKMAGIC|Pocket 6K Pro|6K|6144x3456|23.10|12.99|400|fabrica; dual 400/3200
BLACKMAGIC|Pocket 6K Pro|6K 2.4:1|6144x2560|23.10|9.63|400|calculado; 2.40:1
BLACKMAGIC|Pocket 6K Pro|3.7K 6:5 ana 2x|3728x3104|14.02|11.67|400|calculado; 2.40:1 desplegado
PANAVISION|Millennium DXL2|8K Full Format|8192x4320|40.96|21.60|1600|fabrica; 1.89:1
PANAVISION|Millennium DXL2|8K 2.4:1|8192x3456|40.96|17.28|1600|calculado; 2.37:1
PANAVISION|Millennium DXL2|5K S35|5120x2700|25.60|13.50|1600|calculado; 1.89:1
PHANTOM|Flex4K|4K 4096x2304|4096x2304|27.6|15.5|250|fabrica; 1.78:1
PHANTOM|Flex4K|4K 16:9|4096x2160|27.6|14.6|250|calculado; 1.90:1
```

---

## 12. RIESGOS (datos dudosos o incompletos)

1. **ALEXA 35 / 35 Xtreme — modos "4.8K".** Material promocional de ARRI para la ALEXA 35 Xtreme menciona un Open Gate "4.8K", pero la ficha técnica solo lista 4.6K (4608 × 3164). No se incluyó ningún modo 4.8K. Verificar con el manual SUP vigente antes de cargarlo al catálogo.
2. **ALEXA 265 — ISO base.** ARRI publica "EI 160–6400" pero no declara EI base en la ficha. Se dejó `NV`. No asumir 800.
3. **ALEXA 265 / ALEXA 65 — soporte anamórfico.** No se encontró documentación de modos 4:3/6:5 ni de desqueeze en la ficha del 265. Marcado NV.
4. **ALEXA 65 — 3100 vs 3102 fotositos.** La ficha de ARRI (vía ALEXA 265, mismo formato) y la documentación de ARRI usan 6560 × 3100; notas de prensa de 2014 citan 6560 × 3102. Se usó 3100.
5. **ALEXA 65 — montura.** Original XPL (64 mm); ARRI documenta LPL disponible para ALEXA 65. Las unidades de alquiler pueden tener cualquiera de las dos. Confirmar por unidad.
6. **ALEXA 65 — ISO base y rango.** EI 800 base / 200–3200 proviene de ficha de distribuidor (Illumination Dynamics), no de una página vigente de ARRI. Alta confianza, pero no es fuente primaria actual.
7. **ARRI — áreas redondeadas.** ARRI publica 28.0 × 19.2 y 28.0 × 15.7; el cálculo exacto con pitch 6.075 µm da 27.99 × 19.22 y 27.99 × 15.75. En la tabla Dart se usó el valor exacto. Diferencia ≤ 0.05 mm.
8. **RED — ISO.** RED no publica "native ISO" como tal: el manual indica ISO 800 por defecto y rango 250–12800. Se cargó 800 como base. Para V-RAPTOR [X] el manual consultado es V1.7 (2024).
9. **RED — áreas por modo.** RED publica resoluciones y tamaño de sensor, no mm por modo. Todas las áreas por modo son calculadas con pitch 5.0 µm (VV) o 4.4 µm (KOMODO-X). Error posible < 0.05 mm.
10. **Sony VENICE 2 8.6K — errata del PDF.** La ficha dice "フルフレーム 25.9mm x 24mm"; debe ser 35.9 mm (confirmado por las tablas de modos del mismo PDF). No usar 25.9.
11. **Sony FX9 — resolución 6K.** Sony no publica el número exacto de píxeles del modo 6K; se usó 6048 × 3192 derivado de 35.7 × 18.8 mm a 5.9 µm. Confirmar contra menú de cámara.
12. **Sony FX6 / FX3 — mm por modo.** Sony solo publica 35.6 × 23.8 mm del sensor; las áreas 4K DCI/UHD son calculadas asumiendo uso de ancho completo. Verificar con la herramienta de formatos de Sony.
13. **Canon C400 — área 36.0 × 19.0 mm.** No está en la ficha de Canon China; proviene de la ficha de Canon reproducida por distribuidores. El sensor NO es 36 × 24: es 1.90:1.
14. **Canon C400 — ISO base.** Canon declara triple base ISO 800/3200/12800 para RAW/Log (confirmado también por Canon Australia/Canadá). No es dual clásico: son tres ganancias. La ficha de Canon China lista además 400/1600/6400 para 709.
15. **Canon C500 Mark II — ISO base.** Canon no lo declara en la ficha; 800 proviene de fuentes secundarias (cine.alps.tokyo, CineD). Verificar.
16. **Canon C70 — 16+ stops.** Dato de marketing Canon (DGO, Canon Log 2), no medido independientemente.
17. **Blackmagic URSA Cine 12K LF — ISO 800.** No figura en la ficha técnica de BMD; proviene de Filmmakers Academy y trm.fr, que además afirman que NO hay dual native ISO. Confirmar con el manual.
18. **Blackmagic — áreas por modo.** Calculadas con pitch publicado (2.9 / 2.2 / 5.94 / 3.76 µm). El modo 12K 6:5 de la URSA Cine (9648 × 8040) es una ventana de ancho, no un crop central.
19. **PYXIS 6K — 36 × 24 vs 35.93 × 23.95.** BMD publica 36 × 24; el cálculo con 5.94 µm da 35.93 × 23.95. Se usó el valor de fábrica en la tabla principal.
20. **Panavision DXL2 — ISO 1600.** Es el ISO nativo declarado por Panavision, distinto del 800 por defecto del sensor MONSTRO. No es un error: Panavision calibra distinto.
21. **Phantom Flex4K — fps.** Vision Research declara 938 fps a 4096 × 2304; Panavision declara 900 fps full sensor. Diferencia de criterio de grabación/ventana.
22. **CoC.** Todos los valores son calculados (d/1500). No hay CoC oficial de fabricante para ninguna de estas cámaras.
23. **Cámaras descontinuadas.** ALEXA 35, ALEXA 65, ALEXA Mini, URSA Mini Pro 12K, MONSTRO 8K VV y Flex4K figuran como referencia; su disponibilidad de alquiler varía por mercado.

---

## 13. FUENTES

**ARRI**
- ALEXA 35 (legacy): <https://www.arri.com/en/cine-systems/cine-cameras/legacy-cine-cameras/alexa-35>
- ALEXA 35 Xtreme: <https://www.arri.com/en/cine-systems/cine-cameras/alexa-35-xtreme>
- ALEXA Mini LF: <https://www.arri.com/en/cine-systems/cine-cameras/alexa-mini-lf>
- ALEXA LF: <https://www.arri.com/en/cine-systems/cine-cameras/alexa-lf>
- ALEXA Mini: <https://www.arri.com/en/cine-systems/cine-cameras/legacy-cine-cameras/alexa-mini>
- ALEXA 265: <https://www.arri.com/en/cine-systems/cine-cameras/alexa-265>
- ALEV sensors (A3X 6560 × 3100): <https://www.arri.com/en/learn/arri-camera-technology/alev-sensors>
- ALEXA 65 (ficha distribuidor): <https://www.illuminationdynamics.com/alexa-65>
- ARRI Formats & Resolutions Overview v6.1 (2025-11): <https://www.arri.com/resource/blob/390890/0ecfdcb70ea22c5fc489f0fb7267aa30/2025-11-arri-formatsandresolutionsoverview-v6-1-data.pdf>

**RED**
- V-RAPTOR [X] 8K VV: <https://docs.red.com/955-0225/955-0225_V1.7+Rev-B+RED+PS,+V-RAPTOR+%5bX%5d+8K+VV+Operation+Guide+HTML/Content/B_TechSpecs/Specs_V-RAPTOR%20[X].htm>
- V-RAPTOR XL 8K VV: <https://docs.red.com/955-0203/955-0203_V2.1%20Rev-A%20RED%20PS,%20V-RAPTOR%20XL%208K%20VV%20Operation%20Guide%20HTML/Content/B_TechSpecs/Specs_V-RAPTOR_XL.htm>
- KOMODO-X: <https://docs.red.com/955-0219/955-0219_V1.0beta%20Rev-A%20RED%20PS,%20KOMODO-X%20ST%20Operation%20Guide/Content/A_TechSpecs/Specs_KOMODO-X.htm>
- MONSTRO 8K VV: <https://docs.red.com/955-0160_v7.0/WEAPONMONSTRO8KVVOperationGuide/en-us/Content/A_TechSpecs/Specs_DSMC2_MONSTRO.htm>
- ISO por defecto 800: <http://docs.red.com.s3.amazonaws.com/955-0160/WEAPONMONSTRO8KVVOperationGuide/zh-cn/Content/5_Advanced_Menus/1_Settings/Look/ISO_FLUT.htm>

**Sony**
- VENICE 2 8.6K formatos: <https://www.sony.jp/ls-camera/reference/pdf/VENICE_2_MPC-3628_recording_format.pdf>
- VENICE 2 6K formatos: <https://www.sony.jp/ls-camera/reference/pdf/VENICE_2_MPC-3626_recording_format.pdf>
- BURANO formatos: <https://www.sony.jp/ls-camera/reference/pdf/BURANO_recording_format.pdf>
- FX9 catálogo: <https://www.sony.jp/products/catalog/FX9_2104.pdf>
- FX9 sensor 35.7 × 18.8 (Sony Cinematography / AbelCine): <https://sony-cinematography.com/articles/evaluating-the-sony-fx9-and-venice-sensors---an-abelcine-tutorial-and-guide/>
- FX6 especificaciones: <https://www.sony.jp/pro-cam/products/ILME-FX6V/specification.html>
- FX6 características (ISO 800/12800): <https://www.sony.jp/pro-cam/products/ILME-FX6V/feature_1.html>
- FX3 especificaciones: <https://www.sony.jp/pro-cam/products/archive/ILME-FX3A/spec.html>

**Canon**
- C400: <https://m.canon.com.cn/product/eosc400/spec.html>
- C400 área 36.0 × 19.0 (ficha Canon reproducida): <https://www.glazerscamera.com/collections/canon/products/canon-eos-c400-cinema-camera>
- C500 Mark II (China): <https://www.canon.com.cn/product/eosc500markii/spec.html>
- C500 Mark II PDF técnico: <https://mnd-assets.mynewsdesk.com/image/upload/f_pdf,fl_attachment/sqvgpvxpflkpczssjrbr>
- C70: <https://m.canon.com.cn/product/eosc70/spec.html>
- C70 26.2 × 13.8 / ISO 800: <https://www.bandpro.com/canon-eos-c70-cinema-camera-body-4k-super-35-rf-mount-4507c002.html>

**Blackmagic Design**
- URSA Cine 12K LF: <https://www.blackmagicdesign.com/products/blackmagicursacine/techspecs/W-URSA-70>
- PYXIS (6K y 12K): <https://www.blackmagicdesign.com/products/blackmagicpyxis/techspecs>
- Pocket 6K Pro: <https://www.blackmagicdesign.com/products/blackmagicpocketcinemacamera/techspecs>
- URSA Mini Pro 12K (PDF): <https://www.blackmagicdesign.com/api/print/to-pdf/au/products/blackmagicursaminipro/techspecs/W-URSA-40>
- URSA Cine 12K LF ISO 800 / sin dual ISO: <https://www.filmmakersacademy.com/blog-ursa-cine-12k-lf-ergonomics/>

**Panavision / Phantom**
- DXL2: <https://www.panavision.com/camera-and-optics/cameras/product-detail/dxl2-millennium-dxl2>
- Phantom Flex4K (Panavision): <https://fr.panavision.com/camera-and-optics/cameras/product-detail/phf4-phantom-flex4k>
- Phantom Flex4K (Vision Research, distribuidor): <https://www.phantomcameras.cn/products/cameras/4kmedia/flex4k>

**CoC**
- <https://en.wikipedia.org/wiki/Circle_of_confusion>
- <https://en.wikipedia.org/wiki/Zeiss_formula>
