import logging
import sys
from flask import Flask, jsonify
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)

logging.basicConfig(
    stream=sys.stdout,
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s",
)
logger = logging.getLogger(__name__)

app_requests_total = Counter("app_requests_total", "Total requests")
app_errors_total = Counter("app_errors_total", "Total errors")


@app.route("/health")
def health():
    return jsonify({"status": "ok", "service": "flask-app"}), 200


@app.route("/testlog")
def testlog():
    logger.info("TEST LOG FROM FLASK")
    return "log written"


@app.route("/")
def home():
    app_requests_total.inc()
    logger.info("Home endpoint hit")
    return "Hello DevOps Final Project"


@app.route("/error")
def error():
    app_requests_total.inc()
    app_errors_total.inc()
    logger.error("Error endpoint hit")
    return "Error happened", 500


@app.route("/metrics")
def metrics():
    return generate_latest(), 200, {"Content-Type": CONTENT_TYPE_LATEST}


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
