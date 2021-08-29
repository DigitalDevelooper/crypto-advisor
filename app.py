from flask import Flask, render_template, url_for, request, make_response, jsonify, session
from flask.wrappers import Response
from flask_mysqldb import MySQL
from datetime import datetime
from fbprophet import Prophet
import pandas as pd
import numpy as np
import json
import requests
import yfinance as yf

app = Flask (__name__)
app.secret_key = "rlangus"

#db
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = ''
app.config['MYSQL_DB'] = 'crypto_advisor'
app.config['MYSQL_CURSORCLASS'] = 'DictCursor'

mysql = MySQL(app)

#query
def dobaviParametre():
    cursor = mysql.connection.cursor()
    rezultat = cursor.execute("SELECT u.*, s.* from user u LEFT JOIN settings s on u.id=s.user_id WHERE u.id = 2")
    mysql.connection.commit()
    if rezultat > 0:
        data = cursor.fetchone()
        session['username'] = data['username']
        session['minTransfer'] = data['alert_whale']
        session['dailyAlert'] = data['alert_price_change_daily']
        cursor.close()
    
    return data

def dobaviWatchlist():
    cursor = mysql.connection.cursor()
    rezultat = cursor.execute("SELECT c.* from cryptocurrency c LEFT JOIN is_tracking i on i.crypto_id=c.id WHERE i.user_id = 2")
    mysql.connection.commit()
    if rezultat > 0:
        data = cursor.fetchall()
        cursor.close()
    else:
        data = 0
    
    return data
def getAlertsByUser():
    cursor = mysql.connection.cursor()
    rezultat = cursor.execute("SELECT a.*, c.name_short from alerts a LEFT JOIN cryptocurrency c ON c.id= a.crypto_id WHERE user_id = 2 AND is_alerted = 0")
    mysql.connection.commit()
    if rezultat > 0:
        data = cursor.fetchall()
        cursor.close()
    else:
        data = 0
    
    return data

#routes
@app.route('/')
def dashboard():
    dobaviParametre()

    req = requests.get('https://api.whale-alert.io/v1/transactions?api_key=Car3Car9KocXv6QZyQvZgNkdQiEOyz14&min_value=' + str(session['minTransfer']) + '&limit=10&currency=btc').content
    cryptoData = dobaviWatchlist()
    if(not cryptoData):
        message = "nema podataka"
    else:
        message = "ima podataka"
    username = session['username']
    dailyAlerts = session['dailyAlert']
    
    return render_template('dashboard.html', username=username, cryptoData=cryptoData, message=message, response=req, dailyAlerts=dailyAlerts)

@app.route('/settings')
def settings():
    dobaviParametre()
    username = session['username']
    alertPriceDaily = session['dailyAlert']
    alertWhales = session['minTransfer']
    
    return render_template('settings.html', username=username, alertPriceDaily=alertPriceDaily, alertWhales=alertWhales)

@app.route('/myAlerts')
def myAlerts():
    dobaviParametre()
    alerts = getAlertsByUser()
    username = session['username']
    
    
    return render_template('myAlerts.html', username=username, alerts=alerts)

@app.route('/saveSettings', methods=['POST'])
def saveSettings():
    data = request.get_json()
    cursor = mysql.connection.cursor()
    update = cursor.execute("UPDATE `settings` SET `alert_whale`= %s, `alert_price_change_daily`= %s WHERE user_id = 2", (data['alertWhales'], data['alertPriceDaily']))
    mysql.connection.commit()
    if update > 0:
        message = "Postavke uspješno ažurirane!"
        color = "success"
        cursor.close()
    else:
        message = "Nisu unesene nikakve promjene!"
        color = "warning"
        cursor.close()
    res = make_response(jsonify({"message":message,"color":color}))
    
    return res

@app.route('/cryptoDetails/<string:crypto>')
def cryptoDetails(crypto):
    username = session['username']
    crypto_short = crypto[0:3]
    start = '2016-01-01'
    end = datetime.today().strftime('%Y-%m-%d')
    crypto_df = yf.download(crypto,start, end)
    crypto_df.reset_index(inplace=True)
    jsonGraphData = crypto_df[["Date", "Open"]].to_json(orient='records')
    
    return render_template('cryptoDetails.html',crypto=crypto, cryptoData=jsonGraphData, crypto_short=crypto_short, username=username)

@app.route('/predict', methods=['POST'])
def predict():
    data = request.get_json()
    start = '2016-01-01'
    end = datetime.today().strftime('%Y-%m-%d')
    crypto_df = yf.download(data['crypto'], start, end)
    crypto_df.reset_index(inplace=True)
    phrophet_df = crypto_df[["Date", "Open"]]
    prepareForPhropet = {
        "Date": "ds", 
        "Open": "y",
    }
    phrophet_df.rename(columns=prepareForPhropet, inplace=True)
    m = Prophet(seasonality_mode="multiplicative")
    m.fit(phrophet_df)
    prediction = m.make_future_dataframe(periods = 365)
    forecast_df = m.predict(prediction)
    jsonGraphPrediction = forecast_df[['ds', 'yhat', 'yhat_lower', 'yhat_upper']].to_json(orient='records')
    res = make_response(jsonify({"json":jsonGraphPrediction}))
    
    return res

@app.route('/whalesAlert', methods=['POST'])
def whalesAlert():
    dobaviParametre()
    req = requests.get('https://api.whale-alert.io/v1/transactions?api_key=Car3Car9KocXv6QZyQvZgNkdQiEOyz14&min_value=' + str(session['minTransfer']) + '&limit=10&currency=btc').content
    
    return req

@app.route('/updateCrypto', methods=['POST'])
def updateCrypto():
    data = request.get_json()
    cursor = mysql.connection.cursor()
    update = cursor.execute("UPDATE `cryptocurrency` SET `current_value`= '"+str(data['trenutno'])+"' WHERE `name_short`= '"+data['crypto']+"'")
    mysql.connection.commit()
    if update > 0:
        query = cursor.execute("SELECT * FROM alerts WHERE is_alerted = 0 AND user_id = 2 AND crypto_id = (SELECT id from cryptocurrency WHERE `name_short` = '" + data['crypto'] + "')")
        mysql.connection.commit()
        if query >0:
            alerts="ima"
        else:
            alerts="nema"
        message = "success"
        color = "success"
        cursor.close()
        res = make_response(jsonify({"message":message,"color":color, "alerts":alerts}))
    else:
        message = "error"
        color = "danger"
        cursor.close()
        res = make_response(jsonify({"message":message,"color":color}))
    return res

@app.route('/newAlert', methods=['POST'])
def newAlert():
    data = request.get_json()
    cursor = mysql.connection.cursor()
    query =  cursor.execute("SELECT id from cryptocurrency where name_short = '"+data['crypto'] +"'")
    mysql.connection.commit()
    if query > 0:
        crypto = cursor.fetchone()
        insert = cursor.execute("INSERT INTO `alerts`(`id`, `alert_price`, `alert_price_condition`, `is_alerted`, `user_id`, `crypto_id`) VALUES (NULL, %s, %s, 0, 2, %s)", (data['price'], data['condition'], crypto['id']))
        mysql.connection.commit()
        if insert > 0:
            message = "Alert uspješno kreiran!"
            color = "success"
            cursor.close()
        else:
            message = "Problem prilikom unosa alerta!"
            color = "danger"
            cursor.close()
        res = make_response(jsonify({"message":message,"color":color}))
    else:
        res = make_response(jsonify({"message":"Kripto valuta nije dodana u bazu podataka","color":"warning"}))
    return res
@app.route('/checkAlerts', methods=['POST'])
def checkAlerts():
    data = request.get_json()
    cursor = mysql.connection.cursor()
    query =  cursor.execute("SELECT a.*, c.current_value FROM `alerts` a LEFT JOIN cryptocurrency c ON a.crypto_id=c.id WHERE a.user_id = 2 AND a.is_alerted = 0 AND a.crypto_id = (SELECT id from cryptocurrency where name_short = '" + data['crypto'] + "')")
    mysql.connection.commit()
    if query > 0:
        alerts = cursor.fetchall()
        doAlertStrings = []
        for alert in alerts:
            if(alert['alert_price_condition'] == ">="):
                if(alert['current_value'] >= alert['alert_price']):
                    string = "Price alert za " + data['crypto'] + " >= " + str(alert['alert_price'])
                    doAlertStrings.append(string)
                    update = cursor.execute("UPDATE `alerts` SET `is_alerted`= 1 WHERE id = '" + str(alert['id']) + "'")
                    mysql.connection.commit()
            else:
                if(alert['current_value'] <= alert['alert_price']):
                    string = "Price alert za " + data['crypto'] + " <= " + str(alert['alert_price'])
                    doAlertStrings.append(string)
                    update = cursor.execute("UPDATE `alerts` SET `is_alerted`= 1 WHERE id = '" + str(alert['id']) + "'")
                    mysql.connection.commit()
        res = make_response(jsonify({"message":"success","alerts":doAlertStrings}))
    else:
        res = make_response(jsonify({"message":"Kripto valuta nije dodana u bazu podataka","color":"warning"}))
    return res
if __name__ == '__main__':
    app.run(debug=True)