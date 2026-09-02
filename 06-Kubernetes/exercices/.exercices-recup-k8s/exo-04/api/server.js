const express = require('express');

const app = express();
const PORT = 3000;

// Route Hello World
app.get('/api/v1/hello', (req, res) => {
    res.json({
        message: 'Hello World'
    });
});

app.get('/api/v1/blabla', (req, res) => {
    res.json({
        message: 'Truc bidule'
    });
});

// Lancement du serveur
app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});