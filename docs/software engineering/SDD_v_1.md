**DESCRIPCIÓN DE DISEÑO DEL SOFTWARE**

**Phenomena Atlas**

Sistema de Alerta Temprana del Área Metropolitana de Guadalajara

Conforme a IEEE Std 1016-1998

**Quetzal Soft**

Alejandro Labourdette

Carolina Chi

Dulce Navarro

Edgar Torres

Cliente: CINVESTAV Unidad Guadalajara (IPN)

Última actualización 11 de noviembre de 2026

**Revisiones**

| Fecha      | Nombre del archivo | Baseline                 | Evaluadores |
|------------|--------------------|--------------------------|-------------|
| 11/11/2026 | SDD_v_1.pdf        | v1.0, línea base inicial | Por asignar |

**Contenido**

1\. Introducción 4

> 1.1 Propósito 4
>
> 1.2 Alcance 4
>
> 1.3 Acrónimos y definiciones 4

2\. Referencias 5

3\. Descripción de la descomposición 6

4\. Descripción de dependencias 18

5\. Descripción de interfaces 20

6\. Diseño detallado 24

7\. Trazabilidad con el SRS 30

8\. Decisiones abiertas y riesgos de diseño 33

Anexo A. Modelo 4+1 y diagramas 34

## 1. Introducción

Este documento describe cómo se organizan los módulos, procesos, datos e
interfaces de Phenomena Atlas para cumplir el SRS v1.0 (6/nov/2026)
antes del 11/dic/2026 y sin presupuesto monetario.

### 1.1 Propósito

El SDD es el vínculo entre el SRS y la implementación. El equipo lo usa
para programar y probar, y el CINVESTAV para verificar que el diseño
cubre lo acordado. Sigue la estructura de IEEE Std 1016-1998
(descomposición, dependencias, interfaces y diseño detallado) y toma de
IEEE Std 1016-2009 la razón de diseño y el uso explícito de patrones.

### 1.2 Alcance

El diseño cubre la API (NestJS), la aplicación web (React con TypeScript
y MapLibre GL JS), la base de datos (PostgreSQL con PostGIS), el motor
de cálculo con su planificador y el servicio de notificaciones por
correo. En la primera entrega opera con datos sintéticos.

Esta versión incorpora cuatro decisiones del 11/nov/2026 que cambian el
SRS 1.0 o el SPMP 1.0. Se marcan como **RP** (requisito propuesto) en
todo el documento hasta que el comité de cambios del SPMP 5.3.1 las
apruebe.

| Id  | Requisito propuesto                                                                                                     | Documentos afectados                           |
|-----|-------------------------------------------------------------------------------------------------------------------------|------------------------------------------------|
| RP1 | Cada fenómeno o capa se da de alta con una frecuencia de recálculo elegida entre presets, desde 1 minuto hasta 24 horas | SRS: FR5, FR17, C12, NFR6                      |
| RP2 | La barra temporal recorre un snapshot por día (cada 24 h); los recálculos intradía solo actualizan el estado vigente    | SRS: FR9, FR10                                 |
| RP3 | Se envía como máximo un correo cada 10 minutos por zona, a todo usuario con alertas activas en ella                     | SRS: FR12, NFR6                                |
| RP4 | Telegram queda fuera del alcance por ahora; el único canal fuera de la página es el correo                              | SPMP: 1.1.1, 5.1.3, 6.2 (el SRS ya lo excluye) |

Quedan fuera, como en el SRS: scraping de redes sociales, atención
directa de emergencias, apps móviles, avisos por WhatsApp o SMS y
certificación de potabilidad. Tampoco hay actualización en tiempo real
estricto: con RP1 el intervalo mínimo es de 1 minuto y la web consulta
novedades por sondeo, sin WebSockets.

### 1.3 Acrónimos y definiciones

Los términos del SRS (fenómeno, capa, colonia, índice, nivel de riesgo,
evento, queja, panel) conservan su significado. Este documento agrega
los siguientes.

| Término                 | Definición                                                                                             |
|-------------------------|--------------------------------------------------------------------------------------------------------|
| Frecuencia de recálculo | Intervalo con que el motor recalcula un fenómeno o capa; se elige entre presets al darlo de alta (RP1) |
| Preset                  | Valor predefinido de frecuencia: 1 min, 5 min, 15 min, 1 h o 24 h                                      |
| Recálculo incremental   | Ejecución que procesa solo las colonias con eventos o quejas nuevos desde la ejecución anterior        |
| Recálculo completo      | Ejecución que procesa todas las colonias; aplica el desgaste por antigüedad y cierra el día            |
| Estado vigente          | Último nivel calculado por colonia y capa; es lo que muestra el mapa en el día actual                  |
| Snapshot diario         | Copia del estado vigente al cierre del día; es lo que recorre la barra temporal (RP2)                  |
| Zona                    | Para los avisos, una colonia (supuesto D5, sección 8)                                                  |
| Ventana de envío        | Intervalo de 10 minutos que debe pasar entre dos correos de una misma zona (RP3)                       |
| Filtro                  | Paso del pipeline de cálculo con una entrada y una salida definidas                                    |
| Puerto y adaptador      | Interfaz del dominio (puerto) y su implementación concreta para un proveedor (adaptador)               |
| RP                      | Requisito propuesto, pendiente de aprobación del comité de cambios                                     |

## 2. Referencias

El diseño se apoya en los documentos del proyecto y en las normas y
textos siguientes.

| Documento                                                           | Identificador                                      | Uso en este SDD                                                                      |
|---------------------------------------------------------------------|----------------------------------------------------|--------------------------------------------------------------------------------------|
| Software Requirements Specification, Phenomena Atlas                | SRS v1.0, 6/nov/2026                               | Fuente de los requisitos FR1 a FR18 y NFR1 a NFR15                                   |
| Software Project Management Plan, Phenomena Atlas                   | SPMP v1.0, 4/nov/2026                              | Tecnologías elegidas, riesgos, calendario y plan de pruebas                          |
| IEEE Recommended Practice for Software Design Descriptions          | IEEE Std 1016-1998                                 | Estructura y atributos de las entidades de diseño                                    |
| IEEE Standard for Software Design Descriptions                      | IEEE Std 1016-2009                                 | Razón de diseño y punto de vista de uso de patrones                                  |
| IEEE Recommended Practice for Software Requirements Specifications  | IEEE Std 830-1998                                  | Plantilla del SRS                                                                    |
| IEEE Standard for Software Project Management Plans                 | IEEE Std 1058-1998                                 | Plantilla del SPMP                                                                   |
| Sommerville, I. (2011). Software Engineering, 9.ª ed. Pearson       | Cap. 6                                             | Patrones arquitectónicos: capas, repositorio, cliente–servidor, pipe and filter, MVC |
| Basher, R. (2006). Global early warning systems for natural hazards | Phil. Trans. R. Soc. A, 364                        | Elementos de un sistema de alerta temprana                                           |
| UNDRR (2017). Early warning system                                  | Sendai Framework Terminology                       | Definición de sistema de alerta temprana                                             |
| WMO (2018). Multi-hazard Early Warning Systems: A Checklist         | WMO                                                | Lista de verificación de sistemas multiamenaza                                       |
| W3C (2018). Web Content Accessibility Guidelines 2.1                | WCAG 2.1, nivel AA                                 | NFR3                                                                                 |
| Contrato de la API                                                  | TypeSpec y OpenAPI generado, repositorio de la API | Fuente de verdad de los endpoints (sección 5)                                        |

## 3. Descripción de la descomposición

### 3.1 Razón de diseño

Phenomena Atlas se construye como un monolito modular en capas, con un
motor de cálculo por lotes y avisos por eventos, porque es la opción más
simple que cumple el SRS con cuatro personas, 353 horas y hosting
gratuito.

Cuatro condiciones guían las decisiones:

- **Fenómenos configurables** (FR5, NFR7): agregar un fenómeno no debe
  cambiar el cliente web.

- **Frecuencia distinta por fenómeno** (RP1): desde un recálculo por
  minuto hasta uno diario, sin cambiar de arquitectura.

- **Resultados reproducibles** (NFR12, NFR15): cada nivel guarda la
  versión del método y el origen de sus datos.

- **Proveedores intercambiables** (R7, R11): mapa base, hosting y correo
  siguen sin definirse.

#### Patrones aplicados

| Patrón                                      | Dónde se aplica                                                  | Qué resuelve                                                                             | Contrapartida                                                                              |
|---------------------------------------------|------------------------------------------------------------------|------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------|
| Cliente–servidor                            | SPA React y API NestJS unidas por el contrato TypeSpec y OpenAPI | Separa la web de la API; permite futuros clientes (FR15)                                 | Requiere conexión permanente (SRS 2.4)                                                     |
| Capas                                       | API: controladores, servicios de dominio y repositorios          | Cada capa cambia sin romper las otras; dependency-cruiser lo vigila en CI                | Más archivos; exige no saltarse capas                                                      |
| Pipe and filter                             | Motor de cálculo                                                 | Cada paso se prueba solo; el mismo pipeline sirve al recálculo incremental y al completo | Pensado para lotes, no para respuesta inmediata                                            |
| Strategy y Registry                         | Método de cálculo de cada fenómeno o capa                        | Alta de fenómenos sin tocar el cliente (FR5, NFR7)                                       | Un método nuevo exige código y despliegue de la API (precondición de FR5)                  |
| Repository (datos compartidos)              | PostgreSQL con PostGIS                                           | Fuente única de verdad; los componentes se comunican por la base                         | Punto único de falla; lo cubre NFR13                                                       |
| Observer (eventos de dominio)               | El evento NivelCambió alimenta avisos web y correo               | Canales desacoplados del cálculo                                                         | Un bus en memoria pierde eventos si el proceso cae; la tabla de avisos actúa como respaldo |
| Puertos y adaptadores                       | Correo y mapa base                                               | Cambiar de proveedor sin tocar el dominio (R7, R11)                                      | Una interfaz más por servicio                                                              |
| Lectura y escritura separadas (CQRS ligero) | Entradas (eventos, quejas) frente a niveles precalculados        | El mapa responde sin calcular al consultar (NFR5)                                        | Datos derivados duplicados, reconstruibles desde las entradas                              |
| MVC y componentes                           | Aplicación web                                                   | Vistas, estado y controladores de interfaz separados                                     | Disciplina en el manejo de estado                                                          |

#### Alternativas descartadas

| Alternativa                                       | Por qué se descarta                                                                                                                    |
|---------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------|
| Microservicios                                    | Cuatro personas con experiencia limitada en despliegue (R2) no sostienen varios servicios en hosting gratuito                          |
| Cola de mensajes externa (Kafka, RabbitMQ, Redis) | Agrega infraestructura que el plan gratuito puede no ofrecer; un bus en memoria y tablas en PostgreSQL bastan para el volumen esperado |
| WebSockets o push continuo                        | El SRS excluye el tiempo real estricto; el sondeo cada 1 a 5 minutos cumple NFR6                                                       |
| Event sourcing completo                           | Eventos y quejas inmutables más niveles versionados ya dan reproducibilidad (NFR12) con mucha menos complejidad                        |
| Recálculo al consultar                            | Pondría el costo del cálculo en cada visita y haría imposible cumplir los 500 ms de NFR5                                               |

### 3.2 Descomposición de módulos

La API se divide en 12 módulos NestJS y la web en 5 áreas de pantalla;
cada módulo pertenece a una sola capa y tiene un propósito único.

#### 3.2.1 Subsistema backend (API NestJS)

Capas: **Presentación** (controladores y guardas), **Dominio**
(servicios y métodos de cálculo), **Infraestructura** (repositorios y
adaptadores).

| Módulo               | Capa            | Propósito                                                                                                   | Depende de                                       | Requisitos            |
|----------------------|-----------------|-------------------------------------------------------------------------------------------------------------|--------------------------------------------------|-----------------------|
| AuthModule           | Presentación    | Inicio de sesión del panel, emisión y validación de tokens, guardas por rol                                 | CuentasModule                                    | FR14, NFR10           |
| CuentasModule        | Dominio         | Alta, desactivación y rol de cuentas del panel                                                              | AuditoriaModule                                  | FR14                  |
| ColoniasModule       | Dominio         | Polígonos PostGIS y población de mujeres por colonia                                                        | Repositorio geográfico                           | FR1, FR6              |
| FenomenosModule      | Dominio         | Registro de fenómenos: capas, método, frecuencia (RP1), ponderación versionada, recomendaciones y contactos | AuditoriaModule                                  | FR3 a FR5, FR10, FR17 |
| DatosModule          | Dominio         | Eventos capturados, carga de archivos con validación y generador de datos sintéticos                        | FenomenosModule, ColoniasModule, AuditoriaModule | FR13, FR16            |
| QuejasModule         | Dominio         | Registro anónimo de quejas                                                                                  | FenomenosModule, ColoniasModule                  | FR18                  |
| CalculoModule        | Dominio         | Pipeline de cálculo y métodos Strategy por fenómeno                                                         | FenomenosModule, DatosModule, QuejasModule       | FR6 a FR8, NFR12      |
| PlanificadorModule   | Dominio         | Revisa cada minuto qué capas vencen, evita ejecuciones solapadas y registra cada ejecución                  | CalculoModule, FenomenosModule                   | RP1, NFR13            |
| NivelesModule        | Dominio         | Consultas de solo lectura: niveles del día, serie diaria y detalle de colonia                               | Repositorio de niveles                           | FR2, FR9, FR10, FR15  |
| NotificacionesModule | Dominio         | Avisos web, suscripciones y despachador de correo con ventana de 10 minutos                                 | CorreoPort, FenomenosModule                      | FR11, FR12, RP3       |
| CorreoAdapter        | Infraestructura | Implementa el puerto de correo con el proveedor elegido (por definir)                                       | Proveedor externo                                | FR12                  |
| AuditoriaModule      | Infraestructura | Registro de quién cambió qué y cuándo                                                                       | Repositorio de auditoría                         | FR13, FR14, FR17      |

Un componente transversal adicional, **SaludController**, expone /salud
para monitoreo externo y para despertar el servicio en hosting gratuito
(sección 3.3).

<img src="media/image1.png" style="width:6in;height:3.84821in"
alt="Figura 1 · arquitectura por capas y módulos" />

Figura 1 · arquitectura por capas y módulos

Figura 1. Presentación llama al dominio y el dominio a la
infraestructura; los puertos de correo y de repositorio los define el
dominio y los implementa la infraestructura.

#### 3.2.2 Subsistema frontend (SPA React)

| Área                    | Componentes principales                                                                      | Propósito                                                                     | Consume                       | Requisitos                  |
|-------------------------|----------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------|-------------------------------|-----------------------------|
| Mapa                    | MapaView (MapLibre), LeyendaColonias, AvisoDatosPrueba                                       | Dibuja colonias coloreadas con el degradado o los tres estados de servicio    | Niveles, colonias             | FR1, FR2, NFR3, NFR11       |
| Navegación del fenómeno | IndiceFenomenos, ControlHojasApiladas                                                        | Elegir fenómeno y capa a partir del catálogo, sin conocer fenómenos concretos | Catálogo                      | FR3, FR4, NFR7              |
| Tiempo y detalle        | BarraTemporal, TarjetaColonia                                                                | Recorrer el historial diario y ver nivel, cambio y recomendación              | Serie, detalle                | FR9, FR10                   |
| Avisos y participación  | CentroNotificaciones, FormQueja, FormSuscripcion                                             | Avisos de la sesión, quejas anónimas y suscripción por correo                 | Avisos, quejas, suscripciones | FR11, FR12, FR18            |
| Panel                   | Login, CargaDatos, CapturaEventos, AdminFenomenos (incluye frecuencia), Ponderacion, Cuentas | Trabajo del analista o especialista y del administrador                       | Endpoints del panel           | FR5, FR13, FR14, FR16, FR17 |

La web no contiene lógica de cálculo ni nombres de fenómenos: pinta lo
que declara el catálogo (nombre, icono, capas, tipo de visualización,
leyenda). El cliente de la API se genera desde la definición OpenAPI
para que ambos proyectos compartan la misma versión del contrato.

### 3.3 Descomposición de procesos concurrentes

En el hosting gratuito todo corre en un solo servicio de aplicación más
la base de datos; el planificador, el motor de cálculo y el despachador
de correo son tareas internas de la API que pueden separarse en un
proceso aparte si el plan de hosting lo permite.

| Proceso               | Tipo                          | Disparador                                                                      | Propósito                                                                               | Depende de                |
|-----------------------|-------------------------------|---------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------|---------------------------|
| API HTTP              | Servicio web                  | Peticiones de la web y del panel                                                | Atiende consultas, quejas, suscripciones y panel                                        | Base de datos             |
| Planificador          | Tarea periódica               | Cada 1 minuto                                                                   | Elige las capas vencidas y lanza su recálculo                                           | Base de datos             |
| Motor de cálculo      | Tarea por ejecución           | El planificador, un cambio de ponderación o un disparo manual del administrador | Corre el pipeline en modo incremental o completo                                        | Base de datos             |
| Cierre diario         | Tarea periódica               | 00:00, hora de Guadalajara (D9)                                                 | Recálculo completo de todas las capas y snapshot diario (RP2)                           | Motor de cálculo          |
| Despachador de correo | Tarea periódica               | Cada 1 minuto                                                                   | Revisa las zonas con cambios pendientes cuyo último correo tiene 10 minutos o más (RP3) | Base de datos, CorreoPort |
| Cliente web           | Navegador                     | Sondeo cada 5 minutos o menos                                                   | Consulta avisos nuevos (FR11)                                                           | API HTTP                  |
| Monitor externo       | Servicio gratuito de terceros | Cada pocos minutos                                                              | Hace una petición a /salud para que el servicio no se duerma                            | API HTTP                  |

<img src="media/image2.png" style="width:6in;height:2.58036in"
alt="Figura 2 · despliegue, 1 servicio y 1 base de datos" />

Figura 2 · despliegue, 1 servicio y 1 base de datos

Figura 2. Despliegue previsto; el hosting concreto sigue por definir
(D1).

#### Frecuencia de recálculo por fenómeno (RP1)

El administrador elige un preset al dar de alta un fenómeno o capa y
puede cambiarlo después; el cambio rige desde la siguiente ejecución. El
predeterminado es 24 horas, que reproduce el comportamiento del SRS 1.0.

| Preset                | Intervalo | Qué corre en cada vencimiento             |
|-----------------------|-----------|-------------------------------------------|
| 1 min                 | 60 s      | Recálculo incremental                     |
| 5 min                 | 300 s     | Recálculo incremental                     |
| 15 min                | 900 s     | Recálculo incremental                     |
| 1 h                   | 3600 s    | Recálculo incremental                     |
| 24 h (predeterminado) | 86 400 s  | Solo el cierre diario: recálculo completo |

La lista de presets vive en el código de la API y se expone en el
catálogo; agregar un preset no cambia el cliente.

#### Reglas de concurrencia

1.  **Una ejecución por capa a la vez.** El motor toma un bloqueo asesor
    de PostgreSQL por capa; si no lo obtiene, registra la ejecución como
    OMITIDA y el planificador reintenta en el siguiente minuto.

2.  **El planificador no depende de haber estado despierto.** Cada capa
    guarda su proxima_ejecucion; en cada tick se ejecutan todas las
    vencidas. Si el hosting gratuito duerme el servicio, al despertar se
    recupera con una sola ejecución por capa, no una por cada intervalo
    perdido.

3.  **El cierre diario tiene prioridad.** Si coincide con un incremental
    de la misma capa, espera a que termine y luego corre.

4.  **Fallo no destruye datos.** Si una ejecución falla, el estado
    vigente anterior se conserva y el mapa muestra su fecha (NFR13).

### 3.4 Descomposición de datos

El modelo es relacional en PostgreSQL con PostGIS: las entradas (eventos
y quejas) son inmutables y los niveles son datos derivados que se pueden
reconstruir, lo que permite reproducir cualquier cálculo (NFR12).

| Entidad                   | Propósito                                        | Atributos clave                                                                                                                                                                       | Relaciones                                  |
|---------------------------|--------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------|
| colonia                   | Unidad del mapa                                  | id, clave, nombre, municipio, geometría MultiPolygon SRID 4326 con índice GIST, población de mujeres                                                                                  | Referenciada por eventos, quejas y niveles  |
| fenomeno                  | Catálogo de fenómenos                            | id, slug, nombre, icono, descripción, activo                                                                                                                                          | 1:N capa                                    |
| capa                      | Vista de cálculo dentro de un fenómeno           | id, slug, nombre, tipo_visualizacion (DEGRADADO o ESTADO_SERVICIO), predeterminada, metodo_calculo (clave del Strategy), frecuencia_preset (RP1), proxima_ejecucion, ultima_ejecucion | N:1 fenomeno; 1:N configuracion_ponderacion |
| tipo_evento               | Tipos de hecho y su gravedad                     | id, capa_id, nombre, gravedad                                                                                                                                                         | N:1 capa                                    |
| configuracion_ponderacion | Versión de pesos, umbrales y techo del degradado | id, capa_id, version, pesos_antiguedad, umbral_medio, umbral_alto, techo_indice, reglas_estado, creada_por, creada_en, vigente                                                        | N:1 capa                                    |
| recomendacion             | Texto y contactos por capa y nivel               | id, capa_id, nivel o estado, texto, medios_contacto                                                                                                                                   | N:1 capa                                    |
| evento                    | Hecho registrado                                 | id, capa_id, colonia_id, tipo_evento_id, ocurrido_en, origen (SINTETICO o CAPTURA), carga_id                                                                                          | N:1 colonia, capa, carga_datos              |
| queja                     | Reporte anónimo                                  | id, capa_id, colonia_id, descripcion, creada_en, origen = QUEJA                                                                                                                       | N:1 colonia, capa                           |
| carga_datos               | Lote de datos cargado                            | id, cuenta_id, creada_en, es_sintetico, semilla                                                                                                                                       | 1:N evento                                  |
| ejecucion_calculo         | Registro de cada corrida del motor               | id, capa_id, modo (INCREMENTAL o COMPLETO), estado, iniciada_en, terminada_en, colonias_procesadas, cambios_de_nivel, error                                                           | N:1 capa                                    |
| nivel_vigente             | Estado actual por colonia y capa                 | colonia_id, capa_id (clave), indice, nivel o estado_servicio, calculado_en, ejecucion_id, ponderacion_id                                                                              | N:1 colonia, capa                           |
| nivel_diario              | Snapshot de cierre del día (RP2)                 | colonia_id, capa_id, fecha (clave), indice, nivel o estado_servicio, variacion, rellenado, ejecucion_id, ponderacion_id                                                               | N:1 colonia, capa                           |
| aviso                     | Cambio de nivel detectado                        | id, ejecucion_id, colonia_id, capa_id, nivel_anterior, nivel_nuevo, creado_en, recomendacion                                                                                          | Consultado por la web; origen del correo    |
| suscriptor                | Persona suscrita por correo                      | id, correo_cifrado, correo_hash, estado (PENDIENTE o ACTIVA), tokens de confirmación y baja, aviso_privacidad_aceptado_en                                                             | 1:N suscripcion                             |
| suscripcion               | Preferencia de aviso                             | suscriptor_id, colonia_id, capa_id                                                                                                                                                    | N:1 suscriptor, colonia, capa               |
| envio_correo              | Registro de cada envío, sin contenido            | id, colonia_id, enviado_en, destinatarios, estado                                                                                                                                     | Controla la ventana de 10 minutos           |
| cuenta_panel              | Cuenta del panel                                 | id, correo, hash_contraseña, rol (ANALISTA o ADMIN), activa                                                                                                                           | 1:N auditoria                               |
| auditoria                 | Bitácora de cambios                              | id, cuenta_id, accion, entidad, antes, después, fecha                                                                                                                                 | N:1 cuenta_panel                            |

<img src="media/image3.png" style="width:6in;height:4.32143in"
alt="Figura 3 · modelo de datos, capa y colonia como ejes" />

Figura 3 · modelo de datos, capa y colonia como ejes

Figura 3. Vista parcial del modelo: las tablas de notificación, carga y
cuentas se describen en la sección 3.4.

#### Decisiones de datos

- **Estado vigente y snapshot diario son tablas distintas** (RP2). Los
  recálculos intradía solo escriben nivel_vigente; el cierre diario
  copia ese estado a nivel_diario. La barra temporal lee solo
  nivel_diario, de modo que cada paso sigue siendo un día (FR9).

- **Reproducibilidad.** Cada fila de nivel guarda ejecucion_id y
  ponderacion_id; una ponderación nunca se edita, se crea una versión
  nueva (NFR12).

- **Origen del dato.** Todo evento y queja guarda su origen; los datos
  sintéticos se marcan siempre como datos de prueba (NFR11, NFR15).

- **Privacidad.** Ninguna tabla guarda nombres, teléfonos, direcciones
  ni IP de quejas (NFR8). El correo del suscriptor se guarda cifrado,
  con un hash aparte para buscarlo, y se borra al darse de baja (NFR9).

- **Geometría.** Se sirve una versión simplificada de los polígonos para
  el mapa (ST_SimplifyPreserveTopology) y se conserva la original para
  cálculos espaciales.

### 3.5 Descomposición del modelo de estados

Tres objetos tienen ciclo de vida propio: la ejecución de cálculo, la
suscripción por correo y la ventana de envío de cada zona.

#### 3.5.1 Ejecución de cálculo

| Estado     | Descripción                                                 | Transición                                                                               |
|------------|-------------------------------------------------------------|------------------------------------------------------------------------------------------|
| PROGRAMADA | La capa venció y el planificador la eligió                  | A EN_CURSO si obtiene el bloqueo de la capa; a OMITIDA si no                             |
| EN_CURSO   | El pipeline está procesando colonias                        | A COMPLETADA si termina; a FALLIDA si un filtro lanza un error                           |
| COMPLETADA | Se guardaron niveles, avisos y versión del método. Terminal | Actualiza ultima_ejecucion y proxima_ejecucion                                           |
| FALLIDA    | Error no recuperable. Terminal                              | Se conserva el estado vigente anterior (NFR13); se reintenta en el siguiente vencimiento |
| OMITIDA    | Otra ejecución de la misma capa estaba en curso. Terminal   | El planificador reintenta en el siguiente minuto                                         |

#### 3.5.2 Suscripción por correo

| Estado    | Descripción                                              | Transición                                                   |
|-----------|----------------------------------------------------------|--------------------------------------------------------------|
| PENDIENTE | Se guardó el correo y se envió el enlace de confirmación | A ACTIVA al abrir el enlace; se descarta si el enlace caduca |
| ACTIVA    | Recibe avisos de las colonias y capas elegidas           | A BAJA al usar el enlace de baja                             |
| BAJA      | Se borran el correo y las preferencias (NFR9). Terminal  | Ninguna                                                      |

#### 3.5.3 Ventana de envío por zona (RP3)

| Estado         | Descripción                                                                                      | Transición                                                            |
|----------------|--------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------|
| SIN_PENDIENTES | No hay cambios de nivel por avisar                                                               | A ACUMULANDO cuando el motor crea un aviso para la zona               |
| ACUMULANDO     | Hay cambios; el último correo de la zona fue hace menos de 10 minutos                            | A ENVIANDO cuando se cumplen 10 minutos desde envio_correo.enviado_en |
| ENVIANDO       | El despachador manda un correo con el estado vigente a todos los suscriptores activos de la zona | A ENFRIAMIENTO al registrar el envío                                  |
| ENFRIAMIENTO   | Se registró el envío; la zona no puede enviar durante 10 minutos                                 | A SIN_PENDIENTES si no llegaron cambios; a ACUMULANDO si llegaron     |

Si una zona queda sin cambios netos (subió y volvió a bajar dentro de la
ventana), el despachador no envía correo.

<img src="media/image4.png" style="width:6in;height:2.49107in"
alt="Figura 4 · estados de la ventana de envío, 4 estados" />

Figura 4 · estados de la ventana de envío, 4 estados

Figura 4. Cada zona tiene su propia ventana de 10 minutos; el correo
sale a todos los suscriptores activos de esa zona (RP3).

### 3.6 Descomposición en casos de uso

Se conservan los 15 casos de uso del SRS (C1 a C15), tres cambian por
los requisitos propuestos (C4, C10 y C12) y se agregan dos del sistema
(C16 y C17).

| Código  | Caso de uso                                                                                                                            | Actor                            | Cambio                                                                                     |
|---------|----------------------------------------------------------------------------------------------------------------------------------------|----------------------------------|--------------------------------------------------------------------------------------------|
| C1 a C9 | Consultar mapa, cambiar fenómeno y capa, recorrer historial, ver detalle, aviso en la página, suscribirse, darse de baja, cargar datos | Usuario, analista o especialista | Sin cambio, salvo C4, que recorre nivel_diario (RP2)                                       |
| C10     | Agregar fenómeno o capa                                                                                                                | Administrador                    | Ahora incluye elegir el preset de frecuencia (RP1)                                         |
| C11     | Gestionar cuentas del panel                                                                                                            | Administrador                    | Sin cambio                                                                                 |
| C12     | Recalcular niveles                                                                                                                     | Sistema                          | Ahora se dispara según la frecuencia de cada capa y puede ser incremental o completo (RP1) |
| C13     | Generar los datos                                                                                                                      | Analista o especialista          | Sin cambio                                                                                 |
| C14     | Configurar la ponderación                                                                                                              | Administrador                    | Sin cambio; la nueva versión provoca un recálculo completo                                 |
| C15     | Enviar queja                                                                                                                           | Usuario                          | Sin cambio                                                                                 |
| C16     | Despachar correos por zona                                                                                                             | Sistema                          | Nuevo (RP3). Respeta la ventana de 10 minutos                                              |
| C17     | Cerrar el día                                                                                                                          | Sistema                          | Nuevo (RP2). Recálculo completo y snapshot diario a las 00:00                              |

La Figura 5 muestra los casos de uso por actor.

<img src="media/image5.png" style="width:6in;height:4.38393in"
alt="Figura 5 · casos de uso, 4 actores" />

Figura 5 · casos de uso, 4 actores

Figura 5. Casos de uso del SRS más C16 y C17, agrupados por actor.

## 4. Descripción de dependencias

Las dependencias van siempre hacia abajo (presentación, dominio,
infraestructura) y se comprueban en CI con dependency-cruiser; esto
permite evaluar el impacto de un cambio antes de hacerlo.

### 4.1 Dependencias entre módulos

Reglas que la integración continua hace cumplir:

1.  Un controlador solo llama a servicios de su propio módulo o a
    puertos del dominio; nunca a repositorios.

2.  El dominio no importa nada de NestJS, de la base de datos ni de
    proveedores externos; solo define puertos.

3.  Ningún módulo importa a CalculoModule salvo PlanificadorModule; los
    métodos de cálculo no se llaman desde controladores.

4.  NivelesModule solo lee: no escribe en nivel_vigente ni en
    nivel_diario.

5.  NotificacionesModule reacciona a eventos de dominio y no conoce al
    motor de cálculo.

La columna "Depende de" de la sección 3.2.1 es el grafo permitido;
cualquier otra importación falla la verificación.

### 4.2 Dependencias entre procesos

| Proceso                                     | Necesita de                                         | Si no está disponible                                                                        |
|---------------------------------------------|-----------------------------------------------------|----------------------------------------------------------------------------------------------|
| Planificador                                | Base de datos                                       | No hay recálculos; el mapa conserva el último estado y su fecha (NFR13)                      |
| Motor de cálculo                            | Planificador, datos de entrada, ponderación vigente | La ejecución queda FALLIDA u OMITIDA y se reintenta en el siguiente vencimiento              |
| Despachador de correo                       | Avisos pendientes, puerto de correo                 | Los avisos se acumulan y salen en la siguiente ventana; el aviso en la página no se afecta   |
| Cierre diario                               | Motor de cálculo                                    | Falta el snapshot de ese día; la barra muestra el último disponible y se reintenta el cierre |
| Cliente web                                 | API HTTP                                            | El mapa no carga; se muestra el último dato en caché del navegador con su fecha, si existe   |
| Servicio de correo y proveedor de mapa base | Disponibilidad del tercero                          | Dependencia externa declarada en el SRS 2.4 y 2.5                                            |

### 4.3 Dependencias de datos

| Tabla                                      | Escribe                                       | Lee                                                              |
|--------------------------------------------|-----------------------------------------------|------------------------------------------------------------------|
| colonia                                    | Carga inicial de límites                      | ColoniasModule, CalculoModule, NivelesModule                     |
| fenomeno, capa, tipo_evento, recomendacion | FenomenosModule (administrador)               | CalculoModule, NivelesModule, NotificacionesModule, planificador |
| configuracion_ponderacion                  | FenomenosModule (administrador)               | CalculoModule                                                    |
| evento, carga_datos                        | DatosModule (analista o generador)            | CalculoModule                                                    |
| queja                                      | QuejasModule (público)                        | CalculoModule                                                    |
| ejecucion_calculo                          | PlanificadorModule                            | Panel (estado de ejecuciones)                                    |
| nivel_vigente                              | CalculoModule                                 | NivelesModule, NotificacionesModule                              |
| nivel_diario                               | CalculoModule (solo cierre diario)            | NivelesModule                                                    |
| aviso                                      | NotificacionesModule (al recibir NivelCambió) | NotificacionesModule, web (sondeo)                               |
| suscriptor, suscripcion                    | NotificacionesModule                          | NotificacionesModule                                             |
| envio_correo                               | Despachador de correo                         | Despachador de correo                                            |
| cuenta_panel, auditoria                    | CuentasModule, AuditoriaModule                | AuthModule, panel                                                |

## 5. Descripción de interfaces

Hay tres interfaces: la API REST entre la web y el sistema, los puertos
internos del dominio y las conexiones con servicios externos. Los
endpoints de esta sección son una propuesta derivada del SRS; la fuente
de verdad será el contrato TypeSpec del repositorio de la API, y
cualquier diferencia se corrige en este documento.

### 5.1 API REST

Convenciones: HTTPS, JSON en UTF-8, ruta versionada /v1, fechas de día
como AAAA-MM-DD en hora de Guadalajara, instantes como ISO 8601 en UTC,
y errores como application/problem+json (RFC 9457). El panel usa token
Bearer y rol; la zona pública solo devuelve cifras agregadas por colonia
(FR15, NFR8).

#### 5.1.1 Endpoints públicos

| Método | Ruta                        | Entrada                                           | Salida                                                                          | Requisitos      |
|--------|-----------------------------|---------------------------------------------------|---------------------------------------------------------------------------------|-----------------|
| GET    | /v1/fenomenos               | Ninguna                                           | Fenómenos con capas, tipo de visualización, leyenda y etiqueta de actualización | FR3 a FR5, NFR7 |
| GET    | /v1/colonias                | Ninguna                                           | GeoJSON simplificado de las colonias                                            | FR1             |
| GET    | /v1/niveles                 | capa, fecha (opcional; sin fecha, estado vigente) | Nivel o estado de cada colonia                                                  | FR2, FR15       |
| GET    | /v1/niveles/serie           | capa, desde, hasta                                | Snapshots diarios de cada colonia                                               | FR9, RP2        |
| GET    | /v1/colonias/{id}/detalle   | capa, fecha                                       | Nivel, índice, cambio, fecha de cálculo, recomendación y contactos              | FR10            |
| GET    | /v1/avisos                  | desde (instante)                                  | Avisos nuevos desde ese instante                                                | FR11            |
| POST   | /v1/quejas                  | capa, colonia, descripcion                        | 201 y los medios de reporte del fenómeno                                        | FR18            |
| POST   | /v1/suscripciones           | correo, colonias, capas, avisoPrivacidad = true   | 202; envía el enlace de confirmación                                            | FR12            |
| GET    | /v1/suscripciones/confirmar | token                                             | 200; la suscripción pasa a ACTIVA                                               | FR12            |
| POST   | /v1/suscripciones/baja      | token                                             | 204; borra correo y preferencias                                                | FR12, NFR9      |
| GET    | /salud                      | Ninguna                                           | Estado, versión y fecha del último cálculo                                      | NFR13           |

#### 5.1.2 Endpoints del panel

| Método           | Ruta                                  | Rol                     | Propósito                                                                        | Requisitos |
|------------------|---------------------------------------|-------------------------|----------------------------------------------------------------------------------|------------|
| POST             | /v1/panel/sesiones                    | Ninguno                 | Inicio de sesión; devuelve token, rol y vencimiento                              | NFR10      |
| POST             | /v1/panel/eventos                     | Analista, administrador | Captura un evento                                                                | FR13       |
| POST             | /v1/panel/cargas                      | Analista, administrador | Carga un archivo; rechaza registros con colonia, fecha o tipo inválidos          | FR13       |
| POST             | /v1/panel/sinteticos                  | Analista, administrador | Genera datos sintéticos con semilla fija                                         | FR16       |
| GET, POST, PUT   | /v1/panel/fenomenos y /v1/panel/capas | Administrador           | Alta y edición de fenómenos y capas, con recomendaciones y contactos             | FR5, FR10  |
| PUT              | /v1/panel/capas/{id}/frecuencia       | Administrador           | Cambia el preset de frecuencia                                                   | RP1        |
| POST             | /v1/panel/capas/{id}/ponderaciones    | Administrador           | Crea una versión nueva de pesos, umbrales y techo; dispara un recálculo completo | FR17       |
| POST             | /v1/panel/capas/{id}/recalculos       | Administrador           | Dispara un recálculo manual (propuesto, útil para pruebas)                       | RP1        |
| GET              | /v1/panel/ejecuciones                 | Analista, administrador | Estado de las últimas ejecuciones                                                | NFR13      |
| GET, POST, PATCH | /v1/panel/cuentas                     | Administrador           | Gestión de cuentas y roles                                                       | FR14       |

#### 5.1.3 Formatos de ejemplo

Catálogo de fenómenos. actualizacion es la etiqueta del preset y la web
la muestra junto a la fecha del último cálculo (NFR1).

{  
"fenomenos": \[{  
"slug": "agua", "nombre": "Agua", "icono": "agua",  
"capas": \[{  
"slug": "calidad", "nombre": "Calidad del agua",  
"visualizacion": "DEGRADADO", "predeterminada": true,  
"actualizacion": "24 h"  
}\]  
}\]  
}

Niveles de una capa con degradado. En una capa ESTADO_SERVICIO cada
colonia trae estado (CON_SERVICIO, INTERMITENTE o SIN_SERVICIO) en lugar
de indice y nivel.

{  
"capa": "calidad", "fecha": "2026-12-01",  
"calculadoEn": "2026-12-01T18:42:00Z",  
"origenDatos": \["SINTETICO", "QUEJA"\],  
"versionMetodo": "3",  
"colonias": \[{ "id": "07-C", "indice": 0.62, "nivel": "ALTO",
"variacion": "SUBE" }\]  
}

### 5.2 Puertos internos del dominio

Tres interfaces aislan al dominio de la infraestructura.

// Strategy: función pura, sin acceso a base de datos ni a red.  
interface MetodoCalculo {  
clave: string; // p. ej. 'indice-ponderado', 'estado-por-conteo'  
version: string;  
calcular(entrada: EntradaColonia\[\], ponderacion: Ponderacion):
ResultadoColonia\[\];  
}  
  
// Puerto de correo: el adaptador depende del proveedor elegido.  
interface ServicioCorreo {  
enviarLote(mensajes: MensajeCorreo\[\]):
Promise\<ResultadoEnvio\[\]\>;  
}  
  
// Evento de dominio que alimenta los avisos.  
interface NivelCambio {  
ejecucionId: string; coloniaId: string; capaId: string;  
anterior: Nivel; nuevo: Nivel; calculadoEn: string;  
}

Cada MensajeCorreo lleva un solo destinatario y su propio enlace de
baja, de modo que el lote respeta la privacidad de los suscriptores.

### 5.3 Interfaces externas

| Servicio            | Interfaz                                                             | Estado        | Aislamiento                                                       |
|---------------------|----------------------------------------------------------------------|---------------|-------------------------------------------------------------------|
| Mapa base           | URL de estilo configurable que consume MapLibre GL JS                | En evaluación | Variable de entorno; la API no depende de él (R7)                 |
| Correo              | Adaptador del puerto ServicioCorreo (SMTP o API)                     | Por elegir    | Un adaptador por proveedor (R11)                                  |
| Hosting             | Servicio de aplicación y base de datos con plan gratuito o académico | Por definir   | Contenedor y variables de entorno; sin APIs propias del proveedor |
| Límites de colonias | Carga única hacia PostGIS                                            | Por confirmar | Se carga con un script; no hay dependencia en tiempo de ejecución |

## 6. Diseño detallado

Esta sección detalla las tres piezas de mayor riesgo: el pipeline de
cálculo, el planificador por frecuencia y la regla de avisos por correo;
después cubre seguridad, controladores y degradación.

### 6.1 Pipeline de cálculo

El pipeline tiene nueve filtros. El mismo código sirve al recálculo
incremental y al completo; solo cambia el primer filtro.

| N.º | Filtro               | Entrada                      | Salida                                                                                             |
|-----|----------------------|------------------------------|----------------------------------------------------------------------------------------------------|
| 1   | Seleccionar colonias | Capa, modo, ultima_ejecucion | Incremental: colonias con eventos o quejas creados después de la última ejecución. Completo: todas |
| 2   | Leer registros       | Colonias                     | Eventos y quejas dentro de la ventana útil de la ponderación                                       |
| 3   | Ponderar             | Registros                    | Peso de cada registro: gravedad del tipo por peso de su antigüedad (FR17)                          |
| 4   | Normalizar           | Pesos                        | Cantidad por cada 10 000 mujeres si la capa lo declara (FR6)                                       |
| 5   | Calcular             | Valores                      | Índice o estado de servicio, mediante el método Strategy de la capa                                |
| 6   | Clasificar           | Índice                       | Nivel bajo, medio o alto según los umbrales vigentes                                               |
| 7   | Comparar             | Resultado y nivel_vigente    | Lista de cambios de nivel                                                                          |
| 8   | Persistir            | Resultados                   | nivel_vigente, ejecucion_calculo con versión del método y de la ponderación (NFR12)                |
| 9   | Emitir               | Cambios                      | Un evento NivelCambió por cambio                                                                   |

Los filtros 8 y 9 corren en una sola transacción. El evento se despacha
de forma síncrona dentro de ella y su manejador inserta el aviso, de
modo que no puede haber un nivel cambiado sin su aviso ni un aviso sin
su nivel.

<img src="media/image6.png" style="width:6in;height:3.15178in"
alt="Figura 6 · pipeline de cálculo, 9 filtros" />

Figura 6 · pipeline de cálculo, 9 filtros

Figura 6. El modo incremental y el completo comparten los filtros 2 a 9;
solo cambia qué colonias selecciona el filtro 1.

FUNCIÓN ejecutarCalculo(capa, modo):  
1. SI no obtengo el bloqueo de la capa:  
registrar ejecución OMITIDA; RETORNAR  
2. ejecucion ← crear EN_CURSO(capa, modo)  
3. pond ← ponderación vigente de la capa  
4. colonias ← seleccionar(capa, modo, capa.ultima_ejecucion)  
5. PARA CADA lote DE colonias (tamaño propuesto: 200):  
entrada ← leerRegistros(lote, pond.ventana)  
resultado ← metodoDe(capa).calcular(entrada, pond)  
cambios += comparar(nivelVigente(lote), resultado)  
6. TRANSACCIÓN:  
guardar nivel_vigente(resultados, ejecucion, pond)  
PARA CADA cambio: publicar NivelCambió(cambio)  
ejecucion ← COMPLETADA  
capa.ultima_ejecucion ← ahora  
capa.proxima_ejecucion ← ahora + intervalo(capa.frecuencia_preset)  
7. ANTE ERROR: revertir; ejecucion ← FALLIDA; conservar nivel_vigente

### 6.2 Planificador y cierre diario

El planificador se despierta cada minuto, elige las capas vencidas y
lanza su recálculo incremental; las capas de 24 h no corren
incrementales y solo se actualizan en el cierre diario.

CADA 60 s:  
vencidas ← capas activas CON proxima_ejecucion ≤ ahora  
Y frecuencia_preset ≠ 24 h, ordenadas por proxima_ejecucion  
PARA CADA capa EN vencidas:  
lanzar ejecutarCalculo(capa, INCREMENTAL) // sin esperar su término  
SI falta el cierre de ayer EN alguna capa: // el servicio estuvo
dormido  
ejecutar cierreDiario(capa)  
  
A LAS 00:00 (America/Mexico_City), PARA CADA capa activa:  
cierreDiario(capa):  
1. copiar nivel_vigente → nivel_diario con fecha = día que cierra  
2. calcular variacion contra el snapshot del día anterior  
3. ejecutarCalculo(capa, COMPLETO) // aplica el desgaste por antigüedad

El snapshot se toma antes del recálculo completo, así que guarda el
último estado del día que termina. La consulta de la serie agrega el
estado vigente como el punto de hoy, marcado "en curso", para que la
barra temporal siempre llegue al día actual. Si el servicio durmió
varios días, los días sin cálculo se rellenan con el último valor
conocido y se marcan como rellenados; no se muestra gris (SRS FR2).

<img src="media/image7.png" style="width:6in;height:3.375in"
alt="Figura 7 · secuencia de recalcular, 4 participantes" />

Figura 7 · secuencia de recalcular, 4 participantes

Figura 7. Secuencia de recalcular el índice de una capa en modo
incremental.

### 6.3 Cálculo del índice y del nivel

El índice de una colonia es la suma de los pesos de sus registros,
dividida entre su población cuando la capa lo pide, y se lleva a una
escala de 0 a 1 para colorear.

I_c = \frac{1}{P_c / 10000} \sum\_{r \in R_c} g(r) \cdot
w\bigl(a(r)\bigr)  
\qquad  
\hat{I}\_c = \min\left(1, \frac{I_c}{T}\right)

- **R_c**: eventos y quejas de la colonia dentro de la ventana útil.

- **g(r)**: gravedad del tipo de registro; las quejas tienen su propia
  gravedad configurable.

- **w(a)**: peso según la antigüedad *a* en días, por tramos que define
  el administrador (FR17).

- **P_c**: población base de la colonia. Violencia de género usa mujeres
  (FR6); la calidad del agua no normaliza (FR7), y para ella el divisor
  vale 1.

- **T**: techo del índice, parámetro de la ponderación que fija qué
  valor se pinta como rojo pleno (D7, sección 8).

El nivel sale de comparar Î con dos umbrales: bajo si Î \< umbral medio,
medio si está entre ambos, alto si Î ≥ umbral alto. El color es una
interpolación continua verde, amarillo, rojo sobre Î, idéntica para
todos los fenómenos (FR2).

La capa Disponibilidad de agua usa otro método: suma los pesos de los
eventos y quejas de disponibilidad dentro de su ventana y compara con
dos umbrales del administrador. Hasta el primero la colonia está
CON_SERVICIO, entre ambos INTERMITENTE y desde el segundo SIN_SERVICIO
(FR8).

### 6.4 Avisos en la página y por correo

**En la página (FR11).** El manejador de NivelCambió inserta una fila en
aviso. La web consulta /v1/avisos?desde= cada 60 segundos mientras la
pestaña está visible y nunca con más de 5 minutos de separación. El
centro de notificaciones guarda los avisos de la sesión y, al pulsar
uno, el mapa abre el fenómeno, la capa y la colonia.

**Por correo (FR12, RP3).** El despachador corre cada minuto y envía
como máximo un correo cada 10 minutos por zona, a todos los suscriptores
activos de esa zona.

CADA 60 s:  
PARA CADA colonia CON avisos sin atender:  
ultimo ← MAX(enviado_en) en envio_correo DE la colonia  
SI ultimo es nulo O (ahora − ultimo) ≥ 10 min:  
cambios ← cambio neto por capa: nivel_anterior del aviso más antiguo  
contra nivel_nuevo del aviso más reciente  
descartar las capas cuyo cambio neto es nulo  
SI quedan cambios:  
destinatarios ← suscriptores ACTIVOS con preferencia en  
(colonia, alguna de las capas con cambio)  
mensajes ← un mensaje por destinatario, con fenómeno, colonia,  
nivel anterior y nuevo, fecha, recomendación con contactos,  
enlace al mapa, enlace de baja y, si aplica,  
la aclaración de datos de prueba  
resultado ← ServicioCorreo.enviarLote(mensajes)  
registrar envio_correo(colonia, ahora, número de destinatarios)  
marcar los avisos de la colonia como atendidos

En el peor caso un aviso aparece justo después de un envío: espera 10
minutos, más hasta 1 minuto del siguiente ciclo del despachador, más el
tiempo del proveedor. Eso cumple los 15 minutos de NFR6 mientras el
proveedor entregue en menos de 4 minutos (riesgo RD5, sección 8). El
registro envio_correo no guarda el contenido del mensaje (FR12).

<img src="media/image8.png" style="width:6in;height:3.625in"
alt="Figura 8 · secuencia de enviar la notificación, 4 participantes" />

Figura 8 · secuencia de enviar la notificación, 4 participantes

Figura 8. Secuencia de enviar la notificación de una zona cuando se
cumple la ventana de 10 minutos.

### 6.5 Seguridad y privacidad

| Tema                    | Diseño                                                                                                                                                                 | Requisito        |
|-------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------|
| Autenticación del panel | Token firmado con vencimiento; el rol viaja en el token                                                                                                                | NFR10            |
| Autorización            | Guarda de rol en cada ruta de /v1/panel; lo no declarado se niega por defecto                                                                                          | NFR10, FR14      |
| Contraseñas             | Se guarda solo un hash con algoritmo lento (argon2 o bcrypt, por confirmar)                                                                                            | NFR10            |
| Transporte              | HTTPS en todo el tráfico; CORS limitado al origen de la web                                                                                                            | NFR10            |
| Quejas anónimas         | No se guarda IP, agente ni identificadores; el límite de frecuencia usa la IP solo en memoria y sin persistirla; sin adjuntos                                          | FR18, NFR8       |
| Suscriptores            | Correo cifrado en reposo (AES-256-GCM, clave en variable de entorno) y hash HMAC aparte para buscarlo; tokens aleatorios de un solo uso para confirmar y darse de baja | NFR9             |
| API pública             | Solo cifras por colonia; nunca el texto de una queja ni datos de personas                                                                                              | FR15, NFR8       |
| Auditoría               | Se registran cargas, cambios de ponderación, de frecuencia y de cuentas, con autor y fecha                                                                             | FR13, FR14, FR17 |
| Datos de prueba         | Marcados en la base, en el mapa y en cada correo                                                                                                                       | NFR11, NFR15     |

### 6.6 Diseño de controladores

Los controladores solo validan, llaman al servicio y arman la respuesta.
Dos ejemplos.

FUNCIÓN registrarQueja(solicitud):  
1. VALIDAR que la capa y la colonia existan y la capa esté activa  
2. VALIDAR descripción no vacía y de longitud máxima por definir
(propuesta: 1000)  
3. SI se excedió el límite de frecuencia: RETORNAR 429  
4. GUARDAR queja(capa, colonia, descripcion, ahora, origen = QUEJA) //
sin IP  
5. RETORNAR 201 con los medios de reporte o ayuda de la capa (FR10)  
  
FUNCIÓN cambiarFrecuencia(capaId, preset):  
1. EXIGIR rol ADMIN; en otro caso RETORNAR 403  
2. VALIDAR que preset pertenezca a la lista; en otro caso RETORNAR 400  
3. capa.frecuencia_preset ← preset  
capa.proxima_ejecucion ← MIN(proxima actual, ahora +
intervalo(preset))  
4. REGISTRAR auditoría(antes, después)  
5. RETORNAR 200

El alta de un fenómeno (FR5) exige además que su metodo_calculo exista
en el registro de la API; si no, responde 422. Crea la capa con la
frecuencia de 24 h, la ponderación versión 1 y una recomendación por
nivel.

<img src="media/image9.png" style="width:6in;height:3.375in"
alt="Figura 9 · secuencia de registrar una queja, 4 participantes" />

Figura 9 · secuencia de registrar una queja, 4 participantes

Figura 9. Secuencia de registrar una queja anónima (FR18).

### 6.7 Degradación y manejo de fallos

| Falla                                             | Comportamiento                                                                                               | Requisito |
|---------------------------------------------------|--------------------------------------------------------------------------------------------------------------|-----------|
| El recálculo falla                                | Se conserva el estado vigente; el mapa muestra su fecha de cálculo; se reintenta en el siguiente vencimiento | NFR13     |
| El servicio estuvo dormido                        | El planificador recupera con una ejecución por capa y cierra los días pendientes                             | RP1, RP2  |
| El proveedor de correo rechaza o se agota su plan | El lote queda diferido y se reintenta en el siguiente ciclo; el aviso en la página no se afecta              | R11       |
| Una ejecución tarda más que el intervalo          | La siguiente se marca OMITIDA y no se encima                                                                 | RP1       |
| El proveedor del mapa base no responde            | La web avisa que no puede dibujar el fondo; los datos siguen disponibles                                     | R7        |

## 7. Trazabilidad con el SRS

Cada requisito del SRS 1.0 tiene al menos un componente de diseño
responsable; los cuatro requisitos propuestos se listan al final.

| Requisito                                     | Componentes de diseño                                                                              | Sección         |
|-----------------------------------------------|----------------------------------------------------------------------------------------------------|-----------------|
| FR1 Mapa de los cuatro municipios             | ColoniasModule, /v1/colonias, MapaView                                                             | 3.2, 5.1.1      |
| FR2 Mapa de calor con degradado               | NivelesModule, MapaView, LeyendaColonias, cálculo de Î                                             | 3.2, 6.3        |
| FR3 Elegir fenómeno                           | Catálogo /v1/fenomenos, IndiceFenomenos                                                            | 3.2, 5.1.1      |
| FR4 Cambiar de capa                           | Catálogo, ControlHojasApiladas                                                                     | 3.2.2           |
| FR5 Agregar fenómenos y capas                 | FenomenosModule, Registry y Strategy, AdminFenomenos                                               | 3.1, 5.1.2, 6.6 |
| FR6 Violencia de género                       | CalculoModule con método de índice ponderado y base de mujeres                                     | 6.1, 6.3        |
| FR7 Calidad del agua                          | CalculoModule con método de índice ponderado sin normalizar                                        | 6.3             |
| FR8 Disponibilidad de agua                    | CalculoModule con método de estado por conteo                                                      | 6.3             |
| FR9 Barra temporal                            | nivel_diario, /v1/niveles/serie, BarraTemporal                                                     | 3.4, 6.2        |
| FR10 Detalle de colonia                       | TarjetaColonia, recomendacion, /v1/colonias/{id}/detalle                                           | 3.4, 5.1.1      |
| FR11 Avisos en la página                      | aviso, NotificacionesModule, CentroNotificaciones, /v1/avisos                                      | 6.4             |
| FR12 Avisos por correo                        | NotificacionesModule, despachador, puerto de correo                                                | 5.2, 6.4        |
| FR13 Carga de datos                           | DatosModule, CargaDatos, CapturaEventos, AuditoriaModule                                           | 5.1.2           |
| FR14 Roles y cuentas                          | CuentasModule, AuthModule                                                                          | 3.2.1, 6.5      |
| FR15 API pública agregada                     | NivelesModule y endpoints públicos                                                                 | 5.1.1, 6.5      |
| FR16 Datos sintéticos                         | DatosModule (generador con semilla)                                                                | 5.1.2           |
| FR17 Configuración de ponderación             | configuracion_ponderacion versionada, Ponderacion                                                  | 3.4, 5.1.2      |
| FR18 Buzón de quejas                          | QuejasModule, FormQueja                                                                            | 6.6             |
| NFR1 Mapa comprensible                        | LeyendaColonias, fecha de cálculo y etiqueta de actualización visibles                             | 5.1.3           |
| NFR2 Máximo 2 clics                           | Selector, hojas apiladas y barra temporal en la misma pantalla del mapa                            | 3.2.2           |
| NFR3 Color no es la única señal               | MapaView muestra nivel en texto o patrón; contraste AA                                             | 3.2.2           |
| NFR4 Responsivo desde 360 px                  | SPA con diseño adaptable                                                                           | 3.2.2           |
| NFR5 Rendimiento del mapa                     | Niveles precalculados, serie en una sola petición, recoloreo en el cliente, geometría simplificada | 3.1, 3.4        |
| NFR6 Latencia de avisos                       | Sondeo de 60 s; despachador de 1 min con ventana de 10 min                                         | 6.4             |
| NFR7 Fenómeno nuevo sin tocar el cliente      | Catálogo declarativo y Strategy                                                                    | 3.1, 3.2.2      |
| NFR8 Sin datos que identifiquen a una persona | Quejas sin IP, API agregada, sin texto de quejas en la zona pública                                | 6.5             |
| NFR9 Datos del suscriptor                     | Cifrado, hash aparte y borrado al darse de baja                                                    | 6.5             |
| NFR10 Acceso al panel                         | Token, guarda de rol, HTTPS                                                                        | 6.5             |
| NFR11 Tipo de dato visible                    | Campo origenDatos en las respuestas y aviso fijo de datos de prueba                                | 3.4, 5.1.3      |
| NFR12 Cálculos reproducibles                  | Ponderación versionada, ejecucion_id en cada nivel                                                 | 3.4, 6.1        |
| NFR13 Disponibilidad                          | Estado vigente conservado, /salud, reintentos                                                      | 6.7             |
| NFR14 Mantenibilidad                          | Contrato TypeSpec y OpenAPI, capas verificadas en CI, guía de instalación                          | 4.1, 5          |
| NFR15 Origen de cada registro                 | Campo origen en evento y queja                                                                     | 3.4             |
| RP1 Frecuencia por presets                    | capa.frecuencia_preset, PlanificadorModule, recálculo incremental                                  | 3.3, 6.2        |
| RP2 Snapshot diario                           | nivel_vigente, nivel_diario, cierre diario                                                         | 3.4, 6.2        |
| RP3 Un correo cada 10 min por zona            | Despachador, envio_correo                                                                          | 3.5.3, 6.4      |
| RP4 Sin Telegram                              | Solo el puerto de correo                                                                           | 5.2             |

## 8. Decisiones abiertas y riesgos de diseño

Quedan 12 decisiones sin cerrar; cada una trae el valor por defecto con
el que se diseñó, para que el documento sea consistente mientras se
confirman.

### 8.1 Decisiones abiertas

| Id  | Decisión                               | Opciones                                                                         | Valor por defecto del diseño                                                                                                    | Responsable o plazo                                   | Estado                              |
|-----|----------------------------------------|----------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------|-------------------------------------|
| D1  | Hosting                                | Plan gratuito o académico; si el servicio se duerme por inactividad              | Render con plan gratuito y base de datos en Neon o Supabase; monitor externo a /salud y recuperación al despertar (sección 3.3) | Carolina Chi, antes del 13/nov                        | Por defecto, pendiente de confirmar |
| D2  | Proveedor de correo y su límite diario | SMTP o API                                                                       | Brevo con plan gratuito, mediante el adaptador del puerto ServicioCorreo; probar el límite real antes de cerrar                 | Carolina Chi, antes del 20/nov                        | Por defecto, pendiente de confirmar |
| D3  | Proveedor de mapa base                 | MapLibre GL JS con un estilo gratuito                                            | MapTiler con plan gratuito o Protomaps propio; URL de estilo en variable de entorno                                             | Carolina Chi, antes del 13/nov                        | Por defecto, pendiente de confirmar |
| D4  | Fuente de límites de colonias          | Fuente oficial o abierta                                                         | Script de carga a PostGIS y geometría simplificada para el mapa                                                                 | Edgar Torres, plazo del SPMP: 9/nov; confirmar estado | Sin definir                         |
| D5  | Qué es una "zona" en RP3               | Colonia, municipio o grupo de colonias                                           | Colonia                                                                                                                         | Cliente, vía Dulce Navarro                            | Por defecto, pendiente del cliente  |
| D6  | Suscriptor con varias zonas            | Un correo por zona (literal de RP3) o uno consolidado por suscriptor cada 10 min | Un correo por zona                                                                                                              | Equipo                                                | Por defecto, pendiente del cliente  |
| D7  | Escala del degradado                   | Techo T fijado por el administrador o máximo observado                           | Techo T configurable por capa                                                                                                   | Cliente                                               | Por defecto, pendiente del cliente  |
| D8  | Parpadeo de nivel cerca de un umbral   | Sin histéresis o con margen                                                      | Sin histéresis; el cambio neto por ventana de 10 min ya evita correos inútiles                                                  | Equipo                                                | Por defecto, pendiente de confirmar |
| D9  | Hora del cierre diario                 | 00:00 America/Mexico_City u otra                                                 | 00:00 America/Mexico_City                                                                                                       | Equipo                                                | Por defecto, pendiente de confirmar |
| D10 | Retención de ejecuciones y avisos      | Conservar todo o depurar después de N días                                       | Snapshots diarios sin depurar; quejas 12 meses; revisar según el plan de base de datos                                          | Equipo                                                | Por defecto, pendiente del cliente  |
| D11 | Ejecutor de pruebas                    | Jest u otro                                                                      | Jest en NestJS y Vitest en React                                                                                                | Alejandro Labourdette                                 | Por defecto, pendiente de confirmar |
| D12 | Lista final de presets                 | 1, 5, 15 min, 1 h, 24 h u otra                                                   | Esa lista                                                                                                                       | Cliente                                               | Por defecto, pendiente del cliente  |

Los valores por defecto rigen mientras nadie objete. D1 a D3 y D10 a D11
son propuestas del autor y los límites de los planes gratuitos deben
verificarse en las páginas oficiales antes de cerrarlos. Cambiarlos no
afecta al diseño: hosting, correo y mapa están aislados tras interfaces.

### 8.2 Riesgos de diseño

Se suman a R1 a R12 del SPMP.

| Id  | Riesgo                                                                                           | Mitigación                                                                                             | Contingencia                                                                    |
|-----|--------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------|
| RD1 | El hosting gratuito duerme el servicio y el planificador por minuto deja de correr (liga con R2) | proxima_ejecucion guardada en base, recuperación con una ejecución por capa y monitor externo          | Limitar los presets a 1 h y 24 h                                                |
| RD2 | La base gratuita se llena con snapshots y ejecuciones                                            | Una fila por colonia, capa y día; depurar ejecuciones antiguas (D10)                                   | Reducir la retención                                                            |
| RD3 | El plan gratuito de correo tiene un límite menor al volumen de avisos (R11)                      | Ventana de 10 min, un cambio neto por zona y lotes diferidos                                           | Entregar con avisos solo en la página                                           |
| RD4 | El recálculo cada minuto carga la base compartida                                                | Recálculo incremental, lotes de colonias, índices por fecha de creación y bloqueo por capa             | Subir el intervalo mínimo a 5 min                                               |
| RD5 | La latencia de correo supera los 15 minutos de NFR6                                              | Ciclo del despachador de 1 min y proveedor con entrega rápida                                          | Pedir al cliente reinterpretar NFR6 como 15 min tras el cierre de la ventana    |
| RD6 | RP1 a RP3 agregan trabajo en cinco semanas (R5, R12)                                             | Implementar en este orden: pipeline y cierre diario, planificador incremental, despachador con ventana | Entregar solo los presets de 1 h y 24 h, y un correo por zona sin consolidación |

## Anexo A. Modelo 4+1 y diagramas

Los diagramas organizan el diseño en las cinco vistas de Kruchten, igual
que el ejemplo de referencia; las figuras están en el cuerpo del
documento, junto a su explicación, y esta tabla las ordena por vista.

| Vista      | Figuras                                                                 | Propósito                     | Sección                   |
|------------|-------------------------------------------------------------------------|-------------------------------|---------------------------|
| Desarrollo | Figura 1 Arquitectura por capas y módulos                               | Cómo se organiza el código    | 3.2.1                     |
| Lógica     | Figura 3 Modelo de datos                                                | Entidades y relaciones        | 3.4                       |
| Proceso    | Figura 4 estados del envío, Figura 6 pipeline, Figuras 7 a 9 secuencias | Cómo se comporta en ejecución | 3.5.3, 6.1, 6.2, 6.4, 6.6 |
| Física     | Figura 2 Despliegue                                                     | Dónde corre cada pieza        | 3.3                       |
| Escenarios | Figura 5 Casos de uso                                                   | Qué hace cada actor           | 3.6                       |
