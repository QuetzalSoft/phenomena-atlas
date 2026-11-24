# Software Project Management Plan

**Phenomena Atlas**

Conforme a IEEE Std 1058-1998

## Portada

| Campo | Valor |
| --- | --- |
| Proyecto | Phenomena Atlas |
| Fecha de emisión | 23 de noviembre de 2026 |
| Identificador único | SPMP-PA, versión 1.1 (línea base inicial: versión 1.0 del 4/nov/2026) |
| Organización emisora | Quetzal Soft, equipo de desarrollo de Phenomena Atlas |
| Cliente | CINVESTAV Unidad Guadalajara (IPN) |

## Página de firmas

Las siguientes personas aprueban este plan.

| Nombre | Rol | Firma | Fecha |
| --- | --- | --- | --- |
| Alejandro Labourdette | Project Manager, Product Owner, Scrum Master y especialista de pruebas |  |  |
| Carolina Chi | Especialista en implementación |  |  |
| Dulce Navarro | Especialista en requerimientos |  |  |
| Edgar Torres | Especialista en diseño de software |  |  |
| Mario Siller | Profesor-investigador del CINVESTAV, contacto principal del cliente |  |  |

## Historial de cambios

| Proyecto | Versión | Fecha de liberación | Páginas modificadas | Naturaleza de los cambios |
| --- | --- | --- | --- | --- |
| Phenomena Atlas | 0.1 | 6/oct/2026 | Todas | Versión construida a partir de la reunión de inicio del 5/oct. Fija la visión inicial: mapa de calor de violencia de género, con alerta temprana y recolección de datos de redes sociales |
| Phenomena Atlas | 0.2 | 15/oct/2026 | Alcance, entregables, organización y riesgos | Versión construida a partir de la reunión del 14/oct. Se agrega el fenómeno del agua, se cancela el scraping, se agregan las quejas y el rol de analista o especialista, se segmenta por colonias y se acuerda que los fenómenos y la ponderación de su índice sean configurables dinámicamente |
| Phenomena Atlas | 0.3 | 29/oct/2026 | Alcance, calendario y riesgos | Versión construida a partir de la reunión del 28/oct. Se descarta la desactivación de zonas por el administrador, se decide no mostrar zonas grises, se define el recálculo diario del índice y se acuerda que el agua tenga dos capas: calidad y disponibilidad |
| Phenomena Atlas | 1.0 | 4/nov/2026 | Todas | Primera versión formal según IEEE Std 1058-1998. Consolida los acuerdos de las tres reuniones (ver 1.2) |
| Phenomena Atlas | 1.1 | 23/nov/2026 | Portada, firmas, contenido, 1.2, 3, 4.2, 4.3, 6.1 y 9 | Se describe de forma explícita la metodología ágil del proyecto (Scrum con prácticas de XP): roles, eventos, artefactos, definición de terminado y prácticas de ingeniería. Responde a la observación de que el plan no describía la metodología de desarrollo |

Versiones anteriores: 0.1 (6/oct/2026), 0.2 (15/oct/2026) y 0.3 (29/oct/2026), reconstruidas a partir de los acuerdos de cada reunión con el cliente, y 1.0 (4/nov/2026).

## Prefacio

**Alcance y contexto.** Este plan define cómo se gestiona el proyecto Phenomena Atlas, una aplicación web pública que muestra en mapas de calor por colonia la intensidad de fenómenos sociales y ambientales de la Zona Metropolitana de Guadalajara. Describe los procesos gerenciales y técnicos necesarios para entregar el software y su documentación al CINVESTAV el 11/dic/2026. Es el documento de control del proyecto y se mantiene bajo gestión de la configuración.

**Audiencia.** El equipo de desarrollo, que lo usa para planificar y dar seguimiento al trabajo, y los interesados del CINVESTAV, que lo usan para conocer el plan y verificar su cumplimiento.

## Contenido

| Cláusula | Subcláusulas |
| --- | --- |
| 1. Visión general | 1.1 Resumen del proyecto (1.1.1 Propósito, alcance y objetivos; 1.1.2 Supuestos y restricciones; 1.1.3 Entregables; 1.1.4 Calendario y presupuesto); 1.2 Evolución del SPMP |
| 2. Referencias | Sin subcláusulas |
| 3. Definiciones | Sin subcláusulas |
| 4. Organización del proyecto | 4.1 Interfaces externas; 4.2 Estructura interna; 4.3 Roles y responsabilidades |
| 5. Planes del proceso gerencial | 5.1 Plan de arranque (5.1.1 Estimación; 5.1.2 Personal; 5.1.3 Adquisición de recursos; 5.1.4 Formación); 5.2 Plan de trabajo (5.2.1 Actividades; 5.2.2 Calendario; 5.2.3 Recursos; 5.2.4 Presupuesto); 5.3 Plan de control (5.3.1 Requisitos; 5.3.2 Calendario; 5.3.3 Presupuesto; 5.3.4 Calidad; 5.3.5 Informes; 5.3.6 Métricas); 5.4 Gestión de riesgos; 5.5 Cierre del proyecto |
| 6. Planes del proceso técnico | 6.1 Modelo de proceso (6.1.1 Metodología ágil; 6.1.2 Ciclo de vida del proyecto); 6.2 Métodos, herramientas y técnicas; 6.3 Infraestructura; 6.4 Aceptación del producto |
| 7. Planes de procesos de apoyo | 7.1 Gestión de la configuración; 7.2 Verificación y validación; 7.3 Documentación; 7.4 Aseguramiento de la calidad; 7.5 Revisiones y auditorías; 7.6 Resolución de problemas; 7.7 Subcontratistas; 7.8 Mejora del proceso |
| 8. Planes adicionales | Sin subcláusulas |
| 9. Anexos e índice | Índice de términos |

Lista de figuras: cronograma del proyecto (5.2.2). Las tablas no llevan numeración propia: se identifican por la subcláusula donde aparecen.

## 1. Visión general

Esta cláusula resume el propósito, el alcance y los objetivos del proyecto, sus supuestos y restricciones, los entregables, el calendario y presupuesto, y cómo evoluciona este plan.

### 1.1 Resumen del proyecto

#### 1.1.1 Propósito, alcance y objetivos

**Propósito.** Phenomena Atlas es un sistema de alerta temprana y de información pública. Muestra, en un mapa de calor por colonia, cómo se comporta un fenómeno social o ambiental en la Zona Metropolitana de Guadalajara (ZMG). Cuanto más rojo aparece una colonia, peor es su situación respecto del fenómeno consultado. La necesidad que atiende es que la población acceda a información sobre fenómenos que la afectan y reciba avisos cuando varían.

**Alcance.**

- **Zona geográfica:** ZMG, Jalisco, México, segmentada por colonias. Se consideraron los distritos electorales y se descartaron por consenso el 14/oct/2026.
- **Fenómenos iniciales:** violencia de género y agua. El fenómeno del agua tiene dos capas: la calidad del agua que llega a los hogares (agua sucia o contaminada) y la disponibilidad de agua, acordado el 28/oct/2026. Los fenómenos son dinámicos: se pueden configurar sus características, añadir fenómenos nuevos y modificar la ponderación que cada uno tiene en el cálculo de su índice, acordado el 14/oct/2026.
- **Un mapa por fenómeno:** cada fenómeno tiene su mapa, con las colonias delimitadas y coloreadas según su índice. El fenómeno del agua se muestra con dos capas, una de calidad y otra de disponibilidad.
- **Fuentes de datos:** datos sintéticos en esta etapa; quejas que los usuarios registran sobre un fenómeno en una colonia; y eventos que registran usuarios con rol de analista o especialista mediante un acceso restringido.
- **Índice:** se recalcula automáticamente una vez al día por colonia y fenómeno. Los reportes antiguos pierden peso con el tiempo.
- **Notificaciones:** los usuarios suscritos reciben avisos sobre la variación de los fenómenos que siguen, por correo electrónico y por publicación en grupos de Telegram.
- **Acceso:** público para la población en general.
- **Naturaleza de alerta temprana:** con datos sintéticos, la oportunidad y precisión de las alertas pueden ser limitadas. Esa limitación es de los datos y no cambia el objetivo del sistema.

**Exclusiones.** Quedan fuera la obtención automática de datos desde redes sociales (scraping), la desactivación de zonas por el administrador para mostrarlas en gris y la representación en gris de zonas sin datos. El mapa se pinta según el índice calculado.

**Objetivos y cómo se determina su cumplimiento.**

| Objetivo | Cómo se verifica |
| --- | --- |
| Entregar una versión estable el 11/dic/2026 | Despliegue accesible y aceptación del cliente según 6.4 |
| Dos fenómenos funcionando (el del agua con dos capas) y configurables dinámicamente | Demostración y pruebas de aceptación |
| Notificaciones de variación de los fenómenos | Prueba de envío por al menos un canal y demostración |
| Documentación de ingeniería de software completa y de calidad | Entrega de los documentos de 1.1.3 en las fechas comprometidas |

**Relación con otros proyectos.** Es un proyecto nuevo e independiente. Existen soluciones que mapean otros fenómenos (por ejemplo, niveles de inundación), pero ninguna con fenómenos configurables. La API queda expuesta a terceros y permitirá una futura aplicación móvil; esas extensiones no forman parte de este proyecto.

**Requisitos oficiales del producto.** El enunciado oficial de los requisitos es la Especificación de Requisitos de Software (SRS), que se entrega el 6/nov/2026. Hasta entonces rigen el análisis de requerimientos y viabilidad (presentado el 14/oct/2026) y su validación (28/oct/2026).

#### 1.1.2 Supuestos y restricciones

| Tipo | Descripción |
| --- | --- |
| Supuesto | Los datos iniciales son sintéticos y los genera el equipo |
| Supuesto | Los límites geográficos de las colonias se podrán conseguir en un formato utilizable (fuente por confirmar) |
| Supuesto | Cada integrante dedica entre 15 y 20 horas semanales al proyecto |
| Supuesto | El equipo dispone de GitHub y de herramientas gratuitas durante todo el proyecto |
| Restricción de calendario | Entrega final el 11/dic/2026. Hitos: SRS 6/nov, SDD 11/nov, MTP 25/nov |
| Restricción de presupuesto | Sin presupuesto monetario: solo herramientas gratuitas y el tiempo del equipo |
| Restricción de recursos | Cuatro personas con otras obligaciones académicas y disponibilidad parcial |
| Restricción de tecnología | API en NestJS, base de datos PostgreSQL con PostGIS, aplicación web en React con TypeScript, contrato en TypeSpec |
| Restricción de interfaces | La API sigue un contrato publicado en OpenAPI, generado desde TypeSpec, que la web consume |
| Software a reutilizar | Bibliotecas y servicios de código abierto o gratuitos. El software del cliente a incorporar: ninguno identificado |
| Pendientes de tecnología | Servicio de mapas (en evaluación: MapLibre GL JS), hosting y proveedores de correo electrónico y Telegram |

#### 1.1.3 Entregables del proyecto

Todos los entregables van al CINVESTAV, en un ejemplar y en medio electrónico (repositorio de GitHub y archivos de documentos). Estos puntos de entrega y empaque son propuestas por confirmar con el cliente.

| Entregable | Fecha |
| --- | --- |
| SPMP, Plan de gestión del proyecto de software | 4/nov/2026 |
| SRS, Especificación de requisitos de software | 6/nov/2026 |
| SDD, Descripción del diseño de software | 11/nov/2026 |
| MTP, Plan de pruebas | 25/nov/2026 |
| Software Phenomena Atlas (versión estable) y código fuente | 11/dic/2026 |
| Manual de usuario, manual técnico y de despliegue, documentación de la API e informe final | 11/dic/2026 |

#### 1.1.4 Resumen del calendario y presupuesto

Desde el 4/nov quedan unas 353 horas-persona de trabajo hasta el 11/dic/2026. El periodo de cada actividad incluye el trabajo ya hecho desde el kickoff del 5/oct. El presupuesto monetario es cero.

| Actividad principal | Esfuerzo restante (h) | Periodo |
| --- | --- | --- |
| Gestión y seguimiento | 43 | 5/oct al 11/dic |
| Requisitos (SRS) | 18 | 5/oct al 6/nov |
| Diseño (SDD) | 22 | 5/oct al 11/nov |
| Implementación de la API | 104 | 26/oct al 27/nov |
| Implementación de la aplicación web | 52 | 26/oct al 27/nov |
| Despliegue y hosting | 20 | 26/oct al 4/dic |
| Pruebas y calidad | 70 | 9/nov al 9/dic |
| Documentación final | 24 | 23/nov al 11/dic |
| **Total** | **353** |  |

### 1.2 Evolución del SPMP

**Actualizaciones programadas.** El plan se revisa después de cada reunión con el cliente (aproximadamente cada dos semanas) y en la revisión de cada sprint semanal.

**Actualizaciones no programadas.** Se hacen ante cualquier cambio de alcance, calendario, equipo o riesgo mayor.

**Difusión.** Cada nueva versión se publica en el repositorio del proyecto y el Project Manager la envía al contacto del cliente y al equipo.

**Gestión de la configuración.** El SPMP se versiona en GitHub. Todo cambio se hace por pull request revisado y aprobado por otro integrante, y cada versión aprobada se etiqueta con su número.

**Cambios ocurridos hasta esta versión.**

| Fecha | Evento | Efecto en el proyecto |
| --- | --- | --- |
| 5/oct/2026 | Reunión de inicio con el cliente | Visión inicial: mapa de calor de violencia de género, con alerta temprana y recolección de datos de redes sociales |
| 14/oct/2026 | Segunda reunión: análisis de requerimientos y viabilidad | Se agrega el fenómeno del agua contaminada. Se cancela el scraping. Se agregan las quejas de usuarios y el rol de analista o especialista. Se segmenta por colonias. Se acuerda que los fenómenos y la ponderación de su índice se puedan configurar dinámicamente |
| 28/oct/2026 | Tercera reunión: validación de requerimientos | Se descarta la desactivación de zonas por el administrador. Se decide no mostrar zonas grises. Se define el recálculo diario del índice. Se acuerda que el fenómeno del agua tenga dos capas: calidad y disponibilidad |
| 26/oct/2026 | Inicio oficial del primer sprint | El trabajo se organiza en sprints semanales de lunes a viernes |
| 23/nov/2026 | Observación de que el SPMP no describía la metodología de desarrollo | Se amplía 6.1 con la descripción de la metodología ágil (versión 1.1). No cambia el alcance, el calendario ni el presupuesto |

## 2. Referencias

Esta lista incluye los documentos y fuentes a los que remite este plan. Los datos de autor, fecha y ubicación de los documentos del proyecto se completarán al publicarlos.

| Documento | Número o identificador | Fecha | Autor u organización | Acceso |
| --- | --- | --- | --- | --- |
| IEEE Standard for Software Project Management Plans | IEEE Std 1058-1998 | 22/dic/1998 | IEEE, Software Engineering Standards Committee | Copia oficial del equipo |
| IEEE Standard Glossary of Software Engineering Terminology | IEEE Std 610.12-1990 | 1990 | IEEE | Por obtener |
| Análisis de requerimientos y viabilidad (presentación) | Por asignar | 14/oct/2026 | Dulce Navarro y equipo | Misma carpeta que este SPMP |
| Validación de requerimientos | Por asignar | 28/oct/2026 | Dulce Navarro y equipo | Misma carpeta que este SPMP |
| SRS | SRS-PA, versión por asignar | 6/nov/2026 | Dulce Navarro | Repositorio del proyecto |
| SDD | SDD-PA, versión por asignar | 11/nov/2026 | Edgar Torres | Repositorio del proyecto |
| MTP | MTP-PA, versión por asignar | 25/nov/2026 | Alejandro Labourdette | Repositorio del proyecto |
| Contrato de la API (TypeSpec) y OpenAPI generado | Versión del repositorio | Continua | Equipo | Repositorio de la API |

**Desviaciones de normas y políticas.** Este plan sigue el cumplimiento de formato de IEEE Std 1058-1998. No hay desviaciones identificadas respecto de normas o políticas referenciadas. Las omisiones de planes de apoyo se justifican en la cláusula 7.

## 3. Definiciones

Los términos de la primera parte siguen el sentido que les da IEEE Std 1058-1998, aplicado a este proyecto. Otros términos generales se encuentran en IEEE Std 610.12-1990.

| Término | Significado en este plan |
| --- | --- |
| Adquirente | Quien especifica los requisitos y recibe el producto: el CINVESTAV Unidad Guadalajara |
| Proveedor | Quien desarrolla los entregables: el equipo de desarrollo de Phenomena Atlas |
| Línea base | Producto de trabajo revisado y aceptado formalmente, que solo cambia por el control de configuración |
| Hito | Evento programado que mide el avance, como la entrega de un documento o del software |
| Acuerdo del proyecto | Conjunto de documentos que fijan las condiciones del proyecto. Aquí: el análisis de requerimientos validado y las decisiones de las reuniones con el cliente |
| Entregable | Producto de trabajo que se entrega al adquirente |
| Proceso de apoyo | Conjunto de actividades que abarca todo el proyecto, como la gestión de la configuración o el aseguramiento de la calidad |
| Actividad de trabajo | Conjunto de tareas de duración fija dentro del calendario |
| Paquete de trabajo | Especificación del trabajo de una tarea: recursos, duración, productos y criterios de terminación |
| Producto de trabajo | Cualquier elemento tangible producido durante el desarrollo |
| Tarea de trabajo | Unidad más pequeña de trabajo con responsable |
| SPMP, SRS, SDD, MTP | Plan de gestión del proyecto, especificación de requisitos, descripción del diseño y plan de pruebas |
| CINVESTAV, IPN | Centro de Investigación y de Estudios Avanzados y Instituto Politécnico Nacional |
| ZMG | Zona Metropolitana de Guadalajara |
| Colonia | Unidad urbana de segmentación del mapa; cada colonia tiene un color por fenómeno |
| Fenómeno | Situación social o ambiental que el sistema monitorea y muestra en un mapa. Se pueden añadir dinámicamente y pueden tener varias capas, como el agua (calidad y disponibilidad) |
| Índice | Valor diario por colonia y fenómeno que determina su color |
| Queja | Reporte que un usuario registra sobre un fenómeno en una colonia |
| Analista o especialista | Usuario con rol restringido que registra eventos sobre los fenómenos |
| Dato sintético | Dato generado artificialmente para simular datos reales |
| Metodología ágil | Enfoque de desarrollo iterativo e incremental que entrega software funcionando en ciclos cortos y se adapta a los cambios con retroalimentación frecuente del cliente. En este proyecto: Scrum con prácticas de XP (ver 6.1) |
| Scrum | Marco de trabajo ágil para gestionar el proyecto en sprints, con roles, eventos y artefactos definidos (ver 6.1.1) |
| XP (Extreme Programming) | Metodología ágil centrada en prácticas de ingeniería, como integración continua, revisión del código y pruebas primero |
| Product Owner | Rol de Scrum responsable de maximizar el valor del producto: mantiene y prioriza el product backlog y acepta el trabajo terminado |
| Scrum Master | Rol de Scrum responsable de que el equipo siga el proceso: facilita los eventos y elimina impedimentos |
| Product backlog | Lista ordenada por prioridad de todo el trabajo pendiente del producto |
| Sprint backlog | Elementos del product backlog que el equipo se compromete a terminar en un sprint |
| Incremento | Producto de trabajo terminado al cierre de un sprint, integrado y verificado |
| Definición de terminado | Criterios que debe cumplir un elemento del backlog para considerarse terminado (ver 6.1.1) |
| Retrospectiva | Reunión al cierre de cada sprint en la que el equipo evalúa su forma de trabajar y acuerda mejoras |
| TDD | Desarrollo guiado por pruebas: la prueba se escribe antes del código que la satisface |
| Sprint | Iteración de una semana, de lunes a viernes (ver 6.1.1) |
| CI | Integración continua |
| WBS | Desglose del trabajo en actividades |

## 4. Organización del proyecto

Esta cláusula identifica las interfaces del proyecto con entidades externas, describe su estructura interna y define los roles y responsabilidades.

### 4.1 Interfaces externas

| Entidad | Relación con el proyecto | Interacción |
| --- | --- | --- |
| Organización matriz del equipo | Quetzal Soft, organización a la que pertenece el equipo de desarrollo | Sin interacción de gestión durante el desarrollo |
| CINVESTAV Unidad Guadalajara (IPN), profesor-investigador Mario Siller | Adquirente y contacto principal. Recibe el proyecto | Reuniones de avance y validación, aproximadamente cada dos semanas |
| Estudiantes de maestría y doctorado del profesor | Interesados secundarios. Algunos con especialidad medioambiental, útil para el fenómeno del agua | Participan en las reuniones y aportan conocimiento del dominio |
| Población en general | Usuarios finales | Sin interacción directa con el equipo durante el desarrollo |
| Analistas y especialistas | Usuarios con rol restringido que registran eventos | Se definen con el cliente |
| Fuente de límites de colonias | Proveedor externo de datos geográficos | Por definir |
| Proveedores de mapas, hosting, correo electrónico y Telegram | Proveedores de servicios técnicos. No son subcontratistas | Por definir |

### 4.2 Estructura interna

El equipo tiene cuatro personas y no tiene niveles jerárquicos intermedios. Las decisiones se construyen en colectivo: cada integrante expone su visión del problema y de la solución, y entre todos se elige la mejor respuesta. Cada persona es responsable de un área y tiene la última palabra en los temas de esa área. La autoridad sobre el plan, el calendario y la relación con el cliente recae en el Project Manager.

**Interfaces con los procesos de apoyo.** El equipo ejecuta por sí mismo la gestión de la configuración, el aseguramiento de la calidad y la verificación y validación. No hay unidades de la organización externas al proyecto que presten esos procesos. La independencia se logra así: quien revisa un cambio es siempre otro integrante, y las pruebas formales están a cargo del especialista de pruebas, distinto del especialista de implementación.

**Líneas de comunicación.** Siguen los eventos de Scrum descritos en 6.1.1: reunión diaria entre los cuatro integrantes, planificación, revisión y retrospectiva de cada sprint semanal, y reuniones con el cliente a través del Project Manager, que también actúa como Product Owner y Scrum Master.

### 4.3 Roles y responsabilidades

| Integrante | Rol | Responsabilidades |
| --- | --- | --- |
| Alejandro Labourdette | Project Manager, Product Owner, Scrum Master y especialista de pruebas | Planificación y seguimiento, comunicación con el cliente, priorización del product backlog, facilitación de los eventos de Scrum, SPMP, MTP, pruebas formales, verificación de la calidad |
| Carolina Chi | Especialista en implementación | Construcción del software, despliegue y decisiones de implementación |
| Dulce Navarro | Especialista en requerimientos | Levantamiento y validación de requerimientos, SRS, manual de usuario |
| Edgar Torres | Especialista en diseño de software | Arquitectura y diseño, SDD |

Matriz de actividades y procesos de apoyo contra personas (R: responsable, P: participa).

| Actividad o proceso | Alejandro | Carolina | Dulce | Edgar |
| --- | --- | --- | --- | --- |
| Gestión y seguimiento | R | P | P | P |
| Requisitos | P | P | R | P |
| Diseño | P | P | P | R |
| Implementación de API y web | P | R | P | P |
| Despliegue y hosting | P | R | P | P |
| Pruebas y calidad | R | P | P | P |
| Documentación final | R (informe) | R (técnica y API) | R (usuario) | P |
| Gestión de la configuración | P | R | P | P |
| Aseguramiento de la calidad | R | P | P | P |

La asignación de Carolina a la gestión de la configuración es una propuesta por confirmar. La revisión por pares la hacen los cuatro.

## 5. Planes del proceso gerencial

Esta cláusula especifica los procesos de gestión del proyecto: arranque, plan de trabajo, plan de control, gestión de riesgos y cierre. Es coherente con el alcance de 1.1.1. Los valores marcados como propuestos son estimaciones del equipo de gestión por confirmar.

### 5.1 Plan de arranque

#### 5.1.1 Plan de estimación

**Costo y calendario.** El esfuerzo restante estimado es de 353 horas-persona y el costo monetario es cero. El proyecto empezó con el kickoff del 5/oct/2026 y termina el 11/dic/2026 (ver 5.2). Las 353 horas son el esfuerzo restante desde el 4/nov.

**Métodos.** Estimación por juicio del equipo para cada paquete de trabajo, apoyada en analogía con el avance de los primeros sprints. El proyecto no tiene historial local suficiente, y por eso el nivel de confianza es bajo a medio. Las incertidumbres mayores están en el despliegue, los canales de notificación y la fuente de los límites de colonias.

**Reestimación.** Se reestima el esfuerzo restante en la revisión de cada sprint semanal, con los datos de horas registradas en GitHub Projects, y de forma extraordinaria ante cambios de alcance.

#### 5.1.2 Plan de personal

| Aspecto | Descripción |
| --- | --- |
| Personas | 4 integrantes, de 15 a 20 h semanales cada uno: 60 a 80 h por semana en total |
| Nivel de habilidad | Estudiantes de maestría con formación en ingeniería de software. Experiencia limitada en desarrollo y despliegue |
| Fases y duración | Requisitos y diseño (desde el kickoff del 5/oct hasta el 11/nov), implementación (desde el 26/oct hasta el 27/nov), pruebas y estabilización (26/nov al 11/dic) |
| Fuente del personal | Los propios integrantes del equipo. No hay nuevas contrataciones ni transferencias |
| Roles | Los de 4.3, sin cambios previstos |

#### 5.1.3 Plan de adquisición de recursos

| Recurso | Responsable | Cuándo | Restricción |
| --- | --- | --- | --- |
| Hosting con plan gratuito o académico | Carolina Chi | Elegir antes del 13/nov | Sin presupuesto; los límites reales de los planes gratuitos no se conocen |
| Servicio de mapas (evaluación: MapLibre GL JS) | Carolina Chi | Elegir antes del 13/nov | Gratuito, preferiblemente de código abierto |
| Proveedor de correo electrónico | Carolina Chi | Elegir antes del 20/nov | Gratuito o de costo mínimo; los límites son un riesgo (R11) |
| Bot y grupos de Telegram | Carolina Chi | Antes del 20/nov | Gratuito |
| Límites geográficos de colonias | Edgar Torres | Antes del 9/nov | Fuente abierta u oficial en formato utilizable |
| Equipo de cómputo | Cada integrante | Ya disponible | Se usan equipos personales |

Contratos de servicio, transporte, instalaciones y servicios administrativos no aplican: el trabajo es remoto y sin presupuesto. Los acuerdos de adquisición los registra el Project Manager.

#### 5.1.4 Plan de formación del personal

Todos los integrantes aprenden tecnologías nuevas durante los sprints. La formación cubre habilidades técnicas y de gestión.

| Tema | Quiénes | Método | Criterio de entrada | Criterio de salida |
| --- | --- | --- | --- | --- |
| NestJS, TypeSpec y desarrollo de contrato primero | Los 4 | Autoestudio y tutoría entre pares | Conocimiento básico de desarrollo web | Un endpoint implementado y revisado por otro integrante |
| PostgreSQL con PostGIS | Carolina, Edgar | Autoestudio y prototipo | Conocimiento de bases de datos | Consulta de colonias funcionando |
| MapLibre GL JS y React | Carolina, Edgar | Autoestudio y prototipo | Conocimiento de JavaScript | Mapa con colonias coloreadas |
| Despliegue y DevOps | Carolina, Alejandro | Autoestudio y despliegue de prueba | Ninguno | Despliegue de prueba accesible |
| Herramientas de prueba (Playwright, Schemathesis, Testcontainers) | Alejandro, Carolina, Dulce | Autoestudio y tutoría entre pares | Conocimiento de pruebas de software | Una prueba de cada tipo en CI |

### 5.2 Plan de trabajo

#### 5.2.1 Actividades de trabajo

El trabajo se descompone en ocho paquetes y sus subpaquetes. El nivel de detalle es mayor en las partes con más incertidumbre, como el despliegue y las notificaciones.

| ID | Paquete | Esfuerzo (h) | Producto principal |
| --- | --- | --- | --- |
| WP1 | Gestión y seguimiento | 43 | SPMP, informes de sprint, informe final |
| WP2 | Requisitos | 18 | SRS validado |
| WP3 | Diseño | 22 | SDD con modelos UML |
| WP4 | Implementación de la API | 104 | API desplegable con contrato TypeSpec |
| WP5 | Implementación de la aplicación web | 52 | Aplicación web que consume la API |
| WP6 | Despliegue y hosting | 20 | Sistema accesible en el hosting elegido |
| WP7 | Pruebas y calidad | 70 | MTP, resultados de pruebas, defectos corregidos |
| WP8 | Documentación final | 24 | Manuales y documentación de la API |

| ID | Subpaquete | Esfuerzo (h) | Predecesores | Criterio de terminación |
| --- | --- | --- | --- | --- |
| 1.1 | SPMP | 10 | Ninguno | Aprobado y entregado el 4/nov |
| 1.2 | Seguimiento de sprints y reuniones con el cliente | 25 | Ninguno | Revisión semanal registrada |
| 1.3 | Informe final | 8 | 7.3 | Entregado el 11/dic |
| 2.1 | SRS | 14 | Análisis validado | Entregado el 6/nov |
| 2.2 | Validación continua de requisitos | 4 | 2.1 | Cambios aceptados por el cliente |
| 3.1 | SDD | 22 | 2.1 | Entregado el 11/nov |
| 4.1 | Autenticación y roles | 12 | Ninguno | Roles de usuario, analista y administrador funcionando |
| 4.2 | Colonias y datos geográficos | 10 | Fuente de límites | Colonias cargadas en PostGIS |
| 4.3 | Fenómenos configurables | 18 | 4.1 | Alta de fenómenos nuevos y configuración de sus características y de la ponderación de su índice desde la API |
| 4.4 | Quejas y eventos de analistas | 14 | 4.1, 4.2, 4.3 | Registro asociado a colonia y fenómeno |
| 4.5 | Cálculo diario del índice | 20 | 4.4 | Recálculo automático diario con ponderación por antigüedad |
| 4.6 | Suscripciones y notificaciones | 20 | 4.3, 4.5 | Aviso enviado por al menos un canal |
| 4.7 | Datos sintéticos | 10 | 4.2, 4.3 | Datos cargados para los dos fenómenos |
| 5.1 | Mapa por fenómeno | 22 | 4.2 | Colonias delimitadas y coloreadas por índice |
| 5.2 | Formularios de queja y panel de analistas | 14 | 4.4 | Flujos completos en la interfaz |
| 5.3 | Configuración de fenómenos | 10 | 4.3 | Pantallas funcionando |
| 5.4 | Suscripción a fenómenos | 6 | 4.6 | Pantallas funcionando |
| 6.1 | Elegir hosting y despliegue de prueba | 8 | Ninguno | Despliegue de prueba accesible |
| 6.2 | Pipeline de despliegue desde GitHub | 12 | 6.1 | Despliegue automático desde la rama principal |
| 7.1 | MTP | 12 | 3.1 | Entregado el 25/nov |
| 7.2 | Pruebas unitarias y de contrato continuas | 20 | Ninguno | Bloqueantes en CI |
| 7.3 | Pruebas formales | 18 | 7.1, congelamiento | Resultados registrados |
| 7.4 | Corrección de defectos | 20 | 7.3 | Sin defectos críticos abiertos |
| 8.1 | Manual de usuario | 10 | 5.2 | Entregado el 11/dic |
| 8.2 | Manual técnico y de despliegue | 10 | 6.2 | Entregado el 11/dic |
| 8.3 | Documentación de la API | 4 | 4.6 | Generada y revisada |

Cada subpaquete se especifica como una tarea de GitHub Projects con responsable, sprint, prioridad y criterios de aceptación. Esa tarea funciona como su paquete de trabajo.

#### 5.2.2 Asignación de calendario

Los sprints van de lunes a viernes. Antes del primer sprint, desde el kickoff del 5/oct, el equipo hizo el análisis de requerimientos y su viabilidad (presentado el 14/oct) y creó los repositorios. El primer sprint oficial empezó el 26/oct/2026: en él se validaron los requisitos con el cliente (28/oct), se activó la integración continua del contrato y arrancó la implementación.

&#91;embedded content: cronograma del 5/oct al 11/dic · 9 paquetes, 2 hitos\]

| Sprint | Fechas | Objetivos | Hitos |
| --- | --- | --- | --- |
| 2 | 2 al 6 de nov | Entregar SPMP y SRS. Seguir con roles, mapa por colonias, fenómenos y notificaciones. Decidir el hosting | SPMP 4/nov, SRS 6/nov |
| 3 | 9 al 13 de nov | Entregar el SDD. Despliegue de prueba. Quejas y eventos. Datos sintéticos | SDD 11/nov |
| 4 | 16 al 20 de nov | Índice diario. Formularios de queja y panel de analistas. Suscripciones | Ninguno |
| 5 | 23 al 27 de nov | Entregar el MTP. Integrar todo. Congelar funcionalidades. Empezar los manuales | MTP 25/nov, congelamiento 27/nov |
| 6 | 30 de nov al 4 de dic | Pruebas formales, correcciones y despliegue final | Ninguno |
| 7 | 7 al 11 de dic | Estabilizar, cerrar la documentación y entregar | Entrega final 11/dic |

El congelamiento de funcionalidades del 27/nov es una propuesta del equipo y no un compromiso con el cliente. Las dependencias están en la columna de predecesores de 5.2.1. Las actividades de WP4, WP5 y WP6 se ejecutan en paralelo hasta el congelamiento. No hay restricciones de calendario externas al proyecto aparte de las fechas de entrega y las reuniones con el cliente.

Los hitos se evalúan con indicadores objetivos: documento entregado y aprobado, funcionalidad demostrada, pruebas en verde en CI.

#### 5.2.3 Asignación de recursos

Horas por persona y paquete (propuesta por confirmar). Cada línea corresponde a un tipo de recurso: horas de personal.

| Paquete | Alejandro | Carolina | Dulce | Edgar | Total |
| --- | --- | --- | --- | --- | --- |
| WP1 Gestión | 43 | 0 | 0 | 0 | 43 |
| WP2 Requisitos | 0 | 0 | 18 | 0 | 18 |
| WP3 Diseño | 0 | 0 | 0 | 22 | 22 |
| WP4 API | 12 | 40 | 24 | 28 | 104 |
| WP5 Web | 8 | 20 | 10 | 14 | 52 |
| WP6 Despliegue | 6 | 14 | 0 | 0 | 20 |
| WP7 Pruebas | 30 | 10 | 15 | 15 | 70 |
| WP8 Documentación | 0 | 14 | 10 | 0 | 24 |
| **Total** | **99** | **98** | **77** | **79** | **353** |

La capacidad de cada persona entre el 4/nov y el 11/dic es de 84 a 112 horas (de 15 a 20 h semanales durante 5,6 semanas). Todas las asignaciones están dentro de ese rango, pero la de Alejandro y la de Carolina quedan cerca del límite superior.

Otros recursos por actividad: GitHub y GitHub Projects (todas), NestJS, PostgreSQL con PostGIS y TypeSpec (WP4), React y MapLibre GL JS (WP5), hosting (WP6), herramientas de prueba y CI (WP7).

#### 5.2.4 Asignación de presupuesto

No hay presupuesto monetario. El costo del proyecto es el esfuerzo del equipo.

| Tipo de recurso | Esfuerzo o costo |
| --- | --- |
| Personal | 353 h-persona, sin costo monetario |
| Viajes | 0. Las reuniones y el trabajo son remotos o en las instalaciones del Cinvestav |
| Cómputo | 0. Equipos personales y planes gratuitos |
| Herramientas de software | 0. Herramientas gratuitas |
| Pruebas y simulación | 0 |
| Apoyo administrativo | 0 |

La capacidad total es de 336 a 448 horas. Con 15 h semanales por persona faltarían 17 h (5 %). Con 20 h sobran 95 h.

### 5.3 Plan de control

Los elementos de este plan son coherentes con las políticas del proyecto y con las fechas comprometidas con el cliente.

#### 5.3.1 Plan de control de requisitos

- **Medición e informe de cambios:** cada cambio de requisito se registra como una solicitud en GitHub Projects y se presenta en la siguiente reunión con el cliente. Los cambios de alcance se anotan también en 1.2.
- **Evaluación de impacto:** la especialista en requerimientos y el Project Manager evalúan el efecto sobre el alcance, la calidad, el calendario, el esfuerzo y los riesgos antes de aceptarlo.
- **Control de cambios:** un comité formado por el equipo y el contacto del cliente aprueba los cambios de alcance. Los cambios de contrato de la API pasan además por el control de compatibilidad (oasdiff) en CI.
- **Técnicas:** trazabilidad entre requisitos, diseño y pruebas, prototipos y revisiones con el cliente.

#### 5.3.2 Plan de control del calendario

El progreso se mide en los hitos mayores (documentos y software) y en los menores (cierre de cada sprint). El Project Manager compara lo planificado con lo hecho en la revisión semanal, con datos de GitHub Projects. Si el avance no cumple lo planificado, el equipo decide una acción correctiva: reasignar tareas, simplificar alcance según la prioridad 5 de 5.4, o renegociar con el cliente. Los hitos se juzgan por criterios objetivos de producto terminado.

#### 5.3.3 Plan de control del presupuesto

Como el costo es esfuerzo, se controla en horas. Cada integrante registra las horas dedicadas a cada tarea y el Project Manager las compara cada semana con lo planificado. Se usa un seguimiento simplificado de valor ganado: horas planificadas de las tareas terminadas frente a horas gastadas y horas planificadas a la fecha. Si la desviación supera el 10 %, se aplica una acción correctiva (propuesta).

#### 5.3.4 Plan de control de la calidad

La calidad de los procesos y productos se controla con revisión por pares obligatoria, integración continua que verifica el contrato y las reglas de arquitectura, pruebas automáticas, revisiones de sprint y revisiones con el cliente. Los detalles están en 7.2 y 7.4.

#### 5.3.5 Plan de informes

| Mecanismo | Frecuencia | Destino |
| --- | --- | --- |
| Reunión diaria | Diaria | Equipo |
| Revisión de sprint con estado de avance, horas y riesgos | Semanal | Equipo |
| Reunión de avance y validación con el CINVESTAV | Aproximadamente cada dos semanas | Cliente |
| Tablero de GitHub Projects | Continuo | Equipo y cliente |
| Informe final | 11/dic/2026 | Cliente |

#### 5.3.6 Plan de recolección de métricas

| Métrica | Frecuencia | Validación y uso |
| --- | --- | --- |
| Horas por tarea y por paquete | Semanal | Control del presupuesto y reestimación |
| Tareas terminadas por sprint | Semanal | Control del calendario |
| Defectos abiertos y cerrados | Semanal | Calidad y resolución de problemas |
| Tiempo de revisión de cada pull request | Semanal | Mejora del proceso |
| Fallas de CI por incompatibilidad de contrato | Semanal | Calidad del contrato |
| Cambios de requisitos solicitados | Por reunión con el cliente | Control de requisitos |

Los datos salen de GitHub y GitHub Projects. El Project Manager los valida, los analiza y los incluye en la revisión de sprint. La lista de métricas es propuesta.

### 5.4 Plan de gestión de riesgos

**Proceso.** Los riesgos se identifican, analizan y priorizan en la revisión de cada sprint. Cada riesgo tiene responsable, mitigación y contingencia. Se vigila el cambio de su nivel y se registra la respuesta. El Project Manager comunica el estado de los riesgos al cliente en las reuniones. Como no hay subcontratistas, la comunicación entre adquirente y proveedor es directa. Los valores de probabilidad e impacto son estimaciones del equipo.

**Prioridades si el tiempo aprieta.** Son innegociables: la fecha, una versión estable, los dos fenómenos configurables, las notificaciones y la calidad de la documentación. Se simplifica primero el número de canales de notificación, el refinamiento visual y las funciones adicionales para analistas.

| ID | Riesgo | Categoría | Prob. | Impacto | Mitigación | Contingencia |
| --- | --- | --- | --- | --- | --- | --- |
| R1 | **Falsos negativos por falta de reportes.** El índice depende de las quejas y eventos registrados. Si la población no conoce la plataforma, el mapa pinta de verde colonias que sí tienen problemas. Es más delicado porque el cliente descartó mostrar zonas grises | Relación adquirente-proveedor, aceptación | Alta | Alto | Aclarar en la interfaz que el color refleja los reportes recibidos y no necesariamente la situación real. Promover la participación de especialistas. Proponer al cliente una estrategia de difusión | Documentar la limitación en el manual de usuario y la entrega. Volver a proponer una indicación de sin datos |
| R2 | **Falta de experiencia en despliegue y DevOps.** Se desconoce hasta dónde llegan los planes gratuitos | Entornos de desarrollo y destino | Alta | Alto | Elegir hosting antes del 13/nov. Despliegue de prueba temprano. Automatizar desde GitHub | Hosting alternativo. Como último recurso, ejecución local con instrucciones |
| R3 | **Equipo nuevo sin prácticas consolidadas.** Puede fallar el acoplamiento entre roles y componentes | Personal | Media | Alto | Daily, revisión por pares, sprints semanales y responsabilidades claras. Integración frecuente | El Project Manager replantea responsabilidades en la revisión del sprint |
| R4 | **Aprendizaje de tecnologías desde cero** | Tecnología | Alta | Medio | Tiempo de aprendizaje en cada sprint, prototipos pequeños y conocimiento compartido | Simplificar la solución técnica |
| R5 | **Tiempo limitado** de unas cinco semanas, con otras obligaciones | Calendario y presupuesto | Alta | Alto | Priorizar y planificar solo lo que cabe en cada sprint | Reducir alcance de menor prioridad |
| R6 | **Datos sintéticos poco realistas** | Tecnología, aceptación | Media | Medio | Diseñarlos con estudiantes de perfil medioambiental y documentar su generación | Declarar la limitación al cliente |
| R7 | **Servicio de mapas sin definir** o con límites en su plan gratuito | Tecnología | Media | Medio | Evaluar opciones gratuitas de código abierto | Cambiar de proveedor. La API aísla este componente |
| R8 | **Obtención de los límites de las colonias** | Tecnología | Media | Alto | Buscar fuentes oficiales o abiertas desde ya | Fuente alternativa o simplificar polígonos |
| R9 | **Cambios de requisitos** (ya ocurrieron el 14 y 28/oct) | Contractual, relación con el adquirente | Media | Medio | Validar con el cliente en cada reunión. Actualizar el SPMP | Renegociar el alcance |
| R10 | **Indisponibilidad de un integrante** | Personal | Media | Alto | Revisión por pares y decisiones documentadas | Reasignar tareas |
| R11 | **Canales de notificación con costos o límites** en planes gratuitos | Tecnología | Media | Medio | Probar cada canal pronto y mantener los módulos desacoplados | Entregar con un solo canal |
| R12 | **Tamaño y complejidad del producto** respecto del equipo y el tiempo | Tamaño y complejidad | Media | Alto | Contrato primero y tareas pequeñas integradas con frecuencia | Reducir alcance según prioridades |

### 5.5 Plan de cierre del proyecto

- **Reasignación del personal:** al entregar el 11/dic/2026 los integrantes vuelven a sus actividades académicas. No hay reasignación a otros proyectos prevista.
- **Archivo de materiales:** se etiqueta la versión entregada en GitHub, y los documentos, el contrato y los datos sintéticos quedan en el repositorio entregado al CINVESTAV.
- **Revisión posterior al proyecto:** el equipo hace una sesión de análisis de lo ocurrido en la semana de la entrega (fecha por definir).
- **Informe final:** el Project Manager prepara un informe con las lecciones aprendidas y el análisis de objetivos logrados frente a 1.1.1.

## 6. Planes del proceso técnico

Esta cláusula especifica el modelo de proceso, los métodos, herramientas y técnicas, la infraestructura y la aceptación del producto.

### 6.1 Modelo de proceso

El proyecto usa una **metodología ágil** con un ciclo de vida iterativo e incremental. Scrum es el marco de gestión del trabajo y Extreme Programming (XP) aporta las prácticas de ingeniería. A ambos se suma el enfoque de contrato primero para la API.

**Justificación.** Se eligió una metodología ágil porque:

- Los requisitos cambiaron de forma importante en las reuniones del 14/oct y del 28/oct (ver 1.2), y se espera que sigan ajustándose con la retroalimentación del cliente.
- El cliente revisa el avance aproximadamente cada dos semanas, lo que permite validar incrementos funcionando en lugar de documentos aislados.
- El equipo es pequeño (cuatro personas), con dedicación parcial y una fecha de entrega fija, por lo que conviene planificar en ciclos cortos y ajustar el alcance según la prioridad (ver 5.4).
- El equipo aprende tecnologías nuevas (R4), y los ciclos cortos permiten detectar pronto los problemas técnicos.

#### 6.1.1 Metodología ágil

**Roles de Scrum.**

| Rol | Quién | Responsabilidades |
| --- | --- | --- |
| Product Owner | Alejandro Labourdette | Mantiene y prioriza el product backlog. Traduce los acuerdos con el cliente y los requisitos del SRS en elementos del backlog con criterios de aceptación. Acepta o rechaza el trabajo terminado en la revisión del sprint |
| Scrum Master | Alejandro Labourdette | Facilita los eventos de Scrum, elimina impedimentos y vigila que el equipo siga el proceso y la definición de terminado |
| Equipo de desarrollo | Los cuatro integrantes | Se autoorganiza para entregar el incremento de cada sprint. Cada integrante conserva la autoridad de su área según 4.2 y 4.3 |
| Interesados | CINVESTAV (Mario Siller y sus estudiantes) | Validan los incrementos y los cambios de alcance en las reuniones con el cliente, aproximadamente cada dos semanas |

**Adaptación de los roles.** Por el tamaño del equipo, una misma persona asume los roles de Product Owner y Scrum Master, además de Project Manager. Para equilibrar esa concentración, las prioridades del backlog se revisan con todo el equipo en cada revisión de sprint y se validan con el cliente en cada reunión con el CINVESTAV.

**Eventos de Scrum.**

| Evento | Cuándo | Duración aproximada | Propósito |
| --- | --- | --- | --- |
| Sprint | Una semana, de lunes a viernes | 5 días | Contenedor de los demás eventos. Al terminar produce un incremento integrado y verificado |
| Planificación del sprint | Lunes, al inicio del sprint | 1 hora | El equipo elige del product backlog los elementos que caben en el sprint, los estima en horas y forma el sprint backlog |
| Reunión diaria | Cada día del sprint | 15 minutos | Cada integrante comparte qué hizo, qué hará y qué le impide avanzar |
| Revisión del sprint | Viernes, al cierre del sprint | 1 hora | Se revisa lo terminado frente a lo planificado, las horas registradas y los riesgos (ver 5.3.5). El Product Owner acepta el trabajo terminado y reordena el backlog |
| Retrospectiva | Viernes, después de la revisión | 30 minutos | El equipo evalúa su forma de trabajar y acuerda acciones de mejora para el sprint siguiente (ver 7.8) |
| Reunión con el cliente | Aproximadamente cada dos semanas | 1 a 2 horas | Revisión ampliada con los interesados: demostración de los incrementos y validación de requisitos y cambios de alcance (ver 5.3.1) |

**Artefactos de Scrum.**

| Artefacto | Dónde se mantiene | Descripción |
| --- | --- | --- |
| Product backlog | GitHub Projects | Todo el trabajo pendiente, ordenado por prioridad. Sus elementos salen de los requisitos del SRS, de los acuerdos con el cliente, de los paquetes de trabajo de 5.2.1 y de los defectos registrados (ver 7.6) |
| Sprint backlog | GitHub Projects, filtrado por sprint | Elementos comprometidos en el sprint, cada uno con responsable, prioridad, estimación en horas y criterios de aceptación |
| Incremento | Rama `develop` y, en cada liberación, rama `main` | Funcionalidad y documentación terminadas según la definición de terminado |

**Definición de terminado.** Un elemento del backlog está terminado cuando:

1. Cumple sus criterios de aceptación.
2. Su código, sus pruebas y, si aplica, su documentación están en una rama propia integrada a `develop` mediante pull request.
3. Otro integrante revisó y aprobó el pull request.
4. La integración continua pasa: compatibilidad del contrato, reglas de arquitectura y pruebas automáticas.
5. El Product Owner lo aceptó en la revisión del sprint.

**Prácticas de XP.**

| Práctica | Cómo se aplica en el proyecto |
| --- | --- |
| Integración continua | Cada cambio se integra con frecuencia a `develop`, y GitHub verifica en cada pull request el contrato (oasdiff), las reglas de arquitectura (dependency-cruiser) y las pruebas automáticas |
| Revisión por pares y propiedad colectiva del código | Ningún cambio se integra sin la revisión y aprobación de otro integrante. Cualquier integrante puede modificar cualquier parte del código, respetando la autoridad de cada área para las decisiones de diseño |
| Pruebas primero (TDD) | Las reglas de dominio y los endpoints se desarrollan escribiendo primero la prueba unitaria o de contrato y luego el código que la satisface (ver 7.2) |
| Entregas pequeñas | Las tareas se dividen para que quepan en un sprint y se integran en ramas cortas, de modo que cada sprint entrega un incremento utilizable |

**Contrato primero.** Antes de implementar un endpoint se define en el contrato TypeSpec, que la API implementa y la web consume (ver 6.2).

**Relación con los elementos planificados de este plan.** La metodología ágil convive con los compromisos fijos del proyecto:

- Los paquetes de trabajo de 5.2.1 funcionan como épicas del product backlog, y sus subpaquetes se dividen en tareas de sprint.
- Los documentos entregables (SRS, SDD, MTP y manuales) son elementos del backlog con fecha comprometida, y se planifican en el sprint que corresponde a su hito (ver 5.2.2).
- El calendario de 5.2.2 fija los objetivos de cada sprint. El contenido detallado de cada sprint se decide en su planificación.
- El esfuerzo restante se reestima en cada revisión de sprint (ver 5.1.1).
- El congelamiento de funcionalidades del 27/nov (propuesto) cierra la incorporación de funcionalidades nuevas al backlog. Los sprints posteriores se dedican a pruebas formales, corrección de defectos y documentación.

#### 6.1.2 Ciclo de vida del proyecto

- **Inicio del proyecto:** reunión de inicio con el cliente el 5/oct/2026 y análisis de requerimientos. El primer sprint oficial empezó el 26/oct/2026.
- **Flujo de trabajo:** cada tarea sale de un elemento del product backlog, se implementa en una rama propia, pasa por revisión de otro integrante y por integración continua, se integra a `develop` y, al liberar una versión, pasa a `main`.
- **Flujo de información:** el contrato TypeSpec fija los endpoints que la API implementa y la web consume. De él se genera el OpenAPI, que se usa para validar respuestas y pruebas.
- **Ritmo:** sprints semanales con los eventos de Scrum de 6.1.1.
- **Revisiones:** revisión por pares en cada cambio, revisión y retrospectiva de cada sprint y reuniones con el cliente cada dos semanas (ver 6.1.1 y 7.5).
- **Hitos y líneas base:** SRS 6/nov, SDD 11/nov, MTP 25/nov, congelamiento de funcionalidades 27/nov (propuesto) y entrega 11/dic. Cada documento entregado queda como línea base.
- **Aprobaciones:** el cliente aprueba el alcance y la aceptación final (ver 6.4). Los cambios de contrato pasan por el control de compatibilidad.
- **Terminación del proyecto:** entrega el 11/dic/2026 y cierre según 5.5.

No se modifica ningún modelo de proceso estándar de una organización: el equipo adapta Scrum y XP a su tamaño y a los compromisos del proyecto, como se describe en 6.1.1.

### 6.2 Métodos, herramientas y técnicas

El sistema son dos proyectos independientes, una API y una aplicación web, unidos por un contrato escrito en TypeSpec, del que se genera la definición OpenAPI. La API queda expuesta a terceros y permitirá una futura aplicación móvil.

| Componente | Tecnología | Estado |
| --- | --- | --- |
| API (backend) | NestJS | Elegida |
| Aplicación web | React con TypeScript | Elegida |
| Base de datos | PostgreSQL con PostGIS | Elegida |
| Contrato de la API | TypeSpec | Elegido |
| Definición OpenAPI | Generada desde TypeSpec | Elegida |
| Mapas | MapLibre GL JS | En evaluación |
| Notificaciones | Correo electrónico y publicación en grupos de Telegram | En desarrollo |
| Control de versiones | Git y GitHub | Elegido |
| Gestión de tareas | GitHub Projects | Elegida |
| Integración continua | GitHub | Activa |
| Pruebas de la API | express-openapi-validator, Testcontainers, Schemathesis; test runner por elegir (Jest en evaluación) | Elegidas, salvo el runner |
| Pruebas de la web | Playwright | Elegida |
| Reglas de arquitectura y compatibilidad del contrato | dependency-cruiser y oasdiff, en CI | Activas |

**Estrategia de ramas.**

| Rama | Propósito |
| --- | --- |
| `main` | Código en producción. Solo recibe versiones liberadas desde `develop` mediante pull request |
| `develop` | Integra las funcionalidades terminadas |
| Rama por tarea | Una por tarea, integrada a `develop` mediante pull request |

Ningún cambio se integra sin que otro integrante lo revise y lo apruebe.

**Técnicas de diseño.** El diseño se documenta con UML y diagramas de arquitectura en el SDD: casos de uso, componentes o arquitectura, modelo entidad-relación y diagramas de secuencia de los flujos de registrar una queja, recalcular el índice y enviar una notificación.

**Normas técnicas, políticas y procedimientos.** El contrato primero, la revisión por pares obligatoria, el control de compatibilidad del contrato y las reglas de arquitectura comprobadas en CI son las políticas técnicas del proyecto. Las convenciones de código se definen en el SDD (por confirmar).

### 6.3 Plan de infraestructura

| Elemento | Plan |
| --- | --- |
| Entorno de desarrollo | Equipos personales de los integrantes, con el repositorio clonado y PostgreSQL con PostGIS en contenedores para pruebas |
| Repositorios | Dos repositorios de GitHub, API y aplicación web |
| Integración continua | GitHub, con verificación del contrato, reglas de arquitectura y pruebas |
| Entorno de destino | Hosting con plan gratuito o académico, por definir antes del 13/nov |
| Herramientas de gestión y de análisis | GitHub Projects y las herramientas de 6.2 |
| Seguridad física | Corresponde a cada integrante sobre su equipo. No hay oficinas del proyecto |
| Administración y servicios | No aplican |

La infraestructura se establece en el sprint 2 y 3 y la mantiene Carolina Chi como responsable técnica.

### 6.4 Plan de aceptación del producto

El cliente acepta los entregables con criterios objetivos, que deben quedar acordados por escrito y firmados por el equipo y el CINVESTAV antes del 25/nov (propuesto, junto con el MTP).

**Criterios de aceptación propuestos.**

| Criterio | Método |
| --- | --- |
| Hay un mapa por fenómeno (el del agua con capas de calidad y disponibilidad), con las colonias de la ZMG coloreadas según su índice | Demostración |
| Se pueden configurar las características de los fenómenos, añadir fenómenos nuevos y modificar la ponderación de su índice | Demostración y prueba |
| El índice se recalcula automáticamente cada día con ponderación por antigüedad | Prueba y análisis |
| Los usuarios pueden registrar quejas y los analistas eventos asociados a una colonia | Prueba end-to-end |
| Se envían notificaciones de variación a usuarios suscritos por al menos un canal | Demostración |
| Las pruebas de contrato y de aceptación pasan en CI | Revisión de resultados |
| El sistema está desplegado y accesible | Demostración |
| Todos los documentos de 1.1.3 están entregados | Inspección |

Los procesos, métodos y herramientas necesarios para la aceptación son los de 6.2 y se detallan en el MTP.

## 7. Planes de procesos de apoyo

Estos procesos abarcan todo el proyecto y los ejecuta el propio equipo. Se desarrollan con el nivel de detalle posible a esta fecha. El plan de gestión de subcontratistas se omite con justificación en 7.7. Los demás planes están presentes.

### 7.1 Plan de gestión de la configuración

- **Identificación:** el código, el contrato, los documentos y los datos sintéticos se guardan en repositorios de GitHub. Cada versión liberada se etiqueta con un número.
- **Línea base inicial:** un producto de trabajo es línea base cuando se integra a `develop` por pull request aprobado, y una versión liberada lo es cuando pasa a `main`. Los documentos entregados al cliente son línea base desde su entrega.
- **Control de cambios:** cada cambio se pide como tarea o solicitud en GitHub Projects, se implementa en una rama propia y se integra solo tras la revisión y aprobación de otro integrante y el paso de la integración continua. El comité de cambios de 5.3.1 decide los cambios de alcance. Los cambios del contrato pasan por oasdiff.
- **Registro y análisis de solicitudes de cambio:** se registran en GitHub Projects y se analizan en la revisión de sprint.
- **Estado y evaluación:** el historial de Git y el tablero de GitHub Projects dan el estado. La integración continua evalúa la conformidad.
- **Liberación:** el Project Manager coordina el pull request de `develop` a `main`.
- **Notificación de líneas base:** al fijar o cambiar una línea base se avisa al equipo, y al cliente en la siguiente reunión.
- **Herramienta automatizada:** Git y GitHub.
- **Responsable:** Carolina Chi, con apoyo del Project Manager.

### 7.2 Plan de verificación y validación

**Alcance y responsabilidades.** Verifica que el producto cumpla el contrato, los requisitos y el diseño, y valida que sirva al propósito del cliente. Lo conduce Alejandro Labourdette como especialista de pruebas, con participación de todo el equipo.

**Independencia.** El equipo es pequeño, de modo que la independencia se logra separando funciones: quien implementa un cambio no lo aprueba, y las pruebas formales las conduce el especialista de pruebas.

| Actividad | Técnica | Herramienta |
| --- | --- | --- |
| Verificación | Trazabilidad entre requisitos, diseño y pruebas, revisiones de sprint, revisiones por pares y prototipos | GitHub, revisiones de pull request |
| Verificación del contrato | Pruebas generadas desde OpenAPI, validación de respuestas y comparación de versiones | Schemathesis, express-openapi-validator, oasdiff |
| Verificación de arquitectura | Reglas comprobadas en CI | dependency-cruiser |
| Pruebas unitarias | Reglas de dominio sin levantar NestJS ni la base de datos | Test runner por elegir (Jest en evaluación) |
| Pruebas de integración y end-to-end de la API | Llamadas HTTP contra una base de datos real | Testcontainers con PostgreSQL y PostGIS |
| Pruebas end-to-end de la web | Flujos de usuario completos | Playwright |
| Validación | Demostración al cliente y pruebas de aceptación de 6.4 | Reuniones con el CINVESTAV |

Las pruebas unitarias y de contrato corren desde el inicio. Las pruebas formales se ejecutan del 26/nov al 11/dic según el MTP.

### 7.3 Plan de documentación

Todos los documentos entregables y no entregables, con responsable y revisor. El revisor de cada documento es otro integrante, propuesto por rotación (por confirmar).

| Documento | Entregable | Plantilla o norma | Autor | Revisor | Fecha de línea base | Distribución |
| --- | --- | --- | --- | --- | --- | --- |
| SPMP | Sí | IEEE Std 1058-1998 | Alejandro Labourdette | Dulce Navarro | 4/nov | Equipo y CINVESTAV |
| SRS | Sí | Por confirmar (propuesta: IEEE Std 830) | Dulce Navarro | Edgar Torres | 6/nov | Equipo y CINVESTAV |
| SDD | Sí | Por confirmar (propuesta: IEEE Std 1016) | Edgar Torres | Carolina Chi | 11/nov | Equipo y CINVESTAV |
| MTP | Sí | Por confirmar (propuesta: IEEE Std 829) | Alejandro Labourdette | Carolina Chi | 25/nov | Equipo y CINVESTAV |
| Manual de usuario | Sí | Por definir | Dulce Navarro | Alejandro Labourdette | 11/dic | CINVESTAV y usuarios |
| Manual técnico y de despliegue | Sí | Por definir | Carolina Chi | Edgar Torres | 11/dic | CINVESTAV |
| Documentación de la API | Sí | OpenAPI generado desde TypeSpec | Carolina Chi | Edgar Torres | 11/dic | CINVESTAV y terceros |
| Informe final | Sí | Por definir | Alejandro Labourdette | Dulce Navarro | 11/dic | CINVESTAV |
| Código fuente, contrato y repositorio | Sí | Convenciones del SDD | Equipo | Otro integrante, por pull request | 11/dic | CINVESTAV |
| Actas de reuniones, informes de sprint y revisiones | No | Libre | Alejandro Labourdette | Equipo | Continua | Equipo |

Las normas propuestas son una sugerencia basada en la lista de normas del anexo B del estándar. El equipo debe confirmar con el cliente qué plantillas se esperan.

### 7.4 Plan de aseguramiento de la calidad

Garantiza que el proyecto cumple sus compromisos con el proceso y con el producto especificados en el SRS, este plan y las normas y procedimientos aplicables.

- **Procedimientos:** revisión por pares de todo cambio, inspecciones de los documentos antes de entregarlos, revisiones de sprint y auditorías internas de cumplimiento del proceso al fin de cada dos sprints (propuesto).
- **Responsable:** Alejandro Labourdette.
- **Relaciones:** el aseguramiento de la calidad se apoya en la verificación y validación (7.2), las revisiones y auditorías (7.5), la gestión de la configuración (7.1) y las evaluaciones del proceso (7.8).

### 7.5 Plan de revisiones y auditorías

| Tipo | Frecuencia o fecha | Participantes | Método |
| --- | --- | --- | --- |
| Revisiones conjuntas adquirente-proveedor | Aproximadamente cada dos semanas (5/oct, 14/oct y 28/oct realizadas) | Equipo y CINVESTAV | Presentación y validación |
| Revisión de avance de gestión | Semanal, al fin del sprint | Equipo | Comparación con el plan y revisión de riesgos |
| Revisión por pares | Cada pull request | Dos integrantes | Revisión de código y documentos |
| Auditoría de calidad | Cada dos sprints (propuesto) | Responsable de calidad | Lista de comprobación de proceso |
| Revisiones y auditorías del adquirente | Cuando el cliente lo pida | CINVESTAV | Acceso al repositorio y documentos |

Agencias externas que aprueban o regulan algún producto del proyecto: ninguna identificada. Se evaluará en el SRS si aplican normas de protección de datos personales por las quejas que registran los usuarios.

### 7.6 Plan de resolución de problemas

- **Reporte:** los defectos y problemas se registran como tareas en GitHub Projects, con descripción, severidad y responsable.
- **Análisis y prioridad:** se clasifican por severidad y se priorizan en la revisión de cada sprint.
- **Proceso:** se corrigen en una rama propia con revisión por pares y pasan por las pruebas automáticas.
- **Roles:** el desarrollo corrige, la gestión de la configuración integra y el especialista de pruebas verifica la corrección. El comité de cambios decide los problemas que implican cambio de alcance.
- **Seguimiento del esfuerzo:** el tiempo dedicado a corregir se registra aparte para seguir el retrabajo (ver 5.3.6).

### 7.7 Plan de gestión de subcontratistas

Se omite este plan. **Justificación:** el proyecto no tiene subcontratistas. Todo el trabajo lo hacen los cuatro integrantes. Los servicios de hosting, mapas, correo electrónico y Telegram son servicios de terceros contratados como usuario y no aportan productos de trabajo al proyecto. Si esto cambiara, se elaborará un plan de gestión para cada subcontrato con una versión adaptada de este estándar.

### 7.8 Plan de mejora del proceso

- **Evaluación periódica:** en la retrospectiva al cierre de cada sprint (ver 6.1.1) el equipo evalúa qué funcionó y qué mejorar, y registra acciones.
- **Relación con la resolución de problemas:** si un defecto o fallo se repite, se analiza su causa raíz para cambiar el proceso.
- **Aplicación:** las mejoras que no alteran el trabajo en curso se aplican al sprint siguiente. Lo que exige cambios de fondo se anota para el informe final.
- **Responsable:** Alejandro Labourdette.

## 8. Planes adicionales

Estos planes responden a los requisitos del producto y a los acuerdos con el cliente.

| Plan | Tratamiento |
| --- | --- |
| Seguridad y privacidad | Se define en el SRS y el SDD: control de acceso por rol, acceso restringido de analistas y tratamiento de los datos que acompañan a las quejas. Está pendiente evaluar normas de protección de datos personales |
| Instalación y transición del sistema | Se detalla en el manual técnico y de despliegue (WP8) y en el pipeline de despliegue (subpaquete 6.2 de 5.2.1). El sistema se entrega al CINVESTAV con el repositorio y las instrucciones |
| Conversión de datos | Se cargan datos sintéticos para los dos fenómenos. Cargar datos reales queda fuera de esta etapa |
| Capacitación de usuarios | Se cubre con el manual de usuario. No se prevén sesiones de capacitación |
| Mantenimiento y soporte del producto | No se contempla en este proyecto. El código y la documentación se entregan al CINVESTAV |
| Seguridad física (safety) | No aplica |
| Equipos o instalaciones especiales | No aplica |

## 9. Anexos e índice

**Índice de términos.** La lista siguiente remite cada término clave a las cláusulas donde se trata. Los acrónimos están definidos en la cláusula 3.

| Término | Cláusulas |
| --- | --- |
| Aceptación del producto | 6.4 |
| Alerta temprana | 1.1.1 |
| Analista o especialista | 1.1.1, 4.1, 4.3 |
| Auditorías | 7.4, 7.5 |
| Calendario y sprints | 1.1.4, 5.2.2, 6.1.1 |
| Capas del fenómeno del agua | 1.1.1, 3, 6.4 |
| CI (integración continua) | 6.2, 6.3, 7.1 |
| Cierre del proyecto | 5.5 |
| Colonia | 1.1.1, 3 |
| Contrato de la API (TypeSpec y OpenAPI) | 1.1.2, 6.1, 6.2, 7.2 |
| Control de cambios | 5.3.1, 7.1 |
| Correo electrónico | 1.1.1, 5.1.3, 6.2 |
| Datos sintéticos | 1.1.1, 5.2.1, 5.4 |
| Definición de terminado | 3, 6.1.1 |
| Documentación y entregables | 1.1.3, 7.3 |
| Estimación | 5.1.1 |
| Fenómeno | 1.1.1, 3 |
| Formación del personal | 5.1.4 |
| Gestión de la configuración | 6.2, 7.1 |
| Hosting | 5.1.3, 6.3 |
| Índice de la colonia y su ponderación | 1.1.1, 3, 5.2.1, 6.4 |
| Infraestructura | 6.3 |
| Metodología ágil (Scrum y XP) | 3, 4.2, 6.1 |
| Métricas | 5.3.6 |
| Notificaciones | 1.1.1, 5.2.1, 6.2 |
| Personal y roles | 4.3, 5.1.2, 5.2.3 |
| Presupuesto | 1.1.4, 5.2.4, 5.3.3 |
| Product backlog y sprint backlog | 3, 6.1.1 |
| Product Owner y Scrum Master | 3, 4.3, 6.1.1 |
| Pruebas | 6.2, 7.2 |
| Quejas | 1.1.1, 5.2.1 |
| Retrospectiva | 3, 6.1.1, 7.8 |
| Revisión por pares | 6.1.1, 6.2, 7.4, 7.5 |
| Riesgos | 5.4 |
| Subcontratistas | 7.7 |
| Telegram | 1.1.1, 5.1.3, 6.2 |
| Verificación y validación | 7.2 |
