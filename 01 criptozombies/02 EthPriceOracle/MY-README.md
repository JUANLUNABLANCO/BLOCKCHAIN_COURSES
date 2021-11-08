# STEPS to develop with truffle, ganache, etc

> npm install truffle ganache -g
> truffle init // inicia un proyecto ocn truffle
> npm install truffle-hdwallet-provider // to deploi in many networks
> truffle test // lanzar los test
> truffle compile // compile
> truffle migrate --network rinkeby // deploi a rinkery network
> truffle migrate --network mainnet // deploi to ethereum blockchain
> npm install loom-truffle-provider // instalar el nuevo provider de loom
> truffle migrate --network loom_testnet

## deploi to base chain

> ./ loom genkey -a mainnet_public_key -k mainnet_private_key
> touch .gitignore
> echo mainnet_private_key >> .gitignore

### truffle-config.js

    const { readFylelSync } = require('fs');
    const path = require('path');
    const { join } = require('path');
    loom_testnet : {
        provider: function() {
            const privateKey = 'YOUR_PRIVATE_KEY_READED_FROM_FILE_SECRET';
            const chainId = 'extedev-plama?-us1'; // WARNING CREO QUE NO ESTA BIEN ESCRITO see video 14-10
            const writeUrl = 'wss://extdev-basechain-us1/dappchains.com/websocket';
            const readUrl = 'wss://extdev-basechain-us1/dappchains.com/queryws';
            return new LoomTruffleProvider (chaiId, writeUrl, readUrl, privateKey);
        },
        networkId: 'extdev'
    }

## How to create a oracle

> mkdir caller && cd caller && npm init -y && cd ..
> mkdir oracle && cd oracle && npm init -y && cd ..
> npm install openzeppelin-solidity loom-js loom-truffle-provider bn.js axios
> npm install @openzeppelin/contracts

## PROBLEMS WITH NPM

> npm install --global --production windows-build-tools // in terminal with root permisions
> npm install --global --node-gyp
> npm install -g node-pre-gyp
> // ... sigue sin funcionar

### otra opción https://githubmemory.com/repo/barrysteyn/node-scrypt/issues/176 no probada

finally successfully installed workaround

reinstall vc++ build tools for vs2015

Manually add the string value in Computer\HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\MSBuild\ToolsVersions\14.0

key = VCTargetsPath
value = C:\Program Files (x86)\MSBuild\Microsoft.Cpp\v4.0\v140

## ....

## migrations

> cd oracle && npx truffle migrate --network extdev --reset -all && cd ..

// mira los scripts del package.json

> npm run deploy:all // subida a loom network

> node Client.js // arrancar cliente
