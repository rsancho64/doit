# basado en https://tomasmalio.medium.com/node-js-express-y-mysql-con-sequelize-ec0a7c0ae292

#                  BD con 1  tabla: cliente/s
# TO DO: enrutar   BD con 1  tabla: vehiculo/s
# TO DO: replicar  BD con 1  tabla: vehiculo/s

# TO DO: replicar? BD con 2 tablas: cliente/s + vehiculo/s
# TO DO: replicar? BD con 3 tablas: cliente/s + vehiculo/s + venta/s

# stop old devel server (manually): pkill -f node

# rebuild ... -------------------------------------
# rm -Rf node_modules
rm -f app.js package.json package-lock.json
rm -Rf ./models ./migrations ./seeders ./routes ./controllers

sync # && sleep 2

# "npm init" :
cat << PACKAGE.JSON > package.json
{
  "name": "ej-seq",
  "version": "1.0.0",
  "description": "",
  "main": "app.js",
  "scripts": {
    "start": "nodemon app.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "rsa",
  "license": "ISC"
}
PACKAGE.JSON

## entrypoint: app.js
cat << APPJS > ./app.js
const express       = require('express');
const logger        = require('morgan');
const bodyParser    = require('body-parser');

// app entry. setup server here.
const http = require('http'); 

// Set up express app
const app = express();

// Log requests to the console.
app.use(logger('dev'));

// Parse incoming requests data (https://github.com/expressjs/body-parser)
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));

// Setup a default catch-all route that sends back a welcome message in JSON format.
require('./routes')(app);
app.get('/', (req, res) => res.status(200).send({
     message: 'Welcome to the beginning of nothingness.',
}));
const port = parseInt(process.env.PORT, 10) || 8000;
app.set('port', port);
const server = http.createServer(app);
server.listen(port);
console.log('escuchando en puerto', port)

module.exports = app;
APPJS

if [ ! -d 'node_modules' ] ; then
npm install -S express body-parser morgan mysql2 sequelize
npm install -D sequelize-cli nodemon
sync
fi

# scaffolder -------------------------------------

rm -Rf ./config/config.json
npx sequelize init

cat << CONFIG > ./config/config.json
{
  "development": {
    "username": "root",
    "password": "bea",
    "database": "dbdevel",
    "host": "127.0.0.1",
    "dialect": "mysql"
  },
  "test": {
    "username": "root",
    "password": null,
    "database": "database_test",
    "host": "127.0.0.1",
    "dialect": "mysql"
  },
  "production": {
    "username": "root",
    "password": null,
    "database": "database_production",
    "host": "127.0.0.1",
    "dialect": "mysql"
  }
}
CONFIG

# npm start
# curl http://localhost:8000/
# ^C
# $ again

# BD ------------------------------------

mysql -u root -pbea << NEWDB
DROP DATABASE IF EXISTS dbdevel;
NEWDB

npx sequelize-cli db:create

# modelo CLIENTE ------------------------------------

npx sequelize-cli model:generate --name cliente --attributes nombre:string,apellido:string
npx sequelize-cli db:migrate

# npx sequelize-cli seed:create --name cliente
cat << SEED-CLIENTE > seeders/0-cliente.js
'use strict';

module.exports = {
  async up (queryInterface, Sequelize) {
    await queryInterface.bulkInsert('clientes', [
      {
        nombre: 'John',
        apellido: 'Doe',
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        nombre: 'Maggie',
        apellido: 'Tatcher',
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ], {});
  },

  async down (queryInterface, Sequelize) {
    await queryInterface.bulkDelete('clientes', null, {});
  }
};
SEED-CLIENTE

npx sequelize-cli db:seed:all

# routing -------------------------------------
mkdir ./controllers
cat << controllerCLIENTE > ./controllers/cliente.js
const Sequelize     = require('sequelize');
const cliente       = require('../models').cliente;
module.exports = {

 list(_, res) {
     return cliente.findAll({})
        .then(cliente => res.status(200).send(cliente))
        .catch(error => res.status(400).send(error))
 },

 find(req, res) {
     return cliente.findAll({
         where: {
             nombre: req.params.nombre,
         }
     })
     .then(cliente => res.status(200).send(cliente))
     .catch(error => res.status(400).send(error))
  },

  create(req, res) {
    return cliente
      .create ({
        nombre:   req.params.nombre,
        apellido: req.params.apellido
      })
      .then(cliente => res.status(200).send(cliente))
      .catch(error => res.status(400).send(error))
  },

};
controllerCLIENTE

mkdir routes
cat << routesINDEXJS > ./routes/index.js
const clienteController = require('../controllers/cliente');
module.exports = (app) => {
   app.get('/api', (req, res) => res.status(200).send ({
        message: 'in devel: api web services access denied',
   }));
   app.get( '/api/cliente/list',                clienteController.list);
   app.get( '/api/cliente/find/nombre/:nombre', clienteController.find);
   app.post('/api/cliente/create/nombre/:nombre/apellido/:apellido', clienteController.create);
};
routesINDEXJS

