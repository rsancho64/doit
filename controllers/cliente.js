const Sequelize     = require('sequelize');
const cliente       = require('../models').cliente;
module.exports = {

 list(_, res) {
     return cliente.findAll({})
        .then(cliente => res.status(200).send(cliente))
        .catch(error => res.status(400).send(error))
 },

 find(req, res) {
    console.log('BODY: ' + req.body);   
    return cliente.findAll({
      where: {
        nombre: req.params.nombre,
      }
    })
    .then(cliente => res.status(200).send(cliente))
    .catch(error => res.status(400).send(error))
  },

  create(req, res) {
    console.log('BODY: ' + req.body);
    // return cliente.create ({
    //     nombre:   req.params.nombre,
    //     apellido: req.params.apellido
    //   })
    //   .then(cliente => res.status(200).send(cliente))
    //   .catch(error => res.status(400).send(error))
  },

};
