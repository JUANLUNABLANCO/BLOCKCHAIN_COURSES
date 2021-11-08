const CryptoZombies = artifacts.require('ZombieFactory'); // obtenemos el contrato
const utils = require('./helpers/utils'); // utilidades
const time = require('./helpers/time'); // incrementador de tiempo para zombie attack
var expect = require('chai').expect;

const zombieNames = ['Zombie 1', 'Zombie 2']; // nombres inventados
contract('CryptoZombies', (accounts) => {
	// accounts= 10 addresses with 100 ether
	let [alice, bob] = accounts;
	// hooks
	beforeEach(async () => {
		const contractInstance = await CryptoZombies.new(); // instancia, mejor así
	});
	afterEach(async () => {
		await contractInstance.kill();
	});

	it('should be able to create a new zombie', async () => {
		// siempre async
		// const contractInstance = await CryptoZombies.new(); // instancia
		const result = await contractInstance.createRandomZombie(zombieNames[0], { from: alice });
		// assert.equal(result.receipt.status, true); // la transaccion ha sido realizada con exito
		expect(result.receipt.status).to.equal(true); // expect
		// assert.equal(result.logs[0].args.name, zombieNames[0]); // el propietario es alice
		expect(result.logs[0].args.name).to.equal(zombieNames[0]); // expect
	});
	it('should not allow two zombies', async () => {
		await contractInstance.createRandomZombie(zombieNames[0], { from: alice }); // creamos el
		// primer zombie no necesitamos recoger el result para nada
		await utils.shouldThrow(contractInstance.createRandomZombie(zombieNames[1], { from: alice })); // creamos el segundo zombie, que no
		// deberia estar permitido
	});
	context('with the single-step transfer scenario', async () => {
		it('should transfer a zombie', async () => {
			const result = await contractInstance.createRandomZombie(zombieNames[0], { from: alice }); // step 1
			const zombieId = result.logs[0].args.zombieId.toNumber(); // step 2
			await contractInstance.transferFrom(alice, bob, zombieId, { from: alice });
			const newOwner = await contractInstance.ownerOf(zombieId);
			// assert.equal(newOwner, bob);
			expect(newOwner).to.equal(bob);
		});
	});

	context('with the two-step transfer scenario', async () => {
		it('should approve and then transfer a zombie when the approved address calls transferFrom', async () => {
			const result = await contractInstance.createRandomZombie(zombieNames[0], { from: alice });
			const zombieId = result.logs[0].args.zombieId.toNumber();
			await contractInstance.approve(bob, zombieId, { from: alice });
			await contractInstance.transferFrom(alice, bob, zombieId, { from: bob });
			const newOwner = await contractInstance.ownerOf(zombieId);
			// assert.equal(newOwner, bob);
			expect(newOwner).to.equal(bob);
		});
		it('should approve and then transfer a zombie when the owner calls transferFrom', async () => {
			const result = await contractInstance.createRandomZombie(zombieNames[0], { from: alice });
			const zombieId = result.logs[0].args.zombieId.toNumber();
			await contractInstance.approve(bob, zombieId, { from: alice });
			await contractInstance.transferFrom(alice, bob, zombieId, { from: alice });
			await time.increase(time.duration.days(1));
			const newOwner = await contractInstance.ownerOf(zombieId);
			// assert.equal(newOwner, bob);
			expect(newOwner).to.equal(bob);
		});
	});
	it('zombies should be able to attack another zombie', async () => {
		let result;
		result = await contractInstance.createRandomZombie(zombieNames[0], { from: alice });
		const firstZombieId = result.logs[0].args.zombieId.toNumber();
		result = await contractInstance.createRandomZombie(zombieNames[1], { from: bob });
		const secondZombieId = result.logs[0].args.zombieId.toNumber();
		await time.increase(time.duration.days(1));
		await contractInstance.attack(firstZombieId, secondZombieId, { from: alice });
		// assert.equal(result.receipt.status, true);
		expect(result.receipt.status).to.equal(true);
	});
});
