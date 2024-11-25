from flask import Flask, request, render_template, jsonify
import pickle
import pandas as pd

app = Flask(__name__)

# Charger les modèles et objets
with open('all_models.pkl', 'rb') as f:
    models = pickle.load(f)

xgboost_model = models['xgboost_model']
pca_model = models['pca_model']
scaler_model = models['scaler_model']
encoding_fuelType = models['encoding_fuelType']
encoding_model = models['encoding_model']
encoding_transmission = models['encoding_transmission']

@app.route('/')
def index():
    return render_template('index.html')  # Votre formulaire HTML

@app.route('/predict', methods=['POST'])
def predict():
    try:
        # Récupérer les données JSON envoyées
        data = request.get_json()

        # Préparer les données pour le modèle
        feature_names = ['model', 'year', 'transmission', 'mileage', 'fuelType', 'tax', 'mpg', 'engineSize']
        features = pd.DataFrame([[
            encoding_model[data['model']],
            int(data['year']),
            encoding_transmission[data['transmission']],
            int(data['mileage']),
            encoding_fuelType[data['fuelType']],
            int(data['tax']),
            float(data['mpg']),
            float(data['engineSize'])
        ]], columns=feature_names)

        # Appliquer la transformation
        features_scaled = scaler_model.transform(features)
        features_pca = pca_model.transform(features_scaled)
        predicted_price = xgboost_model.predict(features_pca)[0]

        # Convertir le résultat en float pour éviter les erreurs de sérialisation
        return jsonify({'price': round(float(predicted_price), 2)})

    except Exception as e:
        # En cas d'erreur, renvoyer l'erreur en JSON
        return jsonify({'error': str(e)})

if __name__ == '__main__':
    app.run(debug=True,host='0.0.0.0',port=5001)
