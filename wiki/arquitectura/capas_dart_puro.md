---
type: concept
title: Arquitectura de Capas en Dart Puro
description: Principios de diseño para mantener serum_business 100% agnóstico de Flutter y portable.
tags: [architecture, pure-dart, separation-of-concerns]
timestamp: 2026-10-21T15:45:00Z
---

# Capas en Dart Puro (`serum_business`)

`serum_business` está diseñado bajo el principio de **separación estricta de responsabilidades** y **pureza de plataforma**.

---

## 🎯 ¿Por qué Dart Puro?

1. **Velocidad de Pruebas:** Las pruebas unitarias corren con el runtime nativo de Dart (`dart test`) en milisegundos sin arrancar el entorno gráfico ni el pipeline de Flutter.
2. **Reutilización Total:** Permite que la misma lógica de negocio, cálculos de laboratorio y modelos sean utilizados tanto en la app de escritorio/móvil Flutter como en:
   - Scripts de importación y utilitarios CLI.
   - Microservicios de sincronización con analizadores clínicos (HL7 / ASTM).
   - Aplicaciones de terminal de mantenimiento.
3. **Estabilidad:** Al no depender de las APIs de widgets ni del árbol de renderizado de Flutter, las actualizaciones de versión de Flutter no rompen la lógica del negocio.

---

## 🏛️ Organización de Capas

```
[ Domain Models ]
   ▲ Entidades inmutables, constructores tipados, serialización JSON
   │
[ Repositories ]
   ▲ Orquestan lógica de negocio, cacheo local y Streams de datos
   │
[ Data Sources ]
   ▲ Encargados de la comunicación HTTP REST contra el backend FastAPI
   │
[ Services & Tools ]
   ▲ HttpService, HiveTokenStorage, TokenManager, NumberFormatter
```

- **Inmutabilidad:** Los modelos promueven constructores constantes y métodos de copia (`copyWith`) para prevenir mutaciones colaterales de estado.
- **Tipado Fuerte:** Toda respuesta JSON es inmediatamente convertida a objetos fuertemente tipados.
