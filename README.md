# On Set Pro

Herramientas de cine para dirección de fotografía. Funciona en el teléfono y en la
computadora, sin internet.

## Usar la app

**https://lopezruanocine-sketch.github.io/on-set-pro/**

Abrila desde el teléfono y agregala a la pantalla de inicio para tenerla como una app.

## Qué trae

El menú sigue el flujo de un rodaje, de arriba abajo:

| Departamento | Herramientas |
|---|---|
| Luz y energía | Circuito y reparto por fases, luz solar (hora azul y dorada) |
| Cámara y óptica | Visor con zonas seguras, óptica/FOV, profundidad de campo |
| Imagen y exposición | Sistema de zonas, color y geles, flicker |
| Data y producción | Data y almacenamiento, planes y notas con exportación |
| Utilidades | Calculadora de cine, linterna |

## Cómo está hecho

Flutter. Los motores de cálculo están separados de la interfaz y cubiertos por
pruebas: exposición, óptica, eléctrico, data, color, flicker, solar y reparto de
fases. Se corrige un error en el motor antes de tocar una pantalla.

## Para desarrolladores

```bash
flutter pub get
flutter test          # todas las pruebas
flutter run -d chrome # correr en el navegador
```

Para publicar una versión nueva:

```bash
flutter build web --release --base-href /on-set-pro/
```

El resultado de `build/web` se publica en la rama `gh-pages`.
