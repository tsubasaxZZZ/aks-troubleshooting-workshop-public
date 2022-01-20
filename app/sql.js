const { Connection, Request, TYPES } = require("tedious");
const dotenv = require("dotenv");

dotenv.config();

console.log(process.env);
const executeSQL = (sql, params) => new Promise((resolve, reject) => {

    let results = [];

    const connection = new Connection({
        server: process.env["db_server"],
        authentication: {
            type: 'default',
            options: {
                userName: process.env["db_user"],
                password: process.env["db_password"],
            }
        },
        options: {
            database: process.env["db_database"],
            encrypt: true,
            connectTimeout: Number(process.env["db_connectTimeoutMsec"] || 10)
        }
    });

    connection.on('connect', err => {
        if (err) {
            reject(err);
        } else {
            const request = new Request(`${sql}`, (err) => {
                if (err) {
                    reject(err);
                } else {
                    resolve(results);
                }
            });
            request.on('row', columns => {
                let row = {};
                columns.forEach(column => {
                    row[column.metadata.colName] = column.value;
                });
                results.push(row);
            });

            request.on("requestCompleted", () => {
                connection.close();
            });

            if (params && params.length > 0) {
                params.forEach(p => {
                    request.addParameter(p.name, p.type, p.value);
                });
                console.log(request.sqlTextOrProcedure);
            }

            connection.execSql(request);
        }
    });

    connection.connect();
});

module.exports = {
    executeSQL
}

/*
(async() => {
    try {
        const data = await executeSQL(`
            SELECT Address FROM [dbo].[UserInfo] where [Address] like '神奈川県%';
    `);
        console.log(data);
    } catch (error) {
        console.error(error);
    }
})();
*/