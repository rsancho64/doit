const clienteController = require('../controllers/cliente');
module.exports = (app) => {
   app.get( '/api', (req, res) => res.status(200).send ({
        message: 'devel release: api web services access denied',
   }));
   app.get( '/api/cliente/list',                clienteController.list);
   app.get( '/api/cliente/find/nombre/:nombre', clienteController.find);
   app.post('/api/cliente/create/nombre/:nombre/apellido/:apellido', clienteController.create);
};
