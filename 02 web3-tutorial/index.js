const Web3 = require('web3'); // Web3
// const web3 = new Web3('http://localhost:8545');
// connected to blockchain !!!

// 1 way
// const provider = new Web3.providers.HttpProvider('http://localhost:8545');
// const web3 = new Web3(provider); // ganache client

// 2 way
// const customProvider = {
// 	sendAsync: (payload, cb) => {
// 		console.log('you called'); 	// 'you called'
// 		console.log(payload); 		// { jsonrpc: '2.0', id: 1, method: 'eth_blockNumber', params: [] }
// 		cb(undefined, 100);			// autoexec
// 	},
// };

// const web3 = new Web3(customProvider); // ganache client
// const web3 = new Web3(window.web3.currentProvider); // ??
// connected to the blockchain !!!
// web3.eth
// 	.getBlockNumber()
// 	.then(() => console.log('DONE!!!'))
// 	.catch((error) => console.log(error));

// comunicate with the smart contract
const MyContract = require('./build/contracts/MyContract.json'); // una vez hecho el primer build truffle develop
const init = async () => {
	const web3 = new Web3('http://localhost:9545');
	const id = await web3.eth.net.getId();
	const deployedNetwork = MyContract.networks[id];
	const contract = new web3.eth.Contract(MyContract.abi, deployedNetwork.address);

	// call contract instance to use methods
	// contract.methods.getData(arg1, arg2).call({ from: 'address', gasPrice: 100, gas: 10000 }); 	// with arguments
	// contract.methods.getData().call({ from: 'address', gasPrice: 100, gas: 'gasLimit' }); // whitout arguments
	// contract.methods.getData(arg1, arg2).call({}, (results) => {}); // transactions only
	// ************************** call
	const result = await contract.methods.getData().call(); // read data for the smart contract
	console.log(result); // return 0 by the moment
	// ************************** transaction
	const addresses = await web3.eth.getAccounts(); // all de adrresses
	const receipt = await contract.methods.setData(10).send({
		from: addresses[0],
		// gas: 100,
		// gasPrice: 100
	}); // ejecuta la transacción y devuelve un objeto receipt de transaccion realizada
	console.log(receipt);
	// another way
	// contract.methods.setData(10).send({
	// 	from: addresses[0],
	// })
	// 	.then(receipt => {
	// 		// ... code here
	// 	})
	// 	.catch( error => {
	// 		// ... code error here
	// 	});
	// there is another way with event emitter see video number 6
	// https://www.youtube.com/watch?v=xChKky8kb6A&list=PLbbtODcOYIoFs0PDlTdxpEsZiyDR2q9aA&index=6

	const data = await contract.methods.getData().call();
	console.log(data);
};

init();
