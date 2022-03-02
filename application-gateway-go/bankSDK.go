/*
Copyright 2021 IBM All Rights Reserved.

SPDX-License-Identifier: Apache-2.0
*/

package main

import (
	"bytes"
	"crypto/x509"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"path"
	"time"

	"github.com/gorilla/mux"
	"github.com/hyperledger/fabric-gateway/pkg/client"
	"github.com/hyperledger/fabric-gateway/pkg/identity"
	gwproto "github.com/hyperledger/fabric-protos-go/gateway"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
	"google.golang.org/grpc/status"
)

const (
	mspID         = "UBSMSP"
	cryptoPath    = "../artifacts/channel/crypto-config/peerOrganizations/UBS.bank.com"
	certPath      = cryptoPath + "/users/User1@UBS.bank.com/msp/signcerts/cert.pem"
	keyPath       = cryptoPath + "/users/User1@UBS.bank.com/msp/keystore/"
	tlsCertPath   = cryptoPath + "/peers/peer0.UBS.bank.com/tls/ca.crt"
	peerEndpoint  = "localhost:7051"
	gatewayPeer   = "peer0.UBS.bank.com"
	channelName   = "bank-channel"
	chaincodeName = "banktrxn"
)

func main() {
	log.Println("============ application-golang starts ============")

	// The gRPC client connection should be shared by all Gateway connections to this endpoint

	router := mux.NewRouter().StrictSlash(true)

	router.HandleFunc("/createBank", createBankTrxnsCall).Methods("POST")
	router.HandleFunc("/getBankTxnById", getBankTxnByIdCall).Methods("POST")
	log.Fatal(http.ListenAndServe(":8082", router))

}

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

// newGrpcConnection creates a gRPC connection to the Gateway server.
func newGrpcConnection() *grpc.ClientConn {
	certificate, err := loadCertificate(tlsCertPath)
	if err != nil {
		panic(err)
	}

	certPool := x509.NewCertPool()
	certPool.AddCert(certificate)
	transportCredentials := credentials.NewClientTLSFromCert(certPool, gatewayPeer)

	connection, err := grpc.Dial(peerEndpoint, grpc.WithTransportCredentials(transportCredentials))
	if err != nil {
		panic(fmt.Errorf("failed to create gRPC connection: %w", err))
	}

	return connection
}

// newIdentity creates a client identity for this Gateway connection using an X.509 certificate.
func newIdentity() *identity.X509Identity {
	certificate, err := loadCertificate(certPath)
	if err != nil {
		panic(err)
	}

	id, err := identity.NewX509Identity(mspID, certificate)
	if err != nil {
		panic(err)
	}

	return id
}

func loadCertificate(filename string) (*x509.Certificate, error) {
	certificatePEM, err := ioutil.ReadFile(filename)
	if err != nil {
		return nil, fmt.Errorf("failed to read certificate file: %w", err)
	}
	return identity.CertificateFromPEM(certificatePEM)
}

// newSign creates a function that generates a digital signature from a message digest using a private key.
func newSign() identity.Sign {
	files, err := ioutil.ReadDir(keyPath)
	if err != nil {
		panic(fmt.Errorf("failed to read private key directory: %w", err))
	}
	privateKeyPEM, err := ioutil.ReadFile(path.Join(keyPath, files[0].Name()))
	//fmt.Println("privateKeyPEM:", string(privateKeyPEM))
	if err != nil {
		panic(fmt.Errorf("failed to read private key file: %w", err))
	}

	privateKey, err := identity.PrivateKeyFromPEM(privateKeyPEM)
	if err != nil {
		panic(err)
	}

	sign, err := identity.NewPrivateKeySign(privateKey)
	if err != nil {
		panic(err)
	}

	return sign
}

//Format JSON data
func formatJSON(data []byte) string {
	var prettyJSON bytes.Buffer
	if err := json.Indent(&prettyJSON, data, " ", ""); err != nil {
		panic(fmt.Errorf("failed to parse JSON: %w", err))
	}
	return prettyJSON.String()
}
