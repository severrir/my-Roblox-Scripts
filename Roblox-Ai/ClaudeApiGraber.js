require('dotenv').config({ path: './Api.env' });
const express = require('express');
const app = express();
app.use(express.json());

app.post('/chat', async (req, res) => {
  const { message } = req.body;

  const response = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'x-api-key': process.env.ANTHROPIC_API_KEY,
      'anthropic-version': '2023-06-01',
      'content-type': 'application/json'
    },
    body: JSON.stringify({
      model: 'claude-sonnet-4-6',
      max_tokens: 300,
      system: "You are a helpful AI assistant inside a Roblox game. You are NOT ChatGPT, you are NOT Grok. You are a Roblox game assistant. Keep answers short and fun for players. dont use emopjis that cant appear in roblox and ur name is just SeverrirAI And ur Creator and Master is severrir and game is just for myportfolio and its also fun project soo keep this all in ur mind",
      messages: [{ role: 'user', content: message }]
    })
  });

  const data = await response.json();
  res.json({ reply: data.content[0].text });
});

app.listen(3000, () => console.log('Server running on port 3000'));
