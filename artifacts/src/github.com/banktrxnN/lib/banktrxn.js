/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';


const { Contract } = require('fabric-contract-api');


class Banktrxn extends Contract {

    async GetAssetHistory(ctx, assetName) {

		let resultsIterator = await ctx.stub.getHistoryForKey(assetName);
		let results = await this._GetAllResults(resultsIterator, true);

		return JSON.stringify(results);
	}

    async _GetAllResults(iterator, isHistory) {
		let allResults = [];
		let res = await iterator.next();
		while (!res.done) {
			if (res.value && res.value.value.toString()) {
				let jsonRes = {};
				console.log(res.value.value.toString('utf8'));
				if (isHistory && isHistory === true) {
					jsonRes.TxId = res.value.txId;
					jsonRes.Timestamp = res.value.timestamp;
					try {
						jsonRes.Value = JSON.parse(res.value.value.toString('utf8'));
					} catch (err) {
						console.log(err);
						jsonRes.Value = res.value.value.toString('utf8');
					}
				} else {
					jsonRes.Key = res.value.key;
					try {
						jsonRes.Record = JSON.parse(res.value.value.toString('utf8'));
					} catch (err) {
						console.log(err);
						jsonRes.Record = res.value.value.toString('utf8');
					}
				}
				allResults.push(jsonRes);
			}
			res = await iterator.next();
		}
		iterator.close();
		return allResults;
	}

    async initLedger(ctx) {

        const banktxs = [
            {
                transactionId:'TX899',
                country: 'US',        
            currency:'dollar',
            amount:'56789',
            origin:'canada',
            },
            {
                transactionId:'TX8499',
                country: 'USSR',        
                currency:'doll',
                amount:'56789eee',
                origin:'canada',
            },
        ];

        for (let i = 0; i < banktxs.length; i++) {
            banktxs[i].docType = 'banktrxns';
            await ctx.stub.putState('banktxs' + i, Buffer.from(JSON.stringify(banktxs[i])));
            console.info('Added <--> ', banktxs[i]);
        }
    }

    async createBankTrxns(ctx, data) {
        console.info('============= START : createBankTrxns ===========');
        let obj = JSON. parse(data)
        
       await ctx.stub.putState(obj.transactionId, data);
        console.info('============= END : BankTrxns===========');
    }

    async changeBankTrxns(ctx, transactionId, newAmount) {
        console.info('============= START : changeBankTrxns ===========');

        const banktrxAsBytes = await ctx.stub.getState(transactionId); 
        if (!banktrxAsBytes || banktrxAsBytes.length === 0) {
            throw new Error(`${transactionId} does not exist`);
        }
        const banktrxns = JSON.parse(banktrxAsBytes.toString());
        banktrxns.amount = newAmount;

        await ctx.stub.putState(transactionId, Buffer.from(JSON.stringify(banktrxns)));
        console.info('============= END : change banktrxns ===========');
    }

    async queryBankTrxns(ctx, transactionId) {
        const banktrxnAsBytes = await ctx.stub.getState(transactionId); 
        if (!banktrxnAsBytes || banktrxnAsBytes.length === 0) {
            throw new Error(`${transactionId} does not exist`);
        }
        console.log(banktrxnAsBytes.toString());
        return banktrxnAsBytes.toString();
    }

}

module.exports = Banktrxn;
