import sys
import os

# Agregar src/ al path para poder importar database.py
sys.path.append(os.path.join(os.path.dirname(__file__), 'src'))

from config.database import execute_query

# Prueba simple: preguntar cuántos negocios hay
resultado = execute_query("SELECT COUNT(*) as total FROM negocios")

print("¿PostgreSQL responde?")
print(resultado)
print(f"Total de negocios: {resultado[0]['total']}")

resultado2 = execute_query("SELECT nombre_negocio, slug, tipo_plan FROM negocios")
print("\nlos datos de esta cosa:")

for i in resultado2:

    print(f"negocio: {i["nombre_negocio"]},\n slug:{i["slug"]},\n tipo plan: {i["tipo_plan"]}")