# Departamento eléctrico — datos verificados para el motor de On Set Pro

**Versión:** 1.0 · 12/11/2026
**Alcance:** cables de set, caída de tensión, derating por temperatura y altitud, generadores, conexiones y márgenes de carga.
**Convención numérica:** punto decimal (`7.98`), sin separador de miles dentro de las tablas.
**Regla de la casa:** todo dato sin fuente verificable va marcado `NO VERIFICADO`. El motor **no** debe usar un `NO VERIFICADO` para emitir un semáforo verde.

---

## 0. Lo que cambia respecto de la app actual (leer primero)

1. **El derating por altitud que hoy usa la app (≈10 % por cada 1000 m, con piso 0.4) no corresponde a ninguna norma.** Para cables, ni IEC 60364-5-52 ni NEC tienen factor de altitud; la pérdida real a 3000 m es ≤8 %. Para generadores la regla correcta es distinta y depende de dos componentes separados (motor y alternador). El piso 0.4 es el punto más peligroso: a partir de ~6000 m deja de deratear y **sobreestima** la capacidad.
2. **La ampacidad depende del tipo de cable, no solo de la sección.** 2.5 mm² en H07RN-F (servicio móvil) admite 25 A; 14 AWG en SOOW admite 15 A con 3 conductores cargados. Es la misma sección física con 40 % menos capacidad. El motor tiene que preguntar el tipo de cable.
3. **Los 400 A de un cam-lock no son 400 A de cable.** 4/0 AWG tiene ~230 A de ampacidad (NEC 310.16, 75 °C). Que en un set se cuelguen 400 A de un 4/0 se debe a la excepción del **NEC 530.18(A)** (protección hasta el 400 % de la ampacidad para *stage cables*), que aplica a estudios/etapas, no a cualquier locación.
4. **El factor de potencia de una HMI electrónica es 0.98, no 0.8.** Un generador de 100 kVA está nominalmente limitado a 80 kW (FP 0.8 trifásico), así que alimenta ~80 kW de HMI, no 100 kW. Con cargas resistivas el límite es el motor, no el alternador.
5. **El 80 % de la térmica es una regla de carga continua** (NEC 210.20(A)), no un número universal: con térmicas *100 % rated* y con las excepciones del Art. 530 cambia. La app debe decir *por qué* aplica el 80 %.

---

## 1. Cables de set

### 1.1 Qué es cada cable

| Designación | Tensión | Aislamiento / temperatura | Norma de producto | Dónde se usa |
|---|---|---|---|---|
| **H07RN-F** | 0.6/1 kV | EPR, 90 °C en el conductor | EN 50525-2-21 (antes UNE 21150 / HD 22.4) | Europa, Argentina, Latinoamérica; set y eventos |
| **SOOW** | 600 V | EPDM + chaqueta CPE, 90 °C | UL 62 / CSA C22.2 No. 49 | EE. UU., México, Colombia, Perú; set y rental |
| **Type W** | 600 V (2 kV opcional) | EPDM/CPE, 90 °C | UL 62 | Feeds de generador y cam-lock de gran sección |

- SOOW es "hard service cord": 600 V, aceite y agua, −40 °C a +90 °C, listado UL/CSA y aprobado MSHA.
- H07RN-F es cable flexible de servicio pesado, 0.6/1 kV, apto para uso móvil y fijo.

> Fuentes: [Southwire — SOOW 600 V](https://www.southwire.com/us/es-us/wire-cable/flexible-cord/soow/p/PCORD11) · [Prysmian — Libro Blanco de la instalación BT, p. 420 (FLEXTREME MAX H07RN-F)](http://www.prysmiangroupcatalogue.com/prysmian/libro-blanco-instalacion-baja-tension/420/) · [Mid America Wire — SOOW ampacity chart (NEC 400.5)](https://midamericawirecable.com/resources/soow-cord-ampacity-chart)

### 1.2 H07RN-F — ampacidad y resistencia (cobre)

Tabla del fabricante (Prysmian, cable 3G, cobre). Las columnas *al aire* y *móvil* son a 30 °C de ambiente; *bajo tubo/enterrado* a 20 °C de terreno.

| Sección mm² | AWG equiv. | Al aire, fijo (A) | **Servicio móvil (A)** | Bajo tubo / enterrado (A) | Directo enterrado (A) | R a 20 °C (Ω/km) | Caída V/A·km cos φ=1 |
|---|---|---|---|---|---|---|---|
| 1.0 | 17 | 20 | **10** | 20 | 22 | 19.5 | 46.47 |
| 1.5 | 16 | 26 | **16** | 25 | 27 | 13.3 | 30.98 |
| 2.5 | 14 | 36 | **25** | 33 | 35 | 7.98 | 18.66 |
| 4 | 12 | 49 | **35** | 43 | 46 | 4.95 | 11.68 |
| 6 | 10 | 63 | **44** | 53 | 58 | 3.30 | 7.90 |
| 10 | 8 | 86 | **62** | 71 | 77 | 1.91 | 4.67 |
| 16 | 6 | 115 | **82** | 91 | 100 | 1.21 | 2.94 |
| 25 | 4 | 149 | **109** | 116 | 129 | 0.780 | 1.86 |
| 35 | 2 | 185 | **135** | 139 | 155 | 0.554 | 1.35 |
| 50 | 1/0 | 225 | **169** | 164 | 183 | 0.386 | 0.99 |

**Cómo se lee:**
- *Al aire, fijo*: instalación fija en bandeja perforada o rejilla, 30 °C. Método E/F de IEC 60364-5-52, tabla B.52.12.
- *Servicio móvil*: cable que se mueve, se tiende y se recoge; 30 °C. UNE-EN 50565-1, tablas C.2 y C.3. **Esta es la columna correcta para set.**
- *Bajo tubo / enterrado*: terreno a 20 °C, resistividad térmica 2.5 K·m/W. Método D1/D2.
- *R a 20 °C*: valor máximo de norma IEC 60228 clase 5 (cable flexible). A temperatura de servicio sube (ver §2.2).
- *Caída V/A·km*: dato del fabricante para dos conductores activos; implica R a ~60–65 °C (factor ≈1.17 sobre R20), no R a 20 °C.

> Fuente: [Prysmian — Libro Blanco BT, p. 420](http://www.prysmiangroupcatalogue.com/prysmian/libro-blanco-instalacion-baja-tension/420/). La tabla declara explícitamente las normas y temperaturas de cada columna.

**Nota sobre 1.0 mm²:** existe en H07RN-F 3G1, pero su ampacidad móvil (10 A) es baja y en set se usa casi solo para control o luminarias LED chicas. Para una toma Edison de 15 A no alcanza.

### 1.3 SOOW — ampacidad NEC (30 °C)

NEC Table 400.5(A)(1), cobre, 30 °C de ambiente. **Columna A** = 3 conductores portadores de corriente (trifásico, o monofásico con neutro cargado). **Columna B** = 2 conductores portadores (monofásico 2 hilos o 240 V hot-hot). El conductor de protección no cuenta.

| AWG | Sección nom. mm² | 3 cond. cargados (A) | 2 cond. cargados (A) | R aprox. 20 °C (Ω/km) |
|---|---|---|---|---|
| 18 | 0.823 | 7 | 10 | 20.95 |
| 16 | 1.31 | 10 | 13 | 13.16 |
| 14 | 2.08 | 15 | 18 | 8.29 |
| 12 | 3.31 | 20 | 25 | 5.21 |
| 10 | 5.26 | 25 | 30 | 3.28 |
| 8 | 8.37 | 35 | 40 | 2.06 |
| 6 | 13.3 | 45 | 55 | 1.30 |
| 4 | 21.2 | 60 | 70 | 0.813 |
| 2 | 33.6 | 80 | 95 | 0.513 |

- A partir de 2 AWG, SOOW deja de ser práctico: para 100 A o más se usa **Type W** o DLO con cam-lock.
- **Ajuste por 4 o más conductores cargados** (NEC 400.5(A)(3)): 4–6 → ×0.80; 7–9 → ×0.70; 10–20 → ×0.50; 21–30 → ×0.45; 31–40 → ×0.40; ≥41 → ×0.35. Ejemplo: 8/5 SOOW trifásico con neutro cargado = 4 conductores → 35 A × 0.80 = 28 A.
- SOOW está marcado 90 °C, pero la tabla 400.5 **no da más amperaje por eso**: el margen térmico sirve para ambientes calientes, no para cargar más.

> Fuentes: [Mid America Wire — SOOW ampacity chart, NEC Table 400.5(A)(1) y 400.5(A)(3)](https://midamericawirecable.com/resources/soow-cord-ampacity-chart) · [Hebei Huatong — SOOW, ampacidad 30 °C por cantidad de conductores](https://www.htwirecable.com/products/ul-certificated-cables/soow.html)

**Resistencias**: calculadas con ρ_Cu = 17.241 Ω·mm²/km a 20 °C sobre la sección nominal. Coinciden dentro del 2 % con NEC Chapter 9 Table 8 (valores a 75 °C, ≈1.22 × los de 20 °C).

### 1.4 Equivalencia mm² ↔ AWG

No hay conversión exacta; la equivalencia es comercial (UL 83 da el tamaño más cercano).

| mm² | AWG comercial | Sección real del AWG (mm²) | Desvío |
|---|---|---|---|
| 1.0 | 17 | 1.04 | +4 % |
| 1.5 | 16 | 1.31 | −13 % |
| 2.5 | 14 | 2.08 | −17 % |
| 4 | 12 | 3.31 | −17 % |
| 6 | 10 | 5.26 | −12 % |
| 10 | 8 | 8.37 | −16 % |
| 16 | 6 | 13.3 | −17 % |
| 25 | 4 | 21.2 | −15 % |
| 35 | 2 | 33.6 | −4 % |
| 50 | 1/0 | 53.5 | +7 % |

> Fuente: [Southwire — American Wire Gauge (AWG/KCMIL) to mm²](https://www.southwire.com/medias/2304-American-Wire-Gauge-PRINT.pdf) (tabla oficial de conversión y secciones nominales).

**Consecuencia práctica:** el "2.5 mm²" europeo es un 14 AWG con 17 % menos cobre. Si la app calcula con 2.5 mm² y el eléctrico tiende 14/3 SOOW, la ampacidad real es 15 A (3 CC), no 25 A.

### 1.5 La regla que el motor debe hacer cumplir

`ampacidad_de_tabla × k_temperatura × k_agrupamiento ≥ I_carga`

donde `ampacidad_de_tabla` sale de **la tabla del cable que el usuario declaró**, no de una tabla única.

---

## 2. Caída de tensión

### 2.1 Fórmulas correctas

Con `L` = longitud **de ida** en km, `I` en A, `R` y `X` en Ω/km, `cos φ` del receptor:

**Monofásico / continua (ida y vuelta):**
```
ΔV = 2 · I · L · (R · cos φ + X · sen φ)
```

**Trifásico equilibrado:**
```
ΔV = √3 · I · L · (R · cos φ + X · sen φ)
```

**Porcentaje:**
```
ΔV% = ΔV / V_nominal · 100
```
En trifásico, `V_nominal` es la tensión **entre fases** (380, 400, 480 V); en monofásico, la tensión fase-neutro (120, 220, 230, 240 V).

**Por qué el 2 y por qué √3:**
- El **2** es el camino de ida y vuelta: la corriente sale por la fase y vuelve por el neutro (o por la otra fase en 240 V). Si se olvida, la caída se subestima a la mitad.
- El **√3** aparece porque en un sistema trifásico equilibrado las tres fases están a 120°: la suma vectorial de las caídas de línea da `√3 · I · Z` con `V` entre fases. No se multiplica además por 2: el retorno ya está implícito en el sistema trifásico.

**Reactancia `X`:** para secciones ≤16 mm² y `cos φ` ≥0.9, `X` aporta <2 % y se puede despreciar. Para 25–50 mm² usar 0.07–0.08 Ω/km. `NO VERIFICADO` un valor normativo único de X para cable flexible; es dato de fabricante.

> Fuente: [IEC 60364-5-52 Anexo G — fórmula general ΔV = b·(R·cos φ + X·sen φ)·I·L, con b = 2 monofásico y b = √3 trifásico](https://ecalpro.com/zh-CN/calculators/voltage-drop/iec-60364) · Handbook de Harry Box, *Set Lighting Technician's Handbook*, cap. 17 "Voltage drop and line loss".

### 2.2 La resistencia no es la de 20 °C

`R` sube con la temperatura del conductor:

```
R(T) = R20 · [1 + 0.00393 · (T − 20)]
```

| Temperatura del conductor | Factor sobre R20 |
|---|---|
| 20 °C | 1.000 |
| 60 °C | 1.157 |
| 70 °C | 1.196 |
| 90 °C (régimen EPR/XLPE) | **1.275** |

Usar R20 subestima la caída ~20 % en un cable cargado. **Recomendación para Dart:** `R_servicio = R20 × 1.2` por defecto y `× 1.275` en el caso conservador (cable a plena carga térmica).

### 2.3 Ejemplos verificados

| # | Circuito | Datos | Cálculo | Resultado |
|---|---|---|---|---|
| 1 | Monofásico 230 V | 16 A, 50 m, 2.5 mm² H07RN-F, cos φ=1 | R90 = 7.98×1.275 = 10.17 Ω/km; ΔV = 2×0.05×16×10.17 | **16.28 V = 7.08 %** (con R20: 12.77 V = 5.55 %) |
| 2 | Trifásico 400 V | 10 kW, cos φ=0.9, 30 m, 4 mm² | I = 10000/(√3×400×0.9) = 16.04 A; ΔV = √3×0.03×16.04×(4.95×1.275×0.9 + 0.08×0.436) | **4.76 V = 1.19 %** |
| 3 | Trifásico 380 V | 63 A, 80 m, 16 mm², cos φ=0.9 | R90 = 1.21×1.275 = 1.543; ΔV = √3×0.08×63×(1.543×0.9+0.08×0.436) | **12.43 V = 3.27 %** |
| 4 | Monofásico 120 V | 20 A, 100 ft (30.48 m), 12 AWG SOOW | ΔV = 2×0.03048×20×5.21 | **6.35 V = 5.3 %** (a 75 °C: 7.7 V = 6.4 %) |

**Verificación cruzada:**
- El caso 1 coincide con la tabla del fabricante: 18.66 V/A·km × 16 A × 0.05 km = **14.93 V** (Prysmian usa R a ~60–65 °C; a 70 °C la diferencia es ~2 %).
- El caso 4 coincide con el ejemplo publicado por el proveedor: "un cordón 12 AWG de 100 ft a 20 A en 120 V cae unos 6.5 V".
- Harry Box resuelve el mismo problema con la fórmula de circular mils `ΔV = K·I·L/Cm` (K = 21.6 monofásico, 18.34 trifásico). Su ejemplo: 5-wire #2 AWG, 250 ft, 6 V admitidos → **86.8 A por fase**. Nuestro cálculo da ~81 A por fase con R a 75 °C; la diferencia (~7 %) viene de las constantes K del handbook. El orden de magnitud y el criterio son idénticos.

> Fuentes: [Prysmian — Libro Blanco BT, tabla de caída de tensión](http://www.prysmiangroupcatalogue.com/prysmian/libro-blanco-instalacion-baja-tension/420/) · [Mid America Wire — SOOW chart y ejemplo de caída](https://midamericawirecable.com/resources/soow-cord-ampacity-chart) · [Set Lighting Technician's Handbook (H. Box) — cap. 17, fórmulas K·I·L/Cm](https://vdoc.pub/documents/set-lighting-technicians-handbook-film-lighting-equipment-practice-and-electrical-distribution-70au8nquvsf0)

### 2.4 Límites de caída

| Referencia | Límite |
|---|---|
| IEC 60364-5-52 (Anexo G) / práctica europea | 3 % iluminación, 5 % otros usos (la norma distingue red pública de instalación privada) |
| NEC 210.19(A) nota informativa | 3 % en ramal + 5 % total (recomendación, no obligatorio) |
| Práctica de set | ≤5 % en el tramo más largo; ≤3 % para HMI sensible a tensión |

Para el motor: si `ΔV% > 5` → advertir; si `> 10` → bloquear la recomendación de esa sección.

---

## 3. Derating

### 3.1 Temperatura ambiente (cable)

Factores de corrección para cables **al aire**, base 30 °C (IEC 60364-5-52, tabla B.52.14). Se multiplican por la ampacidad de la tabla.

| Temp. ambiente °C | PVC (70 °C) | **EPR / XLPE (90 °C)** |
|---|---|---|
| 10 | 1.22 | 1.15 |
| 15 | 1.17 | 1.12 |
| 20 | 1.12 | 1.08 |
| 25 | 1.06 | 1.04 |
| **30** | **1.00** | **1.00** |
| 35 | 0.94 | 0.96 |
| 40 | 0.87 | 0.91 |
| 45 | 0.79 | 0.87 |
| 50 | 0.71 | 0.82 |
| 55 | 0.61 | 0.76 |
| 60 | 0.50 | 0.71 |
| 65 | — | 0.65 |
| 70 | — | 0.58 |

**Ejemplo:** 2.5 mm² H07RN-F móvil = 25 A a 30 °C. A 40 °C (verano en Buenos Aires, cable al sol): 25 × 0.91 = **22.75 A**. A 50 °C (cable sobre asfalto): 25 × 0.82 = **20.5 A**.

> Fuente: [IEC 60364-5-52 tabla B.52.14 — factores de corrección por temperatura ambiente para cables al aire](https://www.cableapp.com/info/docs/cn/LowVoltagePowerCableTechnicalData-EN.pdf) · replicada en [pliego de la Junta de Andalucía, tabla B.52.14](https://www.juntadeandalucia.es/sites/default/files/2023-05/280.452%20Lucero%20AU_01.01_Proyecto%20Ejecucion_v0.1%20Firmado%202vez.pdf)

> Ojo con la convención: en España hay tablas con base **40 °C** (UNE-HD 60364). Si se mezclan, el factor se aplica dos veces. La app debe declarar siempre la base.

### 3.2 Agrupamiento

- **NEC 400.5(A)(3)** para cords: 4–6 conductores ×0.80; 7–9 ×0.70; 10–20 ×0.50 (tabla completa en §1.3).
- **IEC 60364-5-52 tabla B.52.17** para cables agrupados en bandeja: factores de 0.80–0.85 para 4–6 cables y más bajos a medida que aumenta la cantidad.
- **Cable enrollado en tambor o en rollo:** la ampacidad cae mucho más que "al aire" porque el calor no se disipa. `NO VERIFICADO` un factor numérico único; la práctica segura es **desenrollar todo el cable antes de cargarlo** o aplicar un factor ≤0.5. La app debe advertir "cable en rollo" como riesgo alto, no calcular con la tabla al aire.

### 3.3 Altitud

#### 3.3.1 Cable: la norma no deratea por altitud

**Hallazgo:** IEC 60364-5-52 y NEC no incluyen un factor de corrección de ampacidad por altitud para cables de baja tensión. La razón física es que la convección depende de la densidad del aire, pero para cables la resistencia térmica de la aislación domina y el efecto es chico.

Datos empíricos disponibles:

| Altitud | Factor sobre ampacidad | Contexto |
|---|---|---|
| 3000 m (10 000 ft) | **0.92** | Cable en aire libre, dato aeronáutico (DTIC / AC 43.13-1B) |
| 15 km | 0.71 | Fuera de cualquier set |

> Fuente: [DTIC ADA101016 — factor 0.92 a 3 km para haces de cable en aire](https://apps.dtic.mil/sti/tr/pdf/ADA101016.pdf). La AC 43.13-1B (cap. 11) usa la misma curva; por debajo de 10 000 ft la corrección es ≤5 %.

**Decisión recomendada para el motor:**
- Factor normativo de altitud para cable = **1.0** (no existe).
- Ofrecer un "margen de ingeniería" opcional de **0.92 a 3000 m** (dato DTIC) y **0.89 a 4000 m** (extrapolación), claramente etiquetado como no normativo y apagado por defecto.
- **Nunca** aplicar 10 %/1000 m ni un piso de 0.4.

#### 3.3.2 Generador: acá sí hay norma y datos de fabricante

El generador pierde por **dos** mecanismos independientes:

**(a) Motor (combustión):** la altura reduce la masa de aire aspirada. Regla Cummins para grupos pequeños (HDKCA/HDKCB):

- **3.5 % por cada 1000 ft (305 m)** de altitud → ≈1.15 % por 100 m.
- **1 % por cada 10 °F (5.6 °C)** por encima de 77 °F (25 °C).

**(b) Alternador (eléctrico):** rodamiento de 1000 m de altitud y 40 °C de ambiente.

- **3 % por cada 500 m** de altitud por encima de 1000 m.
- **3 % por cada 5 °C** de ambiente por encima de 40 °C.

| Componente | Regla | A 3000 m | Fuente |
|---|---|---|---|
| Motor atmosférico (grupos chicos) | 3.5 %/1000 ft | −32.6 % | Cummins HDKCX |
| Motor turboalimentado | Depende del modelo (knee + slope de la curva) | `NO VERIFICADO` genérico | Cummins T-030 |
| Alternador | 3 %/500 m sobre 1000 m | −12 % (0.97⁴ = −11.5 %) | Cummins T-030 |
| Alternador por temperatura | 3 %/5 °C sobre 40 °C | 0 % a 40 °C; −3 % a 45 °C | Cummins T-030 |

> Fuentes: [Cummins — HDKCX Service Manual, "Maximum generator loading": 1 % por 10 °F sobre 77 °F y 3.5 % por 1000 ft](https://www.social.cummins.com/sites/default/files/2024-10/a043m526-i13-hdkcx-service-manual.pdf) · [Cummins — Application Manual T-030, p. 140–158: knee del alternador 1000 m / 40 °C, derate 3 %/500 m y 3 %/5 °C](https://incal.cummins.com/www/literature/applicationmanuals/t-030_p140-158.pdf)

**Por qué el motor turbo no pierde 33 %:** el turbo comprime el aire y recupera parte de la densidad; la pérdida típica de un diésel turbo a 3000 m es del orden de 10–15 %, pero **el número exacto sale de la curva del fabricante**. Por eso va como `NO VERIFICADO` genérico: la app debe pedir el modelo o usar el dato de placa.

#### 3.3.3 Ejemplo completo: 3000 m, 40 °C, Bolivia/Perú

Grupo de **100 kVA / 80 kW** a 400 V, FP 0.8.

| Paso | Cálculo | Resultado |
|---|---|---|
| Potencia aparente nominal | 100 kVA | 100 kVA |
| Derate alternador por altitud | 100 × 0.97⁴ | **88.5 kVA** |
| Derate por temperatura (40 °C) | ×1.00 | 88.5 kVA |
| Potencia activa a FP 0.8 | 88.5 × 0.8 | **70.8 kW** |
| Corriente nominal por fase | 88500/(√3×400) | **127.7 A** |
| Motor: si es atmosférico chico | 80 × (1−0.326) | **53.9 kW** ← el límite real |
| Motor: si es turbo (estimado) | 80 × 0.88 | 70.4 kW (usar curva del fabricante) |

**Conclusión operativa:** a 3000 m el límite suele ser el **motor**, no el alternador. Un grupo que en el llano da 80 kW puede quedar en 55–70 kW. La app debe mostrar los dos límites y quedarse con el menor.

### 3.4 Qué implementar en el motor

```
ampacidad_efectiva = ampacidad_tabla
                   × k_temperatura(ambiente, aislamiento)
                   × k_agrupamiento(n_conductores)
                   × k_altitud_cable   // 1.0 por defecto; 0.92 opcional a 3000 m
                   × k_instalacion     // 1.0 al aire; 0.85 en rollo (advertencia)
```

```
potencia_generador_util = min(
    kVA_nominal × k_alt_alternador × k_temp_alternador × FP,
    kW_motor × k_alt_motor × k_temp_motor
)
```

---

## 4. Generadores de set

### 4.1 kVA ↔ kW

```
kW  = kVA × FP
kVA = kW / FP
I_trifásica = kVA × 1000 / (√3 × V_entre_fases)
I_monofásica = kVA × 1000 / V
```

**Dato clave:** los grupos trifásicos se especifican con **FP 0.8**; los monofásicos, con **FP 1.0**.

> Fuente: [Cummins — T-030 (español): "los conjuntos generadores monofásicos tienen un factor de potencia del 100 % y los trifásicos del 80 %"](https://incal.cummins.com/www/literature/applicationmanuals/t030-es.pdf)

**Consecuencia:** un grupo de 100 kVA trifásico entrega 80 kW *si la carga tiene FP 0.8*. Con HMI (FP 0.98) el alternador podría dar más kW, pero el **motor** sigue limitado a 80 kW. Con cargas de FP bajo (balasto magnético) pasa lo contrario: el motor tiene kW de sobra pero el alternador se queda sin kVA y la corriente se dispara.

### 4.2 Factor de potencia por tecnología

| Carga | FP típico | Estado | Fuente |
|---|---|---|---|
| Tungsteno (fresnel, open face) | 1.00 | Por definición (carga resistiva) | — |
| HMI con balasto electrónico + ALF (575/1200 W) | **0.98** | Verificado | ARRI EB 575/1200 |
| HMI con balasto electrónico 6 kW | **0.98** | Verificado | Cinelight EB 6000 |
| HMI con balasto magnético | `NO VERIFICADO` | Depende de la compensación capacitiva del balasto; leer placa | — |
| LED con driver con PFC (Mean Well HLG) | **0.95–0.98** | Verificado | Mean Well HLG-60H |
| LED barato / sin PFC | `NO VERIFICADO` | Drivers sin PFC tienen FP bajo; no usar sin medir | — |
| Generador trifásico (nominal) | 0.80 | Verificado | Cummins |
| Generador monofásico (nominal) | 1.00 | Verificado | Cummins |

**ARRI EB 575/1200 (dato de placa):** 1390 VA máx, cos φ ≈ 0.98, corriente nominal 15.4–10.7 A en 90–125 V y 7.7–5.5 A en 180–250 V.
**Cinelight EB 6000:** 6900 VA máx, FP 0.98, 38–26 A.

> Fuentes: [ARRI EB 575/1200 — Technical Data (1390 VA, cos φ ≈ 0.98)](https://www.manualzz.com/doc/63889009) · [Cinelight EB 6000 — 6900 VA, PF 0.98](https://cinelight.com/module/producttopdf/view?id_product=279) · [Mean Well HLG-60H — PF >0.98 a 115 V, >0.95 a 230 V](https://www.aipcba.com/datasheet/pdf/hlg60h20-cm15211400-f48911636.html)

**El balasto magnético:** no hay valor de fabricante verificado en esta investigación. Como es una carga inductiva con choke, su FP es bajo salvo que el balasto tenga corrección capacitiva; el dato correcto es el de la placa del balasto o una pinza amperométrica true-RMS. El motor debe permitir **entrar el FP a mano** y no asumir 0.8 por defecto.

### 4.3 Corriente de arranque (inrush)

| Tecnología | Multiplicador sobre I nominal | Duración | Fuente |
|---|---|---|---|
| Rectificador con PFC (HMI electrónica, LED con PFC) | **30–100 × I_n** | ≤1 ms | Schneider Electric, Electrical Installation Guide |
| Rectificador con choke | 10–30 × I_n | ≤5 ms | Schneider Electric, Electrical Installation Guide |
| Driver LED 60 W (medición de fabricante) | **55 A** por unidad a 230 V | 265 µs | Mean Well HLG-60H |
| Balasto magnético HMI | `NO VERIFICADO` | — | — |

**Ejemplo derivado (no medido):** un EB 1200 a 230 V consume 5.5 A nominales. Con 30–100 × I_n → **165–550 A de pico** durante <1 ms. Veinte unidades encendidas a la vez → 3.3–11 kA de pico. Esto no funde un cable, pero:

1. **Dispara la protección magnética** de una térmica curva C (5–10 × I_n según IEC 60898-1; una C16 dispara entre 80 y 160 A) si el pico coincide.
2. **Hunde la tensión** del generador y puede hacer saltar el excitador o apagar otras HMI.
3. **Pega los contactos** de relés y contactores.

**Medidas:** encendido escalonado (una HMI cada 2–5 s), térmicas **curva D** (10–20 × I_n) en circuitos de HMI, y alternador con buena capacidad de arranque de motor.

> Fuente: [Schneider Electric — Electrical Installation Guide, tabla de inrush current (rectificador con PFC / con choke)](https://docshare.tips/electrical-installation-guide-2010_584a4f86b6d87f6d358b4a6e.html) · [Mean Well HLG-60H — inrush 55 A, 265 µs](https://www.aipcba.com/datasheet/pdf/hlg60h20-cm15211400-f48911636.html)

### 4.4 Ejemplo de dimensionado

Set: 4× HMI 6 kW + 20× HMI 1.2 kW + 10 kW de LED.

| Carga | Cantidad | VA unitario | Total kVA |
|---|---|---|---|
| HMI 6 kW (EB 6000) | 4 | 6900 | 27.6 |
| HMI 1.2 kW (EB 1200) | 20 | 1390 | 27.8 |
| LED 10 kW (FP 0.95) | — | — | 10.5 |
| **Total** | | | **65.9 kVA** |

- Generador de 100 kVA a 400 V → 144 A nominales; con la carga del ejemplo, **95 A (66 %)**. OK.
- A 3000 m el mismo grupo queda en 88.5 kVA → la carga es 74 %. Sigue OK, pero el margen se estrecha.
- Si en vez de HMI fueran 65.9 kVA de balastos magnéticos con FP 0.5, los kW serían solo 33 pero la corriente sería la misma: el alternador no se entera, el motor tampoco. **El problema del FP bajo es la corriente y la caída, no los kW.**

---

## 5. Conexiones de set

### 5.1 Tipos, límites y uso

| Conexión | Norma / serie | Tensión típica | Corriente máx. | Cable típico | Notas |
|---|---|---|---|---|---|
| **Tie-in** (acometida directa) | NEC 530 / 590; reglamentación local | 120/208/240/380/400/480 V | La de la acometida y los lugs | 2/0–4/0 AWG o mayor | Sin conector: se atornilla a borneras con la acometida cortada. Requiere electricista habilitado y permiso del AHJ. `NO VERIFICADO` un límite universal: depende de la acometida |
| **Cam-lock** (single-pole cam, "bates" de potencia) | Leviton serie 16; UL/CSA | 600 V | **400 A** | 2/0–4/0 AWG | Estándar de distribución temporaria en cine. El conector es de 400 A, el cable no (ver §5.3) |
| **Stage pin** (Bates, 2P&G) | Industria EE. UU. (Bates/Union Connector) | 125 V (20/60/100 A); versiones 250 V | **20 / 60 / 100 A** | 60 A: #6 AWG | 20 A en grillas teatrales; 60 y 100 A en cine. En 20 A el pin central es tierra; **60 y 100 A tienen otra configuración de pines** (verificar antes de cablear) |
| **Edison / NEMA 5-15** | NEMA WD-6 | 125 V | **15 A** | 14–12 AWG | El enchufe doméstico; 5-20 = 20 A. No usar para HMI grandes |
| **CEE 16 A** | IEC 60309-1/-2 | 230 V (azul) / 400 V (rojo) | **16 A** | 2.5 mm² | 3P+N+PE en 5 polos para trifásico |
| **CEE 32 A** | IEC 60309-1/-2 | 230 V / 400 V | **32 A** | 6 mm² | Común en distribuidores europeos |
| **CEE 63 A** | IEC 60309-1/-2 | 230 V / 400 V | **63 A** | 16 mm² | Alimentación de distro chico/mediano |
| **Schuko** | CEE 7/3 | 230 V | 16 A | 1.5–2.5 mm² | Tierra por contactos laterales; no apto para set con humedad ni para cargas altas |

> Fuentes: [Leviton — Single Pole Cam-Type Connectors, serie 16, hasta 400 A / 600 V, cable 2/0–4/0](http://myoungjiele.co.kr/ctalog-down/leviton_camconnectors.pdf) · [JML Rental — Bates/stage pin: 20, 60 y 100 A; 60 A con cable #6](https://jmlrental.com/film-gear-quick-reference/electric-gear-quick-reference/bates-cables-quick-reference/) · [Marinco — stage pin 20 A/125 V, 60 A/125 V, 100 A/125 V](https://www.datasheets.com/tr/categories/interconnect/connectors/i-o-connectors/connector-power) · [Qualtek/NEMA — 5-15P 15 A 125 V, 5-20P 20 A 125 V](https://my.mouser.com/new/qualtek/qualtek-nema-ac-plugs-receptacles/) · [Mennekes — CEE 16/32/63 A, 5 p, 400 V](https://www.mennekes.co.uk/fileadmin/products_media/downloads/produktinfo/20250307/940010_en_GB.pdf)

### 5.2 Voltajes por país (los que importan al proyecto)

| País | Monofásico | Trifásico (√3 × mono) | Frecuencia | Fuente |
|---|---|---|---|---|
| Argentina | 220 V | 380 V | 50 Hz | Schneider FA158872 |
| Bolivia | 230 V (zonas con 115 V) | 380–400 V | 50 Hz | Electrical Safety First / Mennekes |
| Perú | 220 V | 380 V | **60 Hz** | CNE Perú / Legrand Power Guide |
| Chile | 220 V | 380 V | 50 Hz | Schneider FA158872 |
| Colombia | 110/220 V | 208/380 V | 60 Hz | Schneider FA158872 |
| México | 127 V | 220 V | 60 Hz | Schneider FA158872 |
| Brasil | 127/220 V | 220/380 V | 60 Hz | Schneider FA158872 |
| EE. UU. | 120/240 V | 208/480 V | 60 Hz | NEMA / Schneider |
| España | 230 V | 400 V | 50 Hz | Schneider FA158872 |

**Perú es la trampa del proyecto:** 220 V pero **60 Hz**. Un HMI electrónico funciona igual (50/60 Hz), pero una lámpara fluorescente magnética o un motor de 50 Hz cambia de velocidad y puede parpadear. El módulo de flicker ya usa la frecuencia de red: en Perú tiene que tomar 60 Hz, no 50.

**Argentina:** 220 V/50 Hz monofásico y 380 V/50 Hz trifásico. Los generadores de set suelen venir configurados 380/220 V, que es lo que hay que pedir.

> Fuentes: [Schneider Electric — International Connectors & Country Comparison Reference Chart (FA158872)](https://www.se.com/nl/nl/faqs/FA158872/) · [Código Nacional de Electricidad de Perú — 380/220 V, 60 Hz](https://cdn.www.gob.pe/uploads/document/file/898589/C%C3%B3digo_Nacional_de_Electricidad__Suministro_2011_.pdf) · [Legrand Power Guide — Perú 60 Hz, 220 V](https://www.legrandgroup.com/sites/default/files/Documents_PDF_Legrand/Solutions/Power_guide/Power-Guide-Legrand_EX29007-PDF_BD.pdf) · [Electrical Safety First — Bolivia 230 V, 50 Hz](https://www.electricalsafetyfirst.org.uk/safety-advice/travel-advice/bolivia/)

### 5.3 La regla del 400 % del NEC 530 (por qué 4/0 admite 400 A)

El NEC permite, **solo para stage cables de set lighting en estudios/etapas**, proteger el cable hasta el **400 % de su ampacidad**:

> "Stage cables for stage set lighting shall be protected by means of overcurrent devices set at not more than 400 percent of the ampacity given in the applicable tables of Articles 310 and 400."
> — NEC 530.18(A)

Con 4/0 AWG (≈230 A en tabla 310.16 a 75 °C) el máximo permitido sería 920 A; un cam-lock de 400 A queda holgado y es legal. **Pero:** eso vale para stage set lighting en un estudio bajo Art. 530. En locación, el Art. 590 (temporary installations) y la autoridad local pueden no aceptarlo. La app no debe presentar el 400 % como regla general.

**Factores de demanda del Art. 530.19(A)** para stage set lighting:

| Porción de la carga (VA) | Factor |
|---|---|
| Primeros 50 000 | 100 % |
| 50 001–100 000 | 75 % |
| 100 001–200 000 | 60 % |
| Más de 200 000 | 50 % |

Y **530.19(B)**: se permite un factor de demanda del **50 %** para todos los feeders portátiles.

> Fuente: [NEC Article 530 — texto de 530.18 y 530.19 (California Title 24, Part 3)](http://mirrors.mit.edu/bulk.resource.org/bsc.ca.gov/title24_part03_slice05.pdf) · [NEC 530.19(A)/(B) — tabla de factores de demanda](https://sfgov.m.legistar.com/View.ashx?M=F&ID=4750923&GUID=953C25D5-E9A4-484E-83E8-DE1C9C4F055B)

---

## 6. Regla práctica de carga y márgenes

### 6.1 El 80 % de la térmica

NEC 210.20(A): la protección de un ramal debe ser ≥ carga no continua + **125 % de la carga continua**. Una carga continua es la que dura **3 horas o más**. De ahí sale la regla: **carga continua ≤ 80 % de la térmica**.

```
I_continua ≤ 0.80 × I_térmica        (térmica estándar)
I_continua ≤ 1.00 × I_térmica        (térmica y tablero "100 % rated")
```

La excepción de las térmicas *100 % rated* existe, pero exige que **el conjunto** (térmica + tablero) esté listado para 100 %, no solo la térmica.

> Fuentes: [Eaton — NEC 210.20(A) y diseño 80 % vs 100 %](https://www.eaton.com/content/dam/eaton/products/electrical-circuit-protection/molded-case-circuit-breakers/eaton-mccb-100-percent-rating-application-note-ap01200008e-en-us.pdf) · [Cummins — "for continuous loads, standards only allow circuit breakers to be used at 80 % of their rating"](https://mart.cummins.com/imagelibrary/data/assetfiles/0056625.pdf) · [ETC — Application Note AN101-B, 80 % vs 100 %](https://www.etcconnect.com/uploadedFiles/Main_Site/Documents/Public/White_Papers/AN101-B_100__Cont_Load_4pg.pdf)

### 6.2 Márgenes recomendados para el motor

| Uso | Margen | Fundamento |
|---|---|---|
| Térmica de ramal, carga continua | 80 % | NEC 210.20(A) |
| Térmica de ramal, carga de set <3 h | 100 % | No continua |
| Cable | 100 % de la ampacidad corregida (80 % si la carga es continua) | NEC 210.19(A)(1) / IEC 60364-5-52 |
| Generador, carga continua | 80 % de la potencia útil | Práctica de la industria + derating |
| Generador, picos de arranque | Verificar caída de tensión, no solo kW | Inrush 30–100 × I_n |
| Acometida (tie-in) | 80 % del breaker de la acometida | NEC 210.20(A) |

### 6.3 Semáforo propuesto (decisión de producto, no dato)

| Carga sobre la capacidad corregida | Color | Mensaje |
|---|---|---|
| ≤50 % | Verde | "Holgado" |
| 50–80 % | Ámbar | "Cerca del límite continuo" |
| 80–100 % | Rojo | "Solo admisible si la carga no es continua" |
| >100 % | Negro | "No energizar" |

El semáforo debe mostrar **qué límite se está midiendo**: térmica, ampacidad del cable, caída de tensión o generador. Un número sin el límite que lo origina no sirve en set.

### 6.4 Caso especial: generador + HMI

- Carga en kW: sumar vatios de lámparas y dividir por la eficiencia del balasto (≈0.93–0.95 en electrónico; ≈0.85 en magnético, según la guía de Schneider).
- Carga en kVA: dividir por el FP (0.98 en HMI electrónica).
- Arranque: encendido escalonado.
- Regla de pulgar de la industria: no pasar el **80 % de la potencia útil** del grupo con HMI encendidas y **dejar el 20 %** para picos y para el motor del generador. `NO VERIFICADO` como norma; es práctica, no código.

> Fuente de eficiencias: [Schneider Electric — Electrical Installation Guide (balasto electrónico >93 %, magnético ≈85 %)](https://docshare.tips/electrical-installation-guide-2010_584a4f86b6d87f6d358b4a6e.html)

---

## 7. TABLA PARA DART

### 7.1 H07RN-F (cobre, 3G, 30 °C, servicio móvil)

`ampacidad_a` = servicio móvil (EN 50565-1), que es la que corresponde a instalación temporal. Los valores fijos al aire y bajo tubo van en `notas`.

```text
seccion_mm2|awg|ampacidad_a|ohm_por_km|notas
1.0|17|10|19.5|H07RN-F 3G movil 30C EN 50565-1; fija al aire 20 A; bajo tubo 20 A; R20 max IEC 60228 cl.5
1.5|16|16|13.3|movil 30C; fija al aire 26 A; bajo tubo 25 A
2.5|14|25|7.98|movil 30C; fija al aire 36 A; bajo tubo 33 A
4|12|35|4.95|movil 30C; fija al aire 49 A; bajo tubo 43 A
6|10|44|3.30|movil 30C; fija al aire 63 A; bajo tubo 53 A
10|8|62|1.91|movil 30C; fija al aire 86 A; bajo tubo 71 A
16|6|82|1.21|movil 30C; fija al aire 115 A; bajo tubo 91 A
25|4|109|0.780|movil 30C; fija al aire 149 A; bajo tubo 116 A
35|2|135|0.554|movil 30C; fija al aire 185 A; bajo tubo 139 A
50|1/0|169|0.386|movil 30C; fija al aire 225 A; bajo tubo 164 A
```

### 7.2 SOOW / NEC 400.5 (cobre, 30 °C, 3 conductores cargados)

`seccion_mm2` es la sección nominal del AWG. `ampacidad_a` = columna A (3 conductores cargados); el valor de 2 conductores va en `notas`.

```text
seccion_mm2|awg|ampacidad_a|ohm_por_km|notas
0.823|18|7|20.95|NEC 400.5(A)(1) 30C; 2 CC 10 A
1.31|16|10|13.16|2 CC 13 A
2.08|14|15|8.29|2 CC 18 A
3.31|12|20|5.21|2 CC 25 A
5.26|10|25|3.28|2 CC 30 A
8.37|8|35|2.06|2 CC 40 A
13.3|6|45|1.30|2 CC 55 A
21.2|4|60|0.813|2 CC 70 A
33.6|2|80|0.513|2 CC 95 A
```

**Reglas de uso de estas tablas en el motor:**
1. La tabla se elige por **tipo de cable declarado**, nunca por sección sola.
2. `ampacidad_a` se multiplica por el factor de temperatura (§3.1) y el de agrupamiento (§3.2).
3. La altitud **no** se aplica al cable por defecto (§3.3.1).
4. `ohm_por_km` es a 20 °C: para caída de tensión multiplicar por 1.2 (o 1.275 en el caso conservador).
5. Para secciones >50 mm² o >2 AWG, el motor debe cambiar a Type W / cam-lock y no extrapolar.

---

## 8. Pendientes / NO VERIFICADO

| Dato | Estado | Qué hacer |
|---|---|---|
| FP de balasto magnético HMI | `NO VERIFICADO` | Medir con pinza true-RMS o leer placa; permitir entrada manual |
| Derating de motor turbo a 3000 m | `NO VERIFICADO` genérico | Pedir modelo de grupo; usar curva del fabricante |
| Factor normativo de altitud para cable | No existe en IEC/NEC | Dejar 1.0; ofrecer 0.95 opcional como margen |
| Reactancia X por sección | `NO VERIFICADO` valor único | Usar 0.08 Ω/km para ≤16 mm² y despreciar |
| Límite de tie-in | Depende de la acometida | Pedir breaker de acometida y tipo de servicio |
| powerCON TRUE1 | `NO VERIFICADO` en esta investigación | Ver datasheet Neutrik antes de cargarlo |
| Ampacidad SOOW >2 AWG | No cubierta por la tabla consultada | Cambiar a Type W / DLO |

---

## 9. Fuentes

**Cables y ampacidad**
- Prysmian, *Libro Blanco de la Instalación — Baja Tensión*, p. 420 (H07RN-F, tablas IEC 60364-5-52 B.52.12 y EN 50565-1): http://www.prysmiangroupcatalogue.com/prysmian/libro-blanco-instalacion-baja-tension/420/
- Mid America Wire & Cable, *SOOW Cord Ampacity Chart* (NEC 400.5(A)(1) y 400.5(A)(3)): https://midamericawirecable.com/resources/soow-cord-ampacity-chart
- Hebei Huatong, *SOOW Portable Power Cable* (ampacidad 30 °C por cantidad de conductores): https://www.htwirecable.com/products/ul-certificated-cables/soow.html
- Southwire, *SOOW 600 V Flexible Cord*: https://www.southwire.com/us/es-us/wire-cable/flexible-cord/soow/p/PCORD11
- Southwire, *AWG/KCMIL to mm²*: https://www.southwire.com/medias/2304-American-Wire-Gauge-PRINT.pdf
- La Triveneta Cavi, *Low voltage: current ratings, correction factors, voltage drops* (EN 50565): https://latrivenetacavi.com/download/tables_EN.pdf

**Caída de tensión y derating**
- IEC 60364-5-52, Anexo G (fórmula general, b = 2 / √3) — reproducción técnica: https://ecalpro.com/zh-CN/calculators/voltage-drop/iec-60364
- IEC 60364-5-52, tabla B.52.14 (factores de temperatura): https://www.cableapp.com/info/docs/cn/LowVoltagePowerCableTechnicalData-EN.pdf
- Junta de Andalucía, pliego con tabla B.52.14 completa: https://www.juntadeandalucia.es/sites/default/files/2023-05/280.452%20Lucero%20AU_01.01_Proyecto%20Ejecucion_v0.1%20Firmado%202vez.pdf
- Harry C. Box, *Set Lighting Technician's Handbook*, cap. 17 (fórmulas K·I·L/Cm): https://vdoc.pub/documents/set-lighting-technicians-handbook-film-lighting-equipment-practice-and-electrical-distribution-70au8nquvsf0
- DTIC ADA101016 (derating por altitud en cable, 0.92 a 3 km): https://apps.dtic.mil/sti/tr/pdf/ADA101016.pdf

**Generadores**
- Cummins, *HDKCX Service Manual — Maximum Generator Loading* (1 %/10 °F, 3.5 %/1000 ft): https://www.social.cummins.com/sites/default/files/2024-10/a043m526-i13-hdkcx-service-manual.pdf
- Cummins, *Application Manual T-030*, p. 140–158 (alternador: knee 1000 m/40 °C, 3 %/500 m, 3 %/5 °C): https://incal.cummins.com/www/literature/applicationmanuals/t-030_p140-158.pdf
- Cummins, *T-030* en español (FP 1.0 monofásico / 0.8 trifásico): https://incal.cummins.com/www/literature/applicationmanuals/t030-es.pdf
- Cummins, *Generator set loading* (80 % en carga continua): https://mart.cummins.com/imagelibrary/data/assetfiles/0056625.pdf

**Balastos y cargas**
- ARRI, *EB 575/1200 — Technical Data* (1390 VA, cos φ ≈ 0.98): https://www.manualzz.com/doc/63889009
- Cinelight, *Electronic HMI ballast 6000 W* (6900 VA, PF 0.98): https://cinelight.com/module/producttopdf/view?id_product=279
- Mean Well, *HLG-60H* (PF >0.98/115 V, >0.95/230 V; inrush 55 A): https://www.aipcba.com/datasheet/pdf/hlg60h20-cm15211400-f48911636.html
- Schneider Electric, *Electrical Installation Guide* — tabla de inrush current: https://docshare.tips/electrical-installation-guide-2010_584a4f86b6d87f6d358b4a6e.html

**Conexiones y código**
- Leviton, *Single Pole Cam-Type Connectors* (400 A / 600 V, 2/0–4/0): http://myoungjiele.co.kr/ctalog-down/leviton_camconnectors.pdf
- JML Rental, *Bates Cables Quick Reference* (20/60/100 A; 60 A #6): https://jmlrental.com/film-gear-quick-reference/electric-gear-quick-reference/bates-cables-quick-reference/
- Marinco, *Stage pin 20/60/100 A 125 V*: https://www.datasheets.com/tr/categories/interconnect/connectors/i-o-connectors/connector-power
- Qualtek, *NEMA 5-15P 15 A/125 V, 5-20P 20 A/120 V*: https://my.mouser.com/new/qualtek/qualtek-nema-ac-plugs-receptacles/
- Mennekes, *CEE 16/32/63 A, 5 p, 400 V*: https://www.mennekes.co.uk/fileadmin/products_media/downloads/produktinfo/20250307/940010_en_GB.pdf
- NEC Article 530 (530.18 y 530.19), texto: http://mirrors.mit.edu/bulk.resource.org/bsc.ca.gov/title24_part03_slice05.pdf
- NEC 530.19(A)/(B), tabla de demanda: https://sfgov.m.legistar.com/View.ashx?M=F&ID=4750923&GUID=953C25D5-E9A4-484E-83E8-DE1C9C4F055B
- Eaton, *80 % vs 100 % rated breakers* (NEC 210.20(A)): https://www.eaton.com/content/dam/eaton/products/electrical-circuit-protection/molded-case-circuit-breakers/eaton-mccb-100-percent-rating-application-note-ap01200008e-en-us.pdf
- ETC, *AN101-B 100 % Continuous Load*: https://www.etcconnect.com/uploadedFiles/Main_Site/Documents/Public/White_Papers/AN101-B_100__Cont_Load_4pg.pdf

**Voltajes por país**
- Schneider Electric, *International Connectors & Country Comparison Chart* (FA158872): https://www.se.com/nl/nl/faqs/FA158872/
- Código Nacional de Electricidad de Perú (380/220 V, 60 Hz): https://cdn.www.gob.pe/uploads/document/file/898589/C%C3%B3digo_Nacional_de_Electricidad__Suministro_2011_.pdf
- Legrand, *Power Guide* (Perú 60 Hz, 220 V): https://www.legrandgroup.com/sites/default/files/Documents_PDF_Legrand/Solutions/Power_guide/Power-Guide-Legrand_EX29007-PDF_BD.pdf
- Electrical Safety First, *Bolivia 230 V / 50 Hz*: https://www.electricalsafetyfirst.org.uk/safety-advice/travel-advice/bolivia/

---

## 10. RIESGOS

1. **Mezclar tablas IEC y NEC.** 2.5 mm² H07RN-F = 25 A; 14 AWG SOOW = 15 A. Si la app muestra 25 A y el eléctrico tendió 14/3, el cable trabaja al 167 % de su ampacidad. **Riesgo de incendio.**
2. **Cable en rollo o en tambor.** La tabla es "al aire". Un cable enrollado no disipa y se derrite por dentro sin que se vea. La app debe bloquear el cálculo "al aire" si el usuario marca "en rollo".
3. **Altitud inventada.** El 10 %/1000 m con piso 0.4 no es norma. A 3000 m sobreprotege el cable (falso margen) y, si se aplica al generador, **subestima** la pérdida del alternador (12 %) y del motor (hasta 33 % en atmosféricos).
4. **Cam-lock de 400 A ≠ 400 A de cable.** 4/0 AWG son ~230 A. Los 400 A se justifican por el 400 % del NEC 530.18(A), que es para *stage set lighting* en estudio. En locación sin AHJ de acuerdo, es una práctica de riesgo.
5. **Inrush de HMI y LED.** 30–100 × I_n durante <1 ms. Dispara térmicas curva C, hunde generadores y pega contactos. Encienda escalonado y use curva D en circuitos de HMI.
6. **FP bajo de balastos magnéticos.** El motor no tiene un número verificado. Si asume 0.8 y el balasto es 0.5, la corriente real es 60 % mayor y el alternador se sobrecarga aunque los kW "den bien". Medir o pedir placa.
7. **Tie-in.** No hay conector ni protección propia: se trabaja sobre la acometida viva. Riesgos de arco eléctrico, inversión de polaridad, neutro compartido y re-alimentación del generador hacia la red. Solo electricista habilitado, con permiso y bloqueo.
8. **Perú 60 Hz.** El módulo de flicker y el de generador deben usar 60 Hz, no 50. Un equipo de 50 Hz puede girar distinto o parpadear.
9. **El 80 % mal aplicado.** Es para carga continua (≥3 h). Aplicarlo a un flash de 2 minutos es margen desperdiciado; no aplicarlo a una HMI encendida 6 horas es riesgo.
10. **Caída de tensión con R20.** Subestima ~20 %. En un tramo de 50 m a 16 A la diferencia es 12.8 V vs 16.3 V: pasa de "5.5 %, está bien" a "7.1 %, hay que subir sección".
11. **El límite real suele ser la ficha, no el cable.** Un H07RN-F de 6 mm² con Schuko sigue limitado a 16 A por la ficha. La app debe comparar ampacidad de cable **y** del conector, y quedarse con el menor.
12. **Generador sin derating por temperatura.** 40 °C es el knee del alternador; a 45 °C ya pierde 3 % y a 50 °C 6 %. En el altiplano boliviano/peruano la amplitud térmica diaria es grande: el mismo grupo rinde distinto a la mañana y al mediodía.
