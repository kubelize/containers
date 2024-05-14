const express = require('express');
const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');

const app = express();
const port = 3000;
const scriptPath = path.join(__dirname, 'gitlab-runner-monitoring.sh'); // Replace with your script path
const metricsFilePath = path.join(__dirname, 'metrics.txt'); // Replace with your desired metrics file path

// Function to run the bash script
const runScript = () => {
  exec(`bash ${scriptPath}`, (error, stdout, stderr) => {
    if (error) {
      console.error(`Error executing script: ${error.message}`);
      return;
    }
    if (stderr) {
      console.error(`Script stderr: ${stderr}`);
      return;
    }
    fs.writeFileSync(metricsFilePath, stdout);
  });
};

// Run the script at startup
runScript();

// Set interval to run the script every minute (60000 ms)
setInterval(runScript, 60000);

// Endpoint to expose metrics
app.get('/metrics', (req, res) => {
  fs.readFile(metricsFilePath, 'utf8', (err, data) => {
    if (err) {
      res.status(500).send(`Error reading metrics: ${err.message}`);
      return;
    }
    res.send(data);
  });
});

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}/metrics`);
});