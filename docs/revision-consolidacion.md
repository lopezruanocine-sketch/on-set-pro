# Consolidación de herramientas

Fecha: 13/11/2026 · Decisión: **una herramienta por pregunta, completa.**

Se revisaron las 14 herramientas del menú buscando tres cosas: la misma cuenta en
dos lugares, dos pantallas que responden la misma pregunta, y código que ya nadie usa.

---

## Redundancia real: ND RÁPIDO y Compensar

Eran la misma cuenta. Verificado con el motor:

| Pregunta | ND RÁPIDO | Compensar |
|---|---|---|
| Luz en f/5.6, quiero f/2.8 | ND 0.6 | −2.0 stops → recetario: ND 0.6 |

ND RÁPIDO era Compensar con dos campos menos y un número más grande.

**Decisión:** se eliminó la pantalla. Compensar ahora muestra el filtro sugerido en
grande debajo del resultado ("O PONÉ ND 0.6"), así la respuesta rápida sigue estando
a un toque, sin una herramienta que mantenga la misma fórmula dos veces.

## Dos pantallas para una misma área: Eléctrico y Distro

No eran redundantes —una responde "¿aguanta este circuito?" y la otra "¿cómo reparto
cinco luminarias entre fases?"— pero vivían separadas.

**Decisión:** ahora son las dos pestañas de **ELÉCTRICO**: `CIRCUITO` y `FASES`.
Una sola puerta de entrada para todo lo eléctrico.

## Herramientas que se revisaron y se mantienen

| Herramienta | ¿Se repite? | Veredicto |
|---|---|---|
| Visor de cámara | Muestra el encuadre; Óptica lo calcula | **Se mantienen**: una es visual, la otra numérica y con lens matcher A/B |
| Óptica / FOV | Ver arriba | Se mantiene |
| Profundidad de campo | Única | Se mantiene |
| Zonas / Expo | Comparte la lectura del fotómetro con Compensar | **Se mantiene**: zonas decide dónde cae el tono; compensar ejecuta el cambio |
| Flicker | Única (obturadores seguros) | Se mantiene |
| Color y geles | Comparte el catálogo de gelatinas con Compensar | **Se mantiene**: color corrige temperatura, compensar cuenta pasos |
| Luz solar | Única | Se mantiene |
| Data / Chasis | Un solo módulo con dos modos | Se mantiene |
| Planos y notas | Única | Se mantiene |
| Calculadora | Única (fracciones e inversas) | Se mantiene |
| Linterna | Única | Se mantiene |

## Código muerto eliminado

- `lib/data/camera_formats.dart`: tabla de formatos anterior al catálogo de sensores.
  Nadie la importaba.
- `lib/presentation/distro_screen.dart` y `nd_quick_screen.dart`: absorbidos.

## Resultado

El menú pasa de **14 herramientas a 11**, sin perder ninguna función: dos se
consolidaron y una se retiró por duplicar una cuenta que ya existía.

## Lo que queda para revisar más adelante

- **Dos selectores de gelatina** (Compensar y Color) comparten catálogo pero no
  interfaz. No duplican cálculo, pero conviene unificarlos cuando se haga el diseño.
- **Visor y Óptica** podrían compartir el bloque de focal y sensor.
