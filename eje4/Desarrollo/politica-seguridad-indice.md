# POLÍTICA GENERAL DE SEGURIDAD PARA APLICACIÓN DE BASE DE DATOS
## Sistema de Seguridad Logística

---

### PORTADA

**Institución:** [Nombre de la Institución]  
**Curso:** Gestión de Bases de Datos  
**Eje:** 4  
**Actividad:** Política de Seguridad para Aplicación de BD  

**Participantes:**
- [Nombre Completo 1] - [Documento de Identidad]
- [Nombre Completo 2] - [Documento de Identidad]  
- [Nombre Completo 3] - [Documento de Identidad]

**Fecha:** Junio 2025

---

## TABLA DE CONTENIDO

1. [Introducción](#introducción)
2. [Objetivos](#objetivos)
3. [Alcance](#alcance)
4. [Marco Normativo](#marco-normativo)
5. [Estructura del Sistema](#estructura-del-sistema)
6. [Políticas de Seguridad](#políticas-de-seguridad)
   - 6.1 [Administración de datos, accesos y privilegios, roles y responsabilidades](./1-administracion-datos-accesos.md)
   - 6.2 [Copias de seguridad, seguridad física y del entorno](./2-copias-seguridad-fisica.md)
   - 6.3 [Recursos humanos, control de acceso](./3-recursos-humanos-control-acceso.md)
   - 6.4 [Desarrollo de aplicaciones, correo electrónico, dispositivos móviles](./4-desarrollo-aplicaciones-dispositivos.md)
7. [Conclusiones](#conclusiones)
8. [Bibliografía](#bibliografía)

---

## INTRODUCCIÓN

En el entorno actual de la gestión logística, la seguridad de los datos se ha convertido en un pilar fundamental para garantizar la continuidad operacional y la protección de información crítica. El Sistema de Seguridad Logística desarrollado en el Eje 3 del curso maneja información sensible relacionada con rutas de transporte, vehículos, empleados, eventos de seguridad y alertas operacionales.

La presente política de seguridad establece un marco integral para la protección, administración y control de la base de datos del sistema, considerando las mejores prácticas en seguridad informática y cumpliendo con los estándares internacionales de protección de datos.

Este documento surge de la necesidad de crear un protocolo robusto que permita a los administradores de base de datos (DBA) gestionar de manera efectiva y segura la información del sistema, minimizando riesgos operacionales y garantizando la integridad, confidencialidad y disponibilidad de los datos.

## OBJETIVOS

### Objetivo General
Establecer una política integral de seguridad para la base de datos del Sistema de Seguridad Logística que garantice la protección, integridad y disponibilidad de la información, mediante la implementación de controles técnicos, administrativos y físicos apropiados.

### Objetivos Específicos

1. **Definir los procedimientos** para la administración de datos, control de accesos, asignación de privilegios y gestión de roles dentro del sistema de base de datos.

2. **Establecer protocolos** para la realización de copias de seguridad, recuperación de datos y protección del entorno físico y lógico donde opera la base de datos.

3. **Implementar controles** para la gestión de recursos humanos y el control de acceso al sistema, incluyendo políticas de autenticación y autorización.

4. **Crear lineamientos** para el desarrollo seguro de aplicaciones, manejo de comunicaciones electrónicas y gestión de dispositivos móviles que interactúan con el sistema.

5. **Garantizar el cumplimiento** de las normativas y estándares de seguridad aplicables a sistemas de información y protección de datos.

## ALCANCE

Esta política de seguridad aplica a:

### **Componentes Técnicos**
- Base de datos `seguridad_logistica` y todas sus tablas asociadas
- Servidor de base de datos y infraestructura de soporte
- Aplicaciones que interactúan con la base de datos
- Redes de comunicación y puntos de acceso
- Sistemas de respaldo y recuperación

### **Recursos Humanos**
- Administradores de Base de Datos (DBA)
- Desarrolladores y personal técnico
- Empleados del sistema logístico (conductores, supervisores)
- Personal administrativo con acceso al sistema
- Contratistas y terceros autorizados

### **Procesos y Procedimientos**
- Gestión de rutas y vehículos
- Registro y seguimiento de eventos y alertas
- Administración de usuarios y permisos
- Procedimientos de backup y recuperación
- Monitoreo y auditoría del sistema

### **Exclusiones**
- Sistemas de terceros no integrados directamente
- Comunicaciones telefónicas no registradas en el sistema
- Documentación física no digitalizada

## MARCO NORMATIVO

Esta política se fundamenta en:

- **ISO 27001:2013** - Sistema de Gestión de Seguridad de la Información
- **ISO 27002:2013** - Código de práctica para controles de seguridad de la información
- **COBIT 5** - Marco de gobierno y gestión de TI empresarial
- **Ley 1581 de 2012** - Protección de Datos Personales (Colombia)
- **Decreto 1377 de 2013** - Reglamentación de la Ley de Protección de Datos
- **NIST Cybersecurity Framework** - Marco de seguridad cibernética

## ESTRUCTURA DEL SISTEMA

El Sistema de Seguridad Logística está compuesto por las siguientes entidades principales:

### **Gestión de Personal**
- **Persona**: Información personal de individuos en el sistema
- **Empleado**: Relación laboral y asignaciones específicas
- **Cargo**: Definición de roles y responsabilidades laborales

### **Gestión de Flota**
- **Vehículo**: Información de la flota de transporte
- **Ruta**: Definición de trayectos y niveles de riesgo
- **Estado**: Control de estados operacionales

### **Gestión de Seguridad**
- **Evento**: Registro de incidentes y situaciones relevantes
- **Alerta**: Sistema automatizado de notificaciones
- **Rol**: Definición de permisos y accesos al sistema
- **TipoAcceso**: Categorización de niveles de acceso
- **HistorialAcceso**: Auditoría de accesos al sistema

### **Relaciones Críticas**
- Trigger automático que genera alertas cuando se registran eventos
- Control de integridad referencial entre todas las entidades
- Sistema de roles y permisos multinivel

## POLÍTICAS DE SEGURIDAD

La política de seguridad se estructura en cuatro componentes principales, cada uno abordado en detalle en documentos específicos:

### 1. Administración de Datos, Accesos y Privilegios
Establece los procedimientos para la gestión de datos, control de accesos, asignación de privilegios y definición de roles y responsabilidades del personal técnico.

### 2. Copias de Seguridad, Seguridad Física y del Entorno
Define los protocolos para la protección física de la infraestructura, procedimientos de backup, recuperación ante desastres y seguridad del entorno operativo.

### 3. Recursos Humanos y Control de Acceso
Establece las políticas para la gestión del personal, procesos de contratación, capacitación en seguridad y control de acceso basado en roles.

### 4. Desarrollo de Aplicaciones, Correo Electrónico y Dispositivos Móviles
Define los lineamientos para el desarrollo seguro de software, gestión de comunicaciones y administración de dispositivos móviles.

## CONCLUSIONES

*(Las conclusiones se completarán una vez desarrollados todos los componentes de la política)*

## 7. CONCLUSIONES Y PRÓXIMOS PASOS

### 7.1 Implementación Exitosa

La **Política Integral de Seguridad para Sistema Logístico** ha sido desarrollada siguiendo estándares internacionales y mejores prácticas, proporcionando:

#### **Cobertura Completa**
- ✅ **Componente 1**: Administración de datos y control de accesos con 6 roles específicos
- ✅ **Componente 2**: Backup, seguridad física y continuidad operacional  
- ✅ **Componente 3**: Gestión de recursos humanos y control de acceso físico
- ✅ **Componente 4**: Desarrollo seguro, email corporativo y dispositivos móviles

#### **Características Técnicas Implementadas**
- **Scripts SQL Automatizados**: +50 procedimientos, funciones y triggers
- **Monitoreo en Tiempo Real**: Sistemas de alertas y auditoría automatizada
- **Control de Acceso Granular**: RBAC con permisos específicos por tabla y operación
- **Integración Completa**: Referencia directa a la estructura real del sistema logístico

### 7.2 Beneficios Operacionales

#### **Seguridad Robusta**
- Protección multinivel contra amenazas internas y externas
- Detección automatizada de vulnerabilidades y ataques
- Respuesta automática a incidentes críticos

#### **Cumplimiento Normativo**
- Alineación con ISO 27001/27002
- Cumplimiento de regulaciones colombianas (Ley 1581/2012)
- Preparación para auditorías de seguridad

#### **Operación Eficiente**
- Automatización de tareas repetitivas de seguridad
- Reducción de errores humanos mediante controles sistémicos
- Visibilidad completa del estado de seguridad

### 7.3 Roadmap de Implementación

#### **Fase 1: Preparación (Semanas 1-2)**
- [ ] Configuración de entornos de desarrollo y pruebas
- [ ] Capacitación del equipo técnico en nuevos procedimientos
- [ ] Validación de scripts en ambiente controlado

#### **Fase 2: Implementación Gradual (Semanas 3-6)**
- [ ] Despliegue del Componente 1 (Administración de datos)
- [ ] Migración de usuarios existentes al nuevo sistema RBAC
- [ ] Implementación del Componente 2 (Backup y seguridad física)
- [ ] Activación de monitoreo automatizado

#### **Fase 3: Expansión (Semanas 7-10)**
- [ ] Despliegue del Componente 3 (Recursos humanos)
- [ ] Implementación del Componente 4 (Aplicaciones y móviles)
- [ ] Integración completa de sistemas de alerta

#### **Fase 4: Operación y Mejora Continua (Ongoing)**
- [ ] Monitoreo 24/7 de métricas de seguridad
- [ ] Revisiones trimestrales de políticas
- [ ] Actualizaciones basadas en nuevas amenazas

### 7.4 Métricas de Éxito

#### **KPIs de Seguridad**
- **Tiempo de Detección de Incidentes**: < 15 minutos
- **Tiempo de Respuesta a Alertas Críticas**: < 30 minutos  
- **Disponibilidad del Sistema**: > 99.5%
- **Cumplimiento de Backup**: 100% exitoso

#### **KPIs Operacionales**
- **Reducción de Incidentes Manuales**: > 80%
- **Tiempo de Recuperación (RTO)**: < 4 horas
- **Punto de Recuperación (RPO)**: < 1 hora
- **Satisfacción del Usuario**: > 85%

### 7.5 Valor Agregado

Esta política no solo cumple con los requisitos académicos establecidos, sino que proporciona:

1. **Implementación Práctica Real**: Scripts ejecutables y procedimientos detallados
2. **Escalabilidad**: Diseño modular que permite crecimiento futuro
3. **Mantenibilidad**: Documentación técnica completa y procedimientos claros
4. **Innovación**: Integración de tecnologías modernas de seguridad

---

## BIBLIOGRAFÍA

1. International Organization for Standardization. (2013). *ISO/IEC 27001:2013 Information technology — Security techniques — Information security management systems — Requirements*.

2. International Organization for Standardization. (2013). *ISO/IEC 27002:2013 Information technology — Security techniques — Code of practice for information security controls*.

3. ISACA. (2012). *COBIT 5: A Business Framework for the Governance and Management of Enterprise IT*.

4. National Institute of Standards and Technology. (2018). *Framework for Improving Critical Infrastructure Cybersecurity Version 1.1*.

5. Congreso de Colombia. (2012). *Ley 1581 de 2012 - Por la cual se dictan disposiciones generales para la protección de datos personales*.

6. Presidente de la República de Colombia. (2013). *Decreto 1377 de 2013 - Por el cual se reglamenta parcialmente la Ley 1581 de 2012*.

---

**Nota:** Este documento forma parte de un conjunto de políticas interrelacionadas. Para una comprensión completa, se debe consultar la documentación específica de cada componente referenciado en la sección 6.
