var express = require('express');
var router = express.Router();
const { executeSQL } = require('../sql');
const { TYPES } = require('tedious');

/* GET users listing. */
router.get('/', function(req, res, next) {
    res.render('list', { title: 'list' });
});

router.post('/', async function(req, res, next) {
    try {
        var start = new Date();
        const params = [{ name: 'address', type: TYPES.VarChar, value: req.body.address }];

        console.log(`Start query to DB: ${start}`);
        const data = await executeSQL(`select FirstName, LastName, Address FROM UserInfo WHERE Address like '%' + @address + '%'`, params);
        console.log(`End query to DB: ${new Date()}`);
        console.log(`Duration: ${new Date() - start} ms`);
        // 取得したデータの先頭100件を表示
        res.render('list-result', {
            title: 'list',
            address: req.body.address,
            users: data.slice(0, 100),
            elapsed: new Date() - start
        });
    } catch (error) {
        console.error(error);
        res.status(500).send(error.message);
    }
});
module.exports = router;