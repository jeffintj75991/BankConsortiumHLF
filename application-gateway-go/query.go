package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"time"

	"github.com/hyperledger/fabric-gateway/pkg/client"
)

func getBankTxnByIdCall(w http.ResponseWriter, r *http.Request) {
	//contract := createConnection()
	////////////////////////////////////////
	// The gRPC client connection should be shared by all Gateway connections to this endpoint
	clientConnection := newGrpcConnection()
	defer clientConnection.Close()

	id := newIdentity()
	sign := newSign()

	// Create a Gateway connection for a specific client identity
	gateway, err := client.Connect(
		id,
		client.WithSign(sign),
		client.WithClientConnection(clientConnection),
		// Default timeouts for different gRPC calls
		client.WithEvaluateTimeout(5*time.Second),
		client.WithEndorseTimeout(15*time.Second),
		client.WithSubmitTimeout(5*time.Second),
		client.WithCommitStatusTimeout(1*time.Minute),
	)
	if err != nil {
		panic(err)
	}
	defer gateway.Close()

	network := gateway.GetNetwork(channelName)
	contract := network.GetContract(chaincodeName)
	/////////////////////////////////////////

	reqBody, err := ioutil.ReadAll(r.Body)
	if err != nil {
		fmt.Fprintf(w, "Kindly enter data in correct format")
	}

	returnString := getBankTxnById(contract, string(reqBody))

	w.WriteHeader(http.StatusCreated)

	json.NewEncoder(w).Encode(returnString)
}

// Evaluate a transaction by assetID to query ledger state.
func getBankTxnById(contract *client.Contract, reqBody string) string {
	fmt.Printf("Evaluate Transaction: GetBankTxnById\n")

	evaluateResult, err := contract.EvaluateTransaction("GetBankTxnById", reqBody)
	if err != nil {
		panic(fmt.Errorf("failed to evaluate transaction: %w", err))
	}
	result := formatJSON(evaluateResult)

	fmt.Printf("*** Result:%s\n", result)
	return result
}
