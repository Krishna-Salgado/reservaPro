// Importamos el cliente PostgreSQL y la utilidad de variables de entorno
const { Pool } = require('pg');
require('dotenv').config();

// Configuración del Pool de Conexiones
const pool = new Pool({
  user: process.env.DB_USER,
  host: 'localhost', // En Docker local es localhost. En producción (Render) será una variable de entorno.
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT || 5432, // Usamos el puerto de la BD (5432)
  
  // Parámetros de optimización del Pool
  max: 20, // Máximo de conexiones simultáneas (el max es 25 dejamos 5 para que no muera por mantenimientos)
  idleTimeoutMillis: 30000, // Si está ocioso 30 seg, se apaga para ahorrar memoria
  connectionTimeoutMillis: 2000, // Si no hay disponibles en 2 seg, la petición falla rápido (Fail-Fast)
});

// Middleware de diagnóstico para detectar errores silenciosos del cliente
pool.on('error', (err, client) => {
  console.error('Error inesperado en el cliente inactivo del Pool:', err);
  process.exit(-1); // Apaga el servidor si el Pool se corrompe
});

// Exportamos el pool para usarlo en los endpoints
module.exports = pool;