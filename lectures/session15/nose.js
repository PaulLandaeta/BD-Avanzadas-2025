const redis = require('redis');

const client = redis
  .createClient({
    url: "redis://:eYVX7EwVmmxKPCDmwMtyKVge8oLd2t81@localhost:6379",
  })
  .on("error", (err) => console.log("Redis Client Error", err))
  .connect()
  .then(() => {
    console.log("Connected to Redis");
  })