# Formatos fílmicos — catálogo técnico verificado para On Set Pro

**Investigación:** 2026-11-12  
**Destino:** catálogo Dart de On Set Pro  
**Criterio de datos:** punto decimal. `NO VERIFICADO` = no se encontró fuente para ese dato. `calc.` = calculado a partir de datos verificados. `deriv.` = derivado con una regla explícita (se indica cuál). Las dimensiones son de **cuadro de cámara** salvo que se diga "proyección".

---

## 0. Convenciones (leer antes de usar la tabla)

### 0.1 Cuadro de cámara vs. cuadro de proyección

La apertura de cámara es la que define el encuadre y el campo de visión; la de proyección es la que se ve en pantalla y suele ser menor. En 35 mm Academy, por ejemplo, la cámara expone 22.0 × 16.0 mm, pero el aperture plate de proyección es 20.96 × 15.29 mm (0.825 × 0.602 in). En 65 mm 5-perf, la cámara expone 52.48 × 23.01 mm y la proyección 48.56 × 22.10 mm. Para una app de dirección de fotografía, el valor útil para FOV/DoF es el de **cámara**; el de proyección sirve para entender el recorte final.

### 0.2 Paso de negativo vs. paso de copia

El paso (pitch) no es idéntico en negativo y en copia:

- **35 mm:** negativo BH-1866 = 4.74 mm; copia KS-1870 = 4.75 mm.
- **16 mm:** negativo = 7.605 mm; copia/reversal = 7.620 mm.
- **65 mm:** paso corto = 4.740 mm; paso largo = 4.750 mm. IMAX 15/70 usa paso corto 4.74 mm (SMPTE ST 417).
- **Super 8:** 4.234 mm. **8 mm estándar:** 3.810 mm. **9.5 mm:** 7.54 mm (perforación central).

En las tablas se usa el nominal 4.75 / 7.62 / 4.75 y se aclara el negativo cuando corresponde. La diferencia de 0.01 mm no cambia el consumo de forma apreciable (<0.3 %).

### 0.3 Frecuencia

Todos los consumos de las tablas son a **24.000 fps exactos**, con movimiento continuo y sin rampas. A 25 fps multiplicar por 1.0417; a 48 fps por 2; a 60 fps por 2.5. A 23.976 fps la diferencia con 24 es −0.1 %.

### 0.4 Círculo de confusión (COC)

El COC **no es una propiedad del formato**: es el diámetro de blur que se acepta como "enfocado" según el tamaño de imagen y la ampliación final. Por eso hay valores distintos según la fuente. En este documento:

- 35 mm: **0.0254 mm** (0.001 in), ASC *American Cinematographer Manual*.
- 16 mm: **0.0152 mm** (0.0006 in), ASC.
- Super 16: **0.0125 mm** (0.0005 in), Cooke/FDTimes; el ASC da 0.0152 mm para 16 mm en general.
- 65 mm, 8/70, IMAX, Super 8, 8 mm y 9.5 mm: **no hay valor normativo publicado** en las fuentes consultadas; se da un valor `deriv.` = diagonal del cuadro / 1200, marcado con asterisco y explicado en §5. No debe presentarse como norma.

### 0.5 Fórmula de consumo

```text
m/min = perfs_cuadro * paso_mm * 24 * 60 / 1000
m/min = perfs_cuadro * paso_mm * 1.44
ft/min = m/min / 0.3048
```

El consumo depende del **paso de cuadro** (perfs/cuadro × pitch) y de los fps, no del área de imagen. Por eso 35 mm 3-perf consume 75 % de 4-perf y 2-perf consume 50 %, aunque el ancho del cuadro sea el mismo.

### 0.6 Rollos y duración

Las duraciones son `rollo / consumo`, con 24 fps continuos. No incluyen leader, colas de protección, pérdidas de carga ni rampas de velocidad. Los rollos indicados son los comerciales habituales, no toda la oferta de cada fabricante.

---

## 1. Tabla general

| Formato | Cuadro cámara (mm) | Relación cámara / proy. | Paso (mm) | Perfs/cuadro | 24 fps (ft/min) | 24 fps (m/min) | COC (mm) | Base |
|---|---|---:|---:|---:|---:|---:|---:|---|
| **65 mm 5-perf (5/70)** | 52.48 × 23.01 | 2.28:1 / 2.20:1 | 4.75 (neg. 4.74) | 5 | 112.5 | 34.29 | 0.048* | SMPTE ST 215 / ST 152 |
| **65 mm 8-perf (8/70)** | 52.63 × 37.72 | 1.40:1 / 1.35:1 | 4.75 (corto 4.74) | 8 | 179.53 | 54.72 | 0.054* | SMPTE ST 418 / ST 420 |
| **65 mm 15-perf IMAX (15/70)** | 70.41 × 51.61 | 1.36:1 / 1.43:1 | 4.74 (corto) | 15 | 335.91 | 102.38 | 0.073* | SMPTE ST 417 / ST 419 |
| **35 mm 4-perf full / Super 35** | 24.92 × 18.67 | 1.33:1 | 4.75 (neg. 4.74) | 4 | 90.0 | 27.43 | 0.0254 | SMPTE ST 59 C / ASC |
| **35 mm 4-perf Academy** | 22.0 × 16.0 | 1.375:1 | 4.75 | 4 | 90.0 | 27.43 | 0.0254 | SMPTE ST 59 A / ASC |
| **35 mm 3-perf** | 24.92 × 13.87 | 1.80:1 | 4.75 | 3 | 67.5 | 20.57 | 0.0254 | SMPTE ST 59 D |
| **35 mm 2-perf Techniscope** | 22.05 × 9.47 | 2.33:1 neg. | 4.75 | 2 | 45.0 | 13.72 | 0.0254 | Techniscope (0.868 × 0.373 in) |
| **Super 16** | 12.52 × 7.41 | 1.69:1 / 1.66:1 | 7.62 (neg. 7.605) | 1 | 36.0 | 10.97 | 0.0125 | SMPTE 201 |
| **16 mm estándar** | 10.26 × 7.49 | 1.37:1 | 7.62 (neg. 7.605) | 1 | 36.0 | 10.97 | 0.0152 | SMPTE ST 7 |
| **Super 8** | 5.69 × 4.22 | 1.35:1 / 1.33 nominal | 4.234 | 1 | 20.0 | 6.10 | 0.006* | ISO 3645 |
| **8 mm estándar (Double 8)** | 4.90 × 3.60 | 1.36:1 / 1.33 nominal | 3.810 | 1 | 18.0 | 5.49 | 0.005* | ISO 486 |
| **9.5 mm Pathé** | 8.50 × 6.50 | 1.31:1 / 1.33 proy. | 7.54 | 1 (central) | 35.62 | 10.86 | 0.009* | Pathé Baby manual |

\* COC derivado: diagonal del cuadro / 1200 (criterio angular citado por Cooke/FDTimes). No es un valor normalizado ni verificado como práctica de formato; ver §5 y RIESGOS.

**Notas rápidas de la tabla**

- 65 mm 5-perf: 52.48 mm es el valor de SMPTE ST 215 y del ASC (2.066 in). ARRI 765 declara 52.5 mm; la cifra 52.63 que circula en Wikipedia corresponde al ancho del 8/70 (SMPTE ST 418). Ver RIESGOS.
- IMAX: 51.61 mm de alto es SMPTE ST 417; Wikipedia publica 52.63 mm. La proyección de SMPTE ST 419 es 69.60 × 48.56 mm, no 69.6 × 48.5.
- Academy: 22.0 × 16.0 mm es SMPTE ST 59; el ASC usa 21.95 × 16.0 mm (0.864 in). La diferencia es 0.05 mm.
- Full aperture: 24.92 × 18.67 mm es SMPTE ST 59; el ASC usa 24.89 × 18.67 mm (0.980 in). Diferencia 0.03 mm.
- 16 mm y Super 16: se usa la apertura de cámara (10.26 × 7.49 y 12.52 × 7.41). El área de imagen es algo menor (10.05 × 7.42 y 12.35 × 7.42); ver §3.3.
- Super 8 y 8 mm: se usa la apertura de cámara (5.69 × 4.22 y 4.90 × 3.60). El área proyectable es 5.46 × 4.01 y 4.55 × 3.40.
- 9.5 mm: 8.50 × 6.50 de cámara; el área proyectada es 8.20 × 6.15.

---

## 2. Chasis, bobinas y duración a 24 fps

| Formato | Bobinas comerciales (pies / m) | Duración a 24 fps |
|---|---|---|
| **65 mm 5-perf** | 500 ft / 152.4 m; 1000 ft / 304.8 m (ARRI 765) | 4.44 min (4:26.7); 8.89 min (8:53.3) |
| **65 mm 8-perf (8/70)** | 1000 ft / 304.8 m como referencia; capacidad de chasis 8/70 **NO VERIFICADA** | 5.57 min (5:34.2) `calc.` |
| **IMAX 15/70** | 1000 ft / 304.8 m | 2.98 min (2:58.6) ≈ 3 min |
| **35 mm 4-perf full / Academy** | 100 ft / 30.48 m (spool); 200 ft / 60.96 m; 400 ft / 121.92 m; 1000 ft / 304.8 m | 1.11 (1:06.7); 2.22 (2:13.3); 4.44 (4:26.7); 11.11 min (11:06.7) |
| **35 mm 3-perf** | 400 ft / 121.92 m; 1000 ft / 304.8 m | 5.93 min (5:55.6); 14.81 min (14:48.9) |
| **35 mm 2-perf Techniscope** | 400 ft / 121.92 m; 1000 ft / 304.8 m | 8.89 min (8:53.3); 22.22 min (22:13.3) |
| **Super 16 / 16 mm** | 100 ft / 30.48 m; 200 ft / 60.96 m (Aaton A-Minima); 400 ft / 121.92 m | 2.78 (2:46.7); 5.56 (5:33.3); 11.11 min (11:06.7) |
| **Super 8** | 50 ft / 15.24 m (cartucho) | 2.50 min (2:30) |
| **8 mm estándar (Double 8)** | 25 ft / 7.62 m de película doble-8 → 50 ft / 15.24 m proyectados | 2.78 min (2:46.7) a 24 fps; 4.17 min a 16 fps |
| **9.5 mm Pathé** | 30 ft / 9.14 m; 60 ft / 18.29 m; 27 ft / 8.23 m (cargador de cámara) | 0.84 (0:50.5); 1.68 (1:41.1); 0.76 min (0:45.5) |

**Sobre los rollos**

- 35 mm: el spool de cámara clásico es de 100 ft (Kodak S-83); los chasis de 400 ft y 1000 ft son el estándar profesional (ARRI 435 y equivalentes). También existen 200 ft para cámaras compactas.
- 65 mm: ARRI 765 ofrece chasis de 500 ft (150 m) y 1000 ft (300 m); el de 500 ft es el que aparece en el dato de peso de la cámara.
- 16 mm: 100 ft en spool, 400 ft en core/spool; Aaton A-Minima usa 200 ft.
- Super 8: el cartucho Kodak es de 50 ft (15 m); a 24 fps rinde 2.5 min y a 18 fps 3.33 min.
- Doble 8: el rollo amateur estándar es de 25 ft, que tras el revelado y corte rinde 50 ft de 8 mm.
- 9.5 mm: cartuchos de 30 y 60 ft; el cargador de cámara Pathé Baby tomaba 27 ft. El museo también menciona bobinas de 300 ft (~10 min según su ficha).

---

## 3. Notas por bloque y fuentes

### 3.1 65 mm: 5-perf, 8-perf (8/70) e IMAX 15/70

**65 mm 5-perf (5/70).**  
SMPTE ST 215 define la apertura de cámara como 2.066 × 0.906 in = **52.48 × 23.01 mm**; SMPTE ST 152 define la proyección como **48.56 × 22.10 mm** (2.2:1). ARRI 765 declara una apertura de imagen de **52.5 × 23.0 mm**, ground glass/proyección **48.5 × 22.0 mm** y relación 2.2:1, lo que es consistente con la norma. Son 5 perforaciones por cuadro, paso 4.75 mm (negativo 4.74). El consumo es **112.5 ft/min = 34.29 m/min** según la tabla de footage del ASC, que usa 1 ft = 12.8 frames; el cálculo geométrico 5 × 4.75 × 24 da 112.2 ft/min, diferencia de redondeo. La cifra 52.63 mm que aparece en Wikipedia no coincide con la norma de 5/70: 52.63 es el ancho del 8/70 (SMPTE ST 418). Se adopta 52.48.

**65 mm 8-perf (8/70, Dynavision).**  
SMPTE ST 418 define la apertura de cámara como 2.072 × 1.485 in = **52.63 × 37.72 mm**; SMPTE ST 420 define la proyección como **48.56 × 36.00 mm** (1.35:1). El ASC describe el formato como "65 mm 8-perforation, vertical pulldown (Dynavision)", con apertura de cámara 2.080 × 1.480 in = 52.83 × 37.59 mm, para impresión sobre 70 mm; la diferencia con ST 418 es de 0.2 mm en ancho y 0.13 mm en alto. Son 8 perforaciones; 8 × 4.74 = 37.92 mm, que equivale a 37.72 de cuadro + 0.20 de línea de cuadro (ST 418). Consumo calculado: 8 × 4.75 × 24 → **179.53 ft/min = 54.72 m/min**; con paso corto 4.74 da 179.15 ft/min. La capacidad de chasis del 8/70 no está verificada; la duración de 5.57 min es para 1000 ft.

**IMAX 15/70.**  
SMPTE ST 417 define la apertura de cámara como **70.41 × 51.61 mm**, 15 perforaciones, paso corto **4.74 mm** y línea de cuadro 0.69 mm; 15 × 4.74 = 71.1 mm por cuadro. SMPTE ST 419 define la proyección como **69.60 × 48.56 mm** (1.43:1). El formato es de arrastre horizontal (15/70): el negativo es de 65 mm y la copia de 70 mm. Consumo calculado: 15 × 4.74 × 24 → **335.91 ft/min = 102.38 m/min**. Un rollo de 1000 ft (305 m) da 2.98 min; el Smithsonian documenta 1000 ft y "tres minutos" para el magazine del transbordador. Wikipedia publica 52.63 mm de alto de cámara; se usa 51.61 de ST 417 y se deja la discrepancia en RIESGOS.

**Fuentes de este bloque:** [SMPTE ST 215 (65 mm camera aperture image)](https://pub.smpte.org/doc/st215/19951201-pub/), [SMPTE ST 145 (65 mm perforated KS, paso 4.74/4.75)](https://pub.smpte.org/doc/st145/20041108-pub/), [SMPTE ST 152 (70 mm projectable area)](https://pub.smpte.org/doc/st152/20031020-pub/), [SMPTE ST 418 (8/70 camera)](https://pub.smpte.org/doc/st418/20051018-pub/), [SMPTE ST 420 (8/70 projection)](https://pub.smpte.org/pub/st420/st0420-2005_stable2016.pdf), [SMPTE ST 417 (15/70 camera)](https://pub.smpte.org/doc/st417/20051018-pub/), [SMPTE ST 419 (15/70 projection)](https://pub.smpte.org/doc/st419/20051018-pub/), [ARRI 765 technical data](https://www.arrirental.com/en/cameras/analog-film/arriflex-765), [ASC Manual 1993 (texto OCR)](https://archive.org/download/asc-1993-american-cinematographer-manual.pdf/ASC%20-%20%5B1993%5D%20-%20American%20Cinematographer%20Manual.pdf_text.pdf), [Wikipedia 70 mm film](https://en.wikipedia.org/wiki/70_mm_film), [Smithsonian IMAX magazine](https://www.si.edu/object/magazine-displacement-imax:nasm_A20120258006).

### 3.2 35 mm: 4-perf full/Super 35, Academy, 3-perf y 2-perf Techniscope

**35 mm 4-perf full aperture / Super 35.**  
SMPTE ST 59 Style C define la apertura de cámara como 0.981 × 0.735 in = **24.92 × 18.67 mm** (1.33:1, 4:3). El ASC usa 0.980 × 0.735 in = 24.89 × 18.67 mm. Es la apertura que se usa en Super 35: ocupa todo el espacio entre perforaciones, incluida la zona que en una copia con sonido sería la pista. 4 perforaciones, paso 4.75 (negativo 4.74). Consumo **90 ft/min = 27.43 m/min** (ASC: 1 ft = 16 frames). COC de práctica: **0.0254 mm** (0.001 in, ASC). Las tablas ARRI/ZEISS Master Anamorphic usan 0.030 mm para 35 mm anamórfico; es un rango de práctica, no un único valor.

**35 mm 4-perf Academy.**  
SMPTE ST 59 Style A define 0.866 × 0.630 in = **22.0 × 16.0 mm** (1.375:1); el ASC usa 0.864 × 0.630 in = **21.95 × 16.0 mm**. La proyección Academy es 0.825 × 0.602 in = **20.96 × 15.29 mm**. Son 4 perforaciones y el mismo consumo de 90 ft/min. Es el formato de cámara clásico para 1.85:1 con protección a 1.33:1; el cuadro grabado es 1.375 y el 1.85 se obtiene con máscara de proyección.

**35 mm 3-perf.**  
SMPTE ST 59 Style D define la apertura de cámara como 0.981 × 0.546 in = **24.92 × 13.87 mm** (1.80:1; 16:9 práctico con recorte). Son 3 perforaciones; el consumo es 3/4 del de 4-perf: **67.5 ft/min = 20.57 m/min** (calc. sobre 90 ft/min). Es un formato de producción, no de proyección directa: requiere conversión óptica o digital a 4-perf para copia.

**35 mm 2-perf Techniscope.**  
Technicolor Italia, 1960. Apertura de cámara **22.05 × 9.47 mm** (0.868 × 0.373 in), relación 2.33:1 en el negativo; la copia se hace estirando verticalmente 2× a un cuadro anamórfico de 4 perforaciones, con relación de proyección 2.35:1 (2.39:1 desde la revisión SMPTE de 1970). Son 2 perforaciones; el consumo es la mitad de 4-perf: **45 ft/min = 13.72 m/min**. Es un formato solo de producción (no se proyecta el negativo de 2 perf).

**Rollos y duración (35 mm).**

- 100 ft (4-perf) = 1.11 min a 24 fps.
- 400 ft = 4.44 min a 4-perf; 5.93 min a 3-perf; 8.89 min a 2-perf.
- 1000 ft = 11.11 min a 4-perf; 14.81 min a 3-perf; 22.22 min a 2-perf.
- 200 ft también existe para cámaras compactas (ARRI 435).

**Fuentes de este bloque:** [SMPTE ST 59 (35 mm camera aperture images)](https://pub.smpte.org/latest/st59/st0059-1998_stable2015.pdf), [ASC Manual 1993 (texto OCR)](https://archive.org/download/asc-1993-american-cinematographer-manual.pdf/ASC%20-%20%5B1993%5D%20-%20American%20Cinematographer%20Manual.pdf_text.pdf), [ARRI/ZEISS Master Anamorphic DoF tables (COC 0.030)](http://www.afcinema.com/IMG/pdf/0/b/f/depth-of-field-tables-arri-zeiss-master-anamorphic-lenses-feet.pdf), [Wikipedia 35 mm movie film](https://en.wikipedia.org/wiki/35_mm_movie_film), [Wikipedia Techniscope](https://en.wikipedia.org/wiki/Techniscope), [Widescreen Museum Techniscope](http://www.widescreenmuseum.com/widescreen/wingts1.htm), [ARRI 435 magazines 200/400/1000 ft](https://groupe-tsf.com/cameras-optics/arri-arriflex-435/).

### 3.3 16 mm y Super 16

**16 mm estándar.**  
SMPTE ST 7 define la apertura de cámara como 0.404 × 0.295 in = **10.26 × 7.49 mm** (1.37:1). Una perforación por cuadro; paso 7.620 mm en copia/reversal y 7.605 mm en negativo. Consumo **36 ft/min = 10.97 m/min** (ASC: 1 ft = 40 frames). COC de práctica: **0.0152 mm** (0.0006 in, ASC). Ojo: el área de imagen según ISO 466 es 10.05 × 7.42 mm, algo menor que la apertura; para FOV se usa la apertura, para exposición/scan se puede usar el área de imagen.

**Super 16 (Type W).**  
Apertura de cámara **12.52 × 7.41 mm** (dato de ficha SMPTE 201M-1988 que recoge la literatura; 1.69:1). La imagen Type W según SMPTE 201M-1996 es **12.35 × 7.42 mm**. Una perforación por cuadro y el mismo paso de 16 mm. Consumo **36 ft/min = 10.97 m/min**. COC: Cooke/FDTimes usa **0.0125 mm** (0.0005 in) para Super 16; el ASC da 0.0152 mm para 16 mm en general. La diferencia es criterio de ampliación: S16 se amplía a 35 mm, por eso se usa un COC más estricto.

**Rollos y duración (16 mm / S16).**

- 100 ft = 2.78 min; 200 ft (Aaton A-Minima) = 5.56 min; 400 ft = 11.11 min.
- Los chasis de 400 ft son el estándar profesional; el de 100 ft es el spool clásico.

**Fuentes de este bloque:** [SMPTE ST 7 (16 mm camera aperture)](https://pub.smpte.org/doc/st7/20041108-pub/), [SMPTE ST 201 (16 mm Type W camera aperture image)](https://pub.smpte.org/doc/st201/19960408-pub/), [Cooke/FDTimes "Depth of Field in Cinematography"](https://cookeoptics.cn/wp-content/uploads/2021/11/Depth-of-Field-Explained-FDTimes-June-2006.pdf), [ASC Manual 1993 (texto OCR)](https://archive.org/download/asc-1993-american-cinematographer-manual.pdf/ASC%20-%20%5B1993%5D%20-%20American%20Cinematographer%20Manual.pdf_text.pdf), [Kodak Cinematographer's Field Guide H-2](http://www.davidelkins.com/download/download_files/kodak/H-2_Cinematographers_Field_Guide_6-09.pdf), [Wikipedia 16 mm film](https://en.wikipedia.org/wiki/16_mm_film).

### 3.4 Super 8, 8 mm estándar y 9.5 mm Pathé

**Super 8.**  
Apertura de cámara **5.69 × 4.22 mm**; área proyectable **5.46 × 4.01 mm** (1.35:1 / 1.33 nominal). Una perforación por cuadro; paso **4.234 mm**. Consumo **20 ft/min = 6.10 m/min** (72 frames/ft). Cartucho Kodak de **50 ft / 15.24 m**: 2.5 min a 24 fps, 3.33 min a 18 fps. COC: no hay valor ASC/Cooke específico; `deriv.` 0.006 mm. Algunas fuentes citan 5.79 × 4.01 mm; la tabla ISO/ANSI da 5.69 × 4.22 de cámara y 5.46 × 4.01 de proyección.

**8 mm estándar (Double 8 / Regular 8).**  
Apertura de cámara **4.90 × 3.60 mm**; área proyectable **4.55 × 3.40 mm** (1.36:1 / 1.33 nominal). Una perforación por cuadro; paso **3.810 mm** (80 perfs/ft). Consumo **18 ft/min = 5.49 m/min**. El rollo amateur estándar es de **25 ft** de película doble-8, que tras revelado y corte rinde **50 ft** de 8 mm: 2.78 min a 24 fps y 4.17 min a 16 fps. COC: `deriv.` 0.005 mm. La velocidad habitual de este formato era 16-18 fps, no 24; se incluye 24 para comparación.

**9.5 mm Pathé.**  
Formato de Pathé (1922), película de 9.5 mm con **una perforación central** entre cuadros. Apertura de cámara **8.50 × 6.50 mm**; área proyectada **8.20 × 6.15 mm** (1.31:1 / 1.33 proy.). Paso **7.54 mm**; 1 perforación central por cuadro. Consumo **35.62 ft/min = 10.86 m/min** (a 24 fps). Cartuchos de **30 ft / 9.14 m** y **60 ft / 18.29 m**; cargador de cámara de **27 ft / 8.23 m**. Duraciones a 24 fps: 0.84 min (30 ft), 1.68 min (60 ft), 0.76 min (27 ft). A 16 fps (velocidad silent habitual) duran 1.26 / 2.53 / 1.14 min. COC: `deriv.` 0.009 mm. La fuente de Wikipedia cita 135.1 frames/m, que no es consistente con 7.54 mm de paso (daría 132.6 frames/m); se deja en RIESGOS.

**Fuentes de este bloque:** [ISO/UPM table for 8 mm and Super 8 (camera vs projection)](https://oa.upm.es/22055/1/PFC_BENJAMIN_ASENSIO_LOPEZ.pdf), [Wikipedia Super 8 film](https://en.wikipedia.org/wiki/Super_8_film), [Wikipedia Standard 8 mm film](https://en.wikipedia.org/wiki/Standard_8_mm_film), [Science Museum Super 8 cartridge 50 ft / 2.5 min](https://collection.sciencemuseumgroup.org.uk/objects/co8231436/spool-of-super8-film-super8-film), [Wikipedia 9.5 mm film](https://en.wikipedia.org/wiki/9.5_mm_film), [NMPFT 9.5 mm](https://www.nmpft.org.uk/files/insight/info/5.3.34.pdf).

---

## 4. Consumo a 24 fps: fórmula y variación por formato

El consumo se calcula con el paso de cuadro, no con el área de imagen:

```text
paso_cuadro_mm = perfs_cuadro * paso_perforacion_mm
ft/min = paso_cuadro_mm * 24 * 60 / 304.8
```

Los valores de la derecha son los canónicos de la industria (redondeados); el cálculo geométrico exacto difiere <0.5 % y se detalla en RIESGOS.

Ejemplos:

- 35 mm 4-perf: 4 × 4.75 = 19.0 mm/cuadro → 90 ft/min.
- 35 mm 3-perf: 3 × 4.75 = 14.25 mm/cuadro → 67.5 ft/min (0.75×).
- 35 mm 2-perf: 2 × 4.75 = 9.5 mm/cuadro → 45 ft/min (0.50×).
- 65 mm 5-perf: 5 × 4.75 = 23.75 mm/cuadro → 112.5 ft/min (1.25×).
- 65 mm 8-perf: 8 × 4.75 = 38.0 mm/cuadro → 179.5 ft/min (2.0×).
- IMAX 15/70: 15 × 4.74 = 71.1 mm/cuadro → 335.9 ft/min (3.73×).
- 16 mm / S16: 1 × 7.62 = 7.62 mm/cuadro → 36 ft/min (0.40×).
- Super 8: 1 × 4.234 = 4.234 mm/cuadro → 20 ft/min (0.22×).
- 8 mm estándar: 1 × 3.810 = 3.810 mm/cuadro → 18 ft/min (0.20×).
- 9.5 mm: 1 × 7.54 = 7.54 mm/cuadro → 35.6 ft/min (0.40×).

**Factores relativos al 35 mm 4-perf:** 3-perf 0.75; 2-perf 0.50; 65 mm 5-perf 1.25; 8/70 1.995; IMAX 3.73; 16 mm/S16 0.40; Super 8 0.222; 8 mm 0.20; 9.5 mm 0.396.

**Cambios por fps:** el consumo es lineal con la frecuencia. A 25 fps +4.17 %; a 30 fps +25 %; a 48 fps +100 %; a 60 fps +150 %. Para una rampa de velocidad hay que integrar el consumo por tramo, no usar el valor de 24 fps.

**Cambios por formato:** sí, cambia. 35 mm 3-perf y 2-perf consumen menos que 4-perf porque el paso de cuadro es menor, no porque el cuadro sea más angosto. 65 mm 5-perf consume 25 % más que 35 mm 4-perf; IMAX consume 3.73×. 16 mm consume 40 % de 35 mm 4-perf. Super 8 consume 22 %.

---

## 5. Círculo de confusión: qué valor usar

El COC es el diámetro máximo de blur que, tras la ampliación y a la distancia de visionado prevista, se percibe como punto. No es una constante física del formato. Valores verificados:

- **35 mm:** 0.0254 mm (0.001 in) en las tablas del ASC; el manual explica que ediciones anteriores usaban 0.002 in y que la práctica moderna pasó a 0.001 in por la mayor ampliación en salas. Las tablas ARRI/ZEISS Master Anamorphic usan 0.030 mm para 35 mm anamórfico.
- **16 mm:** 0.0152 mm (0.0006 in) en las tablas del ASC.
- **Super 16:** 0.0125 mm (0.0005 in) en Cooke/FDTimes; el ASC da 0.0152 mm para 16 mm en general. La diferencia es criterio de blow-up.
- **65 mm / IMAX / 8 mm / 9.5 mm:** no se encontró un valor normativo en las fuentes consultadas. Se adopta `deriv.` = diagonal / 1200, el criterio angular que Cooke describe ("el ojo resuelve 1/1200 de la diagonal"). Los valores son:

| Formato | Diagonal del cuadro (mm) | Diagonal / 1200 (mm) | COC adoptado (mm) |
|---|---:|---:|---:|
| 65 mm 5-perf | 57.30 | 0.0478 | 0.048 |
| 65 mm 8-perf (8/70) | 64.75 | 0.0540 | 0.054 |
| IMAX 15/70 | 87.30 | 0.0727 | 0.073 |
| 35 mm 4-perf full | 31.14 | 0.0259 | 0.0254 (ASC) |
| 35 mm Academy | 27.20 | 0.0227 | 0.0254 (ASC) |
| 35 mm 3-perf | 28.52 | 0.0238 | 0.0254 (ASC) |
| 35 mm 2-perf | 24.00 | 0.0200 | 0.0254 (ASC) |
| Super 16 | 14.55 | 0.0121 | 0.0125 (Cooke) |
| 16 mm | 12.70 | 0.0106 | 0.0152 (ASC) |
| Super 8 | 7.08 | 0.0059 | 0.006 |
| 8 mm estándar | 6.08 | 0.0051 | 0.005 |
| 9.5 mm | 10.70 | 0.0089 | 0.009 |

Recomendación para la app: guardar el COC como **default por formato** y permitir override por proyecto. Para 65 mm e IMAX, marcar el valor como "derivado" en la UI; si el usuario trabaja con lentes de 65 mm reales, conviene calibrar con una prueba de hyperfocal. Para 35 mm, ofrecer 0.0254 y 0.030 como presets (cine estándar vs. ARRI/Zeiss anamórfico).

---

## 6. TABLA PARA DART

Formato de columnas: `formato|ancho_mm|alto_mm|perfs_por_cuadro|pies_por_min|metro_por_min|coc_mm|notas`

```text
65mm 5-perf (5/70)|52.48|23.01|5|112.5|34.29|0.048|camara; paso 4.75; COC derivado diag/1200; 500 ft=4.44 min; 1000 ft=8.89 min
65mm 8-perf (8/70)|52.63|37.72|8|179.53|54.72|0.054|camara; paso 4.75 corto; COC derivado; 1000 ft=5.57 min calc; chasis no verificado
65mm 15-perf IMAX|70.41|51.61|15|335.91|102.38|0.073|camara; paso corto 4.74; COC derivado; 1000 ft=2.98 min
35mm 4-perf full|24.92|18.67|4|90.0|27.43|0.0254|full aperture/Super 35; COC ASC 0.001 in; 400 ft=4.44 min
35mm 4-perf Academy|22.0|16.0|4|90.0|27.43|0.0254|Academy; 21.95 en ASC; COC ASC; 400 ft=4.44 min
35mm 3-perf|24.92|13.87|3|67.5|20.57|0.0254|3 perf; 0.75x consumo 4-perf; 400 ft=5.93 min
35mm 2-perf Techniscope|22.05|9.47|2|45.0|13.72|0.0254|Techniscope; 0.5x consumo 4-perf; 400 ft=8.89 min
Super 16|12.52|7.41|1|36.0|10.97|0.0125|S16; COC Cooke 0.0125; ASC 16mm 0.0152 alternativa; 400 ft=11.11 min
16mm estandar|10.26|7.49|1|36.0|10.97|0.0152|16mm; COC ASC 0.0006 in; 400 ft=11.11 min
Super 8|5.69|4.22|1|20.0|6.10|0.006|camara; COC derivado; cartucho 50 ft=2.5 min
8mm estandar|4.9|3.6|1|18.0|5.49|0.005|Double 8; COC derivado; 25 ft doble 8=2.78 min a 24 fps
9.5mm Pathe|8.5|6.5|1|35.62|10.86|0.009|camara; COC derivado; 30 ft=0.84 min; 60 ft=1.68 min
```

**Advertencia de parseo:** los nombres de formato no contienen `|`. Las notas usan `;` como separador interno. `perfs_por_cuadro` es entero salvo que se agregue un formato con paso fraccionario (el 8 mm estándar tiene 1 perf por cuadro, no 0.5: su paso de cuadro es 3.81 mm).

---

## 7. Fuentes

**Normas y publicaciones técnicas**

- SMPTE ST 59:1998 — *Motion-Picture Film (35-mm) — Camera Aperture Images and Usage*: https://pub.smpte.org/latest/st59/st0059-1998_stable2015.pdf
- SMPTE ST 7:2004 — *Motion-Picture Film (16-mm) — Camera Aperture Image and Usage*: https://pub.smpte.org/doc/st7/20041108-pub/
- SMPTE ST 201:1996 — *Motion-Picture Film (16-mm) — Type W Camera Aperture Image*: https://pub.smpte.org/doc/st201/19960408-pub/
- SMPTE ST 215:1995 — *Motion-Picture Film (65-mm) — Camera Aperture Image*: https://pub.smpte.org/doc/st215/19951201-pub/
- SMPTE ST 152:2003 — *Motion-Picture Film (70-mm) — Projectable Image Area*: https://pub.smpte.org/doc/st152/20031020-pub/
- SMPTE ST 417:2005 — *Motion-Picture Film (65-mm) — Camera Aperture Image and Usage, 15/70 Format*: https://pub.smpte.org/doc/st417/20051018-pub/
- SMPTE ST 419:2005 — *Motion-Picture Film (70-mm) — Projectable Image Area, 15/70 Format*: https://pub.smpte.org/doc/st419/20051018-pub/
- SMPTE ST 418:2005 — *Motion-Picture Film (65-mm) — Camera Aperture Image and Usage, 8/70 Format*: https://pub.smpte.org/doc/st418/20051018-pub/
- SMPTE ST 420:2005 — *Motion-Picture Film (70-mm) — Projectable Image Area, 8/70 Format*: https://pub.smpte.org/pub/st420/st0420-2005_stable2016.pdf
- SMPTE ST 145:2004 — *Motion-Picture Film (65-mm) — Perforated KS* (paso 4.74/4.75): https://pub.smpte.org/doc/st145/20041108-pub/

**Manuales y fabricantes**

- ASC, *American Cinematographer Manual*, 7.ª ed. (1993), texto OCR: https://archive.org/download/asc-1993-american-cinematographer-manual.pdf/ASC%20-%20%5B1993%5D%20-%20American%20Cinematographer%20Manual.pdf_text.pdf
- Kodak, *Cinematographer's Field Guide* H-2 (rev. 2009): http://www.davidelkins.com/download/download_files/kodak/H-2_Cinematographers_Field_Guide_6-09.pdf
- ARRI, ARRIFLEX 765 — datos técnicos: https://www.arrirental.com/en/cameras/analog-film/arriflex-765
- ARRI, ARRIFLEX 765 — página legacy: https://www.arri.com/en/learn/legacy-analog-cameras/arriflex-765
- ARRI/ZEISS, *Master Anamorphic DoF tables* (COC 0.030 mm): http://www.afcinema.com/IMG/pdf/0/b/f/depth-of-field-tables-arri-zeiss-master-anamorphic-lenses-feet.pdf
- Cooke Optics / FDTimes, *Depth of Field in Cinematography: Why Size Matters*: https://cookeoptics.cn/wp-content/uploads/2021/11/Depth-of-Field-Explained-FDTimes-June-2006.pdf
- TSF, ARRIFLEX 435 — magazines 200/400/1000 ft: https://groupe-tsf.com/cameras-optics/arri-arriflex-435/

**Referencias secundarias y de contraste**

- Wikipedia, *70 mm film*: https://en.wikipedia.org/wiki/70_mm_film
- Wikipedia, *IMAX*: https://en.wikipedia.org/wiki/IMAX
- Wikipedia, *35 mm movie film*: https://en.wikipedia.org/wiki/35_mm_movie_film
- Wikipedia, *16 mm film*: https://en.wikipedia.org/wiki/16_mm_film
- Wikipedia, *Super 8 film*: https://en.wikipedia.org/wiki/Super_8_film
- Wikipedia, *Standard 8 mm film*: https://en.wikipedia.org/wiki/Standard_8_mm_film
- Wikipedia, *Techniscope*: https://en.wikipedia.org/wiki/Techniscope
- Wikipedia, *9.5 mm film*: https://en.wikipedia.org/wiki/9.5_mm_film
- Widescreen Museum, *Techniscope*: http://www.widescreenmuseum.com/widescreen/wingts1.htm
- UPM (tabla ISO de 8 mm/Super 8, cámara vs proyección): https://oa.upm.es/22055/1/PFC_BENJAMIN_ASENSIO_LOPEZ.pdf
- Science Museum Group, *Spool of Super 8 film* (50 ft / 2.5 min a 24 fps): https://collection.sciencemuseumgroup.org.uk/objects/co8231436/spool-of-super8-film-super8-film
- NMPFT, *9.5 mm*: https://www.nmpft.org.uk/files/insight/info/5.3.34.pdf
- Smithsonian, *IMAX magazine* (1000 ft / 3 min): https://www.si.edu/object/magazine-displacement-imax:nasm_A20120258006
- CineMath, *Circle of Confusion: Values by Sensor Format* (contraste de valores 65 mm/LF): https://www.cinemath.app/guides/camera/circle-of-confusion

---

## 8. RIESGOS

1. **65 mm 5-perf: 52.48 vs 52.63 mm.** SMPTE ST 215, el ASC (2.066 in) y ARRI (52.5 mm) coinciden en ~52.5 mm. Wikipedia y varias fichas publican 52.63 mm, que es el ancho del 8/70 (SMPTE ST 418). Se adoptó 52.48. Si el catálogo prioriza la ficha de Wikipedia, el ancho cambia 0.15 mm (0.3 %) y la relación 2.28 → 2.29.
2. **IMAX: 51.61 vs 52.63 mm de alto.** SMPTE ST 417 dice 51.61; Wikipedia dice 52.63. La proyección ST 419 es 69.60 × 48.56, no 69.6 × 48.5. Se adoptó ST 417. La diferencia de alto cambia la relación de 1.364 a 1.338; el COC derivado queda en 0.073 con ambos valores (0.0728 vs. 0.0732).
3. **Academy: 22.0 vs 21.95 mm.** SMPTE ST 59 define 22.0 × 16.0; el ASC usa 21.95 × 16.0. La diferencia es 0.05 mm; la relación nominal sigue siendo 1.375, pero el cociente con 21.95 es 1.372. Se adoptó 22.0 por ser la norma.
4. **Full aperture: 24.92 vs 24.89 mm.** SMPTE ST 59 0.981 in vs ASC 0.980 in. Diferencia 0.03 mm. Se adoptó 24.92.
5. **16 mm / S16: apertura vs área de imagen.** SMPTE ST 7 da 10.26 × 7.49 de apertura, pero ISO 466 da 10.05 × 7.42 de imagen. SMPTE 201M-1996 da 12.35 × 7.42 de imagen Type W, mientras la ficha SMPTE 201M-1988 recogida por la literatura da 12.52 × 7.41 de apertura. Se usó apertura para FOV; si la app calcula sobre el área escaneada, conviene usar 10.05 × 7.42 y 12.35 × 7.42.
6. **Super 8: 5.69 × 4.22 vs 5.46 × 4.01 vs 5.79 × 4.01.** Se usó la apertura de cámara ISO/ANSI 5.69 × 4.22; el área proyectable es 5.46 × 4.01. Algunas fichas citan 5.79 × 4.01 (posible apertura física o medida con línea de cuadro). La relación cambia de 1.35 a 1.44.
7. **9.5 mm: paso 7.54 vs 7.56 mm; 135.1 vs 132.6 frames/m.** Wikipedia cita 7.54 mm (manual Pathé Baby) y 135.1 frames/m; 135.1 frames/m implica 7.402 mm, incoherente con 7.54. Se usó 7.54 y 10.86 m/min. Si el paso real fuera 7.56, el consumo sería 10.89 m/min; si fuera 7.402, 10.66 m/min. Diferencia <2 %.
8. **COC de 65 mm, 8/70, IMAX, S8, 8 mm y 9.5 mm derivados.** No hay valor ASC/Cooke/SMPTE publicado para estos formatos en las fuentes consultadas. Los valores 0.048 / 0.054 / 0.073 / 0.006 / 0.005 / 0.009 salen de diagonal/1200 y están marcados. No son norma. Para 35 mm la práctica admite 0.0254-0.030; para 16 mm 0.0125-0.0152.
9. **Consumo: diferencias de redondeo.** 65 mm 5-perf 112.5 (ASC, 1 ft = 12.8 frames) vs 112.2 (5 × 4.75). 35 mm 4-perf 90 vs 89.76 (4 × 4.75). 3-perf 67.5 vs 67.32. IMAX 335.91 (15 × 4.74) vs 336.6 (15 × 4.75). 8/70 179.53 (8 × 4.75) vs 179.15 (8 × 4.74). Son diferencias <0.5 %; se usaron los valores canónicos de la industria cuando existían (90 / 112.5 / 36 / 20 / 18) y cálculo geométrico para 8/70, IMAX, 3-perf y 2-perf.
10. **8/70: capacidad de chasis no verificada.** Se asumió 1000 ft para la duración de 5.57 min. El formato se usó en cámaras especiales (HydroFlex Iwerks 870) y no hay una ficha de magazine estándar como la del 765. Si el chasis es de 500 ft, la duración es 2.79 min.
11. **2-perf Techniscope: 22.05 vs 22.0 mm; 2.33 vs 2.35.** La apertura de 0.868 × 0.373 in da 22.05 × 9.47 y 2.33:1. La copia se proyecta a 2.35:1 (2.39 desde 1970). Algunas fuentes redondean el ancho a 22.0. No cambia el consumo (2 perfs).
12. **9.5 mm a 24 fps.** 24 fps es la velocidad de las copias sonoras; el formato silent se rodaba/proyectaba a 16 fps. Las duraciones de 0.84/1.68 min son a 24 fps; a 16 fps son 1.26/2.53 min. Aclarar en la UI.
13. **Duraciones sin leader ni rampas.** Todas las duraciones son rollo/consumo a 24.000 fps constantes. En cámara real hay leader, colas, rampas y pérdidas de carga; para una app de producción conviene descontar 5-10 % o pedir al asistente el metraje útil.
14. **Nomenclatura 65/70.** El negativo es de 65 mm; la copia es de 70 mm (5/70, 8/70, 15/70). En la app conviene llamar "65 mm 5-perf" al formato de cámara y aclarar "copia 70 mm" en la ficha.

---

**Fin del documento.** Los valores marcados `deriv.` o `calc.` no deben tratarse como norma; las fuentes primarias están en §7.
