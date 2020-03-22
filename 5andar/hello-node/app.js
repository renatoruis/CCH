#!/usr/bin/env node
const amqp = require("amqplib/callback_api");
const mysql = require("mysql");

const RABBITMQ_HOST = process.env.RABBITMQ_HOST || "localhost";
const RABBITMQ_PORT = process.env.RABBITMQ_PORT || 5672;
const RABBITMQ_USERNAME = process.env.RABBITMQ_USERNAME || "rabbitmq";
const RABBITMQ_PASSWORD = process.env.RABBITMQ_PASSWORD || "rabbitmq";
const RABBITMQ_QUEUE = process.env.RABBITMQ_QUEUE || "hello";


const db = mysql.createConnection({
  host: process.env.MYSQL_HOST,
  user: process.env.MYSQL_USER,
  password: process.env.MYSQL_PASSWORD,
  database: process.env.MYSQL_DATABASE
});

  url = "amqp://" + RABBITMQ_USERNAME + ":" + RABBITMQ_PASSWORD + "@" + RABBITMQ_HOST + ":" + RABBITMQ_PORT ;

  amqp.connect(url, function(err, conn) {
    process.once('SIGINT', function() { conn.close(); });
    console.log("Connected to RabbitMQ at %s", url);
    //this will fail if the queue is still not ready to accept consumers!
    conn.createChannel(function(err, ch) {
      if (err !== null) return bail(err, conn);

      ch.assertQueue(RABBITMQ_QUEUE, { durable: false });
      console.log("Consuming queue: %s", RABBITMQ_QUEUE);

      ch.consume(RABBITMQ_QUEUE, function(msg) {
        console.log("Received message: %s", msg);

        db.query(
          "INSERT INTO Messages SET ?",
          { message: msg.content.toString() },
          function(err, result) {
            if (err) throw err;
            console.log(result);
          }
        );
      });
    },
    { noAck: true }
  );

  });