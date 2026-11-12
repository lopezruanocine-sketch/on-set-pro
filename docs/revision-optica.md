# Revisión — Departamento de Óptica

Fecha: 13/11/2026 · Estado: **implementado y verificado**.

Dos herramientas: Profundidad de campo (DoF) y Óptica / FOV (lens matcher).

---

## 1. Profundidad de campo

**Qué hacía:** fórmula propia dentro de la pantalla, con la forma aproximada que no devuelve
infinito al enfocar en la hiperfocal. Además trataba como "infinito" cualquier límite lejano
mayor a 500 m.

**Qué hace ahora:**

- Usa `OpticsEngine.depthOfField` (fórmulas exactas `Dn = s(H−f)/(H+s−2f)`,
  `Df = s(H−f)/(H−s)`): enfocar en la hiperfocal deja el fondo en infinito y el frente en H/2.
- Toma el sensor y el CoC del modo elegido en el catálogo (ALEXA 35 4.6K = 0.0226 mm),
  y muestra el área del sensor y la regla usada (diagonal/1500).
- Apertura con la escala real de tercios de paso (f/1.0 a f/32) en lugar de un slider 0.95–32.
- Agrega **profundidad total**, **delante del sujeto** y **detrás del sujeto**: lo que se
  consulta en set para saber si el actor puede moverse.
- Metros o pies.
- El gráfico escala sobre la zona nítida (no sobre la hiperfocal), así el sujeto no queda
  pegado al borde; si la hiperfocal se va de escala, se indica con una flecha.

## 2. Óptica / FOV

**Qué hacía:** tenía cuatro sensores escritos a mano ("Full Frame (36x24)", "Súper 35", "APS-C",
"Micro 4/3") que no coincidían con el catálogo, y el "factor de recorte" se mostraba invertido.

**Qué hace ahora:**

- La cámara A sale del plano (la que elegiste al abrir la app), con su modo real.
- La cámara B se elige del catálogo completo (25 cámaras, 82 modos).
- Calcula campo de visión horizontal, vertical y diagonal, tamaño del encuadre a la distancia,
  focal equivalente en B y crop real de B respecto de A.
- Arranca con una B-cam de sensor distinto (comparar dos iguales no aporta nada).
- Ejemplo verificado: ALEXA 35 4.6K con 50 mm a 5 m da 2.80 × 1.92 m y 31.3° horizontales;
  contra una Mini LF el equivalente es 65.8 mm (crop 1.32×).

---

## Pendientes de decisión

- ¿Querés que el DoF muestre también la **zona de nitidez en pies** por defecto en set
  (equipo americano) o mantenemos metros?
- ¿Agregamos **anamórfico** (squeeze 2×) al FOV, que cambia el encuadre desplegado?
- ¿El lens matcher debería sugerir **la lente más cercana del set** si le cargamos un set de
  ópticas (por ejemplo 25/32/40/50/65/75)?
