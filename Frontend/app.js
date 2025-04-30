const express = require('express');
const bodyParser = require('body-parser');
const axios = require('axios');
const app = express();
const port = process.env.PORT || 3000;

// Set EJS as the templating engine
app.set('view engine', 'ejs');

// Serve static files (if needed)
app.use(express.static('public'));

// Parse URL-encoded bodies (from form submissions)
app.use(bodyParser.urlencoded({ extended: false }));

// GET route: render the input form
app.get('/', (req, res) => {
  res.render('index');
});

// POST route: send the question to the backend and render the answer
app.post('/answer', async (req, res) => {
  const userQuestion = req.body.question;
  try {
    // Send the question to the backend API
    const response = await axios.post(
      "http://backend:5000/api/question",
      { question: userQuestion },
      { headers: { "Content-Type": "application/json" } }
    );
    // Extract the answer from the backend response
    const answer = response.data.answer;
    res.render('answer', { question: userQuestion, answer });
  } catch (error) {
    console.error("Error calling backend:", error.message);
    res.render('answer', { question: userQuestion, answer: "Error fetching answer" });
  }
});

app.listen(port, () => {
  console.log("Server running on port "+port);
});