const express = require('express');
const router = express.Router();
const sql = require('mssql');

// import dbConfig
const dbConfig = require('../dbConfig');




// (GET)/cart/:UserID
// Get cart content by user ID
router.get('/:UserID', async (req, res) => {
    const UserID = req.params.UserID;
    try {
        const pool = await sql.connect(dbConfig);
        const request = pool.request(); 
        
        request.input('input_UserID', sql.VarChar, UserID); 
        const result = await request.execute('GetCartContentByUserID');
        
        return res.json(result.recordsets[0]); 
    } catch (error) {
        console.error(error);
        return res.status(500).send({ message: 'Error executing get cart content by UserID.' });
    }
});



module.exports = router;