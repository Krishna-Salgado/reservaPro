// Importamos el pool que acabamos de configurar
const pool = require('./src/config/db');

// Función asíncrona autoinvocada para poder usar await
(async () => {
    try {
        console.log('Intentando conectar a la base de datos...');
        
        // Ejecutamos una consulta simple para probar la conexión
        const res = await pool.query('SELECT current_database(), current_user, now()');
        
        console.log('✅ ¡CONEXIÓN EXITOSA!');
        console.log('----------------------------------------');
        console.log(`Base de Datos conectada: ${res.rows[0].current_database}`);
        console.log(`Usuario:                ${res.rows[0].current_user}`);
        console.log(`Hora del servidor BD:   ${res.rows[0].now}`);
        console.log('----------------------------------------');
        
    } catch (error) {
        console.error('❌ Error al conectar a la base de datos:', error.message);
    } finally {
        // CRÍTICO: Siempre debemos cerrar el pool al terminar un script independiente
        // Si no hacemos esto, el script de Node.js se quedará "colgado" infinitamente
        await pool.end();
        console.log('Pool de conexiones cerrado.');
    }
})();