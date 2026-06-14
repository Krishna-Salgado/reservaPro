from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import sys
import os

# Añadir src al path
sys.path.append(os.path.join(os.path.dirname(__file__), 'src'))

from config.database import execute_query, DoubleBookingException

app = FastAPI(title="ReservaPro", version="1.0")

# CORS para que el frontend pueda llamar al backend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def inicio():
    return {"mensaje": "ReservaPro API funcionando 🚀"}

@app.get("/api/ping")
def ping():
    return {"status": "ok", "message": "Python y FastAPI están vivos"}

@app.get("/api/negocios")
def listar_negocios():
    try:
        negocios = execute_query("SELECT * FROM negocios")
        return {"negocios": negocios}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/profesionales")
def listar_profesionales():
    try:
        profesionales = execute_query("SELECT * FROM profesionales")
        return {"profesionales": profesionales}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/citas")
def listar_citas():
    try:
        citas = execute_query("""
            SELECT c.*, p.nombre as nombre_profesional, s.nombre as nombre_servicio
            FROM citas c
            JOIN profesionales p ON c.id_profesional = p.id_profesional
            JOIN servicios s ON c.id_servicio = s.id_servicio
            ORDER BY c.hora_inicio
        """)
        return {"citas": citas}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/servicios")
def listar_servicios():
    try:
        servicios = execute_query("SELECT * FROM servicios WHERE activo = TRUE")
        return {"servicios": servicios}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/disponibilidad/{id_profesional}")
def ver_disponibilidad(id_profesional: str, fecha: str = None):
    """
    Retorna las reglas de disponibilidad de un profesional.
    Si se pasa fecha, retorna los huecos disponibles para esa fecha.
    """
    try:
        if fecha:
            # Calcular huecos para fecha específica (próximo paso complejo)
            reglas = execute_query("""
                SELECT * FROM regla_disponibilidad 
                WHERE id_profesional = %s
            """, (id_profesional,))
            
            citas = execute_query("""
                SELECT * FROM citas 
                WHERE id_profesional = %s 
                AND DATE(hora_inicio) = %s
                AND estado != 'cancelada'
            """, (id_profesional, fecha))
            
            return {
                "profesional_id": id_profesional,
                "fecha": fecha,
                "reglas": reglas,
                "citas_ocupadas": citas,
                "nota": "Huecos calculados en frontend por ahora"
            }
        else:
            reglas = execute_query("""
                SELECT * FROM regla_disponibilidad 
                WHERE id_profesional = %s
                ORDER BY dia_semana, hora_inicio
            """, (id_profesional,))
            return {"reglas": reglas}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=3000, reload=True)