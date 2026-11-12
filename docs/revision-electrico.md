# Revisión — Departamento Eléctrico

Fecha: 13/11/2026 · Estado: **implementado y verificado**.

Una pantalla: Electricidad y Energía (red/tie-in, generador, batería).

---

## Lo que estaba mal

1. **La ampacidad del cable se elegía sólo por sección.** Un H07RN-F de 2,5 mm² admite 25 A en
   servicio móvil; un SOOW 14 AWG, con sección parecida, sólo 15 A. La app asumía 20 A para los
   dos. Mezclar cable europeo y americano en un set es habitual, así que la tabla tiene que
   preguntar el tipo.
2. **La tabla terminaba en 10 mm².** Para acometidas (16, 25, 35, 50 mm²) no había dato.
3. **El derating por altura no tenía norma.** Restaba 10 % por cada 1000 m con un piso del 40 %.
   Ese piso *sobreestima* la capacidad real: en un rodaje a 3.000 m la app te decía que tenías
   más corriente de la que hay. En cable, la altura casi no afecta (≤8 % a 3.000 m, IEC/NEC no
   deratean); en el generador, el alternador baja 3 % cada 500 m sobre los 1000 m y 3 % cada
   5 °C sobre los 40 °C.
4. **La caída de tensión se calculaba con la resistencia a 20 °C.** Un conductor en servicio
   está a 70–90 °C: su resistencia sube 20–27 %. La caída real es mayor.
5. **No había trifásico.** Toda acometida de set profesional es trifásica; la pantalla sólo
   hacía monofásico.
6. **El generador se cargaba a mano en amperios.** Ahora se carga en kVA y la app calcula la
   capacidad real según altura y temperatura.
7. **La autonomía de batería ignoraba la profundidad de descarga y el inversor.**
8. **El combustible usaba un coeficiente sin fuente.** Ahora está documentado (0,5 L/kWh a
   gasolina, 0,3 L/kWh a diésel, más 15 % de margen).

## Lo que hace ahora

- **Soporte:** red (110/220/240 V, mono o trifásico, breaker), generador (kVA, altitud,
  temperatura) o batería (14,4/26 V, Wh, límite de descarga).
- **Semáforo** de carga con el porcentaje, el consumo en amperios y la capacidad real del
  soporte. Si es generador, avisa cuánta placa está entregando: 100 kVA a 3.000 m y 40 °C
  entregan 88 kVA (70,4 kW).
- **Cable:** tipo (H07RN-F o SOOW), sección del catálogo completo (1 a 50 mm² / 18 a 2 AWG),
  distancia. Muestra ampacidad de fábrica, ampacidad corregida por temperatura ambiente,
  caída de tensión en volts y porcentaje, y el **cable mínimo necesario** para la carga.
- **Combustible** con el criterio documentado.

## Verificado

- 1000 W a 220 V monofásico: 4,5 A. Con 32 A de breaker, 14 % de carga.
- 2,5 mm² H07RN-F a 30 °C: 25 A. 6000 W (27,3 A) disparan el aviso de peligro térmico.
- 16 A a 50 m con 2,5 mm² y 220 V: 16,3 V de caída a 90 °C, que coincide con la tabla de Prysmian.
- Generador de 100 kVA a 3.000 m: 88 kVA / 70,4 kW.

## Pendientes de decisión

- ¿Querés cargar **el generador en kVA o en kW**? Hoy es kVA; algunos rental lo dicen en kW.
- ¿Agregamos **carga por circuito** (varias luminarias con su potencia) en vez de un único total?
- ¿Sumamos **inrush** (corriente de arranque de HMI/LED) como advertencia al comparar con el breaker?
