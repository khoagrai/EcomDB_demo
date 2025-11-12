const express = require('express');
const router = express.Router();
const sql = require('mssql');

// import dbConfig
const dbConfig = require('../dbConfig');





// (GET)/users/all
// Return all users
router.get('/users/all', async (req, res) => {
    try {
        const pool = await sql.connect(dbConfig);
        const request = pool.request();

        const result = await request.query('SELECT * FROM [User]');
        
        return res.json(result.recordsets[0]);
    }
    catch (error) {
        console.log(error);
        return res.status(500).send({ message: 'Error executing get all users query.' });
    }
});



// (GET)/:UserID
// Return user
router.get('/:UserID', async (req, res) => {
    const UserID = req.params.UserID;
    try {
        const pool = await sql.connect(dbConfig);
        const request = pool.request();

        request.input('UserID', sql.VarChar, UserID);
        const result = await request.query('SELECT * FROM [User] WHERE UserID = @UserID');
        
        return res.json(result.recordsets[0]);
    }
    catch (error) {
        console.log(error);
        return res.status(500).send({ message: 'Error executing get user query.' });
    }
});




module.exports = router;