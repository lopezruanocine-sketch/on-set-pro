# On Set Pro — diagnóstico inicial

Fecha: 12/11/2026 · Proyecto: `/Users/joselopezruano/Documents/Desarrollo/on_set_pro`

## Estado verificado

- Flutter 3.41.2 (canal stable) sobre macOS 26.6.2, Xcode 26.6, Chrome OK.
- **El proyecto compila**: `flutter analyze` → 0 errores, 5 avisos menores (4 son `withOpacity` deprecado).
- Build web de producción funcionando (`flutter build web`).
- 19 archivos Dart, 4.529 líneas. Sin git, sin tests, sin dependencias externas.

## Inventario actual (lo que hay)

| Módulo | Archivo | Líneas | Estado |
|---|---|---|---|
| Inicio / setup de cámara | `presentation/camera_setup_screen.dart` | 182 | Funciona. Formatos fílmicos y digitales, 3 idiomas (ES/EN/PT) |
| Menú principal | `presentation/dashboard_screen.dart` | 253 | Funciona. 7 tarjetas |
| Profundidad de campo | `presentation/dof_calculator_screen.dart` | 264 | Funciona (usa `domain/optical_engine.dart`) |
| Exposición (4 pestañas) | `presentation/exposure_screen.dart` | 701 | Funciona. Zonas, fall-off, compensar, lux⇄f |
| Electricidad y energía | `presentation/electricity_screen.dart` | 631 | Funciona. Incluye caída de tensión |
| Data y almacenamiento | `presentation/storage_screen.dart` | 462 | Funciona. Digital y fílmico |
| Flicker y parpadeo | `presentation/flicker_screen.dart` | 389 | Funciona |
| Color y geles (mireds) | `presentation/color_screen.dart` | 400 | Funciona |
| Óptica / FOV | `presentation/optics_screen.dart` | 496 | Funciona. Con dibujo de campo de visión |
| *(código muerto)* | `presentation/voltage_drop_screen.dart` | 314 | Nunca se abre desde la app |
| *(código muerto)* | `presentation/optical_screen.dart` | 74 | Nunca se abre desde la app |

## Hallazgos técnicos

1. **Fórmulas dentro de la interfaz.** Todo cálculo vive dentro de `build()` de cada pantalla. No se pueden probar sin abrir la app. Ejemplo: `exposure_screen.dart` líneas 310–325.
2. **Archivos-monstruo.** Un archivo contiene 4 pantallas completas + widgets privados (`exposure_screen.dart`).
3. **Widgets duplicados con variantes.** `_buildDropdown`, `_buildManualInput` y `_buildResultCard` están copiados en varias clases con diferencias sutiles.
4. **388 líneas de código muerto** que parecen funcionalidad y no se ejecutan.
5. **Sin persistencia.** El formato de cámara elegido se pierde cada vez que se cierra la app (no hay `shared_preferences` ni archivo de ajustes).
6. **Sin control de versiones.** No hay git: no existe forma de volver atrás ni de comparar versiones (de ahí las versiones sueltas en RTF: v3, v4, 4.5…).
7. **Estilos repetidos a mano.** Los colores hex (`0xFF121212`, `0xFFFFD700`, etc.) y tamaños de letra se repiten en cada archivo; no hay tema ni sistema de diseño.
8. **Idiomas con variable global.** `String lang = 'es'` global + `t('clave')`; funciona pero es frágil y no traduce todo (hay textos en español fijos dentro de las pantallas).
9. **`CineData` incompleto conceptualmente.** ISO base fijo en 800 para todo; no hay modelo de cámara real (ISO base, obturador máximo, formatos disponibles por cámara).

## Fórmulas encontradas (a auditar con tests)

- Zonas: `stopsDiff = 2·log2(F_fotómetro / F_cámara)` · `zonaActual = 5 + stopsDiff` · `corrección = zonaDestino − zonaActual`
- Fall-off: `stops = 2·log2(d1/d2)` · `intensidad = (d1/d2)²`
- Compensación: suma de stops por FPS (`log2(fps/24)`), obturador (`log2(ángulo/180)`), ISO (`log2(ISO/800)`), ND y gelatinas; resultado = stops a abrir/cerrar.
- Lux ⇄ f: `f = √(lux·ISO / (250·48))` (C=250, t=1/48 s) y su inversa.
- Ángulo ↔ velocidad: `ángulo = fps · 360 / (1/x)`.

## Problemas heredados del flujo anterior (evidencia en el chat exportado)

- Funcionalidades eliminadas en silencio al "simplificar" y readmitidas después ("Frankenstein", pág. 34 del PDF).
- Reescrituras completas del archivo en cada iteración → regresiones invisibles.
- Código de compilación nunca verificado: se declaraba "intacto" sin ejecutar.
- Un "arreglo" de error de compilación que dejó el comentario del arreglo pero no el arreglo (pág. 52).
- Versión actual en disco con pérdidas respecto de versiones anteriores: en Compensar desapareció el modo velocidad `1/x` (solo quedó el modo ángulo).

## Riesgos si se sigue así

- La app puede mostrar resultados equivocados sin que nadie lo note (es una calculadora: un error de un stop es grave).
- Cada cambio nuevo vuelve a romper algo anterior.
- Sin git, un error de la IA puede borrar trabajo de semanas.

## Propuesta de orden de trabajo

0. Rescate: backup + git + spec viva + limpieza de código muerto.
1. Núcleo confiable: dominio puro + tests + persistencia de setup + tema/componentes compartidos.
2. Exposición v2 (Anclas + Recetario) sin perder funciones.
3. Resto de módulos + layout web/tablet.
4. Publicación: iconos, onboarding, builds, tiendas.
