const express = require('express');
const path = require('path');
const cookieParser = require('cookie-parser');
const logger = require('morgan');

const VUE_DIST_DIR = 'dist/';

const app = express();

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, VUE_DIST_DIR)));

app.get('/*', (req, res) => {
    res.sendFile(path.join(__dirname, VUE_DIST_DIR, 'index.html'));
});

module.exports = app;
