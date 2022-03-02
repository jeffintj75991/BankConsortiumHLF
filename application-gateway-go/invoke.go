package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"time"

	"github.com/hyperledger/fabric-gateway/pkg/client"
	gwproto "github.com/hyperledger/fabric-protos-go/gateway"
	"google.golang.org/grpc/status"
)

func createBankTrxnsCall(w http.ResponseWriter, r *http.Request) {
	//contract := createConnection()

	/////////////////////////
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
	/////////////////////////////
	reqBody, err := ioutil.ReadAll(r.Body)
	if err != nil {
		fmt.Fprintf(w, "Kindly enter data in correct format")
	}

	returnString := createBankTrxns(contract, string(reqBody))

	w.WriteHeader(http.StatusCreated)

	json.NewEncoder(w).Encode(returnString)
}

// Submit a transaction synchronously, blocking until it has been committed to the ledger.
func createBankTrxns(contract *client.Contract, reqBody string) string {
	fmt.Printf("Submit Transaction: createBankTrxns \n")
	fmt.Println("reqBody:", reqBody)
	_, err := contract.SubmitTransaction("CreateBankTrxns", reqBody)
	//_, err := contract.SubmitTransaction("CreateBankTrxns", "{\"transactionId\":\"TXN00000003\",\"country\":\"Indonesia\",\"currency\":\"Rupiah\",\"amount\":\"200000\", \"origin\":\"US\",\"date\":\"29-09-2021\"}")

	statusErr := status.Convert(err)
	for _, detail := range statusErr.Details() {
		errDetail := detail.(*gwproto.ErrorDetail)
		fmt.Printf("Error from endpoint: %s, mspId: %s, message: %s\n", errDetail.Address, errDetail.MspId, errDetail.Message)
	}

	if err != nil {
		panic(fmt.Errorf("failed to submit transaction: %w", err))
	}

	fmt.Printf("*** Transaction committed successfully\n")
	return "*** Transaction committed successfully****"
}
