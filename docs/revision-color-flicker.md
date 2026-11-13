# Revisión — Color y Flicker

Fecha: 13/11/2026 · Estado: **implementado y verificado**.

---

## Color y geles

**Lo que estaba mal**

1. **Tenía su propia tabla de gelatinas, y estaba mal.** Por ejemplo, daba el 1/2 CTO en
   81 mireds (Lee 205 son 109), el 1/4 CTO en 42 (son 64) y el 1/8 CTB en −12 (son −18). Con
   esos valores el gel recomendado podía quedar a media corrección.
2. **Sólo ofrecía ocho gelatinas** escritas a mano, sin marca ni código: no coincidía con lo
   que hay en el camión.
3. **El tinte no tenía corrección real**: elegía un nombre de una tabla fija, sin pérdida en
   pasos ni relación con el catálogo.
4. **No mostraba el error** de la corrección ni la temperatura resultante.

**Lo que hace ahora**

- Usa el catálogo verificado de **31 gelatinas Lee y Rosco** con mired y pérdida en pasos.
- **Asesor de gelatinas**: elige la de menor error, muestra en qué Kelvin queda, el error en
  mireds y lo que pierde en exposición.
- **Otras opciones** ordenadas por error, para cuando no está la ideal en el camión.
- **Presets de fuente** (tungsteno 3200, diurno 5600, HMI 6000, LED 6500) y objetivo con
  slider de 2000 a 10000 K.
- **Tinte** (muy verde → muy magenta) con la gelatina concreta: Lee 247 Minus Green, 249, 246,
  244, cada una con su pérdida.

## Flicker

**Lo que estaba mal**

1. El cálculo era correcto, pero **la pantalla no sabía cuál era tu obturador**: mostraba las
   ventanas seguras sin decir si el plano actual parpadeaba.
2. No se podía **aplicar** la ventana recomendada al plano: había que memorizar el número.

**Lo que hace ahora**

- Lee el fps y el obturador del **estado del plano** y avisa en grande: **SIN PARPADEO** o
  **PARPADEA**, con el motivo.
- Muestra la ventana recomendada y marca la IDEAL de la lista.
- **Tocar una ventana la aplica al plano**, y ese obturador viaja a Exposición y a Fotometría.
- Frecuencia de red 50/60 Hz y lectura en ángulo o en 1/x.

## Los filtros de cámara entran en Color (13/11/2026)

Un 85 o un 80A no sólo cuestan pasos: mueven el color de la imagen. El módulo de Color ahora
los tiene en cuenta:

- Muestra el corrimiento **a corregir**, que es la diferencia entre fuente y objetivo **menos**
  lo que ya aportan los filtros de cámara.
- Debajo del número grande aclara el desglose: "fuente → cámara: −134 mireds · filtros de
  cámara: +112".
- La gelatina recomendada se calcula sobre ese corrimiento neto.
- Si ninguna gelatina alcanza (por ejemplo un 85 con la cámara balanceada en diurno), avisa:
  "los filtros de cámara aportan +112 mireds; revisá si ese filtro corresponde al objetivo".

## Verificado

- 3200 K contra 5600 K: −133 mireds → Rosco 3202 Full CTB (queda en 5510 K, error 3 mireds,
  pierde 1,47 stops).
- A 50 Hz y 24 fps, el 180° parpadea; la ventana ideal es 172,8° (1/50).
- A 50 Hz y 25 fps, el 180° ya es seguro.
