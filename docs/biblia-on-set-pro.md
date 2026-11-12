# ON SET PRO — Biblia de producto

### Versión 0 · borrador para corregir · 12 de noviembre de 2026

> Este documento es la fuente de verdad del proyecto: si algo no está escrito acá, no existe.
> Cada módulo dice qué es, qué entra, qué sale y en qué estado está.
>
> **Estados:** `HOY` = funciona en la app actual · `PARCIAL` = existe pero incompleto ·
> `BIBLIA` = estaba en el documento original, no está en la app · `A DEFINIR` = todavía no decidimos.

---

## ESTADO TÉCNICO HOY

Verificado el 13/11/2026: el proyecto compila sin errores ni avisos (`flutter analyze` limpio)
y tiene **80 pruebas automáticas en verde**. El código está bajo git: cualquier cambio se puede
revertir. Pendiente de instalación para compilar en teléfono: CocoaPods (iPhone) y SDK de Android.

**Núcleo de cálculo (Fase 1, terminada).** Las fórmulas no viven en las pantallas: están en
`lib/domain/`, en Dart puro y con tests. Las siete pantallas ya usan ese núcleo y los catálogos
verificados (cámaras, formatos fílmicos, filtros, gelatinas, códecs y cables).

| Motor | Qué resuelve | Pruebas |
|---|---|---|
| `exposure` | Zonas, fall-off, lux⇄f, compensación con ISO/obturador/filtros, ND | 26 |
| `optics` | Hiperfocal, DoF exacto, FOV, encuadre a distancia, equivalencia de lentes | 12 |
| `flicker` | Ventanas de obturador seguras por Hz y fps | 6 |
| `color` | Mireds + asesor de gelatinas Lee/Rosco | 7 |
| `power` | Ohm, caída de tensión, ampacidad con derating, generadores | 14 |
| `storage` | Códecs (77 tasas), duración y copia DIT | 11 |

**Pantallas reconectadas:** Exposición, Óptica, Eléctrico, Storage, Color y Flicker.
Cada una tiene su documento de revisión en `docs/revision-*.md`.

Catálogos: gelatinas (31), cables H07RN-F y SOOW, códecs (77 tasas), **cámaras (25 modelos,
82 modos de grabación** con su área de imagen real) y **formatos fílmicos (12)**. Cada dato
tiene su fuente en `docs/research/`, y lo que no se pudo verificar queda marcado como tal en
vez de inventarse.

---

## 1. QUÉ ES

On Set Pro es una herramienta de toma de decisiones para el set. No es una calculadora suelta:
es el lugar donde el director de fotografía resuelve la luz y la óptica **antes de encender la cámara**.

En una frase: **el departamento de cámara y el eléctrico, en el bolsillo, siempre a un toque.**

Texto de la versión comercial (v5.2):

> "Como directores de fotografía, entendemos que cada segundo en el set es sagrado y que la
> técnica debe ser tan sólida que se vuelva invisible. Nuestra visión es liberar el ojo del DF.
> Por eso, hemos traducido la matemática fría en visualizadores dinámicos e intuitivos que
> permiten pre-visualizar el comportamiento de la luz y la óptica antes de encender la cámara."

## 2. PARA QUIÉN

- Director de fotografía, operador, gaffer, eléctrico, DIT, 1er asistente de cámara.
- Se usa **de pie, con una mano, con guantes, en un set oscuro y sin señal**.
- Debe funcionar sin internet.

## 3. LA FILOSOFÍA

1. **La técnica tiene que ser invisible.** Si la app pide pensar en la app, ya falló.
2. **Precisión antes que cantidad.** Un número mal calculado destruye la confianza en toda la herramienta.
3. **Visualizar antes que leer.** La luz y la óptica se entienden mejor con una gráfica que con un número.
4. **El set no espera.** Todo lo importante, a un toque. Nada de buscar dentro de menús.

## 4. PRINCIPIOS DE DISEÑO (fijados por vos en el trabajo con Gemini)

1. **No se pierde ninguna función.** Se sintetiza, se reordena, pero nunca se borra una herramienta
   que ya existía. Si una versión nueva elimina algo, es un error, no una mejora.
2. **Todo a un toque.** Sin barras de búsqueda, sin menús escondidos. El parámetro tiene que estar a la vista.
3. **Listado limpio y vertical**, no formularios con desplegables por todos lados ("parecen un formulario de banco").
4. **El resultado explica el porqué**: no solo "faltan 2 stops", también de dónde salen esos 2 stops.
5. **Oscuro de verdad**, para no deslumbrar en set.
6. **La app no miente**: cada cuenta verificada contra referencias antes de darla por buena.

## 5. IDENTIDAD VISUAL

**Lo que hay hoy en la app:** fondo `#121212`, tarjetas `#1E1E1E`, acento dorado `#FFD700`,
números grandes y finos (48–54 px), etiquetas chicas en mayúscula con letter-spacing,
esquinas rectas en las tarjetas del menú. Referencia estética declarada: **Kaan Cine**.

**Lo que decía la biblia original (GDD v3.0):** fondo `#0D0D0D`, acento naranja,
grid de tarjetas con **color por departamento**.

**DECIDIDO (12/11/2026):** se usan los dos sistemas a la vez, cada uno con su función.

- El **dorado** (`#FFD700`) es la marca: acción principal, botón de ingreso, pestaña activa,
  resultado, zona destino.
- El **color de departamento** identifica a qué área pertenece cada herramienta: barra lateral
  e ícono de cada tarjeta del menú.

| Departamento | Color | Módulos |
|---|---|---|
| Cámara / Óptica | Azul `#4E9AF1` | Profundidad de campo · Óptica / FOV |
| Imagen / Exposición | Rojo `#E57373` | Sistema de zonas / Expo · Flicker |
| Electricidad / Iluminación | Ámbar `#FFB300` | Electricidad y energía · Color y geles |
| Data / Producción | Verde `#66BB6A` | Data y almacenamiento / Chasis y metraje |
| Utilidades | Naranja `#FF8A50` | (calculadora, claqueta, charts, linterna) |

> Los colores viven en `lib/theme/app_theme.dart` (`OnSetColors`). Ninguna pantalla nueva
> debe escribir un hex a mano: se usa el token.

## 6. MAPA DE LA APP

```
Inicio (elegir fílmico o digital + formato)
   └── Menú principal
         ├── Profundidad de campo
         ├── Sistema de zonas / Exposición  (4 sub-pantallas)
         ├── Electricidad y energía
         ├── Data y almacenamiento  (digital) / Chasis y metraje (fílmico)
         ├── Flicker y parpadeo
         ├── Color y geles (mireds)
         └── Óptica / FOV (lens matcher)
```

---

## 7. LOS MÓDULOS

### 7.1 Inicio · Setup de cámara — `HOY`

- Elegir **Fílmico** o **Digital**, después el formato. Eso define el **CoC** que usa todo el resto de la app.
- Idiomas: español, inglés, portugués.
- **Se recuerda entre sesiones:** la próxima vez que se abre la app entra directo al menú con
  la cámara elegida. Para cambiarla, el ícono de cámara arriba a la derecha del menú.

CoC por formato (mm):

| Digital | CoC | Fílmico | CoC |
|---|---|---|---|
| Medio formato (GFX) | 0.050 | 65mm 5-perf | 0.050 |
| Full Frame / VV | 0.030 | 35mm (4, 3 y 2 perf) | 0.025 |
| Super 35 | 0.025 | 16mm (S16 y std) | 0.013 |
| APS-C (Sony/Fuji) | 0.020 | 9.5mm | 0.010 |
| APS-C (Canon) | 0.019 | Super 8 | 0.006 |
| Micro 4/3 | 0.015 | Std 8mm | 0.005 |
| 1" / 1/1.7" / 1/2.3" / 1/3" | 0.011 / 0.007 / 0.006 / 0.005 | | |

> `A DEFINIR` — Fílmico: 35mm 2-perf y 3-perf hoy comparten el CoC de 4-perf. Técnicamente
> el 2-perf tiene otro alto de cuadro. Revisar con tabla de referencia.

### 7.2 Profundidad de campo — `HOY`

- Entra: focal (mm), diafragma, distancia al sujeto.
- Sale: hiperfocal, límite cercano, límite lejano, y una **gráfica de la zona nítida**.
- Fórmulas: `H = f²/(N·c) + f` · `Dn = s(H−f)/(H+s−2f)` · `Df = s(H−f)/(H−s)`
- Muestra siempre el CoC usado al pie (ej. "CoC: 0.030 mm").

### 7.3 Exposición — 4 pantallas — `HOY` / `PARCIAL`

**a) Mapa de Zonas** (`HOY`). Entra: f/ de cámara + lectura del fotómetro. La app ubica la escena
en la escala de 11 zonas de Ansel Adams (0–10, zona V = gris medio 18%), marcás la zona destino
y devuelve los stops a abrir o cerrar.
`zona = 5 + 2·log₂(F_fotómetro / F_cámara)`

**b) Fall-off / Ley inversa del cuadrado** (`HOY`). Entra: distancia de referencia y distancia nueva.
Sale: stops de pérdida o ganancia + gráfica con el sujeto y la fuente a escala.
`stops = 2·log₂(d₁/d₂)`

**c) Compensar** (`PARCIAL`). Entra: diafragma deseado, lectura del fotómetro, ISO, FPS,
obturador (hoy solo en ángulos), ND y gelatina. Sale: los stops totales a corregir.
Suma los stops de cada variable contra la base 24 fps · 180° · ISO 800.
**Falta:** el modo de obturador en velocidad 1/x (existía y se perdió en el camino).

**d) Fotometría Lux ⇄ f-stop** (`HOY`). Conversión bidireccional con botón para invertir.
`f = √(lux · ISO / (250 · 48))` — constante C=250 (plano incidente), t=1/48 s.

> `A DEFINIR` — 1) El lux⇄f usa 1/48 s fijo en lugar del obturador real: ¿lo dejamos como
> referencia rápida o lo conectamos al setup? 2) Recuperar el modo 1/x en Compensar.
> 3) "Anclas" y "Recetario" (fijar variables y ver las alternativas para ganar 2 stops) quedaron
> charlados con Gemini pero no construidos.

### 7.4 Electricidad y energía — `HOY`

- Fuentes: acometida (tie-in), generador o batería.
- Voltajes: 12V, 14.4V, 24V, 110V, 220V, 240V.
- Entra: potencia de las luminarias, sección del cable, altitud.
- Sale: amperaje demandado, carga del cable, margen térmico, **semáforo de riesgo**, y
  **caída de tensión** en el tramo.
- Factores: tabla de cable (1.0 a 10 mm², amperaje térmico y ohms/km) y
  **derating por altitud** (≈10% menos por cada 1000 m, con piso en 0.4).
- `A = W / V` · `W = A · V`

### 7.5 Data y almacenamiento / Chasis y metraje — `HOY`

- **Digital:** capacidad (GB) ⇄ tiempo de grabación por códec y resolución; tiempo de copia DIT
  según velocidad de disco. Hoy tiene bitrates de ProRes.
- **Fílmico:** metros o pies de chasis ⇄ tiempo de rollo, con consumo por formato
  (16mm 36 ft/min, 35mm 4-perf 90 ft/min, 65mm 112.5 ft/min a 24 fps).
- `BIBLIA` — agregar los códecs que faltan: ARRIRAW, Sony X-OCN, REDCODE, Blackmagic RAW, H.265.

### 7.6 Flicker y parpadeo — `HOY`

- Entra: frecuencia de red (50/60 Hz) y FPS.
- Sale: las **ventanas de obturador seguras** (ángulo y 1/x) para no captar parpadeo,
  con la más cercana a 180° recomendada.
- `exposición = n / (2·Hz)` · `ángulo = exposición · fps · 360`

### 7.7 Color y geles (mireds) — `HOY`

- Entra: temperatura de la fuente y temperatura objetivo, más el tinte.
- Sale: el **corrimiento en mireds** y la **gelatina recomendada** (CTO/CTB en fracciones, verde,
  difusión), con el criterio de que mireds es la unidad correcta para mezclar color.
- `mired = 1.000.000 / K` · `shift = mired_objetivo − mired_fuente`

### 7.8 Óptica / FOV — `HOY`

- Entra: focal, distancia al sujeto, sensor de la cámara A y sensor de la cámara B.
- Sale: campo de visión en grados, ancho y alto del encuadre a esa distancia, y **equivalencia
  entre sensores** (lens matching A/B, incluido drone).
- `FOV = 2·arctan(ancho_sensor / (2·f))` · `ancho_encuadre = 2·d·tan(FOV/2)`

---

## 8. LO QUE LA BIBLIA PEDÍA Y HOY NO ESTÁ — `BIBLIA`

Estas cinco herramientas estaban en el GDD v3.0 y nunca se construyeron. Todas viven en
"Utilidades" y ninguna necesita internet:

1. **Calculadora Pro** — científica, con función inversa `1/x` para Hz/segundos.
2. **Claqueta (Slate) 2.0** — pantalla completa horizontal, proyecto/director/rollo/escena/toma,
   persistente entre sesiones, toque en pantalla = flash + sube la toma.
3. **Charts** — estrella de Siemens (foco), barras SMPTE, escala de grises.
4. **Linterna** — pantalla blanca regulable para revisar guion o luz de ojos.
5. **Menú por departamentos con código de color** (ver §5).

## 9. DECISIONES PENDIENTES

1. ~~Identidad visual: ¿dorado único o colores por departamento?~~ **Cerrada el 12/11/2026
   (ver §5): dorado de marca + color por departamento.**
2. ¿La app se publica y se cobra? Si sí: ¿pago único, suscripción o gratis con premium?
3. ~~¿La cámara elegida se recuerda entre sesiones?~~ **Cerrada: sí, ya funciona (§7.1).**
4. ¿"Anclas" y "Recetario" entran en la próxima versión de Exposición?
5. ¿Los módulos de Utilidades (claqueta, calculadora, charts, linterna) entran antes o después de la publicación?

## 10. PRÓXIMOS PASOS

- ~~Fase 0 — rescate y orden~~ **hecha el 12/11/2026**: backup, git, biblia, código muerto
  eliminado, cámara persistente, colores por departamento, analizador en cero y las primeras
  pruebas automáticas.
- **Fase 1 (siguiente)** — núcleo confiable: fórmulas afuera de las pantallas, con tests contra
  valores de referencia; tema y componentes compartidos; revisar el CoC de 35mm 2-perf/3-perf.
- Fase 2 — Exposición v2 completa, sin perder el modo 1/x, con Anclas y Recetario.
- Fase 3 — Utilidades faltantes.
- Fase 4 — Versión web para escritorio, íconos, publicación.

## 11. HISTORIAL DE DOCUMENTOS

| Documento | Fecha | Qué es |
|---|---|---|
| `ON SET INSTRUCCIONES.rtf` / `.pdf` | feb 2026 | GDD v3.0 — documento de diseño técnico, 8 bloques |
| `OnSetPro.pdf` (v5.2) | 24 feb 2026 | One-sheet técnico y comercial + fórmulas + bibliografía |
| Conversación con Gemini (58 pág.) | hasta nov 2026 | Desarrollo del código, pantalla por pantalla |
| Este documento (v0) | 12 nov 2026 | Consolidación: qué existe hoy y qué falta |
| Biblia v1 | 12 nov 2026 | Fase 0 cerrada: decisión de color, persistencia, limpieza técnica |
