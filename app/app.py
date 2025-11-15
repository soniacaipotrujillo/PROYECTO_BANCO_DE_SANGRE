from flask import Flask, render_template

# Inicializa la aplicación Flask
app = Flask(__name__)

# --- Definición de Rutas ---

@app.route('/')
def index():
    """Ruta principal (Homepage)"""
    # render_template busca en la carpeta 'templates'
    return render_template('index.html')

@app.route('/donantes')
def ver_donantes():
    """Ejemplo de otra página"""
    # Puedes pasar variables a tu plantilla
    lista_donantes = ["Ana García (O+)", "Luis Torres (A-)", "María Paz (AB+)"]
    return render_template('donantes.html', donantes=lista_donantes)

# --- Ejecutar la aplicación ---

if __name__ == '__main__':
    # Ejecuta la app en el puerto 5000, accesible desde cualquier IP
    app.run(debug=True, host='0.0.0.0', port=5000)