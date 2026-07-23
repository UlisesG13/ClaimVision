# Validaciones
Documentar cada uno de los tipos de entrada de datos y su forma de validación mostrando las llamadas a función y bloques de código, en caso de usar librerias o frameworks para estas tareas también documentar el origen y el uso.

Esta actividad, se integrará al documento que ya están realizando. Se anexa un checklist para que recuerdes lo que has hecho y lo que aun falta, este checklist se completa con el "como lo haces?" o "porque no lo haces?" o "porque no aplica en tu proyecto?".

## Checklist - validaciones

Checklist de validaciones de entradas de datos
1. Validación del lado del cliente
Validación de formato:
Validación de longitud:
Validación de rango:
Validación de contenido:
Validación de expresiones regulares (regex):
2. Validación del lado del servidor
Validación de autenticidad:
Validación de consistencia:
Validación de integridad:
Validación de permisos:
3. Validación de tipo
Verifica que los datos ingresados correspondan al tipo esperado (por ejemplo, texto,
número, fecha).
4. Validación de lógica de negocio
Asegura que los datos cumplan con las reglas específicas de la lógica de negocio de
la aplicación. Por ejemplo, en una aplicación de comercio electrónico, verificar que el
número de artículos en un pedido no exceda el inventario disponible.
5. Validación de patrones y reglas específicas
Direcciones de correo electrónico:
Números de tarjeta de crédito:
Contraseñas:
Otros:
6. Validación cruzada
Comparar varios campos entre sí para verificar coherencia y validez. Por ejemplo,
asegurarse de que la "fecha de inicio" no sea posterior a la "fecha de finalización".
7. Validación contextual
Asegurar que los datos sean válidos en el contexto específico en que se utilizan. Por
ejemplo, validar que una dirección de envío se encuentre dentro de las áreas de
servicio de una tienda.

8. Sanitización de entrada
a. Escapado de Caracteres
HTML Escaping:
JavaScript Escaping:
SQL Escaping:
b. Filtrado de Entradas
Whitelisting (Lista Blanca):
Blacklisting (Lista Negra):
c. Validación de Tipo de Datos
Tipos Primitivos:
Estructuras de Datos:
d. Limpieza de Entradas (Input Cleaning)
Trim:
Normalize:
e. Codificación de Entradas (Input Encoding)
Base64 Encoding:
URL Encoding:
f. Uso de Funciones y Librerías Seguras
ORMs (Object-Relational Mappers):
Librerías de Escapado:
g. Reemplazo de Caracteres
Reemplazo de Comillas:
Reemplazo de Scripts:
h. Canonicalización
Path Normalization:
Case Normalization:
i. Escape Output Contextually
HTML Context:

JavaScript Context:
URL Context:
j. Revisiones y Auditorías de Código
Código Estático:
Pruebas de penetración:

9. Uso de librerías y frameworks de validación
Utilizar librerías y frameworks de validación que implementan las mejores prácticas y
se mantienen actualizados con los últimos estándares de seguridad.
10. Educación y Capacitación del Equipo
Asegurarse de que todos los desarrolladores estén capacitados en las mejores
prácticas de validación y sanitización de entradas. Por lo que se les recomienda
asistir y organizar talleres y cursos sobre seguridad en el desarrollo de software.
11. Gestión de Errores Adecuada
Manejar los errores de validación de manera que no revelen información sensible o
que pueda ser explotada por atacantes.

## Validaciones de entrada

Los tipos principales de validación de entrada de datos en el desarrollo de aplicaciones
móviles:
1. Validación del lado del cliente
Esta validación se realiza en el dispositivo del usuario antes de que los datos se envíen al
servidor. Es útil para mejorar la experiencia del usuario al proporcionar retroalimentación
inmediata.
● Validación de formato: Verifica si los datos cumplen con un formato específico (por
ejemplo, una dirección de correo electrónico, un número de teléfono, una fecha).
● Validación de longitud: Asegura que los datos no sean demasiado cortos o
demasiado largos.
● Validación de rango: Garantiza que los datos numéricos estén dentro de un rango
específico (por ejemplo, edades entre 18 y 65 años).
● Validación de contenido: Revisa que los datos no contengan caracteres no
permitidos o peligrosos (por ejemplo, caracteres especiales en nombres).
● Validación de expresiones regulares (regex): Usa patrones definidos para
comprobar que los datos cumplen ciertos criterios.
2. Validación del lado del servidor
Esta validación se realiza una vez que los datos han sido enviados al servidor. Es
fundamental ya que los datos pueden ser manipulados en el cliente antes de ser enviados.
● Validación de autenticidad: Verifica la autenticidad de los datos recibidos (por
ejemplo, tokens de autenticación).
● Validación de consistencia: Asegura que los datos recibidos estén en un estado
coherente (por ejemplo, relaciones entre tablas en una base de datos).
● Validación de integridad: Comprueba que los datos no hayan sido alterados
durante la transmisión.
● Validación de permisos: Asegura que el usuario tenga los permisos necesarios
para realizar ciertas acciones.
3. Validación de tipo
Verifica que los datos ingresados correspondan al tipo esperado (por ejemplo, texto,
número, fecha).
4. Validación de lógica de negocio
Asegura que los datos cumplan con las reglas específicas de la lógica de negocio de la
aplicación. Por ejemplo, en una aplicación de comercio electrónico, verificar que el número
de artículos en un pedido no exceda el inventario disponible.

5. Validación de patrones y reglas específicas
Implemente reglas y patrones específicos para campos particulares, como:
● Direcciones de correo electrónico: Verificar que el formato y el dominio sean
válidos.
● Números de tarjeta de crédito: Usar algoritmos como Luhn para validar el número.
● Contraseñas: Comprobar la fortaleza mediante requisitos como longitud mínima,
mezcla de caracteres, etc.
6. Validación cruzada
Comparar varios campos entre sí para verificar coherencia y validez. Por ejemplo,
asegurarse de que la "fecha de inicio" no sea posterior a la "fecha de finalización".
7. Validación contextual
Asegurar que los datos sean válidos en el contexto específico en que se utilizan. Por
ejemplo, validar que una dirección de envío se encuentre dentro de las áreas de servicio de
una tienda.
8. Sanitización de entrada
Procesar los datos para eliminar o neutralizar cualquier entrada maliciosa (por ejemplo,
scripts de inyección SQL o XSS).
La sanitización de entrada es un proceso crucial en ciberseguridad y desarrollo de
aplicaciones móviles para asegurarse de que los datos ingresados por los usuarios
no contengan contenido malicioso que pueda comprometer la seguridad de la
aplicación y del sistema en general. A continuación, se describen todas las formas
comunes de sanitización de entrada:
a. Escapado de Caracteres
Transformar caracteres especiales en secuencias inofensivas antes de almacenarlos
o mostrarlos.
● HTML Escaping: Convierte caracteres especiales como <, >, & en entidades
HTML (&lt;, &gt;, &amp;).
● JavaScript Escaping: Escapa caracteres como " y ' para prevenir
inyección de código JavaScript.
● SQL Escaping: Escapa caracteres peligrosos en consultas SQL para
prevenir inyección SQL.
b. Filtrado de Entradas
Eliminar o reemplazar caracteres no deseados o potencialmente peligrosos.

● Whitelisting (Lista Blanca): Permitir solo caracteres conocidos y seguros,
por ejemplo, solo letras y números para un nombre de usuario.
● Blacklisting (Lista Negra): Bloquear caracteres específicos conocidos por
ser peligrosos, aunque es menos seguro que el whitelisting.
c. Validación de Tipo de Datos
Verificar que los datos ingresados coincidan con el tipo de datos esperado (números,
cadenas, fechas, etc.).
● Tipos Primitivos: Asegurar que los datos sean del tipo correcto, por
ejemplo, números en lugar de cadenas.
● Estructuras de Datos: Validar que las estructuras complejas (JSON, XML)
tengan el formato correcto y esperado.
d. Limpieza de Entradas (Input Cleaning)
Eliminar caracteres innecesarios o peligrosos.
● Trim: Eliminar espacios en blanco al inicio y al final de las cadenas.
● Normalize: Convertir los caracteres a una forma estándar, como pasar todas
las letras a minúsculas o mayúsculas.
e. Codificación de Entradas (Input Encoding)
Transformar los datos en un formato seguro para ser procesado o almacenado.
● Base64 Encoding: Utilizado para convertir datos binarios en una
representación textual segura.
● URL Encoding: Convierte caracteres en una URL en su representación de
% (por ejemplo, en %20).
f. Uso de Funciones y Librerías Seguras
Utilizar funciones y librerías que manejan la sanitización de manera correcta y
segura.
● ORMs (Object-Relational Mappers): Usar ORMs para interactuar con bases
de datos, lo cual puede ayudar a prevenir inyecciones SQL automáticamente.
● Librerías de Escapado: Usar librerías específicas para escapar y sanitizar
entradas, como OWASP ESAPI (Enterprise Security API).
g. Reemplazo de Caracteres
Sustituir caracteres problemáticos con alternativas seguras.
● Reemplazo de Comillas: Reemplazar comillas simples y dobles con su
equivalente escapado.

● Reemplazo de Scripts: Remover o reemplazar etiquetas de script en
contenido HTML.
h. Canonicalización
Convertir datos a una forma canónica o estándar para evitar diferentes
representaciones del mismo valor que podrían ser utilizadas maliciosamente.
● Path Normalization: Convertir rutas de archivo a su forma absoluta y
normalizada.
● Case Normalization: Convertir cadenas a un caso único (mayúsculas o
minúsculas).
i. Escape Output Contextually
Escapar los datos según el contexto en el que se van a utilizar.
● HTML Context: Escapar datos antes de insertarlos en HTML.
● JavaScript Context: Escapar datos antes de utilizarlos en JavaScript.
● URL Context: Escapar datos antes de utilizarlos en URLs.
j. Revisiones y Auditorías de Código
Revisar y auditar el código regularmente para asegurar que las entradas se están
sanitizando adecuadamente.
● Código Estático: Usar herramientas de análisis de código estático para
detectar posibles vulnerabilidades.
● Pruebas de penetración: Realizar pruebas de penetración para identificar y
corregir debilidades en la sanitización de entradas.
Implementar estas formas de sanitización de entrada es esencial para proteger las
aplicaciones móviles contra ataques como inyección SQL, Cross-Site Scripting
(XSS), inyección de comandos, y otros tipos de explotación que pueden
comprometer la seguridad y la integridad del sistema.
9. Uso de librerías y frameworks de validación
Utilizar librerías y frameworks de validación que implementan las mejores prácticas y se
mantienen actualizados con los últimos estándares de seguridad.
Implementar adecuadamente estos tipos de validación es esencial para asegurar que las
aplicaciones móviles sean robustas, seguras y fiables, protegiendo tanto a los usuarios
como a los sistemas que las soportan.

10. Educación y Capacitación del Equipo
● Asegurarse de que todos los desarrolladores estén capacitados en las mejores
prácticas de validación y sanitización de entradas. Por lo que se les recomienda
asistir y organizar talleres y cursos sobre seguridad en el desarrollo de software.
11. Gestión de Errores Adecuada
● Manejar los errores de validación de manera que no revelen información sensible o
que pueda ser explotada por atacantes.