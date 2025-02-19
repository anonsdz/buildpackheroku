const os = require("os");
const { execSync } = require("child_process");

console.log("Node.js Version:", execSync("node -v").toString().trim());
console.log("NPM Version:", execSync("npm -v").toString().trim());
console.log("Số CPU Core:", os.cpus().length);
console.log("Tổng RAM:", (os.totalmem() / 1024 / 1024 / 1024).toFixed(2), "GB");
