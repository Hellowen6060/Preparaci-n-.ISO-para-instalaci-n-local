<img width="1216" height="829" alt="001" src="https://github.com/user-attachments/assets/ae1fa188-ffaa-4991-9247-c43963deac4b" />

# 🖥️ Instalador Local desde Imagen ISO de Windows

Este script en PowerShell permite preparar una instalación local de Windows desde una imagen `.ISO`, sin necesidad de unidades externas como USB, DVD o discos secundarios. Ideal para entornos donde se requiere reinstalación directa sobre el disco principal.

## 🚀 Características

- Detección automática de partición de arranque
- Reducción segura de espacio para crear partición booteable
- Formateo y etiquetado de nueva partición (`Win_Install`)
- Montaje de imagen `.ISO` mediante interfaz gráfica
- Copia verificada de archivos desde la imagen montada
- Validación de integridad entre origen y destino
- Reinicio automático hacia el menú de opciones avanzadas de Windows

## 📦 Requisitos

- Imagen de Windows válida en formato `.ISO` (Win7, Win8, Win10, Win11, Server)
- Espacio libre mínimo de **7.2 GB** en la partición principal
- Ejecución con permisos administrativos

## 🛠️ Uso

1. Ejecuta el script en PowerShell como administrador.
```powershell
irm https://raw.githubusercontent.com/Hellowen6060/Preparaci-n-.ISO-para-instalaci-n-local/refs/heads/main/Preparar_GIT.ps1 | iex
```
2. Sigue las instrucciones en pantalla.
3. Selecciona la imagen `.ISO` cuando se solicite.
4. El script creará una partición booteable y copiará los archivos.
5. Al finalizar, el sistema se reiniciará hacia el menú de recuperación.
6. Desde allí, inicia el instalador (`setup.exe`) desde la nueva partición.

## ⚠️ Advertencias

- La partición `Win_Install` no debe eliminarse durante la instalación.
- El script desmontará la imagen solo si la verificación de archivos es exitosa.
- En caso de error, se mantendrá montada para revisión manual.

## 📁 Compatibilidad

- Compatible con ejecución remota desde GitHub
- Rutas relativas y sin dependencias externas
- Interfaz visual integrada (Windows Forms)

##😊 Ventajas de su utilización

- Puedes usar esta partición para futuras instalaciones en tu equipo al ya tener configurada esta partición en modo booteo
- En un futuro cuando desees reinstalar el sistema y la imagen este obsoleta, puedes borrar manualmente el contenido de la partición, y copiar allí el contenido de una nueva ISO
- Siempre tendras este instalador de forma rápida para cualquier situación

## 🧩 Autoría y mantenimiento

Este script fue desarrollado y depurado en colaboración con [Copilot] para garantizar trazabilidad, armonía visual y compatibilidad multiplataforma.  
Distribúyelo, modifícalo y adáptalo según tus necesidades técnicas.

---
