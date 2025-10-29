<!-- TOC start (generated with https://github.com/derlin/bitdowntoc) -->

- [📸 Media Renamer: organizador de fotos y vídeos basado en EXIF](#-media-renamer-organizador-de-fotos-y-vídeos-basado-en-exif)
   * [🎯 Por qué existe este proyecto](#-por-qué-existe-este-proyecto)
   * [✨ Características principales](#-características-principales)
   * [📋 Requisitos](#-requisitos)
   * [⚠️ Compatibilidad probada](#%EF%B8%8F-compatibilidad-probada)
      + [MacOs](#macos)
      + [Linux (Ubuntu, Debian) o CentOS/Fedora](#linux-ubuntu-debian-o-centosfedora)
   * [Instalación de ExifTool](#instalación-de-exiftool)
   * [🚀 Instalación](#-instalación)
   * [📖 Uso](#-uso)
      + [Basic Syntax](#basic-syntax)
      + [Parámetros esenciales](#parámetros-esenciales)
      + [Personalización de nombres](#personalización-de-nombres)
      + [Selección del tipo de archivo](#selección-del-tipo-de-archivo)
      + [Modos de funcionamiento](#modos-de-funcionamiento)
         - [modo renombrar](#modo-renombrar)
         - [directorio de salida](#directorio-de-salida)
      + [Opciones avanzadas](#opciones-avanzadas)
         - [use_date_name](#use_date_name)
         - [ignore directories](#ignore-directories)
         - [modo de depuración](#modo-de-depuración)
   * [🧪 Ejemplo de uso con el directorio `sandbox`](#-ejemplo-de-uso-con-el-directorio-sandbox)
      + [📁 Estructura del ejemplo](#-estructura-del-ejemplo)
      + [▶️ Ejemplo 1: renombrar fotos genéricas](#%EF%B8%8F-ejemplo-1-renombrar-fotos-genéricas)
      + [▶️ Ejemplo 2: renombrar fotos con prefijo estilo WhatsApp](#%EF%B8%8F-ejemplo-2-renombrar-fotos-con-prefijo-estilo-whatsapp)
   * [💡 Casos de uso comunes](#-casos-de-uso-comunes)
      + [Organizar fotos de la cámara de Android](#organizar-fotos-de-la-cámara-de-android)
      + [Procesamiento de imágenes de WhatsApp con prefijo](#procesamiento-de-imágenes-de-whatsapp-con-prefijo)
      + [Renombrado rápido in situ (utilizar con precaución)](#renombrado-rápido-in-situ-utilizar-con-precaución)
      + [Procesar solo tipos de archivos específicos](#procesar-solo-tipos-de-archivos-específicos)
      + [Procesamiento de formatos HEIC y RAW desde iPhone](#procesamiento-de-formatos-heic-y-raw-desde-iphone)
   * [📁 Formato de salida](#-formato-de-salida)
      + [Ejemplos de transformaciones](#ejemplos-de-transformaciones)
   * [🔍 Cómo funciona](#-cómo-funciona)
   * [🛡️ Funciones de seguridad](#-funciones-de-seguridad)
   * [⚠️ Advertencias importantes](#%EF%B8%8F-advertencias-importantes)
   * [🐛 Solución de problemas](#-solución-de-problemas)
   * [🤝 Contribuciones](#-contribuciones)
   * [📄 Licencia](#-licencia)
   * [🙏 Agradecimientos](#-agradecimientos)
   * [📞 Asistencia](#-asistencia)

<!-- TOC end -->


# 📸 Media Renamer: organizador de fotos y vídeos basado en EXIF

[English](README.md) | Español

Un script Bash para renombrar por lotes fotos y vídeos utilizando las fechas de sus metadatos EXIF.  
Nació de la necesidad de resolver el problema habitual de tener múltiples copias de seguridad con las mismas fotos bajo diferentes nombres, lo que complica la organización y eliminación de duplicados.

El proyecto surgió tras años de intentar consolidar fotos familiares provenientes de distintos teléfonos, servicios en la nube y copias de seguridad. La frustración de encontrar la misma imagen cinco veces con cinco nombres distintos llevó a crear una herramienta que automatiza ese proceso de forma coherente.

> 💬 **Nota del autor**  
> Mis conocimientos de Bash son limitados y he intentado mantener el código lo más claro y comprensible posible.  
> Aun así, puede contener errores o partes mejorables.  
> Se agradecen sugerencias y *pull requests* que ayuden a mejorar la claridad o la fiabilidad del script.

## 🎯 Por qué existe este proyecto

Cuando se gestionan múltiples copias de seguridad de fotos de diferentes fuentes, como teléfonos Android, iPhones, WhatsApp, Google Photos o servicios de almacenamiento en la nube, a menudo se termina con la misma foto guardada con diferentes nombres. Por ejemplo, una sola foto de vacaciones puede aparecer como "IMG_1234.jpg" en una copia de seguridad, "20230814_153045.jpg" en otra y "IMG-20230814-WA0023.jpg" en una carpeta de WhatsApp.

Este script resuelve ese problema renombrando todos tus archivos multimedia con un formato coherente basado en su fecha de creación original almacenada en los metadatos EXIF. Una vez renombradas, las fotos idénticas tendrán el mismo nombre de archivo independientemente de su origen, lo que facilita la identificación y eliminación de duplicados con herramientas de deduplicación estándar.

El script es especialmente útil para situaciones como la consolidación de años de fotos de varios dispositivos, la organización de colecciones de fotos familiares o la preparación de bibliotecas multimedia para el almacenamiento de archivos a largo plazo.


## ✨ Características principales

**La detección inteligente de fechas** significa que el script lee los metadatos EXIF DateTimeOriginal para determinar cuándo se tomó realmente cada foto o vídeo, y no cuándo se modificó o copió por última vez. Esto garantiza que los archivos se renombren en función de su momento real de creación.

**La prioridad de la fecha del nombre de archivo** proporciona un mecanismo de seguridad por el que, si el script detecta un patrón de fecha en el nombre de archivo existente que difiere significativamente de los datos EXIF (más de 180 días de diferencia), asume que el nombre de archivo es más fiable y actualiza los metadatos EXIF en consecuencia. Esto permite gestionar los casos en los que los datos EXIF pueden estar dañados o faltar.

**Los modos de funcionamiento seguro** le ofrecen dos formas de trabajar: un modo de copia que conserva intactos sus archivos originales mientras crea copias renombradas en un directorio separado, y un modo de renombrado in situ para cuando está seguro y desea un procesamiento más rápido sin duplicar datos.

**Los patrones de nomenclatura personalizables** le permiten añadir prefijos para distinguir las fuentes (como "WA_" para las fotos de WhatsApp) y sufijos para la categorización, lo que le ofrece un control total sobre su convención de nomenclatura, al tiempo que mantiene la estructura básica basada en la marca de tiempo.

**La detección automática de panorámicas** reconoce los archivos MPO (el formato utilizado para las fotos panorámicas en algunos dispositivos) y añade automáticamente el sufijo "_PANO" para ayudarte a identificar estos archivos especiales en tu colección.

**El procesamiento selectivo de directorios** significa que puede seleccionar nombres de carpetas específicos dentro de su estructura de copia de seguridad (como "DCIM" para las fotos de la cámara o "WhatsApp" para los archivos multimedia de la aplicación de mensajería) e ignorar automáticamente los directorios de salida y otras carpetas especificadas para evitar problemas de procesamiento recursivo.

## 📋 Requisitos

Antes de utilizar este script, debe asegurarse de que su sistema tiene instaladas las herramientas necesarias. El script requiere Bash versión 3.2 o superior, que es estándar en macOS y en la mayoría de las distribuciones de Linux. La única dependencia externa es ExifTool, una potente aplicación de línea de comandos para leer y escribir metadatos EXIF.

## ⚠️ Compatibilidad probada
### MacOs
Probado en **macOS 14.6.1 (Apple Silicon)** utilizando la herramienta [`exiftool`](https://exiftool.org/).  
Verificado tanto con archivos locales en SSD como con archivos en una unidad de red SMB conectada desde un equipo con **Windows 10** en red local.  

### Linux (Ubuntu, Debian) o CentOS/Fedora
No se ha verificado su funcionamiento en entornos **Linux**, **CentOS** u otros sistemas operativos, por lo que podrían requerirse ajustes adicionales (por ejemplo, rutas, permisos o diferencias en la salida de comandos).

## Instalación de ExifTool

En macOS con Homebrew, puede instalar ExifTool con un solo comando:

```bash
brew install exiftool
```

En sistemas Linux basados en Ubuntu o Debian, la instalación es igualmente sencilla:

```bash
sudo apt-get install libimage-exiftool-perl
```

En sistemas Fedora, RHEL o CentOS, utilice el siguiente comando:

```bash
sudo dnf install perl-Image-ExifTool
```

Después de la instalación, puede verificar que ExifTool se ha instalado correctamente comprobando su versión:

```bash
exiftool -ver
```

Esto debería mostrar un número de versión, lo que confirma que la herramienta está lista para su uso.

## 🚀 Instalación

Comenzar a utilizar Media Renamer es muy sencillo. En primer lugar, clone el repositorio en su máquina local:

```bash
git clone https://github.com/hunzaGit/rename-files-with-exif.git
cd rename-files-with-exif
```

A continuación, haga que el script sea ejecutable para poder ejecutarlo directamente:

```bash
chmod +x rename_files.sh
```

Eso es todo lo que tienes que hacer. El script ya está listo para usar y no requiere ninguna compilación ni configuración adicional.

## 📖 Uso

El script sigue un patrón sencillo de interfaz de línea de comandos en el que se especifica un directorio de origen y parámetros opcionales para controlar su comportamiento. En su forma más básica, debes indicar al script dónde se encuentran tus fotos.


### Basic Syntax

```bash
./rename_files.sh --source <directory> [options]
```

### Parámetros esenciales

El parámetro **source directory** es el único argumento obligatorio e indica al script dónde comenzar a buscar los archivos multimedia. Debe ser el directorio raíz que contiene las copias de seguridad o las colecciones de fotos:

```bash
--source <ruta>  o  -s <ruta>
```

El parámetro **target directory** especifica los nombres de los subdirectorios que se deben buscar dentro del origen. Esto resulta útil cuando las copias de seguridad tienen una estructura coherente. Por ejemplo, las copias de seguridad de Android suelen almacenar las fotos de la cámara en carpetas llamadas "DCIM", mientras que las imágenes de WhatsApp se encuentran en carpetas llamadas "WhatsApp":

```bash
--target <nombre>  o  -t <nombre>
```

El valor predeterminado es "DCIM", que coincide con el nombre estándar de la carpeta de la cámara que utilizan los dispositivos Android y muchas cámaras digitales.


### Personalización de nombres

El parámetro **prefix** añade texto al principio de los archivos renombrados, lo que resulta útil para identificar el origen de las fotos. Por ejemplo, puede utilizar "WA" para las fotos de WhatsApp o "IPHONE" para las copias de seguridad del iPhone:

```bash
--prefijo <texto>  o  -p <texto>
```

Una foto tomada el 14 de agosto de 2023 a las 3:45 p. m. con el prefijo "WA" se convertiría en `WA_20230814_154500.jpg`.

El parámetro **suffix** añade texto al final del nombre del archivo (antes de la extensión), lo que resulta útil para una categorización adicional:

```bash
--suffix <texto>
```

El uso del sufijo "backup" transformaría la misma foto en "20230814_154500_backup.jpg".

### Selección del tipo de archivo

El parámetro **extensions** controla qué tipos de archivos se procesan. De forma predeterminada, el script maneja formatos de foto comunes (JPG, JPEG, PNG, HEIC, DNG) y formatos de vídeo (MP4, MOV, 3GP), además de MPO para panorámicas:

```bash
--ext "<extensions>"  o  -e "<extensions>"
```

Por ejemplo, para procesar solo archivos JPG y MP4, se utilizaría `--ext "jpg mp4"`.


### Modos de funcionamiento
#### modo renombrar
El parámetro **rename mode** determina si el script modifica los archivos originales o crea copias. Esta es una de las características de seguridad más importantes:

```bash
--rename <true|false>  o  -r <true|false>
```

Cuando se establece en false (el valor predeterminado y recomendado para el primer uso), el script copia los archivos a un nuevo directorio mientras los renombra, dejando los originales completamente intactos. Cuando se establece en true, renombra los archivos en su ubicación original, lo que es más rápido y no utiliza espacio adicional en el disco, pero modifica permanentemente los archivos originales.


#### directorio de salida
El parámetro **output directory** especifica dónde se deben colocar las copias renombradas cuando el modo de renombrado es false:

```bash
--output <directorio>  o  -o <directorio>
```

El valor predeterminado es "renamed", que crea un subdirectorio junto a cada archivo procesado.


### Opciones avanzadas
#### use_date_name
El parámetro **use date name** controla si el script debe confiar en las fechas que se encuentran en los nombres de archivo existentes por encima de los datos EXIF cuando hay una discrepancia significativa:

```bash
--use_date_name <true|false>  o  -dn <true|false>
```

El valor predeterminado es true, lo que significa que si un nombre de archivo contiene una fecha que difiere de la fecha EXIF en más de **180 días**, la fecha del nombre de archivo se considera más fiable y los datos EXIF se actualizarán para que coincidan con ella.

Me ha resultado especialmente util en un backup de Whatsapp, donde los nombre de archivo tenian la fecha real y los datos EXIF eran incorrectos. En esta caso se pierde la hora de la image pero se mantiene la fecha original.

> ⚠️ **Opción experimental**:
> Esta funcionalidad aún es experimental y puede no funcionar de forma consistente en todos los casos.
> Se recomienda usarla solo para pruebas o cuando los nombres de archivo sean de confianza.

#### ignore directories
El parámetro **ignore directories** le permite especificar los nombres de las carpetas que deben omitirse durante el procesamiento:

```bash
--ignore <dir1,dir2,dir3>  o  -i <dir1,dir2,dir3>
```

Los directorios se especifican como una lista separada por comas sin espacios. El directorio de salida se añade automáticamente a esta lista para evitar que se procesen los mismos archivos repetidamente.


#### modo de depuración

El parámetro **debug mode** habilita el registro detallado que muestra exactamente lo que hace el script en cada paso:

```bash
--debug <true|false>  o  -d <true|false>
```

Esto es increíblemente útil cuando se empieza a utilizar el script o cuando se resuelven problemas.

## 🧪 Ejemplo de uso con el directorio `sandbox`

El repositorio incluye un directorio `sandbox/` con ejemplos listos para probar el funcionamiento del script sin necesidad de usar tus propias fotos.

### 📁 Estructura del ejemplo
```
sandbox/
├── photos/
│ ├── pexels-francesco-ungaro-2325447.jpg
│ ├── pexels-... (otras imágenes de ejemplo)
│ └── ...
└── WhatsApp/
  └── Media/
    └── WhatsApp Images/
      └── pexels-mastercowley-1128797.jpg
```

Las imágenes utilizadas proceden de [Pexels](https://www.pexels.com/), bajo licencia libre, y se incluyen únicamente con fines demostrativos:

- [Foto de Francesco Ungaro en Pexels](https://www.pexels.com/photo/hot-air-balloon-2325447/)  
- [Foto de Philippe Donn en Pexels](https://www.pexels.com/photo/brown-hummingbird-selective-focus-photography-1133957/)  
- [Foto de Pixabay en Pexels](https://www.pexels.com/photo/green-leafed-tree-beside-body-of-water-during-daytime-158063/)  
- [Foto de Nathan Cowley en Pexels](https://www.pexels.com/photo/pink-flowers-photography-1128797/)  

---

### ▶️ Ejemplo 1: renombrar fotos genéricas

Ejecuta el script desde la raíz del proyecto:

```bash
./rename_files.sh \
  --source ./sandbox \
  --target "photos" \
  --rename false \
  --output "renamed" \
  --debug true
```

Esto procesará las fotos del directorio `sandbox/photos` y generará los resultados renombrados (o simulados, según --rename) en `sandbox/photos/renamed`.

### ▶️ Ejemplo 2: renombrar fotos con prefijo estilo WhatsApp

Ejecuta el script desde la raíz del proyecto:

```bash
./rename_files.sh \
  --source ./sandbox \
  --target "WhatsApp" \
  --prefix "WA" \
  --rename false \
  --output "renamed" \
  --ignore "old,temp" \
  --debug true
```

Este comando procesa las imágenes del directorio `sandbox/WhatsApp/Media/WhatsApp Images/`, aplicando el prefijo WA a los nombres generados y omitiendo los directorios que contengan old o temp.


> 💡 Nota:
> Los ejemplos anteriores se ejecutan en modo --debug true, lo que permite ver las operaciones simuladas sin modificar realmente los archivos.
> Ajusta --rename true si deseas aplicar los cambios en disco.

## 💡 Casos de uso comunes

Permítame mostrarle varios escenarios reales en los que este script destaca, mostrándole los comandos exactos que utilizaría y qué esperar.

### Organizar fotos de la cámara de Android

Cuando tiene copias de seguridad de un teléfono Android y desea cambiar el nombre de todas las fotos de la cámara sin modificar los originales, este es el enfoque más seguro para empezar:

```bash
./rename_files.sh \
  --source "/Users/me/PhoneBackups" \
  --target "DCIM" \
  --rename false \
  --output "renamed" \
  --debug true
```

Este comando busca en tus copias de seguridad cualquier carpeta llamada "DCIM", procesa todos los formatos de imagen y vídeo compatibles, crea copias renombradas en subdirectorios "renamed" y te muestra información detallada sobre el progreso. Tus archivos originales permanecen completamente inalterados, por lo que puedes verificar los resultados antes de decidir utilizar las versiones renombradas.


### Procesamiento de imágenes de WhatsApp con prefijo

Las imágenes de WhatsApp suelen tener nombres confusos, y añadir un prefijo te ayuda a identificarlas más tarde cuando se consolidan varias fuentes:

```bash
./rename_files.sh \
  --source "/Users/me/Backups" \
  --target "WhatsApp" \
  --prefix "WA" \
  --rename false \
  --output "renamed" \
  --ignore "old,temp" \
  --debug true
```

Esto procesa cualquier carpeta llamada "WhatsApp", añade "WA_" al principio de cada archivo renombrado e ignora cualquier carpeta llamada "old" o "temp". El resultado son archivos como `WA_20230814_154500.jpg`, que están claramente marcados como originales de WhatsApp.

### Renombrado rápido in situ (utilizar con precaución)
> ⚠️ **Utilizar con precaución**:

Una vez que hayas probado el script y estés seguro de los resultados, puedes utilizar el renombrado in situ para ganar velocidad:

```bash
./rename_files.sh \
  --source "/Users/me/PhotoArchive" \
  --target "DCIM" \
  --rename true \
  --debug false
```

Esto renombra directamente los archivos originales sin crear copias. Es mucho más rápido y no requiere espacio adicional en el disco, pero no se puede deshacer la operación, así que asegúrate de tener copias de seguridad antes de utilizar este modo.


### Procesar solo tipos de archivos específicos

Si solo desea organizar vídeos e ignorar completamente las fotos:

```bash
./rename_files.sh \
  --source "/Users/me/Videos" \
  --target "Camera" \
  --ext "mp4 mov" \
  --rename false \
  --output "renamed_videos"
```

Esto procesa solo archivos MP4 y MOV, dejando intactos todos los formatos de foto.

### Procesamiento de formatos HEIC y RAW desde iPhone

Los iPhone modernos utilizan el formato HEIC para las fotos, y es posible que tengas una mezcla de formatos para procesar:

```bash
./rename_files.sh \
  --source "/Users/me/iPhoneBackup" \
  --target "DCIM" \
  --prefix "IPHONE" \
  --ext "heic jpg png" \
  --rename false \
  --output "organized"
```

Esto se dirige específicamente a archivos HEIC, JPG y PNG, añade un prefijo "IPHONE" para facilitar su identificación y coloca los resultados en un directorio "organized".



## 📁 Formato de salida

Comprender el formato de salida le ayuda a predecir exactamente cómo se nombrarán sus archivos. El script crea nombres de archivo siguiendo este patrón:

```
[PREFIX_]YYYYMMDD_HHMMSS[_SUFFIX][_PANO].extension
```

Permítame desglosar lo que significa cada componente y mostrarle ejemplos concretos.

El **prefix** aparece primero si lo ha especificado, seguido de un guión bajo. La **parte de la fecha** utiliza el formato AAAAAMMDD, donde AAAA es el año de cuatro dígitos, MM es el mes de dos dígitos y DD es el día de dos dígitos. La **parte de la hora** utiliza el formato HHMMSS en formato de 24 horas. El **suffix** aparece antes de la extensión si se ha especificado uno. El **marcador PANO** se añade automáticamente a los archivos MPO (panorámicos). Por último, la **extensión** conserva el formato de archivo original.


### Ejemplos de transformaciones

Una foto JPEG estándar tomada el 14 de agosto de 2023 a las 3:45:30 p. m. se transformaría de algo como "IMG_1234.jpg" a "20230814_154530.jpg". El momento exacto queda registrado en el nombre del archivo, lo que facilita la clasificación cronológica.

Al procesar imágenes de WhatsApp con el prefijo "WA", esa misma foto se convertiría en "WA_20230814_154530.jpg", lo que indicaría claramente su origen y mantendría la información cronológica.

Si se añade un sufijo como "backup" a la misma foto, se llamaría "20230814_154530_backup.jpg", lo que permite distinguir entre diferentes lotes de procesamiento o fines.

Para las fotos panorámicas en formato MPO, el script añade automáticamente el marcador PANO, por lo que "IMG_5678.MPO" se convierte en "20230814_154530_PANO.MPO", lo que facilita la búsqueda de todas sus panorámicas.

Cuando existen marcas de tiempo duplicadas (varias fotos tomadas en el mismo segundo), el script añade un contador como "20230814_154530-2.jpg" para garantizar que los nombres de los archivos sean únicos.

## 🔍 Cómo funciona

Comprender la lógica interna del script te ayuda a utilizarlo de forma más eficaz y a resolver cualquier problema. Permíteme explicarte paso a paso el proceso que sigue el script al procesar tus archivos.

**La detección de directorios** es la primera fase, en la que el script escanea tu directorio de origen de forma recursiva para encontrar todos los subdirectorios que coincidan con el nombre de destino. Durante este escaneo, respeta la lista de ignorados, omite los directorios que hayas especificado y evita automáticamente los directorios de salida para prevenir problemas de procesamiento recursivo.

La **extracción de la fecha** es donde se produce la inteligencia. Para cada archivo encontrado, el script primero intenta leer la etiqueta EXIF DateTimeOriginal, que almacena la fecha en la que se tomó realmente la foto. Si esa etiqueta no existe (algo habitual en capturas de pantalla o imágenes editadas), recurre a la etiqueta FileModifyDate. Este enfoque en dos etapas garantiza que el script pueda manejar prácticamente cualquier archivo multimedia.

La **detección de la fecha en el nombre del archivo** se activa cuando se habilita use_date_name. El script busca en el nombre de archivo original un patrón de fecha de 8 dígitos como "20230814" y lo extrae. Esto reconoce las convenciones de nomenclatura comunes de varias aplicaciones de cámara y servicios de mensajería.

**La validación de la fecha** compara la fecha del nombre del archivo con la fecha EXIF cuando ambas existen. Si difieren en más de 180 días, el script asume que el nombre del archivo es más fiable (quizás los datos EXIF se corrompieron durante una transferencia o edición) y actualiza los metadatos EXIF para que coincidan con la fecha del nombre del archivo. Se eligió este umbral de 180 días para evitar falsos positivos debidos a diferencias horarias y detectar fechas realmente incorrectas.

**La construcción de la cadena de formato** crea el nuevo nombre de archivo utilizando el prefijo especificado, la fecha extraída en formato AAAAAMMDD_HHMMSS, el sufijo especificado y el marcador especial PANO para archivos MPO. El script utiliza las potentes capacidades de formato de fecha de ExifTool para garantizar un resultado coherente.

**Operación de archivos** depende del modo elegido. En el modo de copia, ExifTool crea una copia renombrada en el directorio de salida sin tocar el original. En el modo de renombrado, ExifTool modifica directamente el nombre del archivo original con el indicador overwrite_original, lo que es más rápido pero permanente.

**El seguimiento del progreso** le mantiene informado durante todo el proceso, mostrando qué directorio se está procesando, cuántos archivos se han encontrado y el porcentaje de progreso de cada directorio. El modo de depuración añade aún más detalles, mostrando los comandos exactos de ExifTool que se están ejecutando y sus resultados.


## 🛡️ Funciones de seguridad

El script incorpora varios mecanismos de seguridad para proteger tu preciada colección de fotos contra pérdidas o daños accidentales.

**El modo de copia predeterminado** significa que el script nunca toca tus archivos originales a menos que habilites explícitamente el modo de renombrado. Esta filosofía de "seguridad por defecto" garantiza que no puedas destruir accidentalmente tu única copia de fotos irremplazables.

**La exclusión automática del directorio de salida** evita que el script procese archivos que ya ha renombrado. Si accidentalmente ejecuta el script dos veces en la misma fuente, no volverá a procesar los archivos del directorio "renombrado", lo que evita la recursividad infinita y la pérdida de tiempo.

**Gestión integral de errores** significa que el script comprueba si faltan dependencias, valida que los directorios de entrada existan y gestiona con elegancia los archivos con datos EXIF corruptos o faltantes, en lugar de bloquearse a mitad del procesamiento de miles de archivos.

**Los indicadores de progreso** le permiten supervisar el funcionamiento del script en tiempo real, de modo que si algo parece ir mal (como procesar muchos más o muchos menos archivos de lo esperado), puede interrumpir la operación antes de que se complete.

El **modo de depuración** le permite ver exactamente lo que está haciendo el script antes de comprometerse con cualquier operación. Ejecute sus primeros lotes de prueba con la depuración habilitada para verificar que el comportamiento coincide con sus expectativas.



## ⚠️ Advertencias importantes

Aunque el script está diseñado para ser seguro, hay situaciones en las que es necesario actuar con precaución.

**El modo de renombrar es permanente** y no se puede deshacer. Una vez que renombre los archivos, los nombres originales se perderán para siempre. Pruebe siempre primero con el modo de copiar utilizando un pequeño subconjunto de sus archivos. Solo cambie al modo de renombrar cuando esté absolutamente seguro de que el resultado es el que desea.

**La modificación de los datos EXIF** se produce cuando el script detecta fechas inconsistentes entre los nombres de los archivos y los metadatos. Aunque esta función es útil para corregir datos corruptos, altera permanentemente la información EXIF. Si necesita conservar los datos EXIF originales en todos los casos, establezca `--use_date_name false` para desactivar este comportamiento.

**Las colecciones grandes llevan tiempo** porque ExifTool necesita leer los metadatos de cada uno de los archivos. El procesamiento de decenas de miles de fotos puede llevar horas, especialmente en el modo de copia, en el que se duplican los datos de los archivos. No interrumpa el script mientras se está ejecutando, ya que esto podría dejar directorios parcialmente procesados.

**Los requisitos de espacio en disco** para el modo de copia son significativos: necesita al menos tanto espacio libre como el tamaño total de los archivos que se están procesando. Compruebe siempre el espacio disponible en disco antes de procesar colecciones grandes.

**Las unidades de red pueden ser lentas**, ya que la lectura de datos EXIF a través de una conexión de red es mucho más lenta que el acceso al disco local. Considere la posibilidad de copiar los archivos a una unidad local para su procesamiento si le preocupa el rendimiento.

**No se ha probado en los corner cases**: En los casos extremos como falta de espacio en disco o con cualquier formato de fecha en el nombre

## 🐛 Solución de problemas

Permítame abordar los problemas comunes que puede encontrar y cómo resolverlos.

**No se encontraron directorios** ocurre cuando el script no puede localizar ninguna carpeta que coincida con el nombre de destino. Utilice el modo de depuración y verifique que el nombre del directorio de destino coincida exactamente con el que figura en su sistema de archivos (incluida la distinción entre mayúsculas y minúsculas). Compruebe que la ruta de origen sea correcta y que no esté ignorando accidentalmente los directorios que desea procesar.

**Los archivos no se procesan** puede ocurrir si las extensiones de los archivos no coinciden con la lista especificada. Recuerde que las extensiones no distinguen entre mayúsculas y minúsculas, pero debe enumerar explícitamente todas las variantes que desea procesar. Utilice el modo de depuración para ver qué archivos se encuentran y cuáles se omiten.

**Los errores de ExifTool** suelen indicar que faltan datos EXIF o que estos están dañados. El script los gestiona correctamente recurriendo a las fechas de modificación de los archivos, pero si ve muchos errores, es posible que algunos de sus archivos tengan problemas graves de metadatos. Intente ejecutar ExifTool manualmente en un archivo problemático para diagnosticar el problema específico.

Los **nombres de archivo duplicados** se producen cuando varias fotos tienen marcas de tiempo idénticas. El script añade automáticamente contadores como "-2", "-3" para crear nombres únicos. Este es un comportamiento normal cuando se procesan fotos en ráfaga o secuencias capturadas rápidamente.

Los **errores de permiso denegado** significan que el script no tiene derechos para leer los archivos fuente o escribir en el directorio de salida. Comprueba los permisos de los archivos y asegúrate de que tienes acceso de escritura al directorio principal de la ubicación de salida.


## 🤝 Contribuciones

Las contribuciones para mejorar el script son bienvenidas y apreciadas. El proyecto sigue las prácticas estándar de contribución de código abierto.

Cuando envíes incidencias, incluye tu sistema operativo, la versión de ExifTool, el comando exacto que ejecutaste y cualquier mensaje de error. Esta información es crucial para reproducir y solucionar los problemas.

Para las solicitudes de extracción, mantenga el estilo de código existente y añada comentarios que expliquen el razonamiento detrás de cualquier lógica compleja. Considere la posibilidad de añadir ejemplos al README si su contribución introduce nuevas características o cambia el comportamiento existente.

Pruebe sus cambios con varios tipos de archivos y estructuras de directorios antes de enviarlos. El script debe funcionar de forma fiable en diferentes escenarios del mundo real.

## 📄 Licencia

Este proyecto se publica bajo la licencia MIT, lo que significa que usted es libre de utilizarlo, modificarlo y distribuirlo para cualquier fin, incluidas las aplicaciones comerciales. El único requisito es que incluya el texto original de la licencia con cualquier copia o parte sustancial del software.

## 🙏 Agradecimientos

Este script se ha creado gracias al trabajo de grandes profesionales. [ExifTool](https://exiftool.org/), de Phil Harvey, es la base que lo hace todo posible: se trata de una herramienta increíblemente potente y fiable que se encarga de la compleja tarea de leer y escribir metadatos EXIF en cientos de formatos de archivo.

El script se creó por necesidad personal, tras luchar durante años por consolidar las fotos familiares de varios teléfonos, servicios en la nube y copias de seguridad. La frustración de tener la misma foto de vacaciones cinco veces con cinco nombres diferentes motivó la creación de una herramienta que resolviera este problema de una vez por todas.

## 📞 Asistencia

Si encuentra algún problema o tiene alguna pregunta que no se trate en este README, abra una incidencia en GitHub con el mayor detalle posible sobre su situación. La comunidad y los administradores harán todo lo posible para ayudarle a resolver el problema.

Si tiene preguntas generales sobre el uso o desea compartir sus experiencias positivas, no dude en iniciar un debate en la sección Discusiones de GitHub. Conocer cómo utilizan la herramienta otras personas ayuda a mejorarla para todos.