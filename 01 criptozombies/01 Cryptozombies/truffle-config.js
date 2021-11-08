/**
 * Use this file to configure your truffle project. It's seeded with some
 * common settings for different networks and features like migrations,
 * compilation and testing. Uncomment the ones you need or modify
 * them to suit your project as necessary.
 *
 * More information about configuration can be found at:
 *
 * trufflesuite.com/docs/advanced/configuration
 *
 * To deploy via Infura you'll need a wallet provider (like @truffle/hdwallet-provider)
 * to sign your transactions before they're sent to a remote public node. Infura accounts
 * are available for free at: infura.io/register.
 *
 * You'll also need a mnemonic - the twelve word phrase the wallet uses to generate
 * public/private key pairs. If you're publishing your code to GitHub make sure you load this
 * phrase from a file you've .gitignored so it doesn't accidentally become public.
 *
 */

// const HDWalletProvider = require('@truffle/hdwallet-provider');
// const infuraKey = "fj4jll3k.....";
//
// const fs = require('fs');
// const mnemonic = fs.readFileSync("./secret/.secret").toString().trim();
const HDWalletProvider = require('truffle-hdwallet-provider'); // truffle hdwallet provider
const LoomTruffleProvider = require('loom-truffle-provider'); // loom truffle provider

const { readFileSync } = require('fs');
const path = require('path');
const { join } = require('path');

const mnemonic = 'YOUR MNEMONIC HERE';

function getLoomProviderWithPrivateKey(privateKeyPath, chainId, writeUrl, readUrl) {
	const privateKey = readFileSync(privateKeyPath, 'utf-8');
	return new LoomTruffleProvider(chainId, writeUrl, readUrl, privateKey);
}

module.exports = {
	// Object with configuration for each network
	networks: {
		//development
		development: {
			host: '127.0.0.1',
			port: 7545,
			network_id: '*',
			gas: 9500000,
		},
		// Configuration for Ethereum Mainnet
		mainnet: {
			provider: function () {
				return new HDWalletProvider(mnemonic, 'https://mainnet.infura.io/v3/<YOUR_INFURA_API_KEY>');
			},
			network_id: '1', // Match any network id
		},
		// Configuration for Rinkeby Metwork
		rinkeby: {
			provider: function () {
				// Setting the provider with the Infura Rinkeby address and Token
				return new HDWalletProvider(mnemonic, 'https://rinkeby.infura.io/v3/<YOUR_INFURA_API_KEY>');
			},
			network_id: 4,
		},
		// Configuration for Loom Testnet
		loom_testnet: {
			provider: function () {
				const privateKey = 'YOUR_PRIVATE_KEY';
				const chainId = 'extdev-plasma-us1';
				const writeUrl = 'wss://extdev-basechain-us1.dappchains.com/websocket';
				const readUrl = 'wss://extdev-basechain-us1.dappchains.com/queryws';
				const loomTruffleProvider = new LoomTruffleProvider(chainId, writeUrl, readUrl, privateKey);
				loomTruffleProvider.createExtraAccountsFromMnemonic(mnemonic, 10);
				return loomTruffleProvider;
			},
			network_id: '9545242630824',
		},
		// configuration to basechain
		basechain: {
			provider: function () {
				const chainId = 'default';
				const writeUrl = 'http://basechain.dappchains.com/rpc';
				const readUrl = 'http://basechain.dappchains.com/query';
				return new LoomTruffleProvider(chainId, writeUrl, readUrl, privateKey);
				const privateKeyPath = path.join(__dirname, 'mainnet_private_key');
				const loomTruffleProvider = getLoomProviderWithPrivateKey(privateKeyPath, chainId, writeUrl, readUrl);
				return loomTruffleProvider;
			},
			network_id: '*',
		},
	},
	compilers: {
		solc: {
			version: '0.8.0', // '0.4.25'
		},
	},
};
