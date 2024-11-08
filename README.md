Laboratorio-4-Terraform

Presentamos el laboratorio 4 en el cual desarrollamos un despliegue automátizado de WordPress con terraform, con acceso automático al wordPress.

La arquitectura implementada consta de los siguientes componentes principales:

Red (VPC):

VPC con dos zonas de disponibilidad
Subredes públicas y privadas en cada zona
Internet Gateway para acceso a internet
NAT Gateway para que las instancias privadas accedan a internet
Balanceadores de Carga (ALB):

ALB Externo en subredes públicas que maneja el tráfico entrante HTTPS (443) y redirecciona HTTP (80) a HTTPS
ALB Interno en subredes privadas que distribuye el tráfico a las instancias WordPress
Compute (EC2):

Auto Scaling Group con instancias WordPress en subredes privadas
Launch Template con configuración de WordPress y dependencias
Montaje de EFS para almacenamiento compartido
Configuración automática de WordPress mediante user data
Almacenamiento:

RDS PostgreSQL para la base de datos de WordPress
EFS para almacenamiento compartido de archivos WordPress
ElastiCache Redis para caché de objetos
Uso de snapshot RDS para restaurar configuración preexistente de WordPress
Seguridad:

Grupos de seguridad específicos para cada componente
ACM para certificado SSL/TLS
IAM roles y políticas para permisos EC2
Monitoreo:

CloudWatch Logs para registros
Alarmas CloudWatch para:
CPU alta en EC2
CPU y almacenamiento en RDS
CPU y memoria en ElastiCache
La arquitectura está diseñada para ser altamente disponible, escalable y segura, utilizando servicios gestionados de AWS.

Limitaciones y Trabajo Pendiente:

a) S3 para medios y Memcached:

Pendiente la integración de S3 para almacenamiento de medios de WordPress
Se requiere configurar el plugin S3 Offload Media para mover archivos multimedia
Evaluada la opción de Memcached vs Redis para caché de objetos
Se eligió Redis por mejor integración con WordPress y características adicionales
El código base para S3 está en s3.tf pero falta la configuración en WordPress

b) CloudFront CDN:

Se ha desarrollado el código en cloudfront.tf
Pendiente la integración completa con el sitio WordPress
El código está listo para despliegue pero requiere ajustes finales

c) AWS Secrets Manager:

Código base implementado en secretmanager.tf
Pendiente la obtención de credenciales RDS en el user-data de EC2
Se utiliza generación aleatoria de nombres para evitar conflictos
Esto permite múltiples destroy/apply sin problemas de nombres duplicados

d) Backup y Restauración:

Se implementó la restauración desde un snapshot de RDS existente
Esto permite preservar toda la configuración previa de WordPress
El snapshot contiene la estructura de la base de datos y los datos
Facilita la migración y el despliegue manteniendo la configuración existente

Nota: A pesar de estas limitaciones, la arquitectura base funciona correctamente y está lista para mejoras incrementales.

Muchas gracias por todas las clases y todo los conocimientos que nos has dado!
