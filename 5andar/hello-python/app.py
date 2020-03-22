import os, pika
from flask import Flask, request, jsonify, render_template

app = Flask(__name__)

host = os.getenv("RABBITMQ_HOST", "localhost")
port = os.getenv("RABBITMQ_PORT", 5672)
queue = os.getenv("RABBITMQ_QUEUE", "hello")
username = os.getenv("RABBITMQ_USERNAME", "rabbitmq")
password = os.getenv("RABBITMQ_PASSWORD", "hellorabbitmq")

credentials = pika.PlainCredentials(username, password)

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        msg = request.form.get("flavour")
        enqueue(msg)
        return render_template('pudim.html', flavor=msg)

    if request.method == 'GET':
        return render_template('pudim.html')

def enqueue(value):
    app.logger.info("Received message: %s", value)
    params = pika.ConnectionParameters(host=host, port=port, credentials=credentials)
    connection = pika.BlockingConnection(params)
    channel = connection.channel()
    channel.queue_declare(queue=queue)
    channel.basic_publish(exchange='', routing_key=queue, body=value)
    connection.close()
    app.logger.info("Enqueued message on host %s:%s queue %s: %s", host, port, queue, value)

@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "ok"})

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=8000)
