---
type: reference
title: Repositorios de Configuración y Seguridad
description: Detalle de repositorios de autenticación JWT, configuración global, API keys y servicios de integración.
tags: [repositories, security, auth, config, api-keys, servin]
timestamp: 2026-10-21T15:45:00Z
---

# Repositorios de Configuración y Seguridad

Esta sección documenta los repositorios de autenticación, integración y ajustes globales:

---

## 1. `AuthRepository` (`auth_repository.dart`)

- **`login(LoginCredentials credentials)`**: Envía credenciales al backend, obtiene el par de tokens (`accessToken` y `refreshToken`) y los persiste cifrados en `HiveTokenStorage`.
- **`logout()`**: Destruye los tokens locales y resetea el estado de sesión.
- **`ensureValidToken()`**: Evalúa la caducidad del token con `TokenManager`. Si restan menos de 10 minutos, ejecuta la rotación mediante `refreshToken` antes de cursar peticiones protegidas.
- **`checkUser()`**: Consulta `/check-user` para confirmar la validez y actividad de la cuenta del usuario.

---

## 2. `AppSettingsRepository` (`app_settings_repository.dart`)
- Parámetros operativos generales del laboratorio (políticas de cobro, tolerancias, datos fiscales).

---

## 3. `ApiKeysRepository` (`api_keys_repository.dart`)
- Gestión de llaves criptográficas API para conexión desatendida de equipos de laboratorio (analizadores automatizados) o APIs externas.

---

## 4. `ServinRepository` (`servin_repository.dart`)
- Monitoreo del estado de servicio y comunicación con la plataforma de integración Servin.
