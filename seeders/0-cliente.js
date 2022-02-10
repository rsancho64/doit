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
