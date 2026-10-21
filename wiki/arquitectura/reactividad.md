---
type: concept
title: Repositorios Reactivos (ReactiveRepository)
description: Patrón de repositorio reactivo mediante Streams de Dart para propagar cambios de estado en tiempo real.
tags: [reactive, streams, repository-pattern]
timestamp: 2026-10-21T15:45:00Z
---

# Patrón `ReactiveRepository`

El componente `ReactiveRepository<T>` ubicado en `lib/src/tools/reactive_repo/` permite que la interfaz de usuario se suscriba a los datos y reaccione inmediatamente a cualquier creación, actualización o eliminación en segundo plano.

---

## ⚡ Funcionamiento

1. **Memoria y Stream:** Mantiene internamente una lista en memoria (`List<T>`) y un `StreamController<List<T>>.broadcast()` (con soporte tipo BehaviorSubject para emitir el estado actual a nuevos suscriptores).
2. **Métodos de Mutación:**
   - `setAll(List<T> items)`: Reemplaza la lista completa e informa a los oyentes.
   - `addOrUpdate(T item)`: Actualiza si ya existe por ID o añade al inicio.
   - `remove(String id)`: Remueve el elemento de memoria y notifica.
3. **Integración con BLoC / Cubits:**
   Los Cubits de la UI pueden suscribirse al `stream` del repositorio:
   ```dart
   _subscription = ordersRepo.stream.listen((orders) {
     emit(OrdersLoaded(orders));
   });
   ```
   Esto elimina la necesidad de recargar manualmente listas completas tras emitir una orden o registrar un cobro.
