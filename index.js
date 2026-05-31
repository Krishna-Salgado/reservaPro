const express = require('express');
const cors = require('cors');

// Importamos el pool de base de datos
const pool = require('./src/config/db');

const app = express();

// ==========================================
// MIDDLEWARES (Configuración a nivel de aplicación)
// ==========================================
// Habilitamos CORS para que el Frontend pueda consumir esta API
app.use(cors());

// Habilitamos la capacidad de recibir payloads en formato JSON en las peticiones
app.use(express.json({ limit: '10kb' })); // Limitamos el tamaño del body a 10kb por seguridad

// ==========================================
// ENDPOINTS (Rutas de la API)
// ==========================================

// Ruta de salud (Health Check) para monitoreo
app.get('/api/ping', (req, res) => {
    res.status(200).json({ 
        status: 'ok', 
        message: 'ReservaPro API está viva',
        timestamp: new Date().toISOString() 
    });
});

// Ruta de prueba de conexión a BD
app.get('/api/db-test', async (req, res) => {
    try {
        const result = await pool.query('SELECT NOW() as server_time');
        res.status(200).json({ 
            db_connected: true, 
            time: result.rows[0].server_time 
        });
    } catch (error) {
        res.status(500).json({ db_connected: false, error: error.message });
    }
});

// ==========================================
// INICIALIZACIÓN DEL SERVIDOR
// ==========================================
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
    console.log(`🚀 Servidor ReservaPro corriendo en el puerto: ${PORT}`);
    console.log(`📍 Entorno: ${process.env.NODE_ENV || 'desarrollo'}`);
});